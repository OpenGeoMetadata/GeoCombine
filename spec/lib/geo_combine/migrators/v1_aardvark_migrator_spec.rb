# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Migrators::V1AardvarkMigrator do
  include JsonDocs

  describe '#run' do
    it 'migrates keys' do
      input_hash = JSON.parse(full_geoblacklight)
      # TODO: Note that this fixture has not yet been fully converted to
      # aardvark. See https://github.com/OpenGeoMetadata/GeoCombine/issues/121
      # for remaining work.
      expected_output = JSON.parse(full_geoblacklight_aardvark)
      expect(described_class.new(v1_hash: input_hash).run).to eq(expected_output)
    end

    context 'when the given record is already in aardvark schema' do
      xit 'returns the record unchanged'
    end
  end
end
