require 'spec_helper'

RSpec.describe GeoCombine::CkanMetadata do
  include JsonDocs
  let(:ckan_sample) { GeoCombine::CkanMetadata.new(ckan_metadata) }
  describe '#to_geoblacklight' do
    it 'returns a GeoCombine::Geoblacklight' do
      expect(ckan_sample.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
  describe '#geoblacklight_terms' do
    describe 'builds a hash which maps metadata' do
      let(:metadata) { ckan_sample.instance_variable_get(:@metadata) }
      it 'with dc_identifier_s' do
        expect(ckan_sample.geoblacklight_terms).to include(dc_identifier_s: metadata['id'])
      end
      it 'with dc_title_s' do
        expect(ckan_sample.geoblacklight_terms).to include(dc_title_s: metadata['title'])
      end
      it 'with dc_rights_s' do
        expect(ckan_sample.geoblacklight_terms).to include(dc_rights_s: 'Public')
      end
      it 'with dct_provenance_s' do
        expect(ckan_sample.geoblacklight_terms).to include(dct_provenance_s: metadata['organization']['title'])
      end
      it 'with layer_slug_s' do
        expect(ckan_sample.geoblacklight_terms).to include(layer_slug_s: metadata['name'])
      end
      it 'with solr_geom' do
        expect(ckan_sample.geoblacklight_terms).to include(solr_geom: 'ENVELOPE(-158.2, -105.7, 59.2, 8.9)')
      end
      it 'with dc_subject_sm' do
        expect(ckan_sample.geoblacklight_terms[:dc_subject_sm].length).to eq 63
      end
    end
  end
end
