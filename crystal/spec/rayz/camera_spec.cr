require "../spec_helper"

describe "Camera" do
  it "Constructing a camera" do
    c = Rayz::Camera.new(160, 120, Math::PI / 2.0)
    c.hsize.should eq(160)
    c.vsize.should eq(120)
    c.field_of_view.should be_close(Math::PI / 2.0, 0.0001)
    c.transform.should eq(Rayz::Matrix.identity)
  end

  it "The pixel size for a horizontal canvas" do
    c = Rayz::Camera.new(200, 125, Math::PI / 2.0)
    c.pixel_size.should be_close(0.01, 0.0001)
  end

  it "The pixel size for a vertical canvas" do
    c = Rayz::Camera.new(125, 200, Math::PI / 2.0)
    c.pixel_size.should be_close(0.01, 0.0001)
  end

  it "Constructing a ray through the center of the canvas" do
    c = Rayz::Camera.new(201, 101, Math::PI / 2.0)
    r = c.ray_for_pixel(100, 50)
    r.origin.should eq(Rayz::Point.new(0.0, 0.0, 0.0))
    r.direction.should eq(Rayz::Vector.new(0.0, 0.0, -1.0))
  end

  it "Constructing a ray through a corner of the canvas" do
    c = Rayz::Camera.new(201, 101, Math::PI / 2.0)
    r = c.ray_for_pixel(0, 0)
    r.origin.should eq(Rayz::Point.new(0.0, 0.0, 0.0))
    r.direction.should eq(Rayz::Vector.new(0.66519, 0.33259, -0.66851))
  end

  it "Constructing a ray when the camera is transformed" do
    c = Rayz::Camera.new(201, 101, Math::PI / 2.0)
    c.transform = Rayz::Transformations.rotation_y(Math::PI / 4.0) * Rayz::Transformations.translation(0.0, -2.0, 5.0)
    r = c.ray_for_pixel(100, 50)
    r.origin.should eq(Rayz::Point.new(0.0, 2.0, -5.0))
    r.direction.should eq(Rayz::Vector.new(Math.sqrt(2.0) / 2.0, 0.0, -Math.sqrt(2.0) / 2.0))
  end

  it "Rendering a world with a camera" do
    w = Rayz::World.default_world
    c = Rayz::Camera.new(11, 11, Math::PI / 2.0)
    from = Rayz::Point.new(0.0, 0.0, -5.0)
    to = Rayz::Point.new(0.0, 0.0, 0.0)
    up = Rayz::Vector.new(0.0, 1.0, 0.0)
    c.transform = Rayz::Transformations.view_transform(from, to, up)
    image = c.render(w)
    image.pixel_at(5, 5).should eq(Rayz::Color.new(0.38066, 0.47583, 0.2855))
  end
end
