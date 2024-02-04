Feature: Tuples, Vectors, and Points
  Scenario: A tuple with w=1.0 is a point
    Given a ← tuple(4.3, -4.2, 3.1, 1.0)
    Then a.x = 4.3
    And a.y = -4.2
    And a.z = 3.1
    And a.w = 1.0
    And a is a point
    And a is not a vector

  Scenario: A tuple with w=0 is a vector
    Given a ← tuple(4.3, -4.2, 3.1, 0)
    Then a.x = 4.3
    And a.y = -4.2
    And a.z = 3.1
    And a.w = 0
    And a is a vector
    And a is not a point

#   describe "Rayz.Tuple.cross/2" do
#     test "The cross product of two vectors" do
#       a = Builder.vector(1, 2, 3)
#       b = Builder.vector(2, 3, 4)
# 
#       cp1 = Rayz.Tuple.cross(a, b)
#       expected_vector1 = Builder.vector(-1, 2, -1)
#       assert Equality.equal?(cp1, expected_vector1) == true
# 
#       cp2 = Rayz.Tuple.cross(b, a)
#       expected_vector2 = Builder.vector(1, -2, 1)
#       assert Equality.equal?(cp2, expected_vector2) == true
#     end
#   end
# 
#   describe "Rayz.Tuple.dot/2" do
#     test "The dot product of two tuples" do
#       a = Builder.vector(1, 2, 3)
#       b = Builder.vector(2, 3, 4)
# 
#       assert Rayz.Tuple.dot(a, b) == 20
#     end
#   end
# 
#   describe "Rayz.Tuple.normalize/1" do
#     test "Normalizing vector(4, 0, 0) gives (1, 0, 0)" do
#       v = Builder.vector(4, 0, 0)
#       nv = Rayz.Tuple.normalize(v)
# 
#       expected_vector = Builder.vector(1, 0, 0)
# 
#       assert Equality.equal?(nv, expected_vector) == true
#     end
# 
#     test "Normalizing vector(1, 2, 3)" do
#       v = Builder.vector(1, 2, 3)
#       nv = Rayz.Tuple.normalize(v)
# 
#       #                                1/sqrt(14), 2/sqrt914), 3/sqrt(14)
#       expected_vector = Builder.vector(0.26726,    0.53452,    0.80178)
# 
#       assert Equality.equal?(nv, expected_vector) == true
#     end
#   end
# 
#   describe "Rayz.Tuple.magnitude/1" do
#     test "Computing the magnitude of vector(1, 0, 0)" do
#       v = Builder.vector(1, 0, 0)
# 
#       assert Rayz.Tuple.magnitude(v) == 1.0
#     end
# 
#     test "Computing the magnitude of vector(0, 1, 0)" do
#       v = Builder.vector(0, 1, 0)
# 
#       assert Rayz.Tuple.magnitude(v) == 1.0
#     end
# 
#     test "Computing the magnitude of vector(0, 0, 1)" do
#       v = Builder.vector(0, 0, 1)
# 
#       assert Rayz.Tuple.magnitude(v) == 1.0
#     end
# 
#     test "Computing the magnitude of vector(1, 2, 3)" do
#       v = Builder.vector(1, 2, 3)
# 
#       assert Rayz.Tuple.magnitude(v) == :math.sqrt(14)
#     end
# 
#     test "Computing the magnitude of vector(-1, -2, -3)" do
#       v = Builder.vector(-1, -2, -3)
# 
#       assert Rayz.Tuple.magnitude(v) == :math.sqrt(14)
#     end
#   end
# 
#   describe "Rayz.Tuple.divide/2" do
#     test "Dividing a tuple by a scalar" do
#       a = Builder.tuple(1, -2, 3, -4)
# 
#       b = Rayz.Tuple.divide(a, 2)
# 
#       expected_tuple = Builder.tuple(0.5, -1, 1.5, -2)
# 
#       assert Equality.equal?(b, expected_tuple) == true
#     end
#   end
# 
#   describe "Rayz.Tuple.multiply/2" do
#     test "Multiplying a tuple by a scalar" do
#       a = Builder.tuple(1, -2, 3, -4)
# 
#       b = Rayz.Tuple.multiply(a, 3.5)
# 
#       expected_tuple = Builder.tuple(3.5, -7, 10.5, -14)
# 
#       assert Equality.equal?(b, expected_tuple) == true
#     end
# 
#     test "Multiplying a tuple by a fraction" do
#       a = Builder.tuple(1, -2, 3, -4)
# 
#       b = Rayz.Tuple.multiply(a, 0.5)
# 
#       expected_tuple = Builder.tuple(0.5, -1, 1.5, -2)
# 
#       assert Equality.equal?(b, expected_tuple) == true
#     end
#   end
# 
#   describe "Rayz.Tuple.negate/1" do
#     test "Negating a tuple" do
#       a = Builder.tuple(1, -2, 3, -4)
# 
#       na = Rayz.Tuple.negate(a)
# 
#       expected_tuple = Builder.tuple(-1, 2, -3, 4)
# 
#       assert Equality.equal?(na, expected_tuple) == true
#     end
#   end
# 
#   describe "Rayz.Tuple.subtract/2" do
#     test "Subtracting two points" do
#       p1 = Builder.point(3, 2, 1)
#       p2 = Builder.point(5, 6, 7)
# 
#       v = Rayz.Tuple.subtract(p1, p2)
# 
#       expected_vector = Builder.vector(-2, -4, -6)
# 
#       assert Rayz.Tuple.is_vector?(v) == true
#       assert Equality.equal?(v, expected_vector) == true
#     end
# 
#     test "Subtracting a vector from a point" do
#       p = Builder.point(3, 2, 1)
#       v = Builder.vector(5, 6, 7)
# 
#       p = Rayz.Tuple.subtract(p, v)
#       expected_point = Builder.point(-2, -4, -6)
# 
#       assert Rayz.Tuple.is_point?(p) == true
#       assert Equality.equal?(p, expected_point) == true
#     end
# 
#     test "Subtracting two vectors" do 
#       v1 = Builder.vector(3, 2, 1)
#       v2 = Builder.vector(5, 6, 7)
# 
#       v = Rayz.Tuple.subtract(v1, v2)
#       expected_vector = Builder.vector(-2, -4, -6)
# 
#       assert Rayz.Tuple.is_vector?(v) == true
#       assert Equality.equal?(v, expected_vector) == true
#     end
# 
#     test "Subtracting a vector from the zero vector" do
#       v0 = Builder.vector(0, 0, 0)
#       v1 = Builder.vector(1, -2, 3)
# 
#       v = Rayz.Tuple.subtract(v0, v1)
#       expected_vector = Builder.vector(-1, 2, -3)
# 
#       assert Rayz.Tuple.is_vector?(v) == true
#       assert Equality.equal?(v, expected_vector) == true
#     end
#   end
# 
#   describe "Rayz.Tuple.add/2" do
#     test "adding two tuples" do
#       a1 = Builder.tuple(3, -2, 5, 1)
#       a2 = Builder.tuple(-2, 3, 1, 0)
# 
#       a3 = Rayz.Tuple.add(a1, a2)
# 
#       expected_tuple = Builder.tuple(1, 1, 6, 1)
# 
#       assert Equality.equal?(a3, expected_tuple) == true
#     end
#   end
# 
#   describe "Equality.equal?/2" do
#     test "the same point is equal to itself" do
#       p = Builder.point(1.0, 2.0, 3.0)
# 
#       assert Equality.equal?(p, p) == true
#     end
# 
#     test "two different points are different" do
#       p1 = Builder.point(1.0, 2.0, 3.0)
#       p2 = Builder.point(4.0, 5.0, 6.0)
# 
#       assert Equality.equal?(p1, p2) == false
#     end
# 
#     test "the same vector is equal to itself" do
#       v = Builder.vector(1.0, 2.0, 3.0)
# 
#       assert Equality.equal?(v, v) == true
#     end
# 
#     test "two different vectors are different" do
#       v1 = Builder.vector(1.0, 2.0, 3.0)
#       v2 = Builder.vector(4.0, 5.0, 6.0)
# 
#       assert Equality.equal?(v1, v2) == false
#     end
# 
#     test "vector is different than point" do
#       v = Builder.vector(1.0, 2.0, 3.0)
#       p = Builder.point(1.0, 2.0, 3.0)
# 
#       assert Equality.equal?(v, p) == false
#     end
#   end
# 
#   describe "Tuple" do
#     test "A tuple with w=1.0 is a point" do
#       a = Builder.tuple(4.3, -4.2, 3.1, 1.0)
# 
#       assert a.x ==  4.3
#       assert a.y == -4.2
#       assert a.z ==  3.1
#       assert a.w ==  1.0
# 
#       assert Rayz.Tuple.is_point?(a) == true
#       assert Rayz.Tuple.is_vector?(a) == false
#     end
# 
#     test "A tuple with w=0 is a vector" do
#       a = Builder.tuple(4.3, -4.2, 3.1, 0.0)
# 
#       assert a.x ==  4.3
#       assert a.y == -4.2
#       assert a.z ==  3.1
#       assert a.w ==  0
# 
#       assert Rayz.Tuple.is_point?(a) == false
#       assert Rayz.Tuple.is_vector?(a) == true
#     end
#   end
# end
# 