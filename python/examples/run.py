"""Runner: execute chapter examples by number or run all.

Usage (from python/):
    uv run examples/run.py          # all chapters
    uv run examples/run.py all      # all chapters (explicit)
    uv run examples/run.py 1        # chapter 1 only
    uv run examples/run.py 2 3      # chapters 2 and 3
"""

import sys

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

CHAPTERS: dict[int, tuple[str, object]] = {
    1: ("Projectile physics", ch1),
    2: ("Canvas & PPM export", ch2),
    3: ("Matrices", ch3),
    4: ("Transformations", ch4),
    5: ("Ray-sphere intersections", ch5),
    6: ("Light and Shading", ch6),
    7: ("Making a Scene", ch7),
    8: ("Patterns and Planes", ch8),
    9: ("Planes", ch9),
    10: ("Reflection and Refraction", ch10),
    11: ("Cubes", ch11),
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
                print(f"Unknown chapter: {a!r}  (valid: {sorted(CHAPTERS)})")
                sys.exit(1)

    for n in targets:
        if n not in CHAPTERS:
            print(f"Chapter {n} not yet implemented.")
            continue
        _name, fn = CHAPTERS[n]
        fn()


if __name__ == "__main__":
    main()
