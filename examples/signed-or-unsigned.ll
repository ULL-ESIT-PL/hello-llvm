; In LLVM IR, `i32` is neither — it's just a 32-bit integer with no inherent signedness. 
; Signedness is determined by the instruction used on it: `add`/`sub`/`mul` are sign-agnostic (two's complement), 
; while `sdiv`/`udiv`, `icmp slt`/`icmp ult`, `sext`/`zext` encode the sign semantics explicitly.
; ModuleID = 'tests/01-simple-int.calc'
source_filename = "tests/01-simple-int.calc"

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx26.0.0"
declare i32 @printf(i8*, ...)
@a = global i32 0
@b = global i32 0
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @add(i32 %a, i32 %b) {
entry:
  ; play with signed vs unsigned by changing the instruction used here, for example:
    %1 = add i32 %a, %b  ; sign-agnostic
  ; %1 = sdiv i32 %a, %b  ; signed division
  ; %1 = udiv i32 %a, %b  ; unsigned division
  ; %1 = sext i32 %a to i64  ; sign-extend
  ; %1 = zext i32 %a to i64  ; zero-extend 
 
  ret i32 %1
}

define i1 @compare(i32 %a, i32 %b) {
entry:
  ; play with signed vs unsigned by changing the instruction used here, for example:
  ; %1 = icmp slt i32 %a, %b  ; signed less than
  %1 = icmp ult i32 %a, %b  ; unsigned less than
  ; %1 = icmp eq i32 %a, %b  ; equality (sign-agnostic)
  ; %1 = icmp sgt i32 %a, %b  ; signed greater than
  ; %1 = icmp ugt i32 %a, %b  ; unsigned greater than
  ret i1 %1
}

define i32 @main() {
  ; Play with different values of a and b to see how the signed vs unsigned behavior changes.
  %1 = call i32 @add(i32 -15, i32 -5)
  
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %1)

  ; Compare using the compare function
  %3 = call i1 @compare(i32 -15, i32 -5)

  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i1 %3)

  ret i32 %1
}