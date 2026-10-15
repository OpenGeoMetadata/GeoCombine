# frozen_string_literal: true

require 'geo_combine/harvester'
require 'geo_combine/indexer'
require 'geo_combine/withdrawals'
require 'spec_helper'

# Runs against a real Solr core with the GeoBlacklight schema.
# Only runs when SOLR_INTEGRATION_URL points to a (disposable) core.
RSpec.describe 'withdrawals against solr', :integration do
  let(:logger) { Logger.new(nil) }
  let(:indexer) { GeoCombine::Indexer.new(solr_url: ENV.fetch('SOLR_INTEGRATION_URL'), logger:) }
  let(:harvester) { GeoCombine::Harvester.new(ogm_path: 'spec/fixtures/withdrawal', skip_repos: ['edu.example-skipped'], logger:) }
  let(:withdrawals) { GeoCombine::Withdrawals.new(ogm_path: 'spec/fixtures/withdrawal', skip_repos: ['edu.example-skipped'], logger:) }

  # Documents a consumer indexed before they were withdrawn, plus one that only it has
  let(:previously_indexed) do
    %w[a-gone b-gone a-orphan local-only skipped-gone a-padded].map do |id|
      {
        'id' => id, 'dct_title_s' => "Plano de la ciudad de Bogotá (#{id})", 'gbl_mdVersion_s' => 'Aardvark',
        'dct_accessRights_s' => 'Public', 'gbl_resourceClass_sm' => ['Maps'], 'gbl_mdModified_dt' => '2026-01-01T00:00:00Z',
        'dct_subject_sm' => ['Cities & towns'], 'dcat_bbox' => 'ENVELOPE(-74.2,-74.0,4.8,4.5)',
        'locn_geometry' => 'ENVELOPE(-74.2,-74.0,4.8,4.5)', 'gbl_indexYear_im' => [1890]
      }
    end
  end
  let(:all_ids) { previously_indexed.map { |doc| doc['id'] } + %w[a-live a-contradicted b-live] }

  # The ids Solr has, from real-time get. POSTed, because Faraday would collapse the
  # repeated id params in a query string into one.
  def indexed_ids
    indexer.solr.post('get', params: { id: all_ids, fl: 'id' })['response']['docs'].map { |doc| doc['id'] }
  end

  before do
    indexer.delete(all_ids)
    indexer.index(previously_indexed.map { |doc| [doc, doc['id']] })
  end

  after { indexer.delete(all_ids) }

  it 'deletes withdrawn records that are no longer published, and nothing else' do
    indexer.index(harvester.docs_to_index)
    withdrawals.apply(harvester:, indexer:)
    expect(indexed_ids).to contain_exactly('a-live', 'a-contradicted', 'b-live', 'a-orphan', 'local-only', 'skipped-gone', 'a-padded')
  end
end
