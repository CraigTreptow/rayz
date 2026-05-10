module Rayz
  class Chapter2
    def self.run
      start = Rayz::Point.new(x: 0.0, y: 1.0, z: 0.0)
      velocity = Rayz::Vector.new(x: 1.0, y: 1.8, z: 0.0).normalize * 11.25
      projectile = Rayz::Projectile.new(position: start, velocity: velocity)

      gravity = Rayz::Vector.new(x: 0.0, y: -0.1, z: 0.0)
      wind = Rayz::Vector.new(x: -0.01, y: 0.0, z: 0.0)
      environment = Rayz::Environment.new(gravity: gravity, wind: wind)

      canvas = Rayz::Canvas.new(width: 900, height: 550)
      red = Rayz::Color.new(red: 1.0, green: 0.0, blue: 0.0)

      print "Calculating projectile trajectory..."
      tick_count = 0
      positions = []

      while projectile.position.y > 0
        positions << {x: projectile.position.x, y: projectile.position.y}
        projectile = tick(environment, projectile)
        tick_count += 1
      end
      puts "Projectile hit the ground after #{tick_count - 1} ticks."

      print "Writing pixels..."
      positions.each do |pos|
        x_pos = pos[:x].round
        y_pos = pos[:y].round
        canvas.write_pixel_async(row: y_pos, col: x_pos, color: red)
      end
      puts "Pixels written."

      file_name = "examples/chapter2.ppm"
      print "Writing PPM to #{file_name}..."
      File.write(file_name, canvas.to_ppm)
      puts "Done"
      puts "\n" + ("=" * 60) + "\n"
    end

    def self.tick(environment, projectile)
      new_position = projectile.position + projectile.velocity
      new_velocity = projectile.velocity + environment.gravity + environment.wind
      Rayz::Projectile.new(position: new_position, velocity: new_velocity)
    end

    def self.print_float(f)
      sprintf("%06.3f", f.round(3))
    end
  end
end
