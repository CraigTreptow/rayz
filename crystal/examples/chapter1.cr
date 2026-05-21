require "../src/rayz"

struct Projectile
  property position : Rayz::Point
  property velocity : Rayz::Vector

  def initialize(@position, @velocity)
  end
end

struct Environment
  property gravity : Rayz::Vector
  property wind : Rayz::Vector

  def initialize(@gravity, @wind)
  end
end

def tick(env : Environment, proj : Projectile) : Projectile
  position = proj.position + proj.velocity
  velocity_tuple = proj.velocity + env.gravity + env.wind
  Projectile.new(
    Rayz::Point.new(position.x, position.y, position.z),
    Rayz::Vector.new(velocity_tuple.x, velocity_tuple.y, velocity_tuple.z)
  )
end

p = Projectile.new(
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(1.0, 1.0, 0.0).normalize
)

e = Environment.new(
  Rayz::Vector.new(0.0, -0.1, 0.0),
  Rayz::Vector.new(-0.01, 0.0, 0.0)
)

tick_count = 0
while p.position.y > 0
  p = tick(e, p)
  tick_count += 1
  puts "Tick #{tick_count}: (#{p.position.x.round(4)}, #{p.position.y.round(4)}, #{p.position.z.round(4)})"
end

puts "\n" + "=" * 60 + "\n"
puts "Projectile hit the ground after #{tick_count} ticks"
