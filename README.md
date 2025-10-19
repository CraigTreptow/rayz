# Rayz

An implementation of a ray tracer based on the ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book by Jamis Buck, written in Ruby.

## Project Scope

**Book Chapters (1-17):** ✅ Complete implementation of all chapters from "The Ray Tracer Challenge" book, covering the fundamentals of ray tracing from projectile physics through smooth triangle rendering.

**Custom Extensions (18-21):** Additional features implemented beyond the book's scope, including OBJ file loading, advanced hierarchical transformations, bounding box optimization, and advanced rendering techniques (torus primitives, area lights, spotlights, anti-aliasing, focal blur, motion blur, texture mapping, normal perturbation).

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

Run chapter demonstrations (generates PPM image files in `examples/` directory):

```bash
# Run all chapters (1-21)
ruby examples/run all

# Run individual chapter
ruby examples/run 4
```

**Note:** Each chapter outputs a visual separator line (60 equals signs) after completion, making it easy to distinguish between chapter outputs when running multiple chapters sequentially.

## Testing

Run all tests:
```bash
bundle exec cucumber
```

Run specific feature:
```bash
bundle exec cucumber features/bounding_boxes.feature
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

---

# Book Chapters (1-17)

All chapters from "The Ray Tracer Challenge" book are fully implemented below.

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

**Output:** `examples/chapter2.ppm` - A 900×550 pixel image showing the projectile's arc

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

**Output:** `examples/chapter3.ppm` - A 400×400 pixel image showing 12 hour marks positioned using 3D rotation matrices

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
Writing clock face to chapter3.ppm... Done!
```

## Chapter 4 - Matrix Transformations

Demonstrates transformation matrices for manipulating objects in 3D space:
- Translation: moving points (vectors unaffected)
- Scaling: resizing objects (negative values create reflections)
- Rotation: around X, Y, and Z axes using radians
- Shearing: skewing transformations in all directions
- Transformation chaining: composing multiple transformations
- Visual demonstration: analog clock at 3:00

**Output:** `examples/chapter4.ppm` - A 500×500 pixel image showing an analog clock with colored hour markers and hands at 3:00

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
Writing analog clock to chapter4.ppm... Done!
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

**Output:** `examples/chapter5.ppm` - A 200×200 pixel image showing a red sphere silhouette rendered using ray casting

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
Writing sphere silhouette to chapter5.ppm... Done!
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

**Output:** `examples/chapter6.ppm` - A 400×400 pixel image showing a purple sphere with Phong shading

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

**Output:** `examples/chapter7.ppm` - A 400×200 pixel image showing a complete 3D scene with three colored spheres, walls, and realistic shadows

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

**Output:** `examples/chapter8.ppm` - A 400×200 pixel image showing spheres with various patterns on an infinite checkerboard floor

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

**Output:** `examples/chapter9.ppm` - A 400×200 pixel image showing spheres resting on an infinite floor plane with wall planes

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

**Output:** `examples/chapter10.ppm` - An 800×400 pixel image showing reflective and refractive materials

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

**Output:** `examples/chapter11.ppm` - An 800×600 pixel image showing a room with a table and various cubes

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

**Output:** `examples/chapter12.ppm` - An 800×600 pixel image showing cylinders with different configurations

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

## Chapter 13 - Groups

Demonstrates hierarchical scene composition using groups:
- Group class for organizing shapes into hierarchies
- Parent-child relationships between shapes
- Transform cascading from parent to child
- Aggregating intersections from multiple child shapes
- Visual demonstration: scene with grouped objects (tree, snowman, hexagon)

**Output:** `examples/chapter13.ppm` - An 800×600 pixel image showing hierarchical groups

**Key concepts:**
- Groups are abstract shapes that contain other shapes
- Groups form tree structures: parents reference children, children reference parent
- Transforming a group transforms all its children
- Intersecting a group checks all child shapes and aggregates results
- Groups have no surface themselves (no normal computation)
- Enable building complex compound objects from simpler primitives

**Example output:**
```
Chapter 13: Groups
Rendering scene with hierarchical groups (800x600 pixels)...
Features:
  - Tree made from grouped trunk and foliage
  - Snowman built from grouped spheres
  - Hexagon pattern using grouped spheres
  - Transformations cascading through group hierarchies
This may take a few minutes...
Done!
Rendering took 298.45 seconds
Time per row: 497.4 ms
Scene rendered to chapter13.ppm
```

## Chapter 14 - Cones

Demonstrates cones as a new primitive shape with support for truncation and end caps:
- Cone class extending Shape interface
- Ray-cone intersection using discriminant algorithm (equation: x² + z² = y²)
- Support for infinite, truncated, and capped cones
- Normal calculation for cone walls and end caps
- Visual demonstration: scene with traffic cones, glass cones, and creative cone shapes

**Output:** `examples/chapter14.ppm` - An 800×600 pixel image showing various cone types with different materials

**Key concepts:**
- Cones are double-napped surfaces aligned with y-axis (equation: x² + z² = y²)
- Intersection uses discriminant algorithm similar to cylinders but with y-dependent radius
- Truncation: `minimum` and `maximum` y values constrain the cone
- End caps: `closed` attribute adds circular caps at min/max extents
- Normal on walls: calculated from cone surface geometry
- Normal on caps: vector(0, ±1, 0) - along y-axis
- Cones support full transformation matrices and materials

**Example output:**
```
Chapter 14: Cones
Rendering scene with cones (800x600 pixels)...
Features:
  - Traffic cone (orange, truncated)
  - Glass cone (transparent with refraction)
  - Metal cone (reflective chrome)
  - Ice cream cone (open cone with sphere on top)
  - Party hat (tall thin cone)
  - Hourglass (two cones meeting at a point)
This may take a few minutes...
Done!
Rendering took 298.75 seconds
Time per row: 497.9 ms
Scene rendered to chapter14.ppm
```

## Chapter 15 - Triangles

Demonstrates triangles as a new primitive shape using the Möller-Trumbore intersection algorithm:
- Triangle class extending Shape interface
- Efficient ray-triangle intersection with barycentric coordinates
- Flat shading with constant normals across triangle surface
- Foundation for loading complex 3D meshes from OBJ files
- Visual demonstration: geometric shapes built entirely from triangles

**Output:** `examples/chapter15.ppm` - An 800×600 pixel image showing geometric shapes constructed from triangles

**Key concepts:**
- Triangles are defined by three vertices (p1, p2, p3)
- Möller-Trumbore algorithm: industry-standard efficient ray-triangle intersection
- Uses barycentric coordinates (u, v) to test if intersection is inside triangle
- Precomputes edge vectors (e1, e2) and normal for efficiency
- Flat shading: normal is constant across entire triangle surface
- Creates faceted appearance, perfect for geometric shapes
- Foundation for triangle mesh loading in future chapters

**Example output:**
```
Chapter 15: Triangles
Rendering scene with triangles (800x600 pixels)...
Features:
  - Pyramid (4 triangular faces)
  - Octahedron (8 triangles forming double pyramid)
  - Tetrahedron (4 triangles forming triangular pyramid)
  - Comparison sphere (showing flat vs smooth shading)
This may take a few minutes...
Done!
Rendering took 305.12 seconds
Time per row: 508.5 ms
Scene rendered to chapter15.ppm
```

## Chapter 16 - Constructive Solid Geometry (CSG)

Demonstrates combining primitive shapes using set operations to create complex composite shapes:
- CSG class extending Shape interface for combining two shapes
- Union operation: combines shapes preserving all external surfaces
- Intersection operation: preserves only overlapping volumes
- Difference operation: subtracts one shape from another
- Recursive filtering of intersections based on operation rules
- Hierarchical CSG operations for arbitrarily complex shapes
- Visual demonstration: carved cubes, lenses, hollow spheres, dice, and more

**Output:** `examples/chapter16.ppm` - An 800×600 pixel image showing various CSG composite shapes

**Key concepts:**
- CSG treats operations as strictly binary (two shapes at a time)
- CSG objects are themselves shapes, enabling hierarchical composition
- Intersection filtering uses truth tables for each operation type
- Union: keeps intersections where ray is outside the other shape
- Intersection: keeps intersections where ray is inside the other shape
- Difference: keeps left shape exterior minus right shape interior
- `includes?` method recursively searches shape hierarchies
- Intersection records always point to primitive shapes, not CSG parents
- Enables complex shapes with far fewer primitives than triangle meshes

**Example output:**
```
Chapter 16: Constructive Solid Geometry (CSG)
Rendering scene with CSG shapes (800x600 pixels)...
Features:
  - Carved cube (cube with spherical cavity using difference)
  - Glass lens (two spheres intersected)
  - Hollow sphere (sphere with inner sphere removed)
  - Die with pips (cube with multiple sphere differences)
  - Rounded cylinder (cylinder with spherical end caps via union)
  - Wedge-cut sphere (sphere with wedge removed)
This may take a few minutes...
Done!
Rendering took 325.67 seconds
Time per row: 542.8 ms
Scene rendered to chapter16.ppm
```

## Chapter 17 - Smooth Triangles

Demonstrates smooth shading for triangles using vertex normals and barycentric interpolation:
- SmoothTriangle class extending Triangle with vertex normals (n1, n2, n3)
- Barycentric interpolation of normals across triangle surface
- Smooth gradients replacing flat shading
- u/v coordinates stored in Intersection for normal interpolation
- Visual demonstration: comparing flat shading vs smooth shading

**Output:** `examples/chapter17.ppm` - An 800×400 pixel image showing flat-shaded and smooth-shaded pyramids side by side

**Key concepts:**
- Smooth triangles store a normal vector for each vertex
- Intersection algorithm computes barycentric coordinates (u, v)
- Normal at any point: n = n2*u + n3*v + n1*(1-u-v)
- Creates smooth gradients instead of faceted appearance
- Essential for realistic rendering of curved surfaces with triangle meshes
- Intersection class extended to store u/v coordinates
- Shape.normal_at updated to accept optional hit parameter

**Example output:**
```
Chapter 17: Smooth Triangles - Smooth shading with normal interpolation
================================================================================
Rendering 800x400 scene...
Left: Flat shaded pyramid (regular triangles)
Right: Smooth shaded pyramid (smooth triangles)
Notice the smooth gradient on the right pyramid vs sharp edges on the left

Complete! Output written to: examples/chapter17.ppm
Open the file in an image viewer to see the difference between
flat shading (left) and smooth shading (right).
```

---

# Custom Extension Demos

The features below extend beyond the book's content with additional advanced ray tracing capabilities. These are demonstration programs, not book chapters.

## OBJ Parser Demo

**Note:** This is a custom extension beyond the book, not an actual chapter.

Demonstrates loading external 3D models from Wavefront OBJ files:
- OBJParser class for parsing OBJ file format
- Vertex parsing (v command) with 1-based indexing
- Vertex normal parsing (vn command) for smooth shading
- Face parsing (f command) with multiple format support
- Fan triangulation for convex polygons (n > 3 vertices)
- Named groups (g command) for organizing model components
- Automatic smooth/flat triangle selection based on normal data
- Visual demonstration: rendering a tetrahedron loaded from OBJ file

**Output:** `examples/obj_parser_demo.ppm` - A 600×400 pixel image showing a 3D model loaded from a Wavefront OBJ file

### About the Wavefront OBJ Format

**Wavefront OBJ** is a plain text 3D geometry file format originally developed by Wavefront Technologies. It's one of the most widely supported 3D formats and can be exported from virtually all 3D modeling software (Blender, Maya, 3ds Max, etc.).

**Format characteristics:**
- Plain text, human-readable and editable
- One command per line
- Lines starting with `#` are comments
- Coordinates use right-handed coordinate system

**Supported commands:**

```obj
# Comment lines start with #

# v x y z - Vertex position
v 0.0 1.0 0.0
v -0.866 -0.5 0.5

# vn x y z - Vertex normal (for smooth shading)
vn 0 1 0
vn 0.707 0 -0.707

# f v1 v2 v3 - Face (triangle)
f 1 2 3

# f v1 v2 v3 v4 - Face (polygon, will be triangulated)
f 1 2 3 4

# f v/vt/vn - Face with vertex/texture/normal indices
f 1/1/1 2/2/2 3/3/3

# f v//vn - Face with vertex and normal indices (no texture)
f 1//1 2//2 3//3

# g name - Named group (organizes geometry)
g LeftWing
f 1 2 3
g RightWing
f 4 5 6
```

**Example OBJ file** (tetrahedron):
```obj
# Tetrahedron - 4 vertices, 4 faces
v 0 1 0
v -0.866 -0.5 0.5
v 0.866 -0.5 0.5
v 0 -0.5 -1

f 2 3 4  # Base
f 1 3 2  # Side 1
f 1 4 3  # Side 2
f 1 2 4  # Side 3
```

**External resources:**
- [Wikipedia: Wavefront .obj file](https://en.wikipedia.org/wiki/Wavefront_.obj_file)
- [Paul Bourke's OBJ format description](http://paulbourke.net/dataformats/obj/)
- [FileFormat.info OBJ specification](https://www.fileformat.info/format/wavefrontobj/egff.htm)

**Key concepts:**
- Vertices use 1-based indexing (first vertex is 1, not 0)
- Face indices reference previously defined vertices
- Polygons with >3 vertices are triangulated using fan triangulation
- Parser creates SmoothTriangle when normals present, Triangle otherwise
- Module functions: `parse_obj_file(content)` and `obj_to_group(parser)`

**Example output:**
```
OBJ Parser Demo: Loading 3D Models from Wavefront OBJ Files
Loading and rendering 3D models from Wavefront OBJ files

Rendering scene with OBJ model (4 vertices, 4 triangles)...
Progress (each dot = 10 rows):
........................................
Done!
Rendering took 45.23 seconds
Time per row: 113.1 ms
Scene saved to examples/obj_parser_demo.ppm
```

## Nested Groups Demo

**Note:** This is a custom extension beyond the book, not an actual chapter.

Demonstrates complex hierarchical transformations using deeply nested group structures:
- Enhanced `world_to_object` method traversing parent hierarchy to convert world coordinates to object space
- Enhanced `normal_to_world` method converting object-space normals to world space through inverse transpose
- Deep nesting of groups (up to 6 levels) demonstrating transform cascading
- Vector type preservation through normalize operations
- Visual demonstration: solar system model with nested planetary orbits and space station

**Output:** `examples/nested_groups_demo.ppm` - An 800×600 pixel image showing a solar system with hierarchical transformations

**Key concepts:**
- `world_to_object(point)` recursively applies inverse transformations up the parent chain
- `normal_to_world(vector)` applies inverse transpose transformations and normalizes
- Transform cascading: child transformations compound with all ancestor transformations
- Deep hierarchies enable complex motion like planetary orbits with moons
- Each level of nesting adds another transformation to the compound matrix
- Essential for skeletal animation, robotic arms, planetary systems, etc.

**Example output:**
```
Nested Groups Demo: Hierarchical Transformations
Demonstrating nested group transformations with world_to_object and normal_to_world
================================================================================

Rendering scene (800x600 pixels)...
This scene demonstrates hierarchical transformations:
  - Solar system with sun, earth, moon (6 levels deep)
  - Mars system with satellite (5 levels deep)
  - Space station with 4 rotating arms (3 levels deep)

Each object's position and orientation is calculated through
multiple levels of group transformations using world_to_object
and normal_to_world methods.

Scene rendered to examples/nested_groups_demo.ppm

Note: The correct rendering of this complex hierarchy demonstrates
that world_to_object and normal_to_world properly cascade through
multiple levels of parent transformations.
```

## Bounding Boxes Demo

**Note:** This is a custom extension beyond the book, not an actual chapter.

Demonstrates performance optimization using axis-aligned bounding boxes (AABBs) for ray tracing:
- `Bounds` class for axis-aligned bounding boxes with min/max extents
- Bounding box calculation for all shape primitives (Sphere, Plane, Cube, Cylinder, Cone, Triangle, CSG, Group)
- Bounding box transformation: transforms all 8 corners and computes new axis-aligned bounds
- Bounding box merging: combines multiple bounding boxes into a single containing box
- Ray-box intersection testing using the same algorithm as cube intersection
- Group optimization: test bounding box first, skip all children if ray misses
- Visual demonstration: scene with 96 marbles in 16 groups showing dramatic performance improvement

**Output:** `examples/bounding_boxes_demo.ppm` - A 600×400 pixel image showing many grouped objects with bounding box optimization

**Key concepts:**
- Bounding boxes provide fast ray-intersection tests before checking complex shapes
- Groups precompute bounding boxes containing all their transformed children
- Ray-box intersection uses axis-slab algorithm (same as cube)
- Bounding box miss means ray cannot possibly hit any child shapes
- Dramatically reduces intersection tests for scenes with many objects
- Particularly effective for hierarchical groups and complex models
- Transforms applied: transform all 8 corners, find new min/max
- Merge operation: component-wise min/max of two bounding boxes

**Example output:**
```
Bounding Boxes Demo: Performance Optimization with AABBs
Rendering a scene with many grouped objects...
Bounding boxes dramatically reduce intersection tests.
Rendering 600x400 image...
With bounding boxes: groups are tested once, not every sphere individually
Rendered in 45.67 seconds
Saved to examples/bounding_boxes_demo.ppm

This scene contains 96 spheres organized into 16 groups.
Bounding boxes allow the ray tracer to skip entire groups when rays miss their bounds,
dramatically reducing the number of intersection tests required.
```

## Advanced Features Demo

**Note:** This is a custom extension beyond the book, not an actual chapter.

Demonstrates 8 advanced ray tracing techniques:
- **Torus primitive**: Donut-shaped objects using quartic equation solving (Durand-Kerner method)
- **Area lights**: Rectangular light sources with soft shadows via grid sampling
- **Spotlights**: Directional cone-shaped beams with configurable angles and soft edges
- **Anti-aliasing**: Supersampling with multiple rays per pixel for smoother edges
- **Focal blur (depth of field)**: Camera aperture simulation with focal distance
- **Motion blur**: Time-based ray sampling for objects in motion
- **Texture mapping**: Image-based patterns with planar/cylindrical/spherical UV mapping
- **Normal perturbation**: Bump/displacement effects (sine waves, quilted patterns, noise, ripples)

**Output:** `examples/advanced_features_demo.ppm` - A 400×200 pixel image showcasing advanced features with a torus, normal-perturbed spheres, and reflective materials

**Key concepts:**
- **Torus**: Quartic intersection equation (4th degree polynomial) solved numerically
- **Area lights**: Multiple shadow rays sample grid positions for soft shadow penumbras
- **Spotlights**: Dot product angle calculations with cone and fade angles
- **Anti-aliasing**: Random sub-pixel offsets averaged across samples_per_pixel
- **Focal blur**: Random aperture sampling with rays converging at focal distance
- **Motion blur**: Ray time attribute (0-1) passed to shape motion_transform callbacks
- **Texture maps**: PPM image loading with UV coordinate mapping functions
- **Normal perturbation**: Procedural displacement via material.normal_perturbation proc

**Performance notes:**
- Area lights: ~16× slower than point lights (4×4 grid = 16 shadow rays per intersection)
- Anti-aliasing: N× slower (N = samples_per_pixel, typically 4-16 for good quality)
- Focal blur: N× slower (N = samples_per_pixel, shares anti-aliasing implementation)
- Motion blur: Only affects moving objects (minimal overhead for static scenes)
- Torus: Quartic solver adds computational cost but converges quickly

**Example features (commented out in demo for performance):**
```ruby
# Area light with soft shadows
light = AreaLight.new(
  corner: Point.new(x: -2, y: 5, z: -2),
  uvec: Vector.new(x: 4, y: 0, z: 0),
  vvec: Vector.new(x: 0, y: 0, z: 4),
  usteps: 4, vsteps: 4
)

# Spotlight with cone beam
spotlight = Spotlight.new(
  position: Point.new(x: 0, y: 10, z: 0),
  direction: Vector.new(x: 0, y: -1, z: 0),
  intensity: Color.new(red: 1, green: 1, blue: 1),
  cone_angle: Math::PI / 6,
  fade_angle: Math::PI / 12
)

# Anti-aliasing with 4 samples per pixel
camera = Camera.new(
  hsize: 400, vsize: 200,
  field_of_view: Math::PI / 3,
  samples_per_pixel: 4
)

# Focal blur (depth of field)
camera.aperture_size = 0.1
camera.focal_distance = 8.0

# Motion blur
world.motion_blur = true
sphere.motion_transform = ->(time) {
  Transformations.translation(x: time * 2, y: 0, z: 0)
}

# Normal perturbation
sphere.material.normal_perturbation = NormalPerturbations.sine_wave(
  frequency: 10,
  amplitude: 0.15
)
```

**Example output:**
```
Advanced Features Demo: Showcasing Extended Ray Tracing Capabilities
Creating showcase scene with advanced features...
Features demonstrated:
  - Torus primitive (green donut)
  - Normal perturbation (wavy red sphere, quilted blue sphere)
  - Reflective materials
  - Checkerboard floor pattern

Additional features available (not shown to keep render times reasonable):
  - Area lights and soft shadows (AreaLight class)
  - Spotlights with directional beams (Spotlight class)
  - Anti-aliasing via supersampling (samples_per_pixel > 1)
  - Focal blur/depth of field (aperture_size > 0, focal_distance)
  - Motion blur (motion_blur: true, shape.motion_transform)
  - Texture mapping (TextureMap with planar/cylindrical/spherical UV mapping)

Rendering took 52.34 seconds
Saved to examples/advanced_features_demo.ppm
```

## Viewing Output Files

The generated `.ppm` files are saved in the `examples/` directory and can be viewed with most image viewers or converted to other formats:

```bash
# View with ImageMagick
display examples/chapter4.ppm

# Convert to PNG
convert examples/chapter4.ppm examples/chapter4.png

# Copy to Windows (WSL users)
cp examples/chapter4.ppm /mnt/c/Users/YourUsername/
```
