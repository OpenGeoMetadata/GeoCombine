require 'spec_helper'

#TODO Provide additional expectations on html structure
describe 'ISO 19139 to html' do
  include XmlDocs
  let(:page) { GeoCombine::Iso19139.new(stanford_iso).to_html }
  describe 'Identification Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-identification-info' do
        with_tag 'dt', text: /Citation/
        with_tag 'dt', text: /Title/
        with_tag 'dd', text: /Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999/
        with_tag 'dt', text: /Originator/
        with_tag 'dd', text: trim('Circuit Rider Productions'), count: 4
        with_tag 'dt', text: /Place of Publication/
        with_tag 'dd', text: /Windsor/
      end
    end
  end
  describe 'Spatial Reference Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-spatial-reference-info'
    end
  end
  describe 'Data Quality Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-data-quality-info'
    end
  end
  describe 'Distribution Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-distribution-info'
    end
  end
  describe 'Content Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-distribution-info'
    end
  end
  describe 'Spatial Representation Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-spatial-representation-info'
    end
  end
  describe 'Metadata Reference Information' do
    it 'has sections' do
      expect(page).to have_tag '#iso-metadata-reference-info'
    end
  end
end
