# frozen_string_literal: true

module GeoCombine
  module GeometryTypes
    def geometry_types
      {
        'esriGeometryPoint' => 'Point',
        'esriGeometryPolygon' => 'Polygon',
        'esriGeometryPolyline' => 'Line'
      }
    end
  end
end
