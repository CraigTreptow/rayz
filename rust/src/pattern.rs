use crate::color::Color;
use crate::matrix::Matrix4;
use crate::point::Point;

#[derive(Debug, Clone)]
pub enum Pattern {
    Solid(Color),
    Stripe(Box<PatternData>),
    Gradient(Box<PatternData>),
    Ring(Box<PatternData>),
    Checkers(Box<PatternData>),
    Test(Matrix4),
}

#[derive(Debug, Clone)]
pub struct PatternData {
    pub a: Color,
    pub b: Color,
    pub transform: Matrix4,
    pub transform_inverse: Matrix4,
}

impl PatternData {
    pub fn new(a: Color, b: Color) -> Self {
        PatternData {
            a,
            b,
            transform: Matrix4::identity(),
            transform_inverse: Matrix4::identity(),
        }
    }

    pub fn with_transform(mut self, t: Matrix4) -> Self {
        self.transform_inverse = t.inverse();
        self.transform = t;
        self
    }
}

impl Pattern {
    pub fn solid(c: Color) -> Self {
        Pattern::Solid(c)
    }

    pub fn stripe(a: Color, b: Color) -> Self {
        Pattern::Stripe(Box::new(PatternData::new(a, b)))
    }

    pub fn gradient(a: Color, b: Color) -> Self {
        Pattern::Gradient(Box::new(PatternData::new(a, b)))
    }

    pub fn ring(a: Color, b: Color) -> Self {
        Pattern::Ring(Box::new(PatternData::new(a, b)))
    }

    pub fn checkers(a: Color, b: Color) -> Self {
        Pattern::Checkers(Box::new(PatternData::new(a, b)))
    }

    pub fn test() -> Self {
        Pattern::Test(Matrix4::identity())
    }

    pub fn set_transform(&mut self, t: Matrix4) {
        match self {
            Pattern::Stripe(d) | Pattern::Gradient(d) | Pattern::Ring(d) | Pattern::Checkers(d) => {
                d.transform_inverse = t.inverse();
                d.transform = t;
            }
            Pattern::Test(m) => *m = t,
            Pattern::Solid(_) => {}
        }
    }

    /// Returns the color at a point already in pattern space.
    pub fn pattern_at(&self, p: Point) -> Color {
        match self {
            Pattern::Solid(c) => *c,
            Pattern::Stripe(d) => {
                if p.x.floor() as i64 % 2 == 0 {
                    d.a
                } else {
                    d.b
                }
            }
            Pattern::Gradient(d) => {
                let fraction = p.x - p.x.floor();
                d.a + (d.b - d.a) * fraction
            }
            Pattern::Ring(d) => {
                let dist = (p.x * p.x + p.z * p.z).sqrt();
                if dist.floor() as i64 % 2 == 0 {
                    d.a
                } else {
                    d.b
                }
            }
            Pattern::Checkers(d) => {
                let sum = p.x.floor() as i64 + p.y.floor() as i64 + p.z.floor() as i64;
                if sum % 2 == 0 {
                    d.a
                } else {
                    d.b
                }
            }
            Pattern::Test(_) => Color::new(p.x, p.y, p.z),
        }
    }

    /// Transform a world point into pattern space and sample.
    /// `shape_transform_inverse` is the shape's cached inverse transform.
    pub fn pattern_at_shape(&self, shape_transform_inverse: &Matrix4, world_point: Point) -> Color {
        let object_point = shape_transform_inverse.mul_point(world_point);
        let pattern_inverse = match self {
            Pattern::Stripe(d) | Pattern::Gradient(d) | Pattern::Ring(d) | Pattern::Checkers(d) => {
                &d.transform_inverse
            }
            Pattern::Test(inv) => inv,
            Pattern::Solid(_) => return self.pattern_at(object_point),
        };
        let pattern_point = pattern_inverse.mul_point(object_point);
        self.pattern_at(pattern_point)
    }
}
