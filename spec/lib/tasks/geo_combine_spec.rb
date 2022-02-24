# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'geo_combine.rake' do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('OGM_PATH').and_return(File.join(fixture_dir, 'indexing'))
  end

  describe 'geocombine:clone' do
    before do
      load File.expand_path('../../../lib/tasks/geo_combine.rake', __dir__)
      Rake::Task.define_task(:environment)
      WebMock.disable_net_connect!
    end

    after do
      WebMock.allow_net_connect!
    end

    it 'does not clone repos on deny list' do
      stub_request(:get, 'https://api.github.com/orgs/opengeometadata/repos').to_return(status: 200, body: read_fixture('docs/repos.json'))
      allow(Kernel).to receive(:system)
      Rake::Task['geocombine:clone'].invoke
      expect(Kernel).to have_received(:system).exactly(21).times
    end
  end

  describe 'geocombine:index' do
    it 'only indexes .json files but not layers.json' do
      rsolr_mock = instance_double('RSolr::Client')
      allow(rsolr_mock).to receive(:update)
      allow(rsolr_mock).to receive(:commit)
      allow(RSolr).to receive(:connect).and_return(rsolr_mock)
      Rake::Task['geocombine:index'].invoke
      # We expect 2 files to index
      expect(rsolr_mock).to have_received(:update).exactly(2).times
    end
  end
end
