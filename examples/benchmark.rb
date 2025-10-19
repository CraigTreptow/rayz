#!/usr/bin/env ruby
require "benchmark"
require "json"
require_relative "../lib/rayz"

class PerformanceBenchmark
  RESULTS_FILE = "performance_results.json"

  def self.run(label:, iterations: 2)
    puts "\n" + "=" * 60
    puts "BENCHMARK: #{label}"
    puts "=" * 60

    scenes = {
      tiny: create_tiny_scene,
      small: create_small_scene,
      medium: create_medium_scene
    }

    results = {}

    scenes.each do |scene_name, (camera, world)|
      puts "\n#{scene_name.to_s.upcase} SCENE (#{camera.hsize}x#{camera.vsize}):"

      times = []
      iterations.times do |i|
        print "  Iteration #{i + 1}/#{iterations}..."
        time = Benchmark.realtime do
          camera.render(world)
        end
        times << time
        puts " #{time.round(2)}s"
      end

      avg = times.sum / times.size
      min = times.min
      max = times.max
      stddev = Math.sqrt(times.map { |t| (t - avg)**2 }.sum / times.size)

      results[scene_name] = {
        avg: avg.round(3),
        min: min.round(3),
        max: max.round(3),
        stddev: stddev.round(3),
        pixels: camera.hsize * camera.vsize,
        pixels_per_second: (camera.hsize * camera.vsize / avg).round(0)
      }

      puts "  Average: #{avg.round(2)}s"
      puts "  Min/Max: #{min.round(2)}s / #{max.round(2)}s"
      puts "  Std Dev: #{stddev.round(2)}s"
      puts "  Pixels/sec: #{(camera.hsize * camera.vsize / avg).round(0)}"
    end

    save_results(label, results)
    results
  end

  def self.compare(baseline_label:, optimized_label:)
    baseline = load_results(baseline_label)
    optimized = load_results(optimized_label)

    puts "\n" + "=" * 60
    puts "PERFORMANCE COMPARISON"
    puts "=" * 60
    puts "Baseline: #{baseline_label}"
    puts "Optimized: #{optimized_label}"
    puts "=" * 60

    [:tiny, :small, :medium].each do |scene|
      b = baseline[scene.to_s]
      o = optimized[scene.to_s]

      speedup = b["avg"] / o["avg"]
      improvement = ((speedup - 1.0) * 100).round(1)

      puts "\n#{scene.to_s.upcase} SCENE:"
      puts "  Baseline:  #{b["avg"]}s (#{b["pixels_per_second"]} px/s)"
      puts "  Optimized: #{o["avg"]}s (#{o["pixels_per_second"]} px/s)"
      puts "  Speedup:   #{speedup.round(2)}x (#{improvement}% faster)"
    end
  end

  def self.create_tiny_scene
    # 100x50, very fast test for quick iteration
    camera = Rayz::Camera.new(hsize: 100, vsize: 50, field_of_view: Math::PI / 3)
    camera.transform = Rayz::Transformations.view_transform(
      from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
      to: Rayz::Point.new(x: 0, y: 1, z: 0),
      up: Rayz::Vector.new(x: 0, y: 1, z: 0)
    )

    world = Rayz::World.new
    world.light = Rayz::PointLight.new(
      position: Rayz::Point.new(x: -10, y: 10, z: -10),
      intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
    )

    # Floor
    floor = Rayz::Plane.new
    floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)
    floor.material.specular = 0

    # 2 spheres
    s1 = Rayz::Sphere.new
    s1.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 0)
    s1.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)

    s2 = Rayz::Sphere.new
    s2.transform = Rayz::Transformations.translation(x: -1.5, y: 0.5, z: -0.5) *
      Rayz::Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
    s2.material.color = Rayz::Color.new(red: 0.3, green: 0.8, blue: 0.3)

    world.objects << floor << s1 << s2

    [camera, world]
  end

  def self.create_small_scene
    # 150x100, simple sphere scene
    camera = Rayz::Camera.new(hsize: 150, vsize: 100, field_of_view: Math::PI / 3)
    camera.transform = Rayz::Transformations.view_transform(
      from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
      to: Rayz::Point.new(x: 0, y: 1, z: 0),
      up: Rayz::Vector.new(x: 0, y: 1, z: 0)
    )

    world = Rayz::World.new
    world.light = Rayz::PointLight.new(
      position: Rayz::Point.new(x: -10, y: 10, z: -10),
      intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
    )

    # Floor
    floor = Rayz::Plane.new
    floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)
    floor.material.specular = 0

    # 3 spheres
    s1 = Rayz::Sphere.new
    s1.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 0)
    s1.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)

    s2 = Rayz::Sphere.new
    s2.transform = Rayz::Transformations.translation(x: -1.5, y: 0.5, z: -0.5) *
      Rayz::Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
    s2.material.color = Rayz::Color.new(red: 0.3, green: 0.8, blue: 0.3)

    s3 = Rayz::Sphere.new
    s3.transform = Rayz::Transformations.translation(x: 1.5, y: 0.33, z: -0.75) *
      Rayz::Transformations.scaling(x: 0.33, y: 0.33, z: 0.33)
    s3.material.color = Rayz::Color.new(red: 0.3, green: 0.3, blue: 0.8)

    world.objects << floor << s1 << s2 << s3

    [camera, world]
  end

  def self.create_medium_scene
    # 200x150, reflections and shadows (more complex materials)
    camera = Rayz::Camera.new(hsize: 200, vsize: 150, field_of_view: Math::PI / 3)
    camera.transform = Rayz::Transformations.view_transform(
      from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
      to: Rayz::Point.new(x: 0, y: 1, z: 0),
      up: Rayz::Vector.new(x: 0, y: 1, z: 0)
    )

    world = Rayz::World.new
    world.light = Rayz::PointLight.new(
      position: Rayz::Point.new(x: -10, y: 10, z: -10),
      intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
    )

    # Reflective floor
    floor = Rayz::Plane.new
    floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)
    floor.material.reflective = 0.3
    floor.material.specular = 0.3

    # Glass sphere
    glass = Rayz::Sphere.new
    glass.transform = Rayz::Transformations.translation(x: -1.5, y: 1, z: 0)
    glass.material.transparency = 0.9
    glass.material.refractive_index = 1.5
    glass.material.reflective = 0.9

    # Mirror sphere
    mirror = Rayz::Sphere.new
    mirror.transform = Rayz::Transformations.translation(x: 1.5, y: 1, z: 0)
    mirror.material.reflective = 0.8
    mirror.material.color = Rayz::Color.new(red: 0.9, green: 0.9, blue: 0.9)

    # Regular sphere
    matte = Rayz::Sphere.new
    matte.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 1)
    matte.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)

    world.objects << floor << glass << mirror << matte

    [camera, world]
  end

  def self.save_results(label, results)
    all_results = File.exist?(RESULTS_FILE) ? JSON.parse(File.read(RESULTS_FILE)) : {}
    all_results[label] = {
      "timestamp" => Time.now.iso8601,
      "results" => results.transform_values { |v| v.transform_keys(&:to_s) }
    }
    File.write(RESULTS_FILE, JSON.pretty_generate(all_results))
    puts "\nResults saved to #{RESULTS_FILE}"
  end

  def self.load_results(label)
    all_results = JSON.parse(File.read(RESULTS_FILE))
    all_results[label]["results"]
  end

  private_class_method :create_tiny_scene, :create_small_scene, :create_medium_scene, :save_results, :load_results
end

# Run if executed directly
if __FILE__ == $0
  label = ARGV[0] || "baseline"
  puts "Running benchmark: #{label}"
  PerformanceBenchmark.run(label: label)
end
