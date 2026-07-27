module Rayz
  class Group < Shape
    getter children : Array(Shape)
    @cached_bounds : Bounds?

    def initialize
      super
      @children = [] of Shape
      @cached_bounds = nil
    end

    def add_child(shape : Shape) : Nil
      @children << shape
      shape.parent = self
      invalidate_bounds_cache
    end

    def empty? : Bool
      @children.empty?
    end

    def includes?(shape : Shape) : Bool
      same?(shape) || @children.any? { |c| c.includes?(shape) }
    end

    def invalidate_bounds_cache : Nil
      @cached_bounds = nil
      super
    end

    def bounds : Bounds
      @cached_bounds ||= begin
        result = Bounds.new
        @children.each do |child|
          result = result.merge(child.bounds.transform(child.transform))
        end
        result
      end
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      return [] of Intersection unless bounds.intersects?(local_ray)

      xs = [] of Intersection
      @children.each { |child| child.intersect_into(local_ray, xs) }
      xs.sort
    end

    def local_normal_at(local_point : Point) : Tuple
      raise "Group#local_normal_at should never be called directly"
    end
  end
end
