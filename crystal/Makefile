# Makefile for Crystal Rayz ray tracer

.PHONY: all build release run test clean examples

# Default target
all: build

# Development build
build:
	@echo "Building rayz (development)..."
	@crystal build src/rayz.cr -o bin/rayz

# Optimized release build
release:
	@echo "Building rayz (release with optimizations)..."
	@crystal build --release src/rayz.cr -o bin/rayz
	@echo "Release build complete! Binary: bin/rayz"

# Run without building
run:
	@crystal run src/rayz.cr

# Run all tests
test:
	@crystal spec

# Run specific test file
test-file:
	@crystal spec $(FILE)

# Clean build artifacts
clean:
	@rm -rf bin/
	@rm -f examples/*.ppm
	@echo "Cleaned build artifacts and example outputs"

# Run all examples (development mode)
examples:
	@crystal run examples/run_all.cr

# Run all examples (optimized)
examples-release:
	@crystal run --release examples/run_all.cr

# Install dependencies
deps:
	@shards install

# Format code
format:
	@crystal tool format

# Check formatting
format-check:
	@crystal tool format --check

# Help
help:
	@echo "Rayz Crystal Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make build           - Build development binary"
	@echo "  make release         - Build optimized release binary"
	@echo "  make run             - Run without building"
	@echo "  make test            - Run all specs"
	@echo "  make examples        - Run all chapter examples (dev)"
	@echo "  make examples-release - Run all chapter examples (optimized)"
	@echo "  make clean           - Remove build artifacts"
	@echo "  make deps            - Install dependencies"
	@echo "  make format          - Format code"
	@echo "  make help            - Show this help"
