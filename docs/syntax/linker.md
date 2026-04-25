# Linking LLVM IR Modules

In LLVM, you can have multiple IR modules (files) that define different functions and global variables. To create a complete program, you often need to link these modules together. The LLVM linker (`llvm-link`) is a tool that merges multiple LLVM IR files into a single module.

Link at LLVM IR level first, then build executable
```bash
llvm-link examples/factorial-main.ll examples/factorial.ll -o tmp/combined.ll
```
Then compile the combined IR to an executable:
```
clang tmp/combined.ll -o tmp/f
```

Let clang do it directly from multiple IR files
```bash
clang examples/factorial-main.ll examples/factorial.ll -o tmp/f
```

On Linux/Codespaces, these sample `.ll` files may need an explicit Linux target because they were generated on macOS:

```bash
clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f
```

So:
- [llvm-link](https://llvm.org/docs/CommandGuide/llvm-link.html) merges modules into one LLVM module. The linker resolves references between the modules, so if `a.ll` calls a function defined in `b.ll`, the linker will connect them.

- clang can absolutely be used for linking, and in practice it is usually the easiest driver.

- If you go through [llc](https://llvm.org/docs/CommandGuide/llc.html) (producing `.s`), then use `clang` for final link:
  
    ```bash
    llc examples/factorial.ll -o tmp/factorial.s
    llc examples/factorial-main.ll -o tmp/factorial-main.s 
    clang tmp/factorial-main.s tmp/factorial.s -o tmp/f
    ```

## Example

The following example is the translation of the Dragon source code:


`➜  dragon2js git:(LLVM-simple-factorized) cat examples/char/charsum.drg`
```C  
{
    print("hello" + " world!"); // Since we rely on JS it will concatenate
}
```

```
➜  dragon2js git:(LLVM-simple-factorized) bin/drg2js.cjs -g llvm examples/char/charsum.drg -o tmp/charsum.ll
Output saved to tmp/charsum.ll
``` 

The resulting LLVM IR code is in `tmp/charsum.ll`:

```ll
➜  dragon2js git:(LLVM-simple-factorized) cat tmp/charsum.ll
; ModuleID = 'examples/char/charsum.drg'
source_filename = "examples/char/charsum.drg"

; Standard declarations
declare i32 @printf(i8*, ...)
declare i32 @sprintf(i8*, i8*, ...)
declare i8* @strcpy(i8*, i8*)
declare i8* @strcat(i8*, i8*)
declare i64 @strlen(i8*)
declare i8* @malloc(i64)
declare void @free(i8*)
declare i32 @memcmp(i8*, i8*, i64)

; LLVM intrinsics for memory operations
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)

; String constants for print (will be populated when needed)
@.str.i32 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.double = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@.str.char = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
; String constants for sprintf (no newline)
@.str.i32.noline = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.double.noline = private unnamed_addr constant [3 x i8] c"%f\00", align 1

@.strlit.0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@.strlit.3 = private unnamed_addr constant [8 x i8] c" world!\00", align 1

define i32 @main() {
  %tmp_b = call i8* @malloc(i64 6)
  %tmp_c = getelementptr inbounds [6 x i8], [6 x i8]* @.strlit.0, i64 0, i64 0
  call i8* @strcpy(i8* %tmp_b, i8* %tmp_c)
  %tmp_e = call i8* @malloc(i64 8)
  %tmp_f = getelementptr inbounds [8 x i8], [8 x i8]* @.strlit.3, i64 0, i64 0
  call i8* @strcpy(i8* %tmp_e, i8* %tmp_f)
  %tmp_g = call i64 @strlen(i8* %tmp_b)
  %tmp_h = call i64 @strlen(i8* %tmp_e)
  %tmp_i = add i64 %tmp_g, %tmp_h
  %tmp_j = add i64 %tmp_i, 1
  %tmp_k = call i8* @malloc(i64 %tmp_j)
  call i8* @strcpy(i8* %tmp_k, i8* %tmp_b)
  call i8* @strcat(i8* %tmp_k, i8* %tmp_e)
  %tmp_l = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.char, i64 0, i64 0), i8* %tmp_k)
  ret i32 0
}
```

## LLVM IR — Explicación

## Explanation of `charsum.drg` LLVM IR

This program concatenates two strings and prints the result. The equivalent C code would be:

```c
int main() {
    char* a = strdup("hello");
    char* b = strdup(" world!");
    char* result = malloc(strlen(a) + strlen(b) + 1);
    strcpy(result, a);
    strcat(result, b);
    printf("%s\n", result);
    return 0;
}
// Output: "hello world!"
```

---

### Global string literals

```ll
@.strlit.0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@.strlit.3 = private unnamed_addr constant [8 x i8] c" world!\00", align 1
```

Two read-only strings stored in global memory:
- `"hello\0"` → 5 chars + null terminator = **6 bytes**
- `" world!\0"` → 7 chars + null terminator = **8 bytes**

---

### Inside `main`, step by step

**Step 1 — Copy "hello" into heap memory**
```ll
%tmp_b = call i8* @malloc(i64 6)
%tmp_c = getelementptr inbounds [6 x i8], [6 x i8]* @.strlit.0, i64 0, i64 0
call i8* @strcpy(i8* %tmp_b, i8* %tmp_c)
```
Allocates 6 bytes on the heap and copies `"hello"` into it. You can't modify a global constant directly, so a writable copy is needed.

**Step 2 — Copy " world!" into heap memory**
```ll
%tmp_e = call i8* @malloc(i64 8)
%tmp_f = getelementptr inbounds [8 x i8], [8 x i8]* @.strlit.3, i64 0, i64 0
call i8* @strcpy(i8* %tmp_e, i8* %tmp_f)
```
Same thing for the second string — 8 bytes allocated, `" world!"` copied in.

**Step 3 — Calculate the size needed for the combined string**
```ll
%tmp_g = call i64 @strlen(i8* %tmp_b)   ; strlen("hello")  = 5
%tmp_h = call i64 @strlen(i8* %tmp_e)   ; strlen(" world!") = 7
%tmp_i = add i64 %tmp_g, %tmp_h         ; 5 + 7 = 12
%tmp_j = add i64 %tmp_i, 1              ; 12 + 1 = 13  ← +1 for the null terminator '\0'
```

**Step 4 — Allocate the result buffer and concatenate**
```ll
%tmp_k = call i8* @malloc(i64 %tmp_j)   ; malloc(13)
call i8* @strcpy(i8* %tmp_k, i8* %tmp_b) ; tmp_k = "hello"
call i8* @strcat(i8* %tmp_k, i8* %tmp_e) ; tmp_k = "hello world!"
```
Allocates exactly the right amount of memory, copies the first string in, then appends the second.

**Step 5 — Print and return**
```ll
%tmp_l = call i32 (i8*, ...) @printf(...@.str.char..., i8* %tmp_k)
ret i32 0
```
Prints using the `"%s\n"` format string, outputting `hello world!`.

---

### Memory layout visualization

```
Heap after all mallocs:

%tmp_b → [ h | e | l | l | o |\0 ]         (6 bytes)
%tmp_e → [   | w | o | r | l | d | ! |\0 ] (8 bytes)
%tmp_k → [ h | e | l | l | o |   | w | o | r | l | d | ! |\0 ] (13 bytes)
```

---

### One thing to notice

The code **never calls `free()`**, so all three heap allocations leak. This is likely intentional for a simple example — the OS reclaims memory when the program exits anyway.

### General Context

The comment `ModuleID = 'examples/char/charsum.drg'` suggests that this IR was **generated by a custom compiler** (extension `.drg`), not handwritten — it's the output of a compiler frontend that compiles to LLVM.

When you invoke `clang file.ll -o output`, clang acts as a **driver** and automatically:

1. **Compiles** the IR to object code (`.o`)
2. **Links** it to the system's libc

That's why the `declare` statements for `printf`, `malloc`, etc., work without you doing anything — clang passes something equivalent to:

```bash
clang file.ll -o output -lc
```

although you don't even need to write `-lc` explicitly because it's included in the driver's default flags.

---

### If you want to avoid automatic linking with the system's libc

To compile **without** automatic linking:

```bash
clang -c file.ll -o file.o # Only compiles, doesn't link
```

Or if you want to see exactly which flags clang is passing to the linker:

```bash
clang file.ll -o output -v
```

The `-v` shows you the complete `ld` (or `lld`) command that it executes internally, where you'll see things like `-lc`, the startup crt, etc.