# python/rayz/normal_perturbations.py
from __future__ import annotations

import math
from functools import partial
from typing import Callable

from rayz.tuple import Point, Vector

# These presets return `functools.partial(_module_level_fn, ...)` rather than
# a closure. A closure's inner function isn't picklable (pickle resolves
# functions by qualified module path, and a nested function has none), which
# crashes `Camera.render_parallel`'s `ProcessPoolExecutor` on any material
# using one of these. `partial` bound to a module-level function pickles fine.


def _sine_wave_perturb(frequency: float, amplitude: float, point: Point) -> Vector:
    return Vector(
        math.sin(point.y * frequency) * amplitude,
        math.sin(point.z * frequency) * amplitude,
        math.sin(point.x * frequency) * amplitude,
    )


def sine_wave(frequency: float = 10.0, amplitude: float = 0.1) -> Callable[[Point], Vector]:
    return partial(_sine_wave_perturb, frequency, amplitude)


def _quilted_perturb(frequency: float, amplitude: float, point: Point) -> Vector:
    u = math.sin(point.x * frequency)
    v = math.sin(point.z * frequency)
    magnitude = u * v * amplitude
    return Vector(0, magnitude, 0)


def quilted(frequency: float = 5.0, amplitude: float = 0.15) -> Callable[[Point], Vector]:
    return partial(_quilted_perturb, frequency, amplitude)


def _noise_perturb(frequency: float, amplitude: float, point: Point) -> Vector:
    nx = math.sin(point.x * frequency + point.y * frequency * 0.7) * amplitude
    ny = math.sin(point.y * frequency + point.z * frequency * 0.7) * amplitude
    nz = math.sin(point.z * frequency + point.x * frequency * 0.7) * amplitude
    return Vector(nx, ny, nz)


def noise(frequency: float = 5.0, amplitude: float = 0.1) -> Callable[[Point], Vector]:
    return partial(_noise_perturb, frequency, amplitude)


def _ripples_perturb(cx: float, cz: float, frequency: float, amplitude: float, point: Point) -> Vector:
    dx = point.x - cx
    dz = point.z - cz
    distance = math.sqrt(dx * dx + dz * dz)
    magnitude = math.sin(distance * frequency) * amplitude
    return Vector(0, magnitude, 0)


def ripples(
    center: Point | None = None,
    frequency: float = 10.0,
    amplitude: float = 0.1,
) -> Callable[[Point], Vector]:
    if center is None:
        center = Point(0, 0, 0)
    return partial(_ripples_perturb, center.x, center.z, frequency, amplitude)
