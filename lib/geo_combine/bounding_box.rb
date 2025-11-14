# frozen_string_literal: true

module GeoCombine
  class BoundingBox
    attr_reader :west, :south, :east, :north

    ##
    # @param [String, Integer, Float] west
    # @param [String, Integer, Float] south
    # @param [String, Integer, Float] east
    # @param [String, Integer, Float] north
    def initialize(west:, south:, east:, north:)
      @west = west.to_f
      @south = south.to_f
      @east = east.to_f
      @north = north.to_f
    end

    ##
    # Returns a bounding box in ENVELOPE syntax
    # @return [String]
    def to_envelope
      "ENVELOPE(#{west}, #{east}, #{north}, #{south})"
    end

    def valid?
      [south, north].map do |coord|
        next if (-90..90).cover?(coord)

        raise GeoCombine::Exceptions::InvalidGeometry,
              "#{coord} should be in range -90 90"
      end
      [east, west].map do |coord|
        next if (-180..180).cover?(coord)

        raise GeoCombine::Exceptions::InvalidGeometry,
              "#{coord} should be in range -180 180"
      end
      if west > east
        raise GeoCombine::Exceptions::InvalidGeometry,
              "east #{east} should be greater than or equal to west #{west}"
      end
      if south > north
        raise GeoCombine::Exceptions::InvalidGeometry,
              "north #{north} should be greater than or equal to south #{south}"
      end
      true
    end

    def self.from_envelope(envelope)
      envelope = envelope[/.*ENVELOPE\(([^)]*)/, 1].split(',')
      new(
        west: envelope[0],
        south: envelope[3],
        east: envelope[1],
        north: envelope[2]
      )
    end

    ##
    # @param [String] spatial w,s,e,n or w s e n
    # @param [String] delimiter "," or " "
    def self.from_string_delimiter(spatial, delimiter: ',')
      spatial = spatial.split(delimiter)
      new(
        west: spatial[0],
        south: spatial[1],
        east: spatial[2],
        north: spatial[3]
      )
    end
  end
end
