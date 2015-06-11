##
# JSON docs that can be included into specs
module JsonDocs
  ##
  # A basic incomplete, non-compliant GeoBlacklight-Schema json document
  def basic_geoblacklight
    File.read(File.join(File.dirname(__FILE__), './docs/basic_geoblacklight.json'))
  end

  ##
  # A fully compliant GeoBlacklight-Schema json document
  def full_geoblacklight
    File.read(File.join(File.dirname(__FILE__), './docs/full_geoblacklight.json'))
  end

  ##
  # A sample Esri OpenData metadata record
  def esri_opendata_metadata
    File.read(File.join(File.dirname(__FILE__), './docs/esri_open_data.json'))
  end
end
