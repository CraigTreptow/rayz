use crate::matrix::Matrix4;
use crate::point::Point;
use crate::ray::Ray;
use crate::util::EPSILON;

#[derive(Debug, Clone, Copy)]
pub struct Bounds {
    pub min: Point,
    pub max: Point,
}

impl Bounds {
    pub fn new(min: Point, max: Point) -> Self {
        Bounds { min, max }
    }

    pub fn empty() -> Self {
        Bounds {
            min: Point::new(f64::INFINITY, f64::INFINITY, f64::INFINITY),
            max: Point::new(f64::NEG_INFINITY, f64::NEG_INFINITY, f64::NEG_INFINITY),
        }
    }

    pub fn unit() -> Self {
        Bounds {
            min: Point::new(-1.0, -1.0, -1.0),
            max: Point::new(1.0, 1.0, 1.0),
        }
    }

    pub fn merge(self, other: Bounds) -> Bounds {
        Bounds {
            min: Point::new(
                self.min.x.min(other.min.x),
                self.min.y.min(other.min.y),
                self.min.z.min(other.min.z),
            ),
            max: Point::new(
                self.max.x.max(other.max.x),
                self.max.y.max(other.max.y),
                self.max.z.max(other.max.z),
            ),
        }
    }

    pub fn add_point(self, p: Point) -> Bounds {
        Bounds {
            min: Point::new(self.min.x.min(p.x), self.min.y.min(p.y), self.min.z.min(p.z)),
            max: Point::new(self.max.x.max(p.x), self.max.y.max(p.y), self.max.z.max(p.z)),
        }
    }

    /// Transform all 8 corners and return the bounding box of the result.
    pub fn transform(&self, m: &Matrix4) -> Bounds {
        let corners = [
            Point::new(self.min.x, self.min.y, self.min.z),
            Point::new(self.min.x, self.min.y, self.max.z),
            Point::new(self.min.x, self.max.y, self.min.z),
            Point::new(self.min.x, self.max.y, self.max.z),
            Point::new(self.max.x, self.min.y, self.min.z),
            Point::new(self.max.x, self.min.y, self.max.z),
            Point::new(self.max.x, self.max.y, self.min.z),
            Point::new(self.max.x, self.max.y, self.max.z),
        ];
        corners.iter().map(|&p| m.mul_point(p)).fold(Bounds::empty(), |b, p| b.add_point(p))
    }

    pub fn contains_point(&self, p: Point) -> bool {
        p.x >= self.min.x && p.x <= self.max.x
            && p.y >= self.min.y && p.y <= self.max.y
            && p.z >= self.min.z && p.z <= self.max.z
    }

    pub fn contains_bounds(&self, other: &Bounds) -> bool {
        self.contains_point(other.min) && self.contains_point(other.max)
    }

    /// Slab method ray-AABB intersection test.
    pub fn intersects_ray(&self, ray: &Ray) -> bool {
        let (xtmin, xtmax) = check_axis(ray.origin.x, ray.direction.x, self.min.x, self.max.x);
        let (ytmin, ytmax) = check_axis(ray.origin.y, ray.direction.y, self.min.y, self.max.y);
        let (ztmin, ztmax) = check_axis(ray.origin.z, ray.direction.z, self.min.z, self.max.z);

        let tmin = xtmin.max(ytmin).max(ztmin);
        let tmax = xtmax.min(ytmax).min(ztmax);
        tmin <= tmax
    }

    /// Split the bounds along its longest axis, returning (left, right).
    pub fn split(&self) -> (Bounds, Bounds) {
        let dx = self.max.x - self.min.x;
        let dy = self.max.y - self.min.y;
        let dz = self.max.z - self.min.z;

        if dx >= dy && dx >= dz {
            let mid = self.min.x + dx / 2.0;
            (
                Bounds::new(self.min, Point::new(mid, self.max.y, self.max.z)),
                Bounds::new(Point::new(mid, self.min.y, self.min.z), self.max),
            )
        } else if dy >= dx && dy >= dz {
            let mid = self.min.y + dy / 2.0;
            (
                Bounds::new(self.min, Point::new(self.max.x, mid, self.max.z)),
                Bounds::new(Point::new(self.min.x, mid, self.min.z), self.max),
            )
        } else {
            let mid = self.min.z + dz / 2.0;
            (
                Bounds::new(self.min, Point::new(self.max.x, self.max.y, mid)),
                Bounds::new(Point::new(self.min.x, self.min.y, mid), self.max),
            )
        }
    }
}

fn check_axis(origin: f64, direction: f64, min: f64, max: f64) -> (f64, f64) {
    let tmin_num = min - origin;
    let tmax_num = max - origin;

    let (tmin, tmax) = if direction.abs() >= EPSILON {
        (tmin_num / direction, tmax_num / direction)
    } else {
        (tmin_num * f64::INFINITY, tmax_num * f64::INFINITY)
    };

    if tmin > tmax { (tmax, tmin) } else { (tmin, tmax) }
}
