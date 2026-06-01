# python/rayz/normal_perturbations.py
from __future__ import annotations

import math
from typing import Callable

from rayz.tuple import Point, Vector


def sine_wave(frequency: float = 10.0, amplitude: float = 0.1) -> Callable[[Point], Vector]:
    def perturb(point: Point) -> Vector:
        return Vector(
            math.sin(point.y * frequency) * amplitude,
            math.sin(point.z * frequency) * amplitude,
            math.sin(point.x * frequency) * amplitude,
        )

    return perturb


def quilted(frequency: float = 5.0, amplitude: float = 0.15) -> Callable[[Point], Vector]:
    def perturb(point: Point) -> Vector:
        u = math.sin(point.x * frequency)
        v = math.sin(point.z * frequency)
        magnitude = u * v * amplitude
        return Vector(0, magnitude, 0)

    return perturb


def noise(frequency: float = 5.0, amplitude: float = 0.1) -> Callable[[Point], Vector]:
    def perturb(point: Point) -> Vector:
        nx = math.sin(point.x * frequency + point.y * frequency * 0.7) * amplitude
        ny = math.sin(point.y * frequency + point.z * frequency * 0.7) * amplitude
        nz = math.sin(point.z * frequency + point.x * frequency * 0.7) * amplitude
        return Vector(nx, ny, nz)

    return perturb


def ripples(
    center: Point | None = None,
    frequency: float = 10.0,
    amplitude: float = 0.1,
) -> Callable[[Point], Vector]:
    if center is None:
        center = Point(0, 0, 0)
    cx, cz = center.x, center.z

    def perturb(point: Point) -> Vector:
        dx = point.x - cx
        dz = point.z - cz
        distance = math.sqrt(dx * dx + dz * dz)
        magnitude = math.sin(distance * frequency) * amplitude
        return Vector(0, magnitude, 0)

    return perturb
