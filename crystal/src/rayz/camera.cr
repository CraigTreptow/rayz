module Rayz
  class Camera
    getter hsize : Int32
    getter vsize : Int32
    getter field_of_view : Float64
    getter pixel_size : Float64
    getter half_width : Float64
    getter half_height : Float64
    getter transform : Matrix
    property samples_per_pixel : Int32
    property aperture_size : Float64
    property focal_distance : Float64

    def initialize(hsize : Int32, vsize : Int32, field_of_view : Float64,
                   samples_per_pixel : Int32 = 1, aperture_size : Float64 = 0.0,
                   focal_distance : Float64 = 1.0)
      @hsize = hsize
      @vsize = vsize
      @field_of_view = field_of_view
      @samples_per_pixel = samples_per_pixel
      @aperture_size = aperture_size
      @focal_distance = focal_distance
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

    def ray_for_pixel(px : Int32, py : Int32,
                      pixel_offset_x : Float64 = 0.5, pixel_offset_y : Float64 = 0.5,
                      aperture_offset_x : Float64 = 0.0, aperture_offset_y : Float64 = 0.0) : Ray
      xoffset = (px + pixel_offset_x) * @pixel_size
      yoffset = (py + pixel_offset_y) * @pixel_size

      world_x = @half_width - xoffset
      world_y = @half_height - yoffset

      pixel_t = @transform_inverse * Point.new(world_x, world_y, -@focal_distance)
      pixel = Point.new(pixel_t.x, pixel_t.y, pixel_t.z)

      aperture_x = aperture_offset_x * @aperture_size
      aperture_y = aperture_offset_y * @aperture_size
      origin_t = @transform_inverse * Point.new(aperture_x, aperture_y, 0.0)
      origin = Point.new(origin_t.x, origin_t.y, origin_t.z)

      dir_t = (pixel - origin).normalize
      direction = Vector.new(dir_t.x, dir_t.y, dir_t.z)

      Ray.new(origin, direction)
    end

    def render(world : World) : Canvas
      image = Canvas.new(@hsize, @vsize)
      (0...@vsize).each do |y|
        (0...@hsize).each do |x|
          color = render_pixel(x, y, world)
          image.write_pixel(x, @vsize - 1 - y, color)
        end
      end
      image
    end

    private def render_pixel(px : Int32, py : Int32, world : World) : Color
      return world.color_at(ray_for_pixel(px, py)) if @samples_per_pixel == 1 && @aperture_size == 0.0

      total_r = 0.0
      total_g = 0.0
      total_b = 0.0

      @samples_per_pixel.times do
        pox = rand
        poy = rand
        aox = @aperture_size > 0.0 ? rand * 2.0 - 1.0 : 0.0
        aoy = @aperture_size > 0.0 ? rand * 2.0 - 1.0 : 0.0

        ray = ray_for_pixel(px, py, pox, poy, aox, aoy)
        color = world.color_at(ray)
        total_r += color.red
        total_g += color.green
        total_b += color.blue
      end

      divisor = @samples_per_pixel.to_f
      Color.new(total_r / divisor, total_g / divisor, total_b / divisor)
    end
  end
end
