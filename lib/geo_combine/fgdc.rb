# frozen_string_literal: true

module GeoCombine
  ##
  # FIXME: FGDC parsing, transformations are still experimental
  class Fgdc < Metadata
    ##
    # Returns a Nokogiri::XSLT object containing the FGDC to GeoBlacklight XSL
    # @return [Nokogiri::XSLT]
    def xsl_geoblacklight
      Nokogiri::XSLT(File.open(File.join(File.dirname(__FILE__), '../xslt/fgdc2geoBL.xsl')))
    end

    ##
    # Returns a Nokogiri::XSLT object containing the ISO19139 to HTML XSL
    # @return [Nokogiri:XSLT]
    def xsl_html
      Nokogiri::XSLT(File.open(File.join(File.dirname(__FILE__), '../xslt/fgdc2html.xsl')))
    end
  end
end
