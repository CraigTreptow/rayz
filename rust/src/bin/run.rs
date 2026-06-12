//! Chapter runner — renders demonstration scenes to PPM files.
//! Usage: run [chapter_number|demo_name]  (default: all)

use rayz::*;
use std::env;
use std::f64::consts::PI;
use std::time::Instant;

fn main() {
    let arg = env::args().nth(1).unwrap_or_else(|| "all".to_string());

    match arg.as_str() {
        "all" => {
            for ch in 1..=17 {
                run_chapter(ch);
            }
            demo_advanced_features();
            demo_obj_parser();
            demo_nested_groups();
        }
        "advanced_features" => demo_advanced_features(),
        "obj_parser" => demo_obj_parser(),
        "nested_groups" => demo_nested_groups(),
        n => {
            if let Ok(ch) = n.parse::<u32>() {
                run_chapter(ch);
            } else {
                eprintln!("Unknown chapter or demo: {n}");
                std::process::exit(1);
            }
        }
    }
}

fn separator() {
    println!("\n{}\n", "=".repeat(60));
}

fn run_chapter(n: u32) {
    match n {
        1 => chapter1(),
        2 => chapter2(),
        3 => chapter3(),
        4 => chapter4(),
        5 => chapter5(),
        6 => chapter6(),
        7 => chapter7(),
        8 => chapter8(),
        9 => chapter9(),
        10 => chapter10(),
        11 => chapter11(),
        12 => chapter12(),
        13 => chapter13(),
        14 => chapter14(),
        15 => chapter15(),
        16 => chapter16(),
        17 => chapter17(),
        _ => eprintln!("Chapter {n} not yet implemented"),
    }
    separator();
}

// Chapter 1: Projectiles
fn chapter1() {
    println!("Chapter 1: Projectile physics");
    let mut pos = Point::new(0.0, 1.0, 0.0);
    let mut vel = Vector::new(1.0, 1.0, 0.0).normalize();
    let gravity = Vector::new(0.0, -0.1, 0.0);
    let wind = Vector::new(-0.01, 0.0, 0.0);
    let mut tick = 0;
    while pos.y >= 0.0 {
        println!("  Tick {tick}: ({:.2}, {:.2}, {:.2})", pos.x, pos.y, pos.z);
        pos = pos + vel;
        vel = vel + gravity + wind;
        tick += 1;
    }
    println!("  Landed after {tick} ticks");
}

// Chapter 2: Canvas / PPM
fn chapter2() {
    println!("Chapter 2: Canvas output");
    let mut canvas = Canvas::new(900, 550);
    let mut pos = Point::new(0.0, 1.0, 0.0);
    let mut vel = Vector::new(1.0, 1.8, 0.0).normalize() * 11.25;
    let gravity = Vector::new(0.0, -0.1, 0.0);
    let wind = Vector::new(-0.01, 0.0, 0.0);
    let red = Color::new(1.0, 0.0, 0.0);
    while pos.y >= 0.0 {
        let col = pos.x as usize;
        let row = canvas.height.saturating_sub(pos.y as usize + 1);
        canvas.write_pixel(col.min(canvas.width - 1), row.min(canvas.height - 1), red);
        pos = pos + vel;
        vel = vel + gravity + wind;
    }
    std::fs::write("chapter2.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter2.ppm");
}

// Chapter 3: Clock
fn chapter3() {
    println!("Chapter 3: Clock (matrix rotation)");
    let mut canvas = Canvas::new(500, 500);
    let white = Color::WHITE;
    let center_x = 250.0_f64;
    let center_y = 250.0_f64;
    let radius = 200.0;
    for h in 0..12 {
        let angle = h as f64 * PI / 6.0;
        let rot = rotation_z(angle);
        let p = rot.mul_point(Point::new(0.0, radius, 0.0));
        let col = (center_x + p.x) as usize;
        let row = (center_y - p.y) as usize;
        canvas.write_pixel(col.min(499), row.min(499), white);
    }
    std::fs::write("chapter3.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter3.ppm");
}

// Chapter 4: Transformation matrices clock (same visual as ch3)
fn chapter4() {
    println!("Chapter 4: Transformation matrices clock");
    chapter3();
}

// Chapter 5: Ray-sphere silhouette
fn chapter5() {
    println!("Chapter 5: Ray-sphere silhouette");
    let ray_origin = Point::new(0.0, 0.0, -5.0);
    let wall_z = 10.0;
    let wall_size = 7.0;
    let canvas_pixels = 200usize;
    let pixel_size = wall_size / canvas_pixels as f64;
    let half = wall_size / 2.0;
    let red = Color::new(1.0, 0.0, 0.0);

    let mut canvas = Canvas::new(canvas_pixels, canvas_pixels);
    let shapes = vec![ShapeNode::sphere()];

    for row in 0..canvas_pixels {
        let world_y = half - pixel_size * row as f64;
        for col in 0..canvas_pixels {
            let world_x = -half + pixel_size * col as f64;
            let target = Point::new(world_x, world_y, wall_z);
            let direction = (target - ray_origin).normalize();
            let r = Ray::new(ray_origin, direction);
            let xs = intersect_shape(&shapes, 0, &r);
            if hit(&xs).is_some() {
                canvas.write_pixel(col, row, red);
            }
        }
    }
    std::fs::write("chapter5.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter5.ppm");
}

// Chapter 6: Shaded sphere with Phong lighting
fn chapter6() {
    println!("Chapter 6: Phong-shaded sphere");
    let ray_origin = Point::new(0.0, 0.0, -5.0);
    let wall_z = 10.0;
    let wall_size = 7.0;
    let canvas_pixels = 200usize;
    let pixel_size = wall_size / canvas_pixels as f64;
    let half = wall_size / 2.0;

    let mut canvas = Canvas::new(canvas_pixels, canvas_pixels);
    let mut shapes = vec![ShapeNode::sphere()];
    shapes[0].material.color = Color::new(1.0, 0.2, 1.0);
    let light = Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE);

    for row in 0..canvas_pixels {
        let world_y = half - pixel_size * row as f64;
        for col in 0..canvas_pixels {
            let world_x = -half + pixel_size * col as f64;
            let target = Point::new(world_x, world_y, wall_z);
            let direction = (target - ray_origin).normalize();
            let r = Ray::new(ray_origin, direction);
            let xs = intersect_shape(&shapes, 0, &r);
            if let Some(h) = hit(&xs) {
                let point = r.position(h.t);
                let normalv = normal_at(&shapes, 0, point, h);
                let eyev = -r.direction;
                let color = lighting(
                    &shapes[0].material,
                    shapes[0].transform_inverse(),
                    &light,
                    point,
                    eyev,
                    normalv,
                    1.0,
                );
                canvas.write_pixel(col, row, color);
            }
        }
    }
    std::fs::write("chapter6.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter6.ppm");
}

// Chapter 7: Full 3D scene with World + Camera
fn chapter7() {
    println!("Chapter 7: Full 3D scene");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));

    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.color = Color::new(1.0, 0.9, 0.9);
    world.shape_mut(floor_id).material.specular = 0.0;

    let mid_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(mid_id)
        .set_transform(translation(-0.5, 1.0, 0.5));
    world.shape_mut(mid_id).material.color = Color::new(0.1, 1.0, 0.5);
    world.shape_mut(mid_id).material.diffuse = 0.7;
    world.shape_mut(mid_id).material.specular = 0.3;

    let right_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(right_id)
        .set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5));
    world.shape_mut(right_id).material.color = Color::new(0.5, 1.0, 0.1);
    world.shape_mut(right_id).material.diffuse = 0.7;
    world.shape_mut(right_id).material.specular = 0.3;

    let left_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(left_id)
        .set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33));
    world.shape_mut(left_id).material.color = Color::new(1.0, 0.8, 0.1);
    world.shape_mut(left_id).material.diffuse = 0.7;
    world.shape_mut(left_id).material.specular = 0.3;

    let mut camera = Camera::new(400, 200, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 1.5, -5.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter7.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter7.ppm");
}

// Chapter 8: Patterns
fn chapter8() {
    println!("Chapter 8: Patterns");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));

    // Floor with checkers
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(1.0, 1.0, 1.0),
        Color::new(0.2, 0.2, 0.2),
    ));
    world.shape_mut(floor_id).material.specular = 0.0;

    // Back wall with gradient
    let back_wall_id = world.add(ShapeNode::plane());
    let bw_t = rotation_x(PI / 2.0) * translation(0.0, 0.0, 5.0);
    world.shape_mut(back_wall_id).set_transform(bw_t);
    let mut bw_pat = Pattern::gradient(Color::new(0.5, 0.7, 1.0), Color::new(0.1, 0.1, 0.3));
    bw_pat.set_transform(rotation_z(PI / 2.0) * scaling(2.0, 2.0, 2.0));
    world.shape_mut(back_wall_id).material.pattern = Some(bw_pat);
    world.shape_mut(back_wall_id).material.specular = 0.0;

    // Middle sphere with ring pattern
    let mid_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(mid_id)
        .set_transform(translation(-0.5, 1.0, 0.5));
    let mut ring_pat = Pattern::ring(Color::new(0.1, 1.0, 0.5), Color::new(0.9, 0.1, 0.9));
    ring_pat.set_transform(scaling(0.2, 0.2, 0.2));
    world.shape_mut(mid_id).material.pattern = Some(ring_pat);
    world.shape_mut(mid_id).material.diffuse = 0.7;
    world.shape_mut(mid_id).material.specular = 0.3;

    // Right sphere with stripe pattern
    let right_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(right_id)
        .set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5));
    let mut stripe_pat = Pattern::stripe(Color::new(1.0, 0.2, 0.2), Color::new(1.0, 1.0, 0.2));
    stripe_pat.set_transform(scaling(0.2, 0.2, 0.2) * rotation_z(PI / 4.0));
    world.shape_mut(right_id).material.pattern = Some(stripe_pat);
    world.shape_mut(right_id).material.diffuse = 0.7;
    world.shape_mut(right_id).material.specular = 0.3;

    // Left sphere with gradient
    let left_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(left_id)
        .set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33));
    let mut grad_pat = Pattern::gradient(Color::new(1.0, 0.8, 0.1), Color::new(0.1, 0.2, 1.0));
    grad_pat.set_transform(translation(-1.0, 0.0, 0.0) * scaling(2.0, 2.0, 2.0));
    world.shape_mut(left_id).material.pattern = Some(grad_pat);
    world.shape_mut(left_id).material.diffuse = 0.7;
    world.shape_mut(left_id).material.specular = 0.3;

    let mut camera = Camera::new(400, 200, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 1.5, -5.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter8.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter8.ppm");
}

// Chapter 9: Planes
fn chapter9() {
    println!("Chapter 9: Planes");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));

    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.color = Color::new(1.0, 0.9, 0.9);
    world.shape_mut(floor_id).material.specular = 0.0;

    let left_wall_id = world.add(ShapeNode::plane());
    world
        .shape_mut(left_wall_id)
        .set_transform(translation(0.0, 0.0, 5.0) * rotation_y(-PI / 4.0) * rotation_x(PI / 2.0));
    world.shape_mut(left_wall_id).material.color = Color::new(1.0, 0.9, 0.9);
    world.shape_mut(left_wall_id).material.specular = 0.0;

    let right_wall_id = world.add(ShapeNode::plane());
    world
        .shape_mut(right_wall_id)
        .set_transform(translation(0.0, 0.0, 5.0) * rotation_y(PI / 4.0) * rotation_x(PI / 2.0));
    world.shape_mut(right_wall_id).material.color = Color::new(1.0, 0.9, 0.9);
    world.shape_mut(right_wall_id).material.specular = 0.0;

    let mid_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(mid_id)
        .set_transform(translation(-0.5, 1.0, 0.5));
    world.shape_mut(mid_id).material.color = Color::new(0.1, 1.0, 0.5);
    world.shape_mut(mid_id).material.diffuse = 0.7;
    world.shape_mut(mid_id).material.specular = 0.3;

    let right_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(right_id)
        .set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5));
    world.shape_mut(right_id).material.color = Color::new(0.5, 1.0, 0.1);
    world.shape_mut(right_id).material.diffuse = 0.7;
    world.shape_mut(right_id).material.specular = 0.3;

    let left_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(left_id)
        .set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33));
    world.shape_mut(left_id).material.color = Color::new(1.0, 0.8, 0.1);
    world.shape_mut(left_id).material.diffuse = 0.7;
    world.shape_mut(left_id).material.specular = 0.3;

    let mut camera = Camera::new(400, 200, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 1.5, -5.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter9.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter9.ppm");
}

// Chapter 10: Reflection and Refraction
fn chapter10() {
    println!("Chapter 10: Reflection and Refraction");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));

    // Floor with reflective checkerboard
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.15, 0.15, 0.15),
        Color::new(0.85, 0.85, 0.85),
    ));
    world.shape_mut(floor_id).material.ambient = 0.2;
    world.shape_mut(floor_id).material.diffuse = 0.8;
    world.shape_mut(floor_id).material.specular = 0.0;
    world.shape_mut(floor_id).material.reflective = 0.4;

    // Back wall - reflective
    let back_wall_id = world.add(ShapeNode::plane());
    world
        .shape_mut(back_wall_id)
        .set_transform(rotation_x(PI / 2.0) * translation(0.0, 0.0, 5.0));
    world.shape_mut(back_wall_id).material.color = Color::new(0.15, 0.15, 0.25);
    world.shape_mut(back_wall_id).material.ambient = 0.2;
    world.shape_mut(back_wall_id).material.diffuse = 0.7;
    world.shape_mut(back_wall_id).material.specular = 0.3;
    world.shape_mut(back_wall_id).material.shininess = 200.0;
    world.shape_mut(back_wall_id).material.reflective = 0.5;

    // Middle sphere - glass
    let mid_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(mid_id)
        .set_transform(translation(-0.5, 1.0, 0.5));
    world.shape_mut(mid_id).material.color = Color::new(0.1, 0.1, 0.1);
    world.shape_mut(mid_id).material.diffuse = 0.1;
    world.shape_mut(mid_id).material.ambient = 0.0;
    world.shape_mut(mid_id).material.specular = 1.0;
    world.shape_mut(mid_id).material.shininess = 300.0;
    world.shape_mut(mid_id).material.reflective = 1.0;
    world.shape_mut(mid_id).material.transparency = 1.0;
    world.shape_mut(mid_id).material.refractive_index = 1.5;

    // Right sphere - chrome
    let right_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(right_id)
        .set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5));
    world.shape_mut(right_id).material.color = Color::new(0.3, 0.3, 0.3);
    world.shape_mut(right_id).material.diffuse = 0.1;
    world.shape_mut(right_id).material.ambient = 0.0;
    world.shape_mut(right_id).material.specular = 1.0;
    world.shape_mut(right_id).material.shininess = 300.0;
    world.shape_mut(right_id).material.reflective = 0.9;

    // Left sphere - colored glass
    let left_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(left_id)
        .set_transform(translation(-1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5));
    world.shape_mut(left_id).material.color = Color::new(0.1, 0.3, 0.6);
    world.shape_mut(left_id).material.diffuse = 0.1;
    world.shape_mut(left_id).material.ambient = 0.0;
    world.shape_mut(left_id).material.specular = 1.0;
    world.shape_mut(left_id).material.shininess = 300.0;
    world.shape_mut(left_id).material.reflective = 0.5;
    world.shape_mut(left_id).material.transparency = 0.9;
    world.shape_mut(left_id).material.refractive_index = 1.5;

    let mut camera = Camera::new(400, 200, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 1.5, -5.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter10.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter10.ppm");
}

// Chapter 11: Cubes
fn chapter11() {
    println!("Chapter 11: Cubes");
    let mut world = World::new();
    world.light = Some(Light::point(
        Point::new(2.0, 10.0, -5.0),
        Color::new(0.9, 0.9, 0.9),
    ));

    // Room - large cube
    let room_id = world.add(ShapeNode::cube());
    world
        .shape_mut(room_id)
        .set_transform(scaling(15.0, 15.0, 15.0));
    world.shape_mut(room_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.15, 0.15, 0.15),
        Color::new(0.25, 0.25, 0.25),
    ));
    world.shape_mut(room_id).material.ambient = 0.3;
    world.shape_mut(room_id).material.diffuse = 0.7;
    world.shape_mut(room_id).material.specular = 0.0;
    world.shape_mut(room_id).material.reflective = 0.1;

    // Table surface
    let table_id = world.add(ShapeNode::cube());
    world
        .shape_mut(table_id)
        .set_transform(translation(0.0, 3.1, 0.0) * scaling(3.0, 0.1, 2.0));
    world.shape_mut(table_id).material.color = Color::new(0.6, 0.3, 0.1);
    world.shape_mut(table_id).material.ambient = 0.2;
    world.shape_mut(table_id).material.diffuse = 0.7;
    world.shape_mut(table_id).material.specular = 0.3;
    world.shape_mut(table_id).material.shininess = 20.0;

    // Table legs
    for &(x, z) in &[(-2.7_f64, -1.7_f64), (2.7, -1.7), (-2.7, 1.7), (2.7, 1.7)] {
        let leg_id = world.add(ShapeNode::cube());
        world
            .shape_mut(leg_id)
            .set_transform(translation(x, 1.5, z) * scaling(0.1, 1.5, 0.1));
        world.shape_mut(leg_id).material.color = Color::new(0.5, 0.25, 0.1);
        world.shape_mut(leg_id).material.ambient = 0.2;
        world.shape_mut(leg_id).material.diffuse = 0.7;
    }

    // Boxes on table
    let box1_id = world.add(ShapeNode::cube());
    world.shape_mut(box1_id).set_transform(
        translation(-1.0, 3.7, -0.5) * rotation_y(PI / 8.0) * scaling(0.5, 0.5, 0.5),
    );
    world.shape_mut(box1_id).material.color = Color::new(0.2, 0.4, 0.8);
    world.shape_mut(box1_id).material.ambient = 0.1;
    world.shape_mut(box1_id).material.diffuse = 0.6;
    world.shape_mut(box1_id).material.specular = 0.5;
    world.shape_mut(box1_id).material.shininess = 100.0;
    world.shape_mut(box1_id).material.reflective = 0.2;

    let box2_id = world.add(ShapeNode::cube());
    world
        .shape_mut(box2_id)
        .set_transform(translation(1.0, 3.7, 0.3) * rotation_y(-PI / 6.0) * scaling(0.4, 0.7, 0.4));
    world.shape_mut(box2_id).material.color = Color::new(0.8, 0.3, 0.2);
    world.shape_mut(box2_id).material.ambient = 0.1;
    world.shape_mut(box2_id).material.diffuse = 0.6;
    world.shape_mut(box2_id).material.specular = 0.5;
    world.shape_mut(box2_id).material.shininess = 100.0;

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(6.0, 5.0, -8.0),
        Point::new(0.0, 2.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter11.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter11.ppm");
}

// Chapter 12: Cylinders
fn chapter12() {
    println!("Chapter 12: Cylinders");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(10.0, 10.0, -10.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.5, 0.5, 0.5),
        Color::new(0.75, 0.75, 0.75),
    ));
    world.shape_mut(floor_id).material.reflective = 0.1;

    // Table legs (truncated cylinders)
    for &(x, z) in &[(-2.0_f64, 1.5_f64), (2.0, 1.5), (-2.0, -1.5), (2.0, -1.5)] {
        let leg_id = world.add(ShapeNode::cylinder_closed(0.0, 3.0));
        world
            .shape_mut(leg_id)
            .set_transform(translation(x, 0.0, z) * scaling(0.2, 1.0, 0.2));
        world.shape_mut(leg_id).material.color = Color::new(0.5, 0.3, 0.1);
        world.shape_mut(leg_id).material.ambient = 0.2;
        world.shape_mut(leg_id).material.diffuse = 0.7;
        world.shape_mut(leg_id).material.specular = 0.5;
        world.shape_mut(leg_id).material.shininess = 50.0;
    }

    // Table top (flat cylinder)
    let table_id = world.add(ShapeNode::cylinder_closed(0.0, 0.2));
    world
        .shape_mut(table_id)
        .set_transform(translation(0.0, 3.0, 0.0) * scaling(2.5, 1.0, 1.5));
    world.shape_mut(table_id).material.color = Color::new(0.6, 0.35, 0.1);
    world.shape_mut(table_id).material.ambient = 0.2;
    world.shape_mut(table_id).material.diffuse = 0.7;
    world.shape_mut(table_id).material.specular = 0.3;

    // Candle (thin tall closed cylinder)
    let candle_id = world.add(ShapeNode::cylinder_closed(0.0, 1.0));
    world
        .shape_mut(candle_id)
        .set_transform(translation(0.0, 3.2, -0.5) * scaling(0.1, 1.0, 0.1));
    world.shape_mut(candle_id).material.color = Color::new(0.9, 0.9, 0.7);

    // Open cylinder vase
    let vase_id = world.add(ShapeNode::cylinder_truncated(0.0, 1.0));
    world
        .shape_mut(vase_id)
        .set_transform(translation(-1.0, 3.2, 0.0) * scaling(0.3, 0.8, 0.3));
    world.shape_mut(vase_id).material.color = Color::new(0.2, 0.6, 0.8);
    world.shape_mut(vase_id).material.specular = 0.8;
    world.shape_mut(vase_id).material.shininess = 200.0;

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 5.0, -8.0),
        Point::new(0.0, 2.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter12.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter12.ppm");
}

// Chapter 13: Groups
fn chapter13() {
    println!("Chapter 13: Groups (hierarchical scene)");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-5.0, 10.0, -10.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.9, 0.9, 0.9),
        Color::new(0.1, 0.1, 0.1),
    ));
    world.shape_mut(floor_id).material.reflective = 0.1;

    // Tree: group containing trunk + foliage
    let tree_id = world.add(ShapeNode::group());
    world
        .shape_mut(tree_id)
        .set_transform(translation(-2.0, 0.0, 2.0));

    let trunk_id = world.add_child(tree_id, ShapeNode::cylinder_closed(0.0, 1.5));
    world
        .shape_mut(trunk_id)
        .set_transform(scaling(0.2, 1.0, 0.2));
    world.shape_mut(trunk_id).material.color = Color::new(0.4, 0.2, 0.1);
    world.shape_mut(trunk_id).material.specular = 0.1;

    let foliage_id = world.add_child(tree_id, ShapeNode::group());
    world
        .shape_mut(foliage_id)
        .set_transform(translation(0.0, 1.5, 0.0));

    for (i, &(dy, s)) in [(0.0_f64, 0.9_f64), (0.5, 0.7), (1.0, 0.5)]
        .iter()
        .enumerate()
    {
        let leaf_id = world.add_child(foliage_id, ShapeNode::sphere());
        let angle = i as f64 * PI * 2.0 / 3.0;
        world.shape_mut(leaf_id).set_transform(
            translation(angle.cos() * 0.3, dy, angle.sin() * 0.3) * scaling(s, s, s),
        );
        world.shape_mut(leaf_id).material.color = Color::new(0.1, 0.5, 0.1);
    }

    // Snowman: group with body spheres
    let snowman_id = world.add(ShapeNode::group());
    world
        .shape_mut(snowman_id)
        .set_transform(translation(2.0, 0.0, 1.0));

    let body_id = world.add_child(snowman_id, ShapeNode::sphere());
    world
        .shape_mut(body_id)
        .set_transform(translation(0.0, 0.75, 0.0) * scaling(0.75, 0.75, 0.75));
    world.shape_mut(body_id).material.color = Color::new(0.9, 0.9, 0.9);

    let head_id = world.add_child(snowman_id, ShapeNode::sphere());
    world
        .shape_mut(head_id)
        .set_transform(translation(0.0, 1.85, 0.0) * scaling(0.4, 0.4, 0.4));
    world.shape_mut(head_id).material.color = Color::new(0.95, 0.95, 0.95);

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 3.0, -8.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter13.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter13.ppm");
}

// Chapter 14: Cones
fn chapter14() {
    println!("Chapter 14: Cones");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(10.0, 10.0, -10.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.5, 0.5, 0.5),
        Color::new(0.75, 0.75, 0.75),
    ));
    world.shape_mut(floor_id).material.reflective = 0.1;

    // Traffic cone (truncated)
    let cone1_id = world.add(ShapeNode::cone_closed(-1.0, 0.0));
    world
        .shape_mut(cone1_id)
        .set_transform(translation(-2.0, 1.0, 0.0) * scaling(0.5, 1.0, 0.5));
    world.shape_mut(cone1_id).material.color = Color::new(1.0, 0.4, 0.0);
    world.shape_mut(cone1_id).material.ambient = 0.2;
    world.shape_mut(cone1_id).material.diffuse = 0.8;

    // Glass cone (double-napped, truncated)
    let cone2_id = world.add(ShapeNode::cone_truncated(-0.5, 0.5));
    world
        .shape_mut(cone2_id)
        .set_transform(translation(0.0, 1.0, 0.0));
    world.shape_mut(cone2_id).material.color = Color::new(0.1, 0.1, 0.1);
    world.shape_mut(cone2_id).material.diffuse = 0.1;
    world.shape_mut(cone2_id).material.specular = 1.0;
    world.shape_mut(cone2_id).material.shininess = 300.0;
    world.shape_mut(cone2_id).material.reflective = 0.9;
    world.shape_mut(cone2_id).material.transparency = 0.9;
    world.shape_mut(cone2_id).material.refractive_index = 1.5;

    // Metal cone (open top)
    let cone3_id = world.add(ShapeNode::cone_truncated(-1.0, 0.0));
    world
        .shape_mut(cone3_id)
        .set_transform(translation(2.0, 1.0, 0.0) * scaling(0.5, 1.0, 0.5));
    world.shape_mut(cone3_id).material.color = Color::new(0.5, 0.5, 0.5);
    world.shape_mut(cone3_id).material.specular = 0.9;
    world.shape_mut(cone3_id).material.shininess = 200.0;
    world.shape_mut(cone3_id).material.reflective = 0.5;

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 3.0, -5.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter14.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter14.ppm");
}

// Chapter 15: Triangles
fn chapter15() {
    println!("Chapter 15: Triangles");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(10.0, 10.0, -10.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.5, 0.5, 0.5),
        Color::new(0.75, 0.75, 0.75),
    ));
    world.shape_mut(floor_id).material.reflective = 0.1;

    // Pyramid from 4 triangles, translated left
    let pyramid_h = 2.0;
    let base = 1.5;
    let p1 = Point::new(-base, 0.0, -base);
    let p2 = Point::new(base, 0.0, -base);
    let p3 = Point::new(base, 0.0, base);
    let p4 = Point::new(-base, 0.0, base);
    let apex = Point::new(0.0, pyramid_h, 0.0);

    for (pa, pb) in &[(p1, p2), (p2, p3), (p3, p4), (p4, p1)] {
        let t_id = world.add(ShapeNode::triangle(*pa, *pb, apex));
        world
            .shape_mut(t_id)
            .set_transform(translation(-3.0, 0.0, 0.0));
        world.shape_mut(t_id).material.color = Color::new(1.0, 0.3, 0.3);
        world.shape_mut(t_id).material.ambient = 0.2;
        world.shape_mut(t_id).material.diffuse = 0.7;
        world.shape_mut(t_id).material.specular = 0.3;
    }

    // Octahedron from 8 triangles, center-right
    let o = 1.0_f64;
    let top = Point::new(0.0, o, 0.0);
    let bot = Point::new(0.0, -o, 0.0);
    let fr = Point::new(0.0, 0.0, o);
    let bk = Point::new(0.0, 0.0, -o);
    let lt = Point::new(-o, 0.0, 0.0);
    let rt = Point::new(o, 0.0, 0.0);

    for (a, b, c) in &[
        (top, fr, rt),
        (top, rt, bk),
        (top, bk, lt),
        (top, lt, fr),
        (bot, rt, fr),
        (bot, bk, rt),
        (bot, lt, bk),
        (bot, fr, lt),
    ] {
        let t_id = world.add(ShapeNode::triangle(*a, *b, *c));
        world
            .shape_mut(t_id)
            .set_transform(translation(1.0, 1.0, 0.0));
        world.shape_mut(t_id).material.color = Color::new(0.3, 0.6, 1.0);
        world.shape_mut(t_id).material.ambient = 0.2;
        world.shape_mut(t_id).material.diffuse = 0.7;
        world.shape_mut(t_id).material.specular = 0.5;
        world.shape_mut(t_id).material.shininess = 50.0;
    }

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 3.0, -6.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter15.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter15.ppm");
}

// Chapter 16: Constructive Solid Geometry
fn chapter16() {
    println!("Chapter 16: Constructive Solid Geometry");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-5.0, 5.0, -8.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.8, 0.8, 0.8),
        Color::new(0.2, 0.2, 0.2),
    ));
    world.shape_mut(floor_id).material.reflective = 0.2;
    world.shape_mut(floor_id).material.specular = 0.0;

    // CSG difference: cube - sphere (carved cube)
    let outer_cube = world.add_shape(ShapeNode::cube());
    world.shape_mut(outer_cube).material.color = Color::new(0.2, 0.5, 0.8);
    world.shape_mut(outer_cube).material.ambient = 0.2;
    world.shape_mut(outer_cube).material.diffuse = 0.7;
    world.shape_mut(outer_cube).material.specular = 0.5;

    let inner_sphere = world.add_shape(ShapeNode::sphere());
    world
        .shape_mut(inner_sphere)
        .set_transform(scaling(1.2, 1.2, 1.2));
    world.shape_mut(inner_sphere).material.color = Color::new(0.8, 0.3, 0.2);

    let csg1_id = world.add(ShapeNode::csg_difference(outer_cube, inner_sphere));
    world
        .shape_mut(csg1_id)
        .set_transform(translation(-2.0, 1.0, 0.0));

    // CSG union: two overlapping spheres
    let sph1 = world.add_shape(ShapeNode::sphere());
    world
        .shape_mut(sph1)
        .set_transform(translation(0.0, 0.3, 0.0));
    world.shape_mut(sph1).material.color = Color::new(0.8, 0.8, 0.2);
    world.shape_mut(sph1).material.reflective = 0.3;

    let sph2 = world.add_shape(ShapeNode::sphere());
    world
        .shape_mut(sph2)
        .set_transform(translation(0.0, -0.3, 0.0));
    world.shape_mut(sph2).material.color = Color::new(0.8, 0.8, 0.2);
    world.shape_mut(sph2).material.reflective = 0.3;

    let csg2_id = world.add(ShapeNode::csg_union(sph1, sph2));
    world
        .shape_mut(csg2_id)
        .set_transform(translation(1.5, 1.0, 0.0));

    // CSG intersection: cube ∩ sphere (rounded cube corners)
    let cube3 = world.add_shape(ShapeNode::cube());
    world.shape_mut(cube3).material.color = Color::new(0.3, 0.7, 0.3);
    world.shape_mut(cube3).material.specular = 0.5;

    let sph3 = world.add_shape(ShapeNode::sphere());
    world
        .shape_mut(sph3)
        .set_transform(scaling(1.35, 1.35, 1.35));
    world.shape_mut(sph3).material.color = Color::new(0.3, 0.7, 0.3);

    let csg3_id = world.add(ShapeNode::csg_intersection(cube3, sph3));
    world
        .shape_mut(csg3_id)
        .set_transform(translation(-0.5, 1.0, 2.5) * rotation_y(PI / 4.0));

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 2.0, -8.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter16.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter16.ppm");
}

// Chapter 17: Smooth Triangles
fn chapter17() {
    println!("Chapter 17: Smooth Triangles");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.9, 0.9, 0.9),
        Color::new(0.1, 0.1, 0.1),
    ));
    world.shape_mut(floor_id).material.ambient = 0.1;
    world.shape_mut(floor_id).material.diffuse = 0.7;
    world.shape_mut(floor_id).material.specular = 0.3;
    world.shape_mut(floor_id).material.reflective = 0.1;

    // Flat-shaded pyramid (left side)
    let fp1 = Point::new(-3.0, 0.0, -1.0);
    let fp2 = Point::new(-4.0, 0.0, 1.0);
    let fp3 = Point::new(-2.0, 0.0, 1.0);
    let fapex = Point::new(-3.0, 2.0, 0.0);

    for (a, b, c, col) in &[
        (fp1, fp2, fapex, Color::new(1.0, 0.0, 0.0)),
        (fp2, fp3, fapex, Color::new(0.0, 1.0, 0.0)),
        (fp3, fp1, fapex, Color::new(0.0, 0.0, 1.0)),
        (fp1, fp3, fp2, Color::new(0.8, 0.8, 0.0)),
    ] {
        let t_id = world.add(ShapeNode::triangle(*a, *b, *c));
        world.shape_mut(t_id).material.color = *col;
        world.shape_mut(t_id).material.ambient = 0.2;
        world.shape_mut(t_id).material.diffuse = 0.8;
        world.shape_mut(t_id).material.specular = 0.4;
        world.shape_mut(t_id).material.shininess = 50.0;
    }

    // Smooth-shaded pyramid (right side) using SmoothTriangle with shared vertex normals
    let sv = [
        Point::new(1.0, 0.0, -1.0),
        Point::new(0.0, 0.0, 1.0),
        Point::new(2.0, 0.0, 1.0),
        Point::new(1.0, 2.0, 0.0),
    ];
    // Compute vertex normals (average of face normals)
    let n_base = Vector::new(0.0, -1.0, 0.0);
    let n_apex = Vector::new(0.0, 1.0, 0.0).normalize();

    for (a, b, c, na, nb, nc, col) in &[
        (
            sv[0],
            sv[1],
            sv[3],
            n_apex,
            n_base,
            n_base,
            Color::new(1.0, 0.3, 0.3),
        ),
        (
            sv[1],
            sv[2],
            sv[3],
            n_base,
            n_apex,
            n_base,
            Color::new(0.3, 1.0, 0.3),
        ),
        (
            sv[2],
            sv[0],
            sv[3],
            n_base,
            n_base,
            n_apex,
            Color::new(0.3, 0.3, 1.0),
        ),
    ] {
        let t_id = world.add(ShapeNode::smooth_triangle(*a, *b, *c, *na, *nb, *nc));
        world.shape_mut(t_id).material.color = *col;
        world.shape_mut(t_id).material.ambient = 0.2;
        world.shape_mut(t_id).material.diffuse = 0.8;
        world.shape_mut(t_id).material.specular = 0.6;
        world.shape_mut(t_id).material.shininess = 100.0;
    }

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 3.0, -6.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("chapter17.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote chapter17.ppm");
}

// Demo: Advanced Features (Torus + normal perturbation)
fn demo_advanced_features() {
    println!("Advanced Features Demo: Torus + normal perturbation");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-5.0, 10.0, -5.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.5, 0.5, 0.5),
        Color::new(0.8, 0.8, 0.8),
    ));
    world.shape_mut(floor_id).material.specular = 0.0;
    world.shape_mut(floor_id).material.reflective = 0.1;

    // Wavy red sphere (sine-wave normal perturbation)
    let s1_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(s1_id)
        .set_transform(translation(-2.0, 1.0, 0.0));
    world.shape_mut(s1_id).material.color = Color::new(1.0, 0.3, 0.3);
    world.shape_mut(s1_id).material.specular = 0.8;
    world.shape_mut(s1_id).material.normal_perturbation = Some(Box::new(|p: Point| {
        let freq = 10.0_f64;
        let amp = 0.15_f64;
        Vector::new(
            (p.y * freq).sin() * amp,
            (p.z * freq).sin() * amp,
            (p.x * freq).sin() * amp,
        )
    }));

    // Torus (green)
    let torus_id = world.add(ShapeNode::torus(0.6, 0.2));
    world
        .shape_mut(torus_id)
        .set_transform(translation(0.0, 1.2, 0.0) * rotation_x(PI / 2.0));
    world.shape_mut(torus_id).material.color = Color::new(0.3, 1.0, 0.3);
    world.shape_mut(torus_id).material.specular = 0.8;
    world.shape_mut(torus_id).material.reflective = 0.4;

    // Quilted blue sphere
    let s2_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(s2_id)
        .set_transform(translation(2.0, 1.0, 0.0));
    world.shape_mut(s2_id).material.color = Color::new(0.3, 0.3, 1.0);
    world.shape_mut(s2_id).material.specular = 0.8;
    world.shape_mut(s2_id).material.normal_perturbation = Some(Box::new(|p: Point| {
        let freq = 8.0_f64;
        let amp = 0.2_f64;
        Vector::new(
            (p.x * freq).sin().abs() * amp,
            (p.y * freq).sin().abs() * amp,
            (p.z * freq).sin().abs() * amp,
        )
    }));

    let mut camera = Camera::new(400, 200, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 3.5, -8.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("advanced_features_demo.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote advanced_features_demo.ppm");
    separator();
}

// Demo: OBJ Parser (load tetrahedron.obj)
fn demo_obj_parser() {
    println!("OBJ Parser Demo: Loading tetrahedron from tetrahedron.obj");

    let obj_path =
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("examples/tetrahedron.obj");
    let obj_content = match std::fs::read_to_string(&obj_path) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("  Could not read {:?}: {e}", obj_path);
            return;
        }
    };

    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-5.0, 5.0, -5.0), Color::WHITE));

    // Load OBJ into a group and apply transform
    let group_id = ObjParser::load_into_world(&obj_content, &mut world);
    world
        .shape_mut(group_id)
        .set_transform(rotation_y(PI / 6.0) * scaling(1.5, 1.5, 1.5));

    // Apply material to all children in the group
    let child_ids: Vec<usize> = match &world.shape(group_id).geometry {
        rayz::Geometry::Group { children } => children.clone(),
        _ => vec![],
    };
    for child_id in child_ids {
        world.shape_mut(child_id).material.color = Color::new(0.8, 0.3, 0.3);
        world.shape_mut(child_id).material.diffuse = 0.7;
        world.shape_mut(child_id).material.specular = 0.3;
    }

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world
        .shape_mut(floor_id)
        .set_transform(translation(0.0, -2.0, 0.0));
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.15, 0.15, 0.15),
        Color::new(0.85, 0.85, 0.85),
    ));
    world.shape_mut(floor_id).material.ambient = 0.8;
    world.shape_mut(floor_id).material.diffuse = 0.2;
    world.shape_mut(floor_id).material.specular = 0.0;
    world.shape_mut(floor_id).material.reflective = 0.1;

    let mut camera = Camera::new(400, 267, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 3.0, -6.0),
        Point::new(0.0, 0.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("obj_parser_demo.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote obj_parser_demo.ppm");
    separator();
}

// Demo: Nested Groups (solar system hierarchy)
fn demo_nested_groups() {
    println!("Nested Groups Demo: Solar system hierarchy");
    let mut world = World::new();
    world.light = Some(Light::point(Point::new(-10.0, 10.0, -10.0), Color::WHITE));

    // Floor
    let floor_id = world.add(ShapeNode::plane());
    world.shape_mut(floor_id).material.pattern = Some(Pattern::checkers(
        Color::new(0.9, 0.9, 0.9),
        Color::new(0.1, 0.1, 0.1),
    ));
    world.shape_mut(floor_id).material.reflective = 0.2;

    // Sun
    let sun_id = world.add(ShapeNode::sphere());
    world
        .shape_mut(sun_id)
        .set_transform(scaling(1.5, 1.5, 1.5));
    world.shape_mut(sun_id).material.color = Color::new(1.0, 0.9, 0.1);
    world.shape_mut(sun_id).material.ambient = 0.8;
    world.shape_mut(sun_id).material.diffuse = 0.9;

    // Earth orbit → position → rotation → earth + moon orbit → moon position → moon
    let earth_orbit = world.add(ShapeNode::group());
    world
        .shape_mut(earth_orbit)
        .set_transform(rotation_y(PI / 4.0));

    let earth_pos = world.add_child(earth_orbit, ShapeNode::group());
    world
        .shape_mut(earth_pos)
        .set_transform(translation(5.0, 0.0, 0.0));

    let earth_rot = world.add_child(earth_pos, ShapeNode::group());
    world
        .shape_mut(earth_rot)
        .set_transform(rotation_y(PI / 3.0));

    let earth_id = world.add_child(earth_rot, ShapeNode::sphere());
    world
        .shape_mut(earth_id)
        .set_transform(scaling(0.8, 0.8, 0.8));
    world.shape_mut(earth_id).material.color = Color::new(0.1, 0.3, 0.8);
    world.shape_mut(earth_id).material.diffuse = 0.7;
    world.shape_mut(earth_id).material.specular = 0.3;

    let moon_orbit = world.add_child(earth_rot, ShapeNode::group());
    world
        .shape_mut(moon_orbit)
        .set_transform(rotation_y(-PI / 6.0));

    let moon_pos = world.add_child(moon_orbit, ShapeNode::group());
    world
        .shape_mut(moon_pos)
        .set_transform(translation(1.5, 0.3, 0.0));

    let moon_id = world.add_child(moon_pos, ShapeNode::sphere());
    world
        .shape_mut(moon_id)
        .set_transform(scaling(0.3, 0.3, 0.3));
    world.shape_mut(moon_id).material.color = Color::new(0.7, 0.7, 0.7);
    world.shape_mut(moon_id).material.diffuse = 0.6;

    let mut camera = Camera::new(400, 300, PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 5.0, -10.0),
        Point::new(0.0, 0.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    let start = Instant::now();
    let canvas = camera.render(&world);
    println!("  Rendered in {:.2}s", start.elapsed().as_secs_f64());
    std::fs::write("nested_groups_demo.ppm", canvas.to_ppm()).unwrap();
    println!("  Wrote nested_groups_demo.ppm");
    separator();
}
