require "matrix"

# Helper methods for matrix step definitions
module MatrixStepHelpers
  # Converts Cucumber table data to Ruby Matrix object
  # @param table [Cucumber::MultilineArgument::DataTable] Raw table data from feature file
  # @return [Matrix] Ruby Matrix with float values
  def table_to_matrix(table)
    table_values = table.raw
    Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
  end

  # Check floating point equality with tolerance
  # @param actual [Float] Actual value
  # @param expected [Float] Expected value
  # @return [Boolean] True if values are equal within tolerance
  def float_equal?(actual, expected)
    (actual - expected).abs < 0.00001
  end
end

World(MatrixStepHelpers)

# Generic matrix creation for any size (2x2, 3x3, 4x4)
Given("the following {} matrix M:") do |size, table|
  @matrix_m = table_to_matrix(table)
end

# Generic matrix A creation (size inferred from table)
Given("the following matrix A:") do |table|
  @matrix_a = table_to_matrix(table)
end

# 3x3 matrix A creation for submatrix operations
Given("the following 3x3 matrix A:") do |table|
  @matrix_3x3_a = table_to_matrix(table)
end

# 4x4 matrix A creation for transformation operations
Given("the following 4x4 matrix A:") do |table|
  @matrix_4x4_a = table_to_matrix(table)
end

# Generic matrix B creation for comparison and multiplication operations
Given("the following matrix B:") do |table|
  @matrix_b = table_to_matrix(table)
end

# 2x2 matrix A creation for determinant calculations
Given("the following 2x2 matrix A:") do |table|
  @matrix_2x2_a = table_to_matrix(table)
end

# Matrix equality comparison
Then("A = B") do
  assert_equal(@matrix_a, @matrix_b)
end

# Matrix inequality comparison
Then("A != B") do
  refute_equal(@matrix_a, @matrix_b)
end

# Matrix multiplication step (appears to be incomplete - should assert result)
Then("A * B") do
  refute_equal(@matrix_a, @matrix_b)
end

# Matrix multiplication with expected result verification
Then("A * B is the following {} matrix:") do |size, table|
  expected = table_to_matrix(table)
  assert_equal(@matrix_a * @matrix_b, expected)
end

# Matrix-tuple multiplication using custom utility method
Then('A * b = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Rayz::Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(Rayz::Util.matrix_multiplied_by_tuple(@matrix_a, @tuple_b), expected)
end

# Matrix element access verification
Then("M[{int},{int}] = {}") do |row, col, val|
  matrix_value = @matrix_m[row, col]
  assert_equal(matrix_value, val.to_f)
end

# Matrix multiplication by identity matrix (should equal original)
Then("A * identity_matrix = A") do
  identity = Matrix.identity(4)
  assert_equal(@matrix_a * identity, @matrix_a)
end

# Identity matrix multiplication with tuple (should equal original tuple)
Then("identity_matrix * a = a") do
  identity = Matrix.identity(4)
  assert_equal(Rayz::Util.matrix_multiplied_by_tuple(identity, @tuple_a), @tuple_a)
end

# Matrix transposition verification
Then('transpose\(A) is the following matrix:') do |table|
  expected = table_to_matrix(table)
  assert_equal(@matrix_a.transpose, expected)
end

# Create matrix A as transpose of identity matrix
Given('A ← transpose\(identity_matrix)') do
  @matrix_a = Matrix.identity(4).transpose
end

# Verify matrix A equals identity matrix
Then("A = identity_matrix") do
  identity = Matrix.identity(4)
  assert_equal(@matrix_a, identity)
end

# Matrix determinant calculation (works for any size)
Then('determinant\(A) = {int}') do |expected_determinant|
  matrix = @matrix_4x4_a || @matrix_3x3_a || @matrix_2x2_a
  assert_equal(matrix.determinant, expected_determinant)
end

# 2x2 matrix B determinant calculation
Then('determinant\(B) = {int}') do |expected_determinant|
  assert_equal(@matrix_2x2_b.determinant, expected_determinant)
end

# 3x3 matrix submatrix extraction (removes specified row and column)
Then('submatrix\(A, {int}, {int}) is the following 2x2 matrix:') do |row, col, table|
  expected = table_to_matrix(table)
  assert_equal(@matrix_3x3_a.first_minor(row, col), expected)
end

# 4x4 matrix submatrix extraction (removes specified row and column)
Then('submatrix\(A, {int}, {int}) is the following 3x3 matrix:') do |row, col, table|
  expected = table_to_matrix(table)
  assert_equal(@matrix_4x4_a.first_minor(row, col), expected)
end

# Extract submatrix from 3x3 matrix A and assign to 2x2 matrix B
Then('B ← submatrix\(A, {int}, {int})') do |row, col|
  @matrix_2x2_b = @matrix_3x3_a.first_minor(row, col)
end

# Matrix minor calculation (determinant of submatrix)
Then('minor\(A, {int}, {int}) = {int}') do |row, col, expected_minor|
  minor = Rayz::Util.matrix_minor(@matrix_3x3_a, row, col)
  assert_equal(minor, expected_minor)
end

# Matrix cofactor calculation (minor with sign adjustment)
Then('cofactor\(A, {int}, {int}) = {int}') do |row, col, expected_cofactor|
  cofactor = Rayz::Util.matrix_cofactor(@matrix_4x4_a || @matrix_3x3_a, row, col)
  assert_equal(cofactor, expected_cofactor)
end

# Matrix invertibility check - determinant != 0
Then("A is invertible") do
  refute_equal(@matrix_4x4_a.determinant, 0)
end

# Matrix non-invertibility check - determinant == 0
Then("A is not invertible") do
  assert_equal(@matrix_4x4_a.determinant, 0)
end

# Calculate inverse and assign to matrix B
Given('B ← inverse\(A)') do
  @matrix_b = @matrix_4x4_a.inverse
end

# Check matrix element equals fraction
Then('B[{int},{int}] = {int}\/{int}') do |row, col, numerator, denominator|
  expected = numerator.to_f / denominator.to_f
  assert float_equal?(@matrix_b[row, col], expected)
end

# Verify matrix B equals expected matrix
Then("B is the following 4x4 matrix:") do |table|
  expected = table_to_matrix(table)
  expected.row_vectors.each_with_index do |row, i|
    row.to_a.each_with_index do |val, j|
      assert float_equal?(@matrix_b[i, j], val), "Mismatch at [#{i},#{j}]: expected #{val}, got #{@matrix_b[i, j]}"
    end
  end
end

# Verify inverse(A) equals expected matrix
Then('inverse\(A) is the following 4x4 matrix:') do |table|
  expected = table_to_matrix(table)
  inverse = @matrix_4x4_a.inverse
  expected.row_vectors.each_with_index do |row, i|
    row.to_a.each_with_index do |val, j|
      assert float_equal?(inverse[i, j], val), "Mismatch at [#{i},#{j}]: expected #{val}, got #{inverse[i, j]}"
    end
  end
end

# Create 4x4 matrix B from table
Given("the following 4x4 matrix B:") do |table|
  @matrix_4x4_b = table_to_matrix(table)
end

# Matrix multiplication and assignment to C
Given("C ← A * B") do
  @matrix_c = @matrix_4x4_a * @matrix_4x4_b
end

# Verify C * inverse(B) = A
Then('C * inverse\(B) = A') do
  result = @matrix_c * @matrix_4x4_b.inverse
  @matrix_4x4_a.row_vectors.each_with_index do |row, i|
    row.to_a.each_with_index do |val, j|
      assert float_equal?(result[i, j], val), "Mismatch at [#{i},#{j}]: expected #{val}, got #{result[i, j]}"
    end
  end
end
