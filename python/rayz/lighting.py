# python/rayz/lighting.py
from __future__ import annotations

from rayz.color import Color


def lighting(material, light, point, eyev, normalv, intensity=1.0, obj=None) -> Color:
    # Backward compat: accept bool from legacy callers (True=shadowed=0.0)
    if isinstance(intensity, bool):
        intensity = 0.0 if intensity else 1.0

    if material.pattern is not None:
        if obj is not None:
            color = material.pattern.pattern_at_shape(obj, point)
        else:
            color = material.pattern.pattern_at(point)
    else:
        color = material.color

    effective_color = color * light.intensity
    ambient = effective_color * material.ambient

    if intensity == 0.0:
        return ambient

    # Direction to light — area lights use their center point
    if hasattr(light, "corner"):
        light_center = light.corner + light.uvec * (light.usteps / 2.0) + light.vvec * (light.vsteps / 2.0)
        lightv = (light_center - point).normalize()
    else:
        lightv = (light.position - point).normalize()

    light_dot_normal = lightv.dot(normalv)

    if light_dot_normal < 0:
        return ambient

    diffuse = effective_color * material.diffuse * light_dot_normal * intensity

    reflectv = (-lightv).reflect(normalv)
    reflect_dot_eye = reflectv.dot(eyev)

    if reflect_dot_eye <= 0:
        return ambient + diffuse

    factor = reflect_dot_eye**material.shininess
    specular = light.intensity * material.specular * factor * intensity
    return ambient + diffuse + specular
