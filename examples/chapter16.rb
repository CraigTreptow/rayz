require_relative "../lib/rayz"

module Rayz
  module Chapter16
    def self.run
      puts "Chapter 16: Constructive Solid Geometry (CSG)"
      puts "=" * 60
      puts "Rendering scene with CSG shapes..."
      puts

      # Camera setup
      camera = Camera.new(
        hsize: 800,
        vsize: 600,
        field_of_view: Math::PI / 3
      )
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 2, z: -8),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      # World setup
      world = World.new
      world.light = PointLight.new(
        position: Point.new(x: -5, y: 5, z: -8),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Floor - reflective checkered pattern
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 0.8, green: 0.8, blue: 0.8),
        b: Color.new(red: 0.2, green: 0.2, blue: 0.2)
      )
      floor.material.reflective = 0.2
      floor.material.specular = 0.0
      world.objects << floor

      # Back wall - subtle gradient
      back_wall = Plane.new
      back_wall.transform = Transformations.rotation_x(radians: Math::PI / 2) *
        Transformations.translation(x: 0, y: 0, z: 5)
      back_wall.material.pattern = GradientPattern.new(
        Color.new(red: 0.3, green: 0.4, blue: 0.6),
        Color.new(red: 0.1, green: 0.2, blue: 0.3)
      )
      back_wall.material.pattern.transform = Transformations.rotation_y(radians: Math::PI / 2) *
        Transformations.scaling(x: 2, y: 1, z: 1)
      back_wall.material.specular = 0.0
      world.objects << back_wall

      # 1. Carved Cube - Cube with sphere carved out using difference
      puts "Creating carved cube (difference)..."
      cube1 = Cube.new
      cube1.material.color = Color.new(red: 0.9, green: 0.7, blue: 0.2)
      cube1.material.ambient = 0.1
      cube1.material.diffuse = 0.7
      cube1.material.specular = 0.3

      carving_sphere = Sphere.new
      carving_sphere.transform = Transformations.scaling(x: 0.8, y: 0.8, z: 0.8)

      carved_cube = Rayz.csg("difference", cube1, carving_sphere)
      carved_cube.transform = Transformations.translation(x: -3, y: 1.5, z: 0) *
        Transformations.rotation_y(radians: Math::PI / 6)
      world.objects << carved_cube

      # 2. Lens - Two spheres intersected
      puts "Creating lens (intersection)..."
      lens_left = Sphere.new
      lens_left.transform = Transformations.translation(x: -0.5, y: 0, z: 0)
      lens_left.material.transparency = 0.9
      lens_left.material.refractive_index = 1.5
      lens_left.material.color = Color.new(red: 0.8, green: 0.9, blue: 1.0)
      lens_left.material.ambient = 0.0
      lens_left.material.diffuse = 0.1
      lens_left.material.specular = 0.9
      lens_left.material.shininess = 300

      lens_right = Sphere.new
      lens_right.transform = Transformations.translation(x: 0.5, y: 0, z: 0)
      lens_right.material = lens_left.material

      lens = Rayz.csg("intersection", lens_left, lens_right)
      lens.transform = Transformations.translation(x: 0, y: 1, z: 0) *
        Transformations.rotation_y(radians: Math::PI / 8)
      world.objects << lens

      # 3. Hollow Sphere - Sphere with inner sphere removed
      puts "Creating hollow sphere (difference)..."
      outer_sphere = Sphere.new
      outer_sphere.material.color = Color.new(red: 0.8, green: 0.2, blue: 0.2)
      outer_sphere.material.ambient = 0.1
      outer_sphere.material.diffuse = 0.7
      outer_sphere.material.specular = 0.3

      inner_sphere = Sphere.new
      inner_sphere.transform = Transformations.scaling(x: 0.7, y: 0.7, z: 0.7)

      hollow_sphere = Rayz.csg("difference", outer_sphere, inner_sphere)
      hollow_sphere.transform = Transformations.translation(x: 3, y: 1.2, z: 0)
      world.objects << hollow_sphere

      # 4. Die - Cube with spherical pips
      puts "Creating die with pips (multiple differences)..."
      die_cube = Cube.new
      die_cube.material.color = Color.new(red: 1.0, green: 1.0, blue: 1.0)
      die_cube.material.ambient = 0.2
      die_cube.material.diffuse = 0.7
      die_cube.material.specular = 0.3

      # Create pip (small sphere for dots)
      pip = Sphere.new
      pip.transform = Transformations.scaling(x: 0.25, y: 0.25, z: 0.25)
      pip.material.color = Color.new(red: 0.1, green: 0.1, blue: 0.1)

      # Front face - one pip in center
      pip1 = Sphere.new
      pip1.transform = Transformations.translation(x: 0, y: 0, z: 1.1) *
        Transformations.scaling(x: 0.25, y: 0.25, z: 0.25)
      die = Rayz.csg("difference", die_cube, pip1)

      # Top face - four pips in corners
      pip2 = Sphere.new
      pip2.transform = Transformations.translation(x: -0.4, y: 1.1, z: -0.4) *
        Transformations.scaling(x: 0.2, y: 0.2, z: 0.2)
      die = Rayz.csg("difference", die, pip2)

      pip3 = Sphere.new
      pip3.transform = Transformations.translation(x: 0.4, y: 1.1, z: -0.4) *
        Transformations.scaling(x: 0.2, y: 0.2, z: 0.2)
      die = Rayz.csg("difference", die, pip3)

      pip4 = Sphere.new
      pip4.transform = Transformations.translation(x: -0.4, y: 1.1, z: 0.4) *
        Transformations.scaling(x: 0.2, y: 0.2, z: 0.2)
      die = Rayz.csg("difference", die, pip4)

      pip5 = Sphere.new
      pip5.transform = Transformations.translation(x: 0.4, y: 1.1, z: 0.4) *
        Transformations.scaling(x: 0.2, y: 0.2, z: 0.2)
      die = Rayz.csg("difference", die, pip5)

      die.transform = Transformations.translation(x: -1.5, y: 0.55, z: -2) *
        Transformations.rotation_y(radians: Math::PI / 5)
      world.objects << die

      # 5. Complex CSG - Cylinder with spherical ends (union)
      puts "Creating cylinder with spherical caps (union)..."
      cylinder_body = Cylinder.new
      cylinder_body.minimum = -0.5
      cylinder_body.maximum = 0.5
      cylinder_body.material.color = Color.new(red: 0.3, green: 0.7, blue: 0.3)
      cylinder_body.material.ambient = 0.1
      cylinder_body.material.diffuse = 0.7
      cylinder_body.material.specular = 0.5

      top_cap = Sphere.new
      top_cap.transform = Transformations.translation(x: 0, y: 0.5, z: 0) *
        Transformations.scaling(x: 1, y: 0.5, z: 1)
      top_cap.material = cylinder_body.material

      bottom_cap = Sphere.new
      bottom_cap.transform = Transformations.translation(x: 0, y: -0.5, z: 0) *
        Transformations.scaling(x: 1, y: 0.5, z: 1)
      bottom_cap.material = cylinder_body.material

      cylinder_with_caps = Rayz.csg("union", cylinder_body, top_cap)
      cylinder_with_caps = Rayz.csg("union", cylinder_with_caps, bottom_cap)
      cylinder_with_caps.transform = Transformations.translation(x: 1.5, y: 0.75, z: -2) *
        Transformations.rotation_z(radians: Math::PI / 6)
      world.objects << cylinder_with_caps

      # 6. Wedge Cut Sphere - Sphere with wedge removed
      puts "Creating wedge-cut sphere (difference)..."
      wedge_sphere = Sphere.new
      wedge_sphere.material.color = Color.new(red: 0.6, green: 0.3, blue: 0.8)
      wedge_sphere.material.ambient = 0.1
      wedge_sphere.material.diffuse = 0.7
      wedge_sphere.material.specular = 0.3
      wedge_sphere.material.reflective = 0.2

      wedge = Cube.new
      wedge.transform = Transformations.rotation_y(radians: Math::PI / 4) *
        Transformations.scaling(x: 2, y: 2, z: 0.3)

      wedge_cut = Rayz.csg("difference", wedge_sphere, wedge)
      wedge_cut.transform = Transformations.translation(x: 0, y: 1, z: -3) *
        Transformations.rotation_y(radians: -Math::PI / 8)
      world.objects << wedge_cut

      # Render the scene
      puts
      puts "Rendering #{camera.hsize}x#{camera.vsize} image..."
      canvas = camera.render(world)

      # Save to file
      filename = File.join(__dir__, "chapter16.ppm")
      File.write(filename, canvas.to_ppm)

      puts
      puts "Scene rendered successfully!"
      puts "Output saved to: #{filename}"
      puts
      puts "Scene contains:"
      puts "  - Carved cube (difference): Yellow cube with spherical carving"
      puts "  - Lens (intersection): Two glass spheres intersected"
      puts "  - Hollow sphere (difference): Red sphere hollowed out"
      puts "  - Die (multiple differences): White cube with black pips"
      puts "  - Rounded cylinder (union): Green cylinder with spherical caps"
      puts "  - Wedge-cut sphere (difference): Purple sphere with wedge removed"
      puts
      puts "All shapes demonstrate CSG operations:"
      puts "  - Union: Combines shapes preserving exteriors"
      puts "  - Intersection: Keeps only overlapping volumes"
      puts "  - Difference: Subtracts one shape from another"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Rayz::Chapter16.run
end
