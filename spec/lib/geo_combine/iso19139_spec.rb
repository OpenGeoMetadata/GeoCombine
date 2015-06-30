require 'spec_helper'

RSpec.describe GeoCombine::Iso19139 do
  include XmlDocs
  let(:iso_object){ GeoCombine::Iso19139.new(stanford_iso) }
  describe '#initialize' do
    it 'returns an instantiated Iso19139 object' do
      expect(iso_object).to be_an GeoCombine::Iso19139
    end
  end
  describe '#xsl_geoblacklight' do
    it 'should be defined' do
      expect(iso_object.xsl_geoblacklight).to be_an Nokogiri::XSLT::Stylesheet
    end
  end
  describe '#xsl_html' do
    it 'should be defined' do
      expect(iso_object.xsl_geoblacklight).to be_an Nokogiri::XSLT::Stylesheet
    end
  end
  describe '#to_geoblacklight' do
    let(:valid_geoblacklight) { iso_object.to_geoblacklight('layer_geom_type_s' => 'Polygon', 'dct_references_s' => '') }
    it 'should create a GeoCombine::Geoblacklight object' do
      expect(valid_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
    it 'is valid GeoBlacklight-Schema' do
      valid_geoblacklight.enhance_metadata
      expect(valid_geoblacklight.valid?).to be_truthy
    end
    it 'should have dc_creator_sm' do
      expect(valid_geoblacklight.metadata["dc_creator_sm"]).to be_an Array
      expect(valid_geoblacklight.metadata["dc_creator_sm"]).to eq ["Circuit Rider Productions"]
    end
    it 'should have dc_publisher_sm' do
      expect(valid_geoblacklight.metadata["dc_publisher_sm"]).to be_an Array
      expect(valid_geoblacklight.metadata["dc_publisher_sm"]).to eq ["Circuit Rider Productions"]
    end    
  end
  describe '#to_html' do
    it 'should create a transformation of the metadata as a String' do
      expect(iso_object.to_html).to be_an String
    end
  end
end
