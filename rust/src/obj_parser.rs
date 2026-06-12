use crate::point::Point;
use crate::shape::ShapeNode;
use crate::vector::Vector;
use crate::world::World;

pub struct ObjParser {
    pub vertices: Vec<Point>,
    pub normals: Vec<Vector>,
    pub ignored: usize,
}

impl ObjParser {
    pub fn parse(input: &str) -> Self {
        let mut parser = ObjParser {
            vertices: vec![Point::origin()], // 1-indexed: slot 0 unused
            normals: vec![Vector::new(0.0, 1.0, 0.0)],
            ignored: 0,
        };
        parser.parse_lines(input);
        parser
    }

    fn parse_lines(&mut self, input: &str) {
        for line in input.lines() {
            let line = line.trim();
            if let Some(rest) = line.strip_prefix("v ") {
                let parts: Vec<f64> = rest
                    .split_whitespace()
                    .filter_map(|s| s.parse().ok())
                    .collect();
                if parts.len() >= 3 {
                    self.vertices.push(Point::new(parts[0], parts[1], parts[2]));
                }
            } else if let Some(rest) = line.strip_prefix("vn ") {
                let parts: Vec<f64> = rest
                    .split_whitespace()
                    .filter_map(|s| s.parse().ok())
                    .collect();
                if parts.len() >= 3 {
                    self.normals.push(Vector::new(parts[0], parts[1], parts[2]));
                }
            } else if line.starts_with("f ") {
                // Faces are handled during world building; we just track ignored here
            } else if !line.is_empty() && !line.starts_with('#') {
                self.ignored += 1;
            }
        }
    }

    /// Parse an OBJ string and add all resulting triangles to the world as children of a group.
    /// Returns the group id.
    pub fn load_into_world(input: &str, world: &mut World) -> usize {
        let mut vertices = vec![Point::origin()];
        let mut normals = vec![Vector::new(0.0, 1.0, 0.0)];

        for line in input.lines() {
            let line = line.trim();
            if let Some(rest) = line.strip_prefix("v ") {
                let parts: Vec<f64> = rest
                    .split_whitespace()
                    .filter_map(|s| s.parse().ok())
                    .collect();
                if parts.len() >= 3 {
                    vertices.push(Point::new(parts[0], parts[1], parts[2]));
                }
            } else if let Some(rest) = line.strip_prefix("vn ") {
                let parts: Vec<f64> = rest
                    .split_whitespace()
                    .filter_map(|s| s.parse().ok())
                    .collect();
                if parts.len() >= 3 {
                    normals.push(Vector::new(parts[0], parts[1], parts[2]));
                }
            }
        }

        let group_id = world.add(ShapeNode::group());

        for line in input.lines() {
            let line = line.trim();
            if !line.starts_with("f ") {
                continue;
            }

            let face_tokens: Vec<&str> = line[2..].split_whitespace().collect();
            if face_tokens.len() < 3 {
                continue;
            }

            let indices: Vec<(usize, Option<usize>)> = face_tokens
                .iter()
                .filter_map(|tok| parse_face_token(tok))
                .collect();

            // Fan triangulation
            for i in 1..indices.len() - 1 {
                let (vi0, ni0) = indices[0];
                let (vi1, ni1) = indices[i];
                let (vi2, ni2) = indices[i + 1];

                let (Some(&p1), Some(&p2), Some(&p3)) =
                    (vertices.get(vi0), vertices.get(vi1), vertices.get(vi2))
                else {
                    eprintln!("OBJ parse warning: face vertex index out of range, skipping");
                    continue;
                };

                let tri = match (ni0, ni1, ni2) {
                    (Some(n0), Some(n1), Some(n2)) => {
                        match (normals.get(n0), normals.get(n1), normals.get(n2)) {
                            (Some(&nv0), Some(&nv1), Some(&nv2)) => {
                                ShapeNode::smooth_triangle(p1, p2, p3, nv0, nv1, nv2)
                            }
                            _ => {
                                eprintln!("OBJ parse warning: face normal index out of range, using flat shading");
                                ShapeNode::triangle(p1, p2, p3)
                            }
                        }
                    }
                    _ => ShapeNode::triangle(p1, p2, p3),
                };
                world.add_child(group_id, tri);
            }
        }

        group_id
    }
}

fn parse_face_token(tok: &str) -> Option<(usize, Option<usize>)> {
    let parts: Vec<&str> = tok.split('/').collect();
    let vi = parts[0].parse::<usize>().ok()?;
    let ni = if parts.len() >= 3 {
        parts[2].parse::<usize>().ok()
    } else {
        None
    };
    Some((vi, ni))
}
