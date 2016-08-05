require 'spec_helper'

RSpec.describe GeoCombine::Geoblacklight do
  include XmlDocs
  include JsonDocs
  include GeoCombine::Exceptions
  let(:full_geobl) { GeoCombine::Geoblacklight.new(full_geoblacklight) }
  let(:basic_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight) }
  describe '#initialize' do
    it 'parses metadata argument JSON to Hash' do
      expect(basic_geobl.instance_variable_get(:@metadata)).to be_an Hash
    end
    describe 'merges fields argument into metadata' do
      let(:basic_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight, 'dc_identifier_s' => 'new one', "extra_field" => true)}
      it 'overwrites existing metadata fields' do
        expect(basic_geobl.metadata['dc_identifier_s']).to eq 'new one'
      end
      it 'adds in new fields' do
        expect(basic_geobl.metadata['extra_field']).to be true
      end
    end
  end
  describe '#metadata' do
    it 'reads the metadata instance variable' do
      expect(basic_geobl.metadata).to be_an Hash
      expect(basic_geobl.metadata).to have_key 'dc_identifier_s'
    end
  end
  describe '#to_json' do
    it 'returns valid json' do
      expect(valid_json?(full_geobl.to_json)).to be_truthy
      expect(valid_json?(basic_geobl.to_json)).to be_truthy
    end
  end
  let(:enhanced_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight, 'layer_geom_type_s' => 'esriGeometryPolygon') }
  before { enhanced_geobl.enhance_metadata }
  describe '#enhance_metadata' do
    it 'calls enhancement methods to validate document' do
      expect(enhanced_geobl.valid?).to be true
    end
    it 'enhances the dc_subject_sm field' do
      expect(enhanced_geobl.metadata['dc_subject_sm']).to include 'Boundaries', 'Inland Waters'
    end
    it 'formats the date properly as ISO8601' do
      expect(enhanced_geobl.metadata['layer_modified_dt']).to match(/Z$/)
    end
    it 'formats the geometry type field' do
      expect(enhanced_geobl.metadata['layer_geom_type_s']).to eq 'Polygon'
    end
  end
  describe '#valid?' do
    it 'a valid geoblacklight-schema document should be valid' do
      expect(full_geobl.valid?).to be true
    end
    it 'an invalid document' do
      expect { basic_geobl.valid? }.to raise_error JSON::Schema::ValidationError
    end
    it 'calls the dct_references_s validator' do
      expect(enhanced_geobl).to receive(:dct_references_validate!)
      enhanced_geobl.valid?
    end
  end
  describe '#dct_references_validate!' do
    context 'with valid document' do
      it 'is valid' do
        expect(full_geobl.dct_references_validate!).to be true
      end
    end
    context 'with invalid document' do
      let(:unparseable_json) do
        <<-JSON
          {
            \"http://schema.org/url\":\"http://example.com/abc123\",,
            \"http://schema.org/downloadUrl\":\"http://example.com/abc123/data.zip\"
          }
        JSON
      end
      let(:bad_ref) do
        GeoCombine::Geoblacklight.new(
          basic_geoblacklight, 'dct_references_s' => unparseable_json, 'layer_geom_type_s' => 'esriGeometryPolygon'
        )
      end
      let(:not_hash) do
        GeoCombine::Geoblacklight.new(
          basic_geoblacklight, 'dct_references_s' => '[{}]', 'layer_geom_type_s' => 'esriGeometryPolygon'
        )
      end
      before do
        bad_ref.enhance_metadata
        not_hash.enhance_metadata
      end
      it 'unparseable json' do
        expect { bad_ref.dct_references_validate! }.to raise_error JSON::ParserError
      end
      it 'not a hash' do
        expect { not_hash.dct_references_validate! }.to raise_error GeoCombine::Exceptions::InvalidDCTReferences
      end
    end
  end
end
