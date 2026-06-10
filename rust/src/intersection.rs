/// An intersection of a ray with a shape, identified by index in the World's shapes Vec.
#[derive(Debug, Clone, Copy)]
pub struct Intersection {
    pub t: f64,
    pub object_id: usize,
    pub u: Option<f64>,
    pub v: Option<f64>,
}

impl Intersection {
    pub fn new(t: f64, object_id: usize) -> Self {
        Intersection { t, object_id, u: None, v: None }
    }

    pub fn with_uv(t: f64, object_id: usize, u: f64, v: f64) -> Self {
        Intersection { t, object_id, u: Some(u), v: Some(v) }
    }
}

/// Return the first non-negative intersection (the "hit").
pub fn hit(xs: &[Intersection]) -> Option<&Intersection> {
    xs.iter().filter(|i| i.t >= 0.0).min_by(|a, b| a.t.partial_cmp(&b.t).unwrap())
}
