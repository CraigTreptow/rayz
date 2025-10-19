# Ray Tracer Performance Optimization Plan

## Executive Summary
The ray tracer has async infrastructure in the Canvas class, but the critical bottleneck is in Camera.render() which processes pixels sequentially. This plan outlines profiling strategies and optimization opportunities ranked by expected impact.

## Current State Analysis

### What's Already Optimized ✅
- **Bounding boxes** (Chapter 20): Groups use AABB to skip intersection tests
- **Async PPM export**: `ppm_body_async` parallelizes row processing during file export
- **Mutex protection**: Thread-safe canvas pixel writing

### Major Bottleneck Identified 🔴
- **Camera.render()** (camera.rb:69-93): Completely sequential pixel processing
  - Outer loop: `@vsize` rows (typically 400-800)
  - Inner loop: `@hsize` columns (typically 400-800)
  - Each pixel calls `render_pixel()` which:
    - Traces 1+ rays (up to `samples_per_pixel` for anti-aliasing/blur)
    - Each ray calls `world.color_at()` with recursive reflection/refraction
    - Shadow calculations, intersection tests, material calculations

### Current Async Implementation Issues
- `Canvas.write_pixel_async()` just calls synchronous version (no parallelization)
- Async is only used for PPM export (I/O bound, not compute bound)
- The compute-heavy work (ray tracing) is not parallelized

---

## Phase 1: Profiling & Baseline Metrics

### 1.1 Setup Profiling Tools
**Priority: HIGH** | **Effort: Low** | **Expected Impact: N/A (measurement)**

Tools to use:
- **ruby-prof**: Standard Ruby profiler with multiple output formats
- **stackprof**: Statistical sampling profiler (low overhead)
- **benchmark**: Simple timing comparisons
- **memory_profiler**: Identify allocation hotspots

```bash
# Add to Gemfile
gem 'ruby-prof', require: false
gem 'stackprof', require: false
gem 'memory_profiler', require: false
```

### 1.2 Create Profiling Harness
**Priority: HIGH** | **Effort: Low**

Create `examples/profile_render.rb`:
```ruby
require 'ruby-prof'
require 'memory_profiler'
require_relative '../lib/rayz'

# Small test scene for quick profiling
camera = Rayz::Camera.new(hsize: 200, vsize: 100, field_of_view: Math::PI / 3)
world = create_simple_test_world() # 3-5 objects, 1 light

# Profile CPU
RubyProf.start
image = camera.render(world)
result = RubyProf.stop

# Print flat profile showing method call times
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, min_percent: 2)

# Profile memory allocations
report = MemoryProfiler.report do
  camera.render(world)
end
report.pretty_print
```

### 1.3 Establish Baseline Metrics
**Priority: HIGH** | **Effort: Low**

Measure current performance:
- **Simple scene** (200x100, 5 objects): Expected ~5-10s
- **Medium scene** (400x200, 10 objects): Expected ~30-60s
- **Complex scene** (800x600, 20+ objects, reflections): Expected ~5-10 minutes
- **With anti-aliasing** (samples_per_pixel: 4): Expected 4x slower
- **Memory usage**: Peak allocations, GC pressure

Expected hotspots to confirm:
1. `Camera#render_pixel` (pixel loop)
2. `World#color_at` (ray tracing)
3. `Shape#intersect` (transformation matrix inversions)
4. `Matrix#inverse` (expensive operation)
5. `World#is_shadowed_from?` (shadow rays)

---

## Phase 2: High-Impact Optimizations

### 2.1 Parallelize Camera.render() - HIGHEST PRIORITY
**Priority: CRITICAL** | **Effort: Medium** | **Expected Impact: 3-8x speedup**

The current render loop is sequential - this is the biggest bottleneck.

**Current code** (camera.rb:74-82):
```ruby
(0...@vsize).each do |y|
  (0...@hsize).each do |x|
    color = render_pixel(x, y, world)
    image.write_pixel(row: @vsize - 1 - y, col: x, color: color)
  end
end
```

**Optimization approach:**

#### Option A: Row-level parallelization (Recommended)
```ruby
def render_async(world)
  image = Canvas.new(width: @hsize, height: @vsize)

  start_time = Time.now
  puts "Progress (each dot = 10 rows):"

  Async do |task|
    (0...@vsize).each do |y|
      task.async do
        print "." if y % 10 == 0

        (0...@hsize).each do |x|
          color = render_pixel(x, y, world)
          # Canvas already has mutex protection
          image.write_pixel(row: @vsize - 1 - y, col: x, color: color)
        end
      end
    end
  end.wait

  # ... timing code ...
  image
end
```

**Pros:**
- Simple to implement (follows existing async pattern)
- Canvas already has mutex for thread safety
- Coarse-grained parallelism reduces overhead
- Already using `async` gem

**Cons:**
- Row granularity may create load imbalance if some rows are more expensive

#### Option B: Tile-based parallelization (Advanced)
Break image into tiles (e.g., 32x32 or 64x64) for better load balancing.

**Pros:**
- Better load balancing (complex regions don't block entire rows)
- Better cache locality

**Cons:**
- More complex implementation
- More context switches

#### Option C: Thread pool with work queue
```ruby
require 'concurrent-ruby'

def render_threaded(world)
  image = Canvas.new(width: @hsize, height: @vsize)
  pool = Concurrent::FixedThreadPool.new(Concurrent.processor_count)

  (0...@vsize).each do |y|
    pool.post do
      (0...@hsize).each do |x|
        color = render_pixel(x, y, world)
        image.write_pixel(row: @vsize - 1 - y, col: x, color: color)
      end
    end
  end

  pool.shutdown
  pool.wait_for_termination
  image
end
```

**Recommendation:** Start with Option A (row-level with Async) since it's already in use.

**Expected results:**
- On 4-core CPU: 3-3.5x speedup
- On 8-core CPU: 5-7x speedup
- On 16-core CPU: 8-12x speedup

### 2.2 Cache Matrix Inversions
**Priority: HIGH** | **Effort: Low-Medium** | **Expected Impact: 1.2-1.5x speedup**

Every ray-shape intersection calls `@transform.inverse` (shape.rb:24). For static scenes, these inverses are constant.

**Current code** (shape.rb:15-26):
```ruby
def intersect(ray, time = 0.0)
  effective_transform = if @motion_transform
    @motion_transform.call(time) * @transform
  else
    @transform
  end

  local_ray = ray.transform(effective_transform.inverse)  # ← Computed every ray!
  # ...
end
```

**Optimization:**
```ruby
class Shape
  def initialize
    @transform = Matrix.identity(4)
    @transform_inverse = Matrix.identity(4)
    @transform_inverse_transpose = Matrix.identity(4)
    # ...
  end

  def transform=(matrix)
    @transform = matrix
    @transform_inverse = matrix.inverse
    @transform_inverse_transpose = matrix.inverse.transpose
  end

  def intersect(ray, time = 0.0)
    effective_transform_inverse = if @motion_transform
      (@motion_transform.call(time) * @transform).inverse  # Still needed for motion
    else
      @transform_inverse  # ← Cached!
    end

    local_ray = ray.transform(effective_transform_inverse)
    # ...
  end
end
```

**Also cache in normal_to_world** (shape.rb:59-75):
- Cache `@transform.inverse.transpose` to avoid recomputation

**Expected results:**
- Reduces expensive matrix operations by ~50%
- Speedup: 1.2-1.5x (varies by scene complexity)

### 2.3 Optimize Anti-Aliasing Sampling
**Priority: MEDIUM** | **Effort: Low** | **Expected Impact: 1.1-1.2x for AA scenes**

**Current code** (camera.rb:105-126):
```ruby
colors = []
@samples_per_pixel.times do
  # ... generate random offsets ...
  ray = ray_for_pixel(px, py, ...)
  colors << world.color_at(ray)
end

# Average all sampled colors
avg_red = colors.map(&:red).sum / colors.size.to_f
avg_green = colors.map(&:green).sum / colors.size.to_f
avg_blue = colors.map(&:blue).sum / colors.size.to_f
```

**Optimization:**
```ruby
# Accumulate instead of array allocation
total_red = 0.0
total_green = 0.0
total_blue = 0.0

@samples_per_pixel.times do
  ray = ray_for_pixel(px, py, ...)
  color = world.color_at(ray)
  total_red += color.red
  total_green += color.green
  total_blue += color.blue
end

divisor = @samples_per_pixel.to_f
Color.new(
  red: total_red / divisor,
  green: total_green / divisor,
  blue: total_blue / divisor
)
```

**Benefits:**
- No array allocation
- No intermediate Color objects
- Single division vs map/sum/division

---

## Phase 3: Medium-Impact Optimizations

### 3.1 Spatial Partitioning for World Objects
**Priority: MEDIUM** | **Effort: High** | **Expected Impact: 1.5-3x for complex scenes**

**Current approach** (world.rb:28-34):
```ruby
def intersect(ray)
  all_intersections = []
  @objects.each do |obj|  # ← Tests EVERY object
    all_intersections.concat(obj.intersect(ray, ray.time))
  end
  all_intersections.sort_by(&:t)
end
```

**Problem:** Tests every object in scene, even if ray is nowhere near it.

**Optimization:** Build a BVH (Bounding Volume Hierarchy) or Octree

**Benefits:**
- Skip large portions of scene with single bounds test
- Logarithmic vs linear intersection tests
- Bigger impact on scenes with 50+ objects

**Implementation complexity:** High (new data structure, scene preprocessing)

**Alternative:** Use existing Group bounds more aggressively
- Put all objects in top-level bounding group
- Current implementation only applies to explicit groups

### 3.2 Reduce Recursive Depth for Reflections
**Priority: LOW-MEDIUM** | **Effort: Very Low** | **Expected Impact: 1.1-1.3x**

**Current defaults:**
- Maximum recursion depth: 5 (world.rb:36, 46, 66, 104, 110)

**Optimization:**
```ruby
# Most realistic scenes don't need depth > 3
# Diminishing returns after 2-3 bounces
def color_at(ray, remaining = 3)  # ← Reduce from 5 to 3
```

**Trade-off:** Slightly less accurate reflections in complex glass/mirror scenes
**Benefit:** 20-30% reduction in recursive calls

### 3.3 Fast Path for Non-Reflective Materials
**Priority: MEDIUM** | **Effort: Low** | **Expected Impact: 1.1-1.2x**

**Current code** (world.rb:88-101):
```ruby
reflected = reflected_color(comps, remaining)  # ← Always computed
refracted = refracted_color(comps, remaining)  # ← Always computed

material = comps.object.material
if material.reflective > 0 && material.transparency > 0
  # Fresnel blending
else
  surface + reflected + refracted  # ← Often just zeros
end
```

**Optimization:**
```ruby
# Early return for non-reflective, opaque materials (most common case)
material = comps.object.material
if material.reflective == 0 && material.transparency == 0
  return surface  # ← Skip recursive calls entirely
end

reflected = reflected_color(comps, remaining)
refracted = refracted_color(comps, remaining)
# ... rest of logic
```

### 3.4 Optimize Shadow Calculations
**Priority: MEDIUM** | **Effort: Medium** | **Expected Impact: 1.1-1.5x**

**Current approach:**
- Every shaded point tests for shadow
- Shadow ray intersects ALL objects
- Can terminate early when first intersection found

**Optimization:**
```ruby
def is_shadowed_from?(point, light_position)
  v = light_position - point
  distance = v.magnitude
  direction = v.normalize

  r = Ray.new(origin: point, direction: direction)

  # Early termination: stop at first hit within distance
  @objects.each do |obj|
    intersections = obj.intersect(r, 0.0)
    intersections.each do |i|
      return true if i.t > 0 && i.t < distance  # ← Early exit
    end
  end

  false
end
```

---

## Phase 4: Memory & Allocation Optimizations

### 4.1 Reduce Object Allocations in Hot Paths
**Priority: MEDIUM** | **Effort: Medium** | **Expected Impact: 1.1-1.3x**

**Hotspots to investigate:**
- Color object creation (may allocate millions)
- Point/Vector creation in intersection tests
- Matrix allocations in transformations

**Profiling approach:**
```ruby
require 'memory_profiler'

report = MemoryProfiler.report do
  camera.render(world)
end

# Show top allocation sources
report.pretty_print(scale_bytes: true)
```

**Potential optimizations:**
- Object pooling for frequently created objects
- In-place operations where possible
- Reuse temporary buffers

### 4.2 Optimize Tuple/Vector/Point Operations
**Priority: LOW-MEDIUM** | **Effort: Medium**

These are called millions of times per render. Profile to confirm hotspots:
- Magnitude calculations (sqrt is expensive)
- Normalize operations
- Dot product

**Possible optimizations:**
- Cache magnitude when possible
- Use fast inverse square root approximations for normalization
- SIMD operations (via C extensions) for vector math

---

## Phase 5: Advanced Optimizations

### 5.1 Adaptive Sampling (Advanced)
**Priority: LOW** | **Effort: High** | **Expected Impact: 1.5-2x for AA**

Instead of fixed `samples_per_pixel`:
- Start with 1 sample per pixel
- Compare with neighbors
- Add more samples only where color variance is high (edges)

### 5.2 JIT Compilation with YJIT
**Priority: MEDIUM** | **Effort: Very Low** | **Expected Impact: 1.2-1.5x**

Ruby 3.4.5 includes YJIT (Just-In-Time compiler):

```bash
# Run with YJIT enabled
RUBY_YJIT_ENABLE=1 ruby rayz 21
```

**Expected benefits:**
- 20-50% speedup on math-heavy code
- No code changes required
- Test to verify it helps

### 5.3 Native Extensions for Math Operations
**Priority: LOW** | **Effort: Very High** | **Expected Impact: 2-4x**

Rewrite hottest math operations in C or Rust:
- Matrix inverse/multiply
- Vector operations
- Ray-shape intersection tests

**Complexity:** Very high, maintenance burden

---

## Implementation Priority Ranking

### Must Do (Weeks 1-2):
1. ✅ **Setup profiling** (1 day)
2. ✅ **Baseline metrics** (1 day)
3. 🔥 **Parallelize Camera.render()** (2-3 days) - **3-8x speedup**
4. 💰 **Cache matrix inversions** (2 days) - **1.2-1.5x speedup**

### Should Do (Weeks 3-4):
5. **Optimize anti-aliasing sampling** (1 day) - **1.1-1.2x speedup**
6. **Fast path for non-reflective materials** (1 day) - **1.1-1.2x speedup**
7. **Optimize shadow calculations** (2 days) - **1.1-1.5x speedup**
8. **Test YJIT** (1 hour) - **1.2-1.5x speedup**

### Could Do (Month 2+):
9. **Reduce recursive depth** (1 hour) - **1.1-1.3x speedup**
10. **Memory profiling & allocation reduction** (3-5 days) - **1.1-1.3x speedup**
11. **Spatial partitioning (BVH)** (1-2 weeks) - **1.5-3x for complex scenes**

### Advanced (Future):
12. **Adaptive sampling** (1-2 weeks)
13. **Native extensions** (1-2 months)

---

## Expected Cumulative Results

### Conservative Estimate:
- Parallel rendering: **4x** (4-core CPU)
- Cached matrix ops: **1.3x**
- Other optimizations: **1.2x**
- **Total: ~6-7x speedup**

### Optimistic Estimate:
- Parallel rendering: **7x** (8-core CPU)
- Cached matrix ops: **1.5x**
- Other optimizations: **1.5x**
- YJIT: **1.3x**
- **Total: ~12-15x speedup**

### Real-World Example:
- **Before:** Chapter 21 (800x600) = 10 minutes
- **After:** Chapter 21 (800x600) = 1-2 minutes

---

## Testing Strategy

### For Each Optimization:
1. **Profile before** (save baseline metrics)
2. **Implement** optimization
3. **Profile after** (measure improvement)
4. **Verify correctness** (run all Cucumber tests)
5. **Visual regression test** (compare rendered images)
6. **Document** results in this file

### Correctness Validation:
```bash
# All tests must still pass
bundle exec cucumber

# Compare rendered output (should be identical)
ruby examples/chapter7.rb  # Before optimization
cp examples/chapter7.ppm examples/chapter7_baseline.ppm

# After optimization
ruby examples/chapter7.rb
diff examples/chapter7.ppm examples/chapter7_baseline.ppm
# Should be identical (or within floating-point tolerance)
```

---

## Profiling Questions to Answer

From the user's question: **"Are async Canvas methods helpful?"**

**Answer:** The current async Canvas methods (`ppm_body_async`) only help with PPM export, which is I/O bound and typically <5% of total time. The big win is parallelizing the **render loop itself**, which is 90%+ of the time.

**Measurement approach:**
```ruby
# Test 1: Measure render time
start = Time.now
image = camera.render(world)
render_time = Time.now - start

# Test 2: Measure PPM export time
start = Time.now
ppm_sync = image.to_ppm
sync_time = Time.now - start

start = Time.now
ppm_async = image.to_ppm_async
async_time = Time.now - start

puts "Render: #{render_time}s"
puts "PPM sync: #{sync_time}s"
puts "PPM async: #{async_time}s"
```

**Expected results:**
- Render: 60s (95% of total)
- PPM sync: 3s (5% of total)
- PPM async: 1s (saves 2s, but tiny compared to render)

**Conclusion:** Async PPM helps marginally, but parallelizing render is 30x more important.

---

## Measurement Framework

### Benchmark Harness (`examples/benchmark.rb`)

This script measures performance before and after optimizations:

```ruby
#!/usr/bin/env ruby
require 'benchmark'
require 'json'
require_relative '../lib/rayz'

class PerformanceBenchmark
  RESULTS_FILE = 'performance_results.json'

  def self.run(label:, iterations: 3)
    puts "\n" + "="*60
    puts "BENCHMARK: #{label}"
    puts "="*60

    scenes = {
      small: create_small_scene,
      medium: create_medium_scene,
      complex: create_complex_scene
    }

    results = {}

    scenes.each do |scene_name, (camera, world)|
      puts "\n#{scene_name.to_s.upcase} SCENE (#{camera.hsize}x#{camera.vsize}):"

      times = []
      iterations.times do |i|
        print "  Iteration #{i+1}/#{iterations}..."
        time = Benchmark.realtime do
          camera.render(world)
        end
        times << time
        puts " #{time.round(2)}s"
      end

      avg = times.sum / times.size
      min = times.min
      max = times.max
      stddev = Math.sqrt(times.map { |t| (t - avg)**2 }.sum / times.size)

      results[scene_name] = {
        avg: avg.round(3),
        min: min.round(3),
        max: max.round(3),
        stddev: stddev.round(3),
        pixels: camera.hsize * camera.vsize,
        pixels_per_second: (camera.hsize * camera.vsize / avg).round(0)
      }

      puts "  Average: #{avg.round(2)}s"
      puts "  Min/Max: #{min.round(2)}s / #{max.round(2)}s"
      puts "  Std Dev: #{stddev.round(2)}s"
      puts "  Pixels/sec: #{(camera.hsize * camera.vsize / avg).round(0)}"
    end

    save_results(label, results)
    results
  end

  def self.compare(baseline_label:, optimized_label:)
    baseline = load_results(baseline_label)
    optimized = load_results(optimized_label)

    puts "\n" + "="*60
    puts "PERFORMANCE COMPARISON"
    puts "="*60
    puts "Baseline: #{baseline_label}"
    puts "Optimized: #{optimized_label}"
    puts "="*60

    [:small, :medium, :complex].each do |scene|
      b = baseline[scene.to_s]
      o = optimized[scene.to_s]

      speedup = b['avg'] / o['avg']
      improvement = ((speedup - 1.0) * 100).round(1)

      puts "\n#{scene.to_s.upcase} SCENE:"
      puts "  Baseline:  #{b['avg']}s (#{b['pixels_per_second']} px/s)"
      puts "  Optimized: #{o['avg']}s (#{o['pixels_per_second']} px/s)"
      puts "  Speedup:   #{speedup.round(2)}x (#{improvement}% faster)"
    end
  end

  private

  def self.create_small_scene
    # 200x100, simple sphere scene
    camera = Rayz::Camera.new(hsize: 200, vsize: 100, field_of_view: Math::PI / 3)
    camera.transform = Rayz::Transformations.view_transform(
      from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
      to: Rayz::Point.new(x: 0, y: 1, z: 0),
      up: Rayz::Vector.new(x: 0, y: 1, z: 0)
    )

    world = Rayz::World.new
    world.light = Rayz::PointLight.new(
      position: Rayz::Point.new(x: -10, y: 10, z: -10),
      intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
    )

    # Floor
    floor = Rayz::Plane.new
    floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)
    floor.material.specular = 0

    # 3 spheres
    s1 = Rayz::Sphere.new
    s1.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 0)
    s1.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)

    world.objects << floor << s1

    [camera, world]
  end

  def self.create_medium_scene
    # 400x200, multiple objects
    camera = Rayz::Camera.new(hsize: 400, vsize: 200, field_of_view: Math::PI / 3)
    camera.transform = Rayz::Transformations.view_transform(
      from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
      to: Rayz::Point.new(x: 0, y: 1, z: 0),
      up: Rayz::Vector.new(x: 0, y: 1, z: 0)
    )

    world = Rayz::World.new
    world.light = Rayz::PointLight.new(
      position: Rayz::Point.new(x: -10, y: 10, z: -10),
      intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
    )

    # Floor & walls
    floor = Rayz::Plane.new
    floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)

    # 10 spheres in a grid
    [-2, 0, 2].each do |x|
      [-2, 0, 2].each do |z|
        s = Rayz::Sphere.new
        s.transform = Rayz::Transformations.translation(x: x, y: 1, z: z)
        s.material.color = Rayz::Color.new(
          red: (x + 2) / 4.0,
          green: (z + 2) / 4.0,
          blue: 0.5
        )
        world.objects << s
      end
    end

    world.objects << floor

    [camera, world]
  end

  def self.create_complex_scene
    # 400x300, reflections and shadows
    camera = Rayz::Camera.new(hsize: 400, vsize: 300, field_of_view: Math::PI / 3)
    camera.transform = Rayz::Transformations.view_transform(
      from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
      to: Rayz::Point.new(x: 0, y: 1, z: 0),
      up: Rayz::Vector.new(x: 0, y: 1, z: 0)
    )

    world = Rayz::World.new
    world.light = Rayz::PointLight.new(
      position: Rayz::Point.new(x: -10, y: 10, z: -10),
      intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
    )

    # Reflective floor
    floor = Rayz::Plane.new
    floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)
    floor.material.reflective = 0.3
    floor.material.specular = 0.3

    # Glass sphere
    glass = Rayz::Sphere.new
    glass.transform = Rayz::Transformations.translation(x: -1.5, y: 1, z: 0)
    glass.material.transparency = 0.9
    glass.material.refractive_index = 1.5
    glass.material.reflective = 0.9

    # Mirror sphere
    mirror = Rayz::Sphere.new
    mirror.transform = Rayz::Transformations.translation(x: 1.5, y: 1, z: 0)
    mirror.material.reflective = 0.8
    mirror.material.color = Rayz::Color.new(red: 0.9, green: 0.9, blue: 0.9)

    # Regular sphere
    matte = Rayz::Sphere.new
    matte.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 1)
    matte.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)

    world.objects << floor << glass << mirror << matte

    [camera, world]
  end

  def self.save_results(label, results)
    all_results = File.exist?(RESULTS_FILE) ? JSON.parse(File.read(RESULTS_FILE)) : {}
    all_results[label] = {
      'timestamp' => Time.now.iso8601,
      'results' => results.transform_values { |v| v.transform_keys(&:to_s) }
    }
    File.write(RESULTS_FILE, JSON.pretty_generate(all_results))
    puts "\nResults saved to #{RESULTS_FILE}"
  end

  def self.load_results(label)
    all_results = JSON.parse(File.read(RESULTS_FILE))
    all_results[label]['results']
  end
end

# Run if executed directly
if __FILE__ == $0
  label = ARGV[0] || "baseline"
  puts "Running benchmark: #{label}"
  PerformanceBenchmark.run(label: label)
end
```

### Measurement Protocol for Each Optimization

#### Step 1: Capture Baseline
```bash
# Run baseline before making any changes
ruby examples/benchmark.rb baseline

# This creates performance_results.json with baseline metrics
```

#### Step 2: Implement Optimization
```bash
# Example: Parallelize rendering
git checkout -b optimize-parallel-render

# Make changes to camera.rb
# ... implement parallel rendering ...

# Verify tests still pass
bundle exec cucumber
```

#### Step 3: Measure Improvement
```bash
# Run benchmark with optimization
ruby examples/benchmark.rb parallel-render

# Compare results
ruby -r ./examples/benchmark -e "PerformanceBenchmark.compare(
  baseline_label: 'baseline',
  optimized_label: 'parallel-render'
)"
```

#### Step 4: Verify Correctness
```bash
# Visual regression test
ruby -r ./examples/chapter7 -e "Rayz::Chapter7.run"
cp examples/chapter7.ppm examples/chapter7_baseline.ppm

# After optimization
ruby -r ./examples/chapter7 -e "Rayz::Chapter7.run"

# Images should be identical (or within floating-point tolerance)
# Can use imagemagick to compare:
compare -metric RMSE examples/chapter7_baseline.ppm examples/chapter7.ppm null:
# Should output: 0 (0) if identical
```

### Per-Optimization Measurement Checklist

For each optimization in the plan, we'll measure:

#### ✅ Optimization 2.1: Parallel Rendering
**Measurement:**
```bash
ruby examples/benchmark.rb baseline
# Implement parallel rendering
ruby examples/benchmark.rb parallel-render
ruby -r ./examples/benchmark -e "PerformanceBenchmark.compare(...)"
```

**Expected metrics:**
- Small scene: 2-4x speedup
- Medium scene: 3-6x speedup
- Complex scene: 4-8x speedup (more parallelizable)
- Pixels/second: Should increase proportionally

**Success criteria:**
- Speedup ≥ 3x on 4+ core CPU
- All Cucumber tests pass
- Rendered images identical to baseline

---

#### ✅ Optimization 2.2: Cache Matrix Inversions
**Measurement:**
```bash
# Profile matrix operations before
ruby -r ruby-prof -r ./lib/rayz -e '
  RubyProf.start
  # render small scene
  result = RubyProf.stop
  result.eliminate_methods!([/^(Array|Hash|Integer)/])
  RubyProf::FlatPrinter.new(result).print(STDOUT)
' | grep inverse

# After caching
ruby examples/benchmark.rb cached-matrix
ruby -r ./examples/benchmark -e "PerformanceBenchmark.compare(...)"
```

**Expected metrics:**
- `Matrix#inverse` calls should drop by 50-90%
- Small scene: 1.2-1.3x speedup
- Medium scene: 1.3-1.4x speedup
- Complex scene: 1.4-1.5x speedup

**Success criteria:**
- Speedup ≥ 1.2x
- Matrix inverse calls significantly reduced (verify with profiler)
- All tests pass

---

#### ✅ Optimization 2.3: Optimize Anti-Aliasing
**Measurement:**
```bash
# Create AA test scene
ruby -e '
  require_relative "./lib/rayz"
  camera = Rayz::Camera.new(
    hsize: 200,
    vsize: 100,
    field_of_view: Math::PI / 3,
    samples_per_pixel: 4  # ← AA enabled
  )
  # ... render and time
'

# Before optimization
time ruby examples/test_aa.rb  # with array allocation

# After optimization
time ruby examples/test_aa.rb  # with accumulation
```

**Expected metrics:**
- Memory allocations: -50% (from memory_profiler)
- Speedup: 1.1-1.2x (modest but measurable)
- GC time: Reduced

**Success criteria:**
- Speedup ≥ 1.1x for AA scenes
- Fewer Color object allocations
- Visual output identical

---

### Memory Profiling Template

For optimization steps involving memory:

```ruby
require 'memory_profiler'

puts "BEFORE OPTIMIZATION:"
report = MemoryProfiler.report do
  camera.render(world)
end

puts "\nTop 10 allocations:"
report.pretty_print(scale_bytes: true, top: 10)

# Implement optimization

puts "\nAFTER OPTIMIZATION:"
report = MemoryProfiler.report do
  camera.render(world)
end
report.pretty_print(scale_bytes: true, top: 10)
```

**Metrics to track:**
- Total allocated memory
- Total retained memory
- Allocations per class (Color, Point, Vector, Matrix)
- GC runs

---

### Continuous Performance Tracking

Create `examples/performance_monitor.rb` for ongoing tracking:

```ruby
#!/usr/bin/env ruby
require_relative 'benchmark'

# Run on every commit/PR to detect regressions
results = PerformanceBenchmark.run(label: "current")

# Load baseline
baseline = PerformanceBenchmark.load_results("baseline")

# Check for regressions
[:small, :medium, :complex].each do |scene|
  baseline_time = baseline[scene.to_s]['avg']
  current_time = results[scene]['avg']

  regression_threshold = 1.1  # 10% slower is a regression

  if current_time > baseline_time * regression_threshold
    puts "⚠️  REGRESSION in #{scene}: #{current_time}s vs #{baseline_time}s baseline"
    exit 1
  end
end

puts "✅ No performance regressions detected"
```

**Usage in CI/PR checks:**
```bash
# Add to GitHub Actions or pre-commit hook
ruby examples/performance_monitor.rb || echo "Performance regression detected!"
```

---

## Deliverables

1. ✅ This performance plan document
2. 📊 Profiling harness (`examples/profile_render.rb`)
3. 📈 **Benchmark harness (`examples/benchmark.rb`)** ← NEW
4. 📊 **Performance monitoring (`examples/performance_monitor.rb`)** ← NEW
5. 📋 Baseline metrics report (`performance_results.json`)
6. 🚀 Parallel render implementation (with before/after benchmarks)
7. ⚡ Cached matrix inversions (with before/after benchmarks)
8. 📝 Performance benchmarks document (summary of all optimizations)
9. ✅ All tests still passing
10. 🎨 Visual regression tests (baseline images for comparison)

---

## Questions for User

1. **Target hardware:** How many CPU cores on typical machine? (affects parallelization strategy)
2. **Target render time:** What's acceptable? (affects optimization priorities)
3. **Most common scenes:** Simple or complex? Reflections? (affects optimization focus)
4. **CI/testing:** Any parallel tests concerns? (async may affect test determinism)

---

## Notes & References

- **Async gem docs:** https://github.com/socketry/async
- **Ruby profiling guide:** https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
- **Matrix optimization:** Consider using `matrix` gem alternatives (NArray, Numo)
- **BVH resources:** "Physically Based Rendering" book (pbrt)
- **Ray tracing optimization:** "Ray Tracing in One Weekend" series

---

**Last Updated:** 2025-10-19
**Author:** Performance analysis for Rayz ray tracer
**Status:** Initial plan - ready for Phase 1 (profiling)
