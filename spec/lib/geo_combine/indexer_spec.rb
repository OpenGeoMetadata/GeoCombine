# frozen_string_literal: true

require 'geo_combine/indexer'
require 'spec_helper'

# Mock an available Blacklight installation
class FakeBlacklight
  def self.default_index
    Repository
  end

  class Repository
    def self.connection; end
  end
end

RSpec.describe GeoCombine::Indexer do
  subject(:indexer) { described_class.new(solr:, logger:) }

  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil, debug: nil) }
  let(:solr) { instance_double(RSolr::Client, options: { url: 'TEST' }) }
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
      allow(RSolr).to receive(:connect).and_return(solr)
    end

    context 'when solr url is set in the environment' do
      before do
        stub_const('ENV', 'SOLR_URL' => 'http://localhost:8983/solr/geoblacklight')
      end

      it 'connects to the solr instance' do
        described_class.new(logger:)
        expect(RSolr).to have_received(:connect).with(
          be_a(Faraday::Connection),
          url: 'http://localhost:8983/solr/geoblacklight'
        )
      end
    end

    context 'when there is a configured Blacklight connection' do
      before do
        stub_const('Blacklight', FakeBlacklight)
        allow(FakeBlacklight::Repository).to receive(:connection).and_return(
          instance_double(RSolr::Client, base_uri: URI('http://localhost:8983/solr/geoblacklight'))
        )
      end

      it 'connects to the solr instance' do
        described_class.new(logger:)
        expect(RSolr).to have_received(:connect).with(
          be_a(Faraday::Connection),
          url: 'http://localhost:8983/solr/geoblacklight'
        )
      end
    end

    context 'when solr url is not set' do
      before do
        stub_const('ENV', {})
      end

      it 'falls back to the Blacklight default' do
        described_class.new(logger:)
        expect(RSolr).to have_received(:connect).with(
          be_a(Faraday::Connection),
          url: 'http://localhost:8983/solr/blacklight-core'
        )
      end
    end
  end

  describe '#index' do
    let(:solr_error_msg) {  { error: { msg: 'error message' } }.to_json }
    let(:solr_response) { { status: '400', body: solr_error_msg } }
    let(:error) { RSolr::Error::Http.new({ uri: URI('') }, solr_response) }

    it 'sends records in batches to solr' do
      indexer.index(docs)
      expect(solr).to have_received(:update).with(
        data: "{ add: { doc: {\"id\":\"1\"} },\nadd: { doc: {\"dc_identifier_s\":\"2\"} } }",
        headers: { 'Content-Type' => 'application/json' },
        params: { overwrite: true }
      )
    end

    context 'when the number of docs is greater than batch size' do
      before do
        stub_const('ENV', 'SOLR_BATCH_SIZE' => 10)
      end

      let(:docs) { (1..40).map { |n| [{ 'id' => n }, "path/to/record#{n}.json"] } }

      it 'indexes the correct number of documents' do
        expect(indexer.index(docs)).to eq 40
      end
    end

    it 'commits changes to solr after indexing' do
      indexer.index(docs)
      expect(solr).to have_received(:commit).once
    end

    it 'returns the count of records successfully indexed' do
      expect(indexer.index(docs)).to eq 2
    end

    context 'when an error occurs during batch indexing' do
      before do
        allow(solr).to receive(:update).and_raise(error)
        allow(solr).to receive(:add)
      end

      it 'attempts to index records individually' do
        total = indexer.index(docs)
        expect(solr).to have_received(:add).twice
        expect(total).to eq 2
      end
    end

    context 'when an error occurs during individual indexing' do
      before do
        allow(solr).to receive(:update).and_raise(error)
        allow(solr).to receive(:add).with(docs[0][0], anything).and_raise(error)
        allow(solr).to receive(:add).with(docs[1][0], anything)
      end

      it 'continues indexing' do
        total = indexer.index(docs)
        expect(total).to eq 1
      end
    end
  end
end
