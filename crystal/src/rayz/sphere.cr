module Rayz
  class Sphere < Shape
    def local_intersect(local_ray : Ray) : Array(Intersection)
      sphere_to_ray = local_ray.origin - Point.new(0.0, 0.0, 0.0)
      a = local_ray.direction.dot(local_ray.direction)
      b = 2.0 * local_ray.direction.dot(sphere_to_ray)
      c = sphere_to_ray.dot(sphere_to_ray) - 1.0
      discriminant = b * b - 4.0 * a * c
      return [] of Intersection if discriminant < 0.0
      sq = Math.sqrt(discriminant)
      [
        Intersection.new((-b - sq) / (2.0 * a), self),
        Intersection.new((-b + sq) / (2.0 * a), self),
      ]
    end

    def local_normal_at(local_point : Point) : Tuple
      local_point - Point.new(0.0, 0.0, 0.0)
    end
  end

  def self.glass_sphere : Sphere
    s = Sphere.new
    s.material.transparency = 1.0
    s.material.refractive_index = 1.5
    s
  end
end
