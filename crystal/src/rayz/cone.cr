module Rayz
  class Cone < Shape
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

      dx = local_ray.direction.x
      dy = local_ray.direction.y
      dz = local_ray.direction.z
      ox = local_ray.origin.x
      oy = local_ray.origin.y
      oz = local_ray.origin.z

      a = dx * dx - dy * dy + dz * dz
      b = 2.0 * ox * dx - 2.0 * oy * dy + 2.0 * oz * dz
      c = ox * ox - oy * oy + oz * oz

      if a.abs < Util::EPSILON
        if b.abs >= Util::EPSILON
          xs << Intersection.new(-c / (2.0 * b), self)
        end
      else
        disc = b * b - 4.0 * a * c
        return [] of Intersection if disc < 0.0

        t0 = (-b - Math.sqrt(disc)) / (2.0 * a)
        t1 = (-b + Math.sqrt(disc)) / (2.0 * a)
        t0, t1 = t1, t0 if t0 > t1

        y0 = oy + t0 * dy
        xs << Intersection.new(t0, self) if @minimum < y0 && y0 < @maximum

        y1 = oy + t1 * dy
        xs << Intersection.new(t1, self) if @minimum < y1 && y1 < @maximum
      end

      intersect_caps(local_ray, xs)
      xs
    end

    def local_normal_at(local_point : Point) : Tuple
      dist = Math.sqrt(local_point.x ** 2 + local_point.z ** 2)
      dist = -dist if local_point.y > 0.0

      if dist < 1.0 && local_point.y >= @maximum - Util::EPSILON
        return Vector.new(0.0, 1.0, 0.0)
      end

      if dist < 1.0 && local_point.y <= @minimum + Util::EPSILON
        return Vector.new(0.0, -1.0, 0.0)
      end

      Vector.new(local_point.x, dist, local_point.z)
    end

    private def check_cap(ray : Ray, t : Float64, y : Float64) : Bool
      x = ray.origin.x + t * ray.direction.x
      z = ray.origin.z + t * ray.direction.z
      (x ** 2 + z ** 2) <= y * y
    end

    private def intersect_caps(ray : Ray, xs : Array(Intersection)) : Nil
      return unless @closed && ray.direction.y.abs >= Util::EPSILON

      t = (@minimum - ray.origin.y) / ray.direction.y
      xs << Intersection.new(t, self) if check_cap(ray, t, @minimum)

      t = (@maximum - ray.origin.y) / ray.direction.y
      xs << Intersection.new(t, self) if check_cap(ray, t, @maximum)
    end
  end
end
