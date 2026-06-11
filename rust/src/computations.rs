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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::intersection::Intersection;
    use crate::point::Point;
    use crate::ray::Ray;
    use crate::shape::ShapeNode;
    use crate::transformations::{scaling, translation};
    use crate::vector::Vector;

    fn three_glass_spheres() -> Vec<ShapeNode> {
        let mut a = ShapeNode::glass_sphere();
        a.set_transform(scaling(2.0, 2.0, 2.0));
        a.material.refractive_index = 1.5;

        let mut b = ShapeNode::glass_sphere();
        b.set_transform(translation(0.0, 0.0, -0.25));
        b.material.refractive_index = 2.0;

        let mut c = ShapeNode::glass_sphere();
        c.set_transform(translation(0.0, 0.0, 0.25));
        c.material.refractive_index = 2.5;

        vec![a, b, c]
    }

    fn n1n2_xs() -> Vec<Intersection> {
        vec![
            Intersection::new(2.0, 0),
            Intersection::new(2.75, 1),
            Intersection::new(3.25, 2),
            Intersection::new(4.75, 1),
            Intersection::new(5.25, 2),
            Intersection::new(6.0, 0),
        ]
    }

    fn n1n2_ray() -> Ray {
        Ray::new(Point::new(0.0, 0.0, -4.0), Vector::new(0.0, 0.0, 1.0))
    }

    // ─── n1/n2 tests ─────────────────────────────────────────────────────────

    #[test]
    fn n1_n2_at_index_0() {
        let shapes = three_glass_spheres();
        let xs = n1n2_xs();
        let comps = prepare_computations(&shapes, &xs[0], &n1n2_ray(), &xs);
        assert!((comps.n1 - 1.0).abs() < 1e-5);
        assert!((comps.n2 - 1.5).abs() < 1e-5);
    }

    #[test]
    fn n1_n2_at_index_1() {
        let shapes = three_glass_spheres();
        let xs = n1n2_xs();
        let comps = prepare_computations(&shapes, &xs[1], &n1n2_ray(), &xs);
        assert!((comps.n1 - 1.5).abs() < 1e-5);
        assert!((comps.n2 - 2.0).abs() < 1e-5);
    }

    #[test]
    fn n1_n2_at_index_2() {
        let shapes = three_glass_spheres();
        let xs = n1n2_xs();
        let comps = prepare_computations(&shapes, &xs[2], &n1n2_ray(), &xs);
        assert!((comps.n1 - 2.0).abs() < 1e-5);
        assert!((comps.n2 - 2.5).abs() < 1e-5);
    }

    #[test]
    fn n1_n2_at_index_3() {
        let shapes = three_glass_spheres();
        let xs = n1n2_xs();
        let comps = prepare_computations(&shapes, &xs[3], &n1n2_ray(), &xs);
        assert!((comps.n1 - 2.5).abs() < 1e-5);
        assert!((comps.n2 - 2.5).abs() < 1e-5);
    }

    #[test]
    fn n1_n2_at_index_4() {
        let shapes = three_glass_spheres();
        let xs = n1n2_xs();
        let comps = prepare_computations(&shapes, &xs[4], &n1n2_ray(), &xs);
        assert!((comps.n1 - 2.5).abs() < 1e-5);
        assert!((comps.n2 - 1.5).abs() < 1e-5);
    }

    #[test]
    fn n1_n2_at_index_5() {
        let shapes = three_glass_spheres();
        let xs = n1n2_xs();
        let comps = prepare_computations(&shapes, &xs[5], &n1n2_ray(), &xs);
        assert!((comps.n1 - 1.5).abs() < 1e-5);
        assert!((comps.n2 - 1.0).abs() < 1e-5);
    }

    // ─── Schlick tests ────────────────────────────────────────────────────────

    #[test]
    fn schlick_total_internal_reflection() {
        let shapes = vec![ShapeNode::glass_sphere()];
        let sqrt2_over_2 = 2.0_f64.sqrt() / 2.0;
        let r = Ray::new(
            Point::new(0.0, 0.0, sqrt2_over_2),
            Vector::new(0.0, 1.0, 0.0),
        );
        let xs = vec![
            Intersection::new(-sqrt2_over_2, 0),
            Intersection::new(sqrt2_over_2, 0),
        ];
        let comps = prepare_computations(&shapes, &xs[1], &r, &xs);
        assert!((schlick(&comps) - 1.0).abs() < 1e-5);
    }

    #[test]
    fn schlick_perpendicular_viewing_angle() {
        let shapes = vec![ShapeNode::glass_sphere()];
        let r = Ray::new(Point::new(0.0, 0.0, 0.0), Vector::new(0.0, 1.0, 0.0));
        let xs = vec![Intersection::new(-1.0, 0), Intersection::new(1.0, 0)];
        let comps = prepare_computations(&shapes, &xs[1], &r, &xs);
        assert!((schlick(&comps) - 0.04).abs() < 1e-5);
    }

    #[test]
    fn schlick_small_angle_n2_greater_than_n1() {
        let shapes = vec![ShapeNode::glass_sphere()];
        let r = Ray::new(Point::new(0.0, 0.99, -2.0), Vector::new(0.0, 0.0, 1.0));
        let xs = vec![Intersection::new(1.8589, 0)];
        let comps = prepare_computations(&shapes, &xs[0], &r, &xs);
        assert!((schlick(&comps) - 0.48873).abs() < 1e-4);
    }
}
