# Rayz

An implementation of a ray tracer based on the ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book in Python.

## Set Up

1. `source venv/bin/activate`
1. `pip install -r requirements.txt`

## Running

`python -m rayz`

## Testing

`behave`

_Note_: If you need print output while these are running, the `behave.ini` is configured to allow it, but you will also need to run with the `--no-color` option.
_Note_: Even easier than the above is the add a couple of lines to all output, then behave will get rid of them and you can see the output *and* the color.

## Linting

`ruff check .`

## Grid

The canvas is a grid of pixels.  The grid is defined by the number of rows and columns.  The rows are the Y axis and the columns are the X axis.
The origin is the bottom left corner of the grid.  The X axis increases to the right and the Y axis increases up.

R(y)
.
.
.
3
2
1
0  1  2  3 ... C (x)

## Chapter 1

A projectile is shot and the position is reported until it hits the ground.

```
Position at tick 000 -> X:   0.707  Y:   1.707  Z:   0.000
Position at tick 001 -> X:   1.404  Y:   2.314  Z:   0.000
Position at tick 002 -> X:   2.091  Y:   2.821  Z:   0.000
Position at tick 003 -> X:   2.768  Y:   3.228  Z:   0.000
Position at tick 004 -> X:   3.436  Y:   3.536  Z:   0.000
Position at tick 005 -> X:   4.093  Y:   3.743  Z:   0.000
Position at tick 006 -> X:   4.740  Y:   3.850  Z:   0.000
Position at tick 007 -> X:   5.377  Y:   3.857  Z:   0.000
Position at tick 008 -> X:   6.004  Y:   3.764  Z:   0.000
Position at tick 009 -> X:   6.621  Y:   3.571  Z:   0.000
Position at tick 010 -> X:   7.228  Y:   3.278  Z:   0.000
Position at tick 011 -> X:   7.825  Y:   2.885  Z:   0.000
Position at tick 012 -> X:   8.412  Y:   2.392  Z:   0.000
Position at tick 013 -> X:   8.989  Y:   1.799  Z:   0.000
Position at tick 014 -> X:   9.557  Y:   1.107  Z:   0.000
Position at tick 015 -> X:  10.114  Y:   0.314  Z:   0.000
Position at tick 016 -> X:  10.661  Y:  -0.579  Z:   0.000
Projectile hit the ground after 16 ticks.
```
## Chapter 2

A projectile is shot and the position is reported until it hits the ground.
The path of the projectile is plotted on a canvas.

Run example:

`python -m rayz && cp projectile.ppm /mnt/c/Users/craig`
