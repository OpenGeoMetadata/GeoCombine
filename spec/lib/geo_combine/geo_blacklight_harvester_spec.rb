# frozen_string_literal: true

require 'net/http'
require 'spec_helper'
require 'rsolr'

RSpec.describe GeoCombine::GeoBlacklightHarvester do
  subject(:harvester) { described_class.new(site_key, logger:) }

  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil, debug: nil) }
  let(:site_key) { :INSTITUTION }
  let(:base_url) { 'https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100' }
  let(:stub_json_response) { '{}' }
  let(:stub_solr_connection) { double('RSolr::Connection') }
  let(:site_config) do
    { host: 'https://example.com/', params: { f: { dct_provenance_s: ['INSTITUTION'] } } }
  end
  let(:config) { { INSTITUTION: site_config } }

  # Requests are stubbed with webmock; make sure none of them escape
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  before { allow(described_class).to receive(:config).and_return(config) }

  describe '.configure' do
    around do |example|
      previous = described_class.instance_variable_get(:@config)
      example.run
      described_class.instance_variable_set(:@config, previous)
    end

    before { allow(described_class).to receive(:config).and_call_original }

    it 'defaults to an empty hash' do
      described_class.instance_variable_set(:@config, nil)
      expect(described_class.config).to eq({})
    end

    it 'stores what the block returns' do
      described_class.configure { { SITE: { host: 'https://example.com/' } } }
      expect(described_class.config).to eq(SITE: { host: 'https://example.com/' })
    end
  end

  describe 'initialization' do
    context 'when an unconfigured site is sent in' do
      let(:site_key) { 'unknown' }

      it { expect { harvester }.to raise_error(ArgumentError) }
    end
  end

  describe '#index' do
    before do
      stub_request(:get, "#{base_url}&page=1").to_return(body: stub_json_response)
      allow(RSolr).to receive(:connect).and_return(stub_solr_connection)
    end

    let(:docs) { [{ layer_slug_s: 'abc-123' }, { layer_slug_s: 'abc-321' }] }
    let(:stub_json_response) do
      { response: { docs:, pages: { current_page: 1, total_pages: 1 } } }.to_json
    end

    it 'adds documents returned to solr' do
      expect(stub_solr_connection).to receive(:update).with(hash_including(data: docs.to_json)).and_return(nil)
      harvester.index
    end

    describe 'document tranformations' do
      let(:docs) do
        [
          { layer_slug_s: 'abc-123', _version_: '1', timestamp: '1999-12-31', score: 0.1,
            solr_bboxtype__minX: -87.324704, solr_bboxtype__minY: 40.233691, solr_bboxtype__maxX: -87.174404, solr_bboxtype__maxY: 40.310695 },
          { layer_slug_s: 'abc-321', dc_source_s: 'abc-123' }
        ]
      end

      context 'when a tranformer is set' do
        before do
          expect(described_class).to receive(:document_transformer).at_least(:once).and_return(
            lambda { |doc|
              doc.delete('_version_')
              doc
            }
          )
        end

        it 'removes the _version_ field as requested' do
          expect(stub_solr_connection).to receive(:update).with(
            hash_including(
              data: [
                { layer_slug_s: 'abc-123', timestamp: '1999-12-31', score: 0.1, solr_bboxtype__minX: -87.324704,
                  solr_bboxtype__minY: 40.233691, solr_bboxtype__maxX: -87.174404, solr_bboxtype__maxY: 40.310695 },
                { layer_slug_s: 'abc-321', dc_source_s: 'abc-123' }
              ].to_json
            )
          ).and_return(nil)

          harvester.index
        end
      end

      context 'when no transformer is set' do
        it 'removes the _version_, timestamp, score, and solr_bboxtype__* fields' do
          expect(stub_solr_connection).to receive(:update).with(
            hash_including(
              data: [
                { layer_slug_s: 'abc-123' },
                { layer_slug_s: 'abc-321', dc_source_s: 'abc-123' }
              ].to_json
            )
          ).and_return(nil)

          harvester.index
        end
      end
    end
  end

  describe '#each_document' do
    before { stub_request(:get, "#{base_url}&page=1").to_return(body: stub_json_response) }

    let(:docs) { [{ 'layer_slug_s' => 'abc-123', 'score' => 0.1 }, { 'layer_slug_s' => 'abc-321' }] }
    let(:transformed_docs) { [{ 'layer_slug_s' => 'abc-123' }, { 'layer_slug_s' => 'abc-321' }] }
    let(:stub_json_response) do
      { response: { docs:, pages: { current_page: 1, total_pages: 1 } } }.to_json
    end

    it 'yields each transformed document' do
      expect { |block| harvester.each_document(&block) }.to yield_successive_args(*transformed_docs)
    end

    it 'returns an enumerator when no block is given' do
      expect(harvester.each_document.to_a).to eq(transformed_docs)
    end

    context 'when the document transformer omits a document' do
      before do
        allow(described_class).to receive(:document_transformer).and_return(
          ->(document) { document unless document['layer_slug_s'] == 'abc-123' }
        )
      end

      it 'does not yield the omitted document' do
        expect { |block| harvester.each_document(&block) }.to yield_successive_args({ 'layer_slug_s' => 'abc-321' })
      end
    end
  end

  describe 'HttpClient' do
    let(:client) { described_class::HttpClient.new(crawl_delay:, logger:) }
    let(:crawl_delay) { 1 }

    before do
      stub_request(:get, 'https://example.com/catalog/abc-123/raw').to_return(body: '{"id":"abc-123"}')
      stub_request(:get, 'https://example.com/catalog/abc-321/raw').to_return(body: '{"id":"abc-321"}')
      allow(client).to receive(:sleep)
    end

    it 'parses the JSON response body' do
      expect(client.get_json('https://example.com/catalog/abc-123/raw')).to eq('id' => 'abc-123')
    end

    it 'waits out the crawl delay before every request, not just every page of results' do
      client.get_json('https://example.com/catalog/abc-123/raw')
      client.get_json('https://example.com/catalog/abc-321/raw')

      expect(client).to have_received(:sleep).with(1.0).twice
    end

    it 'uses a new connection for each request' do
      allow(Net::HTTP).to receive(:get_response).and_call_original

      client.get_json('https://example.com/catalog/abc-123/raw')
      client.get_json('https://example.com/catalog/abc-321/raw')

      # Net::HTTP.get_response opens and closes a connection per call, rather
      # than holding one open across requests the way a WAF tends to dislike
      expect(Net::HTTP).to have_received(:get_response).twice
    end

    context 'when the crawl delay is fractional' do
      let(:crawl_delay) { '0.5' }

      it 'waits that fraction of a second' do
        client.get_json('https://example.com/catalog/abc-123/raw')

        expect(client).to have_received(:sleep).with(0.5)
      end
    end

    context 'when no crawl delay is configured' do
      let(:crawl_delay) { nil }

      it 'does not wait between requests' do
        client.get_json('https://example.com/catalog/abc-123/raw')

        expect(client).not_to have_received(:sleep)
      end
    end
  end

  describe 'crawl delay configuration' do
    let(:client) { instance_double(described_class::HttpClient) }

    before do
      allow(described_class::HttpClient).to receive(:new).and_return(client)
      allow(client).to receive(:get_json).and_return(
        { 'response' => { 'docs' => [], 'pages' => { 'current_page' => 1, 'total_pages' => 1 } } }
      )
    end

    context 'when the site configures a crawl delay' do
      let(:site_config) { super().merge(crawl_delay: 2) }
      let(:config) { { crawl_delay: 1, INSTITUTION: site_config } }

      it 'prefers the site crawl delay over the global one' do
        harvester.each_document.to_a

        expect(described_class::HttpClient).to have_received(:new).with(crawl_delay: 2, logger:)
      end
    end

    context 'when only a global crawl delay is configured' do
      let(:config) { { crawl_delay: 1, INSTITUTION: site_config } }

      it 'uses the global crawl delay' do
        harvester.each_document.to_a

        expect(described_class::HttpClient).to have_received(:new).with(crawl_delay: 1, logger:)
      end
    end
  end

  describe 'BlacklightResponseVersionFactory' do
    let(:version_class) { described_class::BlacklightResponseVersionFactory.call(json) }

    context 'when a legacy blacklight version (6 and earlier)' do
      let(:json) { { 'response' => {} } }

      it { expect(version_class).to be described_class::LegacyBlacklightResponse }
    end

    context 'when a modern blacklight version (7 and later)' do
      let(:json) { { 'links' => {}, 'data' => [] } }

      it { expect(version_class).to be described_class::ModernBlacklightResponse }
    end

    context 'when a the JSON response is not recognizable' do
      let(:json) { { error: 'Broken' } }

      it { expect { version_class }.to raise_error(NotImplementedError) }
    end
  end

  describe 'LegacyBlacklightResponse' do
    before do
      allow(RSolr).to receive(:connect).and_return(stub_solr_connection)
    end

    let(:first_docs) {  [{ 'layer_slug_s' => 'abc-123' }, { 'layer_slug_s' => 'abc-321' }] }
    let(:second_docs) { [{ 'layer_slug_s' => 'xyz-123' }, { 'layer_slug_s' => 'xyz-321' }] }
    let(:stub_first_response) do
      { 'response' => { 'docs' => first_docs, 'pages' => { 'current_page' => 1, 'total_pages' => 2 } } }
    end
    let(:stub_second_response) do
      { 'response' => { 'docs' => second_docs, 'pages' => { 'current_page' => 2, 'total_pages' => 2 } } }
    end

    it 'gives the client it builds by default the logger it was given' do
      allow(described_class::HttpClient).to receive(:new).and_call_original

      described_class::LegacyBlacklightResponse.new(response: stub_first_response, base_url:, logger:)

      expect(described_class::HttpClient).to have_received(:new).with(logger:)
    end

    describe '#documents' do
      it 'pages through the response and returns all the documents' do
        stub_request(:get, "#{base_url}&page=2").to_return(body: stub_second_response.to_json)
        docs = described_class::LegacyBlacklightResponse.new(response: stub_first_response,
                                                             base_url:).documents

        expect(docs.to_a).to eq([first_docs, second_docs])
      end

      it 'stops paging and logs when a request fails' do
        stub_request(:get, "#{base_url}&page=2").to_raise(SocketError.new('no route to host'))
        docs = described_class::LegacyBlacklightResponse.new(response: stub_first_response,
                                                             base_url:, logger:).documents

        expect(docs.to_a).to eq([first_docs])
        expect(logger).to have_received(:error).with(/failed with no route to host/)
      end
    end
  end

  describe 'ModernBlacklightResponse' do
    before do
      allow(RSolr).to receive(:connect).and_return(stub_solr_connection)
      stub_request(
        :get,
        'https://example.com/catalog.json?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&per_page=100&page=2&format=json'
      ).to_return(body: second_results_response.to_json)
    end

    let(:first_results_response) do
      { 'data' => [
          { 'links' => { 'self' => 'https://example.com/catalog/abc-123' } },
          { 'links' => { 'self' => 'https://example.com/catalog/abc-321' } }
        ],
        'links' => { 'next' => 'https://example.com/catalog.json?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&per_page=100&page=2' } }
    end

    let(:second_results_response) do
      { 'data' => [
        { 'links' => { 'self' => 'https://example.com/catalog/xyz-123' } },
        { 'links' => { 'self' => 'https://example.com/catalog/xyz-321' } }
      ] }
    end

    it 'gives the client it builds by default the logger it was given' do
      allow(described_class::HttpClient).to receive(:new).and_call_original

      described_class::ModernBlacklightResponse.new(response: first_results_response, base_url:, logger:)

      expect(described_class::HttpClient).to have_received(:new).with(logger:)
    end

    describe '#documents' do
      it 'pages through the response and fetches documents for each "link" on the response data' do
        %w[abc-123 abc-321 xyz-123 xyz-321].each do |id|
          stub_request(:get, "https://example.com/catalog/#{id}/raw").to_return(
            body: { 'layer_slug_s' => id }.to_json
          )
        end

        docs = described_class::ModernBlacklightResponse.new(response: first_results_response,
                                                             base_url:).documents

        expect(docs.to_a).to eq([
                                  [{ 'layer_slug_s' => 'abc-123' }, { 'layer_slug_s' => 'abc-321' }],
                                  [{ 'layer_slug_s' => 'xyz-123' }, { 'layer_slug_s' => 'xyz-321' }]
                                ])
      end
    end
  end

  describe 'ModernBlacklightResponse errors' do
    subject(:documents) do
      described_class::ModernBlacklightResponse.new(response:, base_url:, logger:).documents.to_a
    end

    let(:next_url) { 'https://example.com/catalog.json?page=2' }

    before { allow(RSolr).to receive(:connect).and_return(stub_solr_connection) }

    context 'when fetching an individual document fails' do
      let(:response) do
        { 'data' => [
          { 'links' => { 'self' => 'https://example.com/catalog/abc-123' } },
          { 'links' => { 'self' => 'https://example.com/catalog/abc-321' } }
        ] }
      end

      before do
        stub_request(:get, 'https://example.com/catalog/abc-123/raw').to_return(
          body: { 'layer_slug_s' => 'abc-123' }.to_json
        )
        stub_request(:get, 'https://example.com/catalog/abc-321/raw').to_raise(
          SocketError.new('connection reset')
        )
      end

      it 'drops that document and keeps the rest' do
        expect(documents).to eq([[{ 'layer_slug_s' => 'abc-123' }]])
      end

      it 'logs which document failed' do
        documents
        expect(logger).to have_received(:error).with(%r{catalog/abc-321/raw" failed with connection reset})
      end
    end

    context 'when fetching the next page fails' do
      let(:response) do
        { 'data' => [{ 'links' => { 'self' => 'https://example.com/catalog/abc-123' } }],
          'links' => { 'next' => next_url } }
      end

      before do
        stub_request(:get, 'https://example.com/catalog/abc-123/raw').to_return(
          body: { 'layer_slug_s' => 'abc-123' }.to_json
        )
        stub_request(:get, "#{next_url}&format=json").to_raise(SocketError.new('no route to host'))
      end

      it 'stops paging and returns what it already had' do
        expect(documents).to eq([[{ 'layer_slug_s' => 'abc-123' }]])
      end

      it 'logs the failure' do
        documents
        expect(logger).to have_received(:error).with(/failed with no route to host/)
      end
    end
  end
end
