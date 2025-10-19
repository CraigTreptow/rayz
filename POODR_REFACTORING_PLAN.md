# POODR Refactoring Plan

Analysis of the Rayz ray tracer codebase through the lens of Sandi Metz's "Practical Object-Oriented Design in Ruby" (POODR).

**Date**: 2025-10-19
**Status**: Planning Phase

---

## 🔴 Critical Issues

### 1. Law of Demeter Violations - Excessive Reach-Through

**Problem**: Multiple locations reach through multiple objects to access nested attributes.

**Examples**:
```ruby
# lib/rayz/world.rb:66
comps.object.material.reflective
comps.object.material.transparency

# lib/rayz/lighting.rb:2
material.pattern.pattern_at_shape(object, point)

# Chapter files everywhere:
sphere.material.color = Color.new(...)
sphere.material.diffuse = 0.7
```

**Sandi says**: "Use only one dot" - reaching through multiple objects creates tight coupling and makes change difficult.

**Solution**:
```ruby
# Option 1: Delegate in Material
class Material
  def reflective?
    @reflective > 0
  end

  def transparent?
    @transparency > 0
  end

  def color_at(object, point)
    @pattern ? @pattern.pattern_at_shape(object, point) : @color
  end
end

# Option 2: Delegate in Shape
class Shape
  def reflective?
    @material.reflective > 0
  end

  def surface_color_at(point)
    @material.color_at(self, point)
  end
end

# Usage becomes:
comps.object.reflective?  # instead of comps.object.material.reflective > 0
```

**Files affected**: `world.rb`, `lighting.rb`, all example chapters

---

### 2. Type Checking with `is_a?` Instead of Duck Typing

**Problem**: Using class checking instead of trusting objects to respond to messages.

**Examples**:
```ruby
# lib/rayz/world.rb:69-76
if @light.is_a?(PointLight)
  shadowed = is_shadowed?(comps.over_point)
  intensity = shadowed ? 0.0 : 1.0
elsif @light.respond_to?(:intensity_at)
  intensity = @light.intensity_at(comps.over_point, self)
else
  intensity = 1.0
end

# lib/rayz/lighting.rb:21-28
if light.respond_to?(:corner)
  # Area light - use center
  light_center = light.corner + light.uvec * (light.usteps / 2.0) + light.vvec * (light.vsteps / 2.0)
  lightv = (light_center - point).normalize
else
  # Point light - use position
  lightv = (light.position - point).normalize
end
```

**Sandi says**: "Trust objects to know what they are" - use duck typing and polymorphism.

**Solution**:
```ruby
# All light types implement same interface
class PointLight
  def intensity_at(point, world)
    world.is_shadowed_from?(point, position) ? 0.0 : 1.0
  end

  def direction_from(point)
    (position - point).normalize
  end
end

class AreaLight
  def intensity_at(point, world)
    # existing implementation
  end

  def direction_from(point)
    light_center = @corner + @uvec * (@usteps / 2.0) + @vvec * (@vsteps / 2.0)
    (light_center - point).normalize
  end
end

class Spotlight
  def intensity_at(point, world)
    # existing implementation
  end

  def direction_from(point)
    (@position - point).normalize
  end
end

# Usage becomes:
intensity = @light.intensity_at(comps.over_point, self)
lightv = light.direction_from(point)
```

**Files affected**: `world.rb`, `lighting.rb`, `point_light.rb`, `area_light.rb`, `spotlight.rb`

---

### 3. Module Functions Instead of Proper Objects

**Problem**: Global functions in the `Rayz` module should be objects.

**Examples**:
```ruby
# lib/rayz/intersection.rb
def self.intersections(*intersections)
def self.hit(intersections)
def self.schlick(comps)

# lib/rayz/lighting.rb
def self.lighting(material, light, point, eyev, normalv, intensity = 1.0, object = nil)
```

**Sandi says**: "Depend on behavior, not data" - these are procedural, not object-oriented.

**Solution**:
```ruby
# Create proper objects
class IntersectionList
  def initialize(intersections)
    @intersections = intersections.sort
  end

  def hit
    @intersections.find { |i| i.t >= 0 }
  end

  def each(&block)
    @intersections.each(&block)
  end
end

class SurfaceShader
  def initialize(material:, light:, point:, eyev:, normalv:, intensity:, object:)
    @material = material
    @light = light
    @point = point
    @eyev = eyev
    @normalv = normalv
    @intensity = intensity
    @object = object
  end

  def compute
    # existing lighting logic
    ambient + diffuse + specular
  end

  private

  def effective_color
    surface_color * @light.intensity
  end

  def surface_color
    @material.color_at(@object, @point)
  end

  def ambient
    effective_color * @material.ambient
  end

  def diffuse
    # existing diffuse calculation
  end

  def specular
    # existing specular calculation
  end
end

class FresnelCalculator
  def self.reflectance(comps)
    # existing schlick implementation
  end
end

# Usage:
intersection_list = IntersectionList.new([i1, i2, i3])
hit = intersection_list.hit

shader = SurfaceShader.new(material: m, light: l, point: p, ...)
color = shader.compute
```

**Files affected**: `intersection.rb`, `lighting.rb`, all files that use these module functions

---

### 4. Single Responsibility Violations - God Object `World`

**Problem**: `World` class has too many responsibilities.

**World currently does**:
- Manages objects collection
- Manages light
- Ray intersection
- Shadow calculation (multiple methods)
- Reflection calculation
- Refraction calculation
- Shading calculation
- Color calculation

**Sandi says**: "A class should have only one reason to change."

**Solution**:
```ruby
# Separate concerns into focused objects

class Scene
  def initialize(objects:, light:)
    @objects = objects
    @light = light
  end

  attr_reader :objects, :light

  def intersect(ray)
    all_intersections = []
    @objects.each do |obj|
      all_intersections.concat(obj.intersect(ray, ray.time))
    end
    IntersectionList.new(all_intersections)
  end
end

class ShadowCalculator
  def initialize(scene)
    @scene = scene
  end

  def intensity_at(point)
    @scene.light.intensity_at(point, @scene)
  end

  def shadowed_from?(point, light_position)
    v = light_position - point
    distance = v.magnitude
    direction = v.normalize

    r = Ray.new(origin: point, direction: direction)
    intersection_list = @scene.intersect(r)
    h = intersection_list.hit

    !!(h && h.t < distance)
  end
end

class ReflectionCalculator
  def color_for(comps, renderer, remaining)
    return Color::BLACK if remaining <= 0
    return Color::BLACK if comps.object.material.reflective == 0

    reflect_ray = Ray.new(origin: comps.over_point, direction: comps.reflectv)
    color = renderer.color_at(reflect_ray, remaining - 1)

    color * comps.object.material.reflective
  end
end

class RefractionCalculator
  def color_for(comps, renderer, remaining)
    return Color::BLACK if remaining <= 0
    return Color::BLACK if comps.object.material.transparency == 0

    # Check for total internal reflection
    n_ratio = comps.n1 / comps.n2
    cos_i = comps.eyev.dot(comps.normalv)
    sin2_t = n_ratio * n_ratio * (1 - cos_i * cos_i)

    return Color::BLACK if sin2_t > 1.0

    # Compute refracted ray direction
    cos_t = Math.sqrt(1.0 - sin2_t)
    direction = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio

    # Create and trace refracted ray
    refract_ray = Ray.new(origin: comps.under_point, direction: direction)
    renderer.color_at(refract_ray, remaining - 1) * comps.object.material.transparency
  end
end

class Renderer
  def initialize(scene:, max_reflections: 5)
    @scene = scene
    @shadow_calculator = ShadowCalculator.new(scene)
    @reflection_calculator = ReflectionCalculator.new
    @refraction_calculator = RefractionCalculator.new
    @max_reflections = max_reflections
  end

  def color_at(ray, remaining = @max_reflections)
    intersection_list = @scene.intersect(ray)
    hit = intersection_list.hit
    return Color::BLACK unless hit

    comps = hit.prepare_computations(ray, intersection_list)
    shade_hit(comps, remaining)
  end

  private

  def shade_hit(comps, remaining)
    intensity = @shadow_calculator.intensity_at(comps.over_point)

    shader = SurfaceShader.new(
      material: comps.object.material,
      light: @scene.light,
      point: comps.point,
      eyev: comps.eyev,
      normalv: comps.normalv,
      intensity: intensity,
      object: comps.object
    )
    surface = shader.compute

    reflected = @reflection_calculator.color_for(comps, self, remaining)
    refracted = @refraction_calculator.color_for(comps, self, remaining)

    blend_colors(surface, reflected, refracted, comps)
  end

  def blend_colors(surface, reflected, refracted, comps)
    material = comps.object.material
    if material.reflective > 0 && material.transparency > 0
      reflectance = FresnelCalculator.reflectance(comps)
      surface + reflected * reflectance + refracted * (1 - reflectance)
    else
      surface + reflected + refracted
    end
  end
end

# Usage:
scene = Scene.new(objects: [sphere1, sphere2], light: light)
renderer = Renderer.new(scene: scene)
color = renderer.color_at(ray)
```

**Files affected**: `world.rb` (would be split into multiple files)
**New files**: `scene.rb`, `shadow_calculator.rb`, `reflection_calculator.rb`, `refraction_calculator.rb`, `renderer.rb`

---

### 5. Dependency Injection Missing

**Problem**: Objects create their own dependencies instead of receiving them.

**Examples**:
```ruby
# lib/rayz/shape.rb:10
def initialize
  @transform = Matrix.identity(4)
  @material = Material.new  # <- hardcoded dependency
  @parent = nil
end

# lib/rayz/world.rb:13-20 (default_world)
s1 = Sphere.new  # <- creates sphere internally
s1.material.color = Color.new(...)  # <- then mutates it
```

**Sandi says**: "Inject dependencies" - don't hardcode object creation.

**Solution**:
```ruby
class Shape
  def initialize(material: Material.new, transform: Matrix.identity(4))
    @material = material
    @transform = transform
    @parent = nil
  end
end

# Usage:
custom_material = Material.new.tap do |m|
  m.color = Color.new(red: 0.8, green: 1.0, blue: 0.6)
  m.diffuse = 0.7
end
sphere = Sphere.new(material: custom_material)

# Or use a builder:
class MaterialBuilder
  def self.glossy_red
    Material.new.tap do |m|
      m.color = Color.new(red: 1, green: 0, blue: 0)
      m.diffuse = 0.7
      m.specular = 0.9
    end
  end

  def self.glass
    Material.new.tap do |m|
      m.transparency = 1.0
      m.refractive_index = 1.5
    end
  end
end

sphere = Sphere.new(material: MaterialBuilder.glass)
```

**Files affected**: `shape.rb`, `world.rb`, all example chapters

---

### 6. Tell, Don't Ask Violations

**Problem**: Objects ask for data and make decisions instead of telling objects what to do.

**Examples**:
```ruby
# lib/rayz/world.rb:36-43
return Color.new(red: 0, green: 0, blue: 0) if remaining <= 0
return Color.new(red: 0, green: 0, blue: 0) if comps.object.material.reflective == 0

reflect_ray = Ray.new(origin: comps.over_point, direction: comps.reflectv)
color = color_at(reflect_ray, remaining - 1)

color * comps.object.material.reflective
```

**Sandi says**: "Tell objects what you want, don't ask them for their data to make decisions."

**Solution**:
```ruby
# Encapsulate decisions inside objects
class Computations
  def reflective?
    @object.material.reflective > 0
  end

  def reflectivity
    @object.material.reflective
  end

  def transparent?
    @object.material.transparency > 0
  end

  def needs_fresnel?
    reflective? && transparent?
  end
end

class ReflectionCalculator
  def color_for(comps, renderer, remaining)
    return Color::BLACK unless should_reflect?(comps, remaining)

    reflected_ray = Ray.new(origin: comps.over_point, direction: comps.reflectv)
    renderer.color_at(reflected_ray, remaining - 1) * comps.reflectivity
  end

  private

  def should_reflect?(comps, remaining)
    remaining > 0 && comps.reflective?
  end
end
```

**Files affected**: `world.rb`, `intersection.rb` (Computations class)

---

## 🟡 Medium Priority Issues

### 7. Primitive Obsession with `attr_accessor`

**Problem**: All those `attr_accessor` declarations expose internals and invite Law of Demeter violations.

**Current**:
```ruby
class Camera
  attr_accessor :hsize, :vsize, :field_of_view, :transform, :samples_per_pixel, :aperture_size, :focal_distance, :motion_blur
end

# Invites mutation:
camera.samples_per_pixel = 4
camera.aperture_size = 0.1
```

**Solution**: Use `attr_reader` by default, provide intention-revealing methods instead.

```ruby
class Camera
  attr_reader :hsize, :vsize, :field_of_view

  def initialize(hsize:, vsize:, field_of_view:, transform: Matrix.identity(4))
    @hsize = hsize
    @vsize = vsize
    @field_of_view = field_of_view
    @transform = transform
    @samples_per_pixel = 1
    @aperture_size = 0.0
    @focal_distance = 1.0
    @motion_blur = false

    calculate_pixel_size
  end

  def with_transform(transform)
    @transform = transform
    self
  end

  def with_anti_aliasing(samples)
    @samples_per_pixel = samples
    self
  end

  def with_focal_blur(aperture_size:, focal_distance:)
    @aperture_size = aperture_size
    @focal_distance = focal_distance
    self
  end

  def with_motion_blur
    @motion_blur = true
    self
  end
end

# Usage:
camera = Camera.new(hsize: 800, vsize: 600, field_of_view: Math::PI / 3)
  .with_anti_aliasing(4)
  .with_focal_blur(aperture_size: 0.1, focal_distance: 10)
  .with_motion_blur
```

**Files affected**: `camera.rb`, `material.rb`, `shape.rb`

---

### 8. Data Clumps

**Problem**: Parameters that always travel together should be objects.

**Examples**:
```ruby
# lib/rayz/camera.rb:36
def ray_for_pixel(px, py, pixel_offset_x: 0.5, pixel_offset_y: 0.5,
                  aperture_offset_x: 0.0, aperture_offset_y: 0.0, time: 0.0)
```

**Solution**:
```ruby
class PixelSample
  attr_reader :x, :y, :pixel_offset_x, :pixel_offset_y,
              :aperture_offset_x, :aperture_offset_y, :time

  def initialize(x:, y:, pixel_offset_x: 0.5, pixel_offset_y: 0.5,
                 aperture_offset_x: 0.0, aperture_offset_y: 0.0, time: 0.0)
    @x = x
    @y = y
    @pixel_offset_x = pixel_offset_x
    @pixel_offset_y = pixel_offset_y
    @aperture_offset_x = aperture_offset_x
    @aperture_offset_y = aperture_offset_y
    @time = time
  end

  def self.center(x, y)
    new(x: x, y: y)
  end

  def self.random(x, y, with_aperture: false, with_motion: false)
    new(
      x: x,
      y: y,
      pixel_offset_x: rand,
      pixel_offset_y: rand,
      aperture_offset_x: with_aperture ? (rand * 2 - 1) : 0.0,
      aperture_offset_y: with_aperture ? (rand * 2 - 1) : 0.0,
      time: with_motion ? rand : 0.0
    )
  end
end

# Usage:
sample = PixelSample.center(100, 200)
ray = camera.ray_for_pixel(sample)

sample = PixelSample.random(100, 200, with_aperture: true, with_motion: true)
ray = camera.ray_for_pixel(sample)
```

**Files affected**: `camera.rb`

---

### 9. Missing Value Objects

**Problem**: Using primitives instead of value objects.

**Examples**:
```ruby
# Returning raw arrays/hashes instead of objects
def bounds
  { min: @min, max: @max }
end

# Using bare Color.new everywhere
Color.new(red: 0, green: 0, blue: 0)
```

**Solution**:
```ruby
class Color
  BLACK = Color.new(red: 0, green: 0, blue: 0)
  WHITE = Color.new(red: 1, green: 1, blue: 1)
  RED = Color.new(red: 1, green: 0, blue: 0)
  GREEN = Color.new(red: 0, green: 1, blue: 0)
  BLUE = Color.new(red: 0, green: 0, blue: 1)
end

# Usage:
return Color::BLACK if remaining <= 0
```

**Files affected**: `color.rb`, all files using colors

---

## 🟢 Strengths (Good POODR Practices)

These are things the codebase does well:

1. ✅ **Named parameters** - Excellent! Makes interfaces clear and self-documenting
2. ✅ **Template Method pattern** in `Shape` - Good use of inheritance with `local_intersect` and `local_normal_at`
3. ✅ **Immutable operations** - Mathematical operations return new objects instead of mutating
4. ✅ **Clear inheritance hierarchies** - Shape subclasses (Sphere, Plane, Cube, etc.) are well-designed
5. ✅ **BDD testing** - Tests drive design and document behavior
6. ✅ **Separation of concerns** - Examples separate from library code
7. ✅ **Module namespacing** - Everything in `Rayz` module prevents global pollution

---

## 📋 Recommended Refactoring Priority

### Phase 1: Duck Typing (Low Risk, High Value)
**Start here** - Most visible improvement with least risk.

1. **Extract Light interface** - Eliminate `is_a?` checks
   - Add `intensity_at` to `PointLight`
   - Add `direction_from` to all light types
   - Remove all type checking in `world.rb` and `lighting.rb`
   - **Estimated effort**: 2-3 hours
   - **Risk**: Low (isolated to light classes)

### Phase 2: Extract Rendering Collaborators (Medium Risk, High Value)
**Second priority** - Breaks up God object, improves testability.

2. **Extract SurfaceShader** from `Rayz.lighting`
   - Convert module function to object
   - Isolate lighting logic
   - **Estimated effort**: 3-4 hours
   - **Risk**: Medium (many callers)

3. **Extract Scene from World**
   - Just objects + light management
   - **Estimated effort**: 2 hours
   - **Risk**: Low

4. **Extract ShadowCalculator from World**
   - Shadow-related methods
   - **Estimated effort**: 2 hours
   - **Risk**: Low

5. **Extract ReflectionCalculator and RefractionCalculator**
   - Separate concerns
   - **Estimated effort**: 3 hours
   - **Risk**: Medium

6. **Create Renderer to orchestrate**
   - Final assembly
   - **Estimated effort**: 3 hours
   - **Risk**: Medium

### Phase 3: Improve Encapsulation (Low Risk, Medium Value)
**Third priority** - Reduces coupling, improves maintainability.

7. **Add delegation methods** - Reduce Law of Demeter violations
   - Add methods to `Material`, `Shape`, `Computations`
   - **Estimated effort**: 4-5 hours
   - **Risk**: Low (just adding methods)

8. **Extract IntersectionList**
   - Convert module functions to object
   - **Estimated effort**: 2 hours
   - **Risk**: Low

### Phase 4: Dependency Injection (Medium Risk, Medium Value)
**Fourth priority** - Better for testing, more flexible.

9. **Inject Material into Shape**
   - Optional parameter with default
   - **Estimated effort**: 2 hours
   - **Risk**: Medium (touches all Shape creation)

10. **Create MaterialBuilder/Factory**
    - Simplify common material creation
    - **Estimated effort**: 2 hours
    - **Risk**: Low

### Phase 5: Polish (Low Risk, Low Value)
**Last priority** - Nice to have but not critical.

11. **Add Color constants**
12. **Convert `attr_accessor` to fluent interface**
13. **Extract PixelSample value object**

---

## 🎯 Quick Win: Start Here

If you want to see immediate benefits with minimal risk, start with **Phase 1: Duck Typing**.

```ruby
# Before: Type checking
if @light.is_a?(PointLight)
  intensity = is_shadowed?(point) ? 0.0 : 1.0
elsif @light.respond_to?(:intensity_at)
  intensity = @light.intensity_at(point, self)
end

# After: Duck typing
intensity = @light.intensity_at(point, self)
```

This single change:
- Removes all type checking
- Makes code easier to test (just mock the interface)
- Makes it trivial to add new light types
- Demonstrates POODR principles clearly

---

## 📚 References

- Metz, Sandi. "Practical Object-Oriented Design in Ruby" (POODR)
- Key POODR principles applied:
  - Chapter 3: Managing Dependencies
  - Chapter 4: Creating Flexible Interfaces
  - Chapter 5: Duck Typing
  - Chapter 6: Acquiring Behavior Through Inheritance
  - Chapter 8: Combining Objects with Composition

---

## ⚠️ Important Notes

- **Don't refactor without tests**: All 370 scenarios must pass after each change
- **Small steps**: Make one change at a time, commit after each green test run
- **Backward compatibility**: Consider keeping old interfaces temporarily with deprecation warnings
- **Performance**: Profile before/after if making significant changes to hot paths (like `lighting`)
- **Book constraints**: Some design decisions driven by "The Ray Tracer Challenge" book - document where we diverge

---

## 🔄 Migration Strategy

For breaking changes (like World → Scene + Renderer):

1. **Create new classes** alongside old ones
2. **Add deprecation warnings** to old World methods
3. **Update examples** one at a time to use new API
4. **Update tests** to use new API
5. **Remove old code** only after everything migrated

Example:
```ruby
class World
  def color_at(ray, remaining = 5)
    warn "[DEPRECATED] World#color_at is deprecated. Use Renderer#color_at instead."
    renderer = Renderer.new(scene: to_scene)
    renderer.color_at(ray, remaining)
  end

  private

  def to_scene
    Scene.new(objects: @objects, light: @light)
  end
end
```
