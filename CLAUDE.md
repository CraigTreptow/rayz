# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rayz is a Ruby implementation of a ray tracer based on ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book by Jamis Buck.

**Book Implementation (Chapters 1-17):** Complete implementation of all chapters from the book, covering projectile physics, canvas visualization, matrix operations, transformation matrices, ray-sphere intersections, Phong shading, reflection/refraction, hierarchical scene composition, triangle primitives, constructive solid geometry, and smooth triangles with normal interpolation.

**Custom Extension Demos:** Additional demonstration programs beyond the book including Wavefront OBJ file parsing, enhanced shape hierarchy with world-to-object/normal-to-world transformations, bounding box optimization for performance, and advanced rendering features (torus primitives, area lights, spotlights, anti-aliasing, focal blur, motion blur, texture mapping, normal perturbation).

## Development Commands

### Setup
```bash
mise install      # Install Ruby 3.4.5 (required)
bundle install    # Install gem dependencies
```

### Running the Application
```bash
./rayz                             # Execute all chapters (1-17) and demos (YJIT enabled by default)
./rayz all                         # Explicitly run all chapters and demos
./rayz 4                           # Run only chapter 4
ruby examples/run 7                # Alternative: run examples directly (YJIT enabled)
ruby examples/run obj_parser       # Run OBJ parser demo
ruby examples/run nested_groups    # Run nested groups demo
ruby examples/run bounding_boxes   # Run bounding boxes demo
ruby examples/run advanced_features # Run advanced features demo
```

**Note:** YJIT is enabled by default in all scripts for 4-5x performance improvement. Ruby 3.4+ with YJIT support is required (see Installation section).

**Output Formatting:** Each chapter and demo script outputs a visual separator line (`puts "\n" + ("=" * 60) + "\n"`) after completion for better readability when running multiple examples sequentially.

### Testing
```bash
bundle exec cucumber                    # Run all implemented tests
bundle exec cucumber features/         # Run working features only
bundle exec cucumber features/tuples.feature  # Run specific feature
```

### Code Quality
```bash
bundle exec standardrb       # Check code style
bundle exec standardrb --fix # Auto-fix formatting issues
```

## Architecture

### Core Mathematical Foundation
The project is built on a mathematical hierarchy centered around 4D tuples:

- `Tuple` - Base class with x,y,z,w coordinates and mathematical operations
- `Point` - Inherits from Tuple with w=1.0 (positions in 3D space)  
- `Vector` - Inherits from Tuple with w=0.0 (directions/displacements)

Key files: `lib/rayz/tuple.rb`, `lib/rayz/point.rb`, `lib/rayz/vector.rb`

### Graphics Components
- `Canvas` - 2D pixel grid with PPM export, origin at bottom-left, Y-axis increases upward
- `Color` - RGB color representation with arithmetic operations
- `Matrix` - Matrix operations using Ruby's stdlib Matrix with custom utility methods for cofactor, minor, determinant, and inversion
- `Transformations` - Static methods for creating transformation matrices (translation, scaling, rotation, shearing, view transform)
- `Ray` - Ray with origin (Point) and direction (Vector), supports position calculation and transformations
- `Sphere` - 3D sphere with transformation support, ray intersection calculations, material properties, and surface normal calculation
- `Plane` - Infinite flat surface with constant normals
- `Cube` - Axis-aligned bounding box (AABB) from -1 to +1 on all axes
- `Cylinder` - Cylindrical primitive with radius 1, supports truncation (min/max) and end caps (closed)
- `Cone` - Double-napped cone aligned with y-axis (equation: x² + z² = y²), supports truncation and end caps
- `Triangle` - Triangle primitive defined by three vertices, uses Möller-Trumbore intersection algorithm, flat shading with constant normal
- `SmoothTriangle` - Extends Triangle with vertex normals for smooth shading using barycentric interpolation of normals
- `Group` - Abstract shape that contains child shapes, enabling hierarchical scene composition with parent-child relationships
- `CSG` (Constructive Solid Geometry) - Combines two shapes using set operations (union, intersection, difference) to create complex composite shapes
- `OBJParser` - Parses Wavefront OBJ files to load 3D models, supports vertices (v), vertex normals (vn), faces (f), named groups (g), polygon triangulation, and smooth/flat shading
- `Bounds` - Axis-aligned bounding box (AABB) with min/max extents for optimization, supports merging, transformation, ray intersection testing, and point/bounds containment checks
- `Torus` - Donut-shaped primitive with configurable major_radius and minor_radius, uses quartic equation solving via Durand-Kerner method for ray-torus intersection
- `Shape` - Base class for all geometric primitives with `parent` attribute for hierarchy, `transform` and `material` attributes, `bounds()` method for bounding box calculation, template methods for `local_intersect` and `local_normal_at`, `includes?` method for hierarchical shape searching, `world_to_object` and `normal_to_world` methods for coordinate space transformations through parent hierarchy, optional `motion_transform` callback for motion blur
- `Intersection` - Encapsulates intersection point (t value) and intersected object, with optional u/v barycentric coordinates for smooth triangles
- `Material` - Surface properties for Phong shading (color, ambient, diffuse, specular, shininess, reflective, transparency, refractive_index, normal_perturbation)
- `PointLight` - Point light source with position (Point) and intensity (Color)
- `AreaLight` - Rectangular area light source with configurable grid sampling for soft shadows, backward compatible with PointLight
- `Spotlight` - Directional light with cone-shaped beam, configurable cone angle and fade angle for soft edges
- `TextureMap` - Image-based surface pattern with UV mapping (planar, cylindrical, spherical), integrates with pattern system
- `NormalPerturbations` - Module providing preset normal perturbation effects (sine_wave, quilted, noise, ripples) for bump/displacement mapping
- `Camera` - Camera with view transformation, supports anti-aliasing (samples_per_pixel), focal blur (aperture_size, focal_distance), and motion blur (motion_blur flag)
- `lighting` - Module function implementing Phong reflection model for realistic shading
- `Computations` - Encapsulates precomputed intersection data (point, eyev, normalv, reflectv, n1, n2, under_point, over_point)
- `glass_sphere` - Helper function creating spheres with glass material (transparency=1.0, refractive_index=1.5)
- `schlick` - Schlick approximation for Fresnel effect calculations
- `reflected_color` - Computes color from reflective surfaces using recursive ray tracing
- `refracted_color` - Computes color from transparent surfaces using Snell's law and refraction
- Coordinate system follows mathematical convention (not screen coordinates)

### Physics Simulation
- `Projectile` - Object with position (Point) and velocity (Vector)
- `Environment` - Contains gravity and wind forces as Vectors
- Chapter demonstration scripts in `/examples/` showcase progressive complexity

### Performance Optimization

The ray tracer includes several performance optimizations providing **4-5x speedup** on complex scenes:

#### YJIT Just-In-Time Compilation
**The most effective optimization**: Ruby 3.4's YJIT JIT compiler provides dramatic performance improvements with zero code changes.

**Requirements**:
- Ruby 3.4+ compiled with `--enable-yjit` flag
- Enable YJIT with `ruby --yjit` command-line flag

**Performance impact** (baseline vs YJIT):
- Tiny scene (100×50): 2.89s → 0.71s (4.08x faster)
- Small scene (150×100): 9.51s → 2.36s (4.03x faster)
- Medium scene (200×150): 86.76s → 17.55s (4.94x faster)

**Usage**:
```bash
ruby --yjit rayz                    # Run with YJIT enabled
ruby --yjit examples/benchmark.rb   # Benchmark with YJIT
```

#### Matrix Inverse Caching
Second most significant optimization: shapes cache their transformation matrix inverses when the transform is set, eliminating hundreds of thousands of redundant O(n³) inverse calculations during rendering.

**Implementation** (`lib/rayz/shape.rb`):
- `@transform_inverse` - Cached inverse matrix
- `@transform_inverse_transpose` - Cached inverse transpose for normal transformations
- Both computed once in `transform=` setter, reused for all ray intersections

**Performance impact** (baseline vs cached, no YJIT):
- Tiny scene (100×50): 2.89s → 1.08s (2.66x faster)
- Small scene (150×100): 9.51s → 3.83s (2.49x faster)
- Medium scene (200×150): 86.76s → 27.74s (3.13x faster)

**Combined impact** (YJIT + matrix caching):
- YJIT with matrix caching: 0.71s (tiny), 2.36s (small), 17.55s (medium)
- Provides 1.5x speedup over matrix caching alone
- Provides 4-5x speedup over baseline

#### Async Canvas Operations
Uses the `async` gem for concurrent pixel writing with mutex protection for thread-safe canvas operations. Note: async provides minimal speedup (~5%) since rendering (not I/O) is the bottleneck.

#### Benchmarking Tools
Performance measurement infrastructure in `/examples/`:
- `benchmark.rb` - Statistical benchmarking with multiple iterations, saves results to `performance_results.json`
- `show_results.rb` - Terminal display of all benchmark results with comparison
- `visualize_results.rb` - Generates interactive HTML dashboard with Chart.js graphs

**Usage**:
```bash
ruby examples/benchmark.rb baseline          # Run baseline benchmark
ruby --yjit examples/benchmark.rb with-yjit  # Run YJIT benchmark
ruby examples/show_results.rb                 # Display results in terminal
ruby examples/visualize_results.rb            # Generate HTML visualization
open performance_results.html                 # View graphs in browser
```

#### Attempted Optimizations (Not Effective)
- **Thread-based parallelism** - Ruby's GVL prevents true CPU parallelism for compute-bound work (0.95x speedup, actually slower due to thread overhead)
- **Ractor-based parallelism** - Marshal serialization overhead too high (2x slower on small scenes)

## Testing Strategy

### Behavior-Driven Development with Cucumbe
- Primary testing uses Cucumber with Gherkin syntax
- Working tests in `/features/` directory
- Reference tests from the book in `/book_features/` (future implementations)
- Step definitions in `/features/step_definitions/`

### Test Structure
- `tuples.feature` - Core mathematical operations including vector reflection
- `colors.feature` - Color arithmetic
- `canvas.feature` - Pixel operations and PPM export
- `matrices.feature` - Matrix operations
- `transformations.feature` - Transformation matrices (translation, scaling, rotation, shearing)
- `rays.feature` - Ray creation, position calculation, and transformations
- `spheres.feature` - Sphere-ray intersection, surface normals, and materials
- `intersections.feature` - Intersection aggregation and hit detection
- `lights.feature` - Point light source creation
- `materials.feature` - Material properties and Phong lighting model
- `world.feature` - World and camera for scene rendering
- `patterns.feature` - Surface patterns (stripe, gradient, ring, checkers)
- `planes.feature` - Infinite plane intersections and normals
- `reflections.feature` - Reflection, refraction, and Fresnel effects
- `cubes.feature` - Cube primitive with ray-cube intersection and normals
- `cylinders.feature` - Cylinder primitive with truncation, end caps, and normals
- `groups.feature` - Group hierarchy, parent-child relationships, and intersection aggregation
- `cones.feature` - Cone primitive with ray-cone intersection and normals
- `triangles.feature` - Triangle primitive with Möller-Trumbore intersection algorithm
- `smooth-triangles.feature` - Smooth triangles with normal interpolation
- `csg.feature` - Constructive Solid Geometry with union, intersection, and difference operations
- `obj_file.feature` - OBJ file parser with vertex, normal, face parsing, and group support

## Code Conventions

### Ruby Style
- Uses StandardRB for consistent formatting
- Ruby 3.4.5 with Prism parser
- Object-oriented design with clear inheritance hierarchies
- **Named parameters**: All class constructors use named parameters for clarity (e.g., `Point.new(x: 0, y: 1, z: 2)`, `Camera.new(hsize: 400, vsize: 200, field_of_view: Math::PI / 3)`)

### Mathematical Precision
- Custom equality comparison with floating-point tolerance (see `Util.==`)
- All mathematical operations return new objects (immutable style)
- Method chaining supported for transformations

### Development Workflow
1. **Always create a new branch** for any changes (never work directly on master)
2. Write Cucumber feature file first (BDD approach)
3. Implement step definitions
4. Create/modify Ruby classes
5. Run tests with `bundle exec cucumber`
6. Format code with `bundle exec standardrb --fix`
7. **Always open a pull request** when work is complete

## Key Dependencies
- `async` - Parallel processing for pixel writes
- `cucumber` - BDD testing framework  
- `matrix` - Matrix operations for 3D transformations
- `standard` - Ruby code formatter/linter
- `debug` - Debugging support

## Project Structure
- `/lib/rayz/` - Core ray tracer library (mathematical foundations, primitives, rendering engine)
- `/examples/` - Chapter demonstration scripts and their output files
- `/features/` - Cucumber BDD tests for implemented features
- `/book_features/` - Reference tests from the book for future implementation
- `/book/` - Reference book in epub format

## Output Files
- PPM image files generated in the `examples/` directory for visual demonstrations
- Canvas coordinate system: origin bottom-left, Y increases upward
- Generated files in `examples/`:
  - `chapter2.ppm` - Projectile trajectory visualization
  - `chapter3.ppm` - Clock face using rotation matrices
  - `chapter4.ppm` - Analog clock at 3:00 using transformation matrices
  - `chapter5.ppm` - Sphere silhouette rendered using ray casting
  - `chapter6.ppm` - Shaded 3D sphere with Phong lighting
  - `chapter7.ppm` - Scene with multiple spheres, walls, and shadows
  - `chapter8.ppm` - Scene with patterns (stripes, gradients, rings, checkers)
  - `chapter9.ppm` - Scene with infinite planes and spheres
  - `chapter10.ppm` - Scene with reflective and refractive materials (mirrors and glass)
  - `chapter11.ppm` - Scene with cubes (room with table and boxes)
  - `chapter12.ppm` - Scene with cylinders (table with candles and various cylinder objects)
  - `chapter13.ppm` - Scene with hierarchical groups (tree, snowman, hexagon)
  - `chapter14.ppm` - Scene with cones (traffic cone, glass cone, metal cone, ice cream, hourglass)
  - `chapter15.ppm` - Scene with triangles (pyramid, octahedron, tetrahedron)
  - `chapter16.ppm` - Scene with CSG shapes (carved cube, lens, hollow sphere, die, rounded cylinder, wedge-cut sphere)
  - `chapter17.ppm` - Scene demonstrating smooth shading vs flat shading (smooth and flat pyramids)
  - `obj_parser_demo.ppm` - Scene with 3D model loaded from Wavefront OBJ file (tetrahedron)
  - `nested_groups_demo.ppm` - Scene demonstrating hierarchical transformations (solar system with nested planetary orbits, space station with rotating arms)
  - `bounding_boxes_demo.ppm` - Scene with many grouped marbles demonstrating bounding box optimization for performance improvement
  - `advanced_features_demo.ppm` - Scene showcasing advanced features (torus primitive, normal perturbation with wavy and quilted spheres, reflective materials)

## Implementation Status

### Book Chapters (1-17) - ✅ Complete
All chapters from "The Ray Tracer Challenge" book are fully implemented:

- **Chapter 1**: Projectile physics simulation
- **Chapter 2**: Canvas and PPM export with parallel pixel writing
- **Chapter 3**: Matrix operations (construction, transpose, determinant, inverse, multiplication)
- **Chapter 4**: Transformation matrices (translation, scaling, rotation, shearing, view transform, chaining)
- **Chapter 5**: Ray-sphere intersections (ray casting, sphere transformations, hit detection, silhouette rendering)
- **Chapter 6**: Light and Shading (Phong reflection model, point lights, materials, surface normals, realistic lighting)
- **Chapter 7**: Making a Scene (world, camera, view transformations, shadows)
- **Chapter 8**: Patterns (stripe, gradient, ring, checkers patterns with transformations)
- **Chapter 9**: Planes (infinite flat surfaces, plane-ray intersections)
- **Chapter 10**: Reflection and Refraction (mirrors, glass, Fresnel effect, recursive ray tracing)
- **Chapter 11**: Cubes (axis-aligned bounding boxes, ray-cube intersection algorithm)
- **Chapter 12**: Cylinders (cylindrical primitives with truncation and end caps)
- **Chapter 13**: Groups (hierarchical scene composition, parent-child relationships, transform cascading)
- **Chapter 14**: Cones (double-napped cones with Möller-Trumbore-style intersection, truncation, and end caps)
- **Chapter 15**: Triangles (triangle primitive with Möller-Trumbore intersection algorithm, flat shading)
- **Chapter 16**: Constructive Solid Geometry (CSG union, intersection, and difference operations to combine primitives into complex shapes)
- **Chapter 17**: Smooth Triangles (smooth shading using vertex normals and barycentric interpolation, creates smooth gradients across triangle surfaces)

### Custom Extension Demos - Beyond the Book
Additional features implemented beyond the book's scope (these are demonstration programs, not book chapters):

- **OBJ Parser Demo**: Wavefront OBJ file parser for loading 3D models, supports vertices, normals, faces, groups, fan triangulation, automatic smooth/flat shading
- **Nested Groups Demo**: Enhanced Shape class with world_to_object and normal_to_world methods that properly traverse parent hierarchy for hierarchical transformations
- **Bounding Boxes Demo**: Axis-aligned bounding box optimization for Groups, dramatically reduces intersection tests by skipping groups when rays miss their bounds, includes bounds transformation, merging, and hierarchical bounding box calculation
- **Advanced Features Demo**: Torus primitive with quartic equation solving, area lights with soft shadows via grid sampling, spotlights with directional beams, anti-aliasing via supersampling, focal blur/depth of field, motion blur with time-based transformations, texture mapping with UV coordinates, normal perturbation for bump/displacement effects

### Test Coverage
- 295 scenarios passing (346 total scenarios in features/, 51 undefined for additional edge cases)
- 23 feature files in `/features/` directory:
  - `tuples.feature` - Core mathematical operations including vector reflection
  - `colors.feature` - Color arithmetic
  - `canvas.feature` - Pixel operations and PPM export
  - `matrices.feature` - Matrix operations
  - `transformations.feature` - Transformation matrices with π and √ notation support
  - `rays.feature` - Ray creation, position calculation, and transformations
  - `spheres.feature` - Sphere-ray intersection, surface normals, materials
  - `intersections.feature` - Intersection aggregation and hit detection
  - `lights.feature` - Point light sources
  - `materials.feature` - Material properties and Phong lighting
  - `world.feature` - World and camera for scene rendering
  - `patterns.feature` - Surface patterns (stripe, gradient, ring, checkers)
  - `planes.feature` - Infinite plane intersections and normals
  - `reflections.feature` - Reflection, refraction, and Fresnel effects
  - `cubes.feature` - Cube primitive with ray-cube intersection and normals
  - `cylinders.feature` - Cylinder primitive with truncation, end caps, and normals
  - `groups.feature` - Group hierarchy, parent-child relationships, and intersection aggregation
  - `cones.feature` - Cone primitive with ray-cone intersection and normals
  - `triangles.feature` - Triangle primitive with Möller-Trumbore intersection algorithm
  - `smooth-triangles.feature` - Smooth triangles with normal interpolation
  - `csg.feature` - Constructive Solid Geometry with union, intersection, and difference operations
  - `obj_file.feature` - OBJ file parser with vertex, normal, face parsing, and group support
  - `bounding_boxes.feature` - Bounding box optimization with bounds creation, transformation, merging, intersection testing, and group optimization
  - `shapes.feature` - Abstract shape tests for world_to_object and normal_to_world transformations
- Additional reference tests from the book in `/book_features/` for future implementation

### Assertions and Testing
- Use Minitest assertions (`assert`, `assert_equal`, `assert_in_delta`, `assert_nil`, `refute_nil`) not RSpec's `expect`
- For floating-point comparisons with infinity, use `assert_equal` for infinite values and `assert_in_delta` for finite values
- Step definitions should avoid ambiguous patterns that could match multiple scenarios