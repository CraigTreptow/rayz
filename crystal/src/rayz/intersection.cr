module Rayz
  class Intersection
    include Comparable(Intersection)

    getter t : Float64
    getter object : Shape

    def initialize(t : Float64 | Int32, object : Shape)
      @t = t.to_f
      @object = object
    end

    def <=>(other : Intersection) : Int32
      (@t <=> other.t) || 0
    end
  end

  def self.intersections(*xs : Intersection) : Array(Intersection)
    xs.to_a.sort
  end

  def self.hit(xs : Array(Intersection)) : Intersection?
    xs.select { |i| i.t >= 0.0 }.min?
  end
end
