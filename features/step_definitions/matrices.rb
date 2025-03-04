require "matrix"

Given("the following {} matrix M:") do |size, table|
  # table is a Cucumber::MultilineArgument::DataTable
  table_values = table.raw
  @m = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following matrix A:") do |table|
  table_values = table.raw
  @m_a = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following 3x3 matrix A:") do |table|
  table_values = table.raw
  @m_33_a = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following 4x4 matrix A:") do |table|
  table_values = table.raw
  @m_44_a = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following matrix B:") do |table|
  table_values = table.raw
  @m_b = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Given("the following 2x2 matrix A:") do |table|
  table_values = table.raw
  @m_22_a = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
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
  expected = Rayz::Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(Rayz::Util.matrix_multiplied_by_tuple(@m_a, @b), expected)
end

Then("M[{int},{int}] = {}") do |int, int2, val|
  m_val = @m[int, int2]
  assert_equal(m_val, val.to_f)
end

Then("A * identity_matrix = A") do
  identity = Matrix.identity(4)
  assert_equal(@m_a * identity, @m_a)
end

Then("identity_matrix * a = a") do
  identity = Matrix.identity(4)
  assert_equal(Rayz::Util.matrix_multiplied_by_tuple(identity, @a), @a)
end

Then('transpose\(A) is the following matrix:') do |table|
  table_values = table.raw
  expected = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
  assert_equal(@m_a.transpose, expected)
end

Given('A ← transpose\(identity_matrix)') do
  @m_a = Matrix.identity(4).transpose
end

Then("A = identity_matrix") do
  identity = Matrix.identity(4)
  assert_equal(@m_a, identity)
end

Then('determinant\(A) = {int}') do |int|
  assert_equal(@m_22_a.determinant, int)
end

Then('determinant\(B) = {int}') do |int|
  assert_equal(@m_22_b.determinant, int)
end

Then('submatrix\(A, {int}, {int}) is the following 2x2 matrix:') do |int, int2, table|
  table_values = table.raw
  expected = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
  assert_equal(@m_33_a.first_minor(int, int2), expected)
end

Then('submatrix\(A, {int}, {int}) is the following 3x3 matrix:') do |int, int2, table|
  table_values = table.raw
  expected = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
  assert_equal(@m_44_a.first_minor(int, int2), expected)
end

Then('B ← submatrix\(A, {int}, {int})') do |int, int2|
  @m_22_b = @m_33_a.first_minor(int, int2)
end

Then('minor\(A, {int}, {int}) = {int}') do |int, int2, int3|
  minor = Rayz::Util.matrix_minor(@m_33_a, int, int2)
  assert_equal(minor, int3)
end
