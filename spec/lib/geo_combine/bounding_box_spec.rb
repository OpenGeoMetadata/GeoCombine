# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::BoundingBox do
  subject(:valid) do
    described_class.new(west: -180, east: 180, north: 90, south: -90)
  end

  describe '#to_envelope' do
    it 'returns a valid envelope syntax' do
      expect(valid.to_envelope).to eq 'ENVELOPE(-180.0, 180.0, 90.0, -90.0)'
    end
  end

  describe '#valid?' do
    context 'when valid' do
      it { expect(valid.valid?).to be true }
    end

    context 'when south > north' do
      subject(:invalid) do
        described_class.new(west: -180, east: 180, north: 33, south: 34)
      end

      it { expect { invalid.valid? }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end

    context 'when west > east' do
      subject(:invalid) do
        described_class.new(west: 10, east: -20, north: 90, south: -90)
      end

      it { expect { invalid.valid? }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end

    context 'when west out of range' do
      subject(:invalid) do
        described_class.new(west: -181, east: 180, north: 90, south: -90)
      end

      it { expect { invalid.valid? }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end

    context 'when east out of range' do
      subject(:invalid) do
        described_class.new(west: -180, east: 181, north: 90, south: -90)
      end

      it { expect { invalid.valid? }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end

    context 'when north out of range' do
      subject(:invalid) do
        described_class.new(west: -180, east: 180, north: 91, south: -90)
      end

      it { expect { invalid.valid? }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end

    context 'when south out of range' do
      subject(:invalid) do
        described_class.new(west: -180, east: 180, north: 90, south: -91)
      end

      it { expect { invalid.valid? }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end
  end

  describe '.from_envelope' do
    it { expect(described_class.from_envelope(valid.to_envelope).to_envelope).to eq valid.to_envelope }
  end

  describe '.from_string_delimiter' do
    it { expect(described_class.from_string_delimiter('-180, -90, 180, 90').to_envelope).to eq valid.to_envelope }
  end
end
