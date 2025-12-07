# Main entry point for the Rayz ray tracer library (Crystal implementation)
#
# This file requires all the core components of the ray tracer.
# Port of the Ruby implementation from lib/rayz.rb

require "./rayz/util"
require "./rayz/tuple"
require "./rayz/point"
require "./rayz/vector"
require "./rayz/color"
require "./rayz/canvas"
# require "./rayz/matrix"
# require "./rayz/transformations"

module Rayz
  VERSION = "0.1.0"

  def self.demo
    puts "\n" + ("=" * 60)
    puts "Rayz Crystal Port - Version #{VERSION}"
    puts ("=" * 60) + "\n"

    puts "✅ Implemented Classes:"
    puts "  - Tuple (4D vector with x,y,z,w)"
    puts "  - Point (position in 3D space, w=1.0)"
    puts "  - Vector (direction in 3D space, w=0.0)"
    puts "  - Color (RGB color representation)"
    puts "  - Canvas (2D pixel grid with PPM export)"
    puts ""

    puts "🔍 Quick Test - Creating and manipulating objects:"
    puts ""

    # Test Point
    p = Point.new(1.0, 2.0, 3.0)
    puts "  Point: #{p}"

    # Test Vector
    v = Vector.new(0.0, 1.0, 0.0)
    puts "  Vector: #{v}"

    # Test Color
    c = Color.new(1.0, 0.5, 0.0)
    puts "  Color: #{c}"

    # Test operations
    v2 = Vector.new(1.0, 0.0, 0.0)
    cross = v.cross(v2)
    puts "  Cross product: #{cross}"

    dot = v.dot(v2)
    puts "  Dot product: #{dot}"

    # Test Canvas
    canvas = Canvas.new(5, 3)
    puts "  Canvas: #{canvas.width}×#{canvas.height} pixels"

    puts ""
    puts "🚧 In Progress:"
    puts "  - Matrix (4×4 matrix operations)"
    puts "  - Transformations (translation, rotation, scaling)"
    puts ""

    puts "📋 Planned:"
    puts "  - Ray, Sphere, Camera, World"
    puts "  - All 17 book chapters"
    puts "  - Performance benchmarks vs Ruby"
    puts ""

    puts ("=" * 60)
    puts "See crystal/PORTING_STATUS.md for detailed progress"
    puts ("=" * 60) + "\n"
  end
end

# Load examples runner - must be at top level for Crystal
require "../examples/run_all"

# When compiled as a binary, parse command-line arguments
# This matches the Ruby examples/run interface
Rayz::ExamplesRunner.parse_and_run(ARGV)
