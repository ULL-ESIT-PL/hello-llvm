; Compile with MacOS Clang: clang /usr/bin/clang examples/factorial-main.ll examples/factorial.ll -o tmp/f
; Run with:     tmp/f
; 

; ModuleID = 'examples/factorial-main.ll'
source_filename = "examples/factorial-main.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx26.0.0"

declare i32 @factorial(i32)
declare i32 @printf(i8*, ...)
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @main(i32 %argc, i8** %argv) {
  %1 = call i32 @factorial(i32 5)
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %1)
  ret i32 %2
}