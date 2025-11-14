# frozen_string_literal: true

require 'spec_helper'

# TODO: Provide additional expectations on html structure
describe 'FGDC to html' do
  include XmlDocs

  let(:page) { GeoCombine::Fgdc.new(tufts_fgdc).to_html }

  describe 'Identification Information' do
    it 'has sections' do
      expect(page).to have_tag '#fgdc-identification-info' do
        with_tag 'dt', text: /Citation/
        with_tag 'dt', text: /Title/
        with_tag 'dd', text: /Drilling Towers 50k Scale Ecuador 2011/
        with_tag 'dt', text: /Abstract/
      end
    end
  end

  describe 'Data Quality Information' do
    it 'has sections' do
      expect(page).to have_tag '#fgdc-data-quality-info'
    end
  end

  describe 'Spatial Data Organization Information' do
    it 'has sections' do
      expect(page).to have_tag '#fgdc-spatialdataorganization-info'
    end
  end

  describe 'Entity and Attribute Information' do
    it 'has sections' do
      expect(page).to have_tag '#fgdc-spatialreference-info'
    end
  end

  describe 'Distribution Information' do
    it 'has sections' do
      expect(page).to have_tag '#fgdc-distribution-info'
    end
  end

  describe 'Metadata Reference Information' do
    it 'has sections' do
      expect(page).to have_tag '#fgdc-metadata-reference-info'
    end
  end

  describe 'Point of Contact' do
    it 'has contact info' do
      expect(page).to have_tag '#fgdc-identification-info'
    end
  end

  context 'with fgdc metadata from another institution' do
    let(:page) { GeoCombine::Fgdc.new(princeton_fgdc).to_html }

    it 'has temporal keywords' do
      expect(page).to have_tag 'dt', text: 'Temporal Keyword'
      expect(page).to have_tag 'dd', text: '2030'
    end

    it 'has supplemental information' do
      expect(page).to have_tag 'dt', text: 'Supplemental Information'
      expect(page).to have_tag 'dd', text: /The E\+ scenario/
    end

    it 'has a contact person' do
      expect(page).to have_tag 'dt', text: 'Contact Person'
      expect(page).to have_tag 'dd', text: 'Andrew Pascale'
    end

    it 'has a contact telephone' do
      expect(page).to have_tag 'dt', text: 'Contact Telephone'
      expect(page).to have_tag 'dd', text: '609-258-1097'
    end

    it 'has an attribute description source and a list of values' do
      expect(page).to have_tag 'dt', text: 'Definition Source'
      expect(page).to have_tag 'dd', text: 'Andlinger Center/HMEI'

      # Attribute elements are show by default
      expect(page).not_to have_tag 'button'
      expect(page).to have_tag 'dd', text: 'Desert Southwest'
    end

    it 'has a attribute source contribution' do
      expect(page).to have_tag 'dt', text: 'Contribution'
      expect(page).to have_tag 'dd', text: 'Net-Zero America report, 2020'
    end
  end
end
