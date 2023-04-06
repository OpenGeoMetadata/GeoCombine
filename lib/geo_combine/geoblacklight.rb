# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/except'
require 'open-uri'

module GeoCombine
  class Geoblacklight
    include GeoCombine::Formats
    include GeoCombine::Subjects
    include GeoCombine::GeometryTypes

    attr_reader :metadata

    GEOBLACKLIGHT_VERSION = '1.0'
    SCHEMA_JSON_URL = "https://raw.githubusercontent.com/OpenGeoMetadata/opengeometadata.github.io/main/docs/schema/geoblacklight-schema-#{GEOBLACKLIGHT_VERSION}.json"
    DEPRECATED_KEYS_V1 = %w[
      uuid
      georss_polygon_s
      georss_point_s
      georss_box_s
      dc_relation_sm
      solr_issued_i
      solr_bbox
    ].freeze

    ##
    # Initializes a GeoBlacklight object
    # @param [String] metadata be a valid JSON string document in
    # GeoBlacklight-Schema
    # @param [Hash] fields enhancements to metadata that are merged with @metadata
    def initialize(metadata, fields = {})
      @metadata = JSON.parse(metadata).merge(fields)
    end

    ##
    # Calls metadata enhancement methods for each key, value pair in the
    # metadata hash
    def enhance_metadata
      upgrade_to_v1 if metadata['geoblacklight_version'].blank?

      metadata.each do |key, value|
        translate_formats(key, value)
        enhance_subjects(key, value)
        format_proper_date(key, value)
        fields_should_be_array(key, value)
        translate_geometry_type(key, value)
      end
    end

    ##
    # Returns a string of JSON from a GeoBlacklight hash
    # @return (String)
    def to_json(options = {})
      metadata.to_json(options)
    end

    ##
    # Validates a GeoBlacklight-Schema json document
    # @return [Boolean]
    def valid?
      JSON::Validator.validate!(schema, to_json, fragment: '#/definitions/layer') &&
        dct_references_validate! &&
        spatial_validate!
    end

    ##
    # Validate dct_references_s
    # @return [Boolean]
    def dct_references_validate!
      return true unless metadata.key?('dct_references_s') # TODO: shouldn't we require this field?

      begin
        ref = JSON.parse(metadata['dct_references_s'])
        unless ref.is_a?(Hash)
          raise GeoCombine::Exceptions::InvalidDCTReferences,
                'dct_references must be parsed to a Hash'
        end

        true
      rescue JSON::ParserError => e
        raise e, "Invalid JSON in dct_references_s: #{e.message}"
      end
    end

    def spatial_validate!
      GeoCombine::BoundingBox.from_envelope(metadata['solr_geom']).valid?
    end

    private

    ##
    # Enhances the 'dc_format_s' field by translating a format type to a valid
    # GeoBlacklight-Schema format
    def translate_formats(key, value)
      return unless key == 'dc_format_s' && formats.include?(value)

      metadata[key] = formats[value]
    end

    ##
    # Enhances the 'layer_geom_type_s' field by translating from known types
    def translate_geometry_type(key, value)
      return unless key == 'layer_geom_type_s' && geometry_types.include?(value)

      metadata[key] = geometry_types[value]
    end

    ##
    # Enhances the 'dc_subject_sm' field by translating subjects to ISO topic
    # categories
    def enhance_subjects(key, value)
      return unless key == 'dc_subject_sm'

      metadata[key] = value.map do |val|
        if subjects.include?(val)
          subjects[val]
        else
          val
        end
      end
    end

    ##
    # Formats the 'layer_modified_dt' to a valid valid RFC3339 date/time string
    # and ISO8601 (for indexing into Solr)
    def format_proper_date(key, value)
      return unless key == 'layer_modified_dt'

      metadata[key] = Time.parse(value).utc.iso8601
    end

    def fields_should_be_array(key, value)
      return unless should_be_array.include?(key) && !value.is_a?(Array)

      metadata[key] = [value]
    end

    ##
    # GeoBlacklight-Schema fields that should be type Array
    def should_be_array
      %w[
        dc_creator_sm
        dc_subject_sm
        dct_spatial_sm
        dct_temporal_sm
        dct_isPartOf_sm
      ].freeze
    end

    ##
    # Converts a pre-v1.0 schema into a compliant v1.0 schema
    def upgrade_to_v1
      metadata['geoblacklight_version'] = '1.0'

      # ensure required fields
      metadata['dc_identifier_s'] = metadata['uuid'] if metadata['dc_identifier_s'].blank?

      # normalize to alphanum and - only
      metadata['layer_slug_s'].gsub!(/[^[[:alnum:]]]+/, '-') if metadata['layer_slug_s'].present?

      # remove deprecated fields
      metadata.except!(*DEPRECATED_KEYS_V1)

      # ensure we have a proper v1 record
      valid?
    end

    def schema
      @schema ||= JSON.parse(URI.open(SCHEMA_JSON_URL).read)
    end
  end
end
