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

; Intializes a row of the matrix to 0s except for the diagonal element %rowNum which is set to 1
define void @initializeRow(ptr noundef %row, i32 noundef %N, i32 noundef %rowNum) {
entry:
  %row.addr = alloca ptr, align 8
  %N.addr = alloca i32, align 4
  %rowNum.addr = alloca i32, align 4
  %j = alloca i32, align 4
  store ptr %row, ptr %row.addr, align 8
  store i32 %N, ptr %N.addr, align 4
  store i32 %rowNum, ptr %rowNum.addr, align 4
  store i32 0, ptr %j, align 4
  br label %for.cond

for.cond:
  %0 = load i32, ptr %j, align 4
  %1 = load i32, ptr %N.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:
  %2 = load ptr, ptr %row.addr, align 8
  %3 = load i32, ptr %j, align 4
  %j64 = sext i32 %3 to i64
  %elemPtr = getelementptr inbounds i32, ptr %2, i64 %j64
  store i32 0, ptr %elemPtr, align 4
  br label %for.inc

for.inc:
  %4 = load i32, ptr %j, align 4
  %inc = add nsw i32 %4, 1
  store i32 %inc, ptr %j, align 4
  br label %for.cond

for.end:
  %5 = load ptr, ptr %row.addr, align 8
  %6 = load i32, ptr %rowNum.addr, align 4
  %diag64 = sext i32 %6 to i64
  %diagPtr = getelementptr inbounds i32, ptr %5, i64 %diag64
  store i32 1, ptr %diagPtr, align 4
  ret void
}

define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %firstRow = getelementptr [3 x i32], ptr %M, i64 0
  call void @initializeRow(ptr noundef %firstRow, i32 noundef 3, i32 0)

  %secondRow = getelementptr [3 x i32], ptr %M, i64 1
  call void @initializeRow(ptr noundef %secondRow, i32 noundef 3, i32 1)
    
  %thirdRow = getelementptr [3 x i32], ptr %M, i64 2
  call void @initializeRow(ptr noundef %thirdRow, i32 noundef 3, i32 2)

  %base = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}