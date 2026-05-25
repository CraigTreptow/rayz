module Rayz
  class SmoothTriangle < Triangle
    getter n1 : Vector
    getter n2 : Vector
    getter n3 : Vector

    def initialize(p1 : Point, p2 : Point, p3 : Point, n1 : Vector, n2 : Vector, n3 : Vector)
      super(p1, p2, p3)
      @n1 = n1
      @n2 = n2
      @n3 = n3
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
      [Intersection.new(t, self, u, v)]
    end

    def normal_at(world_point : Point, hit : Intersection? = nil) : Vector
      if h = hit
        u_val = h.u || 0.0
        v_val = h.v || 0.0
        n_t = @n2 * u_val + @n3 * v_val + @n1 * (1.0 - u_val - v_val)
        normal_to_world(Vector.new(n_t.x, n_t.y, n_t.z))
      else
        normal_to_world(@normal)
      end
    end
  end
end
