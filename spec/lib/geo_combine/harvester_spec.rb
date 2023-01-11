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
      { name: 'aardvark', size: 300 } # on denylist
    ].to_json
  end

  before do
    allow(Net::HTTP).to receive(:get).with(described_class.ogm_api_uri).and_return(stub_gh_api)
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

    it 'can pull all repositories' do
      harvester.pull
      expect(Git).to have_received(:open).exactly(2).times
      expect(stub_repo).to have_received(:pull).exactly(2).times
    end

    it 'skips repositories in the denylist' do
      harvester.pull
      expect(Git).not_to have_received(:open).with('https://github.com/OpenGeoMetadata/aardvark.git')
    end

    it 'clones a repo before pulling if it does not exist' do
      harvester.pull(repo_name)
      expect(Git).to have_received(:clone)
    end

    it 'returns the count of repositories pulled' do
      expect(harvester.pull).to eq(2)
    end
  end

  describe '#clone' do
    it 'can clone a single repository' do
      harvester.clone(repo_name)
      expect(Git).to have_received(:clone).with(
        repo_url,
        repo_name, {
          depth: 1, # shallow clone
          path: repo_path
        }
      )
    end

    it 'can clone all repositories' do
      harvester.clone
      expect(Git).to have_received(:clone).exactly(2).times
    end

    it 'skips repositories in the denylist' do
      harvester.pull
      expect(Git).not_to have_received(:clone).with('https://github.com/OpenGeoMetadata/aardvark.git')
    end

    it 'skips repositories that already exist' do
      allow(File).to receive(:directory?).with(repo_path).and_return(true)
      harvester.clone(repo_name)
      expect(Git).not_to have_received(:clone)
    end

    it 'returns the count of repositories cloned' do
      expect(harvester.clone).to eq(2)
    end
  end
end
