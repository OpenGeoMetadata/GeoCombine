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
  # NYU ISO19139 example from https://github.com/OpenGeoMetadata/edu.nyu/blob/dfcef04cd2fd8cc5f6e6de098b8734911c2aec40/metadata-1.0/handle/2451/3/44/91/iso19139.xml
  #
  # ArcGIS export of a vector point dataset with a GUID fileIdentifier, an
  # untyped "Downloadable Data" keyword and a license URI written into the
  # use limitation.
  def nyu_colleges_iso
    File.read(File.join(File.dirname(__FILE__), './docs/nyu_colleges_iso.xml'))
  end

  ##
  # University of Arizona ISO19139 examples from https://github.com/OpenGeoMetadata/edu.uarizona/tree/42f5e656325e3d739b8fe67f8c1eae150baab8ed
  #
  # Vector polygon dataset with an empty fileIdentifier, so the id comes from
  # the DOI in dataSetURI. Its lineage sources carry their own temporal extents.
  # Upstream path: bM5/Up7/Ma/9Q/iso19139.xml
  def arizona_reservations_iso
    File.read(File.join(File.dirname(__FILE__), './docs/arizona_reservations_iso.xml'))
  end

  ##
  # ISO 19115-2 (gmi:MI_Metadata) record for scanned topographic maps served
  # as a raster, mixing GML 3.2 and GML 3.1 namespaces, with a 1970-1995 time
  # period. Upstream path: OY5/p8N/xC/Lr/iso19139.xml
  def arizona_topo_iso
    File.read(File.join(File.dirname(__FILE__), './docs/arizona_topo_iso.xml'))
  end

  ##
  # Hand-authored ISO 19115-2 record with OGC and Esri services, several
  # downloads, GBL controlled keywords, restricted access, multiple bounding
  # boxes and an open-ended time period
  def services_iso
    File.read(File.join(File.dirname(__FILE__), './docs/services_iso.xml'))
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
  # Vector point dataset whose content date is the zero-padded year 0001.
  def harvard_euratlas_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/harvard_euratlas_fgdc.xml'))
  end

  ##
  # Hand-authored record whose themekt values use the GBL controlled
  # thesaurus names, and whose geoform/sdtstype deliberately disagree with them
  def gbl_keywords_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/gbl_keywords_fgdc.xml'))
  end

  ##
  # Hand-authored scanned map that repeats keywords, place names and dates
  def duplicate_values_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/duplicate_values_fgdc.xml'))
  end

  ##
  # Cornell (CUGIR) vector dataset whose digital forms pair each network
  # resource with a format: a zipped shapefile, PDF and KMZ downloads, FGDC and
  # HTML metadata, and WMS and WFS requests. Also has a browse graphic URL.
  # From https://github.com/OpenGeoMetadata/edu.cornell/blob/main/00/79/48/fgdc.xml
  def cornell_agdistricts_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/cornell_agdistricts_fgdc.xml'))
  end

  ##
  # Hand-authored record with wrapped and free-text links, a site's home page,
  # and WMS, WFS, WMTS and ArcGIS REST services
  def services_fgdc
    File.read(File.join(File.dirname(__FILE__), './docs/services_fgdc.xml'))
  end
end
