# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'geo_combine/exceptions'
require 'geo_combine/logger'

module GeoCombine
  ##
  # A class to harvest and index results from GeoBlacklight sites
  # You can configure the sites to be harvested via a configure command.
  # GeoCombine::GeoBlacklightHarvester.configure do
  #   {
  #     SITE: { host: 'https://example.com', params: { f: { dct_provenance_s: ['SITE'] } } }
  #   }
  # end
  # The class configuration also allows for various other things to be configured:
  #  - A debug parameter to print out details of what is being harvested and indexed
  #  - crawl delays between requests (globally or on a per site basis)
  #  - headers to send with every request (globally or on a per site basis)
  #  - retries and backoff for failed requests (globally or on a per site basis)
  #  - Solr's commitWithin parameter (defaults to 5000)
  #  - A document transformer proc to modify a document before indexing (defaults to removing _version_, score, and timestamp)
  # Example: GeoCombine::GeoBlacklightHarvester.new('SITE').index
  class GeoBlacklightHarvester
    require 'active_support/core_ext/object/to_query'

    class << self
      attr_writer :document_transformer

      def configure(&block)
        @config = yield block
      end

      def config
        @config || {}
      end

      def document_transformer
        @document_transformer || lambda do |document|
          document.delete('_version_')
          document.delete('score')
          document.delete('timestamp')
          document.delete('solr_bboxtype__minX')
          document.delete('solr_bboxtype__minY')
          document.delete('solr_bboxtype__maxX')
          document.delete('solr_bboxtype__maxY')
          document
        end
      end
    end

    attr_reader :site, :site_key

    def initialize(site_key, logger: GeoCombine::Logger.logger)
      @site_key = site_key
      @site = self.class.config[site_key]
      @logger = logger

      raise ArgumentError, "Site key #{@site_key.inspect} is not configured for #{self.class.name}" unless @site
    end

    # Index the documents harvested from the site into Solr
    def index
      each_page do |documents|
        @logger.debug "adding #{documents.count} documents to solr"
        solr_connection.update params: { commitWithin: commit_within, overwrite: true },
                               data: documents.to_json,
                               headers: { 'Content-Type' => 'application/json' }
      end
    end

    # Enumerable of the documents harvested from the site, for passing to an
    # indexer or doing something else with them (e.g. writing them to disk).
    # Documents have already been through the configured document transformer.
    def each_document(&block)
      return to_enum(:each_document) unless block_given?

      each_page { |documents| documents.each(&block) }
    end

    ##
    # Makes the requests for a harvest, waiting out the configured crawl delay
    # before each one. Each request gets its own connection instead of reusing
    # one; a request that is both paced and freshly connected is much less
    # likely to be turned away by a WAF or other bot mitigation.
    class HttpClient
      # Failures that are worth retrying rather than ending a harvest over
      RETRIABLE_ERRORS = [
        Errno::ECONNRESET,
        Errno::EPIPE,
        EOFError,
        Net::OpenTimeout,
        Net::ReadTimeout,
        OpenSSL::SSL::SSLError,
        SocketError
      ].freeze

      DEFAULT_MAX_RETRIES = 3
      DEFAULT_RETRY_DELAY = 2

      # Raised internally to signal a response that is worth retrying
      class RetriableResponse < StandardError; end

      attr_reader :crawl_delay, :headers, :max_retries, :retry_delay

      def initialize(crawl_delay: nil, headers: {}, max_retries: nil, retry_delay: nil,
                     logger: GeoCombine::Logger.logger)
        @crawl_delay = crawl_delay&.to_f
        @headers = headers.to_h { |name, value| [name.to_s, value.to_s] }
        @max_retries = (max_retries || DEFAULT_MAX_RETRIES).to_i
        @retry_delay = (retry_delay || DEFAULT_RETRY_DELAY).to_f
        @logger = logger
      end

      # Fetch a URL and parse the JSON response body, retrying failures that
      # look transient and raising if the harvest cannot go on
      def get_json(url)
        with_retries(url) { parse_json(get(url), url) }
      end

      private

      # Fetch a URL and return the response
      def get(url)
        throttle
        Net::HTTP.get_response(URI(url), headers)
      end

      # Wait out the crawl delay, if one is configured
      def throttle
        return unless crawl_delay

        @logger.debug "waiting #{crawl_delay}s before the next request"
        sleep(crawl_delay)
      end

      # Retry transient failures with an exponential backoff. A request that
      # still cannot be completed ends the harvest rather than quietly
      # truncating it.
      def with_retries(url)
        attempts = 0

        begin
          attempts += 1
          yield
        rescue *RETRIABLE_ERRORS, RetriableResponse => e
          raise Exceptions::HarvestError, "request for #{url} failed after #{attempts} attempts: #{e.message}" if attempts > max_retries

          delay = retry_delay * (2**(attempts - 1))
          @logger.warn "request for #{url} failed with #{e.message}; retrying in #{delay}s"
          sleep(delay)
          retry
        end
      end

      # Parse a response body, or raise if it isn't a document we can use.
      # Bot mitigation often answers with a 200 and a page of HTML, so the
      # status code alone isn't enough to tell a good response from a bad one.
      def parse_json(response, url)
        raise Exceptions::DocumentNotFound, "#{url} was not found" if response.is_a?(Net::HTTPNotFound)
        raise RetriableResponse, status(response) if retriable?(response)

        raise Exceptions::HarvestError, "request for #{url} failed with #{status(response)}" unless response.is_a?(Net::HTTPSuccess)

        parsed = JSON.parse(response.body.to_s)
        raise RetriableResponse, 'a JSON body that is not an object' unless parsed.is_a?(Hash)

        parsed
      rescue JSON::ParserError
        raise RetriableResponse, "a body that is not JSON (content type: #{response.content_type || 'none'})"
      end

      # Server errors and rate limiting are worth waiting out and retrying
      def retriable?(response)
        response.is_a?(Net::HTTPServerError) || response.is_a?(Net::HTTPTooManyRequests)
      end

      def status(response)
        "#{response.code} #{response.message}"
      end
    end

    ##
    # A "factory" class to determine the blacklight response version to use
    class BlacklightResponseVersionFactory
      def self.call(json)
        keys = json.keys
        if keys.include?('response')
          LegacyBlacklightResponse
        elsif keys.any? && %w[links data].all? { |param| keys.include?(param) }
          ModernBlacklightResponse
        else
          raise NotImplementedError,
                "The following json response was not able to be parsed by the GeoBlacklightHarvester\n#{json}"
        end
      end
    end

    class LegacyBlacklightResponse
      attr_reader :base_url, :client
      attr_accessor :response, :page

      def initialize(response:, base_url:, logger: GeoCombine::Logger.logger, client: HttpClient.new(logger:))
        @base_url = base_url
        @response = response
        @client = client
        @page = 1
        @logger = logger
      end

      def documents
        return enum_for(:documents) unless block_given?

        while current_page && total_pages && (current_page <= total_pages)
          yield response.dig('response', 'docs')

          break if current_page == total_pages

          self.page += 1
          @logger.debug "fetching page #{page} @ #{url}"
          self.response = client.get_json(url)
          validate_page!
        end
      end

      private

      # Only the first page of a harvest goes through the response factory. A
      # 200 carrying JSON that isn't a page of search results -- a WAF or API
      # gateway rejection, say -- would otherwise read as the end of the
      # results and finish the harvest as though nothing had gone wrong.
      def validate_page!
        return if current_page && total_pages

        raise Exceptions::HarvestError, "response for #{url} was not a page of search results"
      end

      def url
        "#{base_url}&page=#{page}"
      end

      def current_page
        response&.dig('response', 'pages', 'current_page')
      end

      def total_pages
        response&.dig('response', 'pages', 'total_pages')
      end
    end

    ##
    # Class to return documents from the Blacklight API (v7 and above)
    class ModernBlacklightResponse
      attr_reader :base_url, :client
      attr_accessor :response, :page

      def initialize(response:, base_url:, logger: GeoCombine::Logger.logger, client: HttpClient.new(logger:))
        @base_url = base_url
        @response = response
        @client = client
        @page = 1
        @logger = logger
      end

      def documents
        return enum_for(:documents) unless block_given?

        while response && response['data'].any?
          document_urls = document_urls_from(response['data'])

          yield documents_from_urls(document_urls)

          url = response.dig('links', 'next')
          break unless url

          url = "#{url}&format=json"
          self.page += 1
          @logger.debug "fetching page #{page} @ #{url}"
          self.response = client.get_json(url)
          validate_page!(url)
        end
      end

      private

      # Only the first page of a harvest goes through the response factory. A
      # 200 carrying JSON that isn't a page of search results -- a WAF or API
      # gateway rejection, say -- would otherwise read as the end of the
      # results and finish the harvest as though nothing had gone wrong.
      def validate_page!(url)
        return if response['data'].is_a?(Array)

        raise Exceptions::HarvestError, "response for #{url} was not a page of search results"
      end

      # A result with no link to itself can't be fetched; say which one rather
      # than letting it disappear from the harvest
      def document_urls_from(data)
        data.filter_map do |result|
          url = result.dig('links', 'self')
          @logger.warn "skipping result with no self link: #{result.inspect}" unless url

          url
        end
      end

      def documents_from_urls(urls)
        @logger.debug "fetching #{urls.count} documents for page #{page}"
        documents = urls.map do |url|
          client.get_json("#{url}/raw")
        rescue Exceptions::DocumentNotFound => e
          # A record can be indexed but unreadable; log it and move on
          @logger.warn "skipping document: #{e.message}"

          nil
        end.compact
        @logger.error "skipped every document on page #{page}" if documents.empty? && urls.any?

        documents
      end
    end

    private

    # Enumerable of pages of transformed documents harvested from the site
    def each_page
      return to_enum(:each_page) unless block_given?

      @logger.debug "fetching page 1 @ #{base_url}&page=1"
      response = client.get_json("#{base_url}&page=1")
      response_class = BlacklightResponseVersionFactory.call(response)

      response_class.new(response:, base_url:, client:, logger: @logger).documents.each do |documents|
        yield documents.map { |document| self.class.document_transformer&.call(document) }.compact
      end
    end

    # The client used to make requests for this site
    def client
      @client ||= HttpClient.new(crawl_delay:, headers:, max_retries:, retry_delay:, logger: @logger)
    end

    def base_url
      "#{site[:host]}?#{default_params.to_query}"
    end

    def solr_connection
      solr_url = ENV['SOLR_URL'] || 'http://127.0.0.1:8983/solr/blacklight-core'

      RSolr.connect url: solr_url, adapter: :net_http_persistent
    end

    def commit_within
      self.class.config[:commit_within] || '5000'
    end

    def crawl_delay
      site[:crawl_delay] || self.class.config[:crawl_delay]
    end

    # How many times to retry a request that fails transiently
    def max_retries
      site[:max_retries] || self.class.config[:max_retries]
    end

    # How long to wait before the first retry; it doubles with each attempt
    def retry_delay
      site[:retry_delay] || self.class.config[:retry_delay]
    end

    # Headers to send with every request, e.g. to identify the harvester to a
    # WAF or bot detection, or to authenticate it. Headers configured for the
    # site are merged over any configured globally.
    def headers
      (self.class.config[:headers] || {}).merge(site[:headers] || {})
    end

    def default_params
      {
        per_page: 100,
        format: :json
      }.merge(site[:params])
    end
  end
end
