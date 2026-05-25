module Rayz
  class Intersection
    include Comparable(Intersection)

    getter t : Float64
    getter object : Shape
    getter u : Float64?
    getter v : Float64?

    def initialize(t : Float64 | Int32, object : Shape, u : Float64? = nil, v : Float64? = nil)
      @t = t.to_f
      @object = object
      @u = u
      @v = v
    end

    def <=>(other : Intersection) : Int32
      (@t <=> other.t) || 0
    end

    def prepare_computations(ray : Ray, xs : Array(Intersection) = [] of Intersection) : Computations
      point_t = ray.position(@t)
      point = Point.new(point_t.x, point_t.y, point_t.z)

      neg_dir = -ray.direction
      eyev = Vector.new(neg_dir.x, neg_dir.y, neg_dir.z)

      normalv = @object.normal_at(point, self)
      inside = normalv.dot(eyev) < 0

      if inside
        neg = -normalv
        normalv = Vector.new(neg.x, neg.y, neg.z)
      end

      reflectv = ray.direction.reflect(normalv)

      offset = normalv * Util::EPSILON
      over_point_t = point + offset
      over_point = Point.new(over_point_t.x, over_point_t.y, over_point_t.z)

      under_offset = normalv * Util::EPSILON
      under_point_t = point - under_offset
      under_point = Point.new(under_point_t.x, under_point_t.y, under_point_t.z)

      n1 = 1.0
      n2 = 1.0
      containers = [] of Shape

      xs.each do |i|
        if i.same?(self)
          n1 = containers.empty? ? 1.0 : containers.last.material.refractive_index
        end

        if containers.includes?(i.object)
          containers.delete(i.object)
        else
          containers << i.object
        end

        if i.same?(self)
          n2 = containers.empty? ? 1.0 : containers.last.material.refractive_index
          break
        end
      end

      Computations.new(@t, @object, point, eyev, normalv, inside, over_point, reflectv, n1, n2, under_point)
    end
  end

  def self.intersections(*xs : Intersection) : Array(Intersection)
    xs.to_a.sort
  end

  def self.hit(xs : Array(Intersection)) : Intersection?
    xs.select { |i| i.t >= 0.0 }.min?
  end

  def self.schlick(comps : Computations) : Float64
    cos = comps.eyev.dot(comps.normalv)

    if comps.n1 > comps.n2
      n = comps.n1 / comps.n2
      sin2_t = n * n * (1.0 - cos * cos)
      return 1.0 if sin2_t > 1.0
      cos_t = Math.sqrt(1.0 - sin2_t)
      cos = cos_t
    end

    r0 = ((comps.n1 - comps.n2) / (comps.n1 + comps.n2)) ** 2
    r0 + (1.0 - r0) * (1.0 - cos) ** 5
  end
end
