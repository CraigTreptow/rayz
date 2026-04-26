from __future__ import annotations


class Computations:
    def __init__(
        self, t, obj, point, eyev, normalv, inside, over_point, reflectv, n1=1.0, n2=1.0, under_point=None
    ):
        self.t = t
        self.object = obj
        self.point = point
        self.eyev = eyev
        self.normalv = normalv
        self.inside = inside
        self.over_point = over_point
        self.reflectv = reflectv
        self.n1 = n1
        self.n2 = n2
        self.under_point = under_point
