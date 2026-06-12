use crate::color::Color;
use crate::light::{AreaLight, Light, Spotlight};
use crate::material::Material;
use crate::matrix::Matrix4;
use crate::point::Point;
use crate::vector::Vector;

pub fn lighting(
    material: &Material,
    shape_transform_inverse: &Matrix4,
    light: &Light,
    point: Point,
    eyev: Vector,
    normalv: Vector,
    intensity: f64,
) -> Color {
    let base_color = if let Some(ref pat) = material.pattern {
        pat.pattern_at_shape(shape_transform_inverse, point)
    } else {
        material.color
    };

    let effective_color = base_color * light.intensity_color();
    let ambient = effective_color * material.ambient;

    if intensity == 0.0 {
        return ambient;
    }

    let lightv = match light {
        Light::Point(l) => (l.position - point).normalize(),
        Light::Area(l) => {
            let center =
                l.corner + l.uvec * (l.usteps as f64 / 2.0) + l.vvec * (l.vsteps as f64 / 2.0);
            (center - point).normalize()
        }
        Light::Spot(l) => (l.position - point).normalize(),
    };

    let light_dot_normal = lightv.dot(normalv);

    if light_dot_normal < 0.0 {
        return ambient;
    }

    let diffuse = effective_color * material.diffuse * light_dot_normal * intensity;
    let reflectv = (-lightv).reflect(normalv);
    let reflect_dot_eye = reflectv.dot(eyev);

    if reflect_dot_eye <= 0.0 {
        return ambient + diffuse;
    }

    let factor = reflect_dot_eye.powf(material.shininess);
    let specular = light.intensity_color() * material.specular * factor * intensity;

    ambient + diffuse + specular
}

/// Compute soft-shadow intensity for area lights (0.0 fully shadowed, 1.0 fully lit).
pub fn area_light_intensity(
    light: &AreaLight,
    point: Point,
    is_shadowed: impl Fn(Point, Point) -> bool,
) -> f64 {
    let mut total = 0.0;
    for v in 0..light.vsteps {
        for u in 0..light.usteps {
            let light_pos =
                light.corner + light.uvec * (u as f64 + 0.5) + light.vvec * (v as f64 + 0.5);
            if !is_shadowed(point, light_pos) {
                total += 1.0;
            }
        }
    }
    total / (light.usteps * light.vsteps) as f64
}

/// Compute spotlight intensity falloff.
pub fn spot_intensity(light: &Spotlight, point: Point) -> f64 {
    let to_light = (light.position - point).normalize();
    let dot = to_light.dot(-light.direction);
    let angle = dot.acos();
    if angle > light.cone_angle {
        0.0
    } else if angle > light.fade_angle {
        1.0 - (angle - light.fade_angle) / (light.cone_angle - light.fade_angle)
    } else {
        1.0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn surface_point() -> Point {
        Point::new(0.0, 0.0, 0.0)
    }

    fn surface_normal() -> Vector {
        Vector::new(0.0, 0.0, -1.0)
    }

    #[test]
    fn lighting_eye_between_light_and_surface() {
        // eye=(0,0,-1), light at (0,0,-10): ambient + diffuse + specular all full → 1.9
        let m = Material::new();
        let inv = Matrix4::identity();
        let eye = Vector::new(0.0, 0.0, -1.0);
        let light = Light::point(Point::new(0.0, 0.0, -10.0), Color::WHITE);
        let result = lighting(
            &m,
            &inv,
            &light,
            surface_point(),
            eye,
            surface_normal(),
            1.0,
        );
        assert!((result.r - 1.9).abs() < 1e-4);
        assert!((result.g - 1.9).abs() < 1e-4);
        assert!((result.b - 1.9).abs() < 1e-4);
    }

    #[test]
    fn lighting_eye_offset_45_degrees() {
        // eye=(0, √2/2, -√2/2): reflect faces away from eye → no specular → 1.0
        let m = Material::new();
        let inv = Matrix4::identity();
        let sq2 = std::f64::consts::SQRT_2 / 2.0;
        let eye = Vector::new(0.0, sq2, -sq2);
        let light = Light::point(Point::new(0.0, 0.0, -10.0), Color::WHITE);
        let result = lighting(
            &m,
            &inv,
            &light,
            surface_point(),
            eye,
            surface_normal(),
            1.0,
        );
        assert!((result.r - 1.0).abs() < 1e-4);
        assert!((result.g - 1.0).abs() < 1e-4);
        assert!((result.b - 1.0).abs() < 1e-4);
    }

    #[test]
    fn lighting_light_offset_45_degrees() {
        // light at (0,10,-10): diffuse = 0.9 * cos45 ≈ 0.6364, specular ≈ 0 → 0.7364
        let m = Material::new();
        let inv = Matrix4::identity();
        let eye = Vector::new(0.0, 0.0, -1.0);
        let light = Light::point(Point::new(0.0, 10.0, -10.0), Color::WHITE);
        let result = lighting(
            &m,
            &inv,
            &light,
            surface_point(),
            eye,
            surface_normal(),
            1.0,
        );
        assert!((result.r - 0.7364).abs() < 1e-4);
        assert!((result.g - 0.7364).abs() < 1e-4);
        assert!((result.b - 0.7364).abs() < 1e-4);
    }

    #[test]
    fn lighting_light_behind_surface() {
        // light at (0,0,10): light_dot_normal < 0 → ambient only → 0.1
        let m = Material::new();
        let inv = Matrix4::identity();
        let eye = Vector::new(0.0, 0.0, -1.0);
        let light = Light::point(Point::new(0.0, 0.0, 10.0), Color::WHITE);
        let result = lighting(
            &m,
            &inv,
            &light,
            surface_point(),
            eye,
            surface_normal(),
            1.0,
        );
        assert!((result.r - 0.1).abs() < 1e-4);
        assert!((result.g - 0.1).abs() < 1e-4);
        assert!((result.b - 0.1).abs() < 1e-4);
    }

    #[test]
    fn lighting_surface_in_shadow() {
        // intensity=0.0: shadow path → ambient only → 0.1
        let m = Material::new();
        let inv = Matrix4::identity();
        let eye = Vector::new(0.0, 0.0, -1.0);
        let light = Light::point(Point::new(0.0, 0.0, -10.0), Color::WHITE);
        let result = lighting(
            &m,
            &inv,
            &light,
            surface_point(),
            eye,
            surface_normal(),
            0.0,
        );
        assert!((result.r - 0.1).abs() < 1e-4);
        assert!((result.g - 0.1).abs() < 1e-4);
        assert!((result.b - 0.1).abs() < 1e-4);
    }
}
