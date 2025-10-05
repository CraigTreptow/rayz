require "minitest"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib", "rayz"))

classes = %w[camera canvas color intersection ray sphere plane transformations tuple point util vector material point_light lighting world shape pattern stripe_pattern gradient_pattern ring_pattern checkers_pattern test_pattern test_shape]

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
