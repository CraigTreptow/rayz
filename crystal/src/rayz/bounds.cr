module Rayz
  class Bounds
    property min : Point
    property max : Point

    def initialize(
      min : Point = Point.new(Float64::INFINITY, Float64::INFINITY, Float64::INFINITY),
      max : Point = Point.new(-Float64::INFINITY, -Float64::INFINITY, -Float64::INFINITY),
    )
      @min = min
      @max = max
    end

    def merge(other : Bounds) : Bounds
      Bounds.new(
        min: Point.new(
          {@min.x, other.min.x}.min,
          {@min.y, other.min.y}.min,
          {@min.z, other.min.z}.min
        ),
        max: Point.new(
          {@max.x, other.max.x}.max,
          {@max.y, other.max.y}.max,
          {@max.z, other.max.z}.max
        )
      )
    end

    def transform(matrix : Matrix) : Bounds
      corners = [
        Point.new(@min.x, @min.y, @min.z),
        Point.new(@min.x, @min.y, @max.z),
        Point.new(@min.x, @max.y, @min.z),
        Point.new(@min.x, @max.y, @max.z),
        Point.new(@max.x, @min.y, @min.z),
        Point.new(@max.x, @min.y, @max.z),
        Point.new(@max.x, @max.y, @min.z),
        Point.new(@max.x, @max.y, @max.z),
      ]

      transformed = corners.map do |c|
        t = matrix * c
        Point.new(t.x, t.y, t.z)
      end

      Bounds.new(
        min: Point.new(
          transformed.min_of(&.x),
          transformed.min_of(&.y),
          transformed.min_of(&.z)
        ),
        max: Point.new(
          transformed.max_of(&.x),
          transformed.max_of(&.y),
          transformed.max_of(&.z)
        )
      )
    end

    def intersects?(ray : Ray) : Bool
      xtmin, xtmax = check_axis(ray.origin.x, ray.direction.x, @min.x, @max.x)
      ytmin, ytmax = check_axis(ray.origin.y, ray.direction.y, @min.y, @max.y)
      ztmin, ztmax = check_axis(ray.origin.z, ray.direction.z, @min.z, @max.z)

      tmin = {xtmin, ytmin, ztmin}.max
      tmax = {xtmax, ytmax, ztmax}.min

      tmin <= tmax
    end

    def contains_point?(point : Point) : Bool
      point.x >= @min.x && point.x <= @max.x &&
        point.y >= @min.y && point.y <= @max.y &&
        point.z >= @min.z && point.z <= @max.z
    end

    def contains_bounds?(other : Bounds) : Bool
      contains_point?(other.min) && contains_point?(other.max)
    end

    private def check_axis(origin : Float64, direction : Float64, min_val : Float64, max_val : Float64) : {Float64, Float64}
      tmin_num = min_val - origin
      tmax_num = max_val - origin

      if direction.abs >= Util::EPSILON
        tmin = tmin_num / direction
        tmax = tmax_num / direction
      else
        # Ray is parallel to this axis's planes. A numerator of exactly
        # zero means the origin sits exactly on that plane, which imposes
        # no constraint from this axis rather than the NaN that
        # `0.0 * Float64::INFINITY` would otherwise produce.
        tmin = tmin_num.zero? ? -Float64::INFINITY : tmin_num * Float64::INFINITY
        tmax = tmax_num.zero? ? Float64::INFINITY : tmax_num * Float64::INFINITY
      end

      tmin < tmax ? {tmin, tmax} : {tmax, tmin}
    end
  end

  def self.bounds_of(shape : Shape) : Bounds
    shape.bounds
  end
end
