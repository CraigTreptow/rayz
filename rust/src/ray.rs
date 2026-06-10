use crate::matrix::Matrix4;
use crate::point::Point;
use crate::vector::Vector;

#[derive(Debug, Clone, Copy)]
pub struct Ray {
    pub origin: Point,
    pub direction: Vector,
    pub time: f64,
}

impl Ray {
    pub fn new(origin: Point, direction: Vector) -> Self {
        Ray { origin, direction, time: 0.0 }
    }

    pub fn new_at_time(origin: Point, direction: Vector, time: f64) -> Self {
        Ray { origin, direction, time }
    }

    pub fn position(&self, t: f64) -> Point {
        self.origin + self.direction * t
    }

    pub fn transform(&self, m: &Matrix4) -> Ray {
        Ray {
            origin: m.mul_point(self.origin),
            direction: m.mul_vector(self.direction),
            time: self.time,
        }
    }
}
