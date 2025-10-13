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
    end

    def empty?
      @children.empty?
    end

    def include?(shape)
      @children.include?(shape)
    end

    def local_intersect(local_ray)
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
  end
end
