module Rayz
  class PointLight
    getter position : Point
    getter intensity : Color

    def initialize(position : Point, intensity : Color)
      @position = position
      @intensity = intensity
    end

    def ==(other : PointLight) : Bool
      @position == other.position && @intensity == other.intensity
    end
  end
end
