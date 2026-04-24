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

CHAPTERS: dict[int, tuple[str, object]] = {
    1: ("Projectile physics", ch1),
    2: ("Canvas & PPM export", ch2),
    3: ("Matrices", ch3),
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
