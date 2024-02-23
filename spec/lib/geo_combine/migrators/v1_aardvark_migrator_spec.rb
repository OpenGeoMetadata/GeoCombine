# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Migrators::V1AardvarkMigrator do
  include JsonDocs

  describe '#run' do
    it 'migrates fields to new names and types' do
      input_hash = JSON.parse(full_geoblacklight)
      expected_output = JSON.parse(full_geoblacklight_aardvark)
      expect(described_class.new(v1_hash: input_hash).run).to eq(expected_output)
    end

    it 'removes deprecated fields' do
      input_hash = JSON.parse(full_geoblacklight)
      output = described_class.new(v1_hash: input_hash).run
      expect(output.keys).not_to include(described_class::SCHEMA_FIELD_MAP.keys)
      expect(output.keys).not_to include('dc_type_s')
      expect(output.keys).not_to include('layer_geom_type_s')
    end

    it 'leaves custom fields unchanged' do
      input_hash = JSON.parse(full_geoblacklight)
      input_hash['custom_field'] = 'custom_value'
      output = described_class.new(v1_hash: input_hash).run
      expect(output['custom_field']).to eq('custom_value')
    end

    context 'when the given record is already in aardvark schema' do
      it 'returns the record unchanged' do
        input_hash = JSON.parse(full_geoblacklight_aardvark)
        expect(described_class.new(v1_hash: input_hash).run).to eq(input_hash)
      end
    end

    context 'when the user supplies a mapping for collection names to ids' do
      it 'converts the collection names to ids' do
        input_hash = JSON.parse(full_geoblacklight)
        collection_id_map = { 'Uganda GIS Maps and Data, 2000-2010' => 'stanford-rb371kw9607' }
        output = described_class.new(v1_hash: input_hash, collection_id_map:).run
        expect(output['dct_isPartOf_sm']).to eq(['stanford-rb371kw9607'])
      end
    end
  end
end
