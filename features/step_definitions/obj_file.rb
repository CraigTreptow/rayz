Given(/^(gibberish|file) ← a file containing:$/) do |var_name, string|
  instance_variable_set("@#{var_name}", string)
end

Given(/^(file) ← the file "([^"]*)"$/) do |var_name, filename|
  filepath = File.join("features", "files", filename)
  content = File.read(filepath)
  instance_variable_set("@#{var_name}", content)
end

When(/^(parser) ← parse_obj_file\(([^)]+)\)$/) do |var_name, file_var|
  file_content = instance_variable_get("@#{file_var}")
  parser = Rayz.parse_obj_file(file_content)
  instance_variable_set("@#{var_name}", parser)
end

When(/^(g) ← obj_to_group\(([^)]+)\)$/) do |var_name, parser_var|
  parser = instance_variable_get("@#{parser_var}")
  group = Rayz.obj_to_group(parser)
  instance_variable_set("@#{var_name}", group)
end

Then(/^(parser) should have ignored (\d+) lines?$/) do |var_name, count|
  parser = instance_variable_get("@#{var_name}")
  assert_equal count.to_i, parser.ignored_lines
end

Then(/^(parser)\.vertices\[(\d+)\] = point\(([^,]+), ([^,]+), ([^)]+)\)$/) do |var_name, index, x, y, z|
  parser = instance_variable_get("@#{var_name}")
  expected = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  assert_equal expected, parser.vertices[index.to_i]
end

Then(/^(parser)\.normals\[(\d+)\] = vector\(([^,]+), ([^,]+), ([^)]+)\)$/) do |var_name, index, x, y, z|
  parser = instance_variable_get("@#{var_name}")
  expected = Rayz::Vector.new(x: x.to_f, y: y.to_f, z: z.to_f)
  assert_equal expected, parser.normals[index.to_i]
end

When(/^(g) ← (parser)\.default_group$/) do |var_name, parser_var|
  parser = instance_variable_get("@#{parser_var}")
  instance_variable_set("@#{var_name}", parser.default_group)
end

When(/^(g\d+) ← "([^"]+)" from (parser)$/) do |var_name, group_name, parser_var|
  parser = instance_variable_get("@#{parser_var}")
  group = parser.group(group_name)
  instance_variable_set("@#{var_name}", group)
end

When(/^(t\d+) ← (first|second|third) child of (g\d*)$/) do |var_name, position, group_var|
  group = instance_variable_get("@#{group_var}")
  index = case position
  when "first" then 0
  when "second" then 1
  when "third" then 2
  end
  instance_variable_set("@#{var_name}", group.children[index])
end

Then(/^(t\d+)\.(p[123]) = (parser)\.vertices\[(\d+)\]$/) do |tri_var, point_attr, parser_var, index|
  triangle = instance_variable_get("@#{tri_var}")
  parser = instance_variable_get("@#{parser_var}")
  expected = parser.vertices[index.to_i]
  actual = triangle.send(point_attr)
  assert_equal expected, actual
end

Then(/^(t\d+)\.(n[123]) = (parser)\.normals\[(\d+)\]$/) do |tri_var, normal_attr, parser_var, index|
  triangle = instance_variable_get("@#{tri_var}")
  parser = instance_variable_get("@#{parser_var}")
  expected = parser.normals[index.to_i]
  actual = triangle.send(normal_attr)
  assert_equal expected, actual
end

Then(/^(t\d+) = (t\d+)$/) do |var1, var2|
  obj1 = instance_variable_get("@#{var1}")
  obj2 = instance_variable_get("@#{var2}")
  assert_equal obj2, obj1
end

Then(/^(g) includes "([^"]+)" from (parser)$/) do |group_var, group_name, parser_var|
  group = instance_variable_get("@#{group_var}")
  parser = instance_variable_get("@#{parser_var}")
  named_group = parser.group(group_name)
  assert group.include?(named_group), "Group should include #{group_name}"
end
