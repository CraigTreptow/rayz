class Chapter2
  def self.run
    start = Rayz::Lib::Point.new(x: 0.0, y: 1.0, z: 0.0)
    velocity = Rayz::Lib::Vector.new(x: 1.0, y: 1.8, z: 0.0).normalize * 11.25
    projectile = Projectile.new(position: start, velocity: velocity)

    # gravity -0.1 unit/tick, and wind is -0.01 unit/tick
    gravity = Rayz::Lib::Vector.new(x: 0.0, y: -0.1, z: 0.0)
    wind = Rayz::Lib::Vector.new(x: -0.01, y: 0.0, z: 0.0)
    environment = Environment.new(gravity: gravity, wind: wind)

    canvas = Rayz::Lib::Canvas.new(width: 900, height: 550)

    red = Rayz::Lib::Color.new(red: 1.0, green: 0.0, blue: 0.0)
    print "Shooting projectile..."
    tick_count = 0
    while projectile.position.y > 0
      canvas.write_pixel(col: projectile.position.x.round, row: projectile.position.y.round, color: red)
      projectile = tick(environment, projectile)
      tick_count += 1
    end
    puts "Projectile hit the ground after #{tick_count - 1} ticks."

    file_name = "chapter2.ppm..."
    print "Writing PPM to #{file_name}"
    File.write(file_name, canvas.to_ppm)
    puts "Done"
  end

  def self.tick(environment, projectile)
    new_position = projectile.position + projectile.velocity
    new_velocity = projectile.velocity + environment.gravity + environment.wind
    Projectile.new(position: new_position, velocity: new_velocity)
  end

  def self.print_float(f)
    sprintf("%06.3f", f.round(3))
  end
end
