require_relative "../lib/rayz"

module Rayz
  module Chapter18
    def self.run
      puts "Chapter 18: OBJ File Parsing"
      puts "Loading and rendering 3D models from Wavefront OBJ files"
      puts ""

      # Load the tetrahedron OBJ file
      obj_path = File.join(__dir__, "tetrahedron.obj")
      obj_content = File.read(obj_path)
      parser = Rayz.parse_obj_file(obj_content)
      model = Rayz.obj_to_group(parser)

      # Apply transformations and material to the model
      model.transform = Rayz::Transformations.translation(x: 0, y: 0, z: 0) *
        Rayz::Transformations.rotation_y(radians: Math::PI / 6) *
        Rayz::Transformations.scaling(x: 1.5, y: 1.5, z: 1.5)

      # Create a colorful material for the model
      material = Rayz::Material.new
      material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)
      material.diffuse = 0.7
      material.specular = 0.3

      # Apply material to all triangles in the model
      apply_material_to_group(model, material)

      # Create floor
      floor = Rayz::Plane.new
      floor.transform = Rayz::Transformations.translation(x: 0, y: -2, z: 0)
      floor.material.pattern = Rayz::CheckersPattern.new(
        Rayz::Color.new(red: 0.15, green: 0.15, blue: 0.15),
        Rayz::Color.new(red: 0.85, green: 0.85, blue: 0.85)
      )
      floor.material.ambient = 0.8
      floor.material.diffuse = 0.2
      floor.material.specular = 0
      floor.material.reflective = 0.1

      # Create world
      world = Rayz::World.new
      world.light = Rayz::PointLight.new(
        position: Rayz::Point.new(x: -5, y: 5, z: -5),
        intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
      )
      world.objects << model
      world.objects << floor

      # Set up camera
      camera = Rayz::Camera.new(hsize: 600, vsize: 400, field_of_view: Math::PI / 3)
      camera.transform = Rayz::Transformations.view_transform(
        from: Rayz::Point.new(x: 0, y: 3, z: -6),
        to: Rayz::Point.new(x: 0, y: 0, z: 0),
        up: Rayz::Vector.new(x: 0, y: 1, z: 0)
      )

      # Render the scene
      puts "Rendering scene with OBJ model (#{parser.vertices.size - 1} vertices, #{count_triangles(model)} triangles)..."
      canvas = camera.render(world)

      # Save to file
      filename = File.join(__dir__, "chapter18.ppm")
      File.write(filename, canvas.to_ppm)
      puts "Scene saved to #{filename}"
    end

    def self.apply_material_to_group(group, material)
      group.children.each do |child|
        if child.is_a?(Rayz::Group)
          apply_material_to_group(child, material)
        else
          child.material = material
        end
      end
    end

    def self.count_triangles(group, count = 0)
      group.children.each do |child|
        if child.is_a?(Rayz::Group)
          count = count_triangles(child, count)
        elsif child.is_a?(Rayz::Triangle) || child.is_a?(Rayz::SmoothTriangle)
          count += 1
        end
      end
      count
    end
  end
end

# Run if executed directly
Rayz::Chapter18.run if __FILE__ == $PROGRAM_NAME
