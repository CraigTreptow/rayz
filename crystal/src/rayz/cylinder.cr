module Rayz
  class Cylinder < Shape
    property minimum : Float64
    property maximum : Float64
    property closed : Bool

    def initialize
      super
      @minimum = -Float64::INFINITY
      @maximum = Float64::INFINITY
      @closed = false
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      xs = [] of Intersection

      a = local_ray.direction.x ** 2 + local_ray.direction.z ** 2

      if a.abs >= Util::EPSILON
        b = 2.0 * local_ray.origin.x * local_ray.direction.x +
            2.0 * local_ray.origin.z * local_ray.direction.z
        c = local_ray.origin.x ** 2 + local_ray.origin.z ** 2 - 1.0

        disc = b * b - 4.0 * a * c
        return [] of Intersection if disc < 0.0

        t0 = (-b - Math.sqrt(disc)) / (2.0 * a)
        t1 = (-b + Math.sqrt(disc)) / (2.0 * a)
        t0, t1 = t1, t0 if t0 > t1

        y0 = local_ray.origin.y + t0 * local_ray.direction.y
        xs << Intersection.new(t0, self) if @minimum < y0 && y0 < @maximum

        y1 = local_ray.origin.y + t1 * local_ray.direction.y
        xs << Intersection.new(t1, self) if @minimum < y1 && y1 < @maximum
      end

      intersect_caps(local_ray, xs)
      xs
    end

    def local_normal_at(local_point : Point) : Tuple
      dist = local_point.x ** 2 + local_point.z ** 2

      if dist < 1.0 && local_point.y >= @maximum - Util::EPSILON
        return Vector.new(0.0, 1.0, 0.0)
      end

      if dist < 1.0 && local_point.y <= @minimum + Util::EPSILON
        return Vector.new(0.0, -1.0, 0.0)
      end

      Vector.new(local_point.x, 0.0, local_point.z)
    end

    def bounds : Bounds
      Bounds.new(min: Point.new(-1.0, @minimum, -1.0), max: Point.new(1.0, @maximum, 1.0))
    end

    private def check_cap(ray : Ray, t : Float64) : Bool
      x = ray.origin.x + t * ray.direction.x
      z = ray.origin.z + t * ray.direction.z
      (x ** 2 + z ** 2) <= 1.0
    end

    private def intersect_caps(ray : Ray, xs : Array(Intersection)) : Nil
      return unless @closed && ray.direction.y.abs >= Util::EPSILON

      t = (@minimum - ray.origin.y) / ray.direction.y
      xs << Intersection.new(t, self) if check_cap(ray, t)

      t = (@maximum - ray.origin.y) / ray.direction.y
      xs << Intersection.new(t, self) if check_cap(ray, t)
    end
  end
end
