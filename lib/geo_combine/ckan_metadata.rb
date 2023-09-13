# frozen_string_literal: true

module GeoCombine
  class CkanMetadata
    MAX_STRING_LENGTH = 32_765 # Solr limit

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
        layer_geom_type_s: 'Not Specified',
        dct_provenance_s: organization['title'],
        dc_description_s: @metadata['notes'].respond_to?(:[]) ? @metadata['notes'][0..MAX_STRING_LENGTH] : nil,
        layer_slug_s: @metadata['name'],
        solr_geom: envelope,
        dc_subject_sm: subjects,
        dct_references_s: external_references.to_json.to_s,
        dc_format_s: downloadable? ? 'ZIP' : nil # TODO: we only allow direct ZIP file downloads
      }.compact
    end

    def organization
      @metadata['organization'] || { title: '' }
    end

    def envelope
      return envelope_from_bbox unless envelope_from_bbox.nil?
      return envelope_from_spatial(',') unless envelope_from_spatial(',').nil?

      envelope_from_spatial(' ') unless envelope_from_spatial(' ').nil?
    end

    def envelope_from_bbox
      bbox = GeoCombine::BoundingBox.new(
        west: extras('bbox-west-long'),
        south: extras('bbox-south-lat'),
        east: extras('bbox-east-long'),
        north: extras('bbox-north-lat')
      )
      begin
        bbox.to_envelope if bbox.valid?
      rescue GeoCombine::Exceptions::InvalidGeometry
        nil
      end
    end

    def envelope_from_spatial(delimiter)
      bbox = GeoCombine::BoundingBox.from_string_delimiter(
        extras('spatial'),
        delimiter: delimiter
      )
      begin
        bbox.to_envelope if bbox.valid?
      rescue GeoCombine::Exceptions::InvalidGeometry
        nil
      end
    end

    def subjects
      extras('tags').split(',').map(&:strip)
    end

    def extras(key)
      if @metadata['extras']
        @metadata['extras'].select { |h| h['key'] == key }.collect { |v| v['value'] }[0] || ''
      else
        ''
      end
    end

    def external_references
      h = {
        'http://schema.org/url' => resource_urls('information').first
      }

      h['http://schema.org/downloadUrl'] = resource_urls('download').first if downloadable?

      h.compact
    end

    def downloadable?
      resource_urls('download').first =~ /.*\.zip/im
    end

    def resources(type)
      return [] if @metadata['resources'].nil?

      @metadata['resources'].select { |resource| resource['resource_locator_function'] == type }
    end

    def resource_urls(type)
      resources(type).collect do |resource|
        resource['url'] if resource.respond_to?(:[])
      end
    end
  end
end
