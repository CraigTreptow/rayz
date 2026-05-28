require "complex"

module Rayz
  class Torus < Shape
    property major_radius : Float64
    property minor_radius : Float64

    def initialize(major_radius : Float64 = 1.0, minor_radius : Float64 = 0.25)
      super()
      @major_radius = major_radius
      @minor_radius = minor_radius
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      ox = local_ray.origin.x
      oy = local_ray.origin.y
      oz = local_ray.origin.z
      dx = local_ray.direction.x
      dy = local_ray.direction.y
      dz = local_ray.direction.z

      sum_d_sqr = dx*dx + dy*dy + dz*dz
      e = ox*ox + oy*oy + oz*oz - @major_radius*@major_radius - @minor_radius*@minor_radius
      f = ox*dx + oy*dy + oz*dz
      four_r_sqr = 4.0 * @major_radius * @major_radius

      a = sum_d_sqr * sum_d_sqr
      b = 4.0 * sum_d_sqr * f
      c = 2.0 * sum_d_sqr * e + 4.0 * f * f + four_r_sqr * dz * dz
      d = 4.0 * f * e + 2.0 * four_r_sqr * oz * dz
      e_coef = e * e - four_r_sqr * (@minor_radius * @minor_radius - oz * oz)

      roots = solve_quartic(a, b, c, d, e_coef)
      roots.select { |t| t > 0.0 }.map { |t| Intersection.new(t, self) }
    end

    def local_normal_at(local_point : Point) : Tuple
      x = local_point.x
      y = local_point.y
      z = local_point.z

      # Torus is Z-axis oriented (ring in XY plane): use sqrt(x²+y²)
      dist = Math.sqrt(x*x + y*y)
      if dist > 0.0
        mx = x * @major_radius / dist
        my = y * @major_radius / dist
      else
        mx = @major_radius
        my = 0.0
      end

      n = Vector.new(x - mx, y - my, z).normalize
      Vector.new(n.x, n.y, n.z)
    end

    def bounds : Bounds
      extent = @major_radius + @minor_radius
      Bounds.new(
        min: Point.new(-extent, -extent, -@minor_radius),
        max: Point.new(extent, extent, @minor_radius)
      )
    end

    private def solve_quartic(a : Float64, b : Float64, c : Float64, d : Float64, e : Float64) : Array(Float64)
      return [] of Float64 if a == 0.0

      b /= a
      c /= a
      d /= a
      e /= a

      z1 = Complex.new(1.0, 1.0)
      z2 = Complex.new(-1.0, 1.0)
      z3 = Complex.new(-1.0, -1.0)
      z4 = Complex.new(1.0, -1.0)

      tolerance = 1e-10

      100.times do
        p1 = z1*z1*z1*z1 + z1*z1*z1*b + z1*z1*c + z1*d + e
        p2 = z2*z2*z2*z2 + z2*z2*z2*b + z2*z2*c + z2*d + e
        p3 = z3*z3*z3*z3 + z3*z3*z3*b + z3*z3*c + z3*d + e
        p4 = z4*z4*z4*z4 + z4*z4*z4*b + z4*z4*c + z4*d + e

        new_z1 = z1 - p1 / ((z1 - z2) * (z1 - z3) * (z1 - z4))
        new_z2 = z2 - p2 / ((z2 - z1) * (z2 - z3) * (z2 - z4))
        new_z3 = z3 - p3 / ((z3 - z1) * (z3 - z2) * (z3 - z4))
        new_z4 = z4 - p4 / ((z4 - z1) * (z4 - z2) * (z4 - z3))

        converged = (new_z1 - z1).abs < tolerance &&
                    (new_z2 - z2).abs < tolerance &&
                    (new_z3 - z3).abs < tolerance &&
                    (new_z4 - z4).abs < tolerance

        z1, z2, z3, z4 = new_z1, new_z2, new_z3, new_z4
        break if converged
      end

      [z1, z2, z3, z4].select { |z| z.imag.abs < tolerance }.map(&.real)
    end
  end
end
