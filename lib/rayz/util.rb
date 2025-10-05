module Rayz
  class Util
    EPSILON = 0.00001

    def self.==(x, y)
      (x - y).abs < EPSILON
    end

    def self.matrix_multiplied_by_tuple(m, t)
      result = (m * t.to_matrix).to_a.flatten
      Rayz::Tuple.new(x: result[0], y: result[1], z: result[2], w: result[3])
    end

    def self.matrix_minor(matrix, i, j)
      matrix.first_minor(i, j).determinant
    end

    def self.matrix_cofactor(matrix, i, j)
      minor = matrix_minor(matrix, i, j)
      # Negate if row + column is odd
      (i + j).odd? ? -minor : minor
    end
  end
end
