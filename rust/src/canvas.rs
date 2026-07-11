use crate::color::Color;

pub struct Canvas {
    pub width: usize,
    pub height: usize,
    pixels: Vec<Color>,
}

impl Canvas {
    pub fn new(width: usize, height: usize) -> Self {
        Canvas {
            width,
            height,
            pixels: vec![Color::BLACK; width * height],
        }
    }

    pub fn write_pixel(&mut self, col: usize, row: usize, color: Color) {
        if col < self.width && row < self.height {
            self.pixels[row * self.width + col] = color;
        }
    }

    pub fn pixel_at(&self, col: usize, row: usize) -> Color {
        self.pixels[row * self.width + col]
    }

    pub fn to_ppm(&self) -> String {
        let mut out = format!("P3\n{} {}\n255\n", self.width, self.height);
        // Canvas row 0 is the bottom of the image (origin bottom-left), so rows are
        // written height-1 downto 0 to produce top-to-bottom PPM output. Columns are
        // left-to-right within each row.
        for row in (0..self.height).rev() {
            let mut parts = Vec::with_capacity(self.width * 3);
            for col in 0..self.width {
                let c = self.pixels[row * self.width + col];
                parts.push(scale(c.r));
                parts.push(scale(c.g));
                parts.push(scale(c.b));
            }
            out.push_str(
                &parts
                    .iter()
                    .map(|v| v.to_string())
                    .collect::<Vec<_>>()
                    .join(" "),
            );
            out.push('\n');
        }
        out.push('\n');
        out
    }
}

fn scale(v: f64) -> u8 {
    ((v * 256.0).round() as i64).clamp(0, 255) as u8
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn write_and_read_pixel() {
        let mut c = Canvas::new(10, 20);
        let red = Color::new(1.0, 0.0, 0.0);
        c.write_pixel(2, 3, red);
        assert_eq!(c.pixel_at(2, 3), red);
    }

    #[test]
    fn ppm_pixel_data_preserves_column_order() {
        let mut c = Canvas::new(5, 3);
        let color1 = Color::new(1.5, 0.0, 0.0);
        let color2 = Color::new(0.0, 0.5, 0.0);
        let color3 = Color::new(-0.5, 0.0, 1.0);
        c.write_pixel(0, 0, color1);
        c.write_pixel(2, 1, color2);
        c.write_pixel(4, 2, color3);
        let ppm = c.to_ppm();
        let lines: Vec<&str> = ppm.lines().collect();
        assert_eq!(lines[3], "0 0 0 0 0 0 0 0 0 0 0 0 0 0 255");
        assert_eq!(lines[4], "0 0 0 0 0 0 0 128 0 0 0 0 0 0 0");
        assert_eq!(lines[5], "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0");
    }
}
