module Rayz
  class OBJParser
    attr_reader :ignored_lines, :vertices, :normals, :default_group, :groups

    def initialize
      @ignored_lines = 0
      @vertices = [nil] # 1-based indexing
      @normals = [nil] # 1-based indexing
      @default_group = Group.new
      @groups = {}
      @current_group = @default_group
    end

    def parse(content)
      lines = content.is_a?(String) ? content.split("\n") : content.readlines

      lines.each do |line|
        line = line.strip
        next if line.empty?

        parse_line(line)
      end

      self
    end

    def group(name)
      @groups[name]
    end

    private

    def parse_line(line)
      parts = line.split
      command = parts[0]

      case command
      when "v"
        parse_vertex(parts)
      when "vn"
        parse_normal(parts)
      when "f"
        parse_face(parts)
      when "g"
        parse_group(parts)
      else
        @ignored_lines += 1
      end
    end

    def parse_vertex(parts)
      x = parts[1].to_f
      y = parts[2].to_f
      z = parts[3].to_f
      @vertices << Point.new(x: x, y: y, z: z)
    end

    def parse_normal(parts)
      x = parts[1].to_f
      y = parts[2].to_f
      z = parts[3].to_f
      @normals << Vector.new(x: x, y: y, z: z)
    end

    def parse_face(parts)
      # Parse vertex indices from face definition
      # Formats: "1", "1/2", "1/2/3", "1//3"
      vertices_data = parts[1..].map { |vertex_str|
        vertex_parts = vertex_str.split("/")
        {
          vertex: vertex_parts[0].to_i,
          texture: vertex_parts[1]&.to_i,
          normal: vertex_parts[2]&.to_i
        }
      }

      # Fan triangulation: create triangles from first vertex
      triangulate_face(vertices_data)
    end

    def triangulate_face(vertices_data)
      # Fan triangulation: vertex[0] is the anchor point
      # Create triangles: (0, i, i+1) for i from 1 to n-2
      (1...(vertices_data.length - 1)).each do |i|
        v1_data = vertices_data[0]
        v2_data = vertices_data[i]
        v3_data = vertices_data[i + 1]

        # Get vertex points
        p1 = @vertices[v1_data[:vertex]]
        p2 = @vertices[v2_data[:vertex]]
        p3 = @vertices[v3_data[:vertex]]

        # Check if normals are present
        if v1_data[:normal] && v2_data[:normal] && v3_data[:normal]
          # Create smooth triangle with normals
          n1 = @normals[v1_data[:normal]]
          n2 = @normals[v2_data[:normal]]
          n3 = @normals[v3_data[:normal]]
          triangle = SmoothTriangle.new(p1: p1, p2: p2, p3: p3, n1: n1, n2: n2, n3: n3)
        else
          # Create regular triangle
          triangle = Triangle.new(p1: p1, p2: p2, p3: p3)
        end

        @current_group.add_child(triangle)
      end
    end

    def parse_group(parts)
      group_name = parts[1]
      new_group = Group.new
      @groups[group_name] = new_group
      @current_group = new_group
    end
  end

  def self.parse_obj_file(file_or_string)
    parser = OBJParser.new
    parser.parse(file_or_string)
    parser
  end

  def self.obj_to_group(parser)
    group = Group.new

    # Add default group if it has children
    group.add_child(parser.default_group) unless parser.default_group.empty?

    # Add named groups
    parser.groups.each_value do |named_group|
      group.add_child(named_group)
    end

    group
  end
end
