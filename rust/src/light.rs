use crate::color::Color;
use crate::point::Point;
use crate::vector::Vector;

#[derive(Debug, Clone)]
pub struct PointLight {
    pub position: Point,
    pub intensity: Color,
}

#[derive(Debug, Clone)]
pub struct AreaLight {
    pub corner: Point,
    pub uvec: Vector,
    pub vvec: Vector,
    pub usteps: usize,
    pub vsteps: usize,
    pub intensity: Color,
}

#[derive(Debug, Clone)]
pub struct Spotlight {
    pub position: Point,
    pub direction: Vector,
    pub cone_angle: f64,
    pub fade_angle: f64,
    pub intensity: Color,
}

#[derive(Debug, Clone)]
pub enum Light {
    Point(PointLight),
    Area(AreaLight),
    Spot(Spotlight),
}

impl Light {
    pub fn point(position: Point, intensity: Color) -> Self {
        Light::Point(PointLight {
            position,
            intensity,
        })
    }

    pub fn area(
        corner: Point,
        full_uvec: Vector,
        usteps: usize,
        full_vvec: Vector,
        vsteps: usize,
        intensity: Color,
    ) -> Self {
        Light::Area(AreaLight {
            corner,
            uvec: full_uvec / usteps as f64,
            vvec: full_vvec / vsteps as f64,
            usteps,
            vsteps,
            intensity,
        })
    }

    pub fn spot(
        position: Point,
        direction: Vector,
        cone_angle: f64,
        fade_angle: f64,
        intensity: Color,
    ) -> Self {
        Light::Spot(Spotlight {
            position,
            direction,
            cone_angle,
            fade_angle,
            intensity,
        })
    }

    pub fn intensity_color(&self) -> Color {
        match self {
            Light::Point(l) => l.intensity,
            Light::Area(l) => l.intensity,
            Light::Spot(l) => l.intensity,
        }
    }
}
