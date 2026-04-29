
## The llvm-bindings package

See the elementary example [examples/hello-llvm-bindings.mjs](/examples/hello-llvm-bindings.mjs) of how to use llvm-bindings to create a function that adds two integers and returns the result.

Be sure to set the LLVM version before running this example to LLVM@14:

                source ./llvm-version.sh 14

Then run the example with:

                node examples/hello-llvm-bindings.mjs

This will print the following LLVM IR code:

```ll
        ; ModuleID = 'demo'
        source_filename = "demo"

        define i32 @add(i32 %0, i32 %1) {
        entry:
        %2 = add i32 %0, %1
        ret i32 %2
        }
``` 

### Installing LLVM on macOS:

The installation of `llvm-bindings` was complicated. The version of llvm that must be installed is 14.

```
brew install cmake llvm@14
npm install llvm-bindings
```

You could try a "custom" installation:

```
https://github.com/ApsarasX/llvm-bindings?tab=readme-ov-file#custom-llvm-installation
```

### Brew notes after installing llvm@14

```
To use the bundled libc++ please add the following LDFLAGS:
  LDFLAGS="-L/usr/local/opt/llvm@14/lib/c++ -Wl,-rpath,/usr/local/opt/llvm@14/lib/c++"

llvm@14 is keg-only, which means it was not symlinked into /usr/local, because this is an alternate version of another formula.

If you need to have llvm@14 first in your PATH, run:
  echo 'export PATH="/usr/local/opt/llvm@14/bin:$PATH"' >> /Users/casianorodriguezleon/.zshrc

For compilers to find llvm@14 you may need to set:
  export LDFLAGS="-L/usr/local/opt/llvm@14/lib"
  export CPPFLAGS="-I/usr/local/opt/llvm@14/include"

For cmake to find llvm@14 you may need to set:
  export CMAKE_PREFIX_PATH="/usr/local/opt/llvm@14"
==> Summary
🍺  /usr/local/Cellar/llvm@14/14.0.6: 5,831 files, 1GB
==> Running `brew cleanup llvm@14`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
```

### Script to set LLVM version

I have both LLVM 14 and LLVM 21 installed. I created a [script llvm-version.sh](/llvm-version.sh) to set the environment variables for the desired version:

```zsh
➜  hello-llvm git:(main) cat llvm-version.sh
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
```

### Error installing llvm-bindings with LLVM 21

When trying to install `llvm-bindings` with LLVM version 21, I got the following error:

```
➜  complect git:(main) npm i
npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
npm warn deprecated rimraf@2.7.1: Rimraf versions prior to v4 are no longer supported
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
npm warn deprecated gauge@1.2.7: This package is no longer supported.
npm warn deprecated npmlog@1.2.1: This package is no longer supported.
npm warn deprecated are-we-there-yet@1.0.6: This package is no longer supported.
npm warn deprecated fstream@1.0.12: This package is no longer supported.
npm error code 1
npm error path /Users/casianorodriguezleon/campus-virtual/2526/learning/llvm-learning/complect/node_modules/llvm-bindings
npm error command failed
npm error command sh -c cmake-js compile
```

See issue:

https://github.com/ApsarasX/llvm-bindings/issues/54

> Hey, if you are still looking at this for an answer, you could run `$env:CMAKE_PREFIX_PATH="C:\Users\risharan\scoop\apps\llvm\current\lib\cmake\llvm"` and then run npm install. You can look at the cmake (not cmake-js) documentation for details the CMAKE_PREFIX_PATH env variable.


### llvm-bindings in Codespaces

In the end, with LLVM 14 it seems the installation completes.

I tried it in a GitHub Codespace and it did not work.

You cannot install LLVM 14 directly with apt on Ubuntu 24.04 (noble) because the repository does not exist. You must compile from source, use packages from another version, or use a container.

See section [/docs/installing/github-codespaces.md](/docs/installing/github-codespaces.md)
and section [/docs/installing/README.md](/docs/installing/README.md).
