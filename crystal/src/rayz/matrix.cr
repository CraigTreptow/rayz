module Rayz
  class Matrix
    getter rows : Int32
    getter cols : Int32
    getter flat : Array(Float64)

    def initialize(data : Array(Array(Float64)))
      @data = data
      @rows = data.size
      @cols = data[0].size
      @flat = data.flatten
    end

    def self.identity(size : Int32 = 4) : Matrix
      data = Array.new(size) { |i| Array.new(size) { |j| i == j ? 1.0 : 0.0 } }
      new(data)
    end

    def [](row : Int32, col : Int32) : Float64
      @data[row][col]
    end

    def ==(other : Matrix) : Bool
      return false if @rows != other.rows || @cols != other.cols
      @rows.times.all? do |i|
        @cols.times.all? do |j|
          Util.approx_eq?(@data[i][j], other[i, j])
        end
      end
    end

    def *(other : Matrix) : Matrix
      af = @flat
      bf = other.flat
      nc = other.cols
      data = Array.new(@rows) do |i|
        Array.new(nc) do |j|
          sum = 0.0
          @cols.times { |k| sum += af.unsafe_fetch(i * @cols + k) * bf.unsafe_fetch(k * nc + j) }
          sum
        end
      end
      Matrix.new(data)
    end

    def *(pt : Point) : Point
      f = @flat
      Point.new(
        f.unsafe_fetch(0) * pt.x + f.unsafe_fetch(1) * pt.y + f.unsafe_fetch(2) * pt.z + f.unsafe_fetch(3),
        f.unsafe_fetch(4) * pt.x + f.unsafe_fetch(5) * pt.y + f.unsafe_fetch(6) * pt.z + f.unsafe_fetch(7),
        f.unsafe_fetch(8) * pt.x + f.unsafe_fetch(9) * pt.y + f.unsafe_fetch(10) * pt.z + f.unsafe_fetch(11)
      )
    end

    def *(vec : Vector) : Vector
      f = @flat
      Vector.new(
        f.unsafe_fetch(0) * vec.x + f.unsafe_fetch(1) * vec.y + f.unsafe_fetch(2) * vec.z,
        f.unsafe_fetch(4) * vec.x + f.unsafe_fetch(5) * vec.y + f.unsafe_fetch(6) * vec.z,
        f.unsafe_fetch(8) * vec.x + f.unsafe_fetch(9) * vec.y + f.unsafe_fetch(10) * vec.z
      )
    end

    def *(tuple : Tuple) : Tuple
      Tuple.new(
        row_dot(0, tuple),
        row_dot(1, tuple),
        row_dot(2, tuple),
        row_dot(3, tuple)
      )
    end

    def transpose : Matrix
      data = Array.new(@cols) do |i|
        Array.new(@rows) { |j| @data[j][i] }
      end
      Matrix.new(data)
    end

    def submatrix(skip_row : Int32, skip_col : Int32) : Matrix
      data = [] of Array(Float64)
      @data.each_with_index do |row, i|
        next if i == skip_row
        new_row = [] of Float64
        row.each_with_index { |val, j| new_row << val unless j == skip_col }
        data << new_row
      end
      Matrix.new(data)
    end

    def determinant : Float64
      if @rows == 2
        @data[0][0] * @data[1][1] - @data[0][1] * @data[1][0]
      else
        sum = 0.0
        @cols.times { |j| sum += @data[0][j] * cofactor(0, j) }
        sum
      end
    end

    def minor(row : Int32, col : Int32) : Float64
      submatrix(row, col).determinant
    end

    def cofactor(row : Int32, col : Int32) : Float64
      m = minor(row, col)
      (row + col).odd? ? -m : m
    end

    def invertible? : Bool
      !Util.approx_eq?(determinant, 0.0)
    end

    def inverse : Matrix
      det = determinant
      raise "Matrix is not invertible" if Util.approx_eq?(det, 0.0)
      data = Array.new(@rows) do |i|
        Array.new(@cols) { |j| cofactor(j, i) / det }
      end
      Matrix.new(data)
    end

    private def row_dot(row : Int32, t : Tuple) : Float64
      base = row * @cols
      f = @flat
      f.unsafe_fetch(base) * t.x + f.unsafe_fetch(base + 1) * t.y +
        f.unsafe_fetch(base + 2) * t.z + f.unsafe_fetch(base + 3) * t.w
    end
  end
end
