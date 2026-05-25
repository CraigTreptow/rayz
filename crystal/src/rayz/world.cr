module Rayz
  class World
    property objects : Array(Shape)
    property light : PointLight?

    def initialize
      @objects = [] of Shape
      @light = nil
    end

    def self.default_world : World
      w = World.new
      w.light = PointLight.new(
        Point.new(-10.0, 10.0, -10.0),
        Color.new(1.0, 1.0, 1.0)
      )

      s1 = Sphere.new
      s1.material.color = Color.new(0.8, 1.0, 0.6)
      s1.material.diffuse = 0.7
      s1.material.specular = 0.2

      s2 = Sphere.new
      s2.transform = Transformations.scaling(0.5, 0.5, 0.5)

      w.objects << s1
      w.objects << s2
      w
    end

    def intersect(ray : Ray) : Array(Intersection)
      all = [] of Intersection
      @objects.each { |obj| all.concat(obj.intersect(ray)) }
      all.sort
    end

    def shade_hit(comps : Computations) : Color
      l = @light
      return Color.new(0.0, 0.0, 0.0) unless l
      shadowed = is_shadowed?(comps.over_point)
      Rayz.lighting(comps.object.material, l, comps.point, comps.eyev, comps.normalv, shadowed, comps.object)
    end

    def color_at(ray : Ray) : Color
      xs = intersect(ray)
      hit = Rayz.hit(xs)
      return Color.new(0.0, 0.0, 0.0) unless hit
      comps = hit.prepare_computations(ray)
      shade_hit(comps)
    end

    def is_shadowed?(point : Point) : Bool
      l = @light
      return false unless l

      v = l.position - point
      distance = v.magnitude
      direction_t = v.normalize
      direction = Vector.new(direction_t.x, direction_t.y, direction_t.z)

      shadow_ray = Ray.new(point, direction)
      xs = intersect(shadow_ray)
      hit = Rayz.hit(xs)

      !hit.nil? && hit.t < distance
    end
  end
end
