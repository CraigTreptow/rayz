module Rayz
  class World
    attr_accessor :objects, :light

    def initialize
      @objects = []
      @light = nil
    end

    def self.default_world
      w = World.new
      w.light = PointLight.new(Point.new(x: -10, y: 10, z: -10), Color.new(red: 1, green: 1, blue: 1))

      s1 = Sphere.new
      s1.material.color = Color.new(red: 0.8, green: 1.0, blue: 0.6)
      s1.material.diffuse = 0.7
      s1.material.specular = 0.2

      s2 = Sphere.new
      s2.transform = Transformations.scaling(0.5, 0.5, 0.5)

      w.objects << s1
      w.objects << s2

      w
    end

    def intersect(ray)
      all_intersections = []
      @objects.each do |obj|
        all_intersections.concat(obj.intersect(ray))
      end
      all_intersections.sort_by(&:t)
    end

    def shade_hit(comps)
      shadowed = is_shadowed?(comps.over_point)
      Rayz.lighting(
        comps.object.material,
        @light,
        comps.point,
        comps.eyev,
        comps.normalv,
        shadowed,
        comps.object
      )
    end

    def color_at(ray)
      intersections = intersect(ray)
      hit = Rayz.hit(intersections)
      return Color.new(red: 0, green: 0, blue: 0) unless hit

      comps = hit.prepare_computations(ray)
      shade_hit(comps)
    end

    def is_shadowed?(point)
      return false unless @light

      v = @light.position - point
      distance = v.magnitude
      direction = v.normalize

      r = Ray.new(point, direction)
      intersections = intersect(r)
      h = Rayz.hit(intersections)

      !!(h && h.t < distance)
    end
  end
end
