from __future__ import annotations

from rayz.color import Color


def lighting(material, light, point, eyev, normalv, in_shadow=False, obj=None) -> Color:
    if material.pattern is not None:
        if obj is not None:
            color = material.pattern.pattern_at_shape(obj, point)
        else:
            color = material.pattern.pattern_at(point)
    else:
        color = material.color

    effective_color = color * light.intensity
    ambient = effective_color * material.ambient

    if in_shadow:
        return ambient

    lightv = (light.position - point).normalize()
    light_dot_normal = lightv.dot(normalv)

    if light_dot_normal < 0:
        return ambient

    diffuse = effective_color * material.diffuse * light_dot_normal

    reflectv = (-lightv).reflect(normalv)
    reflect_dot_eye = reflectv.dot(eyev)

    if reflect_dot_eye <= 0:
        return ambient + diffuse

    factor = reflect_dot_eye**material.shininess
    specular = light.intensity * material.specular * factor
    return ambient + diffuse + specular
