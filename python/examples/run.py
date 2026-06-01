"""Runner: execute chapter examples by number or name.

Usage (from python/):
    uv run examples/run.py               # all chapters and demos
    uv run examples/run.py all           # same
    uv run examples/run.py 7             # chapter 7 only
    uv run examples/run.py advanced_features
    uv run examples/run.py bounding_boxes
    uv run examples/run.py nested_groups
    uv run examples/run.py obj_parser
"""

import sys

from examples.advanced_features_demo import run as af_demo
from examples.bounding_boxes_demo import run as bb_demo
from examples.chapter1 import run as ch1
from examples.chapter2 import run as ch2
from examples.chapter3 import run as ch3
from examples.chapter4 import run as ch4
from examples.chapter5 import run as ch5
from examples.chapter6 import run as ch6
from examples.chapter7 import run as ch7
from examples.chapter8 import run as ch8
from examples.chapter9 import run as ch9
from examples.chapter10 import run as ch10
from examples.chapter11 import run as ch11
from examples.chapter12 import run as ch12
from examples.chapter13 import run as ch13
from examples.chapter14 import run as ch14
from examples.chapter15 import run as ch15
from examples.chapter16 import run as ch16
from examples.chapter17 import run as ch17
from examples.nested_groups_demo import run as ng_demo
from examples.obj_parser_demo import run as obj_demo

CHAPTERS: dict[int, tuple[str, object]] = {
    1:  ("Projectile physics", ch1),
    2:  ("Canvas & PPM export", ch2),
    3:  ("Matrices", ch3),
    4:  ("Transformations", ch4),
    5:  ("Ray-sphere intersections", ch5),
    6:  ("Light and Shading", ch6),
    7:  ("Making a Scene", ch7),
    8:  ("Patterns and Planes", ch8),
    9:  ("Planes", ch9),
    10: ("Reflection and Refraction", ch10),
    11: ("Cubes", ch11),
    12: ("Cylinders", ch12),
    13: ("Groups", ch13),
    14: ("Cones", ch14),
    15: ("Triangles", ch15),
    16: ("CSG", ch16),
    17: ("Smooth Triangles", ch17),
    18: ("OBJ Parser Demo", obj_demo),
    19: ("Bounding Boxes Demo", bb_demo),
    20: ("Nested Groups Demo", ng_demo),
    21: ("Advanced Features Demo", af_demo),
}

NAMES: dict[str, int] = {
    "obj_parser":        18,
    "bounding_boxes":    19,
    "nested_groups":     20,
    "advanced_features": 21,
}


def main() -> None:
    args = sys.argv[1:]

    if not args or args == ["all"]:
        targets = sorted(CHAPTERS.keys())
    else:
        targets = []
        for a in args:
            try:
                targets.append(int(a))
            except ValueError:
                if a in NAMES:
                    targets.append(NAMES[a])
                else:
                    valid = f"integers: {sorted(CHAPTERS)}, names: {sorted(NAMES)}"
                    print(f"Unknown chapter: {a!r}  (valid {valid})")
                    sys.exit(1)

    for n in targets:
        if n not in CHAPTERS:
            print(f"Chapter {n} not yet implemented.")
            continue
        _name, fn = CHAPTERS[n]
        fn()


if __name__ == "__main__":
    main()
