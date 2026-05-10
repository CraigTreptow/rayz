require "minitest"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib", "rayz"))

classes = %w[util tuple point vector color canvas environment projectile transformations]

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
