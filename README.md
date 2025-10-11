# Rayz

An implementation of a ray tracer based on the ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book in Ruby.

## Installation

This project requires Ruby 3.4+ and several system dependencies for proper gem compilation.

### Prerequisites

**Install required system libraries:**

Using **apt-get** (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install -y zlib1g-dev libssl-dev libreadline-dev libyaml-dev libffi-dev build-essential
```

Using **brew** (macOS/Linux):
```bash
brew install zlib openssl readline libyaml libffi
```

### Ruby Version Management

This project uses [mise-en-place](https://mise.jdx.dev/) to manage the Ruby version.

**Install mise:**
```bash
# macOS/Linux with brew
brew install mise

# Or with curl
curl https://mise.jdx.dev/install.sh | sh
```

**Install Ruby and dependencies:**
```bash
# Install the specified Ruby version
mise install

# Install Ruby gems
bundle install
```

**Alternative: Manual Ruby Installation**

If not using mise, ensure you have Ruby 3.4+ installed with the system libraries above, then run:
```bash
gem install bundler
bundle install
```

## Running

Execute all chapter demonstrations:
```bash
ruby rayz
```

This runs demonstrations from Chapters 1-12 and generates PPM image files.

Run individual chapters:
```bash
ruby -r ./lib/rayz -e "Rayz::Chapter1.run"
ruby -r ./lib/rayz -e "Rayz::Chapter2.run"
ruby -r ./lib/rayz -e "Rayz::Chapter3.run"
ruby -r ./lib/rayz -e "Rayz::Chapter4.run"
ruby -r ./lib/rayz -e "Rayz::Chapter5.run"
ruby -r ./lib/rayz -e "Rayz::Chapter6.run"
ruby -r ./lib/rayz -e "Rayz::Chapter7.run"
ruby -r ./lib/rayz -e "Rayz::Chapter8.run"
ruby -r ./lib/rayz -e "Rayz::Chapter9.run"
ruby -r ./lib/rayz -e "Rayz::Chapter10.run"
ruby -r ./lib/rayz -e "Rayz::Chapter11.run"
ruby -r ./lib/rayz -e "Rayz::Chapter12.run"
```

## Testing

Run all tests (202 scenarios passing):
```bash
bundle exec cucumber
```

Run Chapter 8 tests only:
```bash
bundle exec cucumber features/patterns.feature features/planes.feature
```

Run Chapter 7 tests only:
```bash
bundle exec cucumber features/world.feature features/camera.feature
```

Run Chapter 6 tests only:
```bash
bundle exec cucumber features/lights.feature features/materials.feature
```

Run Chapter 5 tests only:
```bash
bundle exec cucumber features/rays.feature features/spheres.feature features/intersections.feature
```

Run specific feature:
```bash
bundle exec cucumber features/transformations.feature
bundle exec cucumber features/matrices.feature
bundle exec cucumber features/tuples.feature
bundle exec cucumber features/canvas.feature
bundle exec cucumber features/colors.feature
```

## Formatting

`bundle exec standardrb`

## Troubleshooting

### zlib LoadError
If you encounter `LoadError: cannot load such file -- zlib` when running bundle:

1. Install zlib development package:
   ```bash
   sudo apt update && sudo apt install zlib1g-dev
   ```

2. Reinstall Ruby to pick up the zlib library:
   ```bash
   mise uninstall ruby 3.4.5
   mise install ruby 3.4.5
   ```

3. Try `bundle` again.

## Grid

The canvas is a grid of pixels.  The grid is defined by the number of rows and columns.  The rows are the Y axis and the columns are the X axis.
The origin is the bottom left corner of the grid.  The X axis increases to the right and the Y axis increases up.

R(y)
.
.
.
3
2
1
0  1  2  3 ... C (x)

## Chapter 1

A projectile is shot and the position is reported until it hits the ground.

```
Position at tick 000 -> X:   0.707  Y:   1.707  Z:   0.000
Position at tick 001 -> X:   1.404  Y:   2.314  Z:   0.000
Position at tick 002 -> X:   2.091  Y:   2.821  Z:   0.000
Position at tick 003 -> X:   2.768  Y:   3.228  Z:   0.000
Position at tick 004 -> X:   3.436  Y:   3.536  Z:   0.000
Position at tick 005 -> X:   4.093  Y:   3.743  Z:   0.000
Position at tick 006 -> X:   4.740  Y:   3.850  Z:   0.000
Position at tick 007 -> X:   5.377  Y:   3.857  Z:   0.000
Position at tick 008 -> X:   6.004  Y:   3.764  Z:   0.000
Position at tick 009 -> X:   6.621  Y:   3.571  Z:   0.000
Position at tick 010 -> X:   7.228  Y:   3.278  Z:   0.000
Position at tick 011 -> X:   7.825  Y:   2.885  Z:   0.000
Position at tick 012 -> X:   8.412  Y:   2.392  Z:   0.000
Position at tick 013 -> X:   8.989  Y:   1.799  Z:   0.000
Position at tick 014 -> X:   9.557  Y:   1.107  Z:   0.000
Position at tick 015 -> X:  10.114  Y:   0.314  Z:   0.000
Position at tick 016 -> X:  10.661  Y:  -0.579  Z:   0.000
Projectile hit the ground after 16 ticks.
```
## Chapter 2 - Canvas and Projectile Visualization

A projectile is shot and its trajectory is plotted on a canvas, demonstrating:
- Canvas creation and pixel manipulation
- Color operations
- PPM file format export
- Parallel pixel writing with async operations

**Output:** `chapter2.ppm` - A 900×550 pixel image showing the projectile's arc

**Example output:**
```
Calculating projectile trajectory...Projectile hit the ground after 197 ticks.
Writing pixels in parallel...Pixels written.
Writing PPM to chapter2.ppm...Done
```

## Chapter 3 - Matrix Operations and Transformations

Demonstrates matrix operations and transformations, including:
- Matrix construction, transpose, and determinant
- Matrix multiplication and inversion
- Verification that A × inverse(A) = Identity
- Visual demonstration: clock face using rotation matrices

**Output:** `chapter3_clock.ppm` - A 400×400 pixel image showing 12 hour marks positioned using 3D rotation matrices

**Example output:**
```
=== Chapter 3: Matrices ===
Demonstrating matrix operations and transformations

1. Basic Matrix Operations
----------------------------------------
Original Matrix M:
  [ 1.00   2.00   3.00   4.00]
  [ 5.00   6.00   7.00   8.00]
  ...

2. Matrix Inversion
----------------------------------------
Matrix A:
  [ 3.00  -9.00   7.00   3.00]
  ...
Inverse of A:
  [-0.07821  -0.04833   0.08875  -0.28910]
  ...
Verification: A * inverse(A) = Identity
  [ 1.00000   0.00000   0.00000   0.00000]
  ...

3. Clock Face Visualization
----------------------------------------
Drawing a clock using rotation matrices...
Writing clock face to chapter3_clock.ppm... Done!
```

## Chapter 4 - Matrix Transformations

Demonstrates transformation matrices for manipulating objects in 3D space:
- Translation: moving points (vectors unaffected)
- Scaling: resizing objects (negative values create reflections)
- Rotation: around X, Y, and Z axes using radians
- Shearing: skewing transformations in all directions
- Transformation chaining: composing multiple transformations
- Visual demonstration: analog clock at 3:00

**Output:** `chapter4_clock.ppm` - A 500×500 pixel image showing an analog clock with colored hour markers and hands at 3:00

**Example output:**
```
=== Chapter 4: Matrix Transformations ===
Demonstrating translation, scaling, rotation, and shearing

1. Translation
----------------------------------------
Point: Point(x: -3, y: 4, z: 5)
Translation(5, -3, 2)
Result: Point(x: 2, y: 1, z: 7)

Vector: Vector(x: -3, y: 4, z: 5)
Translation(5, -3, 2)
Result: Vector(x: -3, y: 4, z: 5) (unchanged - vectors are not affected by translation)

2. Scaling and Reflection
----------------------------------------
...

6. Analog Clock Visualization
----------------------------------------
Creating an analog clock face using transformations...
Writing analog clock to chapter4_clock.ppm... Done!
An analog clock showing 3:00 has been created using transformations.
```

## Chapter 5 - Ray-Sphere Intersections

Demonstrates the fundamentals of ray tracing:
- Ray creation with origin and direction
- Computing points along a ray
- Ray transformations (translation and scaling)
- Sphere-ray intersection calculations
- Finding hit points (lowest non-negative intersection)
- Visual demonstration: rendering a sphere silhouette using ray casting

**Output:** `chapter5_sphere.ppm` - A 200×200 pixel image showing a red sphere silhouette rendered using ray casting

**Key concepts:**
- Rays are defined by an origin (point) and direction (vector)
- `position(ray, t)` computes a point along the ray at distance t
- Spheres can be transformed (scaled, rotated, translated)
- Intersections return t values where the ray hits the sphere
- The `hit` function finds the lowest non-negative intersection

**Example output:**
```
=== Chapter 5: Ray-Sphere Intersections ===
Demonstrating ray casting and sphere intersection

1. Basic Ray-Sphere Intersection
----------------------------------------
Ray origin: (0, 0, -5)
Ray direction: (0, 0, 1)
Sphere: Unit sphere at origin
Intersections: 2
  [0] t = 4.0
  [1] t = 6.0

2. Ray Transformations
----------------------------------------
Original ray:
  Origin: (1, 2, 3)
  Direction: (0, 1, 0)

After translation(3, 4, 5):
  Origin: (4.0, 6.0, 8.0)
  Direction: (0, 1, 0)

After scaling(2, 3, 4):
  Origin: (2.0, 6.0, 12.0)
  Direction: (0, 3, 0)

3. Sphere Silhouette Rendering
----------------------------------------
Rendering a sphere using ray casting...
Writing sphere silhouette to chapter5_sphere.ppm... Done!
A red sphere silhouette has been rendered using ray casting.
The sphere is scaled to be flattened (y = 0.5) to demonstrate transformations.
```

## Chapter 6 - Light and Shading

Demonstrates the Phong reflection model for realistic lighting:
- Point light sources with position and intensity
- Surface materials with ambient, diffuse, specular, and shininess properties
- Surface normals calculation for spheres
- Vector reflection for specular highlights
- Phong shading model combining ambient, diffuse, and specular components
- Shadow detection (in_shadow parameter)
- Visual demonstration: rendering a shaded 3D sphere with realistic lighting

**Output:** `chapter6.ppm` - A 400×400 pixel image showing a purple sphere with Phong shading

**Key concepts:**
- Materials define surface properties (color, ambient, diffuse, specular, shininess)
- Point lights have position and intensity (color)
- Surface normals are vectors perpendicular to the surface at a point
- Phong model: `color = ambient + diffuse + specular`
- Ambient: constant base illumination
- Diffuse: matte reflection based on light angle
- Specular: shiny highlights based on reflection angle

**Example output:**
```
=== Chapter 6: Light and Shading ===
Rendering a 3D sphere with Phong shading

Rendering 3D sphere with Phong shading...
Canvas size: 400x400
Sphere material: purple-ish (R:1, G:0.2, B:1)
Light position: Point(x: -10, y: 10, z: -10)
Progress (each dot = 10 rows):
........................................
Done!
Writing to chapter6.ppm...
Complete! Open chapter6.ppm to see the shaded sphere.
```

## Chapter 7 - Making a Scene (World and Camera)

Demonstrates building complete 3D scenes with multiple objects and rendering:
- World class for managing objects and light sources
- Camera class with configurable field of view and viewport
- View transformations for positioning the camera
- Ray generation for each pixel based on camera position
- Shadow detection using ray casting to light source
- Intersection precomputation for efficient rendering
- Visual demonstration: rendering a scene with multiple spheres, floor, and walls

**Output:** `chapter7.ppm` - A 400×200 pixel image showing a complete 3D scene with three colored spheres, walls, and realistic shadows

**Key concepts:**
- World manages collections of objects and a light source
- Camera generates rays through each pixel of the viewport
- `view_transform(from, to, up)` positions and orients the camera
- Shadow rays check if a point is in shadow before applying lighting
- `prepare_computations` precomputes intersection data for efficiency
- Scene rendering iterates through all pixels, casting rays and computing colors

**Example output:**
```
Chapter 7: Making a Scene
Rendering scene (400x200 pixels)...
This may take a minute...
Progress (each dot = 10 rows):
....................
Done!
Rendering took 84.68 seconds
Time per row: 423.4 ms
Scene rendered to chapter7.ppm
```

## Chapter 8 - Patterns and Planes

Demonstrates advanced shape abstraction and surface patterns:
- Shape base class with template method pattern for all geometric primitives
- Plane primitive (infinite flat surface)
- Pattern system with transformations
- Stripe pattern (alternating colors based on x coordinate)
- Gradient pattern (linear color interpolation)
- Ring pattern (concentric rings in XZ plane)
- Checkers pattern (3D checkerboard)
- Pattern transformations independent of object transformations
- Visual demonstration: scene with patterned spheres and infinite floor/wall planes

**Output:** `chapter8.ppm` - A 400×200 pixel image showing spheres with various patterns on an infinite checkerboard floor

**Key concepts:**
- Shape abstraction separates coordinate transformation from shape-specific logic
- Shapes implement `local_intersect` and `local_normal_at` in object space
- Base Shape class handles world-to-object-to-pattern coordinate transformations
- Planes have constant normals (always pointing up) and handle parallel rays
- Patterns have their own transform matrices for positioning/scaling/rotation
- `pattern_at_shape(pattern, object, world_point)` applies both object and pattern transforms
- Materials can use either solid colors or patterns

**Example output:**
```
Chapter 8: Shadows (Patterns and Planes)
Rendering scene with patterns and planes (400x200 pixels)...
Features:
  - Floor: Checkers pattern on an infinite plane
  - Back wall: Gradient pattern
  - Middle sphere: Ring pattern
  - Right sphere: Stripe pattern (rotated)
  - Left sphere: Gradient pattern
This may take a minute...
Progress (each dot = 10 rows):
....................
Done!
Rendering took 85.23 seconds
Time per row: 426.2 ms
Scene rendered to chapter8.ppm
```

## Chapter 9 - Planes

Demonstrates infinite flat surfaces with the Plane primitive:
- Plane class implementing Shape interface
- Constant normals across infinite surface
- Plane-ray intersection calculations
- Handling of parallel rays
- Visual demonstration: scene with floor and wall planes plus spheres

**Output:** `chapter9.ppm` - A 400×200 pixel image showing spheres resting on an infinite floor plane with wall planes

**Key concepts:**
- Planes are infinite flat surfaces with constant normals
- The normal at any point on a plane is always the same vector
- Parallel rays to the plane never intersect
- Transformations can position and orient planes in 3D space
- Planes use the same material and pattern system as other shapes

**Example output:**
```
Chapter 9: Planes
Rendering scene with planes and spheres (400x200 pixels)...
Features:
  - Floor plane at y=0
  - Left and right wall planes with transformations
  - Three spheres with different materials
Progress (each dot = 10 rows):
....................
Done!
Rendering took 82.45 seconds
Time per row: 412.3 ms
Scene rendered to chapter9.ppm
```

## Chapter 10 - Reflection and Refraction

Demonstrates realistic rendering with mirrors and transparent materials:
- Reflective surfaces (mirrors, chrome, polished floors)
- Transparent materials (glass, water) with refraction
- Fresnel effect for realistic glass appearance
- Recursive ray tracing with depth limiting
- Schlick approximation for fast Fresnel calculations
- Combined reflection and refraction for realistic glass
- Visual demonstration: scene with mirrors and glass spheres

**Output:** `chapter10.ppm` - An 800×400 pixel image showing reflective and refractive materials

**Key concepts:**
- Reflection spawns secondary rays that bounce off surfaces
- Refraction bends light when passing between transparent media
- Refractive index determines how much light bends (air=1.0, glass=1.5, diamond=2.4)
- Total internal reflection occurs when light cannot exit a denser medium
- Fresnel effect: viewing angle affects reflection vs refraction
- Schlick approximation provides fast, accurate Fresnel calculations
- Recursion depth limiting prevents infinite loops

**Example output:**
```
Chapter 10: Reflection and Refraction
Rendering scene with mirrors and glass (800x400 pixels)...
Features:
  - Floor: Reflective checkerboard pattern
  - Back wall: Reflective surface
  - Middle sphere: Transparent glass ball
  - Right sphere: Reflective chrome sphere
  - Left sphere: Glass with color
This may take a few minutes...
Done!
Rendering took 187.32 seconds
Time per row: 468.3 ms
Scene rendered to chapter10.ppm
```

## Chapter 11 - Cubes

Demonstrates axis-aligned bounding boxes (cubes) as a new primitive shape:
- Cube class extending Shape interface
- Ray-cube intersection using check_axis algorithm
- Normal calculation based on maximum component value
- Cubes can be transformed like other shapes
- Visual demonstration: scene with table made from cubes

**Output:** `chapter11.ppm` - An 800×600 pixel image showing a room with a table and various cubes

**Key concepts:**
- Cubes are axis-aligned bounding boxes extending from -1 to +1 on all axes
- Intersection algorithm checks ray against 6 planes (2 per axis)
- For each axis, compute tmin and tmax, then take overall max(tmin) and min(tmax)
- Normals determined by finding which component (x, y, or z) has largest absolute value
- Cubes support full transformation matrices and materials
- Can create complex objects by combining transformed cubes

**Example output:**
```
Chapter 11: Cubes
Rendering scene with cubes (800x600 pixels)...
Features:
  - Room made from a large cube
  - Table with 4 legs and a surface
  - Boxes on the table and floor
This may take a few minutes...
Done!
Rendering took 312.45 seconds
Time per row: 520.8 ms
Scene rendered to chapter11.ppm
```

## Chapter 12 - Cylinders

Demonstrates cylinders as a new primitive shape with support for truncation and end caps:
- Cylinder class extending Shape interface
- Ray-cylinder intersection using discriminant algorithm
- Support for infinite, truncated, and capped cylinders
- Normal calculation for cylinder walls and end caps
- Visual demonstration: scene with table, candles, and various cylinder objects

**Output:** `chapter12.ppm` - An 800×600 pixel image showing cylinders with different configurations

**Key concepts:**
- Cylinders have radius 1 and extend infinitely along the y-axis by default
- Intersection uses discriminant to find where ray intersects cylinder walls
- Truncation: `minimum` and `maximum` y values constrain the cylinder
- End caps: `closed` attribute adds circular caps at min/max extents
- Normal on walls: vector(x, 0, z) - perpendicular to y-axis
- Normal on caps: vector(0, ±1, 0) - along y-axis
- Cylinders support full transformation matrices and materials

**Example output:**
```
Chapter 12: Cylinders
Rendering scene with cylinders (800x600 pixels)...
Features:
  - Infinite cylinders (table legs)
  - Truncated cylinders (various heights)
  - Closed cylinders with end caps
  - Open cylinders (hollow)
This may take a few minutes...
Done!
Rendering took 285.32 seconds
Time per row: 475.5 ms
Scene rendered to chapter12.ppm
```

## Viewing Output Files

The generated `.ppm` files can be viewed with most image viewers or converted to other formats:

```bash
# View with ImageMagick
display chapter4_clock.ppm

# Convert to PNG
convert chapter4_clock.ppm chapter4_clock.png

# Copy to Windows (WSL users)
cp chapter4_clock.ppm /mnt/c/Users/YourUsername/
```
