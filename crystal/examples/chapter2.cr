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
  vel = proj.velocity + env.gravity + env.wind
  Projectile.new(
    Rayz::Point.new(position.x, position.y, position.z),
    Rayz::Vector.new(vel.x, vel.y, vel.z)
  )
end

start = Rayz::Point.new(0.0, 1.0, 0.0)
velocity = Rayz::Vector.new(1.0, 1.8, 0.0).normalize * 11.25
p = Projectile.new(start, velocity)

gravity = Rayz::Vector.new(0.0, -0.1, 0.0)
wind = Rayz::Vector.new(-0.01, 0.0, 0.0)
e = Environment.new(gravity, wind)

canvas = Rayz::Canvas.new(900, 550)
red = Rayz::Color.new(1.0, 0.0, 0.0)

tick_count = 0
while p.position.y > 0
  col = p.position.x.round.to_i
  row = p.position.y.round.to_i
  if col.in?(0...canvas.width) && row.in?(0...canvas.height)
    canvas.write_pixel(col, row, red)
  end
  p = tick(e, p)
  tick_count += 1
end

print "Projectile hit the ground after #{tick_count} ticks. Writing PPM..."

ppm_path = File.join(__DIR__, "chapter2.ppm")
File.write(ppm_path, canvas.to_ppm)

puts " Done → #{ppm_path}"
puts "\n" + "=" * 60 + "\n"
