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

  describe '#xsl_aardvark' do
    it 'is defined' do
      expect(fgdc_object.xsl_aardvark).to be_an Nokogiri::XSLT::Stylesheet
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
        expect(fgdc_geobl.metadata['dc_description_s']).to match('Ecuador created from')
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

  describe '#to_aardvark' do
    let(:fgdc_aardvark) { fgdc_object.to_aardvark }

    it 'returns a GeoCombine::GeoblacklightAardvark object' do
      expect(fgdc_aardvark).to be_an GeoCombine::GeoblacklightAardvark
    end

    it 'is valid Aardvark' do
      expect(fgdc_aardvark).to be_valid
    end

    describe 'with Aardvark schema fields' do
      it 'dct_title_s' do
        expect(fgdc_aardvark.metadata['dct_title_s']).to eq 'Drilling Towers 50k Scale Ecuador 2011'
      end

      it 'dct_description_sm labels each source element' do
        expect(fgdc_aardvark.metadata['dct_description_sm']).to be_an Array
        expect(fgdc_aardvark.metadata['dct_description_sm'].first).to start_with 'Abstract: '
        expect(fgdc_aardvark.metadata['dct_description_sm'].first).to match('Ecuador created from')
      end

      it 'dct_creator_sm' do
        expect(fgdc_aardvark.metadata['dct_creator_sm']).to eq ['Instituto Geografico Militar (Ecuador)']
      end

      it 'dct_publisher_sm' do
        expect(fgdc_aardvark.metadata['dct_publisher_sm']).to eq ['Instituto Geografico Militar (Ecuador)']
      end

      it 'schema_provider_s' do
        expect(fgdc_aardvark.metadata['schema_provider_s']).to eq 'Tufts University GIS Center'
      end

      it 'gbl_resourceClass_sm' do
        expect(fgdc_aardvark.metadata['gbl_resourceClass_sm']).to eq ['Datasets']
      end

      it 'gbl_resourceType_sm' do
        expect(fgdc_aardvark.metadata['gbl_resourceType_sm']).to eq ['Point data']
      end

      it 'dct_subject_sm' do
        expect(fgdc_aardvark.metadata['dct_subject_sm']).to include 'point', 'structure', 'economy',
                                                                    'Drilling platforms', 'Oil well drilling'
      end

      it 'dct_temporal_sm' do
        expect(fgdc_aardvark.metadata['dct_temporal_sm']).to eq ['2011']
      end

      it 'dct_issued_s' do
        expect(fgdc_aardvark.metadata['dct_issued_s']).to eq '2011'
      end

      it 'gbl_indexYear_im' do
        expect(fgdc_aardvark.metadata['gbl_indexYear_im']).to eq [2011]
      end

      it 'dct_spatial_sm' do
        expect(fgdc_aardvark.metadata['dct_spatial_sm']).to include 'Ecuador', 'República del Ecuador',
                                                                    'South America'
      end

      it 'locn_geometry' do
        expect(fgdc_aardvark.metadata['locn_geometry']).to eq 'ENVELOPE(-79.904768,-79.904768,-1.377743,-1.377743)'
      end

      it 'dcat_bbox' do
        expect(fgdc_aardvark.metadata['dcat_bbox']).to eq fgdc_aardvark.metadata['locn_geometry']
      end

      it 'dct_isPartOf_sm' do
        expect(fgdc_aardvark.metadata['dct_isPartOf_sm']).to eq ['Instituto Geografico Militar Data']
      end

      it 'dct_rights_sm labels each source element' do
        expect(fgdc_aardvark.metadata['dct_rights_sm']).to eq [
          'Use constraints: For educational noncommercial use only.',
          'Access constraints: Unrestricted Access Online'
        ]
      end

      it 'dct_accessRights_s' do
        expect(fgdc_aardvark.metadata['dct_accessRights_s']).to eq 'Public'
      end

      it 'dct_format_s' do
        expect(fgdc_aardvark.metadata['dct_format_s']).to eq 'Shapefile'
      end

      it 'gbl_fileSize_s' do
        expect(fgdc_aardvark.metadata['gbl_fileSize_s']).to eq '13.102'
      end

      it 'gbl_mdModified_dt' do
        expect(fgdc_aardvark.metadata['gbl_mdModified_dt']).to eq '2013-08-13T00:00:00Z'
      end

      it 'gbl_mdVersion_s' do
        expect(fgdc_aardvark.metadata['gbl_mdVersion_s']).to eq 'Aardvark'
      end
    end

    describe 'field types' do
      it 'returns multivalued fields as arrays' do
        %w[dct_description_sm dct_creator_sm dct_publisher_sm gbl_resourceClass_sm
           gbl_resourceType_sm dct_subject_sm dct_temporal_sm dct_spatial_sm
           dct_isPartOf_sm dct_rights_sm gbl_indexYear_im].each do |field|
          expect(fgdc_aardvark.metadata[field]).to be_an(Array), "expected #{field} to be an Array"
        end
      end

      it 'returns gbl_indexYear_im as integers' do
        expect(fgdc_aardvark.metadata['gbl_indexYear_im']).to all(be_an Integer)
      end

      it 'returns single-valued fields as strings' do
        %w[dct_title_s schema_provider_s dct_issued_s locn_geometry dcat_bbox
           dct_accessRights_s dct_format_s id gbl_mdVersion_s].each do |field|
          expect(fgdc_aardvark.metadata[field]).to be_a(String), "expected #{field} to be a String"
        end
      end
    end

    describe 'with user-supplied fields' do
      it 'uses a supplied provider as the id prefix' do
        record = fgdc_object.to_aardvark('schema_provider_s' => 'Tufts')
        expect(record.metadata['schema_provider_s']).to eq 'Tufts'
        expect(record.metadata['id']).to eq 'tufts-ecuador50kdrillingtower11'
      end

      it 'uses a supplied id' do
        record = fgdc_object.to_aardvark('id' => 'tufts-drilling-towers')
        expect(record.metadata['id']).to eq 'tufts-drilling-towers'
      end

      it 'merges fields the source metadata cannot provide' do
        references = { 'http://schema.org/url' => 'https://example.edu/catalog/tufts-1' }.to_json
        record = fgdc_object.to_aardvark('dct_references_s' => references)
        expect(record.metadata['dct_references_s']).to eq references
      end

      it 'derives the provider from the record when none is supplied' do
        expect(described_class.new(princeton_fgdc).to_aardvark.metadata['schema_provider_s'])
          .to eq 'Map and Geospatial Information Center, Lewis Library, Princeton University'
      end
    end

    describe 'with other FGDC records' do
      describe 'a record with a date range' do
        let(:record) { described_class.new(harvard_usgs_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'gbl_dateRange_drsim' do
          expect(record.metadata['gbl_dateRange_drsim']).to eq ['[1976 TO 1988]']
        end

        it 'takes gbl_indexYear_im from the start of the range' do
          expect(record.metadata['gbl_indexYear_im']).to eq [1976]
        end

        it 'dct_temporal_sm' do
          expect(record.metadata['dct_temporal_sm']).to eq ['1976-1988']
        end

        it 'dct_accessRights_s' do
          expect(record.metadata['dct_accessRights_s']).to eq 'Public'
        end
      end

      describe 'a record with a multi-paragraph abstract' do
        let(:record) { described_class.new(harvard_glb_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'collapses the line breaks' do
          expect(record.metadata['dct_description_sm'].first).to start_with 'Abstract: '
          expect(record.metadata['dct_description_sm'].first).not_to include "\n"
        end

        it 'gbl_resourceType_sm' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Point data']
        end
      end

      describe 'a restricted record' do
        let(:record) { described_class.new(harvard_kng_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'dct_accessRights_s' do
          expect(record.metadata['dct_accessRights_s']).to eq 'Restricted'
        end

        it 'matches the format name case-insensitively' do
          expect(record.metadata['dct_format_s']).to eq 'Shapefile'
        end

        it 'gbl_resourceType_sm' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Line data']
        end

        it 'does not include a citation from a Data Quality Information section' do
          expect(record.metadata).not_to have_key 'dct_isPartOf_sm'
        end
      end

      describe 'a record with abstract, purpose and supplemental information' do
        let(:record) { described_class.new(harvard_nhgis_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'labels all three description sources' do
          expect(record.metadata['dct_description_sm'].map { |d| d.split(':').first })
            .to eq ['Abstract', 'Purpose', 'Supplemental information']
        end

        it 'gbl_resourceType_sm' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Polygon data']
        end

        it 'dct_issued_s' do
          expect(record.metadata['dct_issued_s']).to eq '2006'
        end
      end

      describe 'a scanned map' do
        let(:record) { described_class.new(harvard_mapa_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'gbl_resourceClass_sm' do
          expect(record.metadata['gbl_resourceClass_sm']).to eq ['Maps']
        end

        it 'calculates resource type from spdoinfo/direct when there is no sdtstype' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Raster data']
        end

        it 'normalizes pubdate formatted as YYYYMM' do
          expect(record.metadata['dct_issued_s']).to eq '2009-05'
        end

        it 'dct_format_s' do
          expect(record.metadata['dct_format_s']).to eq 'JPEG2000'
        end

        it 'takes gbl_indexYear_im from the content date, not the publication date' do
          expect(record.metadata['gbl_indexYear_im']).to eq [1889]
        end
      end

      describe 'a record with quotation marks in the abstract' do
        let(:record) { described_class.new(princeton_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'escapes them rather than producing unparseable JSON' do
          expect(record.metadata['dct_description_sm'].first).to include '"E+"'
        end

        it 'collects every temporal value into a single field' do
          expect(record.metadata['dct_temporal_sm'])
            .to eq %w[2020-2050 2020 2025 2030 2035 2040 2045 2050]
        end
      end

      describe 'a record using GBL controlled keywords' do
        let(:record) { described_class.new(gbl_keywords_fgdc).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'use themekt keyword over geoform' do
          expect(record.metadata['gbl_resourceClass_sm']).to eq ['Maps']
        end

        it 'use themekt ketwords over spdoinfo' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Image data']
        end

        it 'dcat_theme_sm' do
          expect(record.metadata['dcat_theme_sm']).to eq ['Imagery and Base Maps']
        end

        it 'excludes the controlled keywords from dct_subject_sm' do
          expect(record.metadata['dct_subject_sm']).to eq ['Cartography', 'Geospatial data']
        end
      end
    end
  end

  describe '#to_html' do
    it 'creates a transformation of the metadata as a String' do
      expect(fgdc_object.to_html).to be_an String
    end
  end
end
