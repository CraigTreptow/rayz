module Rayz
  class PointLight
    attr_reader :position, :intensity

    def initialize(position, intensity)
      @position = position
      @intensity = intensity
    end

    def ==(other)
      @position == other.position && @intensity == other.intensity
    end
  end
end
