module Rayz
  class Spotlight
    getter position : Point
    getter intensity : Color
    getter direction : Vector
    getter cone_angle : Float64
    getter fade_angle : Float64

    def initialize(position : Point, intensity : Color, direction : Vector,
                   cone_angle : Float64, fade_angle : Float64 = cone_angle)
      @position = position
      @intensity = intensity
      d = direction.normalize
      @direction = Vector.new(d.x, d.y, d.z)
      @cone_angle = cone_angle
      @fade_angle = fade_angle
    end

    def intensity_at(point : Point, world : World) : Float64
      light_to_point_t = (point - @position).normalize
      light_to_point = Vector.new(light_to_point_t.x, light_to_point_t.y, light_to_point_t.z)
      cos_angle = @direction.dot(light_to_point)

      cos_outer = Math.cos(@cone_angle)
      cos_inner = Math.cos(@fade_angle)

      return 0.0 if cos_angle < cos_outer

      if cos_angle >= cos_inner
        return world.is_shadowed_from?(point, @position) ? 0.0 : 1.0
      end

      fade_factor = (cos_angle - cos_outer) / (cos_inner - cos_outer)
      world.is_shadowed_from?(point, @position) ? 0.0 : fade_factor
    end
  end
end
