# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'cgi'

module GeoCombine
  # Data model for OpenGeoPortal metadata
  class OGP
    class InvalidMetadata < RuntimeError; end
    include GeoCombine::Formatting
    attr_reader :metadata

    ##
    # Initializes an OGP object for parsing
    # @param [String] metadata a valid serialized JSON string from OGP instance
    # @raise [InvalidMetadata]
    def initialize(metadata)
      @metadata = JSON.parse(metadata)
      raise InvalidMetadata unless valid?
    end

    OGP_REQUIRED_FIELDS = %w[
      Access
      Institution
      LayerDisplayName
      LayerId
      MaxX
      MaxY
      MinX
      MinY
      Name
    ].freeze

    ##
    # Runs validity checks on OGP metadata to ensure fields are present
    def valid?
      OGP_REQUIRED_FIELDS.all? { |k| metadata[k].present? }
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
        dc_identifier_s: identifier,
        layer_slug_s: slug,
        dc_title_s: metadata['LayerDisplayName'],
        solr_geom: envelope,
        dct_provenance_s: institution,
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
      }.compact
    end

    def date
      DateTime.rfc3339(metadata['ContentDate'])
    rescue StandardError
      nil
    end

    def year
      date&.year
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
        'GeoTIFF'
      when 'Polygon', 'Point', 'Line'
        'Shapefile'
      else
        raise ArgumentError, metadata['DataType']
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
      raise ArgumentError unless west >= -180 && west <= 180 &&
                                 east >= -180 && east <= 180 &&
                                 north >= -90 && north <= 90 &&
                                 south >= -90 && south <= 90 &&
                                 west <= east && south <= north

      "ENVELOPE(#{west}, #{east}, #{north}, #{south})"
    end

    def subjects
      fgdc.metadata.xpath('//themekey').map(&:text) if fgdc
    end

    def placenames
      fgdc.metadata.xpath('//placekey').map(&:text) if fgdc
    end

    def fgdc
      GeoCombine::Fgdc.new(metadata['FgdcText']) if metadata['FgdcText']
    end

    private

    ##
    # Builds references used for dct_references
    # @return [Hash]
    def references_hash
      results = {
        'http://www.opengis.net/def/serviceType/ogc/wfs' => location['wfs'],
        'http://www.opengis.net/def/serviceType/ogc/wms' => location['wms'],
        'http://schema.org/url' => location['url'],
        download_uri => location['download']
      }

      # Handle null, "", and [""]
      results.map { |k, v| { k => ([] << v).flatten.first } if v }
             .flatten
             .compact
             .reduce({}, :merge)
    end

    def download_uri
      return 'http://schema.org/DownloadAction' if institution == 'Harvard'

      'http://schema.org/downloadUrl'
    end

    ##
    # OGP "Location" field parsed
    def location
      JSON.parse(metadata['Location'])
    end

    def north
      metadata['MaxY'].to_f
    end

    def south
      metadata['MinY'].to_f
    end

    def east
      metadata['MaxX'].to_f
    end

    def west
      metadata['MinX'].to_f
    end

    def institution
      metadata['Institution']
    end

    def identifier
      CGI.escape(metadata['LayerId']) # TODO: why are we using CGI.escape?
    end

    def slug
      name = metadata['LayerId'] || metadata['Name'] || ''
      name = [institution, name].join('-') if institution.present? &&
                                              !name.downcase.start_with?(institution.downcase)
      sluggify(filter_name(name))
    end

    SLUG_STRIP_VALUES = %w[
      SDE_DATA.
      SDE.
      SDE2.
      GISPORTAL.GISOWNER01.
      GISDATA.
      MORIS.
    ].freeze

    def filter_name(name)
      # strip out schema and usernames
      SLUG_STRIP_VALUES.each do |strip_val|
        name.sub!(strip_val, '')
      end
      unless name.size > 1
        # use first word of title is empty name
        name = metadata['LayerDisplayName'].split.first
      end
      name
    end
  end
end
