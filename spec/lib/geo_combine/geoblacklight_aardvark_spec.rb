# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::GeoblacklightAardvark do
  include JsonDocs

  let(:aardvark_object) { described_class.new(full_geoblacklight_aardvark) }

  describe '#initialize' do
    it 'parses the metadata into a hash' do
      expect(aardvark_object.metadata).to be_a Hash
      expect(aardvark_object.metadata['dct_title_s']).to eq '2005 Rural Poverty GIS Database: Uganda'
    end

    it 'merges supplied fields into the parsed document' do
      record = described_class.new(full_geoblacklight_aardvark, 'schema_provider_s' => 'Elsewhere')
      expect(record.metadata['schema_provider_s']).to eq 'Elsewhere'
    end
  end

  describe '#to_json' do
    it 'returns a JSON string' do
      expect(JSON.parse(aardvark_object.to_json)).to eq aardvark_object.metadata
    end
  end

  describe '#valid?' do
    it 'is true for a compliant record' do
      expect(aardvark_object).to be_valid
    end

    it 'is false for a non-compliant record' do
      expect(described_class.new(basic_geoblacklight)).not_to be_valid
    end
  end

  describe '#validate!' do
    it 'passes a compliant record' do
      expect { aardvark_object.validate! }.not_to raise_error
    end

    it 'raises an error when a required field is missing' do
      record = with_metadata { |metadata| metadata.delete('id') }
      expect { record.validate! }.to raise_error(JSON::Schema::ValidationError, /id/)
    end

    it 'raises an error when a field has the wrong type' do
      record = with_metadata { |metadata| metadata['gbl_resourceClass_sm'] = 'Datasets' }
      expect { record.validate! }.to raise_error(JSON::Schema::ValidationError, /gbl_resourceClass_sm/)
    end

    it 'raises an error when a controlled value is not in the schema' do
      record = with_metadata { |metadata| metadata['gbl_resourceClass_sm'] = ['Nonsense'] }
      expect { record.validate! }.to raise_error(JSON::Schema::ValidationError, /gbl_resourceClass_sm/)
    end
  end

  describe '#validate_version!' do
    it 'raises an error unless gbl_mdVersion_s is Aardvark' do
      record = with_metadata { |metadata| metadata['gbl_mdVersion_s'] = 'Aardvark2' }
      expect { record.validate_version! }.to raise_error(GeoCombine::Exceptions::InvalidSchemaVersion)
    end
  end

  describe '#validate_spatial!' do
    it 'raises an error on an envelope whose corners are inverted' do
      record = with_metadata { |metadata| metadata['locn_geometry'] = 'ENVELOPE(-10, 10, -50, 50)' }
      expect { record.validate_spatial! }.to raise_error(GeoCombine::Exceptions::InvalidGeometry)
    end

    it 'skips geometries that are not envelopes' do
      record = with_metadata { |metadata| metadata['locn_geometry'] = 'POLYGON((0 0, 1 0, 1 1, 0 0))' }
      expect { record.validate_spatial! }.not_to raise_error
    end
  end

  ##
  # Builds a record from a fixture and yeilds to allow caller to change fields
  def with_metadata
    metadata = JSON.parse(full_geoblacklight_aardvark)
    yield metadata
    described_class.new(metadata.to_json)
  end
end
