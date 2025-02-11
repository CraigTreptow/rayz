require "matrix"

Given('the following {} matrix M:') do |size, table|
  table_values = table.raw
  @M = Matrix[*table_values.map { |row| row.map { |x| x.to_f } }]
end

Then('M[{int},{int}] = {}') do |int, int2, val|
  m_val = @M[int, int2]
  assert_equal(m_val, val.to_f)
end
