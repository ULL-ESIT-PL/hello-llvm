target triple = "x86_64-apple-macosx26.0.0"

@.fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(ptr noundef, ...)

define void @printArray(ptr noundef %arr, i32 noundef %N) {
entry:
  %arr.addr = alloca ptr, align 8
  %N.addr = alloca i32, align 4
  %i = alloca i32, align 4
  store ptr %arr, ptr %arr.addr, align 8
  store i32 %N, ptr %N.addr, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:
  %0 = load i32, ptr %i, align 4
  %1 = load i32, ptr %N.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:
  %2 = load ptr, ptr %arr.addr, align 8
  %3 = load i32, ptr %i, align 4
  %idxprom = sext i32 %3 to i64
  %elemPtr = getelementptr inbounds i32, ptr %2, i64 %idxprom
  %val = load i32, ptr %elemPtr, align 4
  %fmtPtr = getelementptr inbounds [4 x i8], ptr @.fmt, i64 0, i64 0
  %4 = call i32 (ptr, ...) @printf(ptr noundef %fmtPtr, i32 noundef %val)
  br label %for.inc

for.inc:
  %5 = load i32, ptr %i, align 4
  %inc = add nsw i32 %5, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond

for.end:
  ret void
}

define i32 @main() {
entry:
  %arr = alloca [5 x i32], align 16

  %p0 = getelementptr [5 x i32], ptr %arr, i64 0, i64 0
  store i32 1, ptr %p0, align 4

  %p1 = getelementptr [5 x i32], ptr %arr, i64 0, i64 1
  store i32 2, ptr %p1, align 4

  %p2 = getelementptr [5 x i32], ptr %arr, i64 0, i64 2
  store i32 3, ptr %p2, align 4

  %p3 = getelementptr [5 x i32], ptr %arr, i64 0, i64 3
  store i32 4, ptr %p3, align 4

  %p4 = getelementptr [5 x i32], ptr %arr, i64 0, i64 4
  store i32 5, ptr %p4, align 4

  %arr0 = getelementptr [5 x i32], ptr %arr, i64 0, i64 0
  call void @printArray(ptr noundef %arr0, i32 noundef 5)

  ret i32 0
}