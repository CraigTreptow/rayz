require "../spec_helper"

module Rayz
  describe OBJParser do
    it "ignoring unrecognized lines" do
      content = "There was a young lady named Bright\n" \
                "who traveled much faster than light.\n" \
                "She set out one day\n" \
                "in a relative way,\n" \
                "and came back the previous night.\n"
      parser = Rayz.parse_obj_file(content)
      parser.ignored_lines.should eq(5)
    end

    it "vertex records" do
      content = "v -1 1 0\nv -1.0000 0.5000 0.0000\nv 1 0 0\nv 1 1 0\n"
      parser = Rayz.parse_obj_file(content)
      parser.vertices[1].not_nil!.x.should be_close(-1.0, 1e-5)
      parser.vertices[1].not_nil!.y.should be_close(1.0, 1e-5)
      parser.vertices[1].not_nil!.z.should be_close(0.0, 1e-5)
      parser.vertices[2].not_nil!.x.should be_close(-1.0, 1e-5)
      parser.vertices[2].not_nil!.y.should be_close(0.5, 1e-5)
      parser.vertices[3].not_nil!.x.should be_close(1.0, 1e-5)
      parser.vertices[4].not_nil!.y.should be_close(1.0, 1e-5)
    end

    it "parsing triangle faces" do
      content = "v -1 1 0\nv -1 0 0\nv 1 0 0\nv 1 1 0\n\nf 1 2 3\nf 1 3 4\n"
      parser = Rayz.parse_obj_file(content)
      g = parser.default_group
      t1 = g.children[0].as(Triangle)
      t2 = g.children[1].as(Triangle)
      t1.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t1.p2.x.should be_close(parser.vertices[2].not_nil!.x, 1e-5)
      t1.p3.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t2.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t2.p2.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t2.p3.x.should be_close(parser.vertices[4].not_nil!.x, 1e-5)
    end

    it "triangulating polygons" do
      content = "v -1 1 0\nv -1 0 0\nv 1 0 0\nv 1 1 0\nv 0 2 0\n\nf 1 2 3 4 5\n"
      parser = Rayz.parse_obj_file(content)
      g = parser.default_group
      t1 = g.children[0].as(Triangle)
      t2 = g.children[1].as(Triangle)
      t3 = g.children[2].as(Triangle)
      t1.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t1.p2.x.should be_close(parser.vertices[2].not_nil!.x, 1e-5)
      t1.p3.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t2.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t2.p2.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t2.p3.x.should be_close(parser.vertices[4].not_nil!.x, 1e-5)
      t3.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t3.p2.x.should be_close(parser.vertices[4].not_nil!.x, 1e-5)
      t3.p3.x.should be_close(parser.vertices[5].not_nil!.x, 1e-5)
    end

    it "triangles in groups" do
      content = File.read(File.join(__DIR__, "../files/triangles.obj"))
      parser = Rayz.parse_obj_file(content)
      g1 = parser.group("FirstGroup")
      g2 = parser.group("SecondGroup")
      t1 = g1.children[0].as(Triangle)
      t2 = g2.children[0].as(Triangle)
      t1.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t1.p2.x.should be_close(parser.vertices[2].not_nil!.x, 1e-5)
      t1.p3.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t2.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t2.p2.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t2.p3.x.should be_close(parser.vertices[4].not_nil!.x, 1e-5)
    end

    it "converting an OBJ file to a group" do
      content = File.read(File.join(__DIR__, "../files/triangles.obj"))
      parser = Rayz.parse_obj_file(content)
      g = Rayz.obj_to_group(parser)
      g.includes?(parser.group("FirstGroup")).should be_true
      g.includes?(parser.group("SecondGroup")).should be_true
    end

    it "vertex normal records" do
      content = "vn 0 0 1\nvn 0.707 0 -0.707\nvn 1 2 3\n"
      parser = Rayz.parse_obj_file(content)
      parser.normals[1].not_nil!.z.should be_close(1.0, 1e-5)
      parser.normals[2].not_nil!.x.should be_close(0.707, 1e-3)
      parser.normals[3].not_nil!.y.should be_close(2.0, 1e-5)
    end

    it "faces with normals" do
      content = "v 0 1 0\nv -1 0 0\nv 1 0 0\n\n" \
                "vn -1 0 0\nvn 1 0 0\nvn 0 1 0\n\n" \
                "f 1//3 2//1 3//2\nf 1/0/3 2/102/1 3/14/2\n"
      parser = Rayz.parse_obj_file(content)
      g = parser.default_group
      t1 = g.children[0].as(SmoothTriangle)
      t2 = g.children[1].as(SmoothTriangle)
      t1.p1.x.should be_close(parser.vertices[1].not_nil!.x, 1e-5)
      t1.p2.x.should be_close(parser.vertices[2].not_nil!.x, 1e-5)
      t1.p3.x.should be_close(parser.vertices[3].not_nil!.x, 1e-5)
      t1.n1.z.should be_close(parser.normals[3].not_nil!.z, 1e-5)
      t1.n2.x.should be_close(parser.normals[1].not_nil!.x, 1e-5)
      t1.n3.x.should be_close(parser.normals[2].not_nil!.x, 1e-5)
      t2.p1.x.should be_close(t1.p1.x, 1e-5)
      t2.n1.z.should be_close(t1.n1.z, 1e-5)
    end
  end
end
