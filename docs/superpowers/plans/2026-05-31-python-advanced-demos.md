# Python Advanced Demo Suite — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port 6 new library primitives plus camera/lighting/world extensions to bring Python's `rayz` to full Ruby feature parity, then add 3 demo scripts.

**Architecture:** Build in dependency order — foundation types first (Bounds, Ray.time), then shape/material infrastructure, then light types and rendering pipeline, finally demos. Existing test suite must stay green after every commit.

**Tech Stack:** Python 3.14, uv, behave (existing tests), Python `complex` builtin for Durand-Kerner quartic solver. All commands run from `python/` directory unless noted.

---

## File Map

**New files:**
- `python/rayz/bounds.py` — `Bounds` AABB class
- `python/rayz/torus.py` — `Torus(Shape)` with quartic intersection
- `python/rayz/normal_perturbations.py` — perturbation factory functions
- `python/rayz/area_light.py` — `AreaLight` with soft-shadow grid sampling
- `python/rayz/spotlight.py` — `Spotlight` with cone + fade
- `python/rayz/texture_map.py` — `PPMImage` + `TextureMap(Pattern)`
- `python/examples/advanced_features_demo.py`
- `python/examples/bounding_boxes_demo.py`
- `python/examples/nested_groups_demo.py`

**Modified files:**
- `python/rayz/ray.py` — add `time: float = 0.0`
- `python/rayz/material.py` — add `normal_perturbation` slot
- `python/rayz/shape.py` — `motion_transform`, `bounds()` abstract, perturbation hook
- `python/rayz/sphere.py`, `plane.py`, `cube.py`, `cylinder.py`, `cone.py`, `triangle.py`, `smooth_triangle.py`, `csg.py` — add `bounds()`
- `python/rayz/group.py` — add `bounds()` + AABB early-exit
- `python/rayz/lighting.py` — `in_shadow: bool` → `intensity: float`
- `python/rayz/world.py` — `is_shadowed_from()`, updated `shade_hit()`
- `python/rayz/camera.py` — AA, focal blur, motion blur
- `python/examples/run.py` — register demos 19/20/21, add string name lookup

---

### Task 1: `rayz/bounds.py` — AABB class

**Files:**
- Create: `python/rayz/bounds.py`

- [ ] **Step 1: Create `bounds.py`**

```python
# python/rayz/bounds.py
from __future__ import annotations

import math

from rayz.tuple import Point


class Bounds:
    def __init__(
        self,
        min: Point | None = None,
        max: Point | None = None,
    ) -> None:
        self.min = min if min is not None else Point(math.inf, math.inf, math.inf)
        self.max = max if max is not None else Point(-math.inf, -math.inf, -math.inf)

    def merge(self, other: Bounds) -> Bounds:
        return Bounds(
            Point(
                builtins_min(self.min.x, other.min.x),
                builtins_min(self.min.y, other.min.y),
                builtins_min(self.min.z, other.min.z),
            ),
            Point(
                builtins_max(self.max.x, other.max.x),
                builtins_max(self.max.y, other.max.y),
                builtins_max(self.max.z, other.max.z),
            ),
        )

    def transform(self, matrix) -> Bounds:
        corners = [
            Point(self.min.x, self.min.y, self.min.z),
            Point(self.min.x, self.min.y, self.max.z),
            Point(self.min.x, self.max.y, self.min.z),
            Point(self.min.x, self.max.y, self.max.z),
            Point(self.max.x, self.min.y, self.min.z),
            Point(self.max.x, self.min.y, self.max.z),
            Point(self.max.x, self.max.y, self.min.z),
            Point(self.max.x, self.max.y, self.max.z),
        ]
        transformed = [matrix * c for c in corners]
        return Bounds(
            Point(
                min(p.x for p in transformed),
                min(p.y for p in transformed),
                min(p.z for p in transformed),
            ),
            Point(
                max(p.x for p in transformed),
                max(p.y for p in transformed),
                max(p.z for p in transformed),
            ),
        )

    def intersects(self, ray) -> bool:
        xtmin, xtmax = self._check_axis(ray.origin.x, ray.direction.x, self.min.x, self.max.x)
        ytmin, ytmax = self._check_axis(ray.origin.y, ray.direction.y, self.min.y, self.max.y)
        ztmin, ztmax = self._check_axis(ray.origin.z, ray.direction.z, self.min.z, self.max.z)
        tmin = max(xtmin, ytmin, ztmin)
        tmax = min(xtmax, ytmax, ztmax)
        return tmin <= tmax

    def contains_point(self, point: Point) -> bool:
        return (
            self.min.x <= point.x <= self.max.x
            and self.min.y <= point.y <= self.max.y
            and self.min.z <= point.z <= self.max.z
        )

    def contains_bounds(self, other: Bounds) -> bool:
        return self.contains_point(other.min) and self.contains_point(other.max)

    def _check_axis(self, origin: float, direction: float, min_val: float, max_val: float):
        from rayz.constants import EPSILON
        if abs(direction) >= EPSILON:
            tmin = (min_val - origin) / direction
            tmax = (max_val - origin) / direction
        else:
            tmin = (min_val - origin) * math.inf
            tmax = (max_val - origin) * math.inf
        if tmin > tmax:
            tmin, tmax = tmax, tmin
        return tmin, tmax


# Avoid shadowing builtins inside the class methods
builtins_min = min
builtins_max = max
```

- [ ] **Step 2: Verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python -c "
from rayz.bounds import Bounds
from rayz.tuple import Point
b = Bounds(Point(-1,-1,-1), Point(1,1,1))
b2 = Bounds(Point(0,0,0), Point(2,2,2))
m = b.merge(b2)
assert m.min.x == -1 and m.max.x == 2, f'merge failed: {m.min} {m.max}'
from rayz.ray import Ray
from rayz.tuple import Vector
r = Ray(Point(0,0,-5), Vector(0,0,1))
assert b.intersects(r), 'should intersect'
r2 = Ray(Point(5,0,-5), Vector(0,0,1))
assert not b2.intersects(r2), 'should miss'
print('Bounds OK')
"
```

Expected: `Bounds OK`

- [ ] **Step 3: Commit**

```bash
git add python/rayz/bounds.py
git commit -m "feat(python): add Bounds AABB class"
```

---

### Task 2: `rayz/ray.py` — add `time` field

**Files:**
- Modify: `python/rayz/ray.py`

- [ ] **Step 1: Add `time` parameter**

Replace the current `__init__` and `transform`:

```python
# python/rayz/ray.py
from __future__ import annotations


class Ray:
    def __init__(self, origin, direction, time: float = 0.0) -> None:
        self.origin = origin
        self.direction = direction
        self.time = time

    def position(self, t: float):
        return self.origin + self.direction * t

    def transform(self, matrix) -> Ray:
        return Ray(matrix * self.origin, matrix * self.direction, time=self.time)
```

- [ ] **Step 2: Verify existing tests pass**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

Expected: all scenarios passing (same count as before).

- [ ] **Step 3: Commit**

```bash
git add python/rayz/ray.py
git commit -m "feat(python): add time field to Ray for motion blur"
```

---

### Task 3: `rayz/material.py` — add `normal_perturbation`

**Files:**
- Modify: `python/rayz/material.py`

- [ ] **Step 1: Add slot and initialise to None**

Add `"normal_perturbation"` to `__slots__` and `self.normal_perturbation = None` in `__init__`. The existing `__eq__` does NOT include `normal_perturbation` (matching Ruby behaviour).

```python
# python/rayz/material.py  (full file)
from __future__ import annotations

from rayz.color import Color
from rayz.constants import EPSILON


class Material:
    __slots__ = (
        "color",
        "ambient",
        "diffuse",
        "specular",
        "shininess",
        "reflective",
        "transparency",
        "refractive_index",
        "pattern",
        "normal_perturbation",
    )

    def __init__(
        self,
        color: Color | None = None,
        ambient: float = 0.1,
        diffuse: float = 0.9,
        specular: float = 0.9,
        shininess: float = 200.0,
        reflective: float = 0.0,
        transparency: float = 0.0,
        refractive_index: float = 1.0,
    ) -> None:
        self.color = color if color is not None else Color(1, 1, 1)
        self.ambient = ambient
        self.diffuse = diffuse
        self.specular = specular
        self.shininess = shininess
        self.reflective = reflective
        self.transparency = transparency
        self.refractive_index = refractive_index
        self.pattern = None
        self.normal_perturbation = None

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Material):
            return NotImplemented
        return (
            self.color == other.color
            and abs(self.ambient - other.ambient) < EPSILON
            and abs(self.diffuse - other.diffuse) < EPSILON
            and abs(self.specular - other.specular) < EPSILON
            and abs(self.shininess - other.shininess) < EPSILON
            and abs(self.reflective - other.reflective) < EPSILON
            and abs(self.transparency - other.transparency) < EPSILON
            and abs(self.refractive_index - other.refractive_index) < EPSILON
        )

    __hash__ = None  # type: ignore[assignment]

    def __repr__(self) -> str:
        return (
            f"Material(color={self.color!r}, ambient={self.ambient}, diffuse={self.diffuse}, "
            f"specular={self.specular}, shininess={self.shininess})"
        )
```

- [ ] **Step 2: Verify existing tests pass**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add python/rayz/material.py
git commit -m "feat(python): add normal_perturbation field to Material"
```

---

### Task 4: `rayz/normal_perturbations.py` — perturbation factories

**Files:**
- Create: `python/rayz/normal_perturbations.py`

- [ ] **Step 1: Create the module**

```python
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
```

- [ ] **Step 2: Verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python -c "
from rayz.normal_perturbations import sine_wave, quilted, noise, ripples
from rayz.tuple import Point
p = Point(1, 0.5, 0.3)
fn = sine_wave(frequency=10, amplitude=0.15)
v = fn(p)
assert hasattr(v, 'x') and hasattr(v, 'y'), 'should return Vector'
fn2 = quilted()
v2 = fn2(p)
assert v2.x == 0, 'quilted only perturbs Y'
print('NormalPerturbations OK')
"
```

Expected: `NormalPerturbations OK`

- [ ] **Step 3: Commit**

```bash
git add python/rayz/normal_perturbations.py
git commit -m "feat(python): add normal_perturbations module"
```

---

### Task 5: `rayz/torus.py` — Torus shape

**Files:**
- Create: `python/rayz/torus.py`

- [ ] **Step 1: Create the file**

```python
# python/rayz/torus.py
from __future__ import annotations

import math

from rayz.bounds import Bounds
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Point, Vector


class Torus(Shape):
    def __init__(self, major_radius: float = 1.0, minor_radius: float = 0.25) -> None:
        super().__init__()
        self.major_radius = major_radius
        self.minor_radius = minor_radius

    def local_intersect(self, ray) -> list:
        ox, oy, oz = ray.origin.x, ray.origin.y, ray.origin.z
        dx, dy, dz = ray.direction.x, ray.direction.y, ray.direction.z

        R, r = self.major_radius, self.minor_radius
        sum_d_sq = dx * dx + dy * dy + dz * dz
        e = ox * ox + oy * oy + oz * oz - R * R - r * r
        f = ox * dx + oy * dy + oz * dz
        four_R_sq = 4.0 * R * R

        a = sum_d_sq * sum_d_sq
        b = 4.0 * sum_d_sq * f
        c = 2.0 * sum_d_sq * e + 4.0 * f * f + four_R_sq * (dz * dz)
        d = 4.0 * f * e + 2.0 * four_R_sq * oz * dz
        e_coef = e * e - four_R_sq * (r * r - oz * oz)

        roots = self._solve_quartic(a, b, c, d, e_coef)
        return [Intersection(t, self) for t in roots if t > 0]

    def local_normal_at(self, local_point, hit=None) -> Vector:
        x, y, z = local_point.x, local_point.y, local_point.z
        dist = math.sqrt(x * x + z * z)
        if dist > 0:
            mx = x * self.major_radius / dist
            mz = z * self.major_radius / dist
        else:
            mx, mz = self.major_radius, 0.0
        return Vector(x - mx, y, z - mz).normalize()

    def bounds(self) -> Bounds:
        extent = self.major_radius + self.minor_radius
        return Bounds(
            Point(-extent, -self.minor_radius, -extent),
            Point(extent, self.minor_radius, extent),
        )

    def _solve_quartic(self, a: float, b: float, c: float, d: float, e: float) -> list[float]:
        if a == 0:
            return []
        b /= a; c /= a; d /= a; e /= a

        z1 = complex(1, 1)
        z2 = complex(-1, 1)
        z3 = complex(-1, -1)
        z4 = complex(1, -1)

        tolerance = 1e-10
        for _ in range(100):
            p1 = z1**4 + b*z1**3 + c*z1**2 + d*z1 + e
            p2 = z2**4 + b*z2**3 + c*z2**2 + d*z2 + e
            p3 = z3**4 + b*z3**3 + c*z3**2 + d*z3 + e
            p4 = z4**4 + b*z4**3 + c*z4**2 + d*z4 + e
            nz1 = z1 - p1 / ((z1-z2) * (z1-z3) * (z1-z4))
            nz2 = z2 - p2 / ((z2-z1) * (z2-z3) * (z2-z4))
            nz3 = z3 - p3 / ((z3-z1) * (z3-z2) * (z3-z4))
            nz4 = z4 - p4 / ((z4-z1) * (z4-z2) * (z4-z3))
            if (abs(nz1-z1) < tolerance and abs(nz2-z2) < tolerance
                    and abs(nz3-z3) < tolerance and abs(nz4-z4) < tolerance):
                break
            z1, z2, z3, z4 = nz1, nz2, nz3, nz4

        return [z.real for z in (z1, z2, z3, z4) if abs(z.imag) < tolerance]
```

- [ ] **Step 2: Verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python -c "
from rayz.torus import Torus
from rayz.ray import Ray
from rayz.tuple import Point, Vector
t = Torus(major_radius=1.0, minor_radius=0.5)
# Ray through the hole — should intersect the tube twice
r = Ray(Point(0, 0, -3), Vector(0, 0, 1))
xs = t.intersect(r)
assert len(xs) == 2, f'expected 2 hits, got {len(xs)}'
b = t.bounds()
assert b.min.x == -1.5 and b.max.x == 1.5, f'wrong bounds: {b.min} {b.max}'
print('Torus OK')
"
```

Expected: `Torus OK`

- [ ] **Step 3: Commit**

```bash
git add python/rayz/torus.py
git commit -m "feat(python): add Torus shape with Durand-Kerner quartic solver"
```

---

### Task 6: `rayz/area_light.py` and `rayz/spotlight.py`

**Files:**
- Create: `python/rayz/area_light.py`
- Create: `python/rayz/spotlight.py`

- [ ] **Step 1: Create `area_light.py`**

```python
# python/rayz/area_light.py
from __future__ import annotations

from typing import Callable

from rayz.color import Color
from rayz.tuple import Point


class AreaLight:
    def __init__(
        self,
        corner: Point,
        full_uvec,
        full_vvec,
        usteps: int,
        vsteps: int,
        intensity: Color,
        jitter_by: Callable[[], float] | None = None,
    ) -> None:
        self.corner = corner
        self.usteps = usteps
        self.vsteps = vsteps
        self.samples = usteps * vsteps
        self.intensity = intensity
        self.jitter_by = jitter_by
        self.uvec = full_uvec / usteps
        self.vvec = full_vvec / vsteps

    def point_on_light(self, u: float, v: float) -> Point:
        return self.corner + self.uvec * (u + 0.5) + self.vvec * (v + 0.5)

    def _jitter(self) -> float:
        return self.jitter_by() if self.jitter_by is not None else 0.0

    def intensity_at(self, point, world) -> float:
        total = 0.0
        for v in range(self.vsteps):
            for u in range(self.usteps):
                light_pos = self.point_on_light(u + self._jitter(), v + self._jitter())
                if not world.is_shadowed_from(point, light_pos):
                    total += 1.0
        return total / self.samples

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, AreaLight):
            return NotImplemented
        return (
            self.corner == other.corner
            and self.uvec == other.uvec
            and self.vvec == other.vvec
            and self.usteps == other.usteps
            and self.vsteps == other.vsteps
            and self.intensity == other.intensity
        )
```

- [ ] **Step 2: Create `spotlight.py`**

```python
# python/rayz/spotlight.py
from __future__ import annotations

import math

from rayz.color import Color
from rayz.tuple import Point, Vector


class Spotlight:
    def __init__(
        self,
        position: Point,
        intensity: Color,
        direction: Vector,
        cone_angle: float,
        fade_angle: float | None = None,
    ) -> None:
        self.position = position
        self.intensity = intensity
        self.direction = direction.normalize()
        self.cone_angle = cone_angle
        self.fade_angle = fade_angle if fade_angle is not None else cone_angle

    def intensity_at(self, point, world) -> float:
        light_to_point = (point - self.position).normalize()
        cos_angle = self.direction.dot(light_to_point)
        cos_outer = math.cos(self.cone_angle)
        cos_inner = math.cos(self.fade_angle)

        if cos_angle < cos_outer:
            return 0.0

        if cos_angle >= cos_inner:
            return 0.0 if world.is_shadowed_from(point, self.position) else 1.0

        fade_factor = (cos_angle - cos_outer) / (cos_inner - cos_outer)
        return 0.0 if world.is_shadowed_from(point, self.position) else fade_factor

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Spotlight):
            return NotImplemented
        return (
            self.position == other.position
            and self.intensity == other.intensity
            and self.direction == other.direction
            and self.cone_angle == other.cone_angle
            and self.fade_angle == other.fade_angle
        )
```

- [ ] **Step 3: Verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python -c "
from rayz.area_light import AreaLight
from rayz.spotlight import Spotlight
from rayz.color import Color
from rayz.tuple import Point, Vector
# AreaLight construction
al = AreaLight(Point(-1,2,-1), Vector(2,0,0), Vector(0,2,0), 2, 2, Color(1,1,1))
p = al.point_on_light(0, 0)
assert p is not None
# Spotlight construction
sl = Spotlight(Point(0,5,0), Color(1,1,1), Vector(0,-1,0), 0.3, 0.2)
assert sl.direction.y < 0
print('AreaLight + Spotlight OK')
"
```

Expected: `AreaLight + Spotlight OK`

- [ ] **Step 4: Commit**

```bash
git add python/rayz/area_light.py python/rayz/spotlight.py
git commit -m "feat(python): add AreaLight and Spotlight"
```

---

### Task 7: `rayz/shape.py` — motion_transform, perturbation hook, abstract bounds()

**Files:**
- Modify: `python/rayz/shape.py`

- [ ] **Step 1: Update `shape.py`**

```python
# python/rayz/shape.py
from __future__ import annotations

from abc import ABC, abstractmethod

from rayz.material import Material
from rayz.matrix import Matrix
from rayz.tuple import Vector


class Shape(ABC):
    def __init__(self) -> None:
        self._transform = Matrix.identity(4)
        self._transform_inverse = Matrix.identity(4)
        self._transform_inverse_transpose = Matrix.identity(4)
        self.material = Material()
        self.parent = None
        self.motion_transform = None  # Callable[[float], Matrix] | None

    @property
    def transform(self) -> Matrix:
        return self._transform

    def set_transform(self, m: Matrix) -> None:
        self._transform = m
        self._transform_inverse = m.inverse()
        self._transform_inverse_transpose = m.inverse().transpose()

    def intersect(self, ray) -> list:
        if self.motion_transform is not None:
            effective_inverse = (self.motion_transform(ray.time) * self._transform).inverse()
        else:
            effective_inverse = self._transform_inverse
        local_ray = ray.transform(effective_inverse)
        return self.local_intersect(local_ray)

    def world_to_object(self, point):
        p = point
        if self.parent is not None:
            p = self.parent.world_to_object(p)
        return self._transform_inverse * p

    def normal_to_world(self, normal) -> Vector:
        n = self._transform_inverse_transpose * normal
        n = Vector(n.x, n.y, n.z).normalize()
        if self.parent is not None:
            n = self.parent.normal_to_world(n)
        return n

    def normal_at(self, world_point, hit=None) -> Vector:
        local_point = self.world_to_object(world_point)
        local_normal = self.local_normal_at(local_point, hit)
        if self.material.normal_perturbation is not None:
            perturbation = self.material.normal_perturbation(local_point)
            local_normal = Vector(
                local_normal.x + perturbation.x,
                local_normal.y + perturbation.y,
                local_normal.z + perturbation.z,
            ).normalize()
        return self.normal_to_world(local_normal)

    @abstractmethod
    def local_intersect(self, ray) -> list: ...

    @abstractmethod
    def local_normal_at(self, point, hit=None) -> Vector: ...

    @abstractmethod
    def bounds(self): ...


class TestShape(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.saved_ray = None

    def local_intersect(self, ray) -> list:
        self.saved_ray = ray
        return []

    def local_normal_at(self, point, hit=None) -> Vector:
        return Vector(point.x, point.y, point.z)

    def bounds(self):
        from rayz.bounds import Bounds
        from rayz.tuple import Point
        return Bounds(Point(-1, -1, -1), Point(1, 1, 1))
```

- [ ] **Step 2: Verify existing tests still pass**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

Expected: same passing count as before.

- [ ] **Step 3: Commit**

```bash
git add python/rayz/shape.py
git commit -m "feat(python): add motion_transform, normal perturbation hook, abstract bounds() to Shape"
```

---

### Task 8: Add `bounds()` to all shape subclasses

**Files:**
- Modify: `python/rayz/sphere.py`, `plane.py`, `cube.py`, `cylinder.py`, `cone.py`, `triangle.py`, `smooth_triangle.py`, `csg.py`

Add the following `bounds()` method to each class. Import `Bounds` and `Point` inside the method to avoid circular imports.

- [ ] **Step 1: `sphere.py`** — add after `local_normal_at`:

```python
def bounds(self):
    from rayz.bounds import Bounds
    from rayz.tuple import Point
    return Bounds(Point(-1, -1, -1), Point(1, 1, 1))
```

- [ ] **Step 2: `plane.py`** — add after `local_normal_at`:

```python
def bounds(self):
    import math
    from rayz.bounds import Bounds
    from rayz.tuple import Point
    return Bounds(Point(-math.inf, 0, -math.inf), Point(math.inf, 0, math.inf))
```

- [ ] **Step 3: `cube.py`** — add after `local_normal_at`:

```python
def bounds(self):
    from rayz.bounds import Bounds
    from rayz.tuple import Point
    return Bounds(Point(-1, -1, -1), Point(1, 1, 1))
```

- [ ] **Step 4: `cylinder.py`** — add after `local_normal_at`:

```python
def bounds(self):
    from rayz.bounds import Bounds
    from rayz.tuple import Point
    return Bounds(Point(-1, self.minimum, -1), Point(1, self.maximum, 1))
```

- [ ] **Step 5: `cone.py`** — add after `local_normal_at`:

```python
def bounds(self):
    import math
    from rayz.bounds import Bounds
    from rayz.tuple import Point
    radius = max(abs(self.minimum), abs(self.maximum))
    return Bounds(Point(-radius, self.minimum, -radius), Point(radius, self.maximum, radius))
```

- [ ] **Step 6: `triangle.py`** — add after `local_normal_at`:

```python
def bounds(self):
    from rayz.bounds import Bounds
    from rayz.tuple import Point
    min_x = min(self.p1.x, self.p2.x, self.p3.x)
    min_y = min(self.p1.y, self.p2.y, self.p3.y)
    min_z = min(self.p1.z, self.p2.z, self.p3.z)
    max_x = max(self.p1.x, self.p2.x, self.p3.x)
    max_y = max(self.p1.y, self.p2.y, self.p3.y)
    max_z = max(self.p1.z, self.p2.z, self.p3.z)
    return Bounds(Point(min_x, min_y, min_z), Point(max_x, max_y, max_z))
```

- [ ] **Step 7: `smooth_triangle.py`** — `SmoothTriangle` inherits from `Triangle`; no override needed. Verify the class declaration and confirm it will inherit `bounds()`.

```bash
grep -n "class SmoothTriangle" /Users/craig/workspace/rayz/python/rayz/smooth_triangle.py
```

Expected: `class SmoothTriangle(Triangle):` — if so, no change needed. If the class doesn't extend Triangle, add the same `bounds()` as Task 8 Step 6.

- [ ] **Step 8: `csg.py`** — add after `local_normal_at`:

```python
def bounds(self):
    l_bounds = self.left.bounds().transform(self.left.transform)
    r_bounds = self.right.bounds().transform(self.right.transform)
    return l_bounds.merge(r_bounds)
```

- [ ] **Step 9: Verify existing tests pass**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

- [ ] **Step 10: Commit**

```bash
git add python/rayz/sphere.py python/rayz/plane.py python/rayz/cube.py \
        python/rayz/cylinder.py python/rayz/cone.py python/rayz/triangle.py \
        python/rayz/smooth_triangle.py python/rayz/csg.py
git commit -m "feat(python): add bounds() to all Shape subclasses"
```

---

### Task 9: `rayz/group.py` — `bounds()` and AABB optimization

**Files:**
- Modify: `python/rayz/group.py`

- [ ] **Step 1: Update `group.py`**

```python
# python/rayz/group.py
from __future__ import annotations

from rayz.shape import Shape
from rayz.tuple import Vector


class Group(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.children: list[Shape] = []

    def add_child(self, shape: Shape) -> None:
        self.children.append(shape)
        shape.parent = self

    def bounds(self):
        from rayz.bounds import Bounds
        result = Bounds()  # starts at +inf/-inf
        for child in self.children:
            child_bounds = child.bounds().transform(child.transform)
            result = result.merge(child_bounds)
        return result

    def local_intersect(self, ray) -> list:
        if self.children and not self.bounds().intersects(ray):
            return []
        xs = []
        for child in self.children:
            xs.extend(child.intersect(ray))
        return sorted(xs, key=lambda i: i.t)

    def local_normal_at(self, point, hit=None) -> Vector:
        raise RuntimeError("Groups have no surface normals")
```

- [ ] **Step 2: Verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

Expected: same passing count (groups tests must still pass).

- [ ] **Step 3: Commit**

```bash
git add python/rayz/group.py
git commit -m "feat(python): add bounds() and AABB early-exit optimization to Group"
```

---

### Task 10: `rayz/lighting.py` — `intensity` float parameter

**Files:**
- Modify: `python/rayz/lighting.py`

- [ ] **Step 1: Update signature and logic**

Key changes:
- `in_shadow: bool = False` → `intensity: float = 1.0`
- Add `isinstance(intensity, bool)` guard for backward compat with existing step definitions that pass `True`/`False`
- Scale diffuse and specular by `intensity`
- Support area light direction (use center when light has `corner` attribute)

```python
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
        light_center = (
            light.corner
            + light.uvec * (light.usteps / 2.0)
            + light.vvec * (light.vsteps / 2.0)
        )
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

    factor = reflect_dot_eye ** material.shininess
    specular = light.intensity * material.specular * factor * intensity
    return ambient + diffuse + specular
```

- [ ] **Step 2: Verify existing tests pass (critical — this touches core shading)**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

Expected: same passing count as before.

- [ ] **Step 3: Commit**

```bash
git add python/rayz/lighting.py
git commit -m "feat(python): change lighting() shadow param to intensity float, support area light direction"
```

---

### Task 11: `rayz/world.py` — `is_shadowed_from()`, updated `shade_hit()`

**Files:**
- Modify: `python/rayz/world.py`

- [ ] **Step 1: Update `world.py`**

Key changes:
- Add `is_shadowed_from(point, light_pos)` — early-exit shadow test
- Update `is_shadowed(point)` to delegate to `is_shadowed_from` for PointLight; call `intensity_at` for AreaLight/Spotlight
- Update `shade_hit()` to pass float `intensity` to `lighting()`

```python
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
```

- [ ] **Step 2: Verify all existing tests pass**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

Expected: same passing count.

- [ ] **Step 3: Commit**

```bash
git add python/rayz/world.py
git commit -m "feat(python): add is_shadowed_from(), AreaLight/Spotlight support in shade_hit()"
```

---

### Task 12: `rayz/camera.py` — anti-aliasing, focal blur, motion blur

**Files:**
- Modify: `python/rayz/camera.py`

- [ ] **Step 1: Update `camera.py`**

```python
# python/rayz/camera.py
from __future__ import annotations

import math
import os
import random
from concurrent.futures import ProcessPoolExecutor

from rayz.canvas import Canvas
from rayz.matrix import Matrix
from rayz.tuple import Point


def _render_chunk(args: tuple) -> list[tuple[int, int, object]]:
    camera, world, rows = args
    from rayz.color import Color
    from rayz.ray import Ray

    inv = camera._transform_inverse
    hw = camera._half_width
    hh = camera._half_height
    ps = camera.pixel_size
    fd = camera.focal_distance
    spp = camera.samples_per_pixel
    ap = camera.aperture_size
    mb = camera.motion_blur

    results = []
    for y in rows:
        for x in range(camera.hsize):
            if spp == 1 and ap == 0.0 and not mb:
                xoffset = (x + 0.5) * ps
                yoffset = (y + 0.5) * ps
                pixel = inv * Point(hw - xoffset, hh - yoffset, -fd)
                origin = inv * Point(0, 0, 0)
                direction = (pixel - origin).normalize()
                color = world.color_at(Ray(origin, direction, time=0.0))
            else:
                total_r = total_g = total_b = 0.0
                for _ in range(spp):
                    px_off = random.random()
                    py_off = random.random()
                    ax = (random.random() * 2 - 1) * ap if ap > 0 else 0.0
                    ay = (random.random() * 2 - 1) * ap if ap > 0 else 0.0
                    t = random.random() if mb else 0.0
                    xoffset = (x + px_off) * ps
                    yoffset = (y + py_off) * ps
                    pixel = inv * Point(hw - xoffset, hh - yoffset, -fd)
                    origin = inv * Point(ax, ay, 0)
                    direction = (pixel - origin).normalize()
                    c = world.color_at(Ray(origin, direction, time=t))
                    total_r += c.red
                    total_g += c.green
                    total_b += c.blue
                color = Color(total_r / spp, total_g / spp, total_b / spp)
            results.append((y, x, color))
    return results


class Camera:
    def __init__(
        self,
        hsize: int,
        vsize: int,
        field_of_view: float,
        samples_per_pixel: int = 1,
        aperture_size: float = 0.0,
        focal_distance: float = 1.0,
        motion_blur: bool = False,
    ) -> None:
        self.hsize = hsize
        self.vsize = vsize
        self.field_of_view = field_of_view
        self.samples_per_pixel = samples_per_pixel
        self.aperture_size = aperture_size
        self.focal_distance = focal_distance
        self.motion_blur = motion_blur
        self._transform = Matrix.identity(4)
        self._transform_inverse = Matrix.identity(4)
        self._calc_pixel_size()

    @property
    def transform(self) -> Matrix:
        return self._transform

    @transform.setter
    def transform(self, m: Matrix) -> None:
        self._transform = m
        self._transform_inverse = m.inverse()

    def _calc_pixel_size(self) -> None:
        half_view = math.tan(self.field_of_view / 2.0)
        aspect = self.hsize / self.vsize
        if aspect >= 1:
            self._half_width = half_view
            self._half_height = half_view / aspect
        else:
            self._half_width = half_view * aspect
            self._half_height = half_view
        self.pixel_size = (self._half_width * 2) / self.hsize

    def ray_for_pixel(
        self,
        px: int,
        py: int,
        pixel_offset_x: float = 0.5,
        pixel_offset_y: float = 0.5,
        aperture_offset_x: float = 0.0,
        aperture_offset_y: float = 0.0,
        time: float = 0.0,
    ):
        from rayz.ray import Ray

        xoffset = (px + pixel_offset_x) * self.pixel_size
        yoffset = (py + pixel_offset_y) * self.pixel_size
        world_x = self._half_width - xoffset
        world_y = self._half_height - yoffset

        inv = self._transform_inverse
        canvas_z = -self.focal_distance
        pixel = inv * Point(world_x, world_y, canvas_z)
        ax = aperture_offset_x * self.aperture_size
        ay = aperture_offset_y * self.aperture_size
        origin = inv * Point(ax, ay, 0)
        direction = (pixel - origin).normalize()
        return Ray(origin, direction, time=time)

    def _render_pixel(self, x: int, y: int, world):
        from rayz.color import Color

        if self.samples_per_pixel == 1 and self.aperture_size == 0.0 and not self.motion_blur:
            return world.color_at(self.ray_for_pixel(x, y))

        total_r = total_g = total_b = 0.0
        for _ in range(self.samples_per_pixel):
            ax = (random.random() * 2 - 1) if self.aperture_size > 0 else 0.0
            ay = (random.random() * 2 - 1) if self.aperture_size > 0 else 0.0
            t = random.random() if self.motion_blur else 0.0
            ray = self.ray_for_pixel(
                x, y,
                pixel_offset_x=random.random(),
                pixel_offset_y=random.random(),
                aperture_offset_x=ax,
                aperture_offset_y=ay,
                time=t,
            )
            c = world.color_at(ray)
            total_r += c.red
            total_g += c.green
            total_b += c.blue
        spp = self.samples_per_pixel
        return Color(total_r / spp, total_g / spp, total_b / spp)

    def render(self, world) -> Canvas:
        image = Canvas(self.hsize, self.vsize)
        for y in range(self.vsize):
            for x in range(self.hsize):
                color = self._render_pixel(x, y, world)
                image.write_pixel(col=x, row=self.vsize - 1 - y, color=color)
        return image

    def render_parallel(self, world, workers: int | None = None) -> Canvas:
        if workers is None:
            workers = os.cpu_count() or 1
        all_rows = list(range(self.vsize))
        chunk_size = max(1, math.ceil(self.vsize / workers))
        chunks = [all_rows[i: i + chunk_size] for i in range(0, self.vsize, chunk_size)]

        image = Canvas(self.hsize, self.vsize)
        with ProcessPoolExecutor(max_workers=workers) as executor:
            for results in executor.map(_render_chunk, [(self, world, chunk) for chunk in chunks]):
                for y, x, color in results:
                    image.write_pixel(col=x, row=self.vsize - 1 - y, color=color)
        return image
```

- [ ] **Step 2: Verify existing tests pass**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

- [ ] **Step 3: Smoke-test that basic render still works**

```bash
cd /Users/craig/workspace/rayz/python
uv run python -c "
from rayz.camera import Camera
from rayz.world import World
from rayz.transformations import view_transform
from rayz.tuple import Point, Vector
import math
w = World.default_world()
c = Camera(20, 10, math.pi/3)
c.transform = view_transform(Point(0,0,-5), Point(0,0,0), Vector(0,1,0))
img = c.render(w)
px = img.pixel_at(5, 5)
assert px.red > 0 or px.green > 0 or px.blue > 0, 'render produced black'
print('Camera render OK')
"
```

Expected: `Camera render OK`

- [ ] **Step 4: Commit**

```bash
git add python/rayz/camera.py
git commit -m "feat(python): add samples_per_pixel, aperture_size, focal_distance, motion_blur to Camera"
```

---

### Task 13: `rayz/texture_map.py` — PPMImage and TextureMap

**Files:**
- Create: `python/rayz/texture_map.py`

- [ ] **Step 1: Create `texture_map.py`**

```python
# python/rayz/texture_map.py
from __future__ import annotations

import math
from typing import Callable

from rayz.color import Color
from rayz.pattern import Pattern
from rayz.tuple import Point, Vector


class PPMImage:
    def __init__(self, width: int, height: int) -> None:
        self.width = width
        self.height = height
        self._pixels: list[list[Color | None]] = [[None] * width for _ in range(height)]

    def pixel_at(self, x: int, y: int) -> Color:
        if x < 0 or x >= self.width or y < 0 or y >= self.height:
            return Color(0, 0, 0)
        return self._pixels[y][x] or Color(0, 0, 0)

    def set_pixel(self, x: int, y: int, color: Color) -> None:
        if 0 <= x < self.width and 0 <= y < self.height:
            self._pixels[y][x] = color

    @classmethod
    def load_ppm(cls, filename: str) -> PPMImage:
        with open(filename) as f:
            raw = f.read()
        lines = [ln.strip() for ln in raw.splitlines() if ln.strip() and not ln.strip().startswith("#")]
        assert lines[0] == "P3", f"Unsupported PPM format: {lines[0]}"
        width, height = map(int, lines[1].split())
        max_color = int(lines[2])
        values = list(map(int, " ".join(lines[3:]).split()))
        image = cls(width, height)
        for i, (r, g, b) in enumerate(zip(values[::3], values[1::3], values[2::3])):
            image.set_pixel(i % width, i // width, Color(r / max_color, g / max_color, b / max_color))
        return image

    @classmethod
    def checkerboard(cls, width: int, height: int, checks: int) -> PPMImage:
        """Programmatic checkerboard — useful for demos without an image file."""
        img = cls(width, height)
        cell_w = max(1, width // checks)
        cell_h = max(1, height // checks)
        white = Color(1, 1, 1)
        black = Color(0.1, 0.1, 0.1)
        for y in range(height):
            for x in range(width):
                color = white if ((x // cell_w) + (y // cell_h)) % 2 == 0 else black
                img.set_pixel(x, y, color)
        return img


class TextureMap(Pattern):
    def __init__(self, image: PPMImage, uv_map: Callable) -> None:
        super().__init__()
        self.image = image
        self.uv_map = uv_map

    def pattern_at(self, point) -> Color:
        u, v = self.uv_map(point)
        x = round(u * (self.image.width - 1))
        y = round((1.0 - v) * (self.image.height - 1))
        return self.image.pixel_at(x, y)

    @staticmethod
    def planar_map(point) -> tuple[float, float]:
        return point.x % 1.0, point.z % 1.0

    @staticmethod
    def cylindrical_map(point) -> tuple[float, float]:
        theta = math.atan2(point.x, point.z)
        u = (theta + math.pi) / (2 * math.pi)
        return u, point.y % 1.0

    @staticmethod
    def spherical_map(point) -> tuple[float, float]:
        theta = math.atan2(point.x, point.z)
        vec = Vector(point.x, point.y, point.z)
        radius = math.sqrt(point.x**2 + point.y**2 + point.z**2)
        phi = math.acos(point.y / radius) if radius > 0 else 0.0
        u = 1.0 - (theta + math.pi) / (2 * math.pi)
        v = 1.0 - phi / math.pi
        return u, v
```

- [ ] **Step 2: Verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python -c "
from rayz.texture_map import PPMImage, TextureMap
from rayz.tuple import Point
img = PPMImage.checkerboard(8, 4, 2)
assert img.pixel_at(0, 0) is not None
tm = TextureMap(img, TextureMap.spherical_map)
p = Point(0, 1, 0)
c = tm.pattern_at(p)
assert c is not None
print('TextureMap OK')
"
```

Expected: `TextureMap OK`

- [ ] **Step 3: Commit**

```bash
git add python/rayz/texture_map.py
git commit -m "feat(python): add PPMImage and TextureMap pattern with UV mapping"
```

---

### Task 14: `examples/advanced_features_demo.py`

**Files:**
- Create: `python/examples/advanced_features_demo.py`

- [ ] **Step 1: Create the demo**

```python
# python/examples/advanced_features_demo.py
"""Advanced Features Demo: torus, normal perturbation, reflective materials."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.normal_perturbations import quilted, sine_wave
from rayz.pattern import CheckersPattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.torus import Torus
from rayz.transformations import rotation_x, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Advanced Features Demo ===")
    print("  Showcasing: Torus primitive, Normal Perturbation, Reflective Materials")

    w = World()
    w.light = PointLight(Point(-5, 10, -5), Color(1, 1, 1))

    # Checkerboard floor
    floor = Plane()
    floor.material.pattern = CheckersPattern(Color(0.5, 0.5, 0.5), Color(0.8, 0.8, 0.8))
    floor.material.specular = 0
    floor.material.reflective = 0.1
    w.objects.append(floor)

    # Red sphere with sine-wave normal perturbation (left)
    sphere1 = Sphere()
    sphere1.set_transform(translation(-2, 1, 0))
    sphere1.material.color = Color(1, 0.3, 0.3)
    sphere1.material.specular = 0.8
    sphere1.material.normal_perturbation = sine_wave(frequency=10, amplitude=0.15)
    w.objects.append(sphere1)

    # Green torus (centre)
    torus = Torus(major_radius=0.6, minor_radius=0.2)
    torus.set_transform(translation(0, 1.2, 0) * rotation_x(math.pi / 2))
    torus.material.color = Color(0.3, 1, 0.3)
    torus.material.specular = 0.8
    torus.material.reflective = 0.4
    w.objects.append(torus)

    # Blue sphere with quilted normal perturbation (right)
    sphere2 = Sphere()
    sphere2.set_transform(translation(2, 1, 0))
    sphere2.material.color = Color(0.3, 0.3, 1)
    sphere2.material.specular = 0.8
    sphere2.material.normal_perturbation = quilted(frequency=8, amplitude=0.2)
    w.objects.append(sphere2)

    camera = Camera(400, 200, math.pi / 3, samples_per_pixel=1)
    camera.transform = view_transform(Point(0, 3.5, -8), Point(0, 1, 0), Vector(0, 1, 0))

    print("  Rendering 400x200...")
    canvas = camera.render_parallel(w)

    out = os.path.join(os.path.dirname(__file__), "advanced_features_demo.ppm")
    with open(out, "w") as f:
        f.write(canvas.to_ppm())
    print(f"  Saved to {out}")
    print()
    print("  Features demonstrated:")
    print("    - Torus primitive (green donut)")
    print("    - Normal perturbation: sine_wave (red sphere), quilted (blue sphere)")
    print("    - Reflective materials")
    print("    - Checkerboard floor pattern")
    print()
    print("  Also available (not rendered to keep times down):")
    print("    - AreaLight (soft shadows via grid sampling)")
    print("    - Spotlight (cone beam with fade angle)")
    print("    - Anti-aliasing (samples_per_pixel > 1)")
    print("    - Focal blur (aperture_size > 0, focal_distance)")
    print("    - Motion blur (motion_blur=True, shape.motion_transform)")
    print("    - TextureMap (planar/cylindrical/spherical UV mapping)")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Run and verify output file is created**

```bash
cd /Users/craig/workspace/rayz/python
uv run examples/run.py advanced_features 2>&1 | head -20
```

(This will fail because run.py doesn't know `advanced_features` yet — that's fine. Run directly instead:)

```bash
cd /Users/craig/workspace/rayz/python
uv run python examples/advanced_features_demo.py
ls -la examples/advanced_features_demo.ppm
```

Expected: file created, non-zero size.

- [ ] **Step 3: Commit**

```bash
git add python/examples/advanced_features_demo.py python/examples/advanced_features_demo.ppm
git commit -m "feat(python): add advanced_features_demo (torus + normal perturbation)"
```

---

### Task 15: `examples/bounding_boxes_demo.py`

**Files:**
- Create: `python/examples/bounding_boxes_demo.py`

- [ ] **Step 1: Create the demo**

```python
# python/examples/bounding_boxes_demo.py
"""Bounding Boxes Demo: AABB optimization with grouped marbles."""

from __future__ import annotations

import math
import os
import random
import time

from rayz.camera import Camera
from rayz.color import Color
from rayz.group import Group
from rayz.pattern import CheckersPattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Bounding Boxes Demo ===")
    print("  Performance optimization with Axis-Aligned Bounding Boxes")
    print("  Rendering a scene with many grouped objects...")

    floor = Plane()
    floor.material.color = Color(1, 0.9, 0.9)
    floor.material.specular = 0
    floor.material.pattern = CheckersPattern(Color(0.8, 0.8, 0.8), Color(0.2, 0.2, 0.2))

    groups = []
    rng = random.Random(42)  # deterministic seed for reproducibility

    for row in range(4):
        for col in range(4):
            group = Group()
            for i in range(6):
                sphere = Sphere()
                x = (col * 10) - 15 + rng.random() * 4
                y = 0.5 + rng.random() * 2
                z = (row * 10) - 15 + rng.random() * 4
                s = 0.3 + rng.random() * 0.5
                sphere.set_transform(translation(x, y, z) * scaling(s, s, s))

                mod = i % 3
                if mod == 0:  # glass
                    sphere.material.color = Color(0.1, 0.1, 0.1)
                    sphere.material.diffuse = 0.1
                    sphere.material.specular = 0.9
                    sphere.material.shininess = 300
                    sphere.material.reflective = 0.9
                    sphere.material.transparency = 0.9
                    sphere.material.refractive_index = 1.5
                elif mod == 1:  # metallic
                    sphere.material.color = Color(0.7, 0.7, 0.8)
                    sphere.material.diffuse = 0.3
                    sphere.material.specular = 1.0
                    sphere.material.shininess = 300
                    sphere.material.reflective = 0.8
                else:  # coloured
                    sphere.material.color = Color(
                        0.3 + rng.random() * 0.7,
                        0.3 + rng.random() * 0.7,
                        0.3 + rng.random() * 0.7,
                    )
                    sphere.material.diffuse = 0.7
                    sphere.material.specular = 0.3

                group.add_child(sphere)
            groups.append(group)

    w = World()
    w.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))
    w.objects.append(floor)
    for g in groups:
        w.objects.append(g)

    camera = Camera(600, 400, math.pi / 3)
    camera.transform = view_transform(Point(0, 5, -20), Point(0, 1, 0), Vector(0, 1, 0))

    total_spheres = len(groups) * 6
    print(f"  Scene: {total_spheres} spheres in {len(groups)} groups")
    print("  Rendering 600x400...")
    t0 = time.time()
    canvas = camera.render_parallel(w)
    elapsed = time.time() - t0
    print(f"  Rendered in {elapsed:.2f}s")

    out = os.path.join(os.path.dirname(__file__), "bounding_boxes_demo.ppm")
    with open(out, "w") as f:
        f.write(canvas.to_ppm())
    print(f"  Saved to {out}")
    print()
    print("  Bounding boxes allow the ray tracer to skip entire groups when")
    print("  rays miss their AABB, reducing intersection tests significantly.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Run and verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python examples/bounding_boxes_demo.py
ls -la examples/bounding_boxes_demo.ppm
```

Expected: file created. The render may take 30–120 seconds.

- [ ] **Step 3: Commit**

```bash
git add python/examples/bounding_boxes_demo.py python/examples/bounding_boxes_demo.ppm
git commit -m "feat(python): add bounding_boxes_demo"
```

---

### Task 16: `examples/nested_groups_demo.py`

**Files:**
- Create: `python/examples/nested_groups_demo.py`

- [ ] **Step 1: Create the demo**

```python
# python/examples/nested_groups_demo.py
"""Nested Groups Demo: hierarchical transformations via world_to_object / normal_to_world."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.cylinder import Cylinder
from rayz.group import Group
from rayz.pattern import CheckersPattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import rotation_y, rotation_z, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Nested Groups Demo ===")
    print("  Demonstrating hierarchical transformations (world_to_object / normal_to_world)")

    w = World()
    w.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    # Reflective checkerboard floor
    floor = Plane()
    floor.material.pattern = CheckersPattern(Color(0.9, 0.9, 0.9), Color(0.1, 0.1, 0.1))
    floor.material.reflective = 0.2
    w.objects.append(floor)

    # --- Solar system: Sun + Earth + Moon (6 levels) ---
    sun = Sphere()
    sun.material.color = Color(1, 0.9, 0.1)
    sun.material.ambient = 0.8
    sun.material.diffuse = 0.9
    sun.set_transform(scaling(1.5, 1.5, 1.5))
    w.objects.append(sun)

    earth_orbit = Group()
    earth_orbit.set_transform(rotation_y(math.pi / 4))
    earth_pos = Group()
    earth_pos.set_transform(translation(5, 0, 0))
    earth_rot = Group()
    earth_rot.set_transform(rotation_y(math.pi / 3))

    earth = Sphere()
    earth.material.color = Color(0.1, 0.3, 0.8)
    earth.material.diffuse = 0.7
    earth.material.specular = 0.3
    earth.set_transform(scaling(0.8, 0.8, 0.8))

    moon_orbit = Group()
    moon_orbit.set_transform(rotation_y(-math.pi / 6))
    moon_pos = Group()
    moon_pos.set_transform(translation(1.5, 0.3, 0))

    moon = Sphere()
    moon.material.color = Color(0.7, 0.7, 0.7)
    moon.material.diffuse = 0.6
    moon.set_transform(scaling(0.3, 0.3, 0.3))

    moon_pos.add_child(moon)
    moon_orbit.add_child(moon_pos)
    earth_rot.add_child(earth)
    earth_rot.add_child(moon_orbit)
    earth_pos.add_child(earth_rot)
    earth_orbit.add_child(earth_pos)
    w.objects.append(earth_orbit)

    # --- Mars + Phobos (5 levels) ---
    mars_orbit = Group()
    mars_orbit.set_transform(rotation_y(-math.pi / 3))
    mars_pos = Group()
    mars_pos.set_transform(translation(-7, 0, 2))

    mars = Sphere()
    mars.material.color = Color(0.9, 0.3, 0.1)
    mars.material.diffuse = 0.7
    mars.set_transform(scaling(0.6, 0.6, 0.6))

    phobos_orbit = Group()
    phobos_orbit.set_transform(rotation_y(math.pi / 2))
    phobos_pos = Group()
    phobos_pos.set_transform(translation(1.2, 0.2, 0))

    phobos = Sphere()
    phobos.material.color = Color(0.5, 0.5, 0.4)
    phobos.set_transform(scaling(0.2, 0.2, 0.2))

    phobos_pos.add_child(phobos)
    phobos_orbit.add_child(phobos_pos)
    mars_pos.add_child(mars)
    mars_pos.add_child(phobos_orbit)
    mars_orbit.add_child(mars_pos)
    w.objects.append(mars_orbit)

    # --- Space station: hub + 4 arms (3 levels) ---
    station = Group()
    station.set_transform(translation(0, 3, -8) * rotation_y(math.pi / 6))

    hub = Sphere()
    hub.material.color = Color(0.8, 0.8, 0.9)
    hub.material.reflective = 0.6
    hub.material.specular = 0.9
    hub.material.shininess = 300
    hub.set_transform(scaling(0.5, 0.5, 0.5))
    station.add_child(hub)

    for i in range(4):
        angle = (math.pi / 2) * i
        arm_group = Group()
        arm_group.set_transform(rotation_y(angle))
        arm_pos = Group()
        arm_pos.set_transform(translation(1, 0, 0))

        arm = Cylinder()
        arm.minimum = 0
        arm.maximum = 1.5
        arm.closed = True
        arm.material.color = Color(0.6, 0.6, 0.7)
        arm.material.specular = 0.5
        arm.set_transform(scaling(0.1, 1, 0.1) * rotation_z(math.pi / 2))

        end_sphere = Sphere()
        end_sphere.material.color = Color(0.3, 0.6, 0.9)
        end_sphere.material.reflective = 0.3
        end_sphere.set_transform(translation(1.5, 0, 0) * scaling(0.3, 0.3, 0.3))

        arm_pos.add_child(arm)
        arm_pos.add_child(end_sphere)
        arm_group.add_child(arm_pos)
        station.add_child(arm_group)

    w.objects.append(station)

    camera = Camera(800, 600, math.pi / 3)
    camera.transform = view_transform(Point(0, 8, -15), Point(0, 1, 0), Vector(0, 1, 0))

    print("  Scene: sun/earth/moon (6 levels), Mars/Phobos (5 levels), space station (3 levels)")
    print("  Rendering 800x600...")
    canvas = camera.render_parallel(w)

    out = os.path.join(os.path.dirname(__file__), "nested_groups_demo.ppm")
    with open(out, "w") as f:
        f.write(canvas.to_ppm())
    print(f"  Saved to {out}")
    print()
    print("  Correct rendering confirms world_to_object / normal_to_world cascade")
    print("  properly through multiple levels of parent group transforms.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Run and verify**

```bash
cd /Users/craig/workspace/rayz/python
uv run python examples/nested_groups_demo.py
ls -la examples/nested_groups_demo.ppm
```

Expected: file created. This scene is large (800×600); expect 2–10 minutes.

- [ ] **Step 3: Commit**

```bash
git add python/examples/nested_groups_demo.py python/examples/nested_groups_demo.ppm
git commit -m "feat(python): add nested_groups_demo (solar system + space station)"
```

---

### Task 17: `examples/run.py` — register demos, add string-name lookup

**Files:**
- Modify: `python/examples/run.py`

- [ ] **Step 1: Update `run.py`**

```python
# python/examples/run.py
"""Runner: execute chapter examples by number or name.

Usage (from python/):
    uv run examples/run.py               # all chapters and demos
    uv run examples/run.py all           # same
    uv run examples/run.py 7             # chapter 7 only
    uv run examples/run.py advanced_features
    uv run examples/run.py bounding_boxes
    uv run examples/run.py nested_groups
    uv run examples/run.py obj_parser
"""

import sys

from examples.chapter1 import run as ch1
from examples.chapter2 import run as ch2
from examples.chapter3 import run as ch3
from examples.chapter4 import run as ch4
from examples.chapter5 import run as ch5
from examples.chapter6 import run as ch6
from examples.chapter7 import run as ch7
from examples.chapter8 import run as ch8
from examples.chapter9 import run as ch9
from examples.chapter10 import run as ch10
from examples.chapter11 import run as ch11
from examples.chapter12 import run as ch12
from examples.chapter13 import run as ch13
from examples.chapter14 import run as ch14
from examples.chapter15 import run as ch15
from examples.chapter16 import run as ch16
from examples.chapter17 import run as ch17
from examples.obj_parser_demo import run as obj_demo
from examples.bounding_boxes_demo import run as bb_demo
from examples.nested_groups_demo import run as ng_demo
from examples.advanced_features_demo import run as af_demo

CHAPTERS: dict[int, tuple[str, object]] = {
    1:  ("Projectile physics", ch1),
    2:  ("Canvas & PPM export", ch2),
    3:  ("Matrices", ch3),
    4:  ("Transformations", ch4),
    5:  ("Ray-sphere intersections", ch5),
    6:  ("Light and Shading", ch6),
    7:  ("Making a Scene", ch7),
    8:  ("Patterns and Planes", ch8),
    9:  ("Planes", ch9),
    10: ("Reflection and Refraction", ch10),
    11: ("Cubes", ch11),
    12: ("Cylinders", ch12),
    13: ("Groups", ch13),
    14: ("Cones", ch14),
    15: ("Triangles", ch15),
    16: ("CSG", ch16),
    17: ("Smooth Triangles", ch17),
    18: ("OBJ Parser Demo", obj_demo),
    19: ("Bounding Boxes Demo", bb_demo),
    20: ("Nested Groups Demo", ng_demo),
    21: ("Advanced Features Demo", af_demo),
}

NAMES: dict[str, int] = {
    "obj_parser":        18,
    "bounding_boxes":    19,
    "nested_groups":     20,
    "advanced_features": 21,
}


def main() -> None:
    args = sys.argv[1:]

    if not args or args == ["all"]:
        targets = sorted(CHAPTERS.keys())
    else:
        targets = []
        for a in args:
            try:
                targets.append(int(a))
            except ValueError:
                if a in NAMES:
                    targets.append(NAMES[a])
                else:
                    print(f"Unknown chapter: {a!r}  (valid integers: {sorted(CHAPTERS)}, names: {sorted(NAMES)})")
                    sys.exit(1)

    for n in targets:
        if n not in CHAPTERS:
            print(f"Chapter {n} not yet implemented.")
            continue
        _name, fn = CHAPTERS[n]
        fn()


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Verify string-name dispatch works**

```bash
cd /Users/craig/workspace/rayz/python
uv run examples/run.py advanced_features 2>&1 | head -5
```

Expected: prints `=== Advanced Features Demo ===` and runs.

- [ ] **Step 3: Verify all existing chapters still work**

```bash
cd /Users/craig/workspace/rayz/python
uv run behave --no-capture -q 2>&1 | tail -5
```

- [ ] **Step 4: Commit**

```bash
git add python/examples/run.py
git commit -m "feat(python): register demo scripts 19-21, add string-name CLI lookup"
```

---

## Self-review

**Spec coverage check:**

| Spec requirement | Task |
|-----------------|------|
| `bounds.py` | Task 1 |
| `torus.py` | Task 5 |
| `normal_perturbations.py` | Task 4 |
| `area_light.py` | Task 6 |
| `spotlight.py` | Task 6 |
| `texture_map.py` | Task 13 |
| `material.normal_perturbation` | Task 3 |
| `shape.motion_transform` | Task 7 |
| `shape.normal_at` perturbation hook | Task 7 |
| `shape.bounds()` abstract | Task 7 |
| `ray.time` | Task 2 |
| `lighting` intensity float | Task 10 |
| `world.is_shadowed_from` | Task 11 |
| `world.shade_hit` area/spot support | Task 11 |
| `camera` AA/focal/motion | Task 12 |
| All shape `bounds()` | Task 8 |
| `group.bounds()` + AABB | Task 9 |
| `advanced_features_demo.py` | Task 14 |
| `bounding_boxes_demo.py` | Task 15 |
| `nested_groups_demo.py` | Task 16 |
| `run.py` updates | Task 17 |

All spec requirements covered. No placeholders or TODOs remain.
