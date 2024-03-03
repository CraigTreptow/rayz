from rayz.canvas import *
from rayz.color import *
from rayz.point import *
from rayz.vector import *

class Chapter2:
    """
    A projectile is an object in motion, affected by gravity and wind.
    The path of the projectile is plotted on a canvas.
    """

    @classmethod
    def run(cls):
        start = Point(0, 1, 0)
        velocity = Vector(1, 1.8, 0).normalize().scalar_mult(11.25)
        gravity = Vector(0, -0.1, 0)
        wind = Vector(-0.01, 0, 0)
        canvas = Canvas(width=900, height=550)

        # projectile starts one unit above the origin.
        # velocity is normalized to 1 unit/tick.
        projectile = {
            "position": start,
            "velocity": velocity
            }

        # gravity -0.1 unit/tick, and wind is -0.01 unit/tick.​​
        environment = {
            "gravity": gravity,
            "wind": wind
            }

        cls.tick(canvas, 0, environment, projectile)

        with open("projectile.ppm", "w") as writer:
          writer.write(canvas.to_ppm())

    @classmethod
    def tick(cls, canvas, count, env, proj):
        """
        Then, run tick repeatedly until the projectile's y position is less than or equal to 0.
        Report the projectile's position after each tick, and the number of ticks it takes for the projectile to hit the ground.
        """
        red = Color(red=1, green=0, blue=0)
        new_position = (proj["position"] + proj["velocity"])
        new_velocity = (proj["velocity"] + env["gravity"] + env["wind"])
        new_projectile = {"position": new_position, "velocity": new_velocity}
        canvas.write_pixel(x=0, y=0, color=red)
        new_x = int(round(new_position.x))
        new_y = int(round(canvas.height - new_position.y))
        if new_x >= 0 and new_x < canvas.width and new_y >= 0 and new_y < canvas.height:
            canvas.write_pixel(x=new_x, y=new_y, color=red)

        if new_position.y <= 0:
            print(f"Projectile hit the ground after {count} ticks.")
            return
        else:
            cls.tick(canvas, count+1, env, new_projectile)
