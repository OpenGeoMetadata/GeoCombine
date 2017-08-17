module GeoCombine
  # Data model for ESRI's open data portal metadata
  class OGP
    include GeoCombine::Formatting
    attr_reader :metadata

    ##
    # Initializes an OGP object for parsing
    # @param [String] metadata a valid serialized JSON string from an ESRI Open
    # Data portal
    def initialize(metadata)
      @metadata = JSON.parse(metadata)
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
        # Required fields
        dc_identifier_s: URI.encode(metadata['LayerId']),
        layer_slug_s: sluggify(metadata['LayerId']),
        dc_title_s: metadata['LayerDisplayName'],
        solr_geom: envelope,
        dct_provenance_s: metadata['Institution'],
        dc_rights_s: metadata['Access'],
        geoblacklight_version: '1.0',

        # Recommended fields
        dc_description_s: metadata['Abstract'],
        layer_geom_type_s: ogp_geom,
        dct_references_s: references,
        layer_id_s: "#{metadata['WorkspaceName']}:#{metadata['Name']}",

        # Optional
        dct_temporal_sm: [metadata['ContentDate']],
        dc_format_s: ogp_formats,
        # dct_issued_dt
        # dc_language_s
        dct_spatial_sm: placenames,
        solr_year_i: year,
        dc_publisher_s: metadata['Publisher'],
        dc_subject_sm: subjects,
        dc_type_s: 'Dataset'
      }.delete_if { |_k, v| v.nil? }
    end

    def date
      begin
        DateTime.rfc3339(metadata['ContentDate'])
      rescue
        nil
      end
    end

    def year
      date.year unless date.nil?
    end

    ##
    # Convert "Paper Map" to Raster, assumes all OGP "Paper Maps" have WMS
    def ogp_geom
      case metadata['DataType']
      when 'Paper Map'
        'Raster'
      else
        metadata['DataType']
      end
    end

    ##
    # OGP doesn't ship format types, so we just try and be clever here.
    def ogp_formats
      case metadata['DataType']
      when 'Paper Map', 'Raster'
        return 'GeoTIFF'
      when 'Polygon', 'Point', 'Line'
        return 'Shapefile'
      else
        ''
      end
    end

    ##
    # Converts references to json
    # @return [String]
    def references
      references_hash.to_json
    end

    ##
    # Builds a Solr Envelope using CQL syntax
    # @return [String]
    def envelope
      "ENVELOPE(#{west}, #{east}, #{north}, #{south})"
    end

    def subjects
      fgdc.metadata.xpath('//themekey').map { |k| k.text }
    end

    def placenames
      fgdc.metadata.xpath('//placekey').map { |k| k.text }
    end

    def fgdc
      GeoCombine::Fgdc.new(metadata['FgdcText'])
    end

    private

    ##
    # Builds references used for dct_references
    # @return [Hash]
    def references_hash
      {
        'http://www.opengis.net/def/serviceType/ogc/wfs' => location['wfs'],
        'http://www.opengis.net/def/serviceType/ogc/wms' => location['wms'],
        'http://schema.org/DownloadAction' => location['download']
        # Handle null, "", and [""]
      }.map { |k, v| { k => ([] << v).flatten.first } if v }
        .flatten.compact.reduce({}, :merge)
    end

    ##
    # OGP "Location" field parsed
    def location
      JSON.parse(metadata['Location'])
    end

    def north
      @metadata['MaxY']
    end

    def south
      @metadata['MinY']
    end

    def east
      @metadata['MaxX']
    end

    def west
      @metadata['MinX']
    end
  end
end
