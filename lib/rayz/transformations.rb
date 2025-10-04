require "matrix"

module Rayz
  class Transformations
    # Create a translation matrix
    # Translation moves a point but does not affect vectors (w=0)
    def self.translation(x, y, z)
      Matrix[
        [1, 0, 0, x],
        [0, 1, 0, y],
        [0, 0, 1, z],
        [0, 0, 0, 1]
      ]
    end

    # Create a scaling matrix
    # Scaling affects both points and vectors
    # Negative values create reflections
    def self.scaling(x, y, z)
      Matrix[
        [x, 0, 0, 0],
        [0, y, 0, 0],
        [0, 0, z, 0],
        [0, 0, 0, 1]
      ]
    end

    # Create a rotation matrix around the X axis
    # Angle in radians
    def self.rotation_x(radians)
      cos_r = Math.cos(radians)
      sin_r = Math.sin(radians)
      Matrix[
        [1, 0, 0, 0],
        [0, cos_r, -sin_r, 0],
        [0, sin_r, cos_r, 0],
        [0, 0, 0, 1]
      ]
    end

    # Create a rotation matrix around the Y axis
    # Angle in radians
    def self.rotation_y(radians)
      cos_r = Math.cos(radians)
      sin_r = Math.sin(radians)
      Matrix[
        [cos_r, 0, sin_r, 0],
        [0, 1, 0, 0],
        [-sin_r, 0, cos_r, 0],
        [0, 0, 0, 1]
      ]
    end

    # Create a rotation matrix around the Z axis
    # Angle in radians
    def self.rotation_z(radians)
      cos_r = Math.cos(radians)
      sin_r = Math.sin(radians)
      Matrix[
        [cos_r, -sin_r, 0, 0],
        [sin_r, cos_r, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
      ]
    end

    # Create a shearing (skew) transformation matrix
    # Parameters specify how each coordinate affects the others:
    # xy: x moves in proportion to y
    # xz: x moves in proportion to z
    # yx: y moves in proportion to x
    # yz: y moves in proportion to z
    # zx: z moves in proportion to x
    # zy: z moves in proportion to y
    def self.shearing(xy, xz, yx, yz, zx, zy)
      Matrix[
        [1, xy, xz, 0],
        [yx, 1, yz, 0],
        [zx, zy, 1, 0],
        [0, 0, 0, 1]
      ]
    end

    # Create a view transformation matrix (for camera positioning)
    # from: point where the eye is
    # to: point where the eye is looking
    # up: vector indicating which direction is up
    def self.view_transform(from, to, up)
      forward = (to - from).normalize
      upn = up.normalize
      left = forward.cross(upn)
      true_up = left.cross(forward)

      orientation = Matrix[
        [left.x, left.y, left.z, 0],
        [true_up.x, true_up.y, true_up.z, 0],
        [-forward.x, -forward.y, -forward.z, 0],
        [0, 0, 0, 1]
      ]

      orientation * translation(-from.x, -from.y, -from.z)
    end
  end
end
