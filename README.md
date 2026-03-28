## Main Goal

Create a lab to translate from [Dragon](https://github.com/ULL-ESIT-PL/dragon2js) to LLVM IR.
Related work:

## Related work: The Complect project

The [Complect](https://github.com/ULL-ESIT-PL/complect/tree/casiano) project.

### The fib example

- Examples in the complect language at folder https://github.com/ULL-ESIT-PL/complect/tree/casiano/fixtures
- Here is the `fib` example:
  ```
  make a 0
  make b 1
  make t 0
  make n 10
  as n > 0
    n = n - 1
    assign t a
    assign a b
    b = b + t
    print a
  repeat
  ```
  
  The command to compile to llvm is:
  ```
  ➜  complect git:(casiano) complect -f fixtures/fib.cplct -b llvm -o fixtures/fib.ll 
  Backend: llvm
  Compiling: fixtures/fib.cplct
  Output: fixtures/fib.ll
  ```
  We can then run the generated llvm code with `lli`:
  ```
  ➜  complect git:(casiano) lli fixtures/fib.ll
  1
  1
  2
  3
  5
  8
  13
  21
  34
  55
  ```

### The sdl-cube example

First, install SDL2. In a macOS system with Homebrew, you can install it with:

```
brew install sdl2
```
Let us check the `sdl2-config` tool to get the correct flags (`--cflags` and `--libs`) for compiling with SDL2:
```
sdl2-config --help
Usage: /usr/local/bin/sdl2-config [--prefix[=DIR]] [--exec-prefix[=DIR]] [--version] [--cflags] [--libs] [--static-libs]
```

Compile the `sdl-cube` example to llvm:

```
➜  complect git:(casiano) complect -f fixtures/sdl-cube.cplct -b llvm -o fixtures/sdl-cube.ll
Backend: llvm
Compiling: fixtures/sdl-cube.cplct
Output: fixtures/sdl-cube.ll
➜  complect git:
```

Compile the generated llvm code to an executable using `clang`:
```
➜  complect git:(casiano) xcrun clang fixtures/sdl-cube.ll -o sdl-cube $(sdl2-config --cflags --libs)
clang: warning: argument unused during compilation: '-I /usr/local/include/SDL2' [-Wunused-command-line-argument]
warning: overriding the module target triple with x86_64-apple-macosx26.0.0
      [-Woverride-module]
```
Explanation:

- `$(sdl2-config --cflags --libs)` adds the correct include and library flags for SDL2.
- `xcrun clang ` ensures clang uses the macOS SDK clang.
- Those warnings are common and not critical:

  **clang: warning**: `argument unused during compilation: '-I /usr/local/include/SDL2'`
  This happens because the -I flag is for C/C++ source files, but we’re compiling LLVM IR (.ll), so the  include path isn’t needed at this stage. It’s safe to ignore.  

  **overriding warning**: `overriding the module target triple with x86_64-apple-macosx26.0.0`
  This means `clang` is using our system’s default target triple instead of what’s in the `.ll` file. It’s just  informational and usually not a problem unless we need a specific target.  
  If we want to suppress the unused -I warning we do:

    ```
    ➜  complect git:(casiano) ✗ sdl2-config --cflags --libs 
    -I/usr/local/include/SDL2 -D_THREAD_SAFE
    -L/usr/local/lib -lSDL2
    ➜  complect git:(casiano) ✗ xcrun clang fixtures/sdl-cube.ll -L/usr/local/lib -lSDL2 -o sdl-cube       
    warning: overriding the module target triple with x86_64-apple-macosx26.0.0 [-Woverride-module]
    1 warning generated.
    ```

This produce an executable `sdl-cube` that can be run with `./sdl-cube` to [see a rotating cube](https://github.com/ULL-ESIT-PL/complect/blob/casiano/rotating.gif).

```
➜  complect git:(casiano) ✗ ls -l sdl-cube 
-rwxr-xr-x@ 1 casianorodriguezleon  staff  13328 28 mar.  13:20 sdl-cube
```


### The RD parser

- Has the RD parser at folder: https://github.com/ULL-ESIT-PL/complect/blob/casiano/lib/ast/ast-builder.js

## The llvm-bindings package

See the elementary example [examples/hello-llvm-bindings.mjs](/examples/hello-llvm-bindings.mjs) of how to use llvm-bindings to create a function that adds two integers and returns the result.

Be sure to set the LLVM version before running this example to LLVM@14:

                source ./llvm-version.sh 14

Then run the example with:

                node examples/hello-llvm-bindings.mjs

This will print the following LLVM IR code:

                ; ModuleID = 'demo'
                source_filename = "demo"

                define i32 @add(i32 %0, i32 %1) {
                entry:
                %2 = add i32 %0, %1
                ret i32 %2
                }


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

I have both LLVM 14 and LLVM 21 installed. I created a script to set the environment variables for the desired version:

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

## Visualizing

Program Visualization using LLVM:

To visualize the Control Flow Graph (CFG)
With LLVM version 21:

```
➜  examples git:(main) ✗ clang -S -emit-llvm -fno-discard-value-names diag.c -o diag.ll
➜  examples git:(main) ✗ opt -passes=dot-cfg diag.ll -disable-output
Writing '.identity.dot'...
examples git:(main) ✗ dot -Tpng .identity.dot -o diag.png
```

Files:

- [diag.c](/examples/diag.c)
- [diag.ll](/examples/diag.ll)
- [.identity.dot](/examples/.identity.dot)
- [diag.png](/docs/images/diag.png) 

![/docs/images/diag.png](/docs/images/diag.png)

A **Control Flow Graph (CFG)** is a graphical representation of all paths that might be traversed through a program during its execution. 

**Key Components**

- **Nodes (Basic Blocks)**: Each node represents a Basic Block—a linear sequence of instructions with one entry point (the first instruction) and one exit point (the last instruction). There are no jumps into or out of the middle of the block.
- **Edges (Control Flow)**: Directed edges represent the flow of control. An edge from Block A to Block B means that Block B can execute immediately after Block A.
- **Entry and Exit**: The graph typically has a unique entry node (where the function starts) and may have one or more exit nodes (return statements or exits)

- Watch https://youtu.be/aFbWIJlcWww?si=JHZ5wDfqHiKO3F1X by CompilersLab

## References

* What Is LLVM? https://www.youtube.com/watch?v=HecW5byOrUY&list=PLDSTpI7ZVmVnvqtebWnnI8YeB8bJoGOyv by CompilersLaboratory
* Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw
* See the list of LLVM videos by Dmitry Soshnikov at https://www.youtube.com/@DmitrySoshnikov-education/search?query=LLVM

