# Read argument from command line. If it is 14 then set the environment variables for llvm@14, otherwise 
# set to 21
# Execute this script in the terminal with `source llvm-version.sh 14` or `source llvm-version.sh 21` to set the environment variables for the desired LLVM version.

safe_return_or_exit() {
  return "$1" 2>/dev/null || exit "$1"
}

remove_from_colon_path() {
  local value="$1"
  local remove_a="$2"
  local remove_b="$3"

  echo "$value" | tr ':' '\n' | grep -vF "$remove_a" | grep -vF "$remove_b" | tr '\n' ':' | sed 's/:$//'
}

remove_from_space_flags() {
  local value="$1"
  local remove_a="$2"
  local remove_b="$3"

  echo "$value" | tr ' ' '\n' | grep -vF "$remove_a" | grep -vF "$remove_b" | tr '\n' ' ' | sed 's/ $//'
}

# If not 14 or 21 print help message
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ] || { [ "$1" != "14" ] && [ "$1" != "21" ]; }; then
  echo "Usage: source llvm-version.sh [14|21]"
  safe_return_or_exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is not installed or not in PATH."
  safe_return_or_exit 1
fi

BREW_PREFIX=$(brew --prefix)
if [ -z "$BREW_PREFIX" ]; then
  echo "Error: Could not detect Homebrew prefix."
  safe_return_or_exit 1
fi

if [ "$1" = "14" ]; then
  LLVM_ADD="$BREW_PREFIX/opt/llvm@14"
  LLVM_REMOVE="$BREW_PREFIX/opt/llvm@21"
else
  LLVM_ADD="$BREW_PREFIX/opt/llvm@21"
  LLVM_REMOVE="$BREW_PREFIX/opt/llvm@14"
fi

if [ ! -d "$LLVM_ADD" ]; then
  echo "Error: $LLVM_ADD does not exist. Install llvm@$1 with Homebrew first."
  safe_return_or_exit 1
fi
# See https://github.com/cucapra/node-llvmc/tree/master For the node-llvm binding to work, If you build LLVM yourself, set LLVM_BUILD_LLVM_DYLIB=On to get the shared library
export LLVM_BUILD_LLVM_DYLIB=On
# Use platform-specific dynamic library path variable.
case "$(uname -s)" in
  Darwin)
    DYLD_LIBRARY_PATH=$(remove_from_colon_path "$DYLD_LIBRARY_PATH" "$LLVM_REMOVE/lib" "$LLVM_ADD/lib")
    export DYLD_LIBRARY_PATH="$LLVM_ADD/lib:$DYLD_LIBRARY_PATH"
    ;;
  Linux)
    LD_LIBRARY_PATH=$(remove_from_colon_path "$LD_LIBRARY_PATH" "$LLVM_REMOVE/lib" "$LLVM_ADD/lib")
    export LD_LIBRARY_PATH="$LLVM_ADD/lib:$LD_LIBRARY_PATH"
    ;;
esac
# Remove the other version and any duplicate of the target from PATH, then prepend
PATH=$(remove_from_colon_path "$PATH" "$LLVM_REMOVE/bin" "$LLVM_ADD/bin")
export PATH="$LLVM_ADD/bin:$PATH"

LDFLAGS=$(remove_from_space_flags "$LDFLAGS" "$LLVM_REMOVE/lib" "$LLVM_ADD/lib")
export LDFLAGS="$LDFLAGS -L$LLVM_ADD/lib"

CPPFLAGS=$(remove_from_space_flags "$CPPFLAGS" "$LLVM_REMOVE/include" "$LLVM_ADD/include")
export CPPFLAGS="$CPPFLAGS -I$LLVM_ADD/include"

export CMAKE_PREFIX_PATH="$LLVM_ADD"