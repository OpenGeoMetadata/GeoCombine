# frozen_string_literal: true

module XmlDocs
  ##
  # Example XSLT from https://developer.mozilla.org/en-US/docs/XSLT_in_Gecko/Basic_Example
  def simple_xslt
    File.read(File.join(File.dirname(__FILE__), './docs/simple_xslt.xsl'))
  end

  ##
  # Example XML from https://developer.mozilla.org/en-US/docs/XSLT_in_Gecko/Basic_Example
  def simple_xml
    File.read(File.join(File.dirname(__FILE__), './docs/simple_xml.xml'))
  end

  ##
  # Stanford ISO19139 example record from https://github.com/OpenGeoMetadata/edu.stanford.purl/blob/08085d766014ea91e5defb6d172e5633bfd9b1ce/bb/338/jh/0716/iso19139.xml
  def stanford_iso
    File.read(File.join(File.dirname(__FILE__), './docs/stanford_iso.xml'))
  end

  ##
  # Example FGDC XML from https://github.com/OpenGeoMetadata/edu.tufts/blob/master/0/108/220/208/fgdc.xml
  def tufts_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/tufts_fgdc.xml'))
  end

  def princeton_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/princeton_fgdc.xml'))
  end

  ##
  # Harvard FGDC examples from https://github.com/harvard-library/harvard-geodata/tree/main/fgdc
  #
  # Vector polygon dataset. Carries abstract, purpose and supplemental
  # information, so it exercises the full three-part dct_description_sm.
  # Upstream filename: NHGIS_POP1860.xml
  def harvard_nhgis_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/harvard_nhgis_fgdc.xml'))
  end

  ##
  # Vector line dataset restricted to Harvard affiliates, with an uppercase
  # "SHAPE" format name. Upstream filename: KNG_CONT.xml
  def harvard_kng_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/harvard_kng_fgdc.xml'))
  end

  ##
  # Vector line dataset with a date range rather than a single date, and a
  # multi-paragraph abstract. Upstream filename: USGS_GT_PUERTO_BARRIOS_PHLB.xml
  def harvard_usgs_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/harvard_usgs_fgdc.xml'))
  end

  ##
  # Vector point dataset with a five-paragraph abstract and a near-global
  # bounding box. Upstream filename: GLB_GAZCTY.xml
  def harvard_glb_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/harvard_glb_fgdc.xml'))
  end

  ##
  # Scanned map: the only non-vector fixture. geoform is "map" and spdoinfo
  # reports Raster with no sdtstype, and pubdate is YYYYMM.
  # Upstream filename: G9482_T35_1899_U5_MAPA.xml
  def harvard_mapa_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/harvard_mapa_fgdc.xml'))
  end

  ##
  # Hand-authored record whose themekt values use the GBL controlled
  # thesaurus names, and whose geoform/sdtstype deliberately disagree with them
  def gbl_keywords_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/gbl_keywords_fgdc.xml'))
  end
end
