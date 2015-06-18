module GeoCombine
  # Data model for ESRI's open data portal metadata
  class EsriOpenData
    include GeoCombine::Formatting
    attr_reader :metadata

    ##
    # Initializes an EsriOpenData object for parsing
    # @param [String] metadata a valid serialized JSON string from an ESRI Open
    # Data portal
    def initialize(metadata)
      @metadata = JSON.parse(metadata)
      @geometry = @metadata['extent']['coordinates']
    end

    ##
    # Creates and returns a Geoblacklight schema object from this metadata
    # @return [GeoCombine::Geoblacklight]
    def to_geoblacklight
      GeoCombine::Geoblacklight.new(geoblacklight_terms.to_json)
    end

    ##
    # Builds a Geoblacklight Schema type hash from Esri Open Data portal
    # metadata
    # @return [Hash]
    def geoblacklight_terms
      {
        uuid: @metadata['id'],
        dc_identifier_s: @metadata['id'],
        dc_title_s: @metadata['name'],
        dc_description_s: sanitize_and_remove_lines(@metadata['description']),
        dc_rights_s: 'Public',
        dct_provenance_s: @metadata['owner'],
        dct_references_s: references,
        georss_box_s: georss_box,
        # layer_id_s is used for describing a layer id for a web serivce (WMS, WFS) but is still a required field
        layer_id_s: '',
        layer_geom_type_s: @metadata['geometry_type'],
        layer_modified_dt: @metadata['updated_at'],
        layer_slug_s: @metadata['id'],
        solr_geom: envelope,
        # solr_year_i: '', No equivalent in Esri Open Data metadata
        dc_subject_sm: @metadata['tags']
      }
    end

    ##
    # Converts references to json
    # @return [String]
    def references
      references_hash.to_json
    end

    ##
    # Builds references used for dct_references
    # @return [Hash]
    def references_hash
      {
        'http://schema.org/url' => @metadata['arcgis_online_item_url'],
        'http://resources.arcgis.com/en/help/arcgis-rest-api' => @metadata['url']
      }
    end

    ##
    # Builds a GeoRSS box
    # @return [String]
    def georss_box
      "#{south} #{west} #{north} #{east}"
    end

    ##
    # Builds a Solr Envelope using CQL syntax
    # @return [String]
    def envelope
      "ENVELOPE(#{west}, #{east}, #{north}, #{south})"
    end

    private

    def north
      @geometry[1][1]
    end

    def south
      @geometry[0][1]
    end

    def east
      @geometry[1][0]
    end

    def west
      @geometry[0][0]
    end
  end
end
