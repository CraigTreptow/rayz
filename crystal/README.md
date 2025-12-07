# Rayz - Crystal Implementation

This is a Crystal port of the Ruby ray tracer implementation. Crystal's static typing and native compilation provide significant performance improvements while maintaining similar syntax to Ruby.

## Installation

### Install Crystal

```bash
# On macOS
brew install crystal

# On Ubuntu/Debian
curl -fsSL https://crystal-lang.org/install.sh | sudo bash

# Or use mise (recommended for project consistency)
mise install crystal@latest
```

### Install Dependencies

```bash
cd crystal
shards install
```

## Building

```bash
# Development build
crystal build src/rayz.cr

# Optimized release build
crystal build --release src/rayz.cr

# Run without building executable
crystal run src/rayz.cr
```

## Running Examples

```bash
# Run all chapters
crystal run examples/run_all.cr

# Run specific chapter (optimized)
crystal run --release examples/chapter1.cr

# Run from project root
./rayz crystal 7  # Run chapter 7 in Crystal
```

## Performance

Crystal provides significant performance improvements over Ruby:
- **Compilation**: Crystal compiles to native code (vs Ruby's interpreted bytecode)
- **Static typing**: Enables compile-time optimizations
- **No GIL**: True parallelism for multi-core rendering
- **Expected speedup**: 10-50x faster than Ruby (even with YJIT)

See the main README for detailed benchmark comparisons.

## Running Tests

```bash
# Run all specs
crystal spec

# Run specific spec file
crystal spec spec/tuple_spec.cr

# Run with verbose output
crystal spec --verbose
```

## Development

The Crystal implementation mirrors the Ruby structure:
- `src/rayz/` - Core library classes
- `examples/` - Chapter demonstration scripts
- `spec/` - Crystal specs (equivalent to Ruby's Cucumber tests)

Key differences from Ruby:
- **Type annotations**: Crystal requires type declarations
- **Null safety**: Use union types (`T | Nil`) instead of Ruby's nil
- **No monkey patching**: Crystal doesn't allow reopening classes
- **Compile-time**: Errors caught at compilation, not runtime
