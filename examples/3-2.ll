; Compile it with: /usr/bin/clang examples/3-2.ll -o tmp/3-2
; ModuleID = 'salida.calc'
source_filename = "salida.calc"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx26.0.0"
   declare i32 @printf(i8*, ...)
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

define i32 @main() {
  %1 = sub i32 3, 2
  %2 = sitofp i32 %1 to double
  %3 = fsub double %2, 1.0
    call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), double %3)
  ret i32 0
}