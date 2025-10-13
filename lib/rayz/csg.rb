require_relative "shape"

module Rayz
  class CSG < Shape
    attr_reader :operation, :left, :right

    def initialize(operation:, left:, right:)
      super()
      @operation = operation
      @left = left
      @right = right
      # Set parent relationships
      @left.parent = self
      @right.parent = self
    end

    def local_intersect(local_ray)
      # Intersect ray with both children
      left_xs = @left.intersect(local_ray)
      right_xs = @right.intersect(local_ray)

      # Combine and sort intersections
      xs = (left_xs + right_xs).sort_by(&:t)

      # Filter based on CSG operation
      filter_intersections(xs)
    end

    def local_normal_at(local_point)
      # CSG objects have no surface of their own
      raise "CSG shapes have no surface and cannot have normals computed"
    end

    def includes?(shape)
      @left.includes?(shape) || @right.includes?(shape)
    end

    private

    def filter_intersections(xs)
      # Track whether we're inside each child shape
      inl = false
      inr = false
      result = []

      xs.each do |i|
        # Determine if intersection is on left or right child
        lhit = @left.includes?(i.object)

        # Check if this intersection is allowed
        if intersection_allowed?(lhit, inl, inr)
          result << i
        end

        # Toggle inside/outside state for the hit shape
        if lhit
          inl = !inl
        else
          inr = !inr
        end
      end

      result
    end

    def intersection_allowed?(lhit, inl, inr)
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
  end

  # Module-level helper function for testing
  def self.intersection_allowed(op, lhit, inl, inr)
    case op
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

  # Module-level helper function for testing
  def self.filter_intersections(csg, xs)
    csg.send(:filter_intersections, xs)
  end

  # Helper function to create CSG objects
  def self.csg(operation, left, right)
    CSG.new(operation: operation, left: left, right: right)
  end
end
