require "minitest"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib", "rayz"))

classes = %w[bounds camera canvas color cone csg cube cylinder group intersection obj_parser ray sphere plane transformations triangle smooth_triangle tuple point util vector material point_light lighting world shape pattern stripe_pattern gradient_pattern ring_pattern checkers_pattern test_pattern test_shape]

classes.each do |class_file_name|
  require class_file_name
end

World(Minitest::Assertions)

ParameterType(
  name: "transform",
  regexp: /[a-z_]+/,
  transformer: ->(s) { s }
)

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
