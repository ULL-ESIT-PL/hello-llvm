#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "[check] Workspace: $REPO_ROOT"

for cmd in clang llvm-config; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[error] Missing required command: $cmd"
    exit 1
  fi
done

echo "[check] clang: $(clang --version | head -n 1)"
echo "[check] llvm-config: $(llvm-config --version)"

mkdir -p tmp

if [[ "$(uname -s)" == "Linux" ]]; then
  COMPILE_CMD=(clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f)
else
  COMPILE_CMD=(clang examples/factorial-main.ll examples/factorial.ll -o tmp/f)
fi

echo "[check] compiling factorial example..."
"${COMPILE_CMD[@]}"

echo "[check] running tmp/f..."
OUTPUT="$(./tmp/f | tr -d '\r')"

if [[ "$OUTPUT" != "120" ]]; then
  echo "[error] Unexpected output from tmp/f: '$OUTPUT' (expected '120')"
  exit 1
fi

echo "[ok] Health check passed (factorial output: 120)"
