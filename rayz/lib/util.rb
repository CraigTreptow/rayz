module Rayz
  module Lib
    class Util
      def self.==(x, y)
        tolerance = 0.00001
        (x - y).abs < tolerance
      end

      def self.matrix_multiplied_by_tuple(m, t)
        result = (m * t.to_matrix).to_a.flatten
        Rayz::Lib::Tuple.new(x: result[0], y: result[1], z: result[2], w: result[3])
      end

      def self.matrix_minor(matrix, i, j)
        matrix.first_minor(i, j).determinant
      end
    end
  end
end
