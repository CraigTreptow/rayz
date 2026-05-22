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
  new_pos = proj.position + proj.velocity
  new_vel = proj.velocity + env.gravity + env.wind
  Projectile.new(
    Rayz::Point.new(new_pos.x, new_pos.y, new_pos.z),
    Rayz::Vector.new(new_vel.x, new_vel.y, new_vel.z)
  )
end

norm = Rayz::Vector.new(1.0, 1.8, 0.0).normalize
p = Projectile.new(
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(norm.x * 11.25, norm.y * 11.25, norm.z * 11.25)
)

e = Environment.new(
  Rayz::Vector.new(0.0, -0.1, 0.0),
  Rayz::Vector.new(-0.01, 0.0, 0.0)
)

canvas = Rayz::Canvas.new(900, 550)
red = Rayz::Color.new(1.0, 0.0, 0.0)

print "Calculating projectile trajectory..."
tick_count = 0

while p.position.y > 0
  col = p.position.x.round.to_i
  row = p.position.y.round.to_i
  canvas.write_pixel(col, row, red) if col >= 0 && col < canvas.width && row >= 0 && row < canvas.height
  p = tick(e, p)
  tick_count += 1
end
puts "done (#{tick_count} ticks)"

file_name = "examples/chapter2.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
