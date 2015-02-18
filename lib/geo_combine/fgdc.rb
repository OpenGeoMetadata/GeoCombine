module GeoCombine

  ##
  # FIXME: FGDC parsing, transformations are still experimental
  class Fgdc < Metadata

    ##
    # Returns a Nokogiri::XSLT object containing the FGDC to GeoBlacklight XSL
    # @return (Nokogiri::XSLT)
    def xsl
      Nokogiri::XSLT(File.read('./lib/xslt/fgdc2geoBL.xsl'))
    end
  end
end
