module Rayz
  class Ray
    getter origin : Point
    getter direction : Vector

    def initialize(origin : Point, direction : Vector)
      @origin = origin
      @direction = direction
    end

    def position(t : Float64 | Int32) : Tuple
      @origin + @direction * t.to_f
    end

    def transform(matrix : Matrix) : Ray
      new_o = matrix * @origin
      new_d = matrix * @direction
      Ray.new(
        Point.new(new_o.x, new_o.y, new_o.z),
        Vector.new(new_d.x, new_d.y, new_d.z)
      )
    end
  end
end
