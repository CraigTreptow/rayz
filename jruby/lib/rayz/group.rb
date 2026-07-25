require_relative "shape"

module Rayz
  class Group < Shape
    attr_reader :children

    def initialize
      super
      @children = []
    end

    def add_child(shape)
      @children << shape
      shape.parent = self
      invalidate_bounds_cache
    end

    def empty?
      @children.empty?
    end

    def include?(shape)
      @children.include?(shape)
    end

    def local_intersect(local_ray)
      # Optimization: check bounding box first
      return [] unless bounds.intersects?(local_ray)

      # Collect intersections from all children
      intersections = []
      @children.each do |child|
        xs = child.intersect(local_ray)
        intersections.concat(xs)
      end
      # Sort by t value
      intersections.sort_by(&:t)
    end

    def local_normal_at(local_point, hit = nil)
      # Groups have no surface of their own, so this should never be called
      raise "Groups have no surface and cannot have normals computed"
    end

    # Override includes? to recursively check children
    def includes?(shape)
      @children.any? { |child| child.includes?(shape) }
    end

    def bounds
      # Cached: recomputing this from scratch (recursing every descendant
      # and transforming each one's bounds) on every single ray test was
      # the dominant cost of local_intersect's bounding-box check.
      # Invalidated via invalidate_bounds_cache whenever a child is added
      # or any descendant's transform changes.
      @cached_bounds ||= begin
        result = Bounds.new

        @children.each do |child|
          child_bounds = child.bounds.transform(child.transform)
          result = result.merge(child_bounds)
        end

        result
      end
    end

    def invalidate_bounds_cache
      @cached_bounds = nil
      super
    end
  end
end
