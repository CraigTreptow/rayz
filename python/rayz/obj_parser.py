from __future__ import annotations

from rayz.group import Group
from rayz.smooth_triangle import SmoothTriangle
from rayz.triangle import Triangle
from rayz.tuple import Point, Vector


class OBJParser:
    def __init__(self) -> None:
        self.ignored_lines = 0
        self.vertices: list = [None]  # 1-based indexing
        self.normals: list = [None]  # 1-based indexing
        self.default_group = Group()
        self.groups: dict[str, Group] = {}
        self._current_group = self.default_group

    def parse(self, content: str) -> OBJParser:
        for line in content.splitlines():
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            cmd = parts[0]
            if cmd == "v":
                self.vertices.append(Point(float(parts[1]), float(parts[2]), float(parts[3])))
            elif cmd == "vn":
                self.normals.append(Vector(float(parts[1]), float(parts[2]), float(parts[3])))
            elif cmd == "f":
                self._parse_face(parts[1:])
            elif cmd == "g":
                name = parts[1]
                grp = Group()
                self.groups[name] = grp
                self._current_group = grp
            else:
                self.ignored_lines += 1
        return self

    def group(self, name: str) -> Group:
        return self.groups[name]

    def _parse_face(self, specs: list[str]) -> None:
        vdata = []
        for spec in specs:
            parts = spec.split("/")
            vi = int(parts[0])
            ni = int(parts[2]) if len(parts) > 2 and parts[2] else None
            vdata.append((vi, ni))
        for i in range(1, len(vdata) - 1):
            p1 = self.vertices[vdata[0][0]]
            p2 = self.vertices[vdata[i][0]]
            p3 = self.vertices[vdata[i + 1][0]]
            n0, ni_, ni1 = vdata[0][1], vdata[i][1], vdata[i + 1][1]
            if n0 and ni_ and ni1:
                tri = SmoothTriangle(p1, p2, p3, self.normals[n0], self.normals[ni_], self.normals[ni1])
            else:
                tri = Triangle(p1, p2, p3)
            self._current_group.add_child(tri)


def parse_obj_file(content: str) -> OBJParser:
    return OBJParser().parse(content)


def obj_to_group(parser: OBJParser) -> Group:
    g = Group()
    if parser.default_group.children:
        g.add_child(parser.default_group)
    for named in parser.groups.values():
        g.add_child(named)
    return g
