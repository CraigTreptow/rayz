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
      Ray.new(matrix * @origin, matrix * @direction, @time)
    end
  end
end
