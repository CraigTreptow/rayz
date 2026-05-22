module Rayz
  class Transformations
    def self.translation(x : Number, y : Number, z : Number) : Matrix
      Matrix.new([
        [1.0, 0.0, 0.0, x.to_f],
        [0.0, 1.0, 0.0, y.to_f],
        [0.0, 0.0, 1.0, z.to_f],
        [0.0, 0.0, 0.0, 1.0],
      ])
    end

    def self.scaling(x : Number, y : Number, z : Number) : Matrix
      Matrix.new([
        [x.to_f, 0.0, 0.0, 0.0],
        [0.0, y.to_f, 0.0, 0.0],
        [0.0, 0.0, z.to_f, 0.0],
        [0.0, 0.0, 0.0, 1.0],
      ])
    end

    def self.rotation_x(radians : Float64) : Matrix
      cos_r = Math.cos(radians)
      sin_r = Math.sin(radians)
      Matrix.new([
        [1.0, 0.0, 0.0, 0.0],
        [0.0, cos_r, -sin_r, 0.0],
        [0.0, sin_r, cos_r, 0.0],
        [0.0, 0.0, 0.0, 1.0],
      ])
    end

    def self.rotation_y(radians : Float64) : Matrix
      cos_r = Math.cos(radians)
      sin_r = Math.sin(radians)
      Matrix.new([
        [cos_r, 0.0, sin_r, 0.0],
        [0.0, 1.0, 0.0, 0.0],
        [-sin_r, 0.0, cos_r, 0.0],
        [0.0, 0.0, 0.0, 1.0],
      ])
    end

    def self.rotation_z(radians : Float64) : Matrix
      cos_r = Math.cos(radians)
      sin_r = Math.sin(radians)
      Matrix.new([
        [cos_r, -sin_r, 0.0, 0.0],
        [sin_r, cos_r, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
      ])
    end

    def self.shearing(xy : Number, xz : Number, yx : Number, yz : Number, zx : Number, zy : Number) : Matrix
      Matrix.new([
        [1.0, xy.to_f, xz.to_f, 0.0],
        [yx.to_f, 1.0, yz.to_f, 0.0],
        [zx.to_f, zy.to_f, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
      ])
    end

    def self.view_transform(from : Point, to : Point, up : Vector) : Matrix
      forward_t = (to - from).normalize
      forward = Vector.new(forward_t.x, forward_t.y, forward_t.z)
      upn_t = up.normalize
      upn = Vector.new(upn_t.x, upn_t.y, upn_t.z)
      left = forward.cross(upn)
      true_up = left.cross(forward)

      orientation = Matrix.new([
        [left.x, left.y, left.z, 0.0],
        [true_up.x, true_up.y, true_up.z, 0.0],
        [-forward.x, -forward.y, -forward.z, 0.0],
        [0.0, 0.0, 0.0, 1.0],
      ])

      orientation * translation(-from.x, -from.y, -from.z)
    end
  end
end
