# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Formatting do
  subject { Object.new.extend(described_class) }

  let(:dirty) { "<p>paragraph</p> \n on a new line" }

  describe '#sanitize' do
    it 'sanitizes a fragment' do
      expect(subject.sanitize(dirty)).not_to match('<p>')
    end
  end

  describe '#remove_lines' do
    it 'removes new lines' do
      expect(subject.remove_lines(dirty)).not_to match(/\n/)
    end
  end

  describe '#sanitize_and_remove_lines' do
    it 'returns a corrected string' do
      expect(subject.sanitize_and_remove_lines(dirty)).not_to match('<p>')
      expect(subject.sanitize_and_remove_lines(dirty)).not_to match(/\n/)
    end
  end

  describe '#sluggify' do
    let(:preslug) { 'HARVARD...Co_0l' }

    it 'handles multiple . and _ and uppercase' do
      expect(subject.sluggify(preslug)).to eq 'harvard-co-0l'
    end
  end
end
