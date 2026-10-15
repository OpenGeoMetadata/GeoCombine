# frozen_string_literal: true

require 'rake'
require 'spec_helper'

RSpec.describe 'geocombine rake tasks' do
  let(:indexer) { instance_double(GeoCombine::Indexer, index: 1) }
  let(:harvester) { instance_double(GeoCombine::Harvester, docs_to_index: records.each) }
  let(:withdrawals) { instance_double(GeoCombine::Withdrawals, apply: []) }
  let(:records) { [[{ 'id' => 'a' }, 'a.json']] }

  before(:all) do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load File.expand_path('../../../lib/tasks/geo_combine.rake', __dir__)
  end

  before do
    Rake::Task.tasks.each(&:reenable)
    allow(GeoCombine::Indexer).to receive(:new).and_return(indexer)
    allow(GeoCombine::Harvester).to receive(:new).and_return(harvester)
    allow(GeoCombine::Withdrawals).to receive(:new).and_return(withdrawals)
  end

  describe 'geocombine:index' do
    it 'indexes every record, then applies withdrawals using the same walk' do
      calls = []
      allow(indexer).to receive(:index) { |docs| calls << [:index, docs] }
      allow(withdrawals).to receive(:apply) { |**args| calls << [:apply, args] }
      Rake::Task['geocombine:index'].invoke('/ogm')
      expect(GeoCombine::Harvester).to have_received(:new).with(ogm_path: '/ogm')
      expect(GeoCombine::Withdrawals).to have_received(:new).with(ogm_path: '/ogm')
      expect(calls).to eq [[:index, harvester.docs_to_index], [:apply, { harvester:, indexer: }]]
    end
  end

  describe 'geocombine:withdraw' do
    it 'walks every record without indexing, then applies withdrawals' do
      Rake::Task['geocombine:withdraw'].invoke('/ogm')
      expect(harvester).to have_received(:docs_to_index)
      expect(indexer).not_to have_received(:index)
      expect(withdrawals).to have_received(:apply).with(harvester:, indexer:)
    end

    it 'reads ogm_path from OGM_PATH' do
      stub_const('ENV', ENV.to_h.merge('OGM_PATH' => '/from/env'))
      Rake::Task['geocombine:withdraw'].invoke
      expect(GeoCombine::Withdrawals).to have_received(:new).with(ogm_path: '/from/env')
    end
  end
end
