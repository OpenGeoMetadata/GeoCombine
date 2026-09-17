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

    context 'when a request keeps failing' do
      let(:site_config) { super().merge(retry_delay: 0) }

      it 'raises instead of returning normally after a partial harvest' do
        stub_request(:get, "#{base_url}&page=1").to_raise(Errno::ECONNRESET)

        expect { harvester.index }.to raise_error(GeoCombine::Exceptions::HarvestError)
      end
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

    context 'when the site has more than one page of results' do
      let(:stub_json_response) do
        { response: { docs: [{ 'layer_slug_s' => 'abc-123' }],
                      pages: { current_page: 1, total_pages: 2 } } }.to_json
      end

      before do
        stub_request(:get, "#{base_url}&page=2").to_return(
          body: { response: { docs: [{ 'layer_slug_s' => 'xyz-123' }],
                              pages: { current_page: 2, total_pages: 2 } } }.to_json
        )
      end

      it 'yields the documents from every page' do
        expect(harvester.each_document.to_a).to eq([{ 'layer_slug_s' => 'abc-123' },
                                                    { 'layer_slug_s' => 'xyz-123' }])
      end
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
    let(:client) do
      described_class::HttpClient.new(crawl_delay:, headers:, max_retries:, retry_delay:, logger:)
    end
    let(:crawl_delay) { 1 }
    let(:headers) { {} }
    let(:max_retries) { nil }
    let(:retry_delay) { nil }

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

    context 'when headers are configured' do
      let(:headers) { { 'User-Agent' => 'GeoCombine', :'X-Api-Key' => :secret } }

      it 'sends them with the request, as strings' do
        client.get_json('https://example.com/catalog/abc-123/raw')

        expect(
          a_request(:get, 'https://example.com/catalog/abc-123/raw')
            .with(headers: { 'User-Agent' => 'GeoCombine', 'X-Api-Key' => 'secret' })
        ).to have_been_made
      end
    end

    context 'when a request fails transiently' do
      let(:crawl_delay) { nil }
      let(:url) { 'https://example.com/catalog/abc-123/raw' }
      let(:document) { { 'id' => 'abc-123' } }

      [Errno::ECONNRESET, Errno::EPIPE, EOFError, Net::OpenTimeout, Net::ReadTimeout,
       OpenSSL::SSL::SSLError, SocketError].each do |error|
        it "retries #{error}" do
          stub_request(:get, url).to_raise(error).then.to_return(body: document.to_json)

          expect(client.get_json(url)).to eq(document)
        end
      end

      it 'retries a server error' do
        stub_request(:get, url).to_return({ status: 503 }, { body: document.to_json })

        expect(client.get_json(url)).to eq(document)
      end

      it 'retries rate limiting' do
        stub_request(:get, url).to_return({ status: 429 }, { body: document.to_json })

        expect(client.get_json(url)).to eq(document)
      end

      it 'retries a 200 that is HTML rather than JSON, as bot mitigation sends' do
        stub_request(:get, url).to_return(
          { body: '<html>checking your browser</html>', headers: { 'Content-Type' => 'text/html' } },
          { body: document.to_json }
        )

        expect(client.get_json(url)).to eq(document)
      end

      it 'retries a body that is valid JSON but not an object' do
        stub_request(:get, url).to_return({ body: 'null' }, { body: document.to_json })

        expect(client.get_json(url)).to eq(document)
      end

      it 'waits longer before each attempt' do
        stub_request(:get, url).to_return({ status: 503 }, { status: 503 }, { body: document.to_json })
        client.get_json(url)

        expect(client).to have_received(:sleep).with(2.0)
        expect(client).to have_received(:sleep).with(4.0)
      end

      it 'raises once it runs out of retries, rather than ending the harvest quietly' do
        stub_request(:get, url).to_raise(Errno::ECONNRESET)

        expect { client.get_json(url) }.to raise_error(GeoCombine::Exceptions::HarvestError,
                                                       /failed after 4 attempts/)
        expect(a_request(:get, url)).to have_been_made.times(4)
      end

      context 'when retries are configured' do
        let(:max_retries) { 1 }
        let(:retry_delay) { 0 }

        it 'retries only as often as configured' do
          stub_request(:get, url).to_raise(Errno::ECONNRESET)

          expect { client.get_json(url) }.to raise_error(GeoCombine::Exceptions::HarvestError)
          expect(a_request(:get, url)).to have_been_made.twice
        end
      end
    end

    context 'when a request fails unrecoverably' do
      let(:crawl_delay) { nil }
      let(:url) { 'https://example.com/catalog/abc-123/raw' }

      it 'raises DocumentNotFound for a document that is gone, without retrying' do
        stub_request(:get, url).to_return(status: 404)

        expect { client.get_json(url) }.to raise_error(GeoCombine::Exceptions::DocumentNotFound, /was not found/)
        expect(a_request(:get, url)).to have_been_made.once
      end

      it 'raises for a response it cannot use, without retrying' do
        stub_request(:get, url).to_return(status: 403)

        expect { client.get_json(url) }.to raise_error(GeoCombine::Exceptions::HarvestError, /failed with 403/)
        expect(a_request(:get, url)).to have_been_made.once
      end
    end
  end

  describe 'client configuration' do
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

        expect(described_class::HttpClient).to have_received(:new).with(hash_including(crawl_delay: 2))
      end
    end

    context 'when only a global crawl delay is configured' do
      let(:config) { { crawl_delay: 1, INSTITUTION: site_config } }

      it 'uses the global crawl delay' do
        harvester.each_document.to_a

        expect(described_class::HttpClient).to have_received(:new).with(hash_including(crawl_delay: 1))
      end
    end

    context 'when headers are configured' do
      let(:site_config) { super().merge(headers: { 'X-Api-Key' => 'secret' }) }
      let(:config) { { headers: { 'User-Agent' => 'GeoCombine', 'X-Api-Key' => 'global' }, INSTITUTION: site_config } }

      it 'merges the site headers over the global ones' do
        harvester.each_document.to_a

        expect(described_class::HttpClient).to have_received(:new).with(
          hash_including(headers: { 'User-Agent' => 'GeoCombine', 'X-Api-Key' => 'secret' })
        )
      end
    end

    context 'when the site configures retries' do
      let(:site_config) { super().merge(max_retries: 5, retry_delay: 3) }
      let(:config) { { max_retries: 1, retry_delay: 10, INSTITUTION: site_config } }

      it 'prefers the site retry configuration over the global one' do
        harvester.each_document.to_a

        expect(described_class::HttpClient).to have_received(:new).with(
          hash_including(max_retries: 5, retry_delay: 3)
        )
      end
    end

    context 'when only a global retry configuration is set' do
      let(:config) { { max_retries: 1, retry_delay: 10, INSTITUTION: site_config } }

      it 'uses the global retry configuration' do
        harvester.each_document.to_a

        expect(described_class::HttpClient).to have_received(:new).with(
          hash_including(max_retries: 1, retry_delay: 10)
        )
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

    let(:client) { described_class::HttpClient.new(retry_delay: 0, logger:) }
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

      it 'raises when a page comes back as JSON that is not a page of search results' do
        stub_request(:get, "#{base_url}&page=2").to_return(body: { 'error' => 'request blocked' }.to_json)
        docs = described_class::LegacyBlacklightResponse.new(response: stub_first_response,
                                                             base_url:, client:, logger:).documents

        expect { docs.to_a }.to raise_error(GeoCombine::Exceptions::HarvestError,
                                            /not a page of search results/)
      end

      it 'raises when a request keeps failing, rather than stopping quietly' do
        stub_request(:get, "#{base_url}&page=2").to_raise(SocketError.new('no route to host'))
        docs = described_class::LegacyBlacklightResponse.new(response: stub_first_response,
                                                             base_url:, client:, logger:).documents

        expect { docs.to_a }.to raise_error(GeoCombine::Exceptions::HarvestError, /no route to host/)
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
      described_class::ModernBlacklightResponse.new(response:, base_url:, client:, logger:).documents.to_a
    end

    let(:client) { described_class::HttpClient.new(retry_delay: 0, logger:) }
    let(:next_url) { 'https://example.com/catalog.json?page=2' }

    before { allow(RSolr).to receive(:connect).and_return(stub_solr_connection) }

    context 'when an individual document is not found' do
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
        stub_request(:get, 'https://example.com/catalog/abc-321/raw').to_return(status: 404)
      end

      it 'skips that document and keeps the rest, since a record can be indexed but unreadable' do
        expect(documents).to eq([[{ 'layer_slug_s' => 'abc-123' }]])
      end

      it 'logs which document it skipped' do
        documents
        expect(logger).to have_received(:warn).with(%r{skipping document.*catalog/abc-321/raw was not found})
      end
    end

    context 'when fetching an individual document keeps failing' do
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
          Errno::ECONNRESET.new('connection reset')
        )
      end

      it 'raises instead of dropping the document' do
        expect { documents }.to raise_error(GeoCombine::Exceptions::HarvestError, /Connection reset/)
      end
    end

    context 'when a page comes back as JSON that is not a page of search results' do
      let(:response) do
        { 'data' => [{ 'links' => { 'self' => 'https://example.com/catalog/abc-123' } }],
          'links' => { 'next' => next_url } }
      end

      before do
        stub_request(:get, 'https://example.com/catalog/abc-123/raw').to_return(
          body: { 'layer_slug_s' => 'abc-123' }.to_json
        )
        stub_request(:get, "#{next_url}&format=json").to_return(body: { 'error' => 'request blocked' }.to_json)
      end

      it 'raises instead of treating it as the end of the results' do
        expect { documents }.to raise_error(GeoCombine::Exceptions::HarvestError,
                                            /not a page of search results/)
      end
    end

    context 'when a search result has no link to itself' do
      let(:response) do
        { 'data' => [
          { 'links' => { 'self' => 'https://example.com/catalog/abc-123' } },
          { 'links' => {} }
        ] }
      end

      before do
        stub_request(:get, 'https://example.com/catalog/abc-123/raw').to_return(
          body: { 'layer_slug_s' => 'abc-123' }.to_json
        )
      end

      it 'logs which result it skipped rather than dropping it silently' do
        expect(documents).to eq([[{ 'layer_slug_s' => 'abc-123' }]])
        expect(logger).to have_received(:warn).with(/skipping result with no self link/)
      end
    end

    context 'when every document on a page is skipped' do
      let(:response) do
        { 'data' => [
          { 'links' => { 'self' => 'https://example.com/catalog/abc-123' } },
          { 'links' => { 'self' => 'https://example.com/catalog/abc-321' } }
        ] }
      end

      before { stub_request(:get, %r{/raw$}).to_return(status: 404) }

      it 'logs at error, since the site may have stopped serving records' do
        expect(documents).to eq([[]])
        expect(logger).to have_received(:error).with(/skipped every document on page 1/)
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

      it 'raises instead of ending the harvest partway through' do
        expect { documents }.to raise_error(GeoCombine::Exceptions::HarvestError, /no route to host/)
      end

      it 'logs each attempt it retried' do
        expect { documents }.to raise_error(GeoCombine::Exceptions::HarvestError)
        expect(logger).to have_received(:warn).with(/retrying/).exactly(3).times
      end
    end
  end
end
