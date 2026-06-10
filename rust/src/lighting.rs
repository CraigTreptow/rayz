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
