require 'spec_helper'

RSpec.describe GeoCombine::Iso19139 do
  include XmlDocs
  let(:iso_object){ GeoCombine::Iso19139.new(stanford_iso) }
  describe '#initialize' do
    it 'returns an instantiated Iso19139 object' do
      expect(iso_object).to be_an GeoCombine::Iso19139
    end
  end
  describe '#xsl' do
    it 'should be defined' do
      expect(iso_object.xsl).to be_an Nokogiri::XSLT::Stylesheet
    end
  end
  describe '#to_geoblacklight' do
    it 'should create a GeoCombine::Geoblacklight object' do
      expect(iso_object.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
end
