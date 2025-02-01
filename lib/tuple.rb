class Tuple
  attr_reader :x, :y, :z, :w

  def initialize(x:, y:, z:, w:)
    @x = x
    @y = y
    @z = z
    @w = w
  end

  def point?
    Util.==(@w, 1.0)
    # @w == 1.0
  end

  def vector?
    @w == 0
  end
end
