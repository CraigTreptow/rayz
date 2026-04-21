# Ray Tracer Profiling & Benchmarking Guide

This guide explains how to use the profiling and benchmarking tools to measure and optimize ray tracer performance.

## Quick Start

### 1. Install Profiling Dependencies

```bash
bundle install  # Installs ruby-prof, stackprof, memory_profiler
```

### 2. Run Baseline Benchmark

```bash
ruby examples/benchmark.rb baseline
```

This will:
- Render 3 test scenes (small, medium, complex)
- Run each scene 3 times for statistical accuracy
- Save results to `performance_results.json`
- Display timing statistics

### 3. Profile CPU Hotspots

```bash
ruby examples/profile_render.rb cpu
```

Generates:
- `profile_graph.html` - Interactive call graph
- `profile_stack.html` - Call stack visualization
- Console output showing top methods by time

### 4. Profile Memory Usage

```bash
ruby examples/profile_render.rb memory
```

Generates:
- `profile_memory.txt` - Detailed memory allocation report
- Console output showing top allocation sources

## Workflow for Optimizations

### Step 1: Capture Baseline

```bash
# Run before making any changes
ruby examples/benchmark.rb baseline
```

### Step 2: Make Your Optimization

```bash
# Create a branch
git checkout -b optimize-something

# Make changes to the code
# ...

# Verify tests still pass
bundle exec cucumber
```

### Step 3: Measure Improvement

```bash
# Run benchmark with a descriptive label
ruby examples/benchmark.rb after-optimization

# Compare results
ruby examples/compare_benchmarks.rb baseline after-optimization
```

Output will show:
```
PERFORMANCE COMPARISON
============================================================
Baseline: baseline
Optimized: after-optimization
============================================================

SMALL SCENE:
  Baseline:  2.5s (8000 px/s)
  Optimized: 0.8s (25000 px/s)
  Speedup:   3.13x (213% faster)
```

### Step 4: Verify Correctness

```bash
# Render a visual test
ruby -r ./examples/chapter7 -e "Rayz::Chapter7.run"

# Compare output visually or with imagemagick:
compare -metric RMSE examples/chapter7_baseline.ppm examples/chapter7.ppm null:
```

## Available Tools

### `examples/benchmark.rb`

**Purpose:** Statistical performance benchmarking across multiple scenes

**Usage:**
```bash
# Run with default label "baseline"
ruby examples/benchmark.rb

# Run with custom label
ruby examples/benchmark.rb my-optimization

# Programmatic use
ruby -r ./examples/benchmark -e "
  PerformanceBenchmark.run(label: 'test', iterations: 5)
"
```

**Output:**
- Saves results to `performance_results.json`
- Shows avg/min/max/stddev timings
- Calculates pixels per second

**Test Scenes:**
- **Small:** 200×100, 4 objects, simple materials
- **Medium:** 400×200, 10 objects, grid layout
- **Complex:** 400×300, 4 objects, reflections + refraction

### `examples/profile_render.rb`

**Purpose:** Identify CPU and memory hotspots

**Usage:**
```bash
# Profile both CPU and memory
ruby examples/profile_render.rb

# Profile CPU only
ruby examples/profile_render.rb cpu

# Profile memory only
ruby examples/profile_render.rb memory
```

**CPU Profiling Output:**
- `profile_graph.html` - Visual call graph (open in browser)
- `profile_stack.html` - Call stack flame graph
- Console: Top methods sorted by total time

**Memory Profiling Output:**
- `profile_memory.txt` - Detailed allocation report
- Console: Top allocating classes

**Use Cases:**
- Find which methods consume the most CPU time
- Identify memory allocation hotspots
- Discover unexpected method calls

### `examples/compare_benchmarks.rb`

**Purpose:** Compare two benchmark runs

**Usage:**
```bash
ruby examples/compare_benchmarks.rb baseline optimized-version
```

**Output:**
- Side-by-side timing comparison
- Speedup multiplier (e.g., 3.5x faster)
- Improvement percentage

**Example:**
```bash
# Before optimization
ruby examples/benchmark.rb baseline

# After optimization
ruby examples/benchmark.rb parallel-render

# Compare
ruby examples/compare_benchmarks.rb baseline parallel-render
```

## Interpreting Results

### CPU Profiling

Look for methods with high **total time**:
- `Camera#render` - Expected to be high (main render loop)
- `World#color_at` - Ray tracing logic
- `Matrix#inverse` - Expensive operation (optimization target!)
- `Shape#intersect` - Core intersection tests

**Red flags:**
- Unexpected methods in top 10
- Heavy GC time (memory pressure)
- Deep call stacks with many intermediate methods

### Memory Profiling

Look for classes with high allocation counts:
- `Color` - Millions of allocations expected
- `Point` / `Vector` - High allocations in ray tracing
- `Matrix` - Should be relatively low (reused)
- `Array` / `Hash` - General purpose, watch for excessive growth

**Red flags:**
- Allocations in hot paths (inside pixel loops)
- Large retained memory (memory leaks)
- Excessive GC runs (thrashing)

### Benchmark Statistics

- **Average time:** Main metric for comparison
- **Standard deviation:** Low is better (consistent performance)
- **Pixels/second:** Throughput metric (higher is better)

**What to expect:**
- First run may be slower (cold caches, JIT warmup)
- Variance should be < 10% (if higher, increase iterations)
- Complex scenes scale worse than simple (more ray bounces)

## Performance Targets

Based on typical hardware:

### Current (Sequential Rendering)
- Small (200×100):  ~2-5 seconds
- Medium (400×200): ~10-20 seconds
- Complex (400×300): ~30-60 seconds

### After Parallel Rendering (Expected)
- Small:  ~0.5-1.5 seconds (3-4x speedup)
- Medium: ~2-5 seconds (4-5x speedup)
- Complex: ~5-10 seconds (5-8x speedup)

**Factors affecting performance:**
- CPU cores (more = better for parallel)
- Reflection depth (depth 5 vs 3)
- Anti-aliasing (samples_per_pixel: 4 = 4x slower)
- Object count (more objects = more tests)
- Material complexity (glass/mirrors = recursive rays)

## Profiling Best Practices

1. **Always profile before optimizing**
   - Premature optimization wastes time
   - Profile shows real bottlenecks

2. **Use small test scenes for quick iteration**
   - Full 800×600 renders are slow
   - Small scenes (100×50) profile faster

3. **Run benchmarks multiple times**
   - Variance is normal (OS scheduling, GC)
   - 3-5 iterations gives statistical confidence

4. **Measure incrementally**
   - One optimization at a time
   - Easier to identify what helped

5. **Verify correctness after each optimization**
   - Run Cucumber tests
   - Visual regression testing
   - Floating-point math can drift

## Common Optimization Opportunities

### High Impact (3-8x speedup)
- Parallelize `Camera#render()` loop
- Use all CPU cores for pixel rendering

### Medium Impact (1.2-1.5x speedup)
- Cache `Matrix#inverse` calculations
- Cache `Matrix#inverse.transpose` for normals
- Avoid redundant transformations

### Low Impact (1.1-1.2x speedup)
- Reduce object allocations in hot paths
- Optimize anti-aliasing sampling (avoid arrays)
- Early return for non-reflective materials
- Shadow ray early termination

## Files Generated

After running profiling tools, you'll see:

```
performance_results.json     # Benchmark timing data
profile_graph.html          # CPU call graph
profile_stack.html          # CPU call stack
profile_memory.txt          # Memory allocation report
```

**Add to .gitignore:**
```
performance_results.json
profile_*.html
profile_*.txt
```

## Troubleshooting

### "Cannot load such file -- ruby-prof"
```bash
bundle install
```

### Benchmark takes too long
```bash
# Use fewer iterations
ruby -r ./examples/benchmark -e "
  PerformanceBenchmark.run(label: 'quick', iterations: 1)
"
```

### Profile files are huge
- Normal for complex scenes
- Use smaller test scenes for profiling
- HTML files can be 10-50 MB

### Results vary wildly
- Close other applications
- Increase iteration count
- Check for background processes (Docker, VMs)

## Next Steps

After establishing baseline:

1. **Identify bottlenecks** with `profile_render.rb`
2. **Implement optimization** (see PERFORMANCE_OPTIMIZATION_PLAN.md)
3. **Measure improvement** with `benchmark.rb`
4. **Verify correctness** with tests
5. **Document results** in performance plan

See `PERFORMANCE_OPTIMIZATION_PLAN.md` for detailed optimization strategies.
