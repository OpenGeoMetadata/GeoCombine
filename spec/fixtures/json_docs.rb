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
end
