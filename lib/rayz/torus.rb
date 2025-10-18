require_relative "shape"
require_relative "bounds"

module Rayz
  class Torus < Shape
    attr_accessor :major_radius, :minor_radius

    def initialize(major_radius: 1.0, minor_radius: 0.25)
      super()
      @major_radius = major_radius  # Distance from center of torus to center of tube
      @minor_radius = minor_radius  # Radius of the tube
    end

    def local_intersect(local_ray)
      # Torus equation: (sqrt(x^2 + z^2) - R)^2 + y^2 = r^2
      # where R = major_radius, r = minor_radius
      # This expands to a quartic equation in t

      ox, oy, oz = local_ray.origin.x, local_ray.origin.y, local_ray.origin.z
      dx, dy, dz = local_ray.direction.x, local_ray.direction.y, local_ray.direction.z

      # Precompute some values
      sum_d_sqr = dx * dx + dy * dy + dz * dz
      e = ox * ox + oy * oy + oz * oz - @major_radius * @major_radius - @minor_radius * @minor_radius
      f = ox * dx + oy * dy + oz * dz
      four_a_sqr = 4.0 * @major_radius * @major_radius

      # Quartic coefficients: at^4 + bt^3 + ct^2 + dt + e = 0
      a = sum_d_sqr * sum_d_sqr
      b = 4.0 * sum_d_sqr * f
      c = 2.0 * sum_d_sqr * e + 4.0 * f * f + four_a_sqr * (dz * dz)
      d = 4.0 * f * e + 2.0 * four_a_sqr * oz * dz
      e_coef = e * e - four_a_sqr * (@minor_radius * @minor_radius - oz * oz)

      # Solve quartic equation
      roots = solve_quartic(a, b, c, d, e_coef)

      # Create intersections for positive real roots
      intersections = []
      roots.each do |t|
        intersections << Intersection.new(t: t, object: self) if t > 0
      end

      intersections
    end

    def local_normal_at(local_point, hit = nil)
      # Normal at point p on torus
      # First find the closest point on the major circle
      x, y, z = local_point.x, local_point.y, local_point.z

      # Distance from Y axis
      dist_from_y_axis = Math.sqrt(x * x + z * z)

      # Point on major circle (in XZ plane)
      if dist_from_y_axis > 0
        major_circle_x = x * @major_radius / dist_from_y_axis
        major_circle_z = z * @major_radius / dist_from_y_axis
      else
        major_circle_x = @major_radius
        major_circle_z = 0.0
      end

      # Normal points from major circle point to surface point
      normal = Vector.new(
        x: x - major_circle_x,
        y: y,
        z: z - major_circle_z
      )

      normal.normalize
    end

    def bounds
      # Bounding box for torus
      extent = @major_radius + @minor_radius
      Bounds.new(
        min: Point.new(x: -extent, y: -@minor_radius, z: -extent),
        max: Point.new(x: extent, y: @minor_radius, z: extent)
      )
    end

    private

    # Durand-Kerner method for solving quartic equations
    # Returns array of real roots
    def solve_quartic(a, b, c, d, e)
      # Normalize coefficients
      return [] if a == 0

      b /= a
      c /= a
      d /= a
      e /= a

      # Initial guesses (spread around the complex plane)
      z1 = Complex(1, 1)
      z2 = Complex(-1, 1)
      z3 = Complex(-1, -1)
      z4 = Complex(1, -1)

      # Durand-Kerner iteration
      max_iterations = 100
      tolerance = 1e-10

      max_iterations.times do
        # Evaluate polynomial at each root guess
        p1 = z1**4 + b * z1**3 + c * z1**2 + d * z1 + e
        p2 = z2**4 + b * z2**3 + c * z2**2 + d * z2 + e
        p3 = z3**4 + b * z3**3 + c * z3**2 + d * z3 + e
        p4 = z4**4 + b * z4**3 + c * z4**2 + d * z4 + e

        # Update estimates
        new_z1 = z1 - p1 / ((z1 - z2) * (z1 - z3) * (z1 - z4))
        new_z2 = z2 - p2 / ((z2 - z1) * (z2 - z3) * (z2 - z4))
        new_z3 = z3 - p3 / ((z3 - z1) * (z3 - z2) * (z3 - z4))
        new_z4 = z4 - p4 / ((z4 - z1) * (z4 - z2) * (z4 - z3))

        # Check convergence
        if (new_z1 - z1).abs < tolerance &&
            (new_z2 - z2).abs < tolerance &&
            (new_z3 - z3).abs < tolerance &&
            (new_z4 - z4).abs < tolerance
          break
        end

        z1, z2, z3, z4 = new_z1, new_z2, new_z3, new_z4
      end

      # Extract real roots (imaginary part close to zero)
      roots = [z1, z2, z3, z4]
      roots.select { |z| z.imag.abs < tolerance }.map(&:real)
    end
  end
end
