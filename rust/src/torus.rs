// Durand-Kerner root finder for the torus quartic intersection.
// Returns up to 4 real roots of: a*t^4 + b*t^3 + c*t^2 + d*t + e = 0

const TOLERANCE: f64 = 1e-10;
const MAX_ITER: usize = 100;

#[derive(Copy, Clone)]
struct C {
    re: f64,
    im: f64,
}

impl C {
    fn new(re: f64, im: f64) -> Self {
        C { re, im }
    }
    fn abs(self) -> f64 {
        (self.re * self.re + self.im * self.im).sqrt()
    }
}

impl std::ops::Add for C {
    type Output = C;
    fn add(self, o: C) -> C {
        C::new(self.re + o.re, self.im + o.im)
    }
}

impl std::ops::Sub for C {
    type Output = C;
    fn sub(self, o: C) -> C {
        C::new(self.re - o.re, self.im - o.im)
    }
}

impl std::ops::Mul for C {
    type Output = C;
    fn mul(self, o: C) -> C {
        C::new(
            self.re * o.re - self.im * o.im,
            self.re * o.im + self.im * o.re,
        )
    }
}

impl std::ops::Mul<f64> for C {
    type Output = C;
    fn mul(self, s: f64) -> C {
        C::new(self.re * s, self.im * s)
    }
}

impl std::ops::Div for C {
    type Output = C;
    fn div(self, o: C) -> C {
        let d = o.re * o.re + o.im * o.im;
        C::new(
            (self.re * o.re + self.im * o.im) / d,
            (self.im * o.re - self.re * o.im) / d,
        )
    }
}

fn poly_eval(bc: f64, cc: f64, dc: f64, ec: f64, z: C) -> C {
    // Evaluate monic quartic z^4 + bc*z^3 + cc*z^2 + dc*z + ec
    let z2 = z * z;
    let z3 = z2 * z;
    let z4 = z2 * z2;
    z4 + z3 * bc + z2 * cc + z * dc + C::new(ec, 0.0)
}

pub fn solve_quartic(a: f64, b: f64, c: f64, d: f64, e: f64) -> Vec<f64> {
    if a == 0.0 {
        return vec![];
    }
    let bc = b / a;
    let cc = c / a;
    let dc = d / a;
    let ec = e / a;

    // Initial guesses spread around the complex plane
    let mut z = [
        C::new(1.0, 1.0),
        C::new(-1.0, 1.0),
        C::new(-1.0, -1.0),
        C::new(1.0, -1.0),
    ];

    for _ in 0..MAX_ITER {
        let p: [C; 4] = std::array::from_fn(|i| poly_eval(bc, cc, dc, ec, z[i]));
        let new_z: [C; 4] = std::array::from_fn(|i| {
            let mut denom = C::new(1.0, 0.0);
            for j in 0..4 {
                if j != i {
                    denom = denom * (z[i] - z[j]);
                }
            }
            z[i] - p[i] / denom
        });
        let converged = (0..4).all(|i| (new_z[i] - z[i]).abs() < TOLERANCE);
        z = new_z;
        if converged {
            break;
        }
    }

    z.iter()
        .filter(|r| r.im.abs() < TOLERANCE)
        .map(|r| r.re)
        .collect()
}
