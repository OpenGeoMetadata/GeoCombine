# frozen_string_literal: true

require 'git'
require 'geo_combine/harvester'
require 'spec_helper'

RSpec.describe GeoCombine::Harvester do
  subject(:harvester) { described_class.new(ogm_path: 'spec/fixtures/indexing', logger: logger) }

  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil, debug: nil) }
  let(:repo_name) { 'my-institution' }
  let(:repo_path) { File.join(harvester.ogm_path, repo_name) }
  let(:repo_url) { "https://github.com/OpenGeoMetadata/#{repo_name}.git" }
  let(:stub_repo) { instance_double(Git::Repository) }
  let(:stub_gh_api) do
    [
      { name: repo_name, size: 100, custom_properties: { supported_schemas: ['Aardvark'] } },
      { name: 'another-institution', size: 100, custom_properties: { supported_schemas: ['Aardvark', '1.0'] } }, # multiple schemas
      { name: 'v1-institution', size: 300, custom_properties: { supported_schemas: ['1.0'] } }, # schema mismatch
      { name: 'outdated-institution', size: 100, custom_properties: { supported_schemas: ['Aardvark'] }, archived: true }, # archived
      { name: 'empty', size: 0, custom_properties: { supported_schemas: ['Aardvark'] } }, # no data
      { name: 'tool', size: 50 } # not a metadata repository
    ]
  end

  # never let a request reach the real GitHub API
  around do |example|
    WebMock.disable_net_connect!
    example.run
  ensure
    WebMock.allow_net_connect!
  end

  before do
    # stub github API requests
    # use the whole org response, or just a portion for particular repos
    stub_request(:get, described_class.ogm_api_uri.to_s).to_return(body: stub_gh_api.to_json)
    stub_gh_api.each do |repo|
      stub_request(:get, "https://api.github.com/repos/opengeometadata/#{repo[:name]}").to_return(body: repo.to_json)
    end

    # stub git commands
    allow(Git).to receive_messages(open: stub_repo, clone: stub_repo)
    allow(stub_repo).to receive(:pull).and_return(stub_repo)
  end

  describe '#docs_to_index' do
    it 'yields each JSON record with its path, skipping layers.JSON' do
      expect { |b| harvester.docs_to_index(&b) }.to yield_successive_args(
        [JSON.parse(File.read('spec/fixtures/indexing/aardvark.json')), 'spec/fixtures/indexing/aardvark.json']
      )
    end

    it 'can yield JSON records for a different schema version' do
      harvester = described_class.new(ogm_path: 'spec/fixtures/indexing/', schema_version: '1.0', logger:)
      expect { |b| harvester.docs_to_index(&b) }.to yield_successive_args(
        [JSON.parse(File.read('spec/fixtures/indexing/basic_geoblacklight.json')), 'spec/fixtures/indexing/basic_geoblacklight.json'],
        [JSON.parse(File.read('spec/fixtures/indexing/geoblacklight.json')), 'spec/fixtures/indexing/geoblacklight.json']
      )
    end

    # Collect the titles of every record yielded, regardless of schema field
    def yielded_titles(harvester)
      harvester.docs_to_index.map { |record, _path| record['dct_title_s'] || record['dc_title_s'] }
    end

    it 'skips records that have no schema version' do
      expect(yielded_titles(harvester)).not_to include('Record With No Schema Version')
      expect(logger).to have_received(:debug)
        .with(%r{skipping spec/fixtures/indexing/no_schema.json; no schema version declared in record})
    end

    context 'when skip_restricted is true (the default)' do
      it 'skips records with restricted access rights' do
        expect(yielded_titles(harvester)).not_to include('Property Lot, Arlington County, VA ')
      end

      it 'skips gbl1 records with restricted access rights' do
        harvester = described_class.new(ogm_path: 'spec/fixtures/indexing', schema_version: '1.0', logger:)
        expect(yielded_titles(harvester)).not_to include('Global Navigation and Planning Chart, Sheet 21 W ')
      end
    end

    context 'when skip_restricted is false' do
      it 'yields records with restricted access rights' do
        harvester = described_class.new(ogm_path: 'spec/fixtures/indexing', skip_restricted: false, logger:)
        expect(yielded_titles(harvester)).to include('Property Lot, Arlington County, VA ')
      end

      it 'yields gbl1 records with restricted access rights' do
        harvester = described_class.new(ogm_path: 'spec/fixtures/indexing', schema_version: '1.0', skip_restricted: false, logger:)
        expect(yielded_titles(harvester)).to include('Global Navigation and Planning Chart, Sheet 21 W ')
      end

      it 'can read from the OGM_SKIP_RESTRICTED environment variable' do
        stub_const('ENV', ENV.to_h.merge('OGM_SKIP_RESTRICTED' => 'false'))
        harvester = described_class.new(ogm_path: 'spec/fixtures/indexing', logger:)
        expect(yielded_titles(harvester)).to include('Property Lot, Arlington County, VA ')
      end
    end
  end

  describe '#pull' do
    it 'can pull a single repository' do
      harvester.pull(repo_name)
      expect(Git).to have_received(:open).with(repo_path)
      expect(stub_repo).to have_received(:pull)
    end

    it 'clones a repo before pulling if it does not exist' do
      harvester.pull(repo_name)
      expect(Git).to have_received(:clone)
    end
  end

  describe '#pull_all' do
    it 'can pull all repositories' do
      harvester.pull_all
      expect(Git).to have_received(:open).exactly(2).times
      expect(stub_repo).to have_received(:pull).exactly(2).times
    end

    it 'returns the names of repositories pulled' do
      expect(harvester.pull_all).to eq(%w[my-institution another-institution])
    end

    it 'skips repositories with no schema declared' do
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/tool.git')
    end

    it 'skips archived repositories' do
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/outdated-institution.git')
    end

    it 'skips repositories with no data' do
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/empty.git')
    end

    it 'skips repositories that are on the skip list' do
      stub_const('ENV', ENV.to_h.merge('OGM_SKIP_REPOS' => 'my-institution,another-institution'))
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/my-institution.git')
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/another-institution.git')
    end
  end

  describe '#clone' do
    it 'can clone a single repository' do
      harvester.clone(repo_name)
      expect(Git).to have_received(:clone).with(
        repo_url,
        nil, {
          depth: 1, # shallow clone
          path: harvester.ogm_path
        }
      )
    end

    it 'skips repositories that already exist' do
      allow(File).to receive(:directory?).with(repo_path).and_return(true)
      harvester.clone(repo_name)
      expect(Git).not_to have_received(:clone)
    end

    it 'skips a repository whose declared schemas do not include the requested version' do
      harvester.clone('v1-institution')
      expect(Git).not_to have_received(:clone)
      expect(logger).to have_received(:warn).with(/don't include schema version Aardvark \(found 1.0\)/)
    end
  end

  describe '#clone_all' do
    it 'can clone all repositories' do
      harvester.clone_all
      expect(Git).to have_received(:clone).exactly(2).times
    end

    it 'skips repositories with no schema declared' do
      harvester.clone_all
      expect(Git).not_to have_received(:clone).with('https://github.com/OpenGeoMetadata/tool.git')
    end

    it 'skips archived repositories' do
      harvester.clone_all
      expect(Git).not_to have_received(:clone).with('https://github.com/OpenGeoMetadata/outdated-institution.git')
    end

    it 'skips repositories with no data' do
      harvester.clone_all
      expect(Git).not_to have_received(:clone).with('https://github.com/OpenGeoMetadata/empty.git')
    end

    it 'returns the names of repositories cloned' do
      expect(harvester.clone_all).to eq(%w[my-institution another-institution])
    end

    it 'skips repositories that are on the skip list' do
      stub_const('ENV', ENV.to_h.merge('OGM_SKIP_REPOS' => 'my-institution,another-institution'))
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/my-institution.git')
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/another-institution.git')
    end
  end

  describe '#ogm_api_uri' do
    it 'requests the largest page size GitHub allows' do
      expect(described_class.send('ogm_api_uri').to_s).to include('per_page=100')
    end
  end

  describe 'GitHub API requests' do
    context 'when the organization has more than one page of repositories' do
      let(:first_page_url) { 'https://api.github.com/organizations/1234/repos?per_page=100&page=1' }
      let(:next_page_url) { 'https://api.github.com/organizations/1234/repos?per_page=100&page=2' }

      before do
        # each page links to the next one; the last page only links back to earlier ones
        stub_request(:get, described_class.ogm_api_uri.to_s).to_return(
          body: stub_gh_api.first(1).to_json,
          headers: { 'Link' => %(<#{next_page_url}>; rel="next", <#{next_page_url}>; rel="last") }
        )
        stub_request(:get, next_page_url).to_return(
          body: stub_gh_api.drop(1).to_json,
          headers: { 'Link' => %(<#{first_page_url}>; rel="prev", <#{first_page_url}>; rel="first") }
        )
      end

      it 'harvests repositories from every page' do
        expect(harvester.pull_all).to eq(%w[my-institution another-institution])
      end

      it 'stops requesting pages when there is no next page' do
        harvester.pull_all
        expect(a_request(:get, next_page_url)).to have_been_made.once
      end
    end

    context 'when GITHUB_TOKEN is set' do
      let(:auth_header) { { 'Authorization' => 'Bearer secret-token' } }

      before { stub_const('ENV', ENV.to_h.merge('GITHUB_TOKEN' => 'secret-token')) }

      it 'authenticates requests for the repository list and for each repository' do
        harvester.clone_all
        expect(a_request(:get, described_class.ogm_api_uri.to_s).with(headers: auth_header)).to have_been_made
        expect(a_request(:get, "https://api.github.com/repos/opengeometadata/#{repo_name}").with(headers: auth_header)).to have_been_made
      end
    end

    context 'when GITHUB_TOKEN is not set' do
      before { stub_const('ENV', ENV.to_h.except('GITHUB_TOKEN')) }

      it 'makes unauthenticated requests' do
        harvester.clone_all
        expect(a_request(:get, /api\.github\.com/).with { |request| request.headers.key?('Authorization') }).not_to have_been_made
      end
    end

    context 'when GITHUB_TOKEN is empty' do
      before { stub_const('ENV', ENV.to_h.merge('GITHUB_TOKEN' => '')) }

      it 'makes unauthenticated requests' do
        harvester.clone_all
        expect(a_request(:get, /api\.github\.com/).with { |request| request.headers.key?('Authorization') }).not_to have_been_made
      end
    end
  end
end
