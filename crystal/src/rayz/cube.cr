module Rayz
  class Cube < Shape
    def local_intersect(local_ray : Ray) : Array(Intersection)
      xtmin, xtmax = check_axis(local_ray.origin.x, local_ray.direction.x)
      ytmin, ytmax = check_axis(local_ray.origin.y, local_ray.direction.y)
      ztmin, ztmax = check_axis(local_ray.origin.z, local_ray.direction.z)

      tmin = {xtmin, ytmin, ztmin}.max
      tmax = {xtmax, ytmax, ztmax}.min

      return [] of Intersection if tmin > tmax

      [Intersection.new(tmin, self), Intersection.new(tmax, self)]
    end

    def local_normal_at(local_point : Point) : Tuple
      ax = local_point.x.abs
      ay = local_point.y.abs
      az = local_point.z.abs
      maxc = {ax, ay, az}.max

      if maxc == ax
        Vector.new(local_point.x, 0.0, 0.0)
      elsif maxc == ay
        Vector.new(0.0, local_point.y, 0.0)
      else
        Vector.new(0.0, 0.0, local_point.z)
      end
    end

    def bounds : Bounds
      Bounds.new(min: Point.new(-1.0, -1.0, -1.0), max: Point.new(1.0, 1.0, 1.0))
    end

    private def check_axis(origin : Float64, direction : Float64) : {Float64, Float64}
      tmin_num = -1.0 - origin
      tmax_num = 1.0 - origin

      if direction.abs >= Util::EPSILON
        tmin = tmin_num / direction
        tmax = tmax_num / direction
      else
        tmin = tmin_num * Float64::INFINITY
        tmax = tmax_num * Float64::INFINITY
      end

      tmin < tmax ? {tmin, tmax} : {tmax, tmin}
    end
  end
end
