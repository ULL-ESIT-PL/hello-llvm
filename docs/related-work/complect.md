
# Related work: The Complect project

See the fork of the [Complect](https://github.com/ULL-ESIT-PL/complect/tree/casiano) project at ULL-ESIT-PL.

The initial implementation of this compiler was created by Jarrod Connolly, (Kabam Games Inc) to support a talk he presented at **OpenJS World 2022**. You can find the contents of this talk here. [Slides](https://static.sched.com/hosted_files/openjsworld2022/78/OpenJSW%20World%202022.pdf) [Video](https://youtu.be/aPHf_-N2yTU)


## The fib example

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

## The sdl-cube example

First, install SDL2. In a macOS system with Homebrew, you can install it with:

```
brew install sdl2
```
Let us check the `sdl2-config` tool to get the correct flags (`--cflags` and `--libs`) for compiling with SDL2:
```
sdl2-config --help
Usage: /usr/local/bin/sdl2-config [--prefix[=DIR]] [--exec-prefix[=DIR]] [--version] [--cflags] [--libs] [--static-libs]
```

Compile [the `sdl-cube` example](https://github.com/ULL-ESIT-PL/complect/blob/casiano/fixtures/sdl-cube.cplct) to llvm:

```
➜  complect git:(casiano) complect -f fixtures/sdl-cube.cplct -b llvm -o fixtures/sdl-cube.ll
Backend: llvm
Compiling: fixtures/sdl-cube.cplct
Output: fixtures/sdl-cube.ll
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


## The RD parser

- Has the RD parser at folder: https://github.com/ULL-ESIT-PL/complect/blob/casiano/lib/ast/ast-builder.js

