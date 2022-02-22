# frozen_string_literal: true

module GeoCombine
  module Migrators
    # migrates the v1 schema to the aardvark schema
    class V1AardvarkMigrator
      attr_reader :v1_hash

      # @param v1_hash [Hash] parsed json in the v1 schema
      def initialize(v1_hash:)
        @v1_hash = v1_hash
      end

      def run
        v1_hash
      end
    end
  end
end
