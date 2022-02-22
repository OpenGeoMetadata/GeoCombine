# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'json-schema'
require 'sanitize'

module GeoCombine
  ##
  # TODO: Create a parse method that can interpret the type of metadata being
  # passed in.
  #
  # def self.parse metadata
  # end

  ##
  # Abstract class for GeoCombine objects
  class Metadata
    attr_reader :metadata

    ##
    # Creates a new GeoCombine::Metadata object, where metadata parameter is can
    # be a File path or String of XML
    # @param [String] metadata can be a File path
    # "./tmp/edu.stanford.purl/bb/338/jh/0716/iso19139.xml" or a String of XML
    # metadata
    def initialize(metadata)
      metadata = File.read metadata if File.readable? metadata
      metadata = Nokogiri::XML(metadata) if metadata.instance_of? String
      @metadata = metadata
    end

    ##
    # Perform an XSLT tranformation on metadata using an object's XSL
    # @return fields additional GeoBlacklight fields to be passed to
    # GeoCombine::Geoblacklight on its instantiation
    # @return [GeoCombine::Geoblacklight] the data transformed into
    # geoblacklight schema, returned as a GeoCombine::Geoblacklight
    def to_geoblacklight(fields = {})
      GeoCombine::Geoblacklight.new(xsl_geoblacklight.apply_to(@metadata), fields)
    end

    ##
    # Perform an XSLT transformation to HTML using an object's XSL
    # @return [String] the xml transformed to an HTML String
    def to_html
      xsl_html.transform(@metadata).to_html
    end
  end
end

# Require custom exceptions
require 'geo_combine/exceptions'

# Require translation mixins
require 'geo_combine/formats'
require 'geo_combine/subjects'
require 'geo_combine/geometry_types'

# Require helper mixins
require 'geo_combine/formatting'
require 'geo_combine/bounding_box'

# Require additional classes
require 'geo_combine/fgdc'
require 'geo_combine/geoblacklight'
require 'geo_combine/iso19139'
require 'geo_combine/esri_open_data'
require 'geo_combine/ckan_metadata'
require 'geo_combine/ogp'

# Require harvesting/indexing files
require 'geo_combine/geo_blacklight_harvester'

# Migrators
require 'geo_combine/migrators/v1_aardvark_migrator'

# Require gem files
require 'geo_combine/version'
require 'geo_combine/railtie' if defined?(Rails)
