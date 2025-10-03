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

Execute all chapter demonstrations:
```bash
ruby rayz
```

This will run demonstrations from all implemented chapters and generate output files.

## Testing

Run all tests:
```bash
bundle exec cucumber
```

Run specific feature tests:
```bash
bundle exec cucumber features/matrices.feature
bundle exec cucumber features/tuples.feature
```

## Formatting

`bundle exec standardrb`

## Troubleshooting

### zlib LoadError
If you encounter `LoadError: cannot load such file -- zlib` when running bundle:

1. Install zlib development package:
   ```bash
   sudo apt update && sudo apt install zlib1g-dev
   ```

2. Reinstall Ruby to pick up the zlib library:
   ```bash
   mise uninstall ruby 3.4.5
   mise install ruby 3.4.5
   ```

3. Try `bundle` again.

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
## Chapter 2 - Canvas and Projectile Visualization

A projectile is shot and its trajectory is plotted on a canvas, demonstrating:
- Canvas creation and pixel manipulation
- Color operations
- PPM file format export
- Parallel pixel writing with async operations

**Output:** `chapter2.ppm` - A 900×550 pixel image showing the projectile's arc

**Example output:**
```
Calculating projectile trajectory...Projectile hit the ground after 197 ticks.
Writing pixels in parallel...Pixels written.
Writing PPM to chapter2.ppm...Done
```

## Chapter 3 - Matrix Operations and Transformations

Demonstrates matrix operations and transformations, including:
- Matrix construction, transpose, and determinant
- Matrix multiplication and inversion
- Verification that A × inverse(A) = Identity
- Visual demonstration: clock face using rotation matrices

**Output:** `chapter3_clock.ppm` - A 400×400 pixel image showing 12 hour marks positioned using 3D rotation matrices

**Example output:**
```
=== Chapter 3: Matrices ===
Demonstrating matrix operations and transformations

1. Basic Matrix Operations
----------------------------------------
Original Matrix M:
  [ 1.00   2.00   3.00   4.00]
  [ 5.00   6.00   7.00   8.00]
  ...

2. Matrix Inversion
----------------------------------------
Matrix A:
  [ 3.00  -9.00   7.00   3.00]
  ...
Inverse of A:
  [-0.07821  -0.04833   0.08875  -0.28910]
  ...
Verification: A * inverse(A) = Identity
  [ 1.00000   0.00000   0.00000   0.00000]
  ...

3. Clock Face Visualization
----------------------------------------
Drawing a clock using rotation matrices...
Writing clock face to chapter3_clock.ppm... Done!
```

## Viewing Output Files

The generated `.ppm` files can be viewed with most image viewers or converted to other formats:

```bash
# View with ImageMagick
display chapter3_clock.ppm

# Convert to PNG
convert chapter3_clock.ppm chapter3_clock.png

# Copy to Windows (WSL users)
cp chapter3_clock.ppm /mnt/c/Users/YourUsername/
```
