module GeoCombine
  class Iso19139 < Metadata

    ##
    # Returns a Nokogiri::XSLT object containing the ISO19139 to GeoBlacklight
    # XSL
    # @return (Nokogiri::XSLT)
    def xsl
      Nokogiri::XSLT(File.read('./lib/xslt/iso2geoBL.xsl'))
    end
  end
end
