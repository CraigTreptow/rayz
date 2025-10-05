# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rayz is a Ruby implementation of a ray tracer based on "The Ray Tracer Challenge" book. It demonstrates 3D graphics concepts through progressive chapters, currently implementing Chapters 1-5 with projectile physics, canvas visualization, matrix operations, transformation matrices, and ray-sphere intersections.

## Development Commands

### Setup
```bash
mise install      # Install Ruby 3.4.5 (required)
bundle install    # Install gem dependencies
```

### Running the Application
```bash
ruby rayz         # Execute all implemented chapters (1, 2, 3, 4, and 5)
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
- `Sphere` - 3D sphere with transformation support and ray intersection calculations
- `Intersection` - Encapsulates intersection point (t value) and intersected object
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
- `tuples.feature` - Core mathematical operations
- `colors.feature` - Color arithmetic
- `canvas.feature` - Pixel operations and PPM export
- `matrices.feature` - Matrix operations
- `transformations.feature` - Transformation matrices (translation, scaling, rotation, shearing)
- `rays.feature` - Ray creation, position calculation, and transformations
- `spheres.feature` - Sphere-ray intersection tests (basic scenarios)
- `intersections.feature` - Intersection aggregation and hit detection

## Code Conventions

### Ruby Style
- Uses StandardRB for consistent formatting
- Ruby 3.4.5 with Prism parser
- Object-oriented design with clear inheritance hierarchies

### Mathematical Precision
- Custom equality comparison with floating-point tolerance (see `Util.==`)
- All mathematical operations return new objects (immutable style)
- Method chaining supported for transformations

### Development Workflow
1. Write Cucumber feature file first (BDD approach)
2. Implement step definitions
3. Create/modify Ruby classes
4. Run tests with `bundle exec cucumber`
5. Format code with `bundle exec standardrb --fix`

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

## Implementation Status

### Completed Chapters
- **Chapter 1**: Projectile physics simulation
- **Chapter 2**: Canvas and PPM export with parallel pixel writing
- **Chapter 3**: Matrix operations (construction, transpose, determinant, inverse, multiplication)
- **Chapter 4**: Transformation matrices (translation, scaling, rotation, shearing, view transform, chaining)
- **Chapter 5**: Ray-sphere intersections (ray casting, sphere transformations, hit detection, silhouette rendering)

### Test Coverage
- 20 scenarios passing for Chapter 5 (basic ray-sphere intersections)
- 8 feature files in `/features/` directory:
  - `tuples.feature` - Core mathematical operations
  - `colors.feature` - Color arithmetic
  - `canvas.feature` - Pixel operations and PPM export
  - `matrices.feature` - Matrix operations
  - `transformations.feature` - Transformation matrices with π and √ notation support
  - `rays.feature` - Ray creation, position calculation, and transformations (4 scenarios)
  - `spheres.feature` - Sphere-ray intersection tests (9 scenarios, normals/materials skipped)
  - `intersections.feature` - Intersection aggregation and hit detection (7 scenarios)
- Additional reference tests from the book in `/book_features/` for future implementation (normals, materials, lighting)