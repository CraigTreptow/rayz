# rayz - a ray tracer based on "The Ray Tracer Challenge" by Jamis Buck
from rayz.canvas import Canvas
from rayz.color import Color
from rayz.constants import EPSILON
from rayz.environment import Environment
from rayz.intersection import Intersection, hit, intersect, intersections
from rayz.material import Material
from rayz.matrix import Matrix
from rayz.projectile import Projectile
from rayz.ray import Ray
from rayz.sphere import Sphere, glass_sphere
from rayz.tuple import Point, Tuple, Vector

__all__ = [
    "Canvas",
    "Color",
    "EPSILON",
    "Environment",
    "Intersection",
    "Material",
    "Matrix",
    "Point",
    "Projectile",
    "Ray",
    "Sphere",
    "Tuple",
    "Vector",
    "glass_sphere",
    "hit",
    "intersect",
    "intersections",
]
