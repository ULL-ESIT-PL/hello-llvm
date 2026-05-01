; Compile and run with:
; clang examples/hello-array.ll -o tmp/hello-array
; tmp/hello-array
; 1
; 2
; 3
; 4
; 5
target triple = "x86_64-apple-macosx26.0.0"

@.fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(ptr noundef, ...)

define void @printArray(ptr noundef %arr, i32 noundef %N) {
entry:
  ; Allocate local storage for function parameters and loop counter
  %arr.addr = alloca ptr, align 8        ; Storage for the array pointer parameter
  %N.addr = alloca i32, align 4          ; Storage for the array size parameter
  %i = alloca i32, align 4               ; Loop counter
  
  ; Store the parameter values into our local variables
  store ptr %arr, ptr %arr.addr, align 8
  store i32 %N, ptr %N.addr, align 4
  store i32 0, ptr %i, align 4           ; Initialize loop counter to 0
  br label %for.cond                     ; Jump to loop condition check

for.cond:
  ; Check if loop counter is less than array size (i < N)
  %0 = load i32, ptr %i, align 4         ; Load current loop counter
  %1 = load i32, ptr %N.addr, align 4    ; Load array size
  %cmp = icmp slt i32 %0, %1             ; Compare: i < N
  br i1 %cmp, label %for.body, label %for.end ; If true, enter loop; else exit

for.body:
  ; Loop body: print the current array element
  %2 = load ptr, ptr %arr.addr, align 8  ; Load the array pointer
  %3 = load i32, ptr %i, align 4         ; Load the current loop counter
  %idxprom = sext i32 %3 to i64          ; Convert loop counter to i64 for getelementptr
  %elemPtr = getelementptr inbounds i32, ptr %2, i64 %idxprom ; Get address of arr[i]
  %val = load i32, ptr %elemPtr, align 4 ; Load the value at arr[i]
  %fmtPtr = getelementptr inbounds [4 x i8], ptr @.fmt, i64 0, i64 0 ; Get format string
  %4 = call i32 (ptr, ...) @printf(ptr noundef %fmtPtr, i32 noundef %val) ; Print the value
  br label %for.inc                      ; Jump to increment

for.inc:
  ; Increment the loop counter
  %5 = load i32, ptr %i, align 4         ; Load current counter
  %inc = add nsw i32 %5, 1               ; Increment by 1
  store i32 %inc, ptr %i, align 4        ; Store back the incremented value
  br label %for.cond                     ; Jump back to condition check

for.end:
  ; Loop finished, return from function
  ret void
}

define i32 @main() {
entry:
  %arr = alloca [5 x i32], align 16

  %p0 = getelementptr i32, ptr %arr, i64 0
  store i32 1, ptr %p0, align 4

  %p1 = getelementptr i32, ptr %arr, i64 1
  store i32 2, ptr %p1, align 4

  %p2 = getelementptr i32, ptr %arr, i64 2
  store i32 3, ptr %p2, align 4

  %p3 = getelementptr i32, ptr %arr, i64 3
  store i32 4, ptr %p3, align 4

  %p4 = getelementptr i32, ptr %arr, i64 4
  store i32 5, ptr %p4, align 4

  %arr0 = getelementptr i32, ptr %arr, i64 0
  call void @printArray(ptr noundef %arr0, i32 noundef 5)

  ret i32 0
}