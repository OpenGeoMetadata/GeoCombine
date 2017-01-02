module GeoCombine
  class CkanMetadata
    attr_reader :metadata
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
        dc_identifier_s: @metadata['id'],
        dc_title_s: @metadata['title'],
        dc_rights_s: 'Public',
        dct_provenance_s: @metadata['organization']['title'],
        layer_slug_s: @metadata['name'],
        solr_geom: envelope,
        dc_subject_sm: subjects
      }
    end

    def envelope
      "ENVELOPE(#{extras('bbox-west-long')}, #{extras('bbox-east-long')}, #{extras('bbox-north-lat')}, #{extras('bbox-south-lat')})"
    end

    def subjects
      extras('tags').split(',').map(&:strip)
    end

    def extras(key)
      @metadata['extras'].select { |h| h['key'] == key }[0]['value']
    end
  end
end
