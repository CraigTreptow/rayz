module Rayz
  def self.lighting(material, light, point, eyev, normalv, intensity = 1.0, object = nil)
    # Determine the color at this point (either from pattern or material color)
    color = if material.pattern && object
      material.pattern.pattern_at_shape(object, point)
    else
      material.color
    end

    # Combine the surface color with the light's color/intensity
    effective_color = color * light.intensity

    # Compute the ambient contribution
    ambient = effective_color * material.ambient

    # If fully shadowed (intensity = 0), return only ambient
    return ambient if intensity == 0.0

    # Determine light direction
    # For area lights, use the center point; for point lights, use position
    if light.respond_to?(:corner)
      # Area light - use center
      light_center = light.corner + light.uvec * (light.usteps / 2.0) + light.vvec * (light.vsteps / 2.0)
      lightv = (light_center - point).normalize
    else
      # Point light - use position
      lightv = (light.position - point).normalize
    end

    # light_dot_normal represents the cosine of the angle between the
    # light vector and the normal vector. A negative number means the
    # light is on the other side of the surface.
    light_dot_normal = lightv.dot(normalv)

    if light_dot_normal < 0
      # Light is on the other side of the surface
      diffuse = Color.new(red: 0, green: 0, blue: 0)
      specular = Color.new(red: 0, green: 0, blue: 0)
    else
      # Compute the diffuse contribution (scaled by intensity for soft shadows)
      diffuse = effective_color * material.diffuse * light_dot_normal * intensity

      # reflect_dot_eye represents the cosine of the angle between the
      # reflection vector and the eye vector. A negative number means the
      # light reflects away from the eye.
      reflectv = (-lightv).reflect(normalv)
      reflect_dot_eye = reflectv.dot(eyev)

      if reflect_dot_eye <= 0
        # Light reflects away from the eye
        specular = Color.new(red: 0, green: 0, blue: 0)
      else
        # Compute the specular contribution (scaled by intensity for soft shadows)
        factor = reflect_dot_eye**material.shininess
        specular = light.intensity * material.specular * factor * intensity
      end
    end

    # Add the three contributions together to get the final shading
    ambient + diffuse + specular
  end
end
