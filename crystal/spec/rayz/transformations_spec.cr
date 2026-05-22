require "../spec_helper"

describe "Transformations" do
  it "Multiplying by a translation matrix" do
    transform = Rayz::Transformations.translation(5, -3, 2)
    p = Rayz::Point.new(x: -3.0, y: 4.0, z: 5.0)
    (transform * p).should eq(Rayz::Point.new(x: 2.0, y: 1.0, z: 7.0))
  end

  it "Multiplying by the inverse of a translation matrix" do
    transform = Rayz::Transformations.translation(5, -3, 2)
    inv = transform.inverse
    p = Rayz::Point.new(x: -3.0, y: 4.0, z: 5.0)
    (inv * p).should eq(Rayz::Point.new(x: -8.0, y: 7.0, z: 3.0))
  end

  it "Translation does not affect vectors" do
    transform = Rayz::Transformations.translation(5, -3, 2)
    v = Rayz::Vector.new(x: -3.0, y: 4.0, z: 5.0)
    (transform * v).should eq(v)
  end

  it "A scaling matrix applied to a point" do
    transform = Rayz::Transformations.scaling(2, 3, 4)
    p = Rayz::Point.new(x: -4.0, y: 6.0, z: 8.0)
    (transform * p).should eq(Rayz::Point.new(x: -8.0, y: 18.0, z: 32.0))
  end

  it "A scaling matrix applied to a vector" do
    transform = Rayz::Transformations.scaling(2, 3, 4)
    v = Rayz::Vector.new(x: -4.0, y: 6.0, z: 8.0)
    (transform * v).should eq(Rayz::Vector.new(x: -8.0, y: 18.0, z: 32.0))
  end

  it "Multiplying by the inverse of a scaling matrix" do
    transform = Rayz::Transformations.scaling(2, 3, 4)
    inv = transform.inverse
    v = Rayz::Vector.new(x: -4.0, y: 6.0, z: 8.0)
    (inv * v).should eq(Rayz::Vector.new(x: -2.0, y: 2.0, z: 2.0))
  end

  it "Reflection is scaling by a negative value" do
    transform = Rayz::Transformations.scaling(-1, 1, 1)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: -2.0, y: 3.0, z: 4.0))
  end

  it "Rotating a point around the x axis" do
    p = Rayz::Point.new(x: 0.0, y: 1.0, z: 0.0)
    half_quarter = Rayz::Transformations.rotation_x(Math::PI / 4)
    full_quarter = Rayz::Transformations.rotation_x(Math::PI / 2)
    (half_quarter * p).should eq(Rayz::Point.new(x: 0.0, y: Math.sqrt(2.0) / 2.0, z: Math.sqrt(2.0) / 2.0))
    (full_quarter * p).should eq(Rayz::Point.new(x: 0.0, y: 0.0, z: 1.0))
  end

  it "The inverse of an x-rotation rotates in the opposite direction" do
    p = Rayz::Point.new(x: 0.0, y: 1.0, z: 0.0)
    half_quarter = Rayz::Transformations.rotation_x(Math::PI / 4)
    inv = half_quarter.inverse
    (inv * p).should eq(Rayz::Point.new(x: 0.0, y: Math.sqrt(2.0) / 2.0, z: -Math.sqrt(2.0) / 2.0))
  end

  it "Rotating a point around the y axis" do
    p = Rayz::Point.new(x: 0.0, y: 0.0, z: 1.0)
    half_quarter = Rayz::Transformations.rotation_y(Math::PI / 4)
    full_quarter = Rayz::Transformations.rotation_y(Math::PI / 2)
    (half_quarter * p).should eq(Rayz::Point.new(x: Math.sqrt(2.0) / 2.0, y: 0.0, z: Math.sqrt(2.0) / 2.0))
    (full_quarter * p).should eq(Rayz::Point.new(x: 1.0, y: 0.0, z: 0.0))
  end

  it "Rotating a point around the z axis" do
    p = Rayz::Point.new(x: 0.0, y: 1.0, z: 0.0)
    half_quarter = Rayz::Transformations.rotation_z(Math::PI / 4)
    full_quarter = Rayz::Transformations.rotation_z(Math::PI / 2)
    (half_quarter * p).should eq(Rayz::Point.new(x: -Math.sqrt(2.0) / 2.0, y: Math.sqrt(2.0) / 2.0, z: 0.0))
    (full_quarter * p).should eq(Rayz::Point.new(x: -1.0, y: 0.0, z: 0.0))
  end

  it "A shearing transformation moves x in proportion to y" do
    transform = Rayz::Transformations.shearing(1, 0, 0, 0, 0, 0)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: 5.0, y: 3.0, z: 4.0))
  end

  it "A shearing transformation moves x in proportion to z" do
    transform = Rayz::Transformations.shearing(0, 1, 0, 0, 0, 0)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: 6.0, y: 3.0, z: 4.0))
  end

  it "A shearing transformation moves y in proportion to x" do
    transform = Rayz::Transformations.shearing(0, 0, 1, 0, 0, 0)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: 2.0, y: 5.0, z: 4.0))
  end

  it "A shearing transformation moves y in proportion to z" do
    transform = Rayz::Transformations.shearing(0, 0, 0, 1, 0, 0)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: 2.0, y: 7.0, z: 4.0))
  end

  it "A shearing transformation moves z in proportion to x" do
    transform = Rayz::Transformations.shearing(0, 0, 0, 0, 1, 0)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: 2.0, y: 3.0, z: 6.0))
  end

  it "A shearing transformation moves z in proportion to y" do
    transform = Rayz::Transformations.shearing(0, 0, 0, 0, 0, 1)
    p = Rayz::Point.new(x: 2.0, y: 3.0, z: 4.0)
    (transform * p).should eq(Rayz::Point.new(x: 2.0, y: 3.0, z: 7.0))
  end

  it "Individual transformations are applied in sequence" do
    p = Rayz::Point.new(x: 1.0, y: 0.0, z: 1.0)
    a = Rayz::Transformations.rotation_x(Math::PI / 2)
    b = Rayz::Transformations.scaling(5, 5, 5)
    c = Rayz::Transformations.translation(10, 5, 7)
    p2 = a * p
    p2.should eq(Rayz::Point.new(x: 1.0, y: -1.0, z: 0.0))
    p3 = b * p2
    p3.should eq(Rayz::Point.new(x: 5.0, y: -5.0, z: 0.0))
    p4 = c * p3
    p4.should eq(Rayz::Point.new(x: 15.0, y: 0.0, z: 7.0))
  end

  it "Chained transformations must be applied in reverse order" do
    p = Rayz::Point.new(x: 1.0, y: 0.0, z: 1.0)
    a = Rayz::Transformations.rotation_x(Math::PI / 2)
    b = Rayz::Transformations.scaling(5, 5, 5)
    c = Rayz::Transformations.translation(10, 5, 7)
    t = c * b * a
    (t * p).should eq(Rayz::Point.new(x: 15.0, y: 0.0, z: 7.0))
  end
end
