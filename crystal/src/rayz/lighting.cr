module Rayz
  def self.lighting(material : Material, light : PointLight, point : Point, eyev : Tuple, normalv : Tuple, in_shadow : Bool = false, shape : Shape? = nil) : Color
    base_color = if p = material.pattern
                   if s = shape
                     p.pattern_at_shape(s.transform_inverse, point)
                   else
                     material.color
                   end
                 else
                   material.color
                 end
    effective_color = base_color * light.intensity
    ambient = effective_color * material.ambient
    return ambient if in_shadow

    lightv = (light.position - point).normalize
    light_dot_normal = lightv.dot(normalv)

    if light_dot_normal < 0.0
      diffuse = Color.new(0, 0, 0)
      specular = Color.new(0, 0, 0)
    else
      diffuse = effective_color * material.diffuse * light_dot_normal
      reflectv = (-lightv).reflect(normalv)
      reflect_dot_eye = reflectv.dot(eyev)
      if reflect_dot_eye <= 0.0
        specular = Color.new(0, 0, 0)
      else
        factor = reflect_dot_eye ** material.shininess
        specular = light.intensity * material.specular * factor
      end
    end

    ambient + diffuse + specular
  end
end
