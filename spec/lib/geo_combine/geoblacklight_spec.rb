# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Geoblacklight do
  include XmlDocs
  include JsonDocs
  include GeoCombine::Exceptions
  let(:full_geobl) { described_class.new(full_geoblacklight) }
  let(:enhanced_geobl) { described_class.new(basic_geoblacklight, 'layer_geom_type_s' => 'esriGeometryPolygon') }
  let(:basic_geobl) { described_class.new(basic_geoblacklight) }
  let(:pre_v1_geobl) { described_class.new(geoblacklight_pre_v1) }
  let(:enhanced_geobl) { described_class.new(basic_geoblacklight, 'layer_geom_type_s' => 'esriGeometryPolygon') }

  before { enhanced_geobl.enhance_metadata }

  describe '#initialize' do
    it 'parses metadata argument JSON to Hash' do
      expect(basic_geobl.instance_variable_get(:@metadata)).to be_an Hash
    end

    describe 'merges fields argument into metadata' do
      let(:basic_geobl) do
        described_class.new(basic_geoblacklight, 'dc_identifier_s' => 'new one', 'extra_field' => true)
      end

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

  describe '#enhance_metadata' do
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

    context 'must have required fields' do
      %w[
        dc_title_s
        dc_identifier_s
        dc_rights_s
        dct_provenance_s
        layer_slug_s
        solr_geom
      ].each do |field|
        it field do
          full_geobl.metadata.delete field
          expect { full_geobl.valid? }.to raise_error(JSON::Schema::ValidationError, /#{field}/)
        end
      end
    end

    context 'need not have optional fields' do
      %w[
        dc_description_s
        dc_format_s
        dc_language_s
        dc_publisher_s
        dc_source_sm
        dc_subject_sm
        dct_isPartOf_sm
        dct_issued_dt
        dct_references_s
        dct_spatial_sm
        dct_temporal_sm
        geoblacklight_version
        layer_geom_type_s
        layer_id_s
        layer_modified_dt
        solr_year_i
      ].each do |field|
        it field do
          full_geobl.metadata.delete field
          expect { full_geobl.valid? }.not_to raise_error
        end
      end
    end

    context 'need not have deprecated fields' do
      %w[
        dc_relation_sm
        dc_type_s
        georss_box_s
        georss_point_s
        uuid
      ].each do |field|
        it field do
          full_geobl.metadata.delete field
          expect { full_geobl.valid? }.not_to raise_error
        end
      end
    end

    it 'an invalid document' do
      expect { basic_geobl.valid? }.to raise_error JSON::Schema::ValidationError
    end

    it 'calls the dct_references_s validator' do
      expect(enhanced_geobl).to receive(:dct_references_validate!)
      enhanced_geobl.valid?
    end

    it 'validates spatial bounding box' do
      expect(JSON::Validator).to receive(:validate!).and_return true
      expect { basic_geobl.valid? }
        .to raise_error GeoCombine::Exceptions::InvalidGeometry
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
            "http://schema.org/url":"http://example.com/abc123",,
            "http://schema.org/downloadUrl":"http://example.com/abc123/data.zip"
          }
        JSON
      end
      let(:bad_ref) do
        described_class.new(
          basic_geoblacklight, 'dct_references_s' => unparseable_json, 'layer_geom_type_s' => 'esriGeometryPolygon'
        )
      end
      let(:not_hash) do
        described_class.new(
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

  describe 'spatial_validate!' do
    context 'when valid' do
      it { expect { full_geobl.spatial_validate! }.not_to raise_error }
    end

    context 'when invalid' do
      it { expect { basic_geobl.spatial_validate! }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end
  end

  describe 'upgrade_to_v1' do
    before do
      expect(pre_v1_geobl).to receive(:upgrade_to_v1).and_call_original
      pre_v1_geobl.enhance_metadata
    end

    it 'tags with version' do
      expect(pre_v1_geobl.metadata).to include('geoblacklight_version' => '1.0')
    end

    it 'properly deprecates fields' do
      described_class::DEPRECATED_KEYS_V1.each do |k|
        expect(pre_v1_geobl.metadata.keys).not_to include(k.to_s)
      end
    end

    it 'normalizes slugs' do
      expect(pre_v1_geobl.metadata).to include('layer_slug_s' => 'sde-columbia-esri-arcatlas-snow-ln')
    end
  end
end
