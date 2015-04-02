module GeoCombine
  class Geoblacklight < Metadata

    ##
    # Returns a string of JSON from a GeoBlacklight hash
    # @return (String)
    def to_json
      to_hash.to_json
    end

    ##
    # Validates a GeoBlacklight-Schema json document
    # @return [Boolean]
    def valid?
      schema = JSON.parse(File.read(File.join(File.dirname(__FILE__), '../schema/geoblacklight-schema.json')))
      JSON::Validator.validate!(schema, JSON.parse(to_json), validate_schema: true)
    end

    ##
    # Returns a hash from a GeoBlacklight object
    # @return (Hash)
    def to_hash
      hash = {}
      @metadata.css('field').each do |field|
        (hash[field.attributes['name'].value] ||= []) << field.children.text
      end
      hash.collect do |key, value|
        hash[key] = value.count > 1 ? value : value[0]
      end
      hash
    end
  end
end
