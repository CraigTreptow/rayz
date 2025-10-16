Feature: Bounding Boxes

Scenario: Creating an empty bounding box
  Given box ← bounds()
  Then box.min = point(∞, ∞, ∞)
  And box.max = point(-∞, -∞, -∞)

Scenario: Creating a bounding box with volume
  Given box ← bounds(min: point(-1, -2, -3), max: point(3, 2, 1))
  Then box.min = point(-1, -2, -3)
  And box.max = point(3, 2, 1)

Scenario: A sphere has a bounding box
  Given shape ← sphere()
  When box ← bounds_of(shape)
  Then box.min = point(-1, -1, -1)
  And box.max = point(1, 1, 1)

Scenario: A plane has a bounding box
  Given shape ← plane()
  When box ← bounds_of(shape)
  Then box.min = point(-∞, 0, -∞)
  And box.max = point(∞, 0, ∞)

Scenario: A cube has a bounding box
  Given shape ← cube()
  When box ← bounds_of(shape)
  Then box.min = point(-1, -1, -1)
  And box.max = point(1, 1, 1)

Scenario: An unbounded cylinder has a bounding box
  Given shape ← cylinder()
  When box ← bounds_of(shape)
  Then box.min = point(-1, -∞, -1)
  And box.max = point(1, ∞, 1)

Scenario: A bounded cylinder has a bounding box
  Given shape ← cylinder()
  And shape.minimum ← -5
  And shape.maximum ← 3
  When box ← bounds_of(shape)
  Then box.min = point(-1, -5, -1)
  And box.max = point(1, 3, 1)

Scenario: An unbounded cone has a bounding box
  Given shape ← cone()
  When box ← bounds_of(shape)
  Then box.min = point(-∞, -∞, -∞)
  And box.max = point(∞, ∞, ∞)

Scenario: A bounded cone has a bounding box
  Given shape ← cone()
  And shape.minimum ← -5
  And shape.maximum ← 3
  When box ← bounds_of(shape)
  Then box.min = point(-5, -5, -5)
  And box.max = point(5, 3, 5)

Scenario: A triangle has a bounding box
  Given shape ← triangle(p1: point(-3, 7, 2), p2: point(6, 2, -4), p3: point(2, -1, -1))
  When box ← bounds_of(shape)
  Then box.min = point(-3, -1, -4)
  And box.max = point(6, 7, 2)

Scenario: Adding one bounding box to another
  Given box1 ← bounds(min: point(-5, -2, 0), max: point(7, 4, 4))
  And box2 ← bounds(min: point(8, -7, -2), max: point(14, 2, 8))
  When box3 ← merge(box1, box2)
  Then box3.min = point(-5, -7, -2)
  And box3.max = point(14, 4, 8)

Scenario: Checking to see if a box contains a given point
  Given box ← bounds(min: point(5, -2, 0), max: point(11, 4, 7))
  Then box contains point(5, -2, 0)
  And box contains point(11, 4, 7)
  And box contains point(8, 1, 3)
  But box does not contain point(3, 0, 3)
  And box does not contain point(8, -4, 3)
  And box does not contain point(8, 1, -1)
  And box does not contain point(13, 1, 3)
  And box does not contain point(8, 5, 3)
  And box does not contain point(8, 1, 8)

Scenario: Checking to see if a box contains a given box
  Given box ← bounds(min: point(5, -2, 0), max: point(11, 4, 7))
  Then box contains bounds(min: point(5, -2, 0), max: point(11, 4, 7))
  And box contains bounds(min: point(6, -1, 1), max: point(10, 3, 6))
  But box does not contain bounds(min: point(4, -3, -1), max: point(10, 3, 6))
  And box does not contain bounds(min: point(6, -1, 1), max: point(12, 5, 8))

Scenario: Transforming a bounding box
  Given box ← bounds(min: point(-1, -1, -1), max: point(1, 1, 1))
  And matrix ← rotation_x(π / 4) * rotation_y(π / 4)
  When box2 ← transform(box, matrix)
  Then box2.min = point(-1.4142, -1.7071, -1.7071)
  And box2.max = point(1.4142, 1.7071, 1.7071)

Scenario: Intersecting a ray with a bounding box at the origin
  Given box ← bounds(min: point(-1, -1, -1), max: point(1, 1, 1))
  And direction ← normalize(<1, 0, 0>)
  And r ← ray(point(-5, 0, 0), direction)
  Then intersects(box, r) = true

Scenario: Intersecting a ray with a bounding box at the origin (examples)
  Given box ← bounds(min: point(-1, -1, -1), max: point(1, 1, 1))
  Examples:
  | origin            | direction        | result |
  | point(5, 0.5, 0)  | vector(-1, 0, 0) | true   |
  | point(-5, 0.5, 0) | vector(1, 0, 0)  | true   |
  | point(0.5, 5, 0)  | vector(0, -1, 0) | true   |
  | point(0.5, -5, 0) | vector(0, 1, 0)  | true   |
  | point(0.5, 0, 5)  | vector(0, 0, -1) | true   |
  | point(0.5, 0, -5) | vector(0, 0, 1)  | true   |
  | point(0, 0.5, 0)  | vector(0, 0, 1)  | true   |
  | point(-2, 0, 0)   | vector(2, 4, 6)  | false  |
  | point(0, -2, 0)   | vector(6, 2, 4)  | false  |
  | point(0, 0, -2)   | vector(4, 6, 2)  | false  |
  | point(2, 0, 2)    | vector(0, 0, -1) | false  |
  | point(0, 2, 2)    | vector(0, -1, 0) | false  |
  | point(2, 2, 0)    | vector(-1, 0, 0) | false  |

Scenario: Intersecting a ray with a non-cubic bounding box
  Given box ← bounds(min: point(5, -2, 0), max: point(11, 4, 7))
  Examples:
  | origin             | direction        | result |
  | point(15, 1, 2)    | vector(-1, 0, 0) | true   |
  | point(-5, -1, 4)   | vector(1, 0, 0)  | true   |
  | point(7, 6, 5)     | vector(0, -1, 0) | true   |
  | point(9, -5, 6)    | vector(0, 1, 0)  | true   |
  | point(8, 2, 12)    | vector(0, 0, -1) | true   |
  | point(6, 0, -5)    | vector(0, 0, 1)  | true   |
  | point(8, 1, 3.5)   | vector(0, 0, 1)  | true   |
  | point(9, -1, -8)   | vector(2, 4, 6)  | false  |
  | point(8, 3, -4)    | vector(6, 2, 4)  | false  |
  | point(9, -1, -2)   | vector(4, 6, 2)  | false  |
  | point(4, 0, 9)     | vector(0, 0, -1) | false  |
  | point(8, 6, -1)    | vector(0, -1, 0) | false  |
  | point(12, 5, 4)    | vector(-1, 0, 0) | false  |

Scenario: A group has a bounding box that contains its children
  Given s ← sphere()
  And set_transform(s, translation(2, 5, -3) * scaling(2, 2, 2))
  And c ← cylinder()
  And c.minimum ← -2
  And c.maximum ← 2
  And set_transform(c, translation(-4, -1, 4) * scaling(0.5, 1, 0.5))
  And shape ← group()
  And add_child(shape, s)
  And add_child(shape, c)
  When box ← bounds_of(shape)
  Then box.min = point(-4.5, -3, -5)
  And box.max = point(4, 7, 4.5)

Scenario: Intersecting ray+group doesn't test children if box is missed
  Given child ← test_shape()
  And shape ← group()
  And add_child(shape, child)
  And r ← ray(point(0, 0, -5), vector(0, 1, 0))
  When xs ← intersect(shape, r)
  Then child.saved_ray is nothing

Scenario: Intersecting ray+group tests children if box is hit
  Given child ← test_shape()
  And shape ← group()
  And add_child(shape, child)
  And r ← ray(point(0, 0, -5), vector(0, 0, 1))
  When xs ← intersect(shape, r)
  Then child.saved_ray is not nothing
