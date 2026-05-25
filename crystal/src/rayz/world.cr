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

    def shade_hit(comps : Computations, remaining : Int32 = 3) : Color
      l = @light
      return Color.new(0.0, 0.0, 0.0) unless l
      shadowed = is_shadowed?(comps.over_point)
      surface = Rayz.lighting(comps.object.material, l, comps.point, comps.eyev, comps.normalv, shadowed, comps.object)

      reflected = reflected_color(comps, remaining)
      refracted = refracted_color(comps, remaining)

      material = comps.object.material
      if material.reflective > 0.0 && material.transparency > 0.0
        reflectance = Rayz.schlick(comps)
        surface + reflected * reflectance + refracted * (1.0 - reflectance)
      else
        surface + reflected + refracted
      end
    end

    def color_at(ray : Ray, remaining : Int32 = 3) : Color
      xs = intersect(ray)
      hit = Rayz.hit(xs)
      return Color.new(0.0, 0.0, 0.0) unless hit
      comps = hit.prepare_computations(ray, xs)
      shade_hit(comps, remaining)
    end

    def reflected_color(comps : Computations, remaining : Int32 = 3) : Color
      return Color.new(0.0, 0.0, 0.0) if remaining <= 0
      return Color.new(0.0, 0.0, 0.0) if comps.object.material.reflective == 0.0

      reflect_ray = Ray.new(comps.over_point, comps.reflectv)
      color = color_at(reflect_ray, remaining - 1)
      color * comps.object.material.reflective
    end

    def refracted_color(comps : Computations, remaining : Int32 = 3) : Color
      return Color.new(0.0, 0.0, 0.0) if remaining <= 0
      return Color.new(0.0, 0.0, 0.0) if comps.object.material.transparency == 0.0

      n_ratio = comps.n1 / comps.n2
      cos_i = comps.eyev.dot(comps.normalv)
      sin2_t = n_ratio * n_ratio * (1.0 - cos_i * cos_i)

      return Color.new(0.0, 0.0, 0.0) if sin2_t > 1.0

      cos_t = Math.sqrt(1.0 - sin2_t)
      dir_t = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio
      direction = Vector.new(dir_t.x, dir_t.y, dir_t.z)

      refract_ray = Ray.new(comps.under_point, direction)
      color_at(refract_ray, remaining - 1) * comps.object.material.transparency
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
