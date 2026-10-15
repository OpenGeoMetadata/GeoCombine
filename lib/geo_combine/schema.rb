# frozen_string_literal: true

module GeoCombine
  # How each GeoBlacklight schema version declares itself and identifies its records
  module Schema
    DEFAULT_VERSION = 'Aardvark'

    # The field each schema version uses as its Solr uniqueKey: GeoBlacklight 4+
    # (Aardvark) uses id, GeoBlacklight 2 and 3 (1.0) use layer_slug_s
    ID_FIELDS = { 'Aardvark' => 'id', '1.0' => 'layer_slug_s' }.freeze

    module_function

    # The schema version a record declares, if any
    def version(record)
      record['gbl_mdVersion_s'] || record['geoblacklight_version']
    end

    # A record's identifier, sent to Solr as the uniqueKey
    def id(record)
      field = ID_FIELDS[version(record)]
      value = field ? record[field] : record['id'] || record['layer_slug_s']
      value&.to_s
    end

    # Whether a string is usable as a delete key. An id with leading or trailing
    # whitespace or with control characters is a bug.
    def valid_id?(id)
      id.is_a?(String) && !id.empty? && id.valid_encoding? && !id.match?(/\A[[:space:]]|[[:space:]]\z|[[:cntrl:]]/)
    end
  end
end
