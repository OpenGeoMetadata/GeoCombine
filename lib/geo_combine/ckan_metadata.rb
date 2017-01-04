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
        layer_geom_type_s: @metadata['type'],
        dct_provenance_s: organization['title'],
        dc_description_s: @metadata['notes'],
        layer_slug_s: @metadata['name'],
        solr_geom: envelope,
        dc_subject_sm: subjects
      }.select { |_k, v| !v.nil? }
    end

    def organization
      @metadata['organization'] || { title: '' }
    end

    def envelope
      bbox = extras('bbox-west-long')
      # If bbox is there, use that
      if !bbox.empty?
        return "ENVELOPE(#{extras('bbox-west-long').strip}, #{extras('bbox-east-long').strip}, #{extras('bbox-north-lat').strip}, #{extras('bbox-south-lat').strip})"
      else
        spatial = extras('spatial')
        # Use spatial if it is there
        unless spatial.empty?
          commasplit = spatial.split(',')
          split = spatial.split(' ')
          # These can be separated by commas or spaces
          split = commasplit if commasplit.length == 4
          if spatial =~ /(-?[0-9]{2,3}),?\s?(-?[0-9]{2,3}),?\s?(-?[0-9]{2,3}),?\s?(-?[0-9]{2,3})/
            return "ENVELOPE(#{split[0]}, #{split[2]}, #{split[3]}, #{split[1]})"
          end
        end
      end
    end

    def subjects
      extras('tags').split(',').map(&:strip)
    end

    def extras(key)
      if @metadata['extras']
        @metadata['extras'].select { |h| h['key'] == key }.collect { |v| v['value'] }[0] || ''
      end
    end
  end
end
