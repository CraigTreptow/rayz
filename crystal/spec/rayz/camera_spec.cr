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

  it "default camera has samples_per_pixel=1, aperture_size=0, focal_distance=1" do
    c = Rayz::Camera.new(160, 120, Math::PI / 2.0)
    c.samples_per_pixel.should eq(1)
    c.aperture_size.should be_close(0.0, 1e-5)
    c.focal_distance.should be_close(1.0, 1e-5)
  end

  it "camera with anti-aliasing renders without error" do
    w = Rayz::World.default_world
    c = Rayz::Camera.new(11, 11, Math::PI / 2.0, samples_per_pixel: 4)
    c.transform = Rayz::Transformations.view_transform(
      Rayz::Point.new(0.0, 0.0, -5.0),
      Rayz::Point.new(0.0, 0.0, 0.0),
      Rayz::Vector.new(0.0, 1.0, 0.0)
    )
    image = c.render(w)
    image.width.should eq(11)
    image.height.should eq(11)
  end

  it "camera with focal blur renders without error" do
    w = Rayz::World.default_world
    c = Rayz::Camera.new(11, 11, Math::PI / 2.0, samples_per_pixel: 4, aperture_size: 0.1, focal_distance: 2.0)
    c.transform = Rayz::Transformations.view_transform(
      Rayz::Point.new(0.0, 0.0, -5.0),
      Rayz::Point.new(0.0, 0.0, 0.0),
      Rayz::Vector.new(0.0, 1.0, 0.0)
    )
    image = c.render(w)
    image.width.should eq(11)
    image.height.should eq(11)
  end

  it "ray_for_pixel with sub-pixel offset differs from center" do
    c = Rayz::Camera.new(201, 101, Math::PI / 2.0)
    r_center = c.ray_for_pixel(100, 50, 0.5, 0.5)
    r_offset = c.ray_for_pixel(100, 50, 0.1, 0.9)
    r_center.direction.should_not eq(r_offset.direction)
  end

  it "ray_for_pixel with aperture offset shifts origin" do
    c = Rayz::Camera.new(201, 101, Math::PI / 2.0, aperture_size: 0.5)
    r_center = c.ray_for_pixel(100, 50, 0.5, 0.5, 0.0, 0.0)
    r_offset = c.ray_for_pixel(100, 50, 0.5, 0.5, 0.5, 0.0)
    r_center.origin.should_not eq(r_offset.origin)
  end
end
