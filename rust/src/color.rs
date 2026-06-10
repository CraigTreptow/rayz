use crate::util::approx_eq;

#[derive(Debug, Clone, Copy)]
pub struct Color {
    pub r: f64,
    pub g: f64,
    pub b: f64,
}

impl Color {
    pub const BLACK: Color = Color { r: 0.0, g: 0.0, b: 0.0 };
    pub const WHITE: Color = Color { r: 1.0, g: 1.0, b: 1.0 };

    pub fn new(r: f64, g: f64, b: f64) -> Self {
        Color { r, g, b }
    }
}

impl PartialEq for Color {
    fn eq(&self, other: &Self) -> bool {
        approx_eq(self.r, other.r) && approx_eq(self.g, other.g) && approx_eq(self.b, other.b)
    }
}

impl std::ops::Add for Color {
    type Output = Color;
    fn add(self, rhs: Color) -> Color {
        Color::new(self.r + rhs.r, self.g + rhs.g, self.b + rhs.b)
    }
}

impl std::ops::Sub for Color {
    type Output = Color;
    fn sub(self, rhs: Color) -> Color {
        Color::new(self.r - rhs.r, self.g - rhs.g, self.b - rhs.b)
    }
}

impl std::ops::Mul for Color {
    type Output = Color;
    fn mul(self, rhs: Color) -> Color {
        Color::new(self.r * rhs.r, self.g * rhs.g, self.b * rhs.b)
    }
}

impl std::ops::Mul<f64> for Color {
    type Output = Color;
    fn mul(self, rhs: f64) -> Color {
        Color::new(self.r * rhs, self.g * rhs, self.b * rhs)
    }
}

impl std::ops::Mul<Color> for f64 {
    type Output = Color;
    fn mul(self, rhs: Color) -> Color {
        Color::new(self * rhs.r, self * rhs.g, self * rhs.b)
    }
}
