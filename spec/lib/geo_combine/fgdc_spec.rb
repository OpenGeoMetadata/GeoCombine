# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Fgdc do
  include XmlDocs

  let(:fgdc_object) { described_class.new(tufts_fgdc) }

  describe '#initialize' do
    it 'returns an instantiated Fgdc object' do
      expect(fgdc_object).to be_an described_class
    end
  end

  describe '#xsl_geoblacklight' do
    it 'is defined' do
      expect(fgdc_object.xsl_geoblacklight).to be_an Nokogiri::XSLT::Stylesheet
    end
  end

  describe '#xsl_html' do
    it 'is defined' do
      expect(fgdc_object.xsl_html).to be_an Nokogiri::XSLT::Stylesheet
    end
  end

  describe '#to_geoblacklight' do
    let(:fgdc_geobl) { fgdc_object.to_geoblacklight }

    it 'returns a GeoCombine::Geoblacklight object' do
      expect(fgdc_geobl).to be_an GeoCombine::Geoblacklight
    end

    it 'is not valid due to bad modification date but valid otherwise' do
      expect { fgdc_geobl.validate! }.to raise_error(JSON::Schema::ValidationError, /layer_modified_dt/)
      fgdc_geobl.metadata.delete 'layer_modified_dt'
      expect(fgdc_geobl).to be_valid
    end

    describe 'with GeoBlacklight-Schema fields' do
      it 'geoblacklight_version' do
        expect(fgdc_geobl.metadata['geoblacklight_version']).to eq '1.0'
      end

      it 'dc_identifier_s' do
        expect(fgdc_geobl.metadata['dc_identifier_s']).to eq 'http://www.geoportaligm.gob.ec/portal/'
      end

      it 'dc_title_s' do
        expect(fgdc_geobl.metadata['dc_title_s']).to eq 'Drilling Towers 50k Scale Ecuador 2011'
      end

      it 'dc_description_s' do
        expect(fgdc_geobl.metadata['dc_description_s']).to match(/Ecuador created from/)
      end

      it 'dc_rights_s' do
        expect(fgdc_geobl.metadata['dc_rights_s']).to eq 'Public'
      end

      it 'dct_provenance_s' do
        expect(fgdc_geobl.metadata['dct_provenance_s']).to eq 'Tufts'
      end

      it 'layer_id_s' do
        expect(fgdc_geobl.metadata['layer_id_s']).to eq 'urn:Ecuador50KDrillingTower11'
      end

      it 'layer_slug_s' do
        expect(fgdc_geobl.metadata['layer_slug_s']).to eq 'Tufts-Ecuador50KDrillingTower11'
      end

      it 'layer_modified_dt' do
        expect(fgdc_geobl.metadata['layer_modified_dt']).to eq '2013-08-13'
      end

      it 'dc_creator_sm' do
        expect(fgdc_geobl.metadata['dc_creator_sm']).to be_an Array
        expect(fgdc_geobl.metadata['dc_creator_sm']).to include 'Instituto Geografico Militar (Ecuador)'
      end

      it 'dc_format_s' do
        expect(fgdc_geobl.metadata['dc_format_s']).to eq 'Shapefile'
      end

      it 'dc_language_s' do
        expect(fgdc_geobl.metadata['dc_language_s']).to eq 'English'
      end

      it 'dc_type_s' do
        expect(fgdc_geobl.metadata['dc_type_s']).to eq 'Dataset'
      end

      it 'dc_subject_sm' do
        expect(fgdc_geobl.metadata['dc_subject_sm']).to be_an Array
        expect(fgdc_geobl.metadata['dc_subject_sm']).to include 'point', 'structure', 'economy', 'Drilling platforms',
                                                                'Oil well drilling'
      end

      it 'dc_spatial_sm' do
        expect(fgdc_geobl.metadata['dc_spatial_sm']).to be_an Array
        expect(fgdc_geobl.metadata['dc_spatial_sm']).to include 'Ecuador', 'República del Ecuador',
                                                                'Northern Hemisphere', 'Southern Hemisphere', 'Western Hemisphere', 'South America'
      end

      it 'dct_issued_s' do
        expect(fgdc_geobl.metadata['dct_issued_s']).to eq '2011'
      end

      it 'dct_temporal_sm' do
        expect(fgdc_geobl.metadata['dct_temporal_sm']).to be_an Array
        expect(fgdc_geobl.metadata['dct_temporal_sm']).to include '2011'
      end

      it 'dct_isPartOf_sm' do
        expect(fgdc_geobl.metadata['dct_isPartOf_sm']).to be_an Array
        expect(fgdc_geobl.metadata['dct_isPartOf_sm']).to include 'Ecuador', 'Instituto Geografico Militar Data'
      end

      it 'solr_geom' do
        expect(fgdc_geobl.metadata['solr_geom']).to eq 'ENVELOPE(-79.904768, -79.904768, -1.377743, -1.377743)'
      end

      it 'solr_year_i' do
        expect(fgdc_geobl.metadata['solr_year_i']).to eq 2011
      end
    end
  end

  describe '#to_html' do
    it 'creates a transformation of the metadata as a String' do
      expect(fgdc_object.to_html).to be_an String
    end
  end
end
