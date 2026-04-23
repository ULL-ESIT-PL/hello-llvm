# Running LLVM IR

## Running LLVM IR with Clang 

See files

- [examples/factorial.ll](examples/factorial.ll)
- [examples/factorial-main.ll](examples/factorial-main.ll)

The target triple and data layout in the IR files are set to match my architecture and platform. You may need to adjust them for your system. 

In my machine, I have LLVM 14 and 21 installed. To switch between them, I use the
[llvm-version.sh](llvm-version.sh) script:

```bash
source llvm-version.sh 14  # to use LLVM 14
source llvm-version.sh 21  # to use LLVM 21
```

then compile and link the two IR files with:

```bash
➜  hello-llvm git:(main) ✗ clang examples/factorial-main.ll examples/factorial.ll -o 
tmp/f
➜  hello-llvm git:(main) ✗ tmp/f
120
```

In GitHub Codespaces (Linux), use an explicit Linux target because these sample `.ll` files were generated on macOS:

```bash
clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f
tmp/f
```

If you skip `--target` in Linux, you may get linker errors like `ld: library 'System' not found`.

### Linking LLVM IR Modules

See section [/docs/syntax/linker.md](/docs/syntax/linker.md)

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


