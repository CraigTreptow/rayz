use crate::intersection::Intersection;
use crate::point::Point;
use crate::ray::Ray;
use crate::shape::{normal_at, ShapeNode};
use crate::util::EPSILON;
use crate::vector::Vector;

pub struct Computations {
    pub t: f64,
    pub object_id: usize,
    pub point: Point,
    pub over_point: Point,
    pub under_point: Point,
    pub eyev: Vector,
    pub normalv: Vector,
    pub reflectv: Vector,
    pub inside: bool,
    pub n1: f64,
    pub n2: f64,
}

pub fn prepare_computations(
    shapes: &[ShapeNode],
    hit: &Intersection,
    ray: &Ray,
    xs: &[Intersection],
) -> Computations {
    let point = ray.position(hit.t);
    let eyev = -ray.direction;
    let mut normalv = normal_at(shapes, hit.object_id, point, hit);

    let inside = if normalv.dot(eyev) < 0.0 {
        normalv = -normalv;
        true
    } else {
        false
    };

    let over_point = point + normalv * EPSILON;
    let under_point = point - normalv * EPSILON;
    let reflectv = ray.direction.reflect(normalv);

    // Compute n1 and n2 for refraction (track which transparent objects the ray is inside)
    let mut n1 = 1.0_f64;
    let mut n2 = 1.0_f64;
    let mut containers: Vec<usize> = Vec::new();

    for i in xs {
        if i.t == hit.t && i.object_id == hit.object_id {
            n1 = if containers.is_empty() {
                1.0
            } else {
                shapes[*containers.last().unwrap()]
                    .material
                    .refractive_index
            };
        }

        if let Some(pos) = containers.iter().position(|&id| id == i.object_id) {
            containers.remove(pos);
        } else {
            containers.push(i.object_id);
        }

        if i.t == hit.t && i.object_id == hit.object_id {
            n2 = if containers.is_empty() {
                1.0
            } else {
                shapes[*containers.last().unwrap()]
                    .material
                    .refractive_index
            };
            break;
        }
    }

    Computations {
        t: hit.t,
        object_id: hit.object_id,
        point,
        over_point,
        under_point,
        eyev,
        normalv,
        reflectv,
        inside,
        n1,
        n2,
    }
}

pub fn schlick(comps: &Computations) -> f64 {
    let mut cos = comps.eyev.dot(comps.normalv);

    if comps.n1 > comps.n2 {
        let n = comps.n1 / comps.n2;
        let sin2_t = n * n * (1.0 - cos * cos);
        if sin2_t > 1.0 {
            return 1.0;
        }
        let cos_t = (1.0 - sin2_t).sqrt();
        cos = cos_t;
    }

    let r0 = ((comps.n1 - comps.n2) / (comps.n1 + comps.n2)).powi(2);
    r0 + (1.0 - r0) * (1.0 - cos).powi(5)
}
