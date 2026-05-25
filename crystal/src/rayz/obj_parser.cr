module Rayz
  class OBJParser
    getter ignored_lines : Int32
    getter vertices : Array(Point?)
    getter normals : Array(Vector?)
    getter default_group : Group
    getter groups : Hash(String, Group)

    def initialize
      @ignored_lines = 0
      @vertices = [nil] of Point?
      @normals = [nil] of Vector?
      @default_group = Group.new
      @groups = {} of String => Group
      @current_group = @default_group
    end

    def parse(content : String) : self
      content.each_line do |line|
        line = line.strip
        next if line.empty?
        parse_line(line)
      end
      self
    end

    def group(name : String) : Group
      @groups[name]
    end

    def to_group : Group
      g = Group.new
      g.add_child(@default_group) unless @default_group.empty?
      @groups.each_value { |named| g.add_child(named) }
      g
    end

    private def parse_line(line : String) : Nil
      parts = line.split
      case parts[0]
      when "v"  then parse_vertex(parts)
      when "vn" then parse_normal(parts)
      when "f"  then parse_face(parts)
      when "g"  then parse_group(parts)
      else           @ignored_lines += 1
      end
    end

    private def parse_vertex(parts : Array(String)) : Nil
      @vertices << Point.new(parts[1].to_f, parts[2].to_f, parts[3].to_f)
    end

    private def parse_normal(parts : Array(String)) : Nil
      @normals << Vector.new(parts[1].to_f, parts[2].to_f, parts[3].to_f)
    end

    private def parse_face(parts : Array(String)) : Nil
      data = parts[1..].map do |s|
        chunks = s.split("/")
        {vi: chunks[0].to_i, ni: chunks[2]?.try(&.to_i?)}
      end

      (1..data.size - 2).each do |i|
        d0 = data[0]
        d1 = data[i]
        d2 = data[i + 1]

        p1 = @vertices[d0[:vi]].not_nil!
        p2 = @vertices[d1[:vi]].not_nil!
        p3 = @vertices[d2[:vi]].not_nil!

        if (ni0 = d0[:ni]) && (ni1 = d1[:ni]) && (ni2 = d2[:ni])
          n1 = @normals[ni0].not_nil!
          n2 = @normals[ni1].not_nil!
          n3 = @normals[ni2].not_nil!
          @current_group.add_child(SmoothTriangle.new(p1, p2, p3, n1, n2, n3))
        else
          @current_group.add_child(Triangle.new(p1, p2, p3))
        end
      end
    end

    private def parse_group(parts : Array(String)) : Nil
      name = parts[1]
      @groups[name] = Group.new unless @groups.has_key?(name)
      @current_group = @groups[name]
    end
  end

  def self.parse_obj_file(content : String) : OBJParser
    OBJParser.new.parse(content)
  end

  def self.obj_to_group(parser : OBJParser) : Group
    parser.to_group
  end
end
