class Tuple
  attr_reader :x, :y, :z, :w

  def initialize(x:, y:, z:, w:)
    @x = x
    @y = y
    @z = z
    @w = w
  end

  def ==(other)
    Util.==(x, other.x)
    Util.==(y, other.y)
    Util.==(z, other.z)
    Util.==(w, other.w)
  end

  def point?
    Util.==(@w, 1.0)
  end

  def vector?
    Util.==(@w, 0.0)
  end
end
