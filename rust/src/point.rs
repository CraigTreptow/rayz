use crate::util::approx_eq;
use crate::vector::Vector;

#[derive(Debug, Clone, Copy)]
pub struct Point {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

impl Point {
    pub fn new(x: f64, y: f64, z: f64) -> Self {
        Point { x, y, z }
    }

    pub fn origin() -> Self {
        Point { x: 0.0, y: 0.0, z: 0.0 }
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Self) -> bool {
        approx_eq(self.x, other.x) && approx_eq(self.y, other.y) && approx_eq(self.z, other.z)
    }
}

impl std::ops::Add<Vector> for Point {
    type Output = Point;
    fn add(self, rhs: Vector) -> Point {
        Point::new(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
    }
}

impl std::ops::Sub<Point> for Point {
    type Output = Vector;
    fn sub(self, rhs: Point) -> Vector {
        Vector::new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
    }
}

impl std::ops::Sub<Vector> for Point {
    type Output = Point;
    fn sub(self, rhs: Vector) -> Point {
        Point::new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
    }
}
