; malloc_free_demo.ll
; Compile: clang examples/malloc-free.ll -o tmp/malloc-free
; Run: tmp/malloc-free  (42)

@.fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare noalias ptr @malloc(i64 noundef)
declare void @free(ptr noundef)
declare i32 @printf(ptr noundef, ...)

define i32 @main() {
entry:
  ; Allocate 4 bytes (size of i32)
  %p = call noalias ptr @malloc(i64 noundef 4)

  ; Optional null check
  %isnull = icmp eq ptr %p, null
  br i1 %isnull, label %oom, label %ok

ok:
  store i32 42, ptr %p, align 4 ; Store the value 42 at the allocated memory
  %v = load i32, ptr %p, align 4

  %fmt = getelementptr [4 x i8], ptr @.fmt, i64 0, i64 0
  call i32 (ptr, ...) @printf(ptr noundef %fmt, i32 noundef %v)

  call void @free(ptr noundef %p)
  ret i32 0

oom:
  ret i32 1
}