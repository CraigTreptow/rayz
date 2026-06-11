use crate::bounds::Bounds;
use crate::intersection::Intersection;
use crate::material::Material;
use crate::matrix::Matrix4;
use crate::point::Point;
use crate::ray::Ray;
use crate::torus::solve_quartic;
use crate::util::EPSILON;
use crate::vector::Vector;

// ─── Geometry enum ────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub enum Geometry {
    Sphere,
    Plane,
    Cube,
    Cylinder {
        minimum: f64,
        maximum: f64,
        closed: bool,
    },
    Cone {
        minimum: f64,
        maximum: f64,
        closed: bool,
    },
    Triangle {
        p1: Point,
        p2: Point,
        p3: Point,
        e1: Vector,
        e2: Vector,
        normal: Vector,
    },
    SmoothTriangle {
        p1: Point,
        p2: Point,
        p3: Point,
        e1: Vector,
        e2: Vector,
        n1: Vector,
        n2: Vector,
        n3: Vector,
    },
    Torus {
        major_radius: f64,
        minor_radius: f64,
    },
    Group {
        children: Vec<usize>,
    },
    Csg {
        operation: CsgOperation,
        left: usize,
        right: usize,
    },
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum CsgOperation {
    Union,
    Intersection,
    Difference,
}

// ─── ShapeNode ────────────────────────────────────────────────────────────────

pub struct ShapeNode {
    pub geometry: Geometry,
    transform: Matrix4,
    transform_inverse: Matrix4,
    transform_inverse_transpose: Matrix4,
    pub material: Material,
    pub parent_id: Option<usize>,
    pub motion_transform: Option<Box<dyn Fn(f64) -> Matrix4 + Send + Sync>>,
}

impl ShapeNode {
    fn with_geometry(geometry: Geometry) -> Self {
        ShapeNode {
            geometry,
            transform: Matrix4::identity(),
            transform_inverse: Matrix4::identity(),
            transform_inverse_transpose: Matrix4::identity(),
            material: Material::new(),
            parent_id: None,
            motion_transform: None,
        }
    }

    pub fn sphere() -> Self {
        Self::with_geometry(Geometry::Sphere)
    }
    pub fn plane() -> Self {
        Self::with_geometry(Geometry::Plane)
    }
    pub fn cube() -> Self {
        Self::with_geometry(Geometry::Cube)
    }

    pub fn cylinder() -> Self {
        Self::with_geometry(Geometry::Cylinder {
            minimum: f64::NEG_INFINITY,
            maximum: f64::INFINITY,
            closed: false,
        })
    }

    pub fn cylinder_truncated(min: f64, max: f64) -> Self {
        Self::with_geometry(Geometry::Cylinder {
            minimum: min,
            maximum: max,
            closed: false,
        })
    }

    pub fn cylinder_closed(min: f64, max: f64) -> Self {
        Self::with_geometry(Geometry::Cylinder {
            minimum: min,
            maximum: max,
            closed: true,
        })
    }

    pub fn cone() -> Self {
        Self::with_geometry(Geometry::Cone {
            minimum: f64::NEG_INFINITY,
            maximum: f64::INFINITY,
            closed: false,
        })
    }

    pub fn cone_truncated(min: f64, max: f64) -> Self {
        Self::with_geometry(Geometry::Cone {
            minimum: min,
            maximum: max,
            closed: false,
        })
    }

    pub fn cone_closed(min: f64, max: f64) -> Self {
        Self::with_geometry(Geometry::Cone {
            minimum: min,
            maximum: max,
            closed: true,
        })
    }

    pub fn csg_union(left: usize, right: usize) -> Self {
        Self::csg(CsgOperation::Union, left, right)
    }

    pub fn csg_intersection(left: usize, right: usize) -> Self {
        Self::csg(CsgOperation::Intersection, left, right)
    }

    pub fn csg_difference(left: usize, right: usize) -> Self {
        Self::csg(CsgOperation::Difference, left, right)
    }

    pub fn triangle(p1: Point, p2: Point, p3: Point) -> Self {
        let e1 = p2 - p1;
        let e2 = p3 - p1;
        let normal = e2.cross(e1).normalize();
        Self::with_geometry(Geometry::Triangle {
            p1,
            p2,
            p3,
            e1,
            e2,
            normal,
        })
    }

    pub fn smooth_triangle(
        p1: Point,
        p2: Point,
        p3: Point,
        n1: Vector,
        n2: Vector,
        n3: Vector,
    ) -> Self {
        let e1 = p2 - p1;
        let e2 = p3 - p1;
        Self::with_geometry(Geometry::SmoothTriangle {
            p1,
            p2,
            p3,
            e1,
            e2,
            n1,
            n2,
            n3,
        })
    }

    pub fn group() -> Self {
        Self::with_geometry(Geometry::Group {
            children: Vec::new(),
        })
    }

    pub fn csg(operation: CsgOperation, left: usize, right: usize) -> Self {
        Self::with_geometry(Geometry::Csg {
            operation,
            left,
            right,
        })
    }

    pub fn torus(major_radius: f64, minor_radius: f64) -> Self {
        Self::with_geometry(Geometry::Torus {
            major_radius,
            minor_radius,
        })
    }

    pub fn glass_sphere() -> Self {
        let mut s = ShapeNode::sphere();
        s.material = Material::glass();
        s
    }

    pub fn set_transform(&mut self, t: Matrix4) {
        let inv = t.inverse();
        let inv_t = inv.transpose();
        self.transform = t;
        self.transform_inverse = inv;
        self.transform_inverse_transpose = inv_t;
    }

    pub fn transform(&self) -> &Matrix4 {
        &self.transform
    }

    pub fn transform_inverse(&self) -> &Matrix4 {
        &self.transform_inverse
    }

    pub fn transform_inverse_transpose(&self) -> &Matrix4 {
        &self.transform_inverse_transpose
    }

    pub fn local_bounds(&self) -> Bounds {
        local_bounds_for(&self.geometry)
    }
}

// ─── Local geometry functions ─────────────────────────────────────────────────

fn local_bounds_for(geom: &Geometry) -> Bounds {
    match geom {
        Geometry::Sphere => Bounds::unit(),
        Geometry::Plane => Bounds::new(
            Point::new(f64::NEG_INFINITY, 0.0, f64::NEG_INFINITY),
            Point::new(f64::INFINITY, 0.0, f64::INFINITY),
        ),
        Geometry::Cube => Bounds::unit(),
        Geometry::Cylinder {
            minimum, maximum, ..
        } => Bounds::new(
            Point::new(-1.0, *minimum, -1.0),
            Point::new(1.0, *maximum, 1.0),
        ),
        Geometry::Cone {
            minimum, maximum, ..
        } => {
            let limit = minimum.abs().max(maximum.abs());
            Bounds::new(
                Point::new(-limit, *minimum, -limit),
                Point::new(limit, *maximum, limit),
            )
        }
        Geometry::Triangle { p1, p2, p3, .. } | Geometry::SmoothTriangle { p1, p2, p3, .. } => {
            Bounds::empty().add_point(*p1).add_point(*p2).add_point(*p3)
        }
        Geometry::Torus {
            major_radius,
            minor_radius,
        } => {
            let e = major_radius + minor_radius;
            Bounds::new(
                Point::new(-e, -*minor_radius, -e),
                Point::new(e, *minor_radius, e),
            )
        }
        Geometry::Group { .. } | Geometry::Csg { .. } => Bounds::empty(),
    }
}

fn local_intersect_sphere(ray: &Ray, id: usize) -> Vec<Intersection> {
    let sphere_to_ray = ray.origin - Point::origin();
    let a = ray.direction.dot(ray.direction);
    let b = 2.0 * ray.direction.dot(sphere_to_ray);
    let c = sphere_to_ray.dot(sphere_to_ray) - 1.0;
    let disc = b * b - 4.0 * a * c;
    if disc < 0.0 {
        return vec![];
    }
    let sqrt_d = disc.sqrt();
    vec![
        Intersection::new((-b - sqrt_d) / (2.0 * a), id),
        Intersection::new((-b + sqrt_d) / (2.0 * a), id),
    ]
}

fn local_intersect_plane(ray: &Ray, id: usize) -> Vec<Intersection> {
    if ray.direction.y.abs() < EPSILON {
        return vec![];
    }
    vec![Intersection::new(-ray.origin.y / ray.direction.y, id)]
}

fn local_intersect_cube(ray: &Ray, id: usize) -> Vec<Intersection> {
    let (xtmin, xtmax) = check_axis(ray.origin.x, ray.direction.x);
    let (ytmin, ytmax) = check_axis(ray.origin.y, ray.direction.y);
    let (ztmin, ztmax) = check_axis(ray.origin.z, ray.direction.z);
    let tmin = xtmin.max(ytmin).max(ztmin);
    let tmax = xtmax.min(ytmax).min(ztmax);
    if tmin > tmax {
        return vec![];
    }
    vec![Intersection::new(tmin, id), Intersection::new(tmax, id)]
}

fn check_axis(origin: f64, direction: f64) -> (f64, f64) {
    let tmin = (-1.0 - origin) / direction;
    let tmax = (1.0 - origin) / direction;
    if tmin > tmax {
        (tmax, tmin)
    } else {
        (tmin, tmax)
    }
}

fn local_intersect_cylinder(
    ray: &Ray,
    id: usize,
    minimum: f64,
    maximum: f64,
    closed: bool,
) -> Vec<Intersection> {
    let a = ray.direction.x * ray.direction.x + ray.direction.z * ray.direction.z;
    let mut xs = Vec::new();

    if a.abs() >= EPSILON {
        let b = 2.0 * ray.origin.x * ray.direction.x + 2.0 * ray.origin.z * ray.direction.z;
        let c = ray.origin.x * ray.origin.x + ray.origin.z * ray.origin.z - 1.0;
        let disc = b * b - 4.0 * a * c;
        if disc < 0.0 {
            return vec![];
        }
        let sqrt_d = disc.sqrt();
        let (mut t0, mut t1) = ((-b - sqrt_d) / (2.0 * a), (-b + sqrt_d) / (2.0 * a));
        if t0 > t1 {
            std::mem::swap(&mut t0, &mut t1);
        }
        let y0 = ray.origin.y + t0 * ray.direction.y;
        if minimum < y0 && y0 < maximum {
            xs.push(Intersection::new(t0, id));
        }
        let y1 = ray.origin.y + t1 * ray.direction.y;
        if minimum < y1 && y1 < maximum {
            xs.push(Intersection::new(t1, id));
        }
    }
    intersect_caps_cylinder(ray, id, minimum, maximum, closed, &mut xs);
    xs
}

fn cap_hit(ray: &Ray, t: f64) -> bool {
    let x = ray.origin.x + t * ray.direction.x;
    let z = ray.origin.z + t * ray.direction.z;
    x * x + z * z <= 1.0
}

fn intersect_caps_cylinder(
    ray: &Ray,
    id: usize,
    minimum: f64,
    maximum: f64,
    closed: bool,
    xs: &mut Vec<Intersection>,
) {
    if !closed || ray.direction.y.abs() < EPSILON {
        return;
    }
    let t = (minimum - ray.origin.y) / ray.direction.y;
    if cap_hit(ray, t) {
        xs.push(Intersection::new(t, id));
    }
    let t = (maximum - ray.origin.y) / ray.direction.y;
    if cap_hit(ray, t) {
        xs.push(Intersection::new(t, id));
    }
}

fn local_intersect_cone(
    ray: &Ray,
    id: usize,
    minimum: f64,
    maximum: f64,
    closed: bool,
) -> Vec<Intersection> {
    let a = ray.direction.x * ray.direction.x - ray.direction.y * ray.direction.y
        + ray.direction.z * ray.direction.z;
    let b = 2.0 * ray.origin.x * ray.direction.x - 2.0 * ray.origin.y * ray.direction.y
        + 2.0 * ray.origin.z * ray.direction.z;
    let c = ray.origin.x * ray.origin.x - ray.origin.y * ray.origin.y + ray.origin.z * ray.origin.z;
    let mut xs = Vec::new();

    if a.abs() < EPSILON {
        if b.abs() < EPSILON {
            return vec![];
        }
        xs.push(Intersection::new(-c / (2.0 * b), id));
    } else {
        let disc = b * b - 4.0 * a * c;
        if disc < 0.0 {
            return vec![];
        }
        let sqrt_d = disc.sqrt();
        let (mut t0, mut t1) = ((-b - sqrt_d) / (2.0 * a), (-b + sqrt_d) / (2.0 * a));
        if t0 > t1 {
            std::mem::swap(&mut t0, &mut t1);
        }
        let y0 = ray.origin.y + t0 * ray.direction.y;
        if minimum < y0 && y0 < maximum {
            xs.push(Intersection::new(t0, id));
        }
        let y1 = ray.origin.y + t1 * ray.direction.y;
        if minimum < y1 && y1 < maximum {
            xs.push(Intersection::new(t1, id));
        }
    }
    intersect_caps_cone(ray, id, minimum, maximum, closed, &mut xs);
    xs
}

fn cone_cap_hit(ray: &Ray, t: f64, y: f64) -> bool {
    let x = ray.origin.x + t * ray.direction.x;
    let z = ray.origin.z + t * ray.direction.z;
    x * x + z * z <= y * y
}

fn intersect_caps_cone(
    ray: &Ray,
    id: usize,
    minimum: f64,
    maximum: f64,
    closed: bool,
    xs: &mut Vec<Intersection>,
) {
    if !closed || ray.direction.y.abs() < EPSILON {
        return;
    }
    let t = (minimum - ray.origin.y) / ray.direction.y;
    if cone_cap_hit(ray, t, minimum) {
        xs.push(Intersection::new(t, id));
    }
    let t = (maximum - ray.origin.y) / ray.direction.y;
    if cone_cap_hit(ray, t, maximum) {
        xs.push(Intersection::new(t, id));
    }
}

fn local_intersect_triangle(
    ray: &Ray,
    id: usize,
    p1: Point,
    e1: Vector,
    e2: Vector,
    _normal: Vector,
) -> Vec<Intersection> {
    let dir_cross_e2 = ray.direction.cross(e2);
    let det = e1.dot(dir_cross_e2);
    if det.abs() < EPSILON {
        return vec![];
    }
    let f = 1.0 / det;
    let p1_to_origin = ray.origin - p1;
    let u = f * p1_to_origin.dot(dir_cross_e2);
    if !(0.0..=1.0).contains(&u) {
        return vec![];
    }
    let origin_cross_e1 = p1_to_origin.cross(e1);
    let v = f * ray.direction.dot(origin_cross_e1);
    if v < 0.0 || (u + v) > 1.0 {
        return vec![];
    }
    let t = f * e2.dot(origin_cross_e1);
    vec![Intersection::new(t, id)]
}

fn local_intersect_smooth_triangle(
    ray: &Ray,
    id: usize,
    p1: Point,
    e1: Vector,
    e2: Vector,
) -> Vec<Intersection> {
    let dir_cross_e2 = ray.direction.cross(e2);
    let det = e1.dot(dir_cross_e2);
    if det.abs() < EPSILON {
        return vec![];
    }
    let f = 1.0 / det;
    let p1_to_origin = ray.origin - p1;
    let u = f * p1_to_origin.dot(dir_cross_e2);
    if !(0.0..=1.0).contains(&u) {
        return vec![];
    }
    let origin_cross_e1 = p1_to_origin.cross(e1);
    let v = f * ray.direction.dot(origin_cross_e1);
    if v < 0.0 || (u + v) > 1.0 {
        return vec![];
    }
    let t = f * e2.dot(origin_cross_e1);
    vec![Intersection::with_uv(t, id, u, v)]
}

fn local_intersect_torus(
    ray: &Ray,
    id: usize,
    major_radius: f64,
    minor_radius: f64,
) -> Vec<Intersection> {
    let ox = ray.origin.x;
    let oy = ray.origin.y;
    let oz = ray.origin.z;
    let dx = ray.direction.x;
    let dy = ray.direction.y;
    let dz = ray.direction.z;

    let sum_d_sqr = dx * dx + dy * dy + dz * dz;
    let e = ox * ox + oy * oy + oz * oz - major_radius * major_radius - minor_radius * minor_radius;
    let f = ox * dx + oy * dy + oz * dz;
    let four_a_sqr = 4.0 * major_radius * major_radius;

    let a = sum_d_sqr * sum_d_sqr;
    let b = 4.0 * sum_d_sqr * f;
    let c = 2.0 * sum_d_sqr * e + 4.0 * f * f + four_a_sqr * dz * dz;
    let d = 4.0 * f * e + 2.0 * four_a_sqr * oz * dz;
    let e_coef = e * e - four_a_sqr * (minor_radius * minor_radius - oz * oz);

    solve_quartic(a, b, c, d, e_coef)
        .into_iter()
        .filter(|&t| t > 0.0)
        .map(|t| Intersection::new(t, id))
        .collect()
}

// ─── World-space intersect and normal functions ───────────────────────────────

/// Intersect a ray (in world space) with the shape at `id`, returning world-space intersections.
pub fn intersect_shape(shapes: &[ShapeNode], id: usize, ray: &Ray) -> Vec<Intersection> {
    let shape = &shapes[id];

    let effective_inverse = if let Some(ref motion_fn) = shape.motion_transform {
        let motion_mat = motion_fn(ray.time);
        (motion_mat * shape.transform).inverse()
    } else {
        shape.transform_inverse
    };

    let local_ray = ray.transform(&effective_inverse);

    match &shape.geometry {
        Geometry::Sphere => local_intersect_sphere(&local_ray, id),
        Geometry::Plane => local_intersect_plane(&local_ray, id),
        Geometry::Cube => local_intersect_cube(&local_ray, id),
        Geometry::Cylinder {
            minimum,
            maximum,
            closed,
        } => local_intersect_cylinder(&local_ray, id, *minimum, *maximum, *closed),
        Geometry::Cone {
            minimum,
            maximum,
            closed,
        } => local_intersect_cone(&local_ray, id, *minimum, *maximum, *closed),
        Geometry::Triangle {
            p1, e1, e2, normal, ..
        } => local_intersect_triangle(&local_ray, id, *p1, *e1, *e2, *normal),
        Geometry::SmoothTriangle { p1, e1, e2, .. } => {
            local_intersect_smooth_triangle(&local_ray, id, *p1, *e1, *e2)
        }
        Geometry::Torus {
            major_radius,
            minor_radius,
        } => local_intersect_torus(&local_ray, id, *major_radius, *minor_radius),
        Geometry::Group { children } => {
            let bounds = group_bounds(shapes, id);
            if !bounds.intersects_ray(&local_ray) {
                return vec![];
            }
            let children: Vec<usize> = children.clone();
            let mut xs: Vec<Intersection> = children
                .iter()
                .flat_map(|&child_id| intersect_shape(shapes, child_id, &local_ray))
                .collect();
            xs.sort_by(|a, b| a.t.partial_cmp(&b.t).unwrap());
            xs
        }
        Geometry::Csg {
            operation,
            left,
            right,
        } => {
            let (op, l, r) = (*operation, *left, *right);
            let mut left_xs = intersect_shape(shapes, l, &local_ray);
            let mut right_xs = intersect_shape(shapes, r, &local_ray);
            left_xs.append(&mut right_xs);
            left_xs.sort_by(|a, b| a.t.partial_cmp(&b.t).unwrap());
            filter_csg_intersections(shapes, op, l, r, &left_xs)
        }
    }
}

fn shape_bounds(shapes: &[ShapeNode], id: usize) -> Bounds {
    match &shapes[id].geometry {
        Geometry::Group { .. } | Geometry::Csg { .. } => group_bounds(shapes, id),
        _ => shapes[id].local_bounds(),
    }
}

fn group_bounds(shapes: &[ShapeNode], id: usize) -> Bounds {
    match &shapes[id].geometry {
        Geometry::Group { children } => {
            let children: Vec<usize> = children.clone();
            children.iter().fold(Bounds::empty(), |acc, &child_id| {
                let child_bounds = shape_bounds(shapes, child_id);
                acc.merge(child_bounds.transform(&shapes[child_id].transform))
            })
        }
        Geometry::Csg { left, right, .. } => {
            let (l, r) = (*left, *right);
            let left_bounds = shape_bounds(shapes, l).transform(&shapes[l].transform);
            let right_bounds = shape_bounds(shapes, r).transform(&shapes[r].transform);
            left_bounds.merge(right_bounds)
        }
        _ => shapes[id].local_bounds(),
    }
}

fn csg_intersection_allowed(
    op: CsgOperation,
    left_hit: bool,
    in_left: bool,
    in_right: bool,
) -> bool {
    match op {
        CsgOperation::Union => (left_hit && !in_right) || (!left_hit && !in_left),
        CsgOperation::Intersection => (left_hit && in_right) || (!left_hit && in_left),
        CsgOperation::Difference => (left_hit && !in_right) || (!left_hit && in_left),
    }
}

fn shape_includes(shapes: &[ShapeNode], id: usize, target: usize) -> bool {
    if id == target {
        return true;
    }
    match &shapes[id].geometry {
        Geometry::Group { children } => {
            let children: Vec<usize> = children.clone();
            children.iter().any(|&c| shape_includes(shapes, c, target))
        }
        Geometry::Csg { left, right, .. } => {
            let (l, r) = (*left, *right);
            shape_includes(shapes, l, target) || shape_includes(shapes, r, target)
        }
        _ => false,
    }
}

fn filter_csg_intersections(
    shapes: &[ShapeNode],
    op: CsgOperation,
    left: usize,
    _right: usize,
    xs: &[Intersection],
) -> Vec<Intersection> {
    let mut in_left = false;
    let mut in_right = false;
    let mut result = Vec::new();
    for &i in xs {
        let left_hit = shape_includes(shapes, left, i.object_id);
        if csg_intersection_allowed(op, left_hit, in_left, in_right) {
            result.push(i);
        }
        if left_hit {
            in_left = !in_left;
        } else {
            in_right = !in_right;
        }
    }
    result
}

/// Transform a world-space point into the local space of shape `id`,
/// walking up the parent chain.
pub fn world_to_object(shapes: &[ShapeNode], id: usize, world_point: Point) -> Point {
    let point = match shapes[id].parent_id {
        Some(parent) => world_to_object(shapes, parent, world_point),
        None => world_point,
    };
    shapes[id].transform_inverse.mul_point(point)
}

/// Transform a local-space normal vector into world space, walking up the parent chain.
pub fn normal_to_world(shapes: &[ShapeNode], id: usize, local_normal: Vector) -> Vector {
    let world_normal = shapes[id]
        .transform_inverse_transpose
        .mul_vector(local_normal)
        .normalize();
    match shapes[id].parent_id {
        Some(parent) => normal_to_world(shapes, parent, world_normal),
        None => world_normal,
    }
}

/// Compute the surface normal at `world_point` on shape `id`.
pub fn normal_at(
    shapes: &[ShapeNode],
    id: usize,
    world_point: Point,
    hit: &Intersection,
) -> Vector {
    let local_point = world_to_object(shapes, id, world_point);
    let local_normal = local_normal_at(&shapes[id], local_point, hit);

    let local_normal = if let Some(ref perturb) = shapes[id].material.normal_perturbation {
        (local_normal + perturb(local_point)).normalize()
    } else {
        local_normal
    };

    normal_to_world(shapes, id, local_normal)
}

fn local_normal_at(shape: &ShapeNode, p: Point, hit: &Intersection) -> Vector {
    match &shape.geometry {
        Geometry::Sphere => (p - Point::origin()).normalize(),
        Geometry::Plane => Vector::new(0.0, 1.0, 0.0),
        Geometry::Cube => {
            let ax = p.x.abs();
            let ay = p.y.abs();
            let az = p.z.abs();
            let max = ax.max(ay).max(az);
            if max == ax {
                Vector::new(p.x, 0.0, 0.0)
            } else if max == ay {
                Vector::new(0.0, p.y, 0.0)
            } else {
                Vector::new(0.0, 0.0, p.z)
            }
        }
        Geometry::Cylinder {
            minimum, maximum, ..
        } => {
            let dist = p.x * p.x + p.z * p.z;
            if dist < 1.0 && p.y >= maximum - EPSILON {
                Vector::new(0.0, 1.0, 0.0)
            } else if dist < 1.0 && p.y <= minimum + EPSILON {
                Vector::new(0.0, -1.0, 0.0)
            } else {
                Vector::new(p.x, 0.0, p.z)
            }
        }
        Geometry::Cone {
            minimum, maximum, ..
        } => {
            let dist = (p.x * p.x + p.z * p.z).sqrt();
            let y = if p.y > 0.0 { -dist } else { dist };
            if p.x * p.x + p.z * p.z < p.y * p.y {
                if p.y >= maximum - EPSILON {
                    return Vector::new(0.0, 1.0, 0.0);
                }
                if p.y <= minimum + EPSILON {
                    return Vector::new(0.0, -1.0, 0.0);
                }
            }
            Vector::new(p.x, y, p.z)
        }
        Geometry::Triangle { normal, .. } => *normal,
        Geometry::SmoothTriangle { n1, n2, n3, .. } => {
            let u = hit.u.unwrap_or(0.0);
            let v = hit.v.unwrap_or(0.0);
            (*n2 * u + *n3 * v + *n1 * (1.0 - u - v)).normalize()
        }
        Geometry::Torus { major_radius, .. } => {
            let dist = (p.x * p.x + p.z * p.z).sqrt();
            let (cx, cz) = if dist > 0.0 {
                (p.x * major_radius / dist, p.z * major_radius / dist)
            } else {
                (*major_radius, 0.0)
            };
            Vector::new(p.x - cx, p.y, p.z - cz).normalize()
        }
        Geometry::Group { .. } | Geometry::Csg { .. } => Vector::new(0.0, 1.0, 0.0),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::point::Point;
    use crate::transformations::{scaling, translation};

    #[test]
    fn sphere_intersects_ray() {
        let shapes = vec![ShapeNode::sphere()];
        let r = Ray::new(Point::new(0.0, 0.0, -5.0), Vector::new(0.0, 0.0, 1.0));
        let xs = intersect_shape(&shapes, 0, &r);
        assert_eq!(xs.len(), 2);
        assert!((xs[0].t - 4.0).abs() < 0.001);
        assert!((xs[1].t - 6.0).abs() < 0.001);
    }

    #[test]
    fn sphere_normal_at_x_axis() {
        let shapes = vec![ShapeNode::sphere()];
        let dummy_hit = Intersection::new(0.0, 0);
        let n = normal_at(&shapes, 0, Point::new(1.0, 0.0, 0.0), &dummy_hit);
        assert!((n.x - 1.0).abs() < 0.001);
        assert!(n.y.abs() < 0.001);
        assert!(n.z.abs() < 0.001);
    }

    #[test]
    fn ray_misses_plane() {
        let shapes = vec![ShapeNode::plane()];
        let r = Ray::new(Point::new(0.0, 10.0, 0.0), Vector::new(0.0, 0.0, 1.0));
        assert!(intersect_shape(&shapes, 0, &r).is_empty());
    }

    #[test]
    fn plane_normal_is_constant() {
        let shapes = vec![ShapeNode::plane()];
        let dummy = Intersection::new(0.0, 0);
        let n = normal_at(&shapes, 0, Point::new(0.0, 0.0, 0.0), &dummy);
        assert!((n.y - 1.0).abs() < 0.001);
    }

    #[test]
    fn cube_ray_hit() {
        let shapes = vec![ShapeNode::cube()];
        let r = Ray::new(Point::new(5.0, 0.5, 0.0), Vector::new(-1.0, 0.0, 0.0));
        let xs = intersect_shape(&shapes, 0, &r);
        assert_eq!(xs.len(), 2);
        assert!((xs[0].t - 4.0).abs() < 0.001);
        assert!((xs[1].t - 6.0).abs() < 0.001);
    }

    #[test]
    fn cylinder_closed_hit() {
        let shapes = vec![ShapeNode::cylinder_closed(1.0, 2.0)];
        let r = Ray::new(Point::new(0.0, 3.0, 0.0), Vector::new(0.0, -1.0, 0.0));
        let xs = intersect_shape(&shapes, 0, &r);
        assert_eq!(xs.len(), 2);
    }

    #[test]
    fn triangle_intersect() {
        let p1 = Point::new(0.0, 1.0, 0.0);
        let p2 = Point::new(-1.0, 0.0, 0.0);
        let p3 = Point::new(1.0, 0.0, 0.0);
        let shapes = vec![ShapeNode::triangle(p1, p2, p3)];
        let r = Ray::new(Point::new(0.0, 0.5, -2.0), Vector::new(0.0, 0.0, 1.0));
        let xs = intersect_shape(&shapes, 0, &r);
        assert_eq!(xs.len(), 1);
        assert!((xs[0].t - 2.0).abs() < 0.001);
    }

    #[test]
    fn scaled_sphere_intersect() {
        let mut s = ShapeNode::sphere();
        s.set_transform(scaling(2.0, 2.0, 2.0));
        let shapes = vec![s];
        let r = Ray::new(Point::new(0.0, 0.0, -5.0), Vector::new(0.0, 0.0, 1.0));
        let xs = intersect_shape(&shapes, 0, &r);
        assert_eq!(xs.len(), 2);
        assert!((xs[0].t - 3.0).abs() < 0.001);
        assert!((xs[1].t - 7.0).abs() < 0.001);
    }

    #[test]
    fn group_intersect_children() {
        let mut shapes = vec![ShapeNode::group()];
        let child = ShapeNode::sphere();
        let child_id = shapes.len();
        shapes.push(child);
        shapes[child_id].parent_id = Some(0);
        if let Geometry::Group { ref mut children } = shapes[0].geometry {
            children.push(child_id);
        }
        let r = Ray::new(Point::new(0.0, 0.0, -5.0), Vector::new(0.0, 0.0, 1.0));
        let xs = intersect_shape(&shapes, 0, &r);
        assert_eq!(xs.len(), 2);
    }

    #[test]
    fn translated_sphere_normal() {
        let mut s = ShapeNode::sphere();
        s.set_transform(translation(0.0, 1.0, 0.0));
        let shapes = vec![s];
        let dummy = Intersection::new(0.0, 0);
        let n = normal_at(&shapes, 0, Point::new(0.0, 1.70711, -0.70711), &dummy);
        assert!((n.x).abs() < 0.001);
        assert!((n.y - 0.70711).abs() < 0.001);
        assert!((n.z + 0.70711).abs() < 0.001);
    }

    // ─── CSG truth-table tests ────────────────────────────────────────────────

    #[test]
    fn csg_union_allowed() {
        assert!(!csg_intersection_allowed(CsgOperation::Union, true,  true,  true));
        assert!( csg_intersection_allowed(CsgOperation::Union, true,  true,  false));
        assert!(!csg_intersection_allowed(CsgOperation::Union, true,  false, true));
        assert!( csg_intersection_allowed(CsgOperation::Union, true,  false, false));
        assert!(!csg_intersection_allowed(CsgOperation::Union, false, true,  true));
        assert!(!csg_intersection_allowed(CsgOperation::Union, false, true,  false));
        assert!( csg_intersection_allowed(CsgOperation::Union, false, false, true));
        assert!( csg_intersection_allowed(CsgOperation::Union, false, false, false));
    }

    #[test]
    fn csg_intersection_allowed_test() {
        assert!( csg_intersection_allowed(CsgOperation::Intersection, true,  true,  true));
        assert!(!csg_intersection_allowed(CsgOperation::Intersection, true,  true,  false));
        assert!( csg_intersection_allowed(CsgOperation::Intersection, true,  false, true));
        assert!(!csg_intersection_allowed(CsgOperation::Intersection, true,  false, false));
        assert!( csg_intersection_allowed(CsgOperation::Intersection, false, true,  true));
        assert!( csg_intersection_allowed(CsgOperation::Intersection, false, true,  false));
        assert!(!csg_intersection_allowed(CsgOperation::Intersection, false, false, true));
        assert!(!csg_intersection_allowed(CsgOperation::Intersection, false, false, false));
    }

    #[test]
    fn csg_difference_allowed() {
        assert!(!csg_intersection_allowed(CsgOperation::Difference, true,  true,  true));
        assert!( csg_intersection_allowed(CsgOperation::Difference, true,  true,  false));
        assert!(!csg_intersection_allowed(CsgOperation::Difference, true,  false, true));
        assert!( csg_intersection_allowed(CsgOperation::Difference, true,  false, false));
        assert!( csg_intersection_allowed(CsgOperation::Difference, false, true,  true));
        assert!( csg_intersection_allowed(CsgOperation::Difference, false, true,  false));
        assert!(!csg_intersection_allowed(CsgOperation::Difference, false, false, true));
        assert!(!csg_intersection_allowed(CsgOperation::Difference, false, false, false));
    }

    // ─── CSG filter tests ─────────────────────────────────────────────────────

    fn two_spheres_xs() -> (Vec<ShapeNode>, Vec<Intersection>) {
        let shapes = vec![ShapeNode::sphere(), ShapeNode::sphere()];
        let xs = vec![
            Intersection::new(1.0, 0),
            Intersection::new(2.0, 1),
            Intersection::new(3.0, 0),
            Intersection::new(4.0, 1),
        ];
        (shapes, xs)
    }

    #[test]
    fn csg_filter_union() {
        let (shapes, xs) = two_spheres_xs();
        let result = filter_csg_intersections(&shapes, CsgOperation::Union, 0, 1, &xs);
        assert_eq!(result.len(), 2);
        assert!((result[0].t - 1.0).abs() < 1e-5);
        assert!((result[1].t - 4.0).abs() < 1e-5);
    }

    #[test]
    fn csg_filter_intersection() {
        let (shapes, xs) = two_spheres_xs();
        let result = filter_csg_intersections(&shapes, CsgOperation::Intersection, 0, 1, &xs);
        assert_eq!(result.len(), 2);
        assert!((result[0].t - 2.0).abs() < 1e-5);
        assert!((result[1].t - 3.0).abs() < 1e-5);
    }

    #[test]
    fn csg_filter_difference() {
        let (shapes, xs) = two_spheres_xs();
        let result = filter_csg_intersections(&shapes, CsgOperation::Difference, 0, 1, &xs);
        assert_eq!(result.len(), 2);
        assert!((result[0].t - 1.0).abs() < 1e-5);
        assert!((result[1].t - 2.0).abs() < 1e-5);
    }
}
