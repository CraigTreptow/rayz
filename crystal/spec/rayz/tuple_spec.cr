require "../spec_helper"

describe "Tuples, Vectors, and Points" do
  it "A tuple with w=1.0 is a point" do
    a = Rayz::Tuple.new(4.3, -4.2, 3.1, 1.0)
    a.x.should eq(4.3)
    a.y.should eq(-4.2)
    a.z.should eq(3.1)
    a.w.should eq(1.0)
    a.point?.should be_true
    a.vector?.should be_false
  end

  it "A tuple with w=0 is a vector" do
    a = Rayz::Tuple.new(4.3, -4.2, 3.1, 0.0)
    a.x.should eq(4.3)
    a.y.should eq(-4.2)
    a.z.should eq(3.1)
    a.w.should eq(0.0)
    a.point?.should be_false
    a.vector?.should be_true
  end

  it "point() creates tuples with w=1" do
    p = Rayz::Point.new(4, -4, 3)
    p.should eq(Rayz::Tuple.new(4, -4, 3, 1))
  end

  it "vector() creates tuples with w=0" do
    v = Rayz::Vector.new(4, -4, 3)
    v.should eq(Rayz::Tuple.new(4, -4, 3, 0))
  end

  it "Adding two tuples" do
    a1 = Rayz::Tuple.new(3, -2, 5, 1)
    a2 = Rayz::Tuple.new(-2, 3, 1, 0)
    (a1 + a2).should eq(Rayz::Tuple.new(1, 1, 6, 1))
  end

  it "Subtracting two points" do
    p1 = Rayz::Point.new(3, 2, 1)
    p2 = Rayz::Point.new(5, 6, 7)
    (p1 - p2).should eq(Rayz::Vector.new(-2, -4, -6))
  end

  it "Subtracting a vector from a point" do
    p = Rayz::Point.new(3, 2, 1)
    v = Rayz::Vector.new(5, 6, 7)
    (p - v).should eq(Rayz::Point.new(-2, -4, -6))
  end

  it "Subtracting two vectors" do
    v1 = Rayz::Vector.new(3, 2, 1)
    v2 = Rayz::Vector.new(5, 6, 7)
    (v1 - v2).should eq(Rayz::Vector.new(-2, -4, -6))
  end

  it "Subtracting a vector from the zero vector" do
    zero = Rayz::Vector.new(0, 0, 0)
    v = Rayz::Vector.new(1, -2, 3)
    (zero - v).should eq(Rayz::Vector.new(-1, 2, -3))
  end

  it "Negating a tuple" do
    a = Rayz::Tuple.new(1, -2, 3, -4)
    (-a).should eq(Rayz::Tuple.new(-1, 2, -3, 4))
  end

  it "Multiplying a tuple by a scalar" do
    a = Rayz::Tuple.new(1, -2, 3, -4)
    (a * 3.5).should eq(Rayz::Tuple.new(3.5, -7, 10.5, -14))
  end

  it "Multiplying a tuple by a fraction" do
    a = Rayz::Tuple.new(1, -2, 3, -4)
    (a * 0.5).should eq(Rayz::Tuple.new(0.5, -1, 1.5, -2))
  end

  it "Dividing a tuple by a scalar" do
    a = Rayz::Tuple.new(1, -2, 3, -4)
    (a / 2).should eq(Rayz::Tuple.new(0.5, -1, 1.5, -2))
  end

  it "Computing the magnitude of vector(1, 0, 0)" do
    v = Rayz::Vector.new(1, 0, 0)
    v.magnitude.should eq(1.0)
  end

  it "Computing the magnitude of vector(0, 1, 0)" do
    v = Rayz::Vector.new(0, 1, 0)
    v.magnitude.should eq(1.0)
  end

  it "Computing the magnitude of vector(0, 0, 1)" do
    v = Rayz::Vector.new(0, 0, 1)
    v.magnitude.should eq(1.0)
  end

  it "Computing the magnitude of vector(1, 2, 3)" do
    v = Rayz::Vector.new(1, 2, 3)
    v.magnitude.should be_close(Math.sqrt(14.0), 0.00001)
  end

  it "Computing the magnitude of vector(-1, -2, -3)" do
    v = Rayz::Vector.new(-1, -2, -3)
    v.magnitude.should be_close(Math.sqrt(14.0), 0.00001)
  end

  it "Normalizing vector(4, 0, 0) gives (1, 0, 0)" do
    v = Rayz::Vector.new(4, 0, 0)
    v.normalize.should eq(Rayz::Vector.new(1, 0, 0))
  end

  it "Normalizing vector(1, 2, 3)" do
    v = Rayz::Vector.new(1, 2, 3)
    v.normalize.should eq(Rayz::Vector.new(0.26726, 0.53452, 0.80178))
  end

  it "The magnitude of a normalized vector" do
    v = Rayz::Vector.new(1, 2, 3)
    norm = v.normalize
    norm.magnitude.should be_close(1.0, 0.00001)
  end

  it "The dot product of two tuples" do
    v1 = Rayz::Vector.new(1, 2, 3)
    v2 = Rayz::Vector.new(2, 3, 4)
    v1.dot(v2).should eq(20.0)
  end

  it "The cross product of two vectors" do
    v1 = Rayz::Vector.new(1, 2, 3)
    v2 = Rayz::Vector.new(2, 3, 4)
    v1.cross(v2).should eq(Rayz::Vector.new(-1, 2, -1))
    v2.cross(v1).should eq(Rayz::Vector.new(1, -2, 1))
  end
end
