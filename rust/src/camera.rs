use crate::canvas::Canvas;
use crate::color::Color;
use crate::matrix::Matrix4;
use crate::point::Point;
use crate::ray::Ray;
use crate::world::World;
use rayon::prelude::*;
use std::cell::Cell;
use std::sync::atomic::{AtomicU64, Ordering};

/// Distinguishes rayon worker threads from one another so each gets an
/// independent RNG seed instead of every thread replaying the same
/// jitter sequence for the pixels it happens to process first.
static THREAD_SEED_COUNTER: AtomicU64 = AtomicU64::new(1);

fn thread_seed() -> u64 {
    use std::collections::hash_map::DefaultHasher;
    use std::hash::{Hash, Hasher};

    let counter = THREAD_SEED_COUNTER.fetch_add(0x9E3779B97F4A7C15, Ordering::Relaxed);
    let mut hasher = DefaultHasher::new();
    std::thread::current().id().hash(&mut hasher);
    let tid_hash = hasher.finish();

    let seed = 0x853c49e6748fea9bu64 ^ counter ^ tid_hash;
    if seed == 0 {
        0x9E3779B97F4A7C15
    } else {
        seed
    }
}

thread_local! {
    static RNG_STATE: Cell<u64> = Cell::new(thread_seed());
}

fn rand_f64() -> f64 {
    RNG_STATE.with(|s| {
        let mut x = s.get();
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        s.set(x);
        (x >> 11) as f64 / (1u64 << 53) as f64
    })
}

pub struct Camera {
    pub hsize: usize,
    pub vsize: usize,
    pub field_of_view: f64,
    pub samples_per_pixel: usize,
    pub aperture_size: f64,
    pub focal_distance: f64,
    pub motion_blur: bool,
    transform: Matrix4,
    transform_inverse: Matrix4,
    pixel_size: f64,
    half_width: f64,
    half_height: f64,
}

impl Camera {
    pub fn new(hsize: usize, vsize: usize, field_of_view: f64) -> Self {
        let mut cam = Camera {
            hsize,
            vsize,
            field_of_view,
            samples_per_pixel: 1,
            aperture_size: 0.0,
            focal_distance: 1.0,
            motion_blur: false,
            transform: Matrix4::identity(),
            transform_inverse: Matrix4::identity(),
            pixel_size: 0.0,
            half_width: 0.0,
            half_height: 0.0,
        };
        cam.recalculate_pixel_size();
        cam
    }

    pub fn set_transform(&mut self, t: Matrix4) {
        self.transform_inverse = t.inverse();
        self.transform = t;
    }

    fn recalculate_pixel_size(&mut self) {
        let half_view = (self.field_of_view / 2.0).tan();
        let aspect = self.hsize as f64 / self.vsize as f64;
        if aspect >= 1.0 {
            self.half_width = half_view;
            self.half_height = half_view / aspect;
        } else {
            self.half_width = half_view * aspect;
            self.half_height = half_view;
        }
        self.pixel_size = (self.half_width * 2.0) / self.hsize as f64;
    }

    #[allow(clippy::too_many_arguments)]
    fn ray_for_pixel(
        &self,
        px: usize,
        py: usize,
        px_off: f64,
        py_off: f64,
        ap_x: f64,
        ap_y: f64,
        time: f64,
    ) -> Ray {
        let xoffset = (px as f64 + px_off) * self.pixel_size;
        let yoffset = (py as f64 + py_off) * self.pixel_size;
        let world_x = self.half_width - xoffset;
        let world_y = self.half_height - yoffset;

        let canvas_z = -self.focal_distance;
        let pixel = self
            .transform_inverse
            .mul_point(Point::new(world_x, world_y, canvas_z));

        let aperture_x = ap_x * self.aperture_size;
        let aperture_y = ap_y * self.aperture_size;
        let origin = self
            .transform_inverse
            .mul_point(Point::new(aperture_x, aperture_y, 0.0));

        let direction = (pixel - origin).normalize();
        Ray::new_at_time(origin, direction, time)
    }

    fn render_pixel(&self, world: &World, px: usize, py: usize) -> Color {
        if self.samples_per_pixel == 1 && self.aperture_size == 0.0 && !self.motion_blur {
            let ray = self.ray_for_pixel(px, py, 0.5, 0.5, 0.0, 0.0, 0.0);
            return world.color_at(&ray, 3);
        }

        let mut total_r = 0.0_f64;
        let mut total_g = 0.0_f64;
        let mut total_b = 0.0_f64;

        for _ in 0..self.samples_per_pixel {
            let (ap_x, ap_y) = if self.aperture_size > 0.0 {
                (rand_f64() * 2.0 - 1.0, rand_f64() * 2.0 - 1.0)
            } else {
                (0.0, 0.0)
            };
            let time = if self.motion_blur { rand_f64() } else { 0.0 };
            let ray = self.ray_for_pixel(px, py, rand_f64(), rand_f64(), ap_x, ap_y, time);
            let c = world.color_at(&ray, 3);
            total_r += c.r;
            total_g += c.g;
            total_b += c.b;
        }
        let div = self.samples_per_pixel as f64;
        Color::new(total_r / div, total_g / div, total_b / div)
    }

    pub fn render(&self, world: &World) -> Canvas {
        let width = self.hsize;
        let height = self.vsize;

        let pixels: Vec<(usize, usize, Color)> = (0..height)
            .into_par_iter()
            .flat_map(|y| {
                let row: Vec<(usize, usize, Color)> = (0..width)
                    .map(|x| (x, y, self.render_pixel(world, x, y)))
                    .collect();
                row
            })
            .collect();

        let mut canvas = Canvas::new(width, height);
        for (x, y, color) in pixels {
            canvas.write_pixel(x, height - 1 - y, color);
        }
        canvas
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::thread;

    #[test]
    fn thread_seeds_are_independent_across_threads() {
        let seed_a = thread_seed();
        let seed_b = thread::spawn(thread_seed).join().unwrap();
        assert_ne!(
            seed_a, seed_b,
            "different threads must not share an RNG seed"
        );
    }

    #[test]
    fn rng_first_output_differs_across_threads() {
        let first_a = rand_f64();
        let first_b = thread::spawn(rand_f64).join().unwrap();
        assert_ne!(
            first_a, first_b,
            "threads must not replay the same jitter sequence"
        );
    }
}
