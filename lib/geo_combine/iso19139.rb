module GeoCombine
  class Iso19139 < Metadata

    ##
    # Returns a Nokogiri::XSLT object containing the ISO19139 to GeoBlacklight
    # XSL
    # @return [Nokogiri::XSLT]
    def xsl_geoblacklight
      Nokogiri::XSLT(File.read(File.join(File.dirname(__FILE__), '../xslt/iso2geoBL.xsl')))
    end

    ##
    # Returns a Nokogiri::XSLT object containing the ISO19139 to HTML XSL
    # @return [Nokogiri:XSLT]
    def xsl_html
      Nokogiri::XSLT(File.read(File.join(File.dirname(__FILE__), '../xslt/iso2html.xsl')))
    end
  end
end
