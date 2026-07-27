use crate::color::Color;
use crate::computations::{prepare_computations, schlick, Computations};
use crate::intersection::{hit, Intersection};
use crate::light::Light;
use crate::lighting::{area_light_intensity, lighting, spot_intensity};
use crate::matrix::Matrix4;
use crate::point::Point;
use crate::ray::Ray;
use crate::shape::{intersect_shape, invalidate_bounds_cache, precompute_bounds, ShapeNode};

pub struct World {
    pub shapes: Vec<ShapeNode>,
    pub root_ids: Vec<usize>,
    pub light: Option<Light>,
}

impl World {
    pub fn new() -> Self {
        World {
            shapes: Vec::new(),
            root_ids: Vec::new(),
            light: None,
        }
    }

    /// Add a shape as a top-level object and return its id.
    pub fn add(&mut self, shape: ShapeNode) -> usize {
        let id = self.shapes.len();
        self.shapes.push(shape);
        self.root_ids.push(id);
        id
    }

    /// Add a shape to the arena without registering it as a root (e.g. CSG children).
    pub fn add_shape(&mut self, shape: ShapeNode) -> usize {
        let id = self.shapes.len();
        self.shapes.push(shape);
        id
    }

    /// Add a shape owned by a group (not a top-level root).
    pub fn add_child(&mut self, group_id: usize, child: ShapeNode) -> usize {
        assert!(
            matches!(
                self.shapes[group_id].geometry,
                crate::shape::Geometry::Group { .. }
            ),
            "add_child: parent shape {group_id} is not a Group"
        );
        let child_id = self.shapes.len();
        self.shapes.push(child);
        self.shapes[child_id].parent_id = Some(group_id);
        if let crate::shape::Geometry::Group { ref mut children } = self.shapes[group_id].geometry {
            children.push(child_id);
        }
        invalidate_bounds_cache(&mut self.shapes, group_id);
        child_id
    }

    pub fn shape(&self, id: usize) -> &ShapeNode {
        &self.shapes[id]
    }
    pub fn shape_mut(&mut self, id: usize) -> &mut ShapeNode {
        &mut self.shapes[id]
    }

    /// Sets a shape's transform and invalidates any cached Group/CSG
    /// bounds up its ancestor chain. Use this (rather than
    /// `shape_mut(id).set_transform(...)`) for shapes that may already be
    /// attached to the graph -- e.g. re-transforming a shape after it's
    /// been added to a group. Shapes are free to call `set_transform`
    /// directly while still being built, before being added to the
    /// world, since they have no `parent_id` yet for invalidation to
    /// reach.
    pub fn set_shape_transform(&mut self, id: usize, transform: Matrix4) {
        self.shapes[id].set_transform(transform);
        invalidate_bounds_cache(&mut self.shapes, id);
    }

    /// Precomputes and caches merged Group/CSG bounds for the whole scene
    /// so `intersect`/`intersect_shape` doesn't re-walk the subtree on
    /// every ray. Call once after finishing scene construction and
    /// before rendering; safe to skip (correctness doesn't depend on it)
    /// or call again if the scene changes and is rendered again.
    pub fn precompute_bounds(&mut self) {
        precompute_bounds(&mut self.shapes);
    }

    pub fn intersect(&self, ray: &Ray) -> Vec<Intersection> {
        let mut xs: Vec<Intersection> = self
            .root_ids
            .iter()
            .flat_map(|&id| intersect_shape(&self.shapes, id, ray))
            .collect();
        xs.sort_by(|a, b| a.t.total_cmp(&b.t));
        xs
    }

    pub fn is_shadowed_from(&self, point: Point, light_pos: Point) -> bool {
        let v = light_pos - point;
        let distance = v.magnitude();
        let direction = v.normalize();
        let r = Ray::new(point, direction);
        for &id in &self.root_ids {
            for i in intersect_shape(&self.shapes, id, &r) {
                if i.t > 0.0 && i.t < distance {
                    return true;
                }
            }
        }
        false
    }

    fn shadow_intensity(&self, point: Point) -> f64 {
        match &self.light {
            Some(Light::Point(l)) => {
                if self.is_shadowed_from(point, l.position) {
                    0.0
                } else {
                    1.0
                }
            }
            Some(Light::Area(l)) => {
                let l = l.clone();
                area_light_intensity(&l, point, |p, lp| self.is_shadowed_from(p, lp))
            }
            Some(Light::Spot(l)) => spot_intensity(l, point),
            None => 1.0,
        }
    }

    pub fn reflected_color(&self, comps: &Computations, remaining: u8) -> Color {
        if remaining == 0 || self.shapes[comps.object_id].material.reflective == 0.0 {
            return Color::BLACK;
        }
        let reflect_ray = Ray::new(comps.over_point, comps.reflectv);
        self.color_at(&reflect_ray, remaining - 1)
            * self.shapes[comps.object_id].material.reflective
    }

    pub fn refracted_color(&self, comps: &Computations, remaining: u8) -> Color {
        if remaining == 0 || self.shapes[comps.object_id].material.transparency == 0.0 {
            return Color::BLACK;
        }
        let n_ratio = comps.n1 / comps.n2;
        let cos_i = comps.eyev.dot(comps.normalv);
        let sin2_t = n_ratio * n_ratio * (1.0 - cos_i * cos_i);
        if sin2_t > 1.0 {
            return Color::BLACK;
        }
        let cos_t = (1.0 - sin2_t).sqrt();
        let direction = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio;
        let refract_ray = Ray::new(comps.under_point, direction);
        self.color_at(&refract_ray, remaining - 1)
            * self.shapes[comps.object_id].material.transparency
    }

    pub fn shade_hit(&self, comps: &Computations, remaining: u8) -> Color {
        let intensity = self.shadow_intensity(comps.over_point);
        let material = &self.shapes[comps.object_id].material;
        let transform_inv = self.shapes[comps.object_id].transform_inverse();

        let surface = if let Some(light) = &self.light {
            lighting(
                material,
                transform_inv,
                light,
                comps.point,
                comps.eyev,
                comps.normalv,
                intensity,
            )
        } else {
            material.color * material.ambient
        };

        let reflected = self.reflected_color(comps, remaining);
        let refracted = self.refracted_color(comps, remaining);

        let mat = &self.shapes[comps.object_id].material;
        if mat.reflective > 0.0 && mat.transparency > 0.0 {
            let reflectance = schlick(comps);
            surface + reflected * reflectance + refracted * (1.0 - reflectance)
        } else {
            surface + reflected + refracted
        }
    }

    pub fn color_at(&self, ray: &Ray, remaining: u8) -> Color {
        let xs = self.intersect(ray);
        match hit(&xs) {
            None => Color::BLACK,
            Some(i) => {
                let comps = prepare_computations(&self.shapes, i, ray, &xs);
                self.shade_hit(&comps, remaining)
            }
        }
    }
}

impl Default for World {
    fn default() -> Self {
        World::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::color::Color;
    use crate::computations::Computations;
    use crate::light::Light;
    use crate::point::Point;
    use crate::shape::ShapeNode;
    use crate::vector::Vector;

    fn world_with_sphere() -> World {
        let mut w = World::new();
        w.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));
        w.add(ShapeNode::sphere());
        w
    }

    // ── is_shadowed_from ──────────────────────────────────────────────────────

    #[test]
    fn no_shadow_when_nothing_collinear_with_point_and_light() {
        let w = world_with_sphere();
        assert!(!w.is_shadowed_from(Point::new(0.0, 10.0, 0.0), Point::new(-10.0, 10.0, -10.0)));
    }

    #[test]
    fn shadow_when_object_between_point_and_light() {
        let w = world_with_sphere();
        assert!(w.is_shadowed_from(
            Point::new(10.0, -10.0, 10.0),
            Point::new(-10.0, 10.0, -10.0)
        ));
    }

    #[test]
    fn no_shadow_when_object_is_behind_light() {
        let w = world_with_sphere();
        assert!(!w.is_shadowed_from(
            Point::new(-20.0, 20.0, -20.0),
            Point::new(-10.0, 10.0, -10.0)
        ));
    }

    #[test]
    fn no_shadow_when_object_is_behind_point() {
        let w = world_with_sphere();
        assert!(!w.is_shadowed_from(Point::new(-2.0, 2.0, -2.0), Point::new(-10.0, 10.0, -10.0)));
    }

    // ── reflected_color ───────────────────────────────────────────────────────

    #[test]
    fn reflected_color_at_max_depth_is_black() {
        let mut w = World::new();
        let mut plane = ShapeNode::plane();
        plane.material.reflective = 0.5;
        let plane_id = w.add(plane);

        let sq2 = std::f64::consts::SQRT_2 / 2.0;
        let comps = Computations {
            t: sq2,
            object_id: plane_id,
            point: Point::new(0.0, -1.0, 0.0),
            over_point: Point::new(0.0, -1.0 + 1e-5, 0.0),
            under_point: Point::new(0.0, -1.0 - 1e-5, 0.0),
            eyev: Vector::new(0.0, sq2, -sq2),
            normalv: Vector::new(0.0, 1.0, 0.0),
            reflectv: Vector::new(0.0, sq2, sq2),
            inside: false,
            n1: 1.0,
            n2: 1.0,
        };

        assert_eq!(w.reflected_color(&comps, 0), Color::BLACK);
    }
}
