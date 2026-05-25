module Rayz
  class Computations
    getter t : Float64
    getter object : Shape
    getter point : Point
    getter eyev : Vector
    getter normalv : Vector
    getter inside : Bool
    getter over_point : Point
    getter reflectv : Vector
    getter n1 : Float64
    getter n2 : Float64
    getter under_point : Point

    def initialize(t : Float64, object : Shape, point : Point, eyev : Vector, normalv : Vector,
                   inside : Bool, over_point : Point, reflectv : Vector,
                   n1 : Float64, n2 : Float64, under_point : Point)
      @t = t
      @object = object
      @point = point
      @eyev = eyev
      @normalv = normalv
      @inside = inside
      @over_point = over_point
      @reflectv = reflectv
      @n1 = n1
      @n2 = n2
      @under_point = under_point
    end
  end
end
