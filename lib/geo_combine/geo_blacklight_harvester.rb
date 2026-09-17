# frozen_string_literal: true

require 'net/http'
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
      attr_reader :crawl_delay, :headers

      def initialize(crawl_delay: nil, headers: {}, logger: GeoCombine::Logger.logger)
        @crawl_delay = crawl_delay&.to_f
        @headers = headers.to_h { |name, value| [name.to_s, value.to_s] }
        @logger = logger
      end

      # Fetch a URL and parse the JSON response body
      def get_json(url)
        JSON.parse(get(url))
      end

      private

      # Fetch a URL and return the response body
      def get(url)
        throttle
        Net::HTTP.get_response(URI(url), headers).body
      end

      # Wait out the crawl delay, if one is configured
      def throttle
        return unless crawl_delay

        @logger.debug "waiting #{crawl_delay}s before the next request"
        sleep(crawl_delay)
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

          begin
            self.response = client.get_json(url)
          rescue StandardError => e
            @logger.error "request for #{url} failed with #{e}"
            self.response = nil
          end
        end
      end

      private

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
          document_urls = response['data'].collect { |data| data.dig('links', 'self') }.compact

          yield documents_from_urls(document_urls)

          url = response.dig('links', 'next')
          break unless url

          url = "#{url}&format=json"
          self.page += 1
          @logger.debug "fetching page #{page} @ #{url}"
          begin
            self.response = client.get_json(url)
          rescue StandardError => e
            @logger.error "Request for #{url} failed with #{e}"
            self.response = nil
          end
        end
      end

      private

      def documents_from_urls(urls)
        @logger.debug "fetching #{urls.count} documents for page #{page}"
        urls.map do |url|
          client.get_json("#{url}/raw")
        rescue StandardError => e
          @logger.error "fetching \"#{url}/raw\" failed with #{e}"

          nil
        end.compact
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
      @client ||= HttpClient.new(crawl_delay:, headers:, logger: @logger)
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
