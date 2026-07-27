module Rayz
  abstract class Shape
    property material : Material
    property parent : Shape?
    property motion_transform : Proc(Float64, Matrix)?
    getter transform : Matrix
    getter transform_inverse : Matrix

    def initialize
      @transform = Matrix.identity
      @transform_inverse = Matrix.identity
      @transform_inverse_transpose = Matrix.identity
      @material = Material.new
      @parent = nil
      @motion_transform = nil
    end

    def transform=(m : Matrix)
      @transform = m
      @transform_inverse = m.inverse
      @transform_inverse_transpose = @transform_inverse.transpose
      invalidate_bounds_cache
    end

    # Group/CSG cache their merged bounds; changing any shape's transform
    # (including a leaf nested deep in the hierarchy) can change an
    # ancestor's bounds, so the invalidation has to propagate upward.
    # Base shapes have nothing of their own to clear, but still need to
    # keep the propagation going.
    def invalidate_bounds_cache : Nil
      @parent.try(&.invalidate_bounds_cache)
    end

    def intersect(ray : Ray) : Array(Intersection)
      buf = [] of Intersection
      intersect_into(ray, buf)
      buf
    end

    def intersect_into(ray : Ray, buf : Array(Intersection)) : Nil
      inv = if mt = @motion_transform
              (mt.call(ray.time) * @transform).inverse
            else
              @transform_inverse
            end
      local_ray = ray.transform(inv)
      local_intersect_into(local_ray, buf)
    end

    def local_intersect_into(local_ray : Ray, buf : Array(Intersection)) : Nil
      buf.concat(local_intersect(local_ray))
    end

    def normal_at(world_point : Point, hit : Intersection? = nil) : Vector
      local_point = world_to_object(world_point)
      local_normal = local_normal_at(local_point)

      if perturb = @material.normal_perturbation
        delta = perturb.call(local_point)
        sum = local_normal + delta
        local_normal = Vector.new(sum.x, sum.y, sum.z).normalize
      end

      normal_to_world(local_normal)
    end

    abstract def local_intersect(local_ray : Ray) : Array(Intersection)
    abstract def local_normal_at(local_point : Point) : Tuple
    abstract def bounds : Bounds

    def includes?(shape : Shape) : Bool
      same?(shape)
    end

    def world_to_object(point : Point) : Point
      p = if (par = @parent)
            par.world_to_object(point)
          else
            point
          end
      @transform_inverse * p
    end

    def normal_to_world(normal : Tuple) : Vector
      result = @transform_inverse_transpose * normal
      t = Vector.new(result.x, result.y, result.z).normalize
      v = Vector.new(t.x, t.y, t.z)
      if (par = @parent)
        par.normal_to_world(v)
      else
        v
      end
    end
  end
end
