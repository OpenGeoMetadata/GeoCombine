# frozen_string_literal: true

module GeoCombine
  ##
  # Mixin used for formatting metadata fields
  module Formatting
    ##
    # Sanitizes html from a text input
    # @param [String] text
    # @return [String]
    def sanitize(text)
      Sanitize.fragment(text)
    end

    ##
    # Removes line breaks from a text input
    # @param [String] text
    # @return [String]
    def remove_lines(text)
      text.delete("\n")
    end

    ##
    # Sanitizes and removes lines from a text block
    # @param [String] text
    # @return [String]
    def sanitize_and_remove_lines(text)
      remove_lines(sanitize(text))
    end

    # slugs should be lowercase and only have a-z, A-Z, 0-9, and -
    def sluggify(slug)
      slug.gsub(/[^a-zA-Z0-9-]/, '-').gsub(/-+/, '-').downcase
    end
  end
end
