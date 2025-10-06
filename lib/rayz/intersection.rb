module Rayz
  class Computations
    attr_accessor :t, :object, :point, :eyev, :normalv, :inside, :over_point

    def initialize(t:, object:, point:, eyev:, normalv:, inside:, over_point:)
      @t = t
      @object = object
      @point = point
      @eyev = eyev
      @normalv = normalv
      @inside = inside
      @over_point = over_point
    end
  end

  class Intersection
    attr_reader :t, :object

    def initialize(t:, object:)
      @t = t
      @object = object
    end

    def <=>(other)
      @t <=> other.t
    end

    def prepare_computations(ray)
      point = ray.position(@t)
      eyev = -ray.direction
      normalv = @object.normal_at(point)

      inside = false
      if normalv.dot(eyev) < 0
        inside = true
        normalv = -normalv
      end

      over_point = point + normalv * Util::EPSILON

      Computations.new(t: @t, object: @object, point: point, eyev: eyev, normalv: normalv, inside: inside, over_point: over_point)
    end
  end

  def self.intersections(*intersections)
    intersections.sort
  end

  def self.hit(intersections)
    intersections.select { |i| i.t >= 0 }.min
  end
end
