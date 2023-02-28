# frozen_string_literal: true

module GeoCombine
  module Migrators
    # TODO: WARNING! This class is not fully implemented and should not be used in
    # production. See https://github.com/OpenGeoMetadata/GeoCombine/issues/121
    # for remaining work.
    #
    # migrates the v1 schema to the aardvark schema
    class V1AardvarkMigrator
      attr_reader :v1_hash

      # @param v1_hash [Hash] parsed json in the v1 schema
      def initialize(v1_hash:)
        @v1_hash = v1_hash
      end

      def run
        v2_hash = convert_keys
        v2_hash['gbl_mdVersion_s'] = 'Aardvark'
        v2_hash
      end

      def convert_keys
        v1_hash.transform_keys do |k|
          SCHEMA_FIELD_MAP[k] || k
        end
      end

      SCHEMA_FIELD_MAP = {
        'dc_title_s' => 'dct_title_s', # new namespace
        'dc_description_s' => 'dct_description_sm', # new namespace; single to multi-valued
        'dc_language_s' => 'dct_language_sm', # new namespace; single to multi-valued
        'dc_language_sm' => 'dct_language_sm', # new namespace; single to multi-valued
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
    end
  end
end
