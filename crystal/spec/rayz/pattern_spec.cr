require "../spec_helper"

BLACK = Rayz::Color.new(0.0, 0.0, 0.0)
WHITE = Rayz::Color.new(1.0, 1.0, 1.0)

describe "StripePattern" do
  it "Creating a stripe pattern" do
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    pattern.a.should eq(WHITE)
    pattern.b.should eq(BLACK)
  end

  it "A stripe pattern is constant in y" do
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 1.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 2.0, 0.0)).should eq(WHITE)
  end

  it "A stripe pattern is constant in z" do
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 1.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 2.0)).should eq(WHITE)
  end

  it "A stripe pattern alternates in x" do
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.9, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(1.0, 0.0, 0.0)).should eq(BLACK)
    pattern.pattern_at(Rayz::Point.new(-0.1, 0.0, 0.0)).should eq(BLACK)
    pattern.pattern_at(Rayz::Point.new(-1.0, 0.0, 0.0)).should eq(BLACK)
    pattern.pattern_at(Rayz::Point.new(-1.1, 0.0, 0.0)).should eq(WHITE)
  end

  it "Stripes with an object transformation" do
    object = Rayz::Sphere.new
    object.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    c = pattern.pattern_at_shape(object.transform_inverse, Rayz::Point.new(1.5, 0.0, 0.0))
    c.should eq(WHITE)
  end

  it "Stripes with a pattern transformation" do
    object = Rayz::Sphere.new
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    pattern.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    c = pattern.pattern_at_shape(object.transform_inverse, Rayz::Point.new(1.5, 0.0, 0.0))
    c.should eq(WHITE)
  end

  it "Stripes with both an object and a pattern transformation" do
    object = Rayz::Sphere.new
    object.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    pattern = Rayz::StripePattern.new(WHITE, BLACK)
    pattern.transform = Rayz::Transformations.translation(0.5, 0.0, 0.0)
    c = pattern.pattern_at_shape(object.transform_inverse, Rayz::Point.new(2.5, 0.0, 0.0))
    c.should eq(WHITE)
  end
end

describe "TestPattern" do
  it "The default pattern transformation" do
    pattern = Rayz::TestPattern.new
    pattern.transform.should eq(Rayz::Matrix.identity)
  end

  it "Assigning a transformation" do
    pattern = Rayz::TestPattern.new
    pattern.transform = Rayz::Transformations.translation(1.0, 2.0, 3.0)
    pattern.transform.should eq(Rayz::Transformations.translation(1.0, 2.0, 3.0))
  end

  it "A pattern with an object transformation" do
    shape = Rayz::Sphere.new
    shape.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    pattern = Rayz::TestPattern.new
    c = pattern.pattern_at_shape(shape.transform_inverse, Rayz::Point.new(2.0, 3.0, 4.0))
    c.should eq(Rayz::Color.new(1.0, 1.5, 2.0))
  end

  it "A pattern with a pattern transformation" do
    shape = Rayz::Sphere.new
    pattern = Rayz::TestPattern.new
    pattern.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    c = pattern.pattern_at_shape(shape.transform_inverse, Rayz::Point.new(2.0, 3.0, 4.0))
    c.should eq(Rayz::Color.new(1.0, 1.5, 2.0))
  end

  it "A pattern with both an object and a pattern transformation" do
    shape = Rayz::Sphere.new
    shape.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    pattern = Rayz::TestPattern.new
    pattern.transform = Rayz::Transformations.translation(0.5, 1.0, 1.5)
    c = pattern.pattern_at_shape(shape.transform_inverse, Rayz::Point.new(2.5, 3.0, 3.5))
    c.should eq(Rayz::Color.new(0.75, 0.5, 0.25))
  end
end

describe "GradientPattern" do
  it "A gradient linearly interpolates between colors" do
    pattern = Rayz::GradientPattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.25, 0.0, 0.0)).should eq(Rayz::Color.new(0.75, 0.75, 0.75))
    pattern.pattern_at(Rayz::Point.new(0.5, 0.0, 0.0)).should eq(Rayz::Color.new(0.5, 0.5, 0.5))
    pattern.pattern_at(Rayz::Point.new(0.75, 0.0, 0.0)).should eq(Rayz::Color.new(0.25, 0.25, 0.25))
  end
end

describe "RingPattern" do
  it "A ring should extend in both x and z" do
    pattern = Rayz::RingPattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(1.0, 0.0, 0.0)).should eq(BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 1.0)).should eq(BLACK)
    pattern.pattern_at(Rayz::Point.new(0.708, 0.0, 0.708)).should eq(BLACK)
  end
end

describe "CheckersPattern" do
  it "Checkers should repeat in x" do
    pattern = Rayz::CheckersPattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.99, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(1.01, 0.0, 0.0)).should eq(BLACK)
  end

  it "Checkers should repeat in y" do
    pattern = Rayz::CheckersPattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.99, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 1.01, 0.0)).should eq(BLACK)
  end

  it "Checkers should repeat in z" do
    pattern = Rayz::CheckersPattern.new(WHITE, BLACK)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.0)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 0.99)).should eq(WHITE)
    pattern.pattern_at(Rayz::Point.new(0.0, 0.0, 1.01)).should eq(BLACK)
  end
end
