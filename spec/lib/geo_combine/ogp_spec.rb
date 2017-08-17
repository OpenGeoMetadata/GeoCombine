require 'spec_helper'

RSpec.describe GeoCombine::OGP do
  include JsonDocs
  let(:ogp_harvard) { GeoCombine::OGP.new(ogp_harvard_raster) }
  let(:metadata) { ogp_harvard.instance_variable_get(:@metadata) }
  let(:ogp_tufts) { GeoCombine::OGP.new(ogp_tufts_vector) }
  # let(:metadata) { ogp_harvard.instance_variable_get(:@metadata) }
  describe '#initialize' do
    it 'parses JSON into metadata Hash' do
      expect(ogp_harvard.instance_variable_get(:@metadata)).to be_an Hash
    end
  end
  describe '#to_geoblacklight' do
    it 'calls geoblacklight_terms to create a GeoBlacklight object' do
      expect(ogp_harvard).to receive(:geoblacklight_terms).and_return({})
      expect(ogp_harvard.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
  describe '#geoblacklight_terms' do
    describe 'builds a hash which maps metadata' do
      it 'with dc_identifier_s' do
        expect(ogp_harvard.geoblacklight_terms).to include(dc_identifier_s: metadata['LayerId'])
      end
      it 'with dc_title_s' do
        expect(ogp_harvard.geoblacklight_terms).to include(dc_title_s: metadata['LayerDisplayName'])
      end
      it 'with dc_description_s sanitized' do
        expect(ogp_harvard.geoblacklight_terms).to include(dc_description_s: metadata['Abstract'])
      end
      it 'with dc_rights_s' do
        expect(ogp_harvard.geoblacklight_terms).to include(dc_rights_s: 'Public')
      end
      it 'with dct_provenance_s' do
        expect(ogp_harvard.geoblacklight_terms).to include(dct_provenance_s: metadata['Institution'])
      end
      it 'with dct_references_s' do
        expect(ogp_harvard).to receive(:references).and_return ''
        expect(ogp_harvard.geoblacklight_terms).to include(:dct_references_s)
      end
      it 'with layer_id_s that is blank' do
        expect(ogp_harvard.geoblacklight_terms)
          .to include(layer_id_s: "#{metadata['WorkspaceName']}:#{metadata['Name']}")
      end
      it 'with layer_geom_type_s' do
        expect(ogp_harvard).to receive(:ogp_geom).and_return ''
        expect(ogp_harvard.geoblacklight_terms).to include(:layer_geom_type_s)
      end
      it 'with layer_slug_s' do
        expect(ogp_harvard.geoblacklight_terms)
          .to include(layer_slug_s: 'harvard-sde2-g1059-w57-1654-pf-sh1')
      end
      it 'with solr_geom' do
        expect(ogp_harvard).to receive(:envelope).and_return ''
        expect(ogp_harvard.geoblacklight_terms).to include(solr_geom: '')
      end
      it 'with dc_subject_sm' do
        expect(ogp_harvard.geoblacklight_terms).to include(
          dc_subject_sm: [
            'Maps', 'Human settlements', 'Cities and towns', 'Villages',
            'Bodies of water', 'Landforms', 'Transportation',
            'imageryBaseMapsEarthCover'
          ]
        )
      end
      it 'with dct_spatial_sm' do
        expect(ogp_harvard.geoblacklight_terms).to include(
          dct_spatial_sm: [
            'Earth', 'Northern Hemisphere', 'Southern Hemisphere',
            'Eastern Hemisphere', 'Western Hemisphere', 'Africa', 'Asia',
            'Australia', 'Europe', 'North America', 'South America',
            'Arctic regions'
          ]
        )
      end
    end
  end
  describe '#ogp_geom' do
    it 'when Paper Map use Raster' do
      expect(ogp_harvard.ogp_geom).to eq 'Raster'
    end
    it 'anything else, return it' do
      expect(ogp_tufts.ogp_geom).to eq 'Polygon'
    end
  end
  describe '#ogp_formats' do
    context 'when Paper Map or Raster' do
      it 'returns GeoTIFF' do
        expect(ogp_harvard).to receive(:metadata).and_return('DataType' => 'Raster')
        expect(ogp_harvard.ogp_formats).to eq 'GeoTIFF'
        expect(ogp_harvard).to receive(:metadata).and_return('DataType' => 'Paper Map')
        expect(ogp_harvard.ogp_formats).to eq 'GeoTIFF'
      end
    end
    context 'when Polygon, Line, or Point' do
      it 'returns Shapefile' do
        expect(ogp_harvard).to receive(:metadata).and_return('DataType' => 'Polygon')
        expect(ogp_harvard.ogp_formats).to eq 'Shapefile'
        expect(ogp_harvard).to receive(:metadata).and_return('DataType' => 'Line')
        expect(ogp_harvard.ogp_formats).to eq 'Shapefile'
        expect(ogp_harvard).to receive(:metadata).and_return('DataType' => 'Point')
        expect(ogp_harvard.ogp_formats).to eq 'Shapefile'
      end
    end
  end
  describe '#envelope' do
    it 'properly formatted envelope' do
      expect(ogp_harvard.envelope).to eq 'ENVELOPE(-180, 180, 90, -90)'
    end
  end
  describe '#references' do
    context 'harvard raster' do
      it do
        expect(JSON.parse(ogp_harvard.references)).to include(
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://pelham.lib.harvard.edu:8090/geoserver/wms',
          'http://schema.org/DownloadAction' => 'http://pelham.lib.harvard.edu:8080/HGL/HGLOpenDelivery'
        )
      end
    end
    context 'tufts vector' do
      it do
        expect(JSON.parse(ogp_tufts.references)).to include(
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://geoserver01.uit.tufts.edu/wms',
          'http://www.opengis.net/def/serviceType/ogc/wfs' => 'http://geoserver01.uit.tufts.edu/wfs'
        )
      end
    end
  end
  describe 'valid geoblacklight schema' do
    context 'harvard' do
      it { expect { ogp_harvard.to_geoblacklight.valid? }.to_not raise_error }
    end
    context 'tufts' do
      it { expect { ogp_tufts.to_geoblacklight.valid? }.to_not raise_error }
    end
  end
end
