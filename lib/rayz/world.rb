module Rayz
  class World
    attr_accessor :objects, :light

    def initialize
      @objects = []
      @light = nil
    end

    def self.default_world
      w = World.new
      w.light = PointLight.new(position: Point.new(x: -10, y: 10, z: -10), intensity: Color.new(red: 1, green: 1, blue: 1))

      s1 = Sphere.new
      s1.material.color = Color.new(red: 0.8, green: 1.0, blue: 0.6)
      s1.material.diffuse = 0.7
      s1.material.specular = 0.2

      s2 = Sphere.new
      s2.transform = Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)

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

    def reflected_color(comps, remaining = 5)
      return Color.new(red: 0, green: 0, blue: 0) if remaining <= 0
      return Color.new(red: 0, green: 0, blue: 0) if comps.object.material.reflective == 0

      reflect_ray = Ray.new(origin: comps.over_point, direction: comps.reflectv)
      color = color_at(reflect_ray, remaining - 1)

      color * comps.object.material.reflective
    end

    def refracted_color(comps, remaining = 5)
      return Color.new(red: 0, green: 0, blue: 0) if remaining <= 0
      return Color.new(red: 0, green: 0, blue: 0) if comps.object.material.transparency == 0

      # Check for total internal reflection
      n_ratio = comps.n1 / comps.n2
      cos_i = comps.eyev.dot(comps.normalv)
      sin2_t = n_ratio * n_ratio * (1 - cos_i * cos_i)

      return Color.new(red: 0, green: 0, blue: 0) if sin2_t > 1.0

      # Compute refracted ray direction
      cos_t = Math.sqrt(1.0 - sin2_t)
      direction = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio

      # Create and trace refracted ray
      refract_ray = Ray.new(origin: comps.under_point, direction: direction)
      color_at(refract_ray, remaining - 1) * comps.object.material.transparency
    end

    def shade_hit(comps, remaining = 5)
      shadowed = is_shadowed?(comps.over_point)
      surface = Rayz.lighting(
        comps.object.material,
        @light,
        comps.point,
        comps.eyev,
        comps.normalv,
        shadowed,
        comps.object
      )

      reflected = reflected_color(comps, remaining)
      refracted = refracted_color(comps, remaining)

      material = comps.object.material
      if material.reflective > 0 && material.transparency > 0
        reflectance = Rayz.schlick(comps)
        surface + reflected * reflectance + refracted * (1 - reflectance)
      else
        surface + reflected + refracted
      end
    end

    def color_at(ray, remaining = 5)
      intersections = intersect(ray)
      hit = Rayz.hit(intersections)
      return Color.new(red: 0, green: 0, blue: 0) unless hit

      comps = hit.prepare_computations(ray, intersections)
      shade_hit(comps, remaining)
    end

    def is_shadowed?(point)
      return false unless @light

      v = @light.position - point
      distance = v.magnitude
      direction = v.normalize

      r = Ray.new(origin: point, direction: direction)
      intersections = intersect(r)
      h = Rayz.hit(intersections)

      !!(h && h.t < distance)
    end
  end
end
