pub mod bounds;
pub mod camera;
pub mod canvas;
pub mod color;
pub mod computations;
pub mod intersection;
pub mod light;
pub mod lighting;
pub mod material;
pub mod matrix;
pub mod obj_parser;
pub mod pattern;
pub mod point;
pub mod ray;
pub mod shape;
pub mod transformations;
pub mod util;
pub mod vector;
pub mod world;

pub use bounds::Bounds;
pub use camera::Camera;
pub use canvas::Canvas;
pub use color::Color;
pub use computations::{prepare_computations, schlick, Computations};
pub use intersection::{hit, Intersection};
pub use light::{AreaLight, Light, PointLight, Spotlight};
pub use lighting::lighting;
pub use material::Material;
pub use matrix::Matrix4;
pub use obj_parser::ObjParser;
pub use pattern::{Pattern, PatternData};
pub use point::Point;
pub use ray::Ray;
pub use shape::{
    intersect_shape, normal_at, normal_to_world, world_to_object, CsgOperation, Geometry, ShapeNode,
};
pub use transformations::{
    rotation_x, rotation_y, rotation_z, scaling, shearing, translation, view_transform,
};
pub use util::{approx_eq, EPSILON};
pub use vector::Vector;
pub use world::World;
