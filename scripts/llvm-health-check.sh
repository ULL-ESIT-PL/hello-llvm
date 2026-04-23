#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

OS_TYPE="$(uname -s)"
echo "[check] Platform: $OS_TYPE"
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

if [[ "$OS_TYPE" == "Linux" ]]; then
  echo "[check] Detected Linux (Codespaces environment)"
  COMPILE_CMD=(clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f)
elif [[ "$OS_TYPE" == "Darwin" ]]; then
  echo "[check] Detected macOS local environment"
  echo "[info] For macOS, ensure you have sourced llvm-version.sh with a recent LLVM:"
  echo "[info]   source llvm-version.sh 21"
  COMPILE_CMD=(clang examples/factorial-main.ll examples/factorial.ll -o tmp/f)
else
  echo "[error] Unsupported OS: $OS_TYPE"
  exit 1
fi

echo "[check] Compiling factorial example..."
"${COMPILE_CMD[@]}"

echo "[check] Running tmp/f..."
OUTPUT="$(./tmp/f | tr -d '\r')"

if [[ "$OUTPUT" != "120" ]]; then
  echo "[error] Unexpected output from tmp/f: '$OUTPUT' (expected '120')"
  exit 1
fi

echo "[ok] Health check passed (factorial output: 120)"
