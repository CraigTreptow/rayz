module Rayz
  class AreaLight
    attr_reader :corner, :uvec, :vvec, :usteps, :vsteps, :samples, :intensity
    attr_accessor :jitter_by

    def initialize(corner:, full_uvec:, full_vvec:, usteps:, vsteps:, intensity:, jitter_by: nil)
      @corner = corner
      @usteps = usteps
      @vsteps = vsteps
      @samples = usteps * vsteps
      @intensity = intensity
      @jitter_by = jitter_by

      # Divide the full vectors by the number of steps to get the step vectors
      @uvec = full_uvec / usteps.to_f
      @vvec = full_vvec / vsteps.to_f
    end

    # Get a point on the light surface at grid position (u, v)
    # u and v are in the range [0, usteps-1] and [0, vsteps-1]
    def point_on_light(u, v)
      @corner + @uvec * (u + 0.5) + @vvec * (v + 0.5)
    end

    # Generate a random jitter within [-0.5, 0.5] for subpixel sampling
    def jitter
      return 0.0 unless @jitter_by

      @jitter_by.call
    end

    # Get the intensity at a point by sampling the area light
    def intensity_at(point, world)
      total = 0.0

      (0...@vsteps).each do |v|
        (0...@usteps).each do |u|
          light_position = point_on_light(u + jitter, v + jitter)
          total += 1.0 unless world.is_shadowed_from?(point, light_position)
        end
      end

      total / @samples
    end

    def ==(other)
      return false unless other.is_a?(AreaLight)

      @corner == other.corner &&
        @uvec == other.uvec &&
        @vvec == other.vvec &&
        @usteps == other.usteps &&
        @vsteps == other.vsteps &&
        @intensity == other.intensity
    end
  end
end
