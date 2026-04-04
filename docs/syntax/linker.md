# Linking LLVM IR Modules

In LLVM, you can have multiple IR modules (files) that define different functions and global variables. To create a complete program, you often need to link these modules together. The LLVM linker (`llvm-link`) is a tool that merges multiple LLVM IR files into a single module.

Link at LLVM IR level first, then build executable
```bash
llvm-link examples/factorial-main.ll examples/factorial.ll -o tmp/combined.ll
clang tmp/combined.ll -o tmp/f
```

Let clang do it directly from multiple IR files
```bash
clang examples/factorial-main.ll examples/factorial.ll -o tmp/f
```

So:
- llvm-link merges modules into one LLVM module. The linker resolves references between the modules, so if `a.ll` calls a function defined in `b.ll`, the linker will connect them.

- clang can absolutely be used for linking, and in practice it is usually the easiest driver.

- If you go through `llc` (producing `.s`), then use `clang` for final link:
  
    ```bash
    llc a.ll -o a.s
    llc b.ll -o b.s
    clang a.s b.s -o prog
    ```