# frozen_string_literal: true

require 'spec_helper'
require 'rake'

describe 'geocombine rake tasks' do
    describe 'geocombine:clone' do
        it 'does not clone repos on deny list' do
            allow(Kernel).to receive(:system)
            Rake::Task['geocombine:clone'].invoke
            expect(Kernel).to have_received(:system).exactly(20).times
        end
    end
end