module Rayz
  class AreaLight
    getter corner : Point
    getter uvec : Vector
    getter vvec : Vector
    getter usteps : Int32
    getter vsteps : Int32
    getter samples : Int32
    getter intensity : Color
    property jitter_by : Proc(Float64)?

    def initialize(corner : Point, full_uvec : Vector, full_vvec : Vector,
                   usteps : Int32, vsteps : Int32, intensity : Color,
                   jitter_by : Proc(Float64)? = nil)
      @corner = corner
      @usteps = usteps
      @vsteps = vsteps
      @samples = usteps * vsteps
      @intensity = intensity
      @jitter_by = jitter_by
      @uvec = Vector.new(full_uvec.x / usteps, full_uvec.y / usteps, full_uvec.z / usteps)
      @vvec = Vector.new(full_vvec.x / vsteps, full_vvec.y / vsteps, full_vvec.z / vsteps)
    end

    def position : Point
      t = @corner + @uvec * (@usteps / 2.0) + @vvec * (@vsteps / 2.0)
      Point.new(t.x, t.y, t.z)
    end

    def point_on_light(u : Float64, v : Float64) : Point
      t = @corner + @uvec * (u + 0.5) + @vvec * (v + 0.5)
      Point.new(t.x, t.y, t.z)
    end

    def jitter : Float64
      jb = @jitter_by
      jb ? jb.call : 0.0
    end

    def intensity_at(point : Point, world : World) : Float64
      total = 0.0
      (0...@vsteps).each do |v|
        (0...@usteps).each do |u|
          light_position = point_on_light(u.to_f + jitter, v.to_f + jitter)
          total += 1.0 unless world.is_shadowed_from?(point, light_position)
        end
      end
      total / @samples
    end
  end
end
