module Rayz
  class Computations
    attr_accessor :t, :object, :point, :eyev, :normalv, :inside, :over_point, :reflectv, :n1, :n2, :under_point

    def initialize(t:, object:, point:, eyev:, normalv:, inside:, over_point:, reflectv: nil, n1: nil, n2: nil, under_point: nil)
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

  class Intersection
    attr_reader :t, :object

    def initialize(t:, object:)
      @t = t
      @object = object
    end

    def <=>(other)
      @t <=> other.t
    end

    def prepare_computations(ray, xs = nil)
      point = ray.position(@t)
      eyev = -ray.direction
      normalv = @object.normal_at(point)

      inside = false
      if normalv.dot(eyev) < 0
        inside = true
        normalv = -normalv
      end

      over_point = point + normalv * Util::EPSILON
      under_point = point - normalv * Util::EPSILON
      reflectv = ray.direction.reflect(normalv)

      # Compute n1 and n2 for refraction
      n1 = 1.0
      n2 = 1.0

      if xs
        containers = []

        xs.each do |i|
          if i == self
            n1 = containers.empty? ? 1.0 : containers.last.material.refractive_index
          end

          if containers.include?(i.object)
            containers.delete(i.object)
          else
            containers << i.object
          end

          if i == self
            n2 = containers.empty? ? 1.0 : containers.last.material.refractive_index
            break
          end
        end
      end

      Computations.new(
        t: @t,
        object: @object,
        point: point,
        eyev: eyev,
        normalv: normalv,
        inside: inside,
        over_point: over_point,
        reflectv: reflectv,
        n1: n1,
        n2: n2,
        under_point: under_point
      )
    end
  end

  def self.intersections(*intersections)
    intersections.sort
  end

  def self.hit(intersections)
    intersections.select { |i| i.t >= 0 }.min
  end

  def self.schlick(comps)
    # Find cosine of angle between eye and normal vectors
    cos = comps.eyev.dot(comps.normalv)

    # Total internal reflection can only occur if n1 > n2
    if comps.n1 > comps.n2
      n = comps.n1 / comps.n2
      sin2_t = n * n * (1.0 - cos * cos)
      return 1.0 if sin2_t > 1.0

      # Compute cosine of theta_t using trig identity
      cos_t = Math.sqrt(1.0 - sin2_t)

      # When n1 > n2, use cos(theta_t) instead
      cos = cos_t
    end

    r0 = ((comps.n1 - comps.n2) / (comps.n1 + comps.n2))**2
    r0 + (1 - r0) * (1 - cos)**5
  end
end
