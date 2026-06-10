use crate::color::Color;
use crate::pattern::Pattern;
use crate::point::Point;
use crate::vector::Vector;

pub struct Material {
    pub color: Color,
    pub ambient: f64,
    pub diffuse: f64,
    pub specular: f64,
    pub shininess: f64,
    pub reflective: f64,
    pub transparency: f64,
    pub refractive_index: f64,
    pub pattern: Option<Pattern>,
    pub normal_perturbation: Option<Box<dyn Fn(Point) -> Vector + Send + Sync>>,
}

impl Material {
    pub fn new() -> Self {
        Material {
            color: Color::WHITE,
            ambient: 0.1,
            diffuse: 0.9,
            specular: 0.9,
            shininess: 200.0,
            reflective: 0.0,
            transparency: 0.0,
            refractive_index: 1.0,
            pattern: None,
            normal_perturbation: None,
        }
    }

    pub fn glass() -> Self {
        let mut m = Material::new();
        m.transparency = 1.0;
        m.refractive_index = 1.5;
        m
    }
}

impl Default for Material {
    fn default() -> Self {
        Material::new()
    }
}

impl Clone for Material {
    fn clone(&self) -> Self {
        Material {
            color: self.color,
            ambient: self.ambient,
            diffuse: self.diffuse,
            specular: self.specular,
            shininess: self.shininess,
            reflective: self.reflective,
            transparency: self.transparency,
            refractive_index: self.refractive_index,
            pattern: self.pattern.clone(),
            normal_perturbation: None, // closures can't be cloned
        }
    }
}
