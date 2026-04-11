# Deugging LLVM IR with LLDB

When you compile a `.ll` file with `clang`, you might expect that adding `-g` would allow you to debug it with `lldb`. However, this doesn't work as you might hope. Here's why, and how to do it correctly.

## Add Debug Metadata to the `.ll` File

LLVM IR supports debug info via metadata nodes. You need to add them manually (or ensure your IR generator emits them).

Here's what a minimal `.ll` with debug info looks like:

```llvm
; ModuleID = 'struct.c'
source_filename = "struct.c"
target triple = "x86_64-apple-macosx13.0.0"

; --- Debug metadata ---
!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "struct.c", directory: "/your/source/dir")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
```

And inside each function, tag instructions with `!dbg`:

```llvm
define i32 @main() !dbg !10 {
entry:
  %x = alloca i32, align 4, !dbg !11
  store i32 42, ptr %x, align 4, !dbg !11
  ret i32 0, !dbg !12
}

!10 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 1, type: !13, unit: !0)
!11 = !DILocation(line: 2, column: 3, scope: !10)
!12 = !DILocation(line: 3, column: 3, scope: !10)
!13 = !DISubroutineType(types: !2)
```

---

## Easiest Practical Workaround

Rather than writing metadata by hand, the cleanest workflow is:

**1. Write your equivalent C, compile with debug info, then inspect the IR it generates:**
```bash
clang -g -O0 -emit-llvm -S struct.c -o struct_debug.ll
```
This gives you a working `.ll` with all the correct metadata — use it as a **template** to understand what your own `.ll` needs.

**2. Then compile that IR normally:**
```bash
clang struct_debug.ll -o struct
lldb struct
```

---

### Why `-g` Has No Effect on `.ll` Input

When `clang` receives a `.ll` file, it skips the frontend entirely and goes straight to the backend (linker/codegen). There's no source-level information to attach debug symbols to — so `-g` is silently ignored. The debug info **must already exist** inside the `.ll` as `!DILocation`, `!DISubprogram`, etc. metadata nodes.