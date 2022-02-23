# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'geo_combine.rake' do
  before do
    load('lib/tasks/geo_combine.rake')
  end

  describe 'geocombine:clone' do
    before do
      WebMock.disable_net_connect!
    end

    after do
      WebMock.allow_net_connect!
    end

    it 'does not clone repos on deny list' do
      stub_request(:get, 'https://api.github.com/orgs/opengeometadata/repos').to_return(status: 200, body: read_fixture('docs/repos.json'))
      allow(Kernel).to receive(:system)
      Rake::Task['geocombine:clone'].invoke
      expect(Kernel).to have_received(:system).exactly(20).times
    end
  end
end
