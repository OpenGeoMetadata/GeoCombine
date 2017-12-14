require 'open-uri'

module GeoCombine
  class Geoblacklight
    include GeoCombine::Formats
    include GeoCombine::Subjects
    include GeoCombine::GeometryTypes

    attr_reader :metadata

    GEOBLACKLIGHT_VERSION = 'v1.1.0'

    ##
    # Initializes a GeoBlacklight object
    # @param [String] metadata be a valid JSON string document in
    # GeoBlacklight-Schema
    # @param [Hash] fields enhancements to metadata that are merged with @metadata
    def initialize(metadata, fields = {})
      @metadata = JSON.parse(metadata).merge(fields)
      @schema = nil
    end

    ##
    # Calls metadata enhancement methods for each key, value pair in the
    # metadata hash
    def enhance_metadata
      @metadata.each do |key, value|
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
    def to_json(_options = {})
      JSON.pretty_generate(@metadata)
    end

    ##
    # Validates a GeoBlacklight-Schema json document
    # @return [Boolean]
    def valid?
      @schema ||= JSON.parse(open("https://raw.githubusercontent.com/geoblacklight/geoblacklight/#{GEOBLACKLIGHT_VERSION}/schema/geoblacklight-schema.json").read)
      JSON::Validator.validate!(@schema, to_json, fragment: '#/properties/layer') &&
        dct_references_validate! &&
        spatial_validate!
    end

    ##
    # Validate dct_references_s
    # @return [Boolean]
    def dct_references_validate!
      return true unless metadata.key?('dct_references_s')
      begin
        ref = JSON.parse(metadata['dct_references_s'])
        raise GeoCombine::Exceptions::InvalidDCTReferences, 'dct_references must be parsed to a Hash' unless ref.is_a?(Hash)
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
      @metadata[key] = formats[value] if key == 'dc_format_s' && formats.include?(value)
    end

    ##
    # Enhances the 'layer_geom_type_s' field by translating from known types
    def translate_geometry_type(key, value)
      @metadata[key] = geometry_types[value] if key == 'layer_geom_type_s' && geometry_types.include?(value)
    end

    ##
    # Enhances the 'dc_subject_sm' field by translating subjects to ISO topic
    # categories
    def enhance_subjects(key, value)
      @metadata[key] = value.map do |val|
        if subjects.include?(val)
          subjects[val]
        else
          val
        end
      end if key == 'dc_subject_sm'
    end

    ##
    # Formats the 'layer_modified_dt' to a valid valid RFC3339 date/time string
    # and ISO8601 (for indexing into Solr)
    def format_proper_date(key, value)
      @metadata[key] = Time.parse(value).utc.iso8601 if key == 'layer_modified_dt'
    end

    def fields_should_be_array(key, value)
      @metadata[key] = [value] if should_be_array.include?(key) && !value.kind_of?(Array)
    end

    ##
    # GeoBlacklight-Schema fields that should be type Array
    def should_be_array
      ['dc_creator_sm', 'dc_subject_sm', 'dct_spatial_sm', 'dct_temporal_sm', 'dct_isPartOf_sm']
    end
  end
end
