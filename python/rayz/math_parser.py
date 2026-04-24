"""Parse math expressions used in Gherkin step text.

Handles: plain numbers, √n, √n/d, -√n/d, π, π/d, infinity, -infinity,
EPSILON, EPSILON/2, -EPSILON/2.
"""

import math
import re

from rayz.constants import EPSILON


def parse_math(text: str) -> float:
    text = "".join(text.split())  # normalize: "π / 4" → "π/4"

    if text == "infinity":
        return float("inf")
    if text == "-infinity":
        return float("-inf")
    if text == "EPSILON":
        return EPSILON
    if text == "EPSILON/2":
        return EPSILON / 2
    if text == "-EPSILON/2":
        return -EPSILON / 2

    sqrt_match = re.fullmatch(r"(-?)√(\d+)(?:/(\d+))?", text)
    if sqrt_match:
        sign = -1.0 if sqrt_match.group(1) == "-" else 1.0
        radicand = float(sqrt_match.group(2))
        divisor = float(sqrt_match.group(3)) if sqrt_match.group(3) else 1.0
        return sign * math.sqrt(radicand) / divisor

    pi_match = re.fullmatch(r"π(?:/(\d+))?", text)
    if pi_match:
        divisor = float(pi_match.group(1)) if pi_match.group(1) else 1.0
        return math.pi / divisor

    # Plain integer fraction like -160/532 or 105/532
    frac_match = re.fullmatch(r"(-?\d+)/(\d+)", text)
    if frac_match:
        return float(frac_match.group(1)) / float(frac_match.group(2))

    return float(text)
