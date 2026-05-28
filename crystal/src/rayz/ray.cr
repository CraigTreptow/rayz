module Rayz
  class Ray
    getter origin : Point
    getter direction : Vector
    getter time : Float64

    def initialize(origin : Point, direction : Vector, time : Float64 = 0.0)
      @origin = origin
      @direction = direction
      @time = time
    end

    def position(t : Float64 | Int32) : Tuple
      @origin + @direction * t.to_f
    end

    def transform(matrix : Matrix) : Ray
      new_o = matrix * @origin
      new_d = matrix * @direction
      Ray.new(
        Point.new(new_o.x, new_o.y, new_o.z),
        Vector.new(new_d.x, new_d.y, new_d.z),
        @time
      )
    end
  end
end
