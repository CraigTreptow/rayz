require "minitest"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib", "rayz"))

classes = %w[camera canvas color cone csg cube cylinder group intersection ray sphere plane transformations triangle smooth_triangle tuple point util vector material point_light lighting world shape pattern stripe_pattern gradient_pattern ring_pattern checkers_pattern test_pattern test_shape]

classes.each do |class_file_name|
  require class_file_name
end

# Include minitest assertions for step definitions
World(Minitest::Assertions)

# Define custom parameter type for transformation names
ParameterType(
  name: "transform",
  regexp: /[a-z_]+/,
  transformer: ->(s) { s }
)

# Define custom parameter types for points and vectors
ParameterType(
  name: "point",
  regexp: /point\(([^,]+),\s*([^,]+),\s*([^)]+)\)/,
  transformer: ->(x, y, z) { Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f) }
)

ParameterType(
  name: "vector",
  regexp: /vector\(([^,]+),\s*([^,]+),\s*([^)]+)\)/,
  transformer: ->(x, y, z) { Rayz::Vector.new(x: x.to_f, y: y.to_f, z: z.to_f) }
)
