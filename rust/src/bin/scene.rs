use rayz::*;
use std::env;
use std::time::Instant;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut scene_name = String::new();
    let mut output_path = String::new();

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--scene" => { i += 1; scene_name = args[i].clone(); }
            "--output" => { i += 1; output_path = args[i].clone(); }
            _ => {}
        }
        i += 1;
    }

    if scene_name.is_empty() || output_path.is_empty() {
        eprintln!("Usage: scene --scene <small|medium|large> --output <path.ppm>");
        std::process::exit(1);
    }

    let dev_mode = env::var("DEV_MODE").as_deref() == Ok("true");
    let parallel = env::var("PARALLEL").as_deref() == Ok("true");

    let (width, height) = if dev_mode {
        match scene_name.as_str() {
            "small"  => (40, 20),
            "medium" => (60, 30),
            "large"  => (100, 50),
            _ => { eprintln!("Unknown scene: {scene_name}"); std::process::exit(1); }
        }
    } else {
        match scene_name.as_str() {
            "small"  => (400, 200),
            "medium" => (600, 300),
            "large"  => (800, 400),
            _ => { eprintln!("Unknown scene: {scene_name}"); std::process::exit(1); }
        }
    };

    let world = build_scene();

    let mut camera = Camera::new(width, height, std::f64::consts::PI / 3.0);
    camera.set_transform(view_transform(
        Point::new(0.0, 1.5, -5.0),
        Point::new(0.0, 1.0, 0.0),
        Vector::new(0.0, 1.0, 0.0),
    ));

    // When parallel is disabled we still use rayon (which auto-selects 1 thread via
    // RAYON_NUM_THREADS=1 if the caller wants sequential behaviour; otherwise multi-threaded).
    // For simplicity we always call render() — the benchmark can set RAYON_NUM_THREADS.
    eprintln!("Rendering {scene_name} ({width}x{height}), parallel={parallel}...");
    let start = Instant::now();
    let canvas = camera.render(&world);
    let elapsed = start.elapsed().as_secs_f64();

    std::fs::write(&output_path, canvas.to_ppm()).expect("Failed to write output");

    let pixels = width * height;
    let pps = (pixels as f64 / elapsed).round() as u64;

    println!(
        r#"{{"scene":"{scene_name}","width":{width},"height":{height},"elapsed":{elapsed:.4},"pixels_per_second":{pps}}}"#
    );
}

fn build_scene() -> World {
    let mut world = World::new();
    world.light = Some(Light::point(
        Point::new(-10.0, 10.0, -10.0),
        Color::WHITE,
    ));

    // Checkers floor
    let floor_id = world.add(ShapeNode::plane());
    {
        let floor = world.shape_mut(floor_id);
        floor.material.pattern = Some(Pattern::checkers(
            Color::new(0.15, 0.15, 0.15),
            Color::new(0.85, 0.85, 0.85),
        ));
        floor.material.ambient = 0.2;
        floor.material.diffuse = 0.8;
        floor.material.specular = 0.0;
        floor.material.reflective = 0.3;
    }

    // Glass sphere
    let glass_id = world.add(ShapeNode::sphere());
    {
        let s = world.shape_mut(glass_id);
        s.set_transform(translation(-1.5, 1.0, 0.0));
        s.material.color = Color::new(0.1, 0.1, 0.1);
        s.material.ambient = 0.0;
        s.material.diffuse = 0.1;
        s.material.specular = 1.0;
        s.material.shininess = 300.0;
        s.material.transparency = 0.9;
        s.material.refractive_index = 1.5;
        s.material.reflective = 0.9;
    }

    // Mirror sphere
    let mirror_id = world.add(ShapeNode::sphere());
    {
        let s = world.shape_mut(mirror_id);
        s.set_transform(translation(1.5, 1.0, 0.0));
        s.material.color = Color::new(0.9, 0.9, 0.9);
        s.material.specular = 1.0;
        s.material.shininess = 300.0;
        s.material.reflective = 0.8;
    }

    // Matte red sphere
    let red_id = world.add(ShapeNode::sphere());
    {
        let s = world.shape_mut(red_id);
        s.set_transform(translation(0.0, 1.0, 1.0));
        s.material.color = Color::new(0.8, 0.3, 0.3);
    }

    // Green closed cylinder
    let cyl_id = world.add({
        let mut cyl = ShapeNode::cylinder();
        if let Geometry::Cylinder { ref mut minimum, ref mut maximum, ref mut closed } = cyl.geometry {
            *minimum = 0.0;
            *maximum = 2.0;
            *closed = true;
        }
        cyl
    });
    {
        let s = world.shape_mut(cyl_id);
        s.set_transform(translation(0.0, 0.0, -1.0) * scaling(0.3, 0.5, 0.3));
        s.material.color = Color::new(0.2, 0.6, 0.2);
        s.material.specular = 0.3;
    }

    world
}
