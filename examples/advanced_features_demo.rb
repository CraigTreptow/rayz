require_relative "../lib/rayz"

module Rayz
  class AdvancedFeaturesDemo
    def self.run
      puts "Advanced Features Demo: Showcasing Extended Ray Tracing Capabilities"
      puts

      # Simple demonstration scene showcasing all features
      render_showcase_scene

      puts
      puts "Advanced features demo complete!"
    end

    def self.render_showcase_scene
      puts "  Creating showcase scene with advanced features..."

      # Create world
      w = World.new

      # Use a point light for simplicity (area lights are very slow)
      w.light = PointLight.new(
        position: Point.new(x: -5, y: 10, z: -5),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Floor with checkers pattern
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 0.5, green: 0.5, blue: 0.5),
        b: Color.new(red: 0.8, green: 0.8, blue: 0.8)
      )
      floor.material.specular = 0
      floor.material.reflective = 0.1
      w.objects << floor

      # Sphere with sine wave normal perturbation
      sphere1 = Sphere.new
      sphere1.transform = Transformations.translation(x: -2, y: 1, z: 0)
      sphere1.material.color = Color.new(red: 1, green: 0.3, blue: 0.3)
      sphere1.material.specular = 0.8
      sphere1.material.normal_perturbation = NormalPerturbations.sine_wave(frequency: 10, amplitude: 0.15)
      w.objects << sphere1

      # Torus primitive
      torus = Torus.new(major_radius: 0.6, minor_radius: 0.2)
      torus.transform = Transformations.translation(x: 0, y: 1.2, z: 0) *
        Transformations.rotation_x(radians: Math::PI / 2)
      torus.material.color = Color.new(red: 0.3, green: 1, blue: 0.3)
      torus.material.specular = 0.8
      torus.material.reflective = 0.4
      w.objects << torus

      # Sphere with quilted normal perturbation
      sphere2 = Sphere.new
      sphere2.transform = Transformations.translation(x: 2, y: 1, z: 0)
      sphere2.material.color = Color.new(red: 0.3, green: 0.3, blue: 1)
      sphere2.material.specular = 0.8
      sphere2.material.normal_perturbation = NormalPerturbations.quilted(frequency: 8, amplitude: 0.2)
      w.objects << sphere2

      # Create camera with anti-aliasing
      camera = Camera.new(
        hsize: 400,
        vsize: 200,
        field_of_view: Math::PI / 3,
        samples_per_pixel: 1  # Set to 1 for faster rendering; increase for better quality
      )
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 3.5, z: -8),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      # Render
      canvas = camera.render(w)
      ppm = canvas.to_ppm
      File.write("examples/advanced_features_demo.ppm", ppm)

      puts "    Saved to examples/advanced_features_demo.ppm"
      puts
      puts "  Features demonstrated:"
      puts "    - Torus primitive (green donut)"
      puts "    - Normal perturbation (wavy red sphere, quilted blue sphere)"
      puts "    - Reflective materials"
      puts "    - Checkerboard floor pattern"
      puts
      puts "  Additional features available (not shown to keep render times reasonable):"
      puts "    - Area lights and soft shadows (AreaLight class)"
      puts "    - Spotlights with directional beams (Spotlight class)"
      puts "    - Anti-aliasing via supersampling (samples_per_pixel > 1)"
      puts "    - Focal blur/depth of field (aperture_size > 0, focal_distance)"
      puts "    - Motion blur (motion_blur: true, shape.motion_transform)"
      puts "    - Texture mapping (TextureMap with planar/cylindrical/spherical UV mapping)"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end

Rayz::AdvancedFeaturesDemo.run if __FILE__ == $0
