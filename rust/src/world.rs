use crate::color::Color;
use crate::computations::{prepare_computations, schlick, Computations};
use crate::intersection::{hit, Intersection};
use crate::light::Light;
use crate::lighting::{area_light_intensity, lighting, spot_intensity};
use crate::point::Point;
use crate::ray::Ray;
use crate::shape::{intersect_shape, ShapeNode};

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
        let child_id = self.shapes.len();
        self.shapes.push(child);
        self.shapes[child_id].parent_id = Some(group_id);
        if let crate::shape::Geometry::Group { ref mut children } = self.shapes[group_id].geometry {
            children.push(child_id);
        }
        child_id
    }

    pub fn shape(&self, id: usize) -> &ShapeNode {
        &self.shapes[id]
    }
    pub fn shape_mut(&mut self, id: usize) -> &mut ShapeNode {
        &mut self.shapes[id]
    }

    pub fn intersect(&self, ray: &Ray) -> Vec<Intersection> {
        let mut xs: Vec<Intersection> = self
            .root_ids
            .iter()
            .flat_map(|&id| intersect_shape(&self.shapes, id, ray))
            .collect();
        xs.sort_by(|a, b| a.t.partial_cmp(&b.t).unwrap());
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
        let transform_inv = &self.shapes[comps.object_id].transform_inverse;

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
