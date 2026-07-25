use crate::point::Point;
use crate::util::approx_eq;
use crate::vector::Vector;

/// Row-major 4x4 matrix. Element (row, col) is at data[row * 4 + col].
#[derive(Debug, Clone, Copy)]
pub struct Matrix4 {
    pub data: [f64; 16],
}

impl Matrix4 {
    pub fn new(data: [f64; 16]) -> Self {
        Matrix4 { data }
    }

    pub fn identity() -> Self {
        Matrix4 {
            data: [
                1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
            ],
        }
    }

    pub fn zero() -> Self {
        Matrix4 { data: [0.0; 16] }
    }

    pub fn get(&self, row: usize, col: usize) -> f64 {
        self.data[row * 4 + col]
    }

    pub fn set(&mut self, row: usize, col: usize, val: f64) {
        self.data[row * 4 + col] = val;
    }

    pub fn transpose(&self) -> Self {
        let d = &self.data;
        Matrix4::new([
            d[0], d[4], d[8], d[12], d[1], d[5], d[9], d[13], d[2], d[6], d[10], d[14], d[3], d[7],
            d[11], d[15],
        ])
    }

    pub fn mul_point(&self, p: Point) -> Point {
        let d = &self.data;
        Point::new(
            d[0] * p.x + d[1] * p.y + d[2] * p.z + d[3],
            d[4] * p.x + d[5] * p.y + d[6] * p.z + d[7],
            d[8] * p.x + d[9] * p.y + d[10] * p.z + d[11],
        )
    }

    pub fn mul_vector(&self, v: Vector) -> Vector {
        let d = &self.data;
        Vector::new(
            d[0] * v.x + d[1] * v.y + d[2] * v.z,
            d[4] * v.x + d[5] * v.y + d[6] * v.z,
            d[8] * v.x + d[9] * v.y + d[10] * v.z,
        )
    }

    /// Inverse via Gauss-Jordan elimination with partial pivoting.
    pub fn inverse(&self) -> Self {
        let mut aug = [[0.0f64; 8]; 4];
        for row in 0..4 {
            for (col, item) in aug[row][..4].iter_mut().enumerate() {
                *item = self.data[row * 4 + col];
            }
            aug[row][4 + row] = 1.0;
        }

        for col in 0..4 {
            // Partial pivot
            let pivot_row = (col..4)
                .max_by(|&a, &b| aug[a][col].abs().partial_cmp(&aug[b][col].abs()).unwrap())
                .unwrap();
            aug.swap(col, pivot_row);

            let pivot = aug[col][col];
            assert!(
                pivot.abs() > f64::EPSILON,
                "Matrix4::inverse: matrix is singular"
            );
            for item in aug[col].iter_mut() {
                *item /= pivot;
            }

            for row in 0..4 {
                if row != col {
                    let factor = aug[row][col];
                    let pivot_row = aug[col]; // copy (f64 is Copy)
                    for (item, pv) in aug[row].iter_mut().zip(pivot_row.iter()) {
                        *item -= factor * pv;
                    }
                }
            }
        }

        let mut result = [0.0f64; 16];
        for row in 0..4 {
            for col in 0..4 {
                result[row * 4 + col] = aug[row][4 + col];
            }
        }
        Matrix4 { data: result }
    }
}

impl PartialEq for Matrix4 {
    fn eq(&self, other: &Self) -> bool {
        self.data
            .iter()
            .zip(other.data.iter())
            .all(|(a, b)| approx_eq(*a, *b))
    }
}

impl std::ops::Mul for Matrix4 {
    type Output = Matrix4;
    fn mul(self, rhs: Matrix4) -> Matrix4 {
        let a = &self.data;
        let b = &rhs.data;
        let mut r = [0.0f64; 16];
        for row in 0..4 {
            for col in 0..4 {
                r[row * 4 + col] = a[row * 4] * b[col]
                    + a[row * 4 + 1] * b[4 + col]
                    + a[row * 4 + 2] * b[8 + col]
                    + a[row * 4 + 3] * b[12 + col];
            }
        }
        Matrix4 { data: r }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn multiply_identity() {
        let m = Matrix4::new([
            1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0,
        ]);
        assert_eq!(m * Matrix4::identity(), m);
    }

    #[test]
    fn inverse_of_identity_is_identity() {
        assert_eq!(Matrix4::identity().inverse(), Matrix4::identity());
    }

    #[test]
    fn multiply_by_inverse() {
        let m = Matrix4::new([
            3.0, -9.0, 7.0, 3.0, 3.0, -8.0, 2.0, -9.0, -4.0, 4.0, 4.0, 1.0, -6.0, 5.0, -1.0, 1.0,
        ]);
        let inv = m.inverse();
        let product = m * inv;
        assert_eq!(product, Matrix4::identity());
    }

    #[test]
    #[should_panic(expected = "singular")]
    fn inverse_of_singular_matrix_panics() {
        // A degenerate (e.g. zero-scale) transform is genuinely singular.
        // This must panic in release builds too, not just debug — a plain
        // `assert!` is used in `inverse()` specifically so the check isn't
        // compiled out under `--release` the way `debug_assert!` would be.
        let m = Matrix4::zero();
        let _ = m.inverse();
    }
}
