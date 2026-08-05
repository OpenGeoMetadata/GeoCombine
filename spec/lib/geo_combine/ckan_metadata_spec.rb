# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::CkanMetadata do
  include JsonDocs

  let(:ckan_sample) { described_class.new(ckan_metadata) }

  describe '#to_geoblacklight' do
    it 'returns a GeoCombine::Geoblacklight' do
      expect(ckan_sample.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end

  describe 'solr_geom' do
    def record_with(extras)
      described_class.new(
        { 'id' => 'x', 'title' => 'Test', 'name' => 'test', 'organization' => { 'title' => 'Org' },
          'extras' => extras.map { |k, v| { 'key' => k, 'value' => v } } }.to_json
      )
    end

    let(:out_of_range_bbox) do
      { 'bbox-west-long' => '-10', 'bbox-south-lat' => '-20',
        'bbox-east-long' => '30', 'bbox-north-lat' => '200' }
    end

    it 'uses the bbox extras' do
      record = record_with('bbox-west-long' => '-10', 'bbox-south-lat' => '-20',
                           'bbox-east-long' => '30', 'bbox-north-lat' => '40',
                           'spatial' => '1,2,3,4')
      expect(record.geoblacklight_terms[:solr_geom]).to eq 'ENVELOPE(-10.0, 30.0, 40.0, -20.0)'
    end

    it 'can falls back to a comma delimited spatial extra when the bbox is out of range' do
      record = record_with(out_of_range_bbox.merge('spatial' => '-10,-20,30,40'))
      expect(record.geoblacklight_terms[:solr_geom]).to eq 'ENVELOPE(-10.0, 30.0, 40.0, -20.0)'
    end

    it 'can fall back to a space delimited spatial extra when the bbox is out of range' do
      record = record_with(out_of_range_bbox.merge('spatial' => '10 20 30 40'))
      expect(record.geoblacklight_terms[:solr_geom]).to eq 'ENVELOPE(10.0, 30.0, 40.0, 20.0)'
    end

    it 'omits solr_geom when neither the bbox nor the spatial extra is valid' do
      record = record_with(out_of_range_bbox.merge('spatial' => '300,400,500,600'))
      expect(record.geoblacklight_terms).not_to have_key(:solr_geom)
    end

    it 'reads missing extras as empty' do
      record = described_class.new(
        { 'id' => 'x', 'title' => 'Test', 'name' => 'test', 'organization' => { 'title' => 'Org' } }.to_json
      )
      expect(record.geoblacklight_terms[:dc_subject_sm]).to eq []
      expect(record.geoblacklight_terms[:solr_geom]).to eq 'ENVELOPE(0.0, 0.0, 0.0, 0.0)'
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
          ckan = described_class.new(ckan_metadata)
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
          ckan = described_class.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['resources'].delete_if { |resource| resource['resource_locator_function'] == 'download' }
          ckan
        end

        it 'has no downloadUrl in dct_references_s' do
          expect(ckan_sample).not_to be_downloadable
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/downloadUrl')
        end
      end

      context 'with a ZIP download' do
        let(:ckan_sample) do
          ckan = described_class.new(ckan_metadata)
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
          expect(ckan_sample).to be_downloadable
          expect(ckan_sample.geoblacklight_terms).to include(dc_format_s: 'ZIP')
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).to include('http://schema.org/downloadUrl' => 'https://example.com/layer.zip')
        end
      end

      context 'without any resources' do
        let(:ckan_sample) do
          ckan = described_class.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata.delete('resources')
          ckan
        end

        it 'has no urls in dct_references_s' do
          expect(ckan_sample).not_to be_downloadable
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/url')
          expect(JSON.parse(ckan_sample.geoblacklight_terms[:dct_references_s])).not_to include('http://schema.org/downloadUrl')
        end
      end

      context 'with very long descriptions' do
        let(:ckan_sample) do
          ckan = described_class.new(ckan_metadata)
          metadata = ckan.instance_variable_get('@metadata')
          metadata['notes'] = 'x' * 50_000
          ckan
        end

        it 'restricts the size' do
          expect(ckan_sample.geoblacklight_terms[:dc_description_s].length).to eq GeoCombine::CkanMetadata::MAX_STRING_LENGTH + 1
        end
      end

      context 'with no descriptions' do
        let(:ckan_sample) do
          ckan = described_class.new(ckan_metadata)
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
