# python/rayz/world.py
from __future__ import annotations

from rayz.color import Color
from rayz.intersection import hit, intersect, prepare_computations
from rayz.lighting import lighting
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import scaling
from rayz.tuple import Point


class World:
    def __init__(self) -> None:
        self.objects: list = []
        self.light = None

    @classmethod
    def default_world(cls) -> World:
        w = cls()
        w.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))
        s1 = Sphere()
        s1.material.color = Color(0.8, 1.0, 0.6)
        s1.material.diffuse = 0.7
        s1.material.specular = 0.2
        s2 = Sphere()
        s2.set_transform(scaling(0.5, 0.5, 0.5))
        w.objects = [s1, s2]
        return w

    def intersect_world(self, ray) -> list:
        xs = []
        for obj in self.objects:
            xs.extend(obj.intersect(ray))
        return sorted(xs, key=lambda i: i.t)

    def is_shadowed_from(self, point, light_position) -> bool:
        from rayz.ray import Ray
        v = light_position - point
        distance = v.magnitude()
        direction = v.normalize()
        shadow_ray = Ray(point, direction)
        for obj in self.objects:
            for i in obj.intersect(shadow_ray):
                if 0 < i.t < distance:
                    return True
        return False

    def is_shadowed(self, point) -> bool:
        if self.light is None:
            return False
        if isinstance(self.light, PointLight):
            return self.is_shadowed_from(point, self.light.position)
        if hasattr(self.light, "intensity_at"):
            return self.light.intensity_at(point, self) < 1.0
        return False

    def reflected_color(self, comps, remaining: int = 3) -> Color:
        if remaining <= 0 or comps.object.material.reflective == 0:
            return Color(0, 0, 0)
        from rayz.ray import Ray
        reflect_ray = Ray(comps.over_point, comps.reflectv)
        return self.color_at(reflect_ray, remaining - 1) * comps.object.material.reflective

    def refracted_color(self, comps, remaining: int = 3) -> Color:
        if remaining <= 0 or comps.object.material.transparency == 0:
            return Color(0, 0, 0)
        import math
        n_ratio = comps.n1 / comps.n2
        cos_i = comps.eyev.dot(comps.normalv)
        sin2_t = n_ratio * n_ratio * (1 - cos_i * cos_i)
        if sin2_t > 1.0:
            return Color(0, 0, 0)
        cos_t = math.sqrt(1.0 - sin2_t)
        direction = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio
        from rayz.ray import Ray
        refract_ray = Ray(comps.under_point, direction)
        return self.color_at(refract_ray, remaining - 1) * comps.object.material.transparency

    def shade_hit(self, comps, remaining: int = 3) -> Color:
        if self.light is None:
            intensity = 0.0
        elif isinstance(self.light, PointLight):
            intensity = 0.0 if self.is_shadowed_from(comps.over_point, self.light.position) else 1.0
        elif hasattr(self.light, "intensity_at"):
            intensity = self.light.intensity_at(comps.over_point, self)
        else:
            intensity = 1.0

        surface = lighting(
            comps.object.material,
            self.light,
            comps.point,
            comps.eyev,
            comps.normalv,
            intensity,
            comps.object,
        )
        reflected = self.reflected_color(comps, remaining)
        refracted = self.refracted_color(comps, remaining)
        mat = comps.object.material
        if mat.reflective > 0 and mat.transparency > 0:
            reflectance = schlick(comps)
            return surface + reflected * reflectance + refracted * (1 - reflectance)
        return surface + reflected + refracted

    def color_at(self, ray, remaining: int = 3) -> Color:
        xs = self.intersect_world(ray)
        h = hit(xs)
        if h is None:
            return Color(0, 0, 0)
        comps = prepare_computations(h, ray, xs)
        return self.shade_hit(comps, remaining)


def default_world() -> World:
    return World.default_world()


def schlick(comps) -> float:
    import math
    cos = comps.eyev.dot(comps.normalv)
    if comps.n1 > comps.n2:
        n = comps.n1 / comps.n2
        sin2_t = n * n * (1.0 - cos * cos)
        if sin2_t > 1.0:
            return 1.0
        cos = math.sqrt(1.0 - sin2_t)
    r0 = ((comps.n1 - comps.n2) / (comps.n1 + comps.n2)) ** 2
    return r0 + (1 - r0) * (1 - cos) ** 5
