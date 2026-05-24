module Rayz
  class Computations
    getter t : Float64
    getter object : Shape
    getter point : Point
    getter eyev : Vector
    getter normalv : Vector
    getter inside : Bool
    getter over_point : Point

    def initialize(t : Float64, object : Shape, point : Point, eyev : Vector, normalv : Vector, inside : Bool, over_point : Point)
      @t = t
      @object = object
      @point = point
      @eyev = eyev
      @normalv = normalv
      @inside = inside
      @over_point = over_point
    end
  end
end
