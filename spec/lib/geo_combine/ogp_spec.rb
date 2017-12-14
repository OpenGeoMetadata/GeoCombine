require 'spec_helper'

RSpec.describe GeoCombine::OGP do
  include JsonDocs

  subject(:ogp) { GeoCombine::OGP.new(ogp_harvard_raster) }
  let(:ogp_tufts) { GeoCombine::OGP.new(ogp_tufts_vector) }
  let(:ogp_line) { GeoCombine::OGP.new(ogp_harvard_line) }
  let(:metadata) { ogp.instance_variable_get(:@metadata) }

  describe '#initialize' do
    it 'parses JSON into metadata Hash' do
      expect(metadata).to be_an Hash
    end
  end

  describe '#to_geoblacklight' do
    it 'calls geoblacklight_terms to create a GeoBlacklight object' do
      expect(ogp).to receive(:geoblacklight_terms).and_return({})
      expect(ogp.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end

  describe '#geoblacklight_terms' do
    describe 'builds a hash which maps metadata' do
      it 'with dc_identifier_s' do
        expect(ogp.geoblacklight_terms).to include(dc_identifier_s: 'HARVARD.SDE2.G1059_W57_1654_PF_SH1')
      end
      it 'with dc_title_s' do
        expect(ogp.geoblacklight_terms).to include(dc_title_s: 'World Map, 1654 (Raster Image)')
      end
      it 'with dc_description_s sanitized' do
        expect(ogp.geoblacklight_terms).to include(dc_description_s: metadata['Abstract'])
      end
      it 'with dc_rights_s' do
        expect(ogp.geoblacklight_terms).to include(dc_rights_s: 'Public')
        expect(ogp_line.geoblacklight_terms).to include(dc_rights_s: 'Restricted')
      end
      it 'with dct_provenance_s' do
        expect(ogp.geoblacklight_terms).to include(dct_provenance_s: 'Harvard')
      end
      it 'with dct_references_s' do
        expect(ogp.geoblacklight_terms).to include(:dct_references_s)
      end
      it 'with layer_id_s that is blank' do
        expect(ogp.geoblacklight_terms)
          .to include(layer_id_s: "#{metadata['WorkspaceName']}:#{metadata['Name']}")
      end
      it 'with layer_geom_type_s' do
        expect(ogp.geoblacklight_terms).to include(:layer_geom_type_s)
      end
      it 'with layer_slug_s' do
        expect(ogp.geoblacklight_terms)
          .to include(layer_slug_s: 'harvard-g1059-w57-1654-pf-sh1')
      end
      it 'with solr_geom' do
        expect(ogp.geoblacklight_terms).to include(:solr_geom)
      end
      it 'with dc_subject_sm' do
        expect(ogp.geoblacklight_terms).to include(
          dc_subject_sm: [
            'Maps', 'Human settlements', 'Cities and towns', 'Villages',
            'Bodies of water', 'Landforms', 'Transportation',
            'imageryBaseMapsEarthCover'
          ]
        )
      end
      it 'with dct_spatial_sm' do
        expect(ogp.geoblacklight_terms).to include(
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
      expect(ogp.ogp_geom).to eq 'Raster'
    end
    it 'anything else, return it' do
      expect(ogp_tufts.ogp_geom).to eq 'Polygon'
    end
  end

  describe '#ogp_formats' do
    context 'when Paper Map or Raster' do
      it 'returns GeoTIFF' do
        %w[Raster Paper\ Map].each do |datatype|
          expect(ogp).to receive(:metadata).and_return('DataType' => datatype)
          expect(ogp.ogp_formats).to eq 'GeoTIFF'
        end

      end
    end
    context 'when Polygon, Line, or Point' do
      it 'returns Shapefile' do
        %w[Polygon Line Point].each do |datatype|
          expect(ogp).to receive(:metadata).and_return('DataType' => datatype)
          expect(ogp.ogp_formats).to eq 'Shapefile'
        end
      end
    end
    context 'unknown data types' do
      it 'throws exception' do
        expect(ogp).to receive(:metadata).and_return('DataType' => 'Unknown')
        expect { ogp.ogp_formats }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#envelope' do
    it 'properly formatted envelope' do
      expect(ogp.envelope).to eq 'ENVELOPE(-180.0, 180.0, 90.0, -90.0)'
    end
    it 'fails on out-of-bounds envelopes' do
      expect(ogp).to receive(:west).and_return(-181)
      expect { ogp.envelope }.to raise_error(ArgumentError)
    end
  end

  describe '#references' do
    context 'harvard raster' do
      it 'has wms and download services' do
        expect(JSON.parse(ogp.references)).to include(
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://pelham.lib.harvard.edu:8080/geoserver/wms',
          'http://schema.org/DownloadAction' => 'http://pelham.lib.harvard.edu:8080/HGL/HGLOpenDelivery'
        )
      end
    end
    context 'tufts vector' do
      it 'has wms wfs services' do
        expect(JSON.parse(ogp_tufts.references)).to include(
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://geoserver01.uit.tufts.edu/wms',
          'http://www.opengis.net/def/serviceType/ogc/wfs' => 'http://geoserver01.uit.tufts.edu/wfs'
        )
      end
    end
    context 'harvard line' do
      it 'has restricted services' do
        expect(JSON.parse(ogp_line.references)).to include(
          'http://www.opengis.net/def/serviceType/ogc/wfs' => 'http://hgl.harvard.edu:8080/geoserver/wfs',
          'http://www.opengis.net/def/serviceType/ogc/wms' => 'http://hgl.harvard.edu:8080/geoserver/wms'
        )
        expect(JSON.parse(ogp_line.references)).not_to include('http://schema.org/DownloadAction')
      end
    end
  end

  describe 'valid geoblacklight schema' do
    context 'harvard' do
      it { expect { ogp.to_geoblacklight.valid? }.to_not raise_error }
      it { expect { ogp_line.to_geoblacklight.valid? }.to_not raise_error }
    end
    context 'tufts' do
      it { expect { ogp_tufts.to_geoblacklight.valid? }.to_not raise_error }
    end
  end
end
