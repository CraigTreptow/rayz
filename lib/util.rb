class Util
  def self.==(x, y)
    tolerance = 0.00001
      (x - y).abs < tolerance
  end
end
