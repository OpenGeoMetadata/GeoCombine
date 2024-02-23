# frozen_string_literal: true

require 'rsolr'
require 'faraday/retry'
require 'faraday/net_http_persistent'
require 'geo_combine/logger'

module GeoCombine
  # Indexes Geoblacklight documents into Solr
  class Indexer
    attr_reader :solr

    def initialize(solr: nil, logger: GeoCombine::Logger.logger)
      @logger = logger
      @batch_size = ENV.fetch('SOLR_BATCH_SIZE', 100).to_i

      # If SOLR_URL is set, use it; if in a Geoblacklight app, use its solr core
      solr_url = ENV.fetch('SOLR_URL', nil)
      solr_url ||= Blacklight.default_index.connection.base_uri.to_s if defined? Blacklight

      # If neither, warn and try to use local Blacklight default solr core
      if solr_url.nil?
        @logger.warn 'SOLR_URL not set; using Blacklight default'
        solr_url = 'http://localhost:8983/solr/blacklight-core'
      end

      @solr = solr || RSolr.connect(client, url: solr_url)
    end

    # Index everything and return the number of docs successfully indexed
    def index(docs)
      # Track total indexed and time spent
      @logger.info "indexing into #{solr_url}"
      total_indexed = 0
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # Index in batches; set batch size via BATCH_SIZE
      batch = []
      docs.each do |doc, path|
        if batch.size < @batch_size
          batch << [doc, path]
        else
          total_indexed += index_batch(batch)
          batch = []
        end
      end
      total_indexed += index_batch(batch) unless batch.empty?

      # Issue a commit to make sure all documents are indexed
      @solr.commit
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      sec = end_time - start_time
      @logger.info format('indexed %<total_indexed>d documents in %<sec>.2f seconds', total_indexed:, sec:)
      total_indexed
    end

    # URL to the solr instance being used
    def solr_url
      @solr.options[:url]
    end

    private

    # Index a batch of documents; if we fail, index them all individually
    def index_batch(batch)
      docs = batch.map(&:first)
      @solr.update(data: batch_json(docs), params:, headers:)
      @logger.debug "indexed batch (#{batch.size} docs)"
      batch.size
    rescue RSolr::Error::Http => e
      @logger.error "error indexing batch (#{batch.size} docs): #{format_error(e)}"
      @logger.warn 'retrying documents individually'
      batch.map { |doc, path| index_single(doc, path) }.compact.size
    end

    # Index a single document; if it fails, log the error and continue
    def index_single(doc, path)
      @solr.add(doc, params:, headers:)
      @logger.debug "indexed #{path}"
      doc
    rescue RSolr::Error::Http => e
      @logger.error "error indexing #{path}: #{format_error(e)}"
      nil
    end

    # Generate a JSON string to send to solr update API for a batch of documents
    def batch_json(batch)
      batch.map { |doc| "add: { doc: #{doc.to_json} }" }.join(",\n").prepend('{ ').concat(' }')
    end

    # Generate a friendly error message for logging including status code and message
    def format_error(error)
      code = error.response[:status]
      status_info = "#{code} #{RSolr::Error::Http::STATUS_CODES[code.to_i]}"
      error_info = parse_solr_error(error)
      [status_info, error_info].compact.join(' - ')
    end

    # Extract the specific error message from a solr JSON error response, if any
    def parse_solr_error(error)
      JSON.parse(error.response[:body]).dig('error', 'msg')
    rescue StandardError
      nil
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

    def params
      { overwrite: true }
    end

    def client
      @client ||= Faraday.new do |conn|
        conn.request :retry, max: 3, interval: 1, backoff_factor: 2, exceptions: [
          Faraday::TimeoutError,
          Faraday::ConnectionFailed,
          Faraday::TooManyRequestsError
        ]
        conn.response :raise_error
        conn.adapter :net_http_persistent
      end
    end
  end
end
