pub const EPSILON: f64 = 0.00003;

pub fn approx_eq(a: f64, b: f64) -> bool {
    (a - b).abs() < EPSILON
}
