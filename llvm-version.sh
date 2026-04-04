# Read argument from command line. If it is 14 then set the environment variables for llvm@14, otherwise 
# set to 21
# Execute this script in the terminal with `source llvm-version.sh 14` or `source llvm-version.sh 21` to set the environment variables for the desired LLVM version.

# If not 14 or 21 print help message
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ] || [ "$1" != "14" ] && [ "$1" != "21" ]; then
  echo "Usage: source llvm-version.sh [14|21]"
  return
fi
if [ "$1" = "14" ]; then
  LLVM_ADD="/usr/local/opt/llvm@14"
  LLVM_REMOVE="/usr/local/opt/llvm@21"
else
  LLVM_ADD="/usr/local/opt/llvm@21"
  LLVM_REMOVE="/usr/local/opt/llvm@14"
fi

# Remove the other version and any duplicate of the target from PATH, then prepend
PATH=$(echo "$PATH" | tr ':' '\n' | grep -vF "$LLVM_REMOVE/bin" | grep -vF "$LLVM_ADD/bin" | tr '\n' ':' | sed 's/:$//')
export PATH="$LLVM_ADD/bin:$PATH"

LDFLAGS=$(echo "$LDFLAGS" | tr ' ' '\n' | grep -vF "$LLVM_REMOVE/lib" | grep -vF "$LLVM_ADD/lib" | tr '\n' ' ' | sed 's/ $//')
export LDFLAGS="$LDFLAGS -L$LLVM_ADD/lib"

CPPFLAGS=$(echo "$CPPFLAGS" | tr ' ' '\n' | grep -vF "$LLVM_REMOVE/include" | grep -vF "$LLVM_ADD/include" | tr '\n' ' ' | sed 's/ $//')
export CPPFLAGS="$CPPFLAGS -I$LLVM_ADD/include"

export CMAKE_PREFIX_PATH="$LLVM_ADD"