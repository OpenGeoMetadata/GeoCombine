# frozen_string_literal: true

require 'net/http'
require 'spec_helper'
require 'rsolr'

RSpec.describe GeoCombine::GeoBlacklightHarvester do
  subject(:harvester) { described_class.new(site_key, logger:) }

  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil, debug: nil) }
  let(:site_key) { :INSTITUTION }
  let(:stub_json_response) { '{}' }
  let(:stub_solr_connection) { double('RSolr::Connection') }

  before do
    allow(described_class).to receive(:config).and_return({
                                                            INSTITUTION: {
                                                              host: 'https://example.com/',
                                                              params: {
                                                                f: { dct_provenance_s: ['INSTITUTION'] }
                                                              }
                                                            }
                                                          })
  end

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
      expect(Net::HTTP).to receive(:get).with(
        URI('https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100&page=1')
      ).and_return(stub_json_response)
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

    describe '#documents' do
      it 'pages through the response and returns all the documents' do
        expect(Net::HTTP).to receive(:get).with(
          URI('https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100&page=2')
        ).and_return(stub_second_response.to_json)
        base_url = 'https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100'
        docs = described_class::LegacyBlacklightResponse.new(response: stub_first_response,
                                                             base_url:).documents

        expect(docs.to_a).to eq([first_docs, second_docs])
      end

      it 'stops paging and logs when a request fails' do
        allow(Net::HTTP).to receive(:get).and_raise(SocketError, 'no route to host')
        base_url = 'https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100'
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
      expect(Net::HTTP).to receive(:get).with(
        URI('https://example.com/catalog.json?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&per_page=100&page=2&format=json')
      ).and_return(second_results_response.to_json)
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

    describe '#documents' do
      it 'pages through the response and fetches documents for each "link" on the response data' do
        %w[abc-123 abc-321 xyz-123 xyz-321].each do |id|
          expect(Net::HTTP).to receive(:get).with(
            URI("https://example.com/catalog/#{id}/raw")
          ).and_return({ 'layer_slug_s' => id }.to_json)
        end

        base_url = 'https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100'
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

    let(:base_url) { 'https://example.com?f%5Bdct_provenance_s%5D%5B%5D=INSTITUTION&format=json&per_page=100' }
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
        allow(Net::HTTP).to receive(:get).with(URI('https://example.com/catalog/abc-123/raw'))
                                         .and_return({ 'layer_slug_s' => 'abc-123' }.to_json)
        allow(Net::HTTP).to receive(:get).with(URI('https://example.com/catalog/abc-321/raw'))
                                         .and_raise(SocketError, 'connection reset')
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
        allow(Net::HTTP).to receive(:get).with(URI('https://example.com/catalog/abc-123/raw'))
                                         .and_return({ 'layer_slug_s' => 'abc-123' }.to_json)
        allow(Net::HTTP).to receive(:get).with(URI("#{next_url}&format=json"))
                                         .and_raise(SocketError, 'no route to host')
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
