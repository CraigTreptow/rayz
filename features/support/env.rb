require "minitest"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib", "rayz"))

classes = %w[camera canvas color intersection ray sphere transformations tuple point util vector material point_light lighting world]

classes.each do |class_file_name|
  require class_file_name
end

# Include minitest assertions for step definitions
World(Minitest::Assertions)
