# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rayz is a Ruby implementation of a ray tracer based on "The Ray Tracer Challenge" book. It demonstrates 3D graphics concepts through progressive chapters, currently implementing Chapters 1-6 with projectile physics, canvas visualization, matrix operations, transformation matrices, ray-sphere intersections, and Phong shading.

## Development Commands

### Setup
```bash
mise install      # Install Ruby 3.4.5 (required)
bundle install    # Install gem dependencies
```

### Running the Application
```bash
ruby rayz         # Execute all implemented chapters (1-9)
```

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
- `Intersection` - Encapsulates intersection point (t value) and intersected object
- `Material` - Surface properties for Phong shading (color, ambient, diffuse, specular, shininess, reflective, transparency, refractive_index)
- `PointLight` - Point light source with position (Point) and intensity (Color)
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
- Chapter implementations demonstrate progressive complexity

### Parallelization
Uses the `async` gem for concurrent pixel writing with mutex protection for thread-safe canvas operations.

## Testing Strategy

### Behavior-Driven Development with Cucumber
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

## Output Files
- PPM image files generated for visual demonstrations
- Canvas coordinate system: origin bottom-left, Y increases upward
- Generated files:
  - `chapter2.ppm` - Projectile trajectory visualization
  - `chapter3_clock.ppm` - Clock face using rotation matrices
  - `chapter4_clock.ppm` - Analog clock at 3:00 using transformation matrices
  - `chapter5_sphere.ppm` - Sphere silhouette rendered using ray casting
  - `chapter6.ppm` - Shaded 3D sphere with Phong lighting
  - `chapter7.ppm` - Scene with multiple spheres, walls, and shadows
  - `chapter8.ppm` - Scene with patterns (stripes, gradients, rings, checkers)
  - `chapter9.ppm` - Scene with infinite planes and spheres
  - `chapter10.ppm` - Scene with reflective and refractive materials (mirrors and glass)
  - `chapter11.ppm` - Scene with cubes (room with table and boxes)

## Implementation Status

### Completed Chapters
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

### Test Coverage
- 173 scenarios passing (215 total scenarios, 42 undefined for future chapters)
- 14 feature files in `/features/` directory:
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
- Additional reference tests from the book in `/book_features/` for future implementation