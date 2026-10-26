# frozen_string_literal: true

require 'geo_combine/schema'
require 'spec_helper'

RSpec.describe GeoCombine::Schema do
  describe '.version' do
    it 'reads the version of an Aardvark record' do
      expect(described_class.version('gbl_mdVersion_s' => 'Aardvark')).to eq 'Aardvark'
    end

    it 'reads the version of a 1.0 record' do
      expect(described_class.version('geoblacklight_version' => '1.0')).to eq '1.0'
    end

    it 'is nil for a record that declares no version' do
      expect(described_class.version('id' => 'no-version')).to be_nil
    end
  end

  describe '.id' do
    it 'uses id for an Aardvark record' do
      record = { 'gbl_mdVersion_s' => 'Aardvark', 'id' => 'stanford-bb058zh0946', 'layer_slug_s' => 'other' }
      expect(described_class.id(record)).to eq 'stanford-bb058zh0946'
    end

    it 'uses layer_slug_s for a 1.0 record' do
      record = { 'geoblacklight_version' => '1.0', 'layer_slug_s' => 'stanford-bb058zh0946', 'dc_identifier_s' => 'other' }
      expect(described_class.id(record)).to eq 'stanford-bb058zh0946'
    end

    it 'falls back to id, then layer_slug_s, for a record that declares no version' do
      expect(described_class.id('id' => 'a', 'layer_slug_s' => 'b')).to eq 'a'
      expect(described_class.id('layer_slug_s' => 'b')).to eq 'b'
    end

    it 'never uses other identifier fields' do
      expect(described_class.id('gbl_mdVersion_s' => 'Aardvark', 'dct_identifier_sm' => ['a'], 'dc_identifier_s' => 'b')).to be_nil
    end

    it 'returns the id as Solr receives it, without normalizing it' do
      expect(described_class.id('gbl_mdVersion_s' => 'Aardvark', 'id' => ' Padded:ID/1 ')).to eq ' Padded:ID/1 '
      expect(described_class.id('gbl_mdVersion_s' => 'Aardvark', 'id' => 5)).to eq '5'
    end
  end

  describe '.valid_id?' do
    # The ids in a list that valid_id? accepts
    def valid(ids)
      ids.select { |id| described_class.valid_id?(id) }
    end

    it 'accepts OGM identifiers' do
      ids = %w[stanford-bb058zh0946 ark:/85335/m5bc3v86s 00138f08-1327-4ae1-9b9e-9794140059eb]
      expect(valid(ids)).to eq ids
    end

    it 'rejects anything that is not a non-empty string' do
      expect(valid([nil, 5, ['a'], ''])).to be_empty
    end

    it 'rejects ids that are not valid UTF-8' do
      expect(valid(["a\xC3(".dup.force_encoding('UTF-8')])).to be_empty
    end

    it 'rejects ids with leading or trailing whitespace' do
      expect(valid([' a', 'a ', "a\n", "\u00a0a", "a\u3000"])).to be_empty
    end

    it 'rejects ids with control characters' do
      expect(valid(["a\tb", "a\u0000b", "a\u007fb"])).to be_empty
    end
  end
end
