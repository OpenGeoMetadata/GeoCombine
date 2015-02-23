require 'spec_helper'

RSpec.describe GeoCombine::Fgdc do
  include XmlDocs
  let(:fgdc_object){ GeoCombine::Fgdc.new(tufts_fgdc) }
  describe '#initialize' do
    it 'returns an instantiated Fgdc object' do
      expect(fgdc_object).to be_an GeoCombine::Fgdc
    end
  end
  describe '#xsl_geoblacklight' do
    it 'should be defined' do
      expect(fgdc_object.xsl_geoblacklight).to be_an Nokogiri::XSLT::Stylesheet
    end
  end
  describe '#xsl_html'do
    it 'should be defined' do
      expect(fgdc_object.xsl_html).to be_an Nokogiri::XSLT::Stylesheet
    end
  end
  describe '#to_geoblacklight' do
    it 'returns a GeoCombine::Geoblacklight object' do
      pending('fgdc2geoBL.xsl is incomplete and can cause errors')
      expect(fgdc_object.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
  describe '#to_html' do
    it 'should create a transformation of the metadata as a String' do
      expect(fgdc_object.to_html).to be_an String
    end
  end
end
