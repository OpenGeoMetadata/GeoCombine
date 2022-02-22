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
end
