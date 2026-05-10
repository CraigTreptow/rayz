require "minitest"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib", "rayz"))

classes = %w[util tuple point vector color canvas environment projectile transformations
             ray intersection material point_light lighting
             pattern stripe_pattern gradient_pattern ring_pattern checkers_pattern test_pattern
             shape test_shape sphere plane cube cylinder cone
             triangle smooth_triangle group bounds csg obj_parser
             area_light spotlight texture_map normal_perturbations torus
             world camera]

classes.each { |c| require c }

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
