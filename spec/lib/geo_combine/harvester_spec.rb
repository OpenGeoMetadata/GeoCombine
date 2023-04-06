# frozen_string_literal: true

require 'git'
require 'geo_combine/harvester'
require 'spec_helper'

RSpec.describe GeoCombine::Harvester do
  subject(:harvester) { described_class.new(ogm_path: 'spec/fixtures/indexing') }

  let(:repo_name) { 'my-institution' }
  let(:repo_path) { File.join(harvester.ogm_path, repo_name) }
  let(:repo_url) { "https://github.com/OpenGeoMetadata/#{repo_name}.git" }
  let(:stub_repo) { instance_double(Git::Base) }
  let(:stub_gh_api) do
    [
      { name: repo_name, size: 100 },
      { name: 'another-institution', size: 100 },
      { name: 'outdated-institution', size: 100, archived: true }, # archived
      { name: 'aardvark', size: 300 },                             # on denylist
      { name: 'empty', size: 0 }                                   # no data
    ]
  end

  before do
    # stub github API requests
    # use the whole org response, or just a portion for particular repos
    allow(Net::HTTP).to receive(:get) do |uri|
      if uri == described_class.ogm_api_uri
        stub_gh_api.to_json
      else
        repo_name = uri.path.split('/').last.gsub('.git', '')
        stub_gh_api.find { |repo| repo[:name] == repo_name }.to_json
      end
    end

    # stub git commands
    allow(Git).to receive(:open).and_return(stub_repo)
    allow(Git).to receive(:clone).and_return(stub_repo)
    allow(stub_repo).to receive(:pull).and_return(stub_repo)
  end

  describe '#docs_to_index' do
    it 'yields each JSON record with its path, skipping layers.JSON' do
      expect { |b| harvester.docs_to_index(&b) }.to yield_successive_args(
        [JSON.parse(File.read('spec/fixtures/indexing/basic_geoblacklight.json')), 'spec/fixtures/indexing/basic_geoblacklight.json'],
        [JSON.parse(File.read('spec/fixtures/indexing/geoblacklight.json')), 'spec/fixtures/indexing/geoblacklight.json']
      )
    end

    it 'skips records with a different schema version' do
      harvester = described_class.new(ogm_path: 'spec/fixtures/indexing/', schema_version: 'Aardvark')
      expect { |b| harvester.docs_to_index(&b) }.to yield_successive_args(
        [JSON.parse(File.read('spec/fixtures/indexing/aardvark.json')), 'spec/fixtures/indexing/aardvark.json']
      )
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

    it 'returns the count of repositories pulled' do
      expect(harvester.pull_all).to eq(2)
    end

    it 'skips repositories in the denylist' do
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/aardvark.git')
    end

    it 'skips archived repositories' do
      harvester.pull_all
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/outdated-institution.git')
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

    it 'warns if a repository is empty' do
      allow(Net::HTTP).to receive(:get).with('https://api.github.com/repos/opengeometadata/empty').and_return('{"size": 0}')
      expect do
        harvester.clone('empty')
      end.to output(/repository 'empty' is empty/).to_stdout
    end

    it 'warns if a repository is archived' do
      allow(Net::HTTP).to receive(:get).with('https://api.github.com/repos/opengeometadata/empty').and_return('{"archived": true}')
      expect do
        harvester.clone('outdated-institution')
      end.to output(/repository 'outdated-institution' is archived/).to_stdout
    end
  end

  describe '#clone_all' do
    it 'can clone all repositories' do
      harvester.clone_all
      expect(Git).to have_received(:clone).exactly(2).times
    end

    it 'skips repositories in the denylist' do
      harvester.clone_all
      expect(Git).not_to have_received(:clone).with('https://github.com/OpenGeoMetadata/aardvark.git')
    end

    it 'returns the count of repositories cloned' do
      expect(harvester.clone_all).to eq(2)
    end
  end

  describe '#ogm_api_uri' do
    it 'includes a per_page param' do
      expect(described_class.send('ogm_api_uri').to_s).to include('per_page')
    end
  end
end
