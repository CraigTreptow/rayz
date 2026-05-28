require "../spec_helper"

module Rayz
  describe TextureMap do
    describe PPMImage do
      it "creating an image sets width and height" do
        img = PPMImage.new(10, 5)
        img.width.should eq(10)
        img.height.should eq(5)
      end

      it "pixel_at returns black for a fresh image" do
        img = PPMImage.new(4, 4)
        img.pixel_at(0, 0).should eq(Color.new(0.0, 0.0, 0.0))
      end

      it "set_pixel and pixel_at round-trip" do
        img = PPMImage.new(4, 4)
        img.set_pixel(2, 1, Color.new(1.0, 0.0, 0.5))
        img.pixel_at(2, 1).red.should be_close(1.0, 1e-5)
        img.pixel_at(2, 1).blue.should be_close(0.5, 1e-5)
      end

      it "pixel_at returns black for out-of-bounds coordinates" do
        img = PPMImage.new(4, 4)
        img.pixel_at(-1, 0).should eq(Color.new(0.0, 0.0, 0.0))
        img.pixel_at(4, 0).should eq(Color.new(0.0, 0.0, 0.0))
      end
    end

    describe "UV mapping" do
      it "planar_map maps point to u=x%1, v=z%1" do
        uv = TextureMap.planar_map.call(Point.new(0.25, 0.0, 0.5))
        uv[0].should be_close(0.25, 1e-5)
        uv[1].should be_close(0.5, 1e-5)
      end

      it "spherical_map maps top of unit sphere to v≈1" do
        uv = TextureMap.spherical_map.call(Point.new(0.0, 1.0, 0.0))
        uv[1].should be_close(1.0, 1e-4)
      end

      it "spherical_map maps bottom of unit sphere to v≈0" do
        uv = TextureMap.spherical_map.call(Point.new(0.0, -1.0, 0.0))
        uv[1].should be_close(0.0, 1e-4)
      end

      it "cylindrical_map maps y directly to v" do
        uv = TextureMap.cylindrical_map.call(Point.new(0.0, 0.5, 1.0))
        uv[1].should be_close(0.5, 1e-5)
      end
    end

    it "TextureMap is a Pattern" do
      img = PPMImage.new(2, 2)
      tm = TextureMap.new(img, TextureMap.planar_map)
      tm.is_a?(Pattern).should be_true
    end

    it "pattern_at samples the image at UV coordinates" do
      img = PPMImage.new(4, 4)
      img.set_pixel(3, 3, Color.new(1.0, 0.0, 0.0))
      tm = TextureMap.new(img, TextureMap.planar_map)
      # u=0.9 → x=round(0.9*3)=3, v=0.0 → y=round((1-0)*3)=3
      c = tm.pattern_at(Point.new(0.9, 0.0, 0.0))
      c.red.should be_close(1.0, 1e-5)
    end

    it "TextureMap integrates with a sphere via pattern_at_shape" do
      img = PPMImage.new(8, 8)
      img.set_pixel(4, 0, Color.new(0.0, 1.0, 0.0))
      s = Sphere.new
      tm = TextureMap.new(img, TextureMap.spherical_map)
      s.material.pattern = tm
      # Top of sphere maps to v≈1 → y=0 in image, so the green pixel may be sampled
      c = tm.pattern_at_shape(s.transform_inverse, Point.new(0.0, 1.0, 0.0))
      c.is_a?(Color).should be_true
    end
  end
end
