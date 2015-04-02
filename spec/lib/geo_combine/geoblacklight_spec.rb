require 'spec_helper'

RSpec.describe GeoCombine::Geoblacklight do
  include XmlDocs
  include JsonDocs
  let(:full_geobl) { GeoCombine::Geoblacklight.new(full_geoblacklight) }
  let(:basic_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight) }
  describe '#initialize' do
    it 'parses metadata argument JSON to Hash' do
      expect(basic_geobl.instance_variable_get(:@metadata)).to be_an Hash
    end
    describe 'merges fields argument into metadata' do
      let(:basic_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight, 'uuid' => 'new one', "extra_field" => true)}
      it 'overwrites existing metadata fields' do
        expect(basic_geobl.metadata['uuid']).to eq 'new one'
      end
      it 'adds in new fields' do
        expect(basic_geobl.metadata['extra_field']).to be true
      end
    end
  end
  describe '#metadata' do
    it 'reads the metadata instance variable' do
      expect(basic_geobl.metadata).to be_an Hash
      expect(basic_geobl.metadata).to have_key 'uuid'
    end
  end
  describe '#to_json' do
    it 'returns valid json' do
      expect(valid_json?(full_geobl.to_json)).to be_truthy
      expect(valid_json?(basic_geobl.to_json)).to be_truthy
    end
  end
  describe '#enhance_metadata' do
    let(:enhanced_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight, 'dct_references_s' => '', 'layer_geom_type_s' => 'Polygon') }
    before { enhanced_geobl.enhance_metadata }
    it 'calls enhancement methods to validate document' do
      expect { basic_geobl.valid? }.to raise_error JSON::Schema::ValidationError
      expect(enhanced_geobl.valid?).to be true
    end
    it 'enhances the dc_subject_sm field' do
      expect(enhanced_geobl.metadata['dc_subject_sm']).to include 'Boundaries', 'Inland Waters'
    end
  end
  describe '#valid?' do
    it 'a valid geoblacklight-schema document should be valid' do
      expect(full_geobl.valid?).to be true
    end
    it 'an invalid document' do
      expect { basic_geobl.valid? }.to raise_error JSON::Schema::ValidationError
    end
  end
end
