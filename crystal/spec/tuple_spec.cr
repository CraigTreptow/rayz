require "../src/rayz"
require "spec"

describe Rayz::Tuple do
  describe "basic operations" do
    it "creates a tuple with given coordinates" do
      t = Rayz::Tuple.new(4.3, -4.2, 3.1, 1.0)
      t.x.should eq(4.3)
      t.y.should eq(-4.2)
      t.z.should eq(3.1)
      t.w.should eq(1.0)
    end

    it "adds two tuples" do
      t1 = Rayz::Tuple.new(3, -2, 5, 1)
      t2 = Rayz::Tuple.new(-2, 3, 1, 0)
      result = t1 + t2
      result.should eq(Rayz::Tuple.new(1, 1, 6, 1))
    end

    it "multiplies tuple by scalar" do
      t = Rayz::Tuple.new(1, -2, 3, -4)
      result = t * 3.5
      result.should eq(Rayz::Tuple.new(3.5, -7, 10.5, -14))
    end

    it "computes magnitude" do
      v = Rayz::Vector.new(1, 0, 0)
      v.magnitude.should eq(1.0)
    end

    it "normalizes a vector" do
      v = Rayz::Vector.new(4, 0, 0)
      normalized = v.normalize
      normalized.should eq(Rayz::Vector.new(1, 0, 0))
    end

    it "computes dot product" do
      v1 = Rayz::Vector.new(1, 2, 3)
      v2 = Rayz::Vector.new(2, 3, 4)
      v1.dot(v2).should eq(20.0)
    end

    it "computes cross product" do
      v1 = Rayz::Vector.new(1, 2, 3)
      v2 = Rayz::Vector.new(2, 3, 4)
      v1.cross(v2).should eq(Rayz::Vector.new(-1, 2, -1))
    end
  end
end

describe Rayz::Point do
  it "creates a point with w=1.0" do
    p = Rayz::Point.new(4, -4, 3)
    p.w.should eq(1.0)
    p.point?.should be_true
  end
end

describe Rayz::Vector do
  it "creates a vector with w=0.0" do
    v = Rayz::Vector.new(4, -4, 3)
    v.w.should eq(0.0)
    v.vector?.should be_true
  end

  it "reflects a vector around a normal" do
    v = Rayz::Vector.new(1, -1, 0)
    n = Rayz::Vector.new(0, 1, 0)
    r = v.reflect(n)
    r.should eq(Rayz::Vector.new(1, 1, 0))
  end
end
