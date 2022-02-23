# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'geo_combine.rake' do
  before do
    load('lib/tasks/geo_combine.rake')
  end
  describe 'geocombine:clone' do
    it 'does not clone repos on deny list' do
      allow(Kernel).to receive(:system)
      Rake::Task['geocombine:clone'].invoke
      expect(Kernel).to have_received(:system).exactly(20).times
    end
  end
end