## Main Goal

Create a lab to translate from [Dragon](https://github.com/ULL-ESIT-PL/dragon2js) to LLVM IR.
Related work:

## Related work: The Complect project

See the fork of the [Complect](https://github.com/ULL-ESIT-PL/complect/tree/casiano) project at ULL-ESIT-PL.

The initial implementation of this compiler was created by Jarrod Connolly, (Kabam Games Inc) to support a talk he presented at **OpenJS World 2022**. You can find the contents of this talk here. [Slides](https://static.sched.com/hosted_files/openjsworld2022/78/OpenJSW%20World%202022.pdf) [Video](https://youtu.be/aPHf_-N2yTU)


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

## Informal and Simplistic LLVM IR grammar

``` 
module      ::= (function | global)*

function    ::= 'define' type '@' name '(' params ')' '{' block* '}'

block       ::= label ':' instruction*

instruction ::= assignment | terminator

assignment  ::= '%' name '=' op

op          ::= 'add' type value ',' value
              | 'sub' type value ',' value
              | 'load' type ',' type '*'
              | ...

terminator  ::= 'ret' type value
              | 'br' 'label' '%' name
              | 'br' 'i1' value ',' 'label' '%' name ',' 'label' '%' name
```

- LLVM IR is strongly typed.
- Global symbols begin with an at sign (`@`).
- Local symbols begin with a percent symbol (`%`).
- All symbols must be declared or defined.
- If in doubt, consult the Language Reference Manual: https://llvm.org/docs/LangRef.html

## Running LLVM IR in Compiler Explorer


[Compiler Explorer](https://godbolt.org/) **does** support LLVM IR as a source language. Use LLVM IR as the source language + Clang as compiler. Select:

- **Language: LLVM IR**
- **Compiler: Clang** (any version)

Clang accepts `.ll` files as input and can compile them to a binary. Then if you add an **Executor** pane, it will run the resulting binary — so you effectively write IR and execute it.

This is the closest thing to running IR directly inside Compiler Explorer. 

Given this input:

```ll
@variable = global i32 21
@fmt = constant [4 x i8] c"%d\0A\00"
declare i32 @printf(ptr, ...)
define i32 @main() {
    %1 = load i32, i32* @variable  ; load the global variable
    %2 = mul i32 %1, 2
    store i32 %2, i32* @variable   ; store instruction to write to global variable
    call i32 (ptr, ...) @printf(ptr @fmt, i32 %1)
    ret i32 %2
}
```

to make it work we have the `declare i32 @printf(ptr, ...)` declaration and also a `@main` entry point.

The picture shows the Compiler Explorer interface with LLVM IR code in the left pane, the assembly output in the middle pane, and the execution output in the right pane.


![Running LLVM IR in Compiler Explorer](/docs/images/runningLLVM-IR-on-compiler-explorer.png)


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

* [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)
  * [fanyi-zhao/Kaleidoscope](https://github.com/fanyi-zhao/Kaleidoscope) repo at GitHub
* [Mapping High-Level Constructs to LLVM IR](https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/latest/a-quick-primer/index.html) by Michael Rodler and Mikael Egevig
* [LLVM Language Reference Manual](https://llvm.org/docs/LangRef.html)
* What Is LLVM? https://www.youtube.com/watch?v=HecW5byOrUY&list=PLDSTpI7ZVmVnvqtebWnnI8YeB8bJoGOyv by CompilersLaboratory
* See the list of LLVM videos by Dmitry Soshnikov at https://www.youtube.com/@DmitrySoshnikov-education/search?query=LLVM
  * Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw
* [Compiler Explorer](https://godbolt.org/)
  * [Compiler Explorer (part 1 of 2)](https://www.youtube.com/watch?v=4_HL3PH4wDg&list=PL2HVqYf7If8dNYVN6ayjB06FPyhHCcnhG) by Mat Godbolt
  * [Compiler Explorer | Introduction to Common Compiler Tools #4](https://www.youtube.com/watch?v=0Idx1hiz_Bk) by LLVM Social Bangalore
* [CppInsights](https://cppinsights.io/)
  * C++ Insights at YouTube: Hello, C++ Insights: https://www.youtube.com/watch?v=NhIubRbFfuM&list=PLm0Dc2Lp2ycaFyR2OqPkusuSB8LmifY8D 
* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation)
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf)
* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation)
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf) 
* Jarrod Connolly, (Kabam Games Inc) at **OpenJS World 2022** "Writing a Compiler in Node.js using Streams" 
  * [Github Complect](https://github.com/jarrodconnolly/complect)
  * [Slides](https://static.sched.com/hosted_files/openjsworld2022/78/OpenJSW%20World%202022.pdf) 
  * [Video](https://youtu.be/aPHf_-N2yTU)
* An introduction to LLVM IR: https://youtu.be/CDKuH7SIgdM?si=kDHsuQsNNXo6uDJW by revng 2025
