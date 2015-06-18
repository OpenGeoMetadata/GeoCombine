require 'spec_helper'

RSpec.describe GeoCombine::Formatting do
  let(:dirty) { "<p>paragraph</p> \n on a new line" }
  subject { Object.new.extend(GeoCombine::Formatting) }
  describe '#sanitize' do
    it 'sanitizes a fragment' do
      expect(subject.sanitize(dirty)).to_not match('<p>')
    end
  end
  describe '#remove_lines' do
    it 'removes new lines' do
      expect(subject.remove_lines(dirty)).to_not match(/\n/)
    end
  end
  describe '#sanitize_and_remove_lines' do
    it 'returns a corrected string' do
      expect(subject.sanitize_and_remove_lines(dirty)).to_not match('<p>')
      expect(subject.sanitize_and_remove_lines(dirty)).to_not match(/\n/)
    end
  end
end
