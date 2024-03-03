from rayz.point import *
from rayz.vector import *

class Chapter1:
    """
    A projectile is an object in motion, affected by gravity and wind.
    """

    @classmethod
    def run(cls):
        # projectile starts one unit above the origin.
        # velocity is normalized to 1 unit/tick.
        projectile = {
            "position": Point(0, 1, 0),
            "velocity": Vector(1, 1, 0).normalize()
            }

        # gravity -0.1 unit/tick, and wind is -0.01 unit/tick.​​
        environment = {
            "gravity": Vector(0, -0.1, 0),
            "wind": Vector(-0.01, 0, 0)
            }
        cls.tick(0, environment, projectile)

    @classmethod
    def tick(cls, count, env, proj):
        """
        Then, run tick repeatedly until the projectile's y position is less than or equal to 0.
        Report the projectile's position after each tick, and the number of ticks it takes for the projectile to hit the ground.
        """
        new_position = (proj["position"] + proj["velocity"])
        new_velocity = (proj["velocity"] + env["gravity"] + env["wind"])
        new_projectile = {"position": new_position, "velocity": new_velocity}
        cls.report(count, new_projectile)
        if new_position.y <= 0:
            print(f"Projectile hit the ground after {count} ticks.")
            return
        else:
            cls.tick(count+1, env, new_projectile)

    @classmethod
    def report(cls, count, proj):
        formatted_count = "{:03d}".format(count)
        formatted_x = "{:7.3f}".format(round(proj["position"].x, 3))
        formatted_y = "{:7.3f}".format(round(proj["position"].y, 3))
        formatted_z = "{:7.3f}".format(round(proj["position"].z, 3))
        print(f"Position at tick {formatted_count} -> X: {formatted_x}  Y: {formatted_y}  Z: {formatted_z}")
