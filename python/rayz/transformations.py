"""Transformation matrix factories for 3D graphics."""

from __future__ import annotations

import math

from rayz.matrix import Matrix
from rayz.tuple import Vector


def translation(x: float, y: float, z: float) -> Matrix:
    return Matrix(
        [
            [1, 0, 0, x],
            [0, 1, 0, y],
            [0, 0, 1, z],
            [0, 0, 0, 1],
        ]
    )


def scaling(x: float, y: float, z: float) -> Matrix:
    return Matrix(
        [
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1],
        ]
    )


def rotation_x(radians: float) -> Matrix:
    c, s = math.cos(radians), math.sin(radians)
    return Matrix(
        [
            [1, 0, 0, 0],
            [0, c, -s, 0],
            [0, s, c, 0],
            [0, 0, 0, 1],
        ]
    )


def rotation_y(radians: float) -> Matrix:
    c, s = math.cos(radians), math.sin(radians)
    return Matrix(
        [
            [c, 0, s, 0],
            [0, 1, 0, 0],
            [-s, 0, c, 0],
            [0, 0, 0, 1],
        ]
    )


def rotation_z(radians: float) -> Matrix:
    c, s = math.cos(radians), math.sin(radians)
    return Matrix(
        [
            [c, -s, 0, 0],
            [s, c, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1],
        ]
    )


def shearing(xy: float, xz: float, yx: float, yz: float, zx: float, zy: float) -> Matrix:
    return Matrix(
        [
            [1, xy, xz, 0],
            [yx, 1, yz, 0],
            [zx, zy, 1, 0],
            [0, 0, 0, 1],
        ]
    )


def view_transform(from_pt, to_pt, up) -> Matrix:
    diff = to_pt - from_pt
    forward = Vector(diff.x, diff.y, diff.z).normalize()
    upn = Vector(up.x, up.y, up.z).normalize()
    left = forward.cross(upn)
    true_up = left.cross(forward)

    orientation = Matrix(
        [
            [left.x, left.y, left.z, 0],
            [true_up.x, true_up.y, true_up.z, 0],
            [-forward.x, -forward.y, -forward.z, 0],
            [0, 0, 0, 1],
        ]
    )

    return orientation * translation(-from_pt.x, -from_pt.y, -from_pt.z)
