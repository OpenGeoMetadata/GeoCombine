require 'spec_helper'

RSpec.describe GeoCombine::EsriOpenData do
  include JsonDocs
  let(:esri_sample) { GeoCombine::EsriOpenData.new(esri_opendata_metadata) }
  let(:metadata) { esri_sample.instance_variable_get(:@metadata) }
  describe '#initialize' do
    it 'parses metadata argument JSON to Hash' do
      expect(esri_sample.instance_variable_get(:@metadata)).to be_an Hash
    end
    it 'puts extend data into @geometry' do
      expect(esri_sample.instance_variable_get(:@geometry)).to be_an Array
    end
  end
  describe '#to_geoblacklight' do
    it 'calls geoblacklight_terms to create a GeoBlacklight object' do
      expect(esri_sample).to receive(:geoblacklight_terms).and_return({})
      expect(esri_sample.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
  describe '#geoblacklight_terms' do
    describe 'builds a hash which maps metadata' do
      let(:metadata) { esri_sample.instance_variable_get(:@metadata) }
      it 'with uuid' do
        expect(esri_sample.geoblacklight_terms).to include(uuid: metadata['id'])
      end
      it 'with dc_identifier_s' do
        expect(esri_sample.geoblacklight_terms).to include(dc_identifier_s: metadata['id'])
      end
      it 'with dc_title_s' do
        expect(esri_sample.geoblacklight_terms).to include(dc_title_s: metadata['name'])
      end
      it 'with dc_description_s sanitized' do
        expect(esri_sample).to receive(:sanitize_and_remove_lines).and_return 'sanitized'
        expect(esri_sample.geoblacklight_terms).to include(dc_description_s: 'sanitized')
      end
      it 'with dc_rights_s' do
        expect(esri_sample.geoblacklight_terms).to include(dc_rights_s: 'Public')
      end
      it 'with dct_provenance_s' do
        expect(esri_sample.geoblacklight_terms).to include(dct_provenance_s: metadata['owner'])
      end
      it 'with dct_references_s' do
        expect(esri_sample).to receive(:references).and_return ''
        expect(esri_sample.geoblacklight_terms).to include(:dct_references_s)
      end
      it 'with georss_box_s' do
        expect(esri_sample).to receive(:georss_box).and_return ''
        expect(esri_sample.geoblacklight_terms).to include(georss_box_s: '')
      end
      it 'with layer_id_s that is blank' do
        expect(esri_sample.geoblacklight_terms).to include(layer_id_s: '')
      end
      it 'with layer_geom_type_s' do
        expect(esri_sample.geoblacklight_terms).to include(layer_geom_type_s: metadata['geometry_type'])
      end
      it 'with layer_modified_dt' do
        expect(esri_sample.geoblacklight_terms).to include(layer_modified_dt: metadata['updated_at'])
      end
      it 'with layer_slug_s' do
        expect(esri_sample.geoblacklight_terms).to include(layer_slug_s: metadata['id'])
      end
      it 'with solr_geom' do
        expect(esri_sample).to receive(:envelope).and_return ''
        expect(esri_sample.geoblacklight_terms).to include(solr_geom: '')
      end
      it 'with dc_subject_sm' do
        expect(esri_sample.geoblacklight_terms).to include(dc_subject_sm: metadata['tags'])
      end
    end
  end
  describe '#references' do
    it 'converts references to a JSON string' do
      expect(esri_sample).to receive(:references_hash).and_return({})
      expect(esri_sample.references).to be_an String
    end
  end
  describe '#references_hash' do
    it 'builds out references' do
      expect(esri_sample.references_hash).to include('http://schema.org/url' => metadata['landing_page'])
      expect(esri_sample.references_hash).to include('http://resources.arcgis.com/en/help/arcgis-rest-api' => metadata['url'])
    end
  end
  describe '#georss_box' do
    it 'creates a GeoRSS box' do
      expect(esri_sample.georss_box).to be_an String
      expect(esri_sample.georss_box.split(' ').count).to eq 4
    end
  end
  describe '#envelope' do
    it 'creates an envelope for use in Solr' do
      expect(esri_sample.envelope).to be_an String
      expect(esri_sample.envelope).to match /ENVELOPE\(/
    end
  end
end
