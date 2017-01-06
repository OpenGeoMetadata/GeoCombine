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
      context 'with no information resources' do
        let(:ckan_sample) do
          ckan = GeoCombine::CkanMetadata.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['resources'].delete_if { |resource| resource['resource_locator_function'] == 'information' }
          ckan
        end
        it 'has no url (home page) in dct_references_s' do
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/url')
        end
      end
      context 'with no download resources' do
        let(:ckan_sample) do
          ckan = GeoCombine::CkanMetadata.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['resources'].delete_if { |resource| resource['resource_locator_function'] == 'download' }
          ckan
        end
        it 'has no downloadUrl in dct_references_s' do
          expect(ckan_sample.downloadable?).to be_falsey
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/downloadUrl')
        end
      end
      context 'with a ZIP download' do
        let(:ckan_sample) do
          ckan = GeoCombine::CkanMetadata.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['resources'] = [
            {
              'resource_locator_function' => 'download',
              'format' => 'ZIP',
              'url' => 'https://example.com/layer.zip'
            }
          ]
          ckan
        end
        it 'has a format and a download URL' do
          expect(ckan_sample.downloadable?).to be_truthy
          expect(ckan_sample.geoblacklight_terms).to include(dc_format_s: 'ZIP')
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).to include('http://schema.org/downloadUrl' => 'https://example.com/layer.zip')
        end
      end
      context 'without any resources' do
        let(:ckan_sample) do
          ckan = GeoCombine::CkanMetadata.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata.delete('resources')
          ckan
        end
        it 'has no urls in dct_references_s' do
          expect(ckan_sample.downloadable?).to be_falsey
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/url')
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/downloadUrl')
        end
      end
      context 'with very long descriptions' do
        let(:ckan_sample) do
          ckan = GeoCombine::CkanMetadata.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['notes'] = 'x' * 50000
          ckan
        end
        it 'restricts the size' do
          expect(ckan_sample.geoblacklight_terms[:dc_description_s].length).to eq GeoCombine::CkanMetadata::MAX_STRING_LENGTH + 1
        end
      end
      context 'with no descriptions' do
        let(:ckan_sample) do
          ckan = GeoCombine::CkanMetadata.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['notes'] = nil
          ckan
        end
        it 'omits the description' do
          expect(ckan_sample.geoblacklight_terms).not_to include(:dc_description_s)
        end
      end
    end
  end
end
