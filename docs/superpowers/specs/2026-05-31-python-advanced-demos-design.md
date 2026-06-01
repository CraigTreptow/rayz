# Python Advanced Demo Suite — Design Spec
**Date:** 2026-05-31
**Scope:** Bring Python's `rayz` library to full feature parity with Ruby, then add the three missing demo scripts.

---

## Goal

Ruby has six library components, extensive camera/lighting/world extensions, and three demo scripts beyond chapters 1–17 that Python lacks. This spec covers porting all of them so Python matches Ruby exactly.

---

## Section 1 — New library files (6)

### `rayz/torus.py`
`Torus(Shape)` — donut-shaped primitive.

- Constructor: `Torus(major_radius=1.0, minor_radius=0.25)`
- `local_intersect(ray)`: expands torus equation `(sqrt(x²+z²) - R)² + y² = r²` into quartic `at⁴ + bt³ + ct² + dt + e = 0`; solves via Durand-Kerner iteration using Python's built-in `complex` type (100 iterations, tolerance 1e-10); returns intersections for positive real roots (imaginary part < tolerance).
- `local_normal_at(point, hit=None)`: finds closest point on major circle in XZ plane, returns normalized vector from that point to surface point.
- `bounds()`: returns `Bounds(min=Point(-extent, -minor_r, -extent), max=Point(extent, minor_r, extent))` where `extent = major_r + minor_r`.

### `rayz/bounds.py`
`Bounds` — axis-aligned bounding box.

- Constructor: `Bounds(min=Point(+inf,+inf,+inf), max=Point(-inf,-inf,-inf))`
- `merge(other) -> Bounds`: component-wise min/max.
- `transform(matrix) -> Bounds`: transforms all 8 corners, returns new AABB enclosing them.
- `intersects(ray) -> bool`: slab method — `check_axis()` for each axis, `tmin <= tmax`.
- `contains_point(point) -> bool`
- `contains_bounds(other) -> bool`: delegates to `contains_point` on min and max.

### `rayz/normal_perturbations.py`
Module of factory functions, each returns a `Callable[[Point], Vector]`.

- `sine_wave(frequency=10.0, amplitude=0.1)`: perturbs x/y/z using `sin` of the perpendicular axis.
- `quilted(frequency=5.0, amplitude=0.15)`: u=sin(x*f), v=sin(z*f), perturbation = u*v*amplitude along Y.
- `noise(frequency=5.0, amplitude=0.1)`: cross-axis sine combinations for x/y/z.
- `ripples(center=Point(0,0,0), frequency=10.0, amplitude=0.1)`: radial distance from center, perturbation along Y.

### `rayz/area_light.py`
`AreaLight` — rectangular area light for soft shadows.

- Constructor: `AreaLight(corner, full_uvec, full_vvec, usteps, vsteps, intensity, jitter_by=None)`
  - Stores `uvec = full_uvec / usteps`, `vvec = full_vvec / vsteps`; `samples = usteps * vsteps`
- `point_on_light(u, v) -> Point`: `corner + uvec*(u+0.5) + vvec*(v+0.5)`
- `intensity_at(point, world) -> float`: samples grid, sums unblocked samples divided by `self.samples`. Uses `world.is_shadowed_from(point, sample_pos)` for each sample.
- `__eq__`: compares corner, uvec, vvec, usteps, vsteps, intensity.
- Note: `jitter_by` is an optional `Callable[[], float]` for randomised sampling.

### `rayz/spotlight.py`
`Spotlight` — directional cone light.

- Constructor: `Spotlight(position, intensity, direction, cone_angle, fade_angle=None)`
  - `direction` stored normalised; `fade_angle` defaults to `cone_angle` (hard edge).
- `intensity_at(point, world) -> float`:
  1. `cos_angle = direction.dot((point - position).normalize())`
  2. Outside outer cone → 0.0
  3. Inside fade angle → 1.0 if not shadowed, 0.0 if shadowed (using `world.is_shadowed_from`)
  4. Fade zone → linear interpolation, zeroed if shadowed.
- `__eq__`: compares all five fields.

### `rayz/texture_map.py`
`PPMImage` and `TextureMap(Pattern)`.

**PPMImage:**
- Constructor: `PPMImage(width, height)` — 2-D pixel array.
- `pixel_at(x, y) -> Color`: returns black for out-of-bounds.
- `set_pixel(x, y, color)`
- `classmethod load_ppm(filename) -> PPMImage`: parses P3 PPM; strips comments/blanks; reads width/height/max_color; converts RGB triples to `Color(r/max, g/max, b/max)`.

**TextureMap(Pattern):**
- Constructor: `TextureMap(image: PPMImage, uv_map: Callable)`
- `pattern_at(point) -> Color`: calls `uv_map(point)` → `(u, v)`; converts to pixel coords (`x = round(u*(w-1))`, `y = round((1-v)*(h-1))`); returns `image.pixel_at(x, y)`.
- `staticmethod planar_map`: `(x%1, z%1)`
- `staticmethod cylindrical_map`: theta = `atan2(x, z)`, u = `(theta+pi)/(2*pi)`, v = `y%1`
- `staticmethod spherical_map`: theta from `atan2(x,z)`, phi from `acos(y/radius)`, map to `[0,1]²`

---

## Section 2 — Library modifications

### `rayz/ray.py`
Add `time: float = 0.0` to constructor and store as `self.time`. `transform()` passes `time` to the new `Ray`.

### `rayz/material.py`
Add `normal_perturbation` to `__slots__`, initialised to `None`. No change to `__eq__` (perturbation is not part of material equality, matching Ruby).

### `rayz/lighting.py`
Change signature from `in_shadow: bool = False` to `intensity: float = 1.0`.

- Return `ambient` early when `intensity == 0.0`.
- Multiply `diffuse` and `specular` by `intensity`.
- Area light direction: if `light` has a `corner` attribute, compute center as `corner + uvec*(usteps/2) + vvec*(vsteps/2)`; otherwise use `light.position`. (PointLight and Spotlight both have `position`.)
- Update all callers: `world.py` passes `0.0` or `1.0` for point lights, or the float from `light.intensity_at()` for area/spot lights.

### `rayz/shape.py`
- Add `self.motion_transform = None` in `__init__` (callable `(time: float) -> Matrix`, or `None`).
- Update `intersect(self, ray)`: if `motion_transform` is set, compute `effective_inverse = (motion_transform(ray.time) @ self._transform).inverse()`; otherwise use cached `_transform_inverse`.
- Update `normal_at(self, world_point, hit=None)`: after `local_normal_at`, if `material.normal_perturbation` is not None, add `perturbation(local_point)` to `local_normal` then normalise before `normal_to_world`.
- Add abstract `bounds(self) -> Bounds` — raises `NotImplementedError` in base class.

### Shape subclasses — `bounds()` implementations

| File | Bounds (object space) |
|------|-----------------------|
| `sphere.py` | `Bounds(Point(-1,-1,-1), Point(1,1,1))` |
| `plane.py` | `Bounds(Point(-inf, 0, -inf), Point(inf, 0, inf))` |
| `cube.py` | `Bounds(Point(-1,-1,-1), Point(1,1,1))` |
| `cylinder.py` | min=`Point(-1, self.minimum, -1)`, max=`Point(1, self.maximum, 1)`; handle `inf`/`-inf` defaults |
| `cone.py` | `radius = max(abs(self.minimum), abs(self.maximum))`; `Bounds(Point(-radius, self.minimum, -radius), Point(radius, self.maximum, radius))` — handles `±inf` naturally |
| `triangle.py` | `Bounds` enclosing p1, p2, p3 (component-wise min/max of vertices) |
| `smooth_triangle.py` | inherits `Triangle.bounds()` — no override needed |
| `csg.py` | `left.bounds().transform(left.transform).merge(right.bounds().transform(right.transform))` |
| `group.py` | merge of all `child.bounds().transform(child.transform)` |

### `rayz/group.py`
- Add `bounds()` as described above (empty group → default empty `Bounds`).
- Update `local_intersect(ray)`: if `self.children` is non-empty and `not self.bounds().intersects(ray)`, return `[]` immediately.

### `rayz/camera.py`
Add constructor params (all keyword-or-positional with defaults):
- `samples_per_pixel: int = 1`
- `aperture_size: float = 0.0`
- `focal_distance: float = 1.0`
- `motion_blur: bool = False`

Update `ray_for_pixel(px, py, pixel_offset_x=0.5, pixel_offset_y=0.5, aperture_offset_x=0.0, aperture_offset_y=0.0, time=0.0)`:
- Canvas placed at `z = -focal_distance` instead of `z = -1`.
- Origin offset by `(aperture_offset * aperture_size)` in camera space.
- Returns `Ray(origin, direction, time=time)`.

Add `_render_pixel(x, y, world) -> Color`:
- Fast path when `samples_per_pixel == 1 and aperture_size == 0.0 and not motion_blur` (existing behaviour).
- Otherwise accumulate `samples_per_pixel` samples with random pixel offset (AA), random aperture offset (focal blur), random time in [0,1] (motion blur); return averaged colour.

Update `render_parallel` worker (`_render_chunk`) to call `_render_pixel` logic inline (subprocess must re-implement since `Camera` object is pickled).

### `rayz/world.py`
- Add `is_shadowed_from(self, point, light_position) -> bool`: vectors to light, casts shadow ray, early-exits on first blocking intersection (no sort needed).
- Update `is_shadowed(self, point)`:
  - `PointLight` → delegates to `is_shadowed_from`.
  - Light with `intensity_at` → returns `intensity_at(point, self) < 1.0`.
- Update `shade_hit(self, comps, remaining=3)`:
  - `PointLight` → `intensity = 0.0 if is_shadowed_from(...) else 1.0`
  - Light with `intensity_at` → `intensity = light.intensity_at(comps.over_point, self)`
  - Pass `intensity` (float) to `lighting()`.
- Update `intersect_world(self, ray)`: pass `ray` (not `obj.intersect(ray)` wrapper) — `shape.intersect` already reads `ray.time` internally; no API change needed.

---

## Section 3 — Demo scripts

### `examples/advanced_features_demo.py`
Scene: checkerboard floor, red sphere with `sine_wave` perturbation (left), green torus (centre), blue sphere with `quilted` perturbation (right). `PointLight` at `(-5, 10, -5)`. Camera 400×200, `samples_per_pixel=1`. Output: `examples/advanced_features_demo.ppm`. Printed footer notes area lights, spotlights, AA, focal blur, motion blur, and texture mapping as "also available."

### `examples/bounding_boxes_demo.py`
4×4 grid of `Group` objects, 6 spheres each (glass / metallic / coloured, random position+scale within cell). Checkerboard floor. `PointLight`. Camera 600×400. Output: `examples/bounding_boxes_demo.ppm`. Prints timing and total sphere/group count.

### `examples/nested_groups_demo.py`
- Solar system: Sun (level 0) → `earth_orbit` group → `earth_position` group → `earth_rotation` group → Earth sphere + `moon_orbit` group → `moon_position` group → Moon sphere (6 levels).
- Mars system: similar 5-level hierarchy with Phobos satellite.
- Space station: central hub sphere + 4 arm groups (cylinder + end sphere each), 3 levels.
- Reflective checkerboard floor. Camera 800×600. Output: `examples/nested_groups_demo.ppm`.

### `examples/run.py`
Add three entries to `CHAPTERS`:
```python
19: ("Bounding Boxes Demo", bb_demo),
20: ("Nested Groups Demo",  ng_demo),
21: ("Advanced Features Demo", af_demo),
```
Support string name lookup alongside integers by adding a `NAMES` dict:
```python
NAMES = {
    "bounding_boxes": 19,
    "nested_groups": 20,
    "advanced_features": 21,
    "obj_parser": 18,
}
```
When a CLI arg fails `int()` conversion, look it up in `NAMES` before printing "unknown".

---

## Section 4 — Out of scope

- BDD feature files for the new library components (torus, bounds, area_light, spotlight, texture_map, normal_perturbations). These can follow as a separate task.
- Crystal parallel variant for the benchmark.
- Any CLAUDE.md updates (those happen post-implementation).
