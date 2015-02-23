require 'spec_helper'

RSpec.describe GeoCombine::Metadata do
  include XmlDocs
  describe '#initialize' do
    it 'reads metadata from file if File is readable' do
      expect(File).to receive(:readable?).and_return(true)
      expect(File).to receive(:read).and_return(simple_xml)
      metadata_object = GeoCombine::Metadata.new('./tmp/fake/file/location')
      expect(metadata_object).to be_an GeoCombine::Metadata
      expect(metadata_object.metadata).to be_an Nokogiri::XML::Document
      expect(metadata_object.metadata.css('Author').count).to eq 2
    end
    it 'reads metadata from parameter if File is not readable' do
      metadata_object = GeoCombine::Metadata.new(simple_xml)
      expect(metadata_object).to be_an GeoCombine::Metadata
      expect(metadata_object.metadata).to be_an Nokogiri::XML::Document
      expect(metadata_object.metadata.css('Author').count).to eq 2
    end
  end
  # GeoCombine subclasses should individually test `to_geoblacklight` and
  # `to_html` methods
end
