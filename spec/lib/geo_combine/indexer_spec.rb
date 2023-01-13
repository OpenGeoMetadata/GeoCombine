# frozen_string_literal: true

require 'geo_combine/indexer'
require 'spec_helper'

RSpec.describe GeoCombine::Indexer do
  subject(:indexer) { described_class.new(solr: solr) }

  let(:solr) { instance_double(RSolr::Client) }
  let(:docs) do
    [
      [{ 'id' => '1' }, 'path/to/record1.json'],              # v1.0 schema
      [{ 'dc_identifier_s' => '2' }, 'path/to/record2.json']  # aardvark schema
    ]
  end

  before do
    allow(solr).to receive(:update)
    allow(solr).to receive(:commit)
  end

  describe '#initialize' do
    before do
      stub_const('ENV', 'SOLR_URL' => 'http://localhost:8983/solr/geoblacklight')
      allow(RSolr).to receive(:connect).and_return(solr)
    end

    it 'connects to a solr instance if set in the environment' do
      described_class.new
      expect(RSolr).to have_received(:connect).with(
        url: 'http://localhost:8983/solr/geoblacklight',
        adapter: :net_http_persistent
      )
    end
  end

  describe '#index' do
    it 'posts each record to solr as JSON' do
      indexer.index([docs[0]], commit_within: 1)
      expect(solr).to have_received(:update).with(
        params: { commitWithin: 1, overwrite: true },
        data: [docs[0][0]].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'prints the id and path of each record in debug mode' do
      $DEBUG = true
      expect { indexer.index([docs[0]]) }.to output("Indexing 1: path/to/record1.json\n").to_stdout
      expect { indexer.index([docs[1]]) }.to output("Indexing 2: path/to/record2.json\n").to_stdout
      $DEBUG = false
    end

    it 'commits changes to solr after indexing' do
      indexer.index(docs)
      expect(solr).to have_received(:commit).once
    end

    it 'returns the count of records successfully indexed' do
      expect(indexer.index(docs)).to eq 2
    end
  end
end
