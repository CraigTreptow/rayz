#!/bin/bash
# Auto-rebuild Crystal binary if source files are newer than binary

BIN_FILE="bin/rayz"
NEEDS_REBUILD=false

# Check if binary exists
if [ ! -f "$BIN_FILE" ]; then
  NEEDS_REBUILD=true
else
  # Check if any source file is newer than binary
  if [ -n "$(find src -name '*.cr' -newer $BIN_FILE)" ] || \
     [ -n "$(find examples -name '*.cr' -newer $BIN_FILE 2>/dev/null)" ]; then
    NEEDS_REBUILD=true
  fi
fi

# Rebuild if needed
if [ "$NEEDS_REBUILD" = true ]; then
  echo "⚙️  Rebuilding Crystal binary (source files changed)..."
  make release > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "✅ Build complete"
  else
    echo "❌ Build failed"
    exit 1
  fi
fi
