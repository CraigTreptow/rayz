module Rayz
  class Intersection
    attr_reader :t, :object

    def initialize(t, object)
      @t = t
      @object = object
    end

    def <=>(other)
      @t <=> other.t
    end
  end

  def self.intersections(*intersections)
    intersections.sort
  end

  def self.hit(intersections)
    intersections.select { |i| i.t >= 0 }.min
  end
end
