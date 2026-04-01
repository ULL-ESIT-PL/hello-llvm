target triple = "x86_64-apple-macosx26.0.0"

@.fmt = private unnamed_addr constant [4 x i8] c"%d \00"
@.nl = private unnamed_addr constant [2 x i8] c"\0A\00"

declare i32 @printf(ptr noundef, ...)

define void @printMatrix(ptr noundef %m, i32 noundef %N) {
entry:
  %m.addr = alloca ptr, align 8
  %N.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store ptr %m, ptr %m.addr, align 8
  store i32 %N, ptr %N.addr, align 4
  store i32 0, ptr %i, align 4
  br label %for.i.cond

for.i.cond:
  %0 = load i32, ptr %i, align 4
  %1 = load i32, ptr %N.addr, align 4
  %cmp.i = icmp slt i32 %0, %1
  br i1 %cmp.i, label %for.i.body, label %for.i.end

for.i.body:
  store i32 0, ptr %j, align 4
  br label %for.j.cond

for.j.cond:
  %2 = load i32, ptr %j, align 4
  %3 = load i32, ptr %N.addr, align 4
  %cmp.j = icmp slt i32 %2, %3
  br i1 %cmp.j, label %for.j.body, label %for.j.end

for.j.body:
  %4 = load ptr, ptr %m.addr, align 8
  %5 = load i32, ptr %i, align 4
  %6 = load i32, ptr %N.addr, align 4
  %rowOff = mul nsw i32 %5, %6
  %7 = load i32, ptr %j, align 4
  %idx = add nsw i32 %rowOff, %7
  %idx64 = sext i32 %idx to i64
  %elemPtr = getelementptr inbounds i32, ptr %4, i64 %idx64
  %val = load i32, ptr %elemPtr, align 4
  %fmtPtr = getelementptr inbounds [4 x i8], ptr @.fmt, i64 0, i64 0
  %8 = call i32 (ptr, ...) @printf(ptr noundef %fmtPtr, i32 noundef %val)
  br label %for.j.inc

for.j.inc:
  %9 = load i32, ptr %j, align 4
  %inc.j = add nsw i32 %9, 1
  store i32 %inc.j, ptr %j, align 4
  br label %for.j.cond

for.j.end:
  %nlPtr = getelementptr inbounds [2 x i8], ptr @.nl, i64 0, i64 0
  %10 = call i32 (ptr, ...) @printf(ptr noundef %nlPtr)
  br label %for.i.inc

for.i.inc:
  %11 = load i32, ptr %i, align 4
  %inc.i = add nsw i32 %11, 1
  store i32 %inc.i, ptr %i, align 4
  br label %for.i.cond

for.i.end:
  ret void
}

define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %p00 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 0
  store i32 1, ptr %p00, align 4

  %p01 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 1
  store i32 0, ptr %p01, align 4

  %p02 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 2
  store i32 0, ptr %p02, align 4

  %p10 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 0
  store i32 0, ptr %p10, align 4

  %p11 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 1
  store i32 1, ptr %p11, align 4

  %p12 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 2
  store i32 0, ptr %p12, align 4

  %p20 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 0
  store i32 0, ptr %p20, align 4

  %p21 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 1
  store i32 0, ptr %p21, align 4

  %p22 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 2
  store i32 1, ptr %p22, align 4

  %base = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}