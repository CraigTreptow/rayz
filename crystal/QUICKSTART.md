# Crystal Quick Start Guide

## One-Time Setup

1. **Install dependencies** (if not done already):
```bash
sudo apt-get install -y pkg-config libssl-dev libpcre3-dev libevent-dev
mise install crystal
```

2. **Build the optimized binary** (one time, or after code changes):
```bash
cd crystal
make release    # Takes ~10-30 seconds
```

This creates `crystal/bin/rayz` - a standalone, highly optimized native binary.

## Daily Usage

### Fastest Way (Recommended for Performance Testing)

```bash
# From project root - automatically uses pre-compiled binary if available
./rayz crystal

# Or run the binary directly
./crystal/bin/rayz
```

**This is the fastest** because:
- Uses pre-compiled optimized binary
- No compilation overhead
- Full LLVM optimizations applied
- Native machine code execution

### When to Rebuild

Rebuild the binary after any code changes:
```bash
cd crystal
make release    # Rebuilds optimized binary
```

### Development Mode (Faster Compilation)

If you're actively developing/testing Crystal code:
```bash
cd crystal

# Fast compile, slower runtime (good for testing changes)
crystal run examples/run_all.cr

# Or with optimizations (slower compile, faster runtime)
crystal run --release examples/run_all.cr
```

## Performance Comparison

| Method | Compile Time | Runtime Speed | When to Use |
|--------|--------------|---------------|-------------|
| `./crystal/bin/rayz` | 0s (pre-compiled) | **Fastest** | Benchmarking, final runs |
| `crystal run --release` | ~10-30s every time | Fast | Quick testing with optimizations |
| `crystal run` | ~5-10s every time | Medium | Development, rapid iteration |

## Workflow Summary

```bash
# Step 1: Build once (after setup or code changes)
cd crystal && make release

# Step 2: Run many times (no recompilation)
cd .. && ./rayz crystal
./rayz crystal    # Run again - instant, no recompile!
./rayz crystal    # Run again - still instant!

# When you change code:
cd crystal && make release    # Rebuild
```

## Current Status

Only core mathematical classes are implemented:
- ✅ Tuple, Point, Vector
- ✅ Color, Canvas
- 🚧 Matrix, Transformations (in progress)
- 📋 Full ray tracer (planned)

The binary currently just prints a placeholder message. Full ray tracing examples coming soon!
