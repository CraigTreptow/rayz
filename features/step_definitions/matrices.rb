require "matrix"

Given("the following {} matrix M:") do |size, table|
  table_values = table.raw
  @m = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following matrix A:") do |table|
  table_values = table.raw
  @m_a = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following matrix B:") do |table|
  table_values = table.raw
  @m_b = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Then("A = B") do
  assert_equal(@m_a, @m_b)
end

Then("A != B") do
  refute_equal(@m_a, @m_b)
end

Then("A * B") do
  refute_equal(@m_a, @m_b)
end

Then("A * B is the following {} matrix:") do |size, table|
  table_values = table.raw
  expected = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
  assert_equal(@m_a * @m_b, expected)
end

Then('A * b = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(Rayz::Lib::Util.matrix_multiplied_by_tuple(@m_a, @b), expected)
end

Then("M[{int},{int}] = {}") do |int, int2, val|
  m_val = @m[int, int2]
  assert_equal(m_val, val.to_f)
end

Then('A * identity_matrix = A') do
  identity = Matrix.identity(4)
  assert_equal(@m_a * identity, @m_a)
end

Then('identity_matrix * a = a') do
  identity = Matrix.identity(4)
  assert_equal(Rayz::Lib::Util.matrix_multiplied_by_tuple(identity, @a), @a)
end
