module Rayz
  module NormalPerturbations
    # Sine wave perturbation
    def self.sine_wave(frequency: 10.0, amplitude: 0.1)
      ->(point) {
        Vector.new(
          x: Math.sin(point.y * frequency) * amplitude,
          y: Math.sin(point.z * frequency) * amplitude,
          z: Math.sin(point.x * frequency) * amplitude
        )
      }
    end

    # Quilted pattern perturbation
    def self.quilted(frequency: 5.0, amplitude: 0.15)
      ->(point) {
        u = Math.sin(point.x * frequency)
        v = Math.sin(point.z * frequency)
        magnitude = u * v * amplitude
        Vector.new(x: 0, y: magnitude, z: 0)
      }
    end

    # Simple 3D noise-like perturbation using sine waves
    def self.noise(frequency: 5.0, amplitude: 0.1)
      ->(point) {
        # Use different frequencies for x, y, z to avoid patterns
        nx = Math.sin(point.x * frequency + point.y * frequency * 0.7) * amplitude
        ny = Math.sin(point.y * frequency + point.z * frequency * 0.7) * amplitude
        nz = Math.sin(point.z * frequency + point.x * frequency * 0.7) * amplitude
        Vector.new(x: nx, y: ny, z: nz)
      }
    end

    # Ripple effect
    def self.ripples(center: Point.new(x: 0, y: 0, z: 0), frequency: 10.0, amplitude: 0.1)
      ->(point) {
        # Distance from center
        dx = point.x - center.x
        dz = point.z - center.z
        distance = Math.sqrt(dx * dx + dz * dz)

        # Ripple magnitude based on distance
        magnitude = Math.sin(distance * frequency) * amplitude

        # Perturbation along Y axis
        Vector.new(x: 0, y: magnitude, z: 0)
      }
    end
  end
end
