# Step definitions for world operations

Given("w ← world\\()") do
  @w = Rayz::World.new
end

Then("w contains no objects") do
  assert_equal(@w.objects.empty?, true)
end

Then("w has no light source") do
  assert_nil(@w.light)
end

Given("s1 ← sphere\\() with:") do |table|
  @s1 = Rayz::Sphere.new
  table.raw.each do |row|
    property = row[0].strip
    value = row[1].strip

    case property
    when "material.color"
      # Parse (0.8, 1.0, 0.6) format
      match = value.match(/\(([^,]+),\s*([^,]+),\s*([^)]+)\)/)
      if match
        @s1.material.color = Rayz::Color.new(red: match[1].to_f, green: match[2].to_f, blue: match[3].to_f)
      end
    when "material.diffuse"
      @s1.material.diffuse = value.to_f
    when "material.specular"
      @s1.material.specular = value.to_f
    when "material.ambient"
      @s1.material.ambient = value.to_f
    when "transform"
      # Handle transform parsing
      if value =~ /scaling\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        @s1.transform = Rayz::Transformations.scaling(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      elsif value =~ /translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        @s1.transform = Rayz::Transformations.translation(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      end
    end
  end
end

Given("s2 ← sphere\\() with:") do |table|
  @s2 = Rayz::Sphere.new
  table.raw.each do |row|
    property = row[0].strip
    value = row[1].strip

    case property
    when "material.color"
      match = value.match(/\(([^,]+),\s*([^,]+),\s*([^)]+)\)/)
      if match
        @s2.material.color = Rayz::Color.new(red: match[1].to_f, green: match[2].to_f, blue: match[3].to_f)
      end
    when "material.diffuse"
      @s2.material.diffuse = value.to_f
    when "material.specular"
      @s2.material.specular = value.to_f
    when "material.ambient"
      @s2.material.ambient = value.to_f
    when "transform"
      if value =~ /scaling\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        @s2.transform = Rayz::Transformations.scaling(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      elsif value =~ /translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        @s2.transform = Rayz::Transformations.translation(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      end
    end
  end
end

When("w ← default_world\\()") do
  @w = Rayz::World.default_world
end

Then("w.light = light") do
  assert_equal(@w.light, @light)
end

Then("w contains s1") do
  assert(@w.objects.include?(@s1))
end

Then("w contains s2") do
  assert(@w.objects.include?(@s2))
end

When("xs ← intersect_world\\(w, r)") do
  @xs = @w.intersect(@r)
end

Given("shape ← the first object in w") do
  @shape = @w.objects[0]
end

Given("shape ← the second object in w") do
  @shape = @w.objects[1]
end

When("i ← intersection\\({float}, shape)") do |t|
  @i = Rayz::Intersection.new(t: t, object: @shape)
end

When("comps ← prepare_computations\\(i, r)") do
  @comps = @i.prepare_computations(@r)
end

When("c ← shade_hit\\(w, comps)") do
  @c = @w.shade_hit(@comps)
end

When("w.light ← point_light\\(point\\({float}, {float}, {float}), color\\({float}, {float}, {float}))") do |px, py, pz, cr, cg, cb|
  position = Rayz::Point.new(x: px, y: py, z: pz)
  intensity = Rayz::Color.new(red: cr, green: cg, blue: cb)
  @w.light = Rayz::PointLight.new(position: position, intensity: intensity)
end

When("c ← color_at\\(w, r)") do
  @c = @w.color_at(@r)
end

Given("outer ← the first object in w") do
  @outer = @w.objects[0]
end

Given("outer.material.ambient ← {float}") do |value|
  @outer.material.ambient = value
end

Given("inner ← the second object in w") do
  @inner = @w.objects[1]
end

Given("inner.material.ambient ← {float}") do |value|
  @inner.material.ambient = value
end

Then("c = inner.material.color") do
  assert_equal(@c, @inner.material.color)
end

Then("is_shadowed\\(w, p) is false") do
  assert_equal(@w.is_shadowed?(@p), false)
end

Then("is_shadowed\\(w, p) is true") do
  assert_equal(@w.is_shadowed?(@p), true)
end

Given("s1 ← sphere\\()") do
  @s1 = Rayz::Sphere.new
end

Given("s1 is added to w") do
  @w.objects << @s1
end

Given("s2 is added to w") do
  @w.objects << @s2
end

When("i ← intersection\\({float}, s2)") do |t|
  @i = Rayz::Intersection.new(t: t, object: @s2)
end

Then("c = color\\({float}, {float}, {float})") do |r, g, b|
  expected = Rayz::Color.new(red: r, green: g, blue: b)
  assert_equal(@c, expected)
end
