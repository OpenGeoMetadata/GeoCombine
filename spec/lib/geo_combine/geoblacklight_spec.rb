require 'spec_helper'

RSpec.describe GeoCombine::Geoblacklight do
  include XmlDocs
  let(:geobl_object){ GeoCombine::Geoblacklight.new(stanford_geobl) }
  describe '#to_json' do
    it 'returns valid json' do
      expect(valid_json?(geobl_object.to_json)).to be_truthy
    end
  end
  describe '#to_hash' do
    it 'returns a hash' do
      expect(geobl_object.to_hash).to be_an Hash
    end
  end
end
