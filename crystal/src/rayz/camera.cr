module Rayz
  class Camera
    getter hsize : Int32
    getter vsize : Int32
    getter field_of_view : Float64
    getter pixel_size : Float64
    getter half_width : Float64
    getter half_height : Float64
    getter transform : Matrix

    def initialize(hsize : Int32, vsize : Int32, field_of_view : Float64)
      @hsize = hsize
      @vsize = vsize
      @field_of_view = field_of_view
      @transform = Matrix.identity
      @transform_inverse = Matrix.identity

      half_view = Math.tan(@field_of_view / 2.0)
      aspect = @hsize.to_f / @vsize.to_f

      if aspect >= 1.0
        @half_width = half_view
        @half_height = half_view / aspect
      else
        @half_width = half_view * aspect
        @half_height = half_view
      end

      @pixel_size = (@half_width * 2.0) / @hsize
    end

    def transform=(m : Matrix)
      @transform = m
      @transform_inverse = m.inverse
    end

    def ray_for_pixel(px : Int32, py : Int32) : Ray
      xoffset = (px + 0.5) * @pixel_size
      yoffset = (py + 0.5) * @pixel_size

      world_x = @half_width - xoffset
      world_y = @half_height - yoffset

      pixel_t = @transform_inverse * Point.new(world_x, world_y, -1.0)
      pixel = Point.new(pixel_t.x, pixel_t.y, pixel_t.z)

      origin_t = @transform_inverse * Point.new(0.0, 0.0, 0.0)
      origin = Point.new(origin_t.x, origin_t.y, origin_t.z)

      dir_t = (pixel - origin).normalize
      direction = Vector.new(dir_t.x, dir_t.y, dir_t.z)

      Ray.new(origin, direction)
    end

    def render(world : World) : Canvas
      image = Canvas.new(@hsize, @vsize)
      (0...@vsize).each do |y|
        (0...@hsize).each do |x|
          ray = ray_for_pixel(x, y)
          color = world.color_at(ray)
          image.write_pixel(x, y, color)
        end
      end
      image
    end
  end
end
