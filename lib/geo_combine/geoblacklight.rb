module GeoCombine
  class Geoblacklight < Metadata

    ##
    # Returns a string of JSON from a GeoBlacklight hash
    # @return (String)
    def to_json
      to_hash.to_json
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
        hash[key] = value.count > 1 ? { key => value } : { key => value[0] }
      end
      hash
    end
  end
end
