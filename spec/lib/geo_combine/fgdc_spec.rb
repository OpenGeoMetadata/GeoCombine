require 'spec_helper'

RSpec.describe GeoCombine::Fgdc do
  include XmlDocs
  let(:fgdc_object){ GeoCombine::Fgdc.new(tufts_fgdc) }
  describe '#initialize' do
    it 'returns an instantiated Fgdc object' do
      expect(fgdc_object).to be_an GeoCombine::Fgdc
    end
  end
  describe '#xsl' do
    it 'should be defined' do
      expect(fgdc_object.xsl).to be_an Nokogiri::XSLT::Stylesheet
    end
  end
  describe '#to_geoblacklight' do
    it 'returns a GeoCombine::Geoblacklight object' do
      pending('fgdc2geoBL.xsl is incomplete and can cause errors')
      expect(fgdc_object.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
end
