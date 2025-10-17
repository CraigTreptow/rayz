module Rayz
  class Spotlight
    attr_reader :position, :intensity, :direction, :cone_angle, :fade_angle

    def initialize(position:, intensity:, direction:, cone_angle:, fade_angle: nil)
      @position = position
      @intensity = intensity
      @direction = direction.normalize
      @cone_angle = cone_angle  # Outer cone angle in radians
      @fade_angle = fade_angle || cone_angle  # Inner fade angle (defaults to cone_angle for hard edge)
    end

    # Calculate the intensity at a point based on whether it's in the spotlight cone
    # Returns a value between 0.0 (outside cone) and 1.0 (inside fade area)
    def intensity_at(point, world)
      # Vector from light to point
      light_to_point = (point - @position).normalize

      # Cosine of angle between light direction and light-to-point vector
      # (dot product of normalized vectors)
      cos_angle = @direction.dot(light_to_point)

      # Cosines for our cone angles
      cos_outer = Math.cos(@cone_angle)
      cos_inner = Math.cos(@fade_angle)

      # If point is outside the cone, intensity is 0
      return 0.0 if cos_angle < cos_outer

      # If point is inside fade angle, full intensity (but check shadow)
      if cos_angle >= cos_inner
        # Check if point is shadowed from this light position
        return world.is_shadowed_from?(point, @position) ? 0.0 : 1.0
      end

      # Point is in the fade zone - interpolate between 0 and 1
      # cos_angle is between cos_outer and cos_inner
      # Map it to range [0, 1]
      fade_factor = (cos_angle - cos_outer) / (cos_inner - cos_outer)

      # Check shadow
      shadowed = world.is_shadowed_from?(point, @position)
      shadowed ? 0.0 : fade_factor
    end

    def ==(other)
      return false unless other.is_a?(Spotlight)

      @position == other.position &&
        @intensity == other.intensity &&
        @direction == other.direction &&
        @cone_angle == other.cone_angle &&
        @fade_angle == other.fade_angle
    end
  end
end
