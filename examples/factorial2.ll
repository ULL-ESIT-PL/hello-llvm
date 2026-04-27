; ModuleID = 'examples/factorial.c'
; Comment first target datalayout and target triple to match
; Compile: (MacOS) clang examples/factorial-main.ll examples/factorial.ll -o tmp/f
; Compile (Linux/Codespaces): clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f
; Run: tmp/f (Output: 120)
source_filename = "examples/factorial.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
;target triple = "x86_64-apple-macosx26.0.0"

; Function Attrs: nofree nosync nounwind readnone ssp uwtable
define i32 @factorial(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq i32 %0, 0
  br i1 %2, label %7, label %3
3:                                                ; preds = %1
  %4 = add nsw i32 -1, %0
  %5 = call i32 @factorial(i32 noundef %4)
  %6 = mul nsw i32 %5, %0
  br label %7   
7:                                                ; preds = %1, %3
  %8 = phi i32 [ %6, %3 ], [ 1, %1 ]
  ret i32 %8
}

declare i32 @printf(i8*, ...)

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @main(i32 %argc, i8** %argv) {
  %1 = call i32 @factorial(i32 5)
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %1)
  ret i32 %2
}