require_relative "../lib/rayz"

module Rayz
  class Chapter19
    def self.run
      puts "Chapter 19: Hierarchical Transformations"
      puts "Demonstrating nested group transformations with world_to_object and normal_to_world"
      puts "=" * 80

      # Create a world
      world = World.new

      # Light source
      world.light = PointLight.new(
        position: Point.new(x: -10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Floor - reflective checkerboard
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 0.9, green: 0.9, blue: 0.9),
        b: Color.new(red: 0.1, green: 0.1, blue: 0.1)
      )
      floor.material.reflective = 0.2
      world.objects << floor

      # Create a solar system model using nested groups
      # This demonstrates hierarchical transformations

      # Sun at the center (level 0)
      sun = Sphere.new
      sun.material.color = Color.new(red: 1, green: 0.9, blue: 0.1)
      sun.material.ambient = 0.8
      sun.material.diffuse = 0.9
      sun.transform = Transformations.scaling(x: 1.5, y: 1.5, z: 1.5)

      # Earth orbit group (level 1) - rotates around sun
      earth_orbit = Group.new
      earth_orbit.transform = Transformations.rotation_y(radians: Math::PI / 4)

      # Earth position group (level 2) - positions earth away from sun
      earth_position = Group.new
      earth_position.transform = Transformations.translation(x: 5, y: 0, z: 0)

      # Earth rotation group (level 3) - rotates earth on its axis
      earth_rotation = Group.new
      earth_rotation.transform = Transformations.rotation_y(radians: Math::PI / 3)

      # Earth sphere (level 4)
      earth = Sphere.new
      earth.material.color = Color.new(red: 0.1, green: 0.3, blue: 0.8)
      earth.material.diffuse = 0.7
      earth.material.specular = 0.3
      earth.transform = Transformations.scaling(x: 0.8, y: 0.8, z: 0.8)

      # Moon orbit group (level 4) - rotates around earth
      moon_orbit = Group.new
      moon_orbit.transform = Transformations.rotation_y(radians: -Math::PI / 6)

      # Moon position group (level 5) - positions moon away from earth
      moon_position = Group.new
      moon_position.transform = Transformations.translation(x: 1.5, y: 0.3, z: 0)

      # Moon sphere (level 6)
      moon = Sphere.new
      moon.material.color = Color.new(red: 0.7, green: 0.7, blue: 0.7)
      moon.material.diffuse = 0.6
      moon.transform = Transformations.scaling(x: 0.3, y: 0.3, z: 0.3)

      # Build the hierarchy
      moon_position.add_child(moon)
      moon_orbit.add_child(moon_position)
      earth_rotation.add_child(earth)
      earth_rotation.add_child(moon_orbit)
      earth_position.add_child(earth_rotation)
      earth_orbit.add_child(earth_position)

      # Add to world
      world.objects << sun
      world.objects << earth_orbit

      # Create a second planetary system to show multiple hierarchies
      # Mars system (simpler - just planet and satellite)
      mars_orbit = Group.new
      mars_orbit.transform = Transformations.rotation_y(radians: -Math::PI / 3)

      mars_position = Group.new
      mars_position.transform = Transformations.translation(x: -7, y: 0, z: 2)

      mars = Sphere.new
      mars.material.color = Color.new(red: 0.9, green: 0.3, blue: 0.1)
      mars.material.diffuse = 0.7
      mars.transform = Transformations.scaling(x: 0.6, y: 0.6, z: 0.6)

      # Phobos (Mars satellite)
      phobos_orbit = Group.new
      phobos_orbit.transform = Transformations.rotation_y(radians: Math::PI / 2)

      phobos_position = Group.new
      phobos_position.transform = Transformations.translation(x: 1.2, y: 0.2, z: 0)

      phobos = Sphere.new
      phobos.material.color = Color.new(red: 0.5, green: 0.5, blue: 0.4)
      phobos.transform = Transformations.scaling(x: 0.2, y: 0.2, z: 0.2)

      # Build Mars hierarchy
      phobos_position.add_child(phobos)
      phobos_orbit.add_child(phobos_position)
      mars_position.add_child(mars)
      mars_position.add_child(phobos_orbit)
      mars_orbit.add_child(mars_position)

      world.objects << mars_orbit

      # Create a space station using hierarchical groups
      station = Group.new
      station.transform = Transformations.translation(x: 0, y: 3, z: -8) *
        Transformations.rotation_y(radians: Math::PI / 6)

      # Central hub
      hub = Sphere.new
      hub.material.color = Color.new(red: 0.8, green: 0.8, blue: 0.9)
      hub.material.reflective = 0.6
      hub.material.specular = 0.9
      hub.material.shininess = 300
      hub.transform = Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)

      station.add_child(hub)

      # Create 4 arms extending from the hub
      4.times do |i|
        angle = (Math::PI / 2) * i
        arm_group = Group.new
        arm_group.transform = Transformations.rotation_y(radians: angle)

        arm_position = Group.new
        arm_position.transform = Transformations.translation(x: 1, y: 0, z: 0)

        # Arm cylinder
        arm = Cylinder.new
        arm.minimum = 0
        arm.maximum = 1.5
        arm.closed = true
        arm.material.color = Color.new(red: 0.6, green: 0.6, blue: 0.7)
        arm.material.specular = 0.5
        arm.transform = Transformations.scaling(x: 0.1, y: 1, z: 0.1) *
          Transformations.rotation_z(radians: Math::PI / 2)

        # End sphere
        end_sphere = Sphere.new
        end_sphere.material.color = Color.new(red: 0.3, green: 0.6, blue: 0.9)
        end_sphere.material.reflective = 0.3
        end_sphere.transform = Transformations.translation(x: 1.5, y: 0, z: 0) *
          Transformations.scaling(x: 0.3, y: 0.3, z: 0.3)

        arm_position.add_child(arm)
        arm_position.add_child(end_sphere)
        arm_group.add_child(arm_position)
        station.add_child(arm_group)
      end

      world.objects << station

      # Camera
      camera = Camera.new(
        hsize: 800,
        vsize: 600,
        field_of_view: Math::PI / 3
      )

      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 8, z: -15),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      puts "\nRendering scene (800x600 pixels)..."
      puts "This scene demonstrates hierarchical transformations:"
      puts "  - Solar system with sun, earth, moon (6 levels deep)"
      puts "  - Mars system with satellite (5 levels deep)"
      puts "  - Space station with 4 rotating arms (3 levels deep)"
      puts "\nEach object's position and orientation is calculated through"
      puts "multiple levels of group transformations using world_to_object"
      puts "and normal_to_world methods.\n\n"

      canvas = camera.render(world)

      output_path = File.join(File.dirname(__FILE__), "chapter19.ppm")
      File.write(output_path, canvas.to_ppm)

      puts "Scene rendered to #{output_path}"
      puts "\nNote: The correct rendering of this complex hierarchy demonstrates"
      puts "that world_to_object and normal_to_world properly cascade through"
      puts "multiple levels of parent transformations."
    end
  end
end

Rayz::Chapter19.run if __FILE__ == $0
