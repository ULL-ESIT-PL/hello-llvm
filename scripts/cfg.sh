#!/bin/bash
#  Script to generate CFGs
# Usage: scripts/cfg.sh examples/malloc-free-array.ll
# Output: tmp/cfg.png 
# It will call opt to generate the CFG in dot format, then use dot to convert it to png, and finally open the image.
# opt -passes=dot-cfg examples/malloc-free-array.ll -disable-output
# Writing '.main.dot'...
# dot -Tpng .main.dot -o tmp/cfg.png
# open tmp/cfg.png 

if [ -z "$1" ]; then
  echo "Usage: $0 <input.ll>"
  exit 1
fi
INPUT="$1"
OUTPUT="tmp/cfg.png"
# Generate CFG in dot format
opt -passes=dot-cfg "$INPUT" -disable-output
# Find the generated .dot file (it will be named like .<function>.dot, for example .main.dot)
DOT_FILE=$(ls .*.dot | head -n 1)
if [ -z "$DOT_FILE" ]; then
  echo "Error: no .dot file generated"
  exit 1
fi
# Convert .dot to .png
dot -Tpng "$DOT_FILE" -o "$OUTPUT"
# Open the image
open "$OUTPUT"
