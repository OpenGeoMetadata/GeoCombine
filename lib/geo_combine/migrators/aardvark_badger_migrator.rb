# frozen_string_literal: true

require 'active_support'
require 'json/ld'

module GeoCombine
  module Migrators
    # migrates the Aardvark schema to the Badger schema
    class AardvarkBadgerMigrator
      # Ontologies used in the Badger schema
      OGM = RDF::Vocabulary.new('https://opengeometadata.org/ns/badger#')
      DCT = RDF::Vocabulary.new('http://purl.org/dc/terms/')
      DCAT = RDF::Vocabulary.new('http://www.w3.org/ns/dcat#')
      LOCN = RDF::Vocabulary.new('http://www.w3.org/ns/locn#')
      PCDM = RDF::Vocabulary.new('http://pcdm.org/models#')
      SCHEMA = RDF::Vocabulary.new('https://schema.org/')
      GSP = RDF::Vocabulary.new('http://www.opengis.net/ont/geosparql#')
      XSD = RDF::Vocabulary.new('http://www.w3.org/2001/XMLSchema#')

      # Full JSON-LD context
      CONTEXT = {
        '@version' => 1.1,
        'ogm' => OGM.to_uri.to_s,
        'dct' => DCT.to_uri.to_s,
        'dcat' => DCAT.to_uri.to_s,
        'locn' => LOCN.to_uri.to_s,
        'pcdm' => PCDM.to_uri.to_s,
        'schema' => SCHEMA.to_uri.to_s,
        'gsp' => GSP.to_uri.to_s,
        'xsd' => XSD.to_uri.to_s,
        'title' => 'dct:title',
        'description' => 'dct:description',
        'language' => 'dct:language',
        'creator' => 'dct:creator',
        'publisher' => 'dct:publisher',
        'subject' => 'dct:subject',
        'spatial' => 'dct:spatial',
        'source' => 'dct:source',
        'accessRights' => 'dct:accessRights',
        'identifier' => 'dct:identifier',
        'wxsIdentifier' => 'ogm:wxsIdentifier',
        'indexYear' => {
          '@id' => 'ogm:indexYear',
          '@container' => '@set'
        },
        'mdModified' => {
          '@id' => 'ogm:mdModified',
          '@type' => XSD.dateTime.to_s
        },
        'mdVersion' => 'ogm:mdVersion',
        'suppressed' => {
          '@id' => 'ogm:suppressed',
          '@type' => XSD.boolean.to_s
        },
        'resourceClass' => 'ogm:resourceClass',
        'resourceType' => 'ogm:resourceType',
        'provider' => 'schema:provider',
        'geometry' => 'locn:geometry',
        'bbox' => 'dcat:bbox'
      }.freeze

      # Fields that convert directly to RDF literals in Badger
      STRING_FIELD_MAP = {
        'dct_title_s' => DCT.title,
        'dct_description_sm' => DCT.description,
        'dct_creator_sm' => DCT.creator,
        'dct_publisher_sm' => DCT.publisher,
        'dct_subject_sm' => DCT.subject,
        'dct_spatial_sm' => DCT.spatial,
        'dct_source_sm' => DCT.source,
        'dct_accessRights_s' => DCT.accessRights,
        'dct_identifier_sm' => DCT.identifier,
        'gbl_wxsIdentifier_s' => OGM.wxsIdentifier,
        # 'gbl_indexYear_im' => OGM.indexYear,
        # 'gbl_mdModified_dt' => OGM.mdModified,
        # 'gbl_suppressed_b' => OGM.suppressed,
        'gbl_resourceClass_sm' => OGM.resourceClass,
        'gbl_resourceType_sm' => OGM.resourceType,
        'schema_provider_s' => SCHEMA.provider
        # 'locn_geometry' => LOCN.geometry,
        # 'dcat_bbox' => DCAT.bbox
      }.freeze

      attr_reader :aardvark_hash, :subject

      # @param aardvark_hash [Hash] parsed json in the Aardvark schema
      def initialize(aardvark_hash:)
        @aardvark_hash = aardvark_hash
        @subject = RDF::URI(@aardvark_hash['id'])
      end

      def run
        # Return unchanged if already in the Badger schema
        return aardvark_hash if aardvark_hash['mdVersion'] == 'Badger'

        # Create the structure that will hold the converted record
        @badger_graph = RDF::Graph.new

        # Convert the record
        convert_string_fields
        convert_ogm_fields
        convert_languages

        # Return the converted record as JSON-LD
        JSON::LD::API.compact(JSON::LD::API.fromRdf(@badger_graph, useNativeTypes: true), CONTEXT, expanded: true)
      end

      def convert_string_fields
        STRING_FIELD_MAP.each do |aardvark_key, badger_key|
          next unless aardvark_hash.key?(aardvark_key)

          Array(aardvark_hash[aardvark_key]).each do |value|
            @badger_graph << [subject, RDF::URI(badger_key), RDF::Literal(value)]
          end
        end
      end

      # Convert index year, modified date, and set mdVersion to Badger
      def convert_ogm_fields
        Array(aardvark_hash['gbl_indexYear_im']).each { |year| @badger_graph << [subject, OGM.indexYear, RDF::Literal(year.to_i)] }
        @badger_graph << [subject, OGM.mdModified, RDF::Literal(Time.parse(aardvark_hash['gbl_mdModified_dt']))]
        @badger_graph << [subject, OGM.mdVersion, RDF::Literal('Badger')]
      end

      # Recognize ISO 639-3 language codes and convert them to the appropriate datatype
      def convert_languages
        Array(aardvark_hash['dct_language_sm']).each do |language|
          @badger_graph << [subject, DCT.language, RDF::Literal(language, datatype: DCT['ISO639-3'])] if language.match?(/^[a-z]{3}$/)
        end
      end
    end
  end
end
