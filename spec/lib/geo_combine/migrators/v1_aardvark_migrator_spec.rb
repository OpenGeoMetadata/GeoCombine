# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Migrators::V1AardvarkMigrator do
  include JsonDocs

  # TODO: the input fixture doesn't have:
  #  - dc_source_sm
  #  - suppressed_b
  describe '#run' do
    it 'migrates keys' do
      input_hash = JSON.parse(full_geoblacklight)
      expected_output = JSON.parse(full_geoblacklight_aardvark)
      expect(described_class.new(v1_hash: input_hash).run).to eq(expected_output)
    end
  end
end
