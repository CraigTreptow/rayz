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
        self.light: PointLight | None = None

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
            xs.extend(intersect(obj, ray))
        return sorted(xs, key=lambda i: i.t)

    def is_shadowed(self, point) -> bool:
        if self.light is None:
            return False
        v = self.light.position - point
        distance = v.magnitude()
        direction = v.normalize()
        from rayz.ray import Ray

        shadow_ray = Ray(point, direction)
        xs = self.intersect_world(shadow_ray)
        h = hit(xs)
        return h is not None and h.t < distance

    def reflected_color(self, comps, remaining: int = 3) -> Color:
        if remaining <= 0 or comps.object.material.reflective == 0:
            return Color(0, 0, 0)
        from rayz.ray import Ray

        reflect_ray = Ray(comps.over_point, comps.reflectv)
        color = self.color_at(reflect_ray, remaining - 1)
        return color * comps.object.material.reflective

    def shade_hit(self, comps, remaining: int = 3) -> Color:
        shadowed = self.is_shadowed(comps.over_point)
        surface = lighting(
            comps.object.material,
            self.light,
            comps.point,
            comps.eyev,
            comps.normalv,
            shadowed,
            comps.object,
        )
        reflected = self.reflected_color(comps, remaining)
        return surface + reflected

    def color_at(self, ray, remaining: int = 3) -> Color:
        xs = self.intersect_world(ray)
        h = hit(xs)
        if h is None:
            return Color(0, 0, 0)
        comps = prepare_computations(h, ray, xs)
        return self.shade_hit(comps, remaining)


def default_world() -> World:
    return World.default_world()
