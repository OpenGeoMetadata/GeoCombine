# frozen_string_literal: true

module GeoCombine
  module Migrators
    # migrates the v1 schema to the aardvark schema
    class V1AardvarkMigrator
      attr_reader :v1_hash

      # @param v1_hash [Hash] parsed json in the v1 schema
      # @param collection_id_map [Hash] a hash mapping collection names to ids for converting dct_isPartOf_sm
      def initialize(v1_hash:, collection_id_map: {})
        @v1_hash = v1_hash
        @v2_hash = v1_hash
        @collection_id_map = collection_id_map
      end

      def run
        # Return unchanged if already in the aardvark schema
        return @v2_hash if @v2_hash['gbl_mdVersion_s'] == 'Aardvark'

        # Convert the record
        convert_keys
        convert_single_to_multi_valued_fields
        convert_non_crosswalked_fields
        remove_deprecated_fields

        # Mark the record as converted and return it
        @v2_hash['gbl_mdVersion_s'] = 'Aardvark'
        @v2_hash
      end

      # Namespace and URI changes to fields
      def convert_keys
        @v2_hash.transform_keys! do |k|
          SCHEMA_FIELD_MAP[k] || k
        end
      end

      # Fields that need to be converted from single to multi-valued
      def convert_single_to_multi_valued_fields
        @v2_hash = @v2_hash.each_with_object({}) do |(k, v), h|
          h[k] = if !v.is_a?(Array) && k.match?(/.*_[s|i]m/)
                   [v]
                 else
                   v
                 end
        end
      end

      # Convert non-crosswalked fields via lookup tables
      def convert_non_crosswalked_fields
        # Keys may or may not include whitespace, so we normalize them.
        # Resource class is required so we default to "Other"; resource type is not required.
        @v2_hash['gbl_resourceClass_s'] = RESOURCE_CLASS_MAP[@v1_hash['dc_type_s'].gsub(/\s+/, '')] || ['Other']
        resource_type = RESOURCE_TYPE_MAP[@v1_hash['layer_geom_type_s'].gsub(/\s+/, '')]
        @v2_hash['gbl_resourceType_s'] = resource_type unless resource_type.nil?

        # If the user specified a collection id map, use it to convert the collection names to ids
        is_part_of = @v1_hash['dct_isPartOf_sm']&.map { |name| @collection_id_map[name] }&.compact
        if is_part_of.empty?
          @v2_hash.delete('dct_isPartOf_sm')
        else
          @v2_hash['dct_isPartOf_sm'] = is_part_of
        end
      end

      # Remove fields that are no longer used
      def remove_deprecated_fields
        @v2_hash = @v2_hash.except(*SCHEMA_FIELD_MAP.keys, 'dc_type_s', 'layer_geom_type_s')
      end

      SCHEMA_FIELD_MAP = {
        'dc_title_s' => 'dct_title_s', # new namespace
        'dc_description_s' => 'dct_description_sm', # new namespace; single to multi-valued
        'dc_language_s' => 'dct_language_sm', # new namespace; single to multi-valued
        'dc_language_sm' => 'dct_language_sm', # new namespace
        'dc_creator_sm' => 'dct_creator_sm', # new namespace
        'dc_publisher_s' => 'dct_publisher_sm', # new namespace; single to multi-valued
        'dct_provenance_s' => 'schema_provider_s', # new URI name
        'dc_subject_sm' => 'dct_subject_sm', # new namespace
        'solr_year_i' => 'gbl_indexYear_im', # new URI name; single to multi-valued
        'dc_source_sm' => 'dct_source_sm', # new namespace
        'dc_rights_s' => 'dct_accessRights_s', # new URI name
        'dc_format_s' => 'dct_format_s', # new namespace
        'layer_id_s' => 'gbl_wxsIdentifier_s', # new URI name
        'layer_slug_s' => 'id', # new URI name
        'dc_identifier_s' => 'dct_identifier_sm', # new namespace; single to multi-valued
        'layer_modified_dt' => 'gbl_mdModified_dt', # new URI name
        'geoblacklight_version' => 'gbl_mdVersion_s', # new URI name
        'suppressed_b' => 'gbl_suppressed_b' # new namespace
      }.freeze

      # Map Dublin Core types to Aardvark resource class sets
      # See: https://github.com/OpenGeoMetadata/opengeometadata.github.io/blob/main/docs/ogm-aardvark/resource-class.md
      RESOURCE_CLASS_MAP = {
        'Collection' => ['Collections'],
        'Dataset' => ['Datasets'],
        'Image' => ['Imagery'],
        'InteractiveResource' => ['Websites'],
        'PhysicalObject' => ['Maps'],
        'Service' => ['Web services'],
        'StillImage' => ['Imagery']
      }.freeze

      # Map geometry types to Aardvark resource type sets
      # See: https://github.com/OpenGeoMetadata/opengeometadata.github.io/blob/main/docs/ogm-aardvark/resource-type.md
      RESOURCE_TYPE_MAP = {
        'Point' => ['Point data'],
        'Line' => ['Line data'],
        'Polygon' => ['Polygon data'],
        'Raster' => ['Raster data'],
        'ScannedMap' => ['Raster data'],
        'Image' => ['Raster data']
      }.freeze
    end
  end
end
