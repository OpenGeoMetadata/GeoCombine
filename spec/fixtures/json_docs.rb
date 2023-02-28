# frozen_string_literal: true

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
  #  full_geoblacklight fixture converted to the aardvark schema
  def full_geoblacklight_aardvark
    File.read(File.join(File.dirname(__FILE__), './docs/full_geoblacklight_aardvark.json'))
  end

  ##
  # A sample Esri OpenData metadata record
  def esri_opendata_metadata
    File.read(File.join(File.dirname(__FILE__), './docs/esri_open_data.json'))
  end

  def ckan_metadata
    File.read(File.join(File.dirname(__FILE__), './docs/ckan.json'))
  end

  def ogp_harvard_raster
    File.read(File.join(File.dirname(__FILE__), './docs/ogp_harvard_raster.json'))
  end

  def ogp_harvard_line
    File.read(File.join(File.dirname(__FILE__), './docs/ogp_harvard_line.json'))
  end

  def ogp_tufts_vector
    File.read(File.join(File.dirname(__FILE__), './docs/ogp_tufts_vector.json'))
  end

  def geoblacklight_pre_v1
    File.read(File.join(File.dirname(__FILE__), './docs/geoblacklight_pre_v1.json'))
  end
end
