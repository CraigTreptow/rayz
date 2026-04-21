#!/usr/bin/env ruby
require "ruby-prof"
require "memory_profiler"
require_relative "../lib/rayz"

class RenderProfiler
  def self.run(output_mode: :both)
    puts "\n" + "=" * 60
    puts "RAY TRACER PROFILING"
    puts "=" * 60

    camera, world = create_test_scene

    if output_mode == :cpu || output_mode == :both
      profile_cpu(camera, world)
    end

    if output_mode == :memory || output_mode == :both
      profile_memory(camera, world)
    end
  end

  def self.profile_cpu(camera, world)
    puts "\n" + "-" * 60
    puts "CPU PROFILING (ruby-prof)"
    puts "-" * 60

    RubyProf.start

    camera.render(world)

    result = RubyProf.stop

    # Flat profile showing method call times
    puts "\nTop methods by total time:"
    printer = RubyProf::FlatPrinter.new(result)
    printer.print($stdout, min_percent: 1)

    # Save detailed profile to file
    File.open("profile_graph.html", "w") do |file|
      RubyProf::GraphHtmlPrinter.new(result).print(file)
    end
    puts "\nDetailed graph profile saved to: profile_graph.html"

    # Save call stack profile
    File.open("profile_stack.html", "w") do |file|
      RubyProf::CallStackPrinter.new(result).print(file)
    end
    puts "Call stack profile saved to: profile_stack.html"
  end

  def self.profile_memory(camera, world)
    puts "\n" + "-" * 60
    puts "MEMORY PROFILING (memory_profiler)"
    puts "-" * 60

    report = MemoryProfiler.report do
      camera.render(world)
    end

    puts "\nMemory allocation summary:"
    puts "-" * 60

    # Print summary
    puts "Total allocated: #{format_bytes(report.total_allocated_memsize)}"
    puts "Total retained:  #{format_bytes(report.total_retained_memsize)}"
    puts "\nTop 10 allocations by class:"

    report.pretty_print(
      to_file: "profile_memory.txt",
      scale_bytes: true,
      normalize_paths: true
    )

    puts "\nDetailed memory report saved to: profile_memory.txt"

    # Show top allocators inline
    puts "\nTop allocation sources:"
    allocated = report.allocated_memory_by_class.sort_by { |k, v| -v }
    allocated.first(10).each do |klass, bytes|
      puts "  #{klass}: #{format_bytes(bytes)}"
    end
  end

  def self.create_test_scene
    # Small test scene for profiling (faster than full renders)
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

    # Middle sphere
    middle = Rayz::Sphere.new
    middle.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 0)
    middle.material.color = Rayz::Color.new(red: 0.1, green: 1, blue: 0.5)
    middle.material.diffuse = 0.7
    middle.material.specular = 0.3

    # Right sphere (reflective)
    right = Rayz::Sphere.new
    right.transform = Rayz::Transformations.translation(x: 1.5, y: 0.5, z: -0.5) *
      Rayz::Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
    right.material.color = Rayz::Color.new(red: 0.9, green: 0.9, blue: 0.9)
    right.material.reflective = 0.5

    # Left sphere (glass)
    left = Rayz::Sphere.new
    left.transform = Rayz::Transformations.translation(x: -1.5, y: 0.33, z: -0.75) *
      Rayz::Transformations.scaling(x: 0.33, y: 0.33, z: 0.33)
    left.material.transparency = 0.9
    left.material.refractive_index = 1.5

    world.objects << floor << middle << right << left

    [camera, world]
  end

  def self.format_bytes(bytes)
    if bytes < 1024
      "#{bytes} B"
    elsif bytes < 1024 * 1024
      "#{(bytes / 1024.0).round(2)} KB"
    else
      "#{(bytes / (1024.0 * 1024.0)).round(2)} MB"
    end
  end
end

# Run if executed directly
if __FILE__ == $0
  mode = (ARGV[0] || "both").to_sym
  RenderProfiler.run(output_mode: mode)
end
