# frozen_string_literal: true

require 'open-uri'

module GeoCombine
  class GeoblacklightAardvark
    attr_reader :metadata

    SCHEMA_VERSION = 'Aardvark'
    SCHEMA_JSON_URL = 'https://raw.githubusercontent.com/OpenGeoMetadata/opengeometadata.github.io/main/docs/schema/geoblacklight-schema-aardvark.json'
    SCHEMA_DRAFT_URL = 'http://json-schema.org/draft-04/schema#'

    ##
    # @param [String] metadata a JSON string document in the Aardvark schema
    # @param [Hash] fields values merged with the parsed document, used for
    # fields Aardvark defines but the source metadata cannot supply
    def initialize(metadata, fields = {})
      @metadata = JSON.parse(metadata).merge(fields)
    end

    ##
    # Returns a string of JSON from an Aardvark hash
    # @return [String]
    def to_json(options = {})
      metadata.to_json(options)
    end

    ##
    # True if the document is a valid Aardvark record
    # @return [Boolean]
    def valid?
      validate!
      true
    rescue StandardError
      false
    end

    ##
    # Validates an Aardvark json document
    def validate!
      JSON::Validator.validate!(schema, to_json)
      validate_version!
      validate_spatial!
    end

    ##
    # Validate gbl_mdVersion_s
    def validate_version!
      return if metadata['gbl_mdVersion_s'] == SCHEMA_VERSION

      raise GeoCombine::Exceptions::InvalidSchemaVersion,
            "gbl_mdVersion_s must be #{SCHEMA_VERSION.inspect}, got #{metadata['gbl_mdVersion_s'].inspect}"
    end

    ##
    # Validate locn_geometry
    def validate_spatial!
      geometry = metadata['locn_geometry']
      return unless geometry =~ /ENVELOPE\(/

      raise GeoCombine::Exceptions::InvalidGeometry unless GeoCombine::BoundingBox.from_envelope(geometry).valid?
    end

    private

    def schema
      @schema ||= JSON.parse(URI.open(SCHEMA_JSON_URL).read).merge('$schema' => SCHEMA_DRAFT_URL)
    end
  end
end
