require_relative "../rayz/environment"
require_relative "../rayz/projectile"
require_relative "../rayz/vector"

module Rayz
  class Chapter1
    def self.run
      # projectile starts one unit above the origin.
      # velocity is normalized to 1 unit/tick.
      projectile = Rayz::Projectile.new(position: Rayz::Point.new(x: 0.0, y: 1.0, z: 0.0), velocity: Rayz::Vector.new(x: 1.0, y: 1.0, z: 0.0).normalize)

      # gravity -0.1 unit/tick, and wind is -0.01 unit/tick
      environment = Rayz::Environment.new(gravity: Rayz::Vector.new(x: 0.0, y: -0.1, z: 0.0), wind: Rayz::Vector.new(x: -0.01, y: 0.0, z: 0.0))

      puts "Shooting projectile..."
      tick_count = 0
      while projectile.position.y > 0
        puts "Position at tick #{"%03d" % tick_count}: -> X: #{print_float(projectile.position.x)} Y: #{print_float(projectile.position.y)}"
        projectile = tick(environment, projectile)
        tick_count += 1
      end
      puts "Projectile hit the ground after #{tick_count - 1} ticks."
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
