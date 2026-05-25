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

    def prepare_computations(ray : Ray) : Computations
      point_t = ray.position(@t)
      point = Point.new(point_t.x, point_t.y, point_t.z)

      neg_dir = -ray.direction
      eyev = Vector.new(neg_dir.x, neg_dir.y, neg_dir.z)

      normalv = @object.normal_at(point)
      inside = normalv.dot(eyev) < 0

      if inside
        neg = -normalv
        normalv = Vector.new(neg.x, neg.y, neg.z)
      end

      offset = normalv * Util::EPSILON
      over_point_t = point + offset
      over_point = Point.new(over_point_t.x, over_point_t.y, over_point_t.z)

      Computations.new(@t, @object, point, eyev, normalv, inside, over_point)
    end
  end

  def self.intersections(*xs : Intersection) : Array(Intersection)
    xs.to_a.sort
  end

  def self.hit(xs : Array(Intersection)) : Intersection?
    xs.select { |i| i.t >= 0.0 }.min?
  end
end
