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

Then('A * B is the following {} matrix:') do |size, table|
  table_values = table.raw
  expected = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
  assert_equal(@m_a * @m_b, expected)
end

Then("M[{int},{int}] = {}") do |int, int2, val|
  m_val = @m[int, int2]
  assert_equal(m_val, val.to_f)
end
