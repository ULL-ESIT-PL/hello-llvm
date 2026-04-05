; malloc-free-array.ll
; Compile: clang examples/malloc-free-array.ll -o tmp/malloc-free-array
; Run: ./tmp/malloc-free-array
; Output: 1 2 3 4 5

@.fmt = private unnamed_addr constant [4 x i8] c"%d \00"
@.nl  = private unnamed_addr constant [2 x i8] c"\0A\00"

declare noalias ptr @malloc(i64 noundef)
declare void @free(ptr noundef)
declare i32 @printf(ptr noundef, ...)

define i32 @main() {
entry:
  ; 5 elements * 4 bytes (i32) = 20 bytes
  %arr = call noalias ptr @malloc(i64 noundef 20)
  %isnull = icmp eq ptr %arr, null
  br i1 %isnull, label %oom, label %init

init:
  br label %init.cond

init.cond:
  %i = phi i64 [ 0, %init ], [ %inext, %init.body ]
  %cmp = icmp slt i64 %i, 5
  br i1 %cmp, label %init.body, label %print.start

init.body:
  %val64 = add i64 %i, 1
  %val = trunc i64 %val64 to i32
  %p = getelementptr i32, ptr %arr, i64 %i
  store i32 %val, ptr %p, align 4
  %inext = add i64 %i, 1
  br label %init.cond

print.start:
  br label %print.cond

print.cond:
  %j = phi i64 [ 0, %print.start ], [ %jnext, %print.body ]
  %cmp2 = icmp slt i64 %j, 5
  br i1 %cmp2, label %print.body, label %done

print.body:
  %q = getelementptr i32, ptr %arr, i64 %j
  %x = load i32, ptr %q, align 4
  %fmt = getelementptr [4 x i8], ptr @.fmt, i64 0, i64 0
  call i32 (ptr, ...) @printf(ptr noundef %fmt, i32 noundef %x)
  %jnext = add i64 %j, 1
  br label %print.cond

done:
  %nl = getelementptr [2 x i8], ptr @.nl, i64 0, i64 0
  call i32 (ptr, ...) @printf(ptr noundef %nl)
  call void @free(ptr noundef %arr)
  ret i32 0

oom:
  ret i32 1
}