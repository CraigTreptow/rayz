module Rayz
  class Plane < Shape
    PLANE_EPSILON = 1e-5

    def local_intersect(local_ray : Ray) : Array(Intersection)
      return [] of Intersection if local_ray.direction.y.abs < PLANE_EPSILON

      t = -local_ray.origin.y / local_ray.direction.y
      [Intersection.new(t, self)]
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
