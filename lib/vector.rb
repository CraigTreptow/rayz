class Vector < Tuple
  def initialize(x:, y:, z:)
    @x = x
    @y = y
    @z = z
    @w = 0
  end

  def magnitude
    Math.sqrt(@x**2 + @y**2 + @z**2 + @w**2)
  end
end
