module GeoCombine
  ##
  # Translation dictionary for mime-type to valid GeoBlacklight-Schema formats
  module Formats
    def formats
      {
        'application/x-esri-shapefile' => 'Shapefile'
      }
    end
  end
end
