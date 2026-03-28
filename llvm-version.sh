# Read argument from command line. If it is 14 then set the environment variables for llvm@14, otherwise 
# set to 21
# Execute this script in the terminal with `source llvm-version.sh 14` or `source llvm-version.sh 21` to set the environment variables for the desired LLVM version.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: source llvm-version.sh [14|21]"
  return
fi
if [ "$1" = "14" ]; then
  export PATH="/usr/local/opt/llvm@14/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L/usr/local/opt/llvm@14/lib"
  export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/llvm@14/include"
  export CMAKE_PREFIX_PATH="/usr/local/opt/llvm@14"
else
  export PATH="/usr/local/opt/llvm@21/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L/usr/local/opt/llvm@21/lib"
  export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/llvm@21/include"
  export CMAKE_PREFIX_PATH="/usr/local/opt/llvm@21"
fi