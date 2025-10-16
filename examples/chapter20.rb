require_relative "../lib/rayz"

module Rayz
  module Chapter20
    def self.run
      puts "Chapter 20: Bounding Boxes Optimization"
      puts "Rendering a scene with many grouped objects..."
      puts "Bounding boxes dramatically reduce intersection tests."

      # Create floor
      floor = Plane.new
      floor.material.color = Color.new(red: 1, green: 0.9, blue: 0.9)
      floor.material.specular = 0
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 0.8, green: 0.8, blue: 0.8),
        b: Color.new(red: 0.2, green: 0.2, blue: 0.2)
      )

      # Create multiple groups of spheres
      # Each group will have its own bounding box for optimization
      groups = []

      # Create 4x4 grid of grouped marble collections
      4.times do |row|
        4.times do |col|
          group = Group.new

          # Create 6 marbles in this group
          6.times do |i|
            sphere = Sphere.new

            # Random position within group area
            x = (col * 10) - 15 + (rand * 4)
            y = 0.5 + (rand * 2)
            z = (row * 10) - 15 + (rand * 4)

            # Random size
            scale = 0.3 + (rand * 0.5)

            sphere.transform = Transformations.translation(x: x, y: y, z: z) *
              Transformations.scaling(x: scale, y: scale, z: scale)

            # Varied materials
            case i % 3
            when 0
              # Glass marbles
              sphere.material.color = Color.new(red: 0.1, green: 0.1, blue: 0.1)
              sphere.material.diffuse = 0.1
              sphere.material.specular = 0.9
              sphere.material.shininess = 300
              sphere.material.reflective = 0.9
              sphere.material.transparency = 0.9
              sphere.material.refractive_index = 1.5
            when 1
              # Metallic marbles
              sphere.material.color = Color.new(red: 0.7, green: 0.7, blue: 0.8)
              sphere.material.diffuse = 0.3
              sphere.material.specular = 1.0
              sphere.material.shininess = 300
              sphere.material.reflective = 0.8
            else
              # Colored marbles
              sphere.material.color = Color.new(
                red: 0.3 + (rand * 0.7),
                green: 0.3 + (rand * 0.7),
                blue: 0.3 + (rand * 0.7)
              )
              sphere.material.diffuse = 0.7
              sphere.material.specular = 0.3
            end

            group.add_child(sphere)
          end

          groups << group
        end
      end

      # Create world
      world = World.new
      world.light = PointLight.new(
        position: Point.new(x: -10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      world.objects << floor
      groups.each { |g| world.objects << g }

      # Set up camera
      camera = Camera.new(hsize: 600, vsize: 400, field_of_view: Math::PI / 3)
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 5, z: -20),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      # Render scene
      puts "Rendering 600x400 image..."
      puts "With bounding boxes: groups are tested once, not every sphere individually"
      start_time = Time.now
      canvas = camera.render(world)
      render_time = Time.now - start_time
      puts "Rendered in #{render_time.round(2)} seconds"

      # Save to file
      filename = File.join(File.dirname(__FILE__), "chapter20.ppm")
      File.write(filename, canvas.to_ppm)
      puts "Saved to #{filename}"
      puts
      puts "This scene contains #{groups.length * 6} spheres organized into #{groups.length} groups."
      puts "Bounding boxes allow the ray tracer to skip entire groups when rays miss their bounds,"
      puts "dramatically reducing the number of intersection tests required."
    end
  end
end
