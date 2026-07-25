module Rayz
  class CSG < Shape
    getter operation : String
    getter left : Shape
    getter right : Shape

    def initialize(operation : String, left : Shape, right : Shape)
      super()
      @operation = operation
      @left = left
      @right = right
      left.parent = self
      right.parent = self
    end

    def intersection_allowed?(lhit : Bool, inl : Bool, inr : Bool) : Bool
      case @operation
      when "union"
        (lhit && !inr) || (!lhit && !inl)
      when "intersection"
        (lhit && inr) || (!lhit && inl)
      when "difference"
        (lhit && !inr) || (!lhit && inl)
      else
        false
      end
    end

    def filter_intersections(xs : Array(Intersection)) : Array(Intersection)
      inl = false
      inr = false
      result = [] of Intersection

      xs.each do |i|
        lhit = @left.includes?(i.object)
        result << i if intersection_allowed?(lhit, inl, inr)
        if lhit
          inl = !inl
        else
          inr = !inr
        end
      end

      result
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      return [] of Intersection unless bounds.intersects?(local_ray)

      xs = (@left.intersect(local_ray) + @right.intersect(local_ray)).sort
      filter_intersections(xs)
    end

    def bounds : Bounds
      @left.bounds.transform(@left.transform).merge(
        @right.bounds.transform(@right.transform)
      )
    end

    def local_normal_at(local_point : Point) : Tuple
      raise "CSG#local_normal_at should never be called directly"
    end

    def includes?(shape : Shape) : Bool
      @left.includes?(shape) || @right.includes?(shape)
    end
  end
end
