module Rayz
  class Ray
    attr_reader :origin, :direction

    def initialize(origin, direction)
      @origin = origin
      @direction = direction
    end

    def position(t)
      @origin + @direction * t
    end

    def transform(matrix)
      new_origin = Rayz::Util.matrix_multiplied_by_tuple(matrix, @origin)
      new_direction = Rayz::Util.matrix_multiplied_by_tuple(matrix, @direction)
      Ray.new(new_origin, new_direction)
    end
  end
end
