module Rayz
  class Plane < Shape
    PLANE_EPSILON = 1e-5

    def local_intersect(local_ray : Ray) : Array(Intersection)
      buf = [] of Intersection
      local_intersect_into(local_ray, buf)
      buf
    end

    def local_intersect_into(local_ray : Ray, buf : Array(Intersection)) : Nil
      return if local_ray.direction.y.abs < PLANE_EPSILON
      buf << Intersection.new(-local_ray.origin.y / local_ray.direction.y, self)
    end

    def local_normal_at(local_point : Point) : Tuple
      Vector.new(0.0, 1.0, 0.0)
    end

    def bounds : Bounds
      Bounds.new(
        min: Point.new(-Float64::INFINITY, 0.0, -Float64::INFINITY),
        max: Point.new(Float64::INFINITY, 0.0, Float64::INFINITY)
      )
    end
  end
end
