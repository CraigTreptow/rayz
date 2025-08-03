# Rayz

An implementation of a ray tracer based on the ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book in Ruby.

## Installation

This project requires Ruby 3.4+ and several system dependencies for proper gem compilation.

### Prerequisites

**Install required system libraries:**

Using **apt-get** (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install -y zlib1g-dev libssl-dev libreadline-dev libyaml-dev libffi-dev build-essential
```

Using **brew** (macOS/Linux):
```bash
brew install zlib openssl readline libyaml libffi
```

### Ruby Version Management

This project uses [mise-en-place](https://mise.jdx.dev/) to manage the Ruby version.

**Install mise:**
```bash
# macOS/Linux with brew
brew install mise

# Or with curl
curl https://mise.jdx.dev/install.sh | sh
```

**Install Ruby and dependencies:**
```bash
# Install the specified Ruby version
mise install

# Install Ruby gems
bundle install
```

**Alternative: Manual Ruby Installation**

If not using mise, ensure you have Ruby 3.4+ installed with the system libraries above, then run:
```bash
gem install bundler
bundle install
```

## Running

`ruby rayz`

## Testing

`bundle exec cucumber`

## Formatting

`bundle exec standardrb`

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

`ruby rayz.rb && cp chapter2.ppm /mnt/c/Users/craig`

```
Projectile hit the ground after 16 ticks.
Shooting projectile...Projectile hit the ground after 197 ticks.
Writing PPM to chapter2.ppm...Done
```
