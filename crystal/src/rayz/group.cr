module Rayz
  class Group < Shape
    getter children : Array(Shape)

    def initialize
      super
      @children = [] of Shape
    end

    def add_child(shape : Shape) : Nil
      @children << shape
      shape.parent = self
    end

    def empty? : Bool
      @children.empty?
    end

    def includes?(shape : Shape) : Bool
      same?(shape) || @children.any? { |c| c.includes?(shape) }
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      xs = [] of Intersection
      @children.each { |child| xs.concat(child.intersect(local_ray)) }
      xs.sort
    end

    def local_normal_at(local_point : Point) : Tuple
      raise "Group#local_normal_at should never be called directly"
    end
  end
end
