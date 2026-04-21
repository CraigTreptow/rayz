module Rayz
  class Ray
    attr_reader :origin, :direction, :time

    def initialize(origin:, direction:, time: 0.0)
      @origin = origin
      @direction = direction
      @time = time  # For motion blur
    end

    def position(t)
      @origin + @direction * t
    end

    def transform(matrix)
      new_origin = Rayz::Util.matrix_multiplied_by_tuple(matrix, @origin)
      new_direction = Rayz::Util.matrix_multiplied_by_tuple(matrix, @direction)
      Ray.new(origin: new_origin, direction: new_direction, time: @time)
    end
  end
end
