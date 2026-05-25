module Rayz
  abstract class Shape
    property material : Material
    property parent : Shape?
    getter transform : Matrix
    getter transform_inverse : Matrix

    def initialize
      @transform = Matrix.identity
      @transform_inverse = Matrix.identity
      @transform_inverse_transpose = Matrix.identity
      @material = Material.new
      @parent = nil
    end

    def transform=(m : Matrix)
      @transform = m
      @transform_inverse = m.inverse
      @transform_inverse_transpose = @transform_inverse.transpose
    end

    def intersect(ray : Ray) : Array(Intersection)
      local_intersect(ray.transform(@transform_inverse))
    end

    def normal_at(world_point : Point) : Vector
      normal_to_world(local_normal_at(world_to_object(world_point)))
    end

    abstract def local_intersect(local_ray : Ray) : Array(Intersection)
    abstract def local_normal_at(local_point : Point) : Tuple

    def includes?(shape : Shape) : Bool
      same?(shape)
    end

    def world_to_object(point : Point) : Point
      p = if (par = @parent)
            par.world_to_object(point)
          else
            point
          end
      result = @transform_inverse * p
      Point.new(result.x, result.y, result.z)
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
