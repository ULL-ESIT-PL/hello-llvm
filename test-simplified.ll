; ModuleID = 'test-simplified.bc'
source_filename = "test.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx26.0.0"

define noundef i32 @main() {
  ret i32 42
}
