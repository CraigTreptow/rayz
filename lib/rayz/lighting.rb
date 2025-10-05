module Rayz
  def self.lighting(material, light, point, eyev, normalv, in_shadow = false)
    # Combine the surface color with the light's color/intensity
    effective_color = material.color * light.intensity

    # Find the direction to the light source
    lightv = (light.position - point).normalize

    # Compute the ambient contribution
    ambient = effective_color * material.ambient

    # If in shadow, return only ambient
    return ambient if in_shadow

    # light_dot_normal represents the cosine of the angle between the
    # light vector and the normal vector. A negative number means the
    # light is on the other side of the surface.
    light_dot_normal = lightv.dot(normalv)

    if light_dot_normal < 0
      # Light is on the other side of the surface
      diffuse = Color.new(red: 0, green: 0, blue: 0)
      specular = Color.new(red: 0, green: 0, blue: 0)
    else
      # Compute the diffuse contribution
      diffuse = effective_color * material.diffuse * light_dot_normal

      # reflect_dot_eye represents the cosine of the angle between the
      # reflection vector and the eye vector. A negative number means the
      # light reflects away from the eye.
      reflectv = (-lightv).reflect(normalv)
      reflect_dot_eye = reflectv.dot(eyev)

      if reflect_dot_eye <= 0
        # Light reflects away from the eye
        specular = Color.new(red: 0, green: 0, blue: 0)
      else
        # Compute the specular contribution
        factor = reflect_dot_eye**material.shininess
        specular = light.intensity * material.specular * factor
      end
    end

    # Add the three contributions together to get the final shading
    ambient + diffuse + specular
  end
end
