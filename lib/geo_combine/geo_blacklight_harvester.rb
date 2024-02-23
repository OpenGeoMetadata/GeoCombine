# frozen_string_literal: true

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
  #  - crawl delays for each page of results (globally or on a per site basis)
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

    def index
      @logger.debug "fetching page 1 @ #{base_url}&page=1"
      response = JSON.parse(Net::HTTP.get(URI("#{base_url}&page=1")))
      response_class = BlacklightResponseVersionFactory.call(response)

      response_class.new(response:, base_url:, logger: @logger).documents.each do |docs|
        docs.map! do |document|
          self.class.document_transformer&.call(document)
        end.compact

        @logger.debug "adding #{docs.count} documents to solr"
        solr_connection.update params: { commitWithin: commit_within, overwrite: true },
                               data: docs.to_json,
                               headers: { 'Content-Type' => 'application/json' }

        sleep(crawl_delay.to_i) if crawl_delay
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
      attr_reader :base_url
      attr_accessor :response, :page

      def initialize(response:, base_url:, logger: GeoCombine::Logger.logger)
        @base_url = base_url
        @response = response
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
            self.response = JSON.parse(Net::HTTP.get(URI(url)))
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
        response.dig('response', 'pages', 'current_page')
      end

      def total_pages
        response.dig('response', 'pages', 'total_pages')
      end
    end

    ##
    # Class to return documents from the Blacklight API (v7 and above)
    class ModernBlacklightResponse
      attr_reader :base_url
      attr_accessor :response, :page

      def initialize(response:, base_url:, logger: GeoCombine::Logger.logger)
        @base_url = base_url
        @response = response
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
            self.response = JSON.parse(Net::HTTP.get(URI(url)))
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
          JSON.parse(Net::HTTP.get(URI("#{url}/raw")))
        rescue StandardError => e
          @logger.error "fetching \"#{url}/raw\" failed with #{e}"

          nil
        end.compact
      end
    end

    private

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

    def default_params
      {
        per_page: 100,
        format: :json
      }.merge(site[:params])
    end
  end
end
