# frozen_string_literal: true

require 'rsolr'
require 'faraday/net_http_persistent'

module GeoCombine
  # Indexes Geoblacklight documents into Solr
  class Indexer
    attr_reader :solr

    def self.solr(url: ENV.fetch('SOLR_URL', 'http://127.0.0.1:8983/solr/blacklight-core'))
      RSolr.connect url: url, adapter: :net_http_persistent
    end

    def initialize(solr: GeoCombine::Indexer.solr)
      @solr = solr
    end

    def solr_url
      @solr.options[:url]
    end

    # Index everything and return the number of docs successfully indexed
    def index(docs, commit_within: ENV.fetch('SOLR_COMMIT_WITHIN', 5000).to_i)
      indexed_count = 0

      docs.each do |record, path|
        # log the unique identifier for the record for debugging
        id = record['id'] || record['dc_identifier_s']
        puts "Indexing #{id}: #{path}" if $DEBUG

        # index the record into solr
        @solr.update params: { commitWithin: commit_within, overwrite: true },
                     data: [record].to_json,
                     headers: { 'Content-Type' => 'application/json' }

        # count the number of records successfully indexed
        indexed_count += 1
      rescue RSolr::Error::Http => e
        puts e
      end

      @solr.commit
      indexed_count
    end
  end
end
