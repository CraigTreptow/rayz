module Rayz
  class Triangle < Shape
    getter p1 : Point
    getter p2 : Point
    getter p3 : Point
    getter e1 : Vector
    getter e2 : Vector
    getter normal : Vector

    def initialize(p1 : Point, p2 : Point, p3 : Point)
      super()
      @p1 = p1
      @p2 = p2
      @p3 = p3
      e1_t = p2 - p1
      e2_t = p3 - p1
      @e1 = Vector.new(e1_t.x, e1_t.y, e1_t.z)
      @e2 = Vector.new(e2_t.x, e2_t.y, e2_t.z)
      n_t = @e2.cross(@e1).normalize
      @normal = Vector.new(n_t.x, n_t.y, n_t.z)
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      dir_cross_e2 = local_ray.direction.cross(@e2)
      det = @e1.dot(dir_cross_e2)
      return [] of Intersection if det.abs < Util::EPSILON

      f = 1.0 / det

      p1_to_origin_t = local_ray.origin - @p1
      p1_to_origin = Vector.new(p1_to_origin_t.x, p1_to_origin_t.y, p1_to_origin_t.z)
      u = f * p1_to_origin.dot(dir_cross_e2)
      return [] of Intersection if u < 0.0 || u > 1.0

      origin_cross_e1 = p1_to_origin.cross(@e1)
      v = f * local_ray.direction.dot(origin_cross_e1)
      return [] of Intersection if v < 0.0 || (u + v) > 1.0

      t = f * @e2.dot(origin_cross_e1)
      [Intersection.new(t, self)]
    end

    def local_normal_at(local_point : Point) : Tuple
      @normal
    end
  end
end
