class Point < Tuple
  def initialize(x:, y:, z:)
    @x = x
    @y = y
    @z = z
    @w = 1.0
  end

  def -(other)
    Vector.new(x: @x - other.x, y: @y - other.y, z: @z - other.z)
  end
end
