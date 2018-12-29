# Rayz
[![Build Status](https://travis-ci.org/CraigTreptow/rayz.svg?branch=master)](https://travis-ci.org/CraigTreptow/rayz)
[![Coverage Status](https://coveralls.io/repos/github/CraigTreptow/rayz/badge.svg?branch=master)](https://coveralls.io/github/CraigTreptow/rayz?branch=master)
[![CircleCI](https://circleci.com/gh/CraigTreptow/rayz/tree/master.svg?style=svg)](https://circleci.com/gh/CraigTreptow/rayz/tree/master)

An implementation of a ray tracer based on the ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book in Elixir.

### Plan

1. Make it work.
1. Make it work better.
1. Make it work faster.

## Current Status

I intend to implement most everything by myself initially.  Then, in the future, 
I may use libraries such as [graphmath](https://github.com/crertel/graphmath) or others 
for speed, or simply ease of use.  There are libraries for faster 
[matrix math](https://github.com/versilov/matrex) for instance.


- Can color pixels on a canvas
- Can produces rayz.ppm from a canvas
- Contains a Cannon module that uses `Point`s and `Vector`s to fire a projectile

## TODO
- [X] Configure CI
- [X] Better description
- [X] Convert Cucumber to `ExUnit` (nope, too much work)
- [X] Limit lines in PPM to 70 characters
- [ ] Make use of more `ExUnit` features, such as [`describe`](https://hexdocs.pm/ex_unit/ExUnit.Case.html)
