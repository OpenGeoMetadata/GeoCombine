# frozen_string_literal: true

module GeoCombine
  module Exceptions
    class InvalidDCTReferences < StandardError
    end

    class InvalidGeometry < StandardError
    end

    class InvalidSchemaVersion < StandardError
    end

    # A harvest could not be completed and should not be treated as a success
    class HarvestError < StandardError
    end

    # An individual document could not be found and can be skipped
    class DocumentNotFound < HarvestError
    end
  end
end
