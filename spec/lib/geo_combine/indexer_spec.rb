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
      [{ 'id' => '1' }, 'path/to/record1.json'],              # aardvark schema
      [{ 'dc_identifier_s' => '2' }, 'path/to/record2.json']  # v1.0 schema
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

      it 'logs the status and the message solr returned' do
        indexer.index(docs)
        expect(logger).to have_received(:error).with(/400 Bad Request - error message/).at_least(:once)
      end
    end

    context 'when solr returns an error that is not JSON' do
      let(:solr_error_msg) { +'<html>Bad Gateway</html>' }
      let(:solr_response) { { status: '502', body: solr_error_msg } }

      before do
        allow(solr).to receive(:update).and_raise(error)
        allow(solr).to receive(:add).and_raise(error)
      end

      it 'logs the status rather than raising an error while parsing' do
        expect { indexer.index(docs) }.not_to raise_error
        expect(logger).to have_received(:error).with(/502 Bad Gateway$/).at_least(:once)
      end
    end

    context 'when a request to solr times out' do
      let(:timeout) { Faraday::TimeoutError.new('Net::ReadTimeout') }

      before do
        # Timeouts have no response; RSolr raises them with the Faraday error as the cause
        allow(solr).to receive(:update) { raise RSolr::Error::Timeout.new({ uri: URI('') }, nil), cause: timeout }
        allow(solr).to receive(:add)
      end

      it 'attempts to index records individually' do
        expect(indexer.index(docs)).to eq 2
      end

      it 'logs the timeout rather than raising an error while formatting' do
        indexer.index(docs)
        expect(logger).to have_received(:error).with('error indexing batch (2 docs): RSolr::Error::Timeout - Net::ReadTimeout')
      end
    end

    context 'when a request to solr times out and then succeeds' do
      subject(:indexer) { described_class.new(solr_url: 'http://solr.example.com/solr/test', logger:) }

      before do
        stub_request(:post, %r{solr\.example\.com/solr/test/update})
          .to_raise(Net::ReadTimeout).then
          .to_return(status: 200, body: +'{}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'retries the request' do
        expect(indexer.index(docs)).to eq 2
        # the timed out update, the retried update, and the commit
        expect(a_request(:post, %r{solr\.example\.com/solr/test/update})).to have_been_made.times(3)
        expect(logger).not_to have_received(:error)
      end
    end
  end

  describe '#delete' do
    let(:solr_response) { { status: '400', body: { error: { msg: 'error message' } }.to_json } }
    let(:error) { RSolr::Error::Http.new({ uri: URI('') }, solr_response) }

    before do
      allow(solr).to receive(:delete_by_id)
    end

    it 'deletes ids in batches, by id' do
      indexer.delete(%w[a:1 b/2])
      expect(solr).to have_received(:delete_by_id).with(%w[a:1 b/2])
    end

    it 'commits after deleting' do
      indexer.delete(%w[a b])
      expect(solr).to have_received(:delete_by_id).ordered
      expect(solr).to have_received(:commit).ordered
    end

    it 'returns the ids deleted' do
      expect(indexer.delete(%w[a b])).to eq %w[a b]
    end

    it 'never deletes by query, rolls back, or optimizes' do
      allow(solr).to receive_messages(delete_by_query: nil, rollback: nil, optimize: nil)
      indexer.delete(%w[a b])
      expect(solr).not_to have_received(:delete_by_query)
      expect(solr).not_to have_received(:rollback)
      expect(solr).not_to have_received(:optimize)
    end

    context 'when the number of ids is greater than batch size' do
      before do
        stub_const('ENV', 'SOLR_BATCH_SIZE' => 10)
      end

      it 'deletes the ids in batches' do
        expect(indexer.delete((1..25).map(&:to_s)).size).to eq 25
        expect(solr).to have_received(:delete_by_id).exactly(3).times
      end
    end

    context 'when an error occurs deleting a batch' do
      before do
        allow(solr).to receive(:delete_by_id).with(%w[a b]).and_raise(error)
        allow(solr).to receive(:delete_by_id).with('a')
        allow(solr).to receive(:delete_by_id).with('b').and_raise(error)
      end

      it 'retries the ids individually and returns those deleted' do
        expect(indexer.delete(%w[a b])).to eq %w[a]
      end

      it 'logs the ids that could not be deleted' do
        indexer.delete(%w[a b])
        expect(logger).to have_received(:error).with('error deleting b: 400 Bad Request - error message')
      end

      it 'still commits' do
        indexer.delete(%w[a b])
        expect(solr).to have_received(:commit)
      end
    end

    context 'when a request to solr times out' do
      let(:timeout) { Faraday::TimeoutError.new('Net::ReadTimeout') }

      before do
        allow(solr).to receive(:delete_by_id).with(%w[a b]) { raise RSolr::Error::Timeout.new({ uri: URI('') }, nil), cause: timeout }
      end

      it 'retries the ids individually and returns those deleted' do
        expect(indexer.delete(%w[a b])).to eq %w[a b]
      end

      it 'logs the timeout' do
        indexer.delete(%w[a b])
        expect(logger).to have_received(:error).with('error deleting batch (2 ids): RSolr::Error::Timeout - Net::ReadTimeout')
      end
    end
  end
end
