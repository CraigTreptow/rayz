module Rayz
  module NormalPerturbations
    def self.sine_wave(frequency : Float64 = 10.0, amplitude : Float64 = 0.1) : Proc(Point, Vector)
      ->(point : Point) {
        Vector.new(
          Math.sin(point.y * frequency) * amplitude,
          Math.sin(point.z * frequency) * amplitude,
          Math.sin(point.x * frequency) * amplitude
        )
      }
    end

    def self.quilted(frequency : Float64 = 5.0, amplitude : Float64 = 0.15) : Proc(Point, Vector)
      ->(point : Point) {
        u = Math.sin(point.x * frequency)
        v = Math.sin(point.z * frequency)
        Vector.new(0.0, u * v * amplitude, 0.0)
      }
    end

    def self.noise(frequency : Float64 = 5.0, amplitude : Float64 = 0.1) : Proc(Point, Vector)
      ->(point : Point) {
        nx = Math.sin(point.x * frequency + point.y * frequency * 0.7) * amplitude
        ny = Math.sin(point.y * frequency + point.z * frequency * 0.7) * amplitude
        nz = Math.sin(point.z * frequency + point.x * frequency * 0.7) * amplitude
        Vector.new(nx, ny, nz)
      }
    end

    def self.ripples(center : Point = Point.new(0.0, 0.0, 0.0), frequency : Float64 = 10.0, amplitude : Float64 = 0.1) : Proc(Point, Vector)
      ->(point : Point) {
        dx = point.x - center.x
        dz = point.z - center.z
        distance = Math.sqrt(dx * dx + dz * dz)
        Vector.new(0.0, Math.sin(distance * frequency) * amplitude, 0.0)
      }
    end
  end
end
