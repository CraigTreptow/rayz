use crate::matrix::Matrix4;
use crate::point::Point;
use crate::vector::Vector;

pub fn translation(x: f64, y: f64, z: f64) -> Matrix4 {
    Matrix4::new([
        1.0, 0.0, 0.0, x,
        0.0, 1.0, 0.0, y,
        0.0, 0.0, 1.0, z,
        0.0, 0.0, 0.0, 1.0,
    ])
}

pub fn scaling(x: f64, y: f64, z: f64) -> Matrix4 {
    Matrix4::new([
        x,   0.0, 0.0, 0.0,
        0.0, y,   0.0, 0.0,
        0.0, 0.0, z,   0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
}

pub fn rotation_x(radians: f64) -> Matrix4 {
    let c = radians.cos();
    let s = radians.sin();
    Matrix4::new([
        1.0, 0.0,  0.0, 0.0,
        0.0, c,   -s,   0.0,
        0.0, s,    c,   0.0,
        0.0, 0.0,  0.0, 1.0,
    ])
}

pub fn rotation_y(radians: f64) -> Matrix4 {
    let c = radians.cos();
    let s = radians.sin();
    Matrix4::new([
        c,   0.0, s,   0.0,
        0.0, 1.0, 0.0, 0.0,
       -s,   0.0, c,   0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
}

pub fn rotation_z(radians: f64) -> Matrix4 {
    let c = radians.cos();
    let s = radians.sin();
    Matrix4::new([
        c,  -s,   0.0, 0.0,
        s,   c,   0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
}

pub fn shearing(xy: f64, xz: f64, yx: f64, yz: f64, zx: f64, zy: f64) -> Matrix4 {
    Matrix4::new([
        1.0, xy,  xz,  0.0,
        yx,  1.0, yz,  0.0,
        zx,  zy,  1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
}

pub fn view_transform(from: Point, to: Point, up: Vector) -> Matrix4 {
    let forward = (to - from).normalize();
    let left = forward.cross(up.normalize());
    let true_up = left.cross(forward);

    let orientation = Matrix4::new([
        left.x,     left.y,     left.z,     0.0,
        true_up.x,  true_up.y,  true_up.z,  0.0,
       -forward.x, -forward.y, -forward.z,  0.0,
        0.0,        0.0,        0.0,        1.0,
    ]);

    orientation * translation(-from.x, -from.y, -from.z)
}
