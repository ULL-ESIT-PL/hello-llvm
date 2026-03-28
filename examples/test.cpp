// Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw 
int main(int argc, char const *argv[]) { return 42; }
//   clang++ -S -emit-llvm test.cpp
// Options:
//   -S                      Only run preprocess and compilation steps
//   -emit-llvm              Emit LLVM IR
// Produces the file test.ll, which contains the LLVM IR representation of the original C++ code.
// We can compile the LLVM IR to machine code and execute it using clang:
// ➜  hello-llvm clang test.ll -o test
// ➜  hello-llvm ./test
// ➜  hello-llvm echo $?
// 42 
// The content of test.ll will look something like this:
/* 
➜  hello-llvm cat -n test.ll
     1  ; ModuleID = 'test.cpp'
     2  source_filename = "test.cpp"
     3  target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
     4  target triple = "x86_64-apple-macosx26.0.0"
     5
     6  ; Function Attrs: mustprogress noinline norecurse nounwind optnone ssp uwtable
     7  define noundef i32 @main(i32 noundef %0, ptr noundef %1) #0 {
     8    %3 = alloca i32, align 4
     9    %4 = alloca i32, align 4
    10    %5 = alloca ptr, align 8
    11    store i32 0, ptr %3, align 4
    12    store i32 %0, ptr %4, align 4
    13    store ptr %1, ptr %5, align 8
    14    ret i32 42
    15  }
    16
    17  attributes #0 = { mustprogress noinline norecurse nounwind optnone ssp uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
    18
    19  !llvm.module.flags = !{!0, !1, !2, !3, !4}
    20  !llvm.ident = !{!5}
    21
    22  !0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 2]}
    23  !1 = !{i32 1, !"wchar_size", i32 4}
    24  !2 = !{i32 8, !"PIC Level", i32 2}
    25  !3 = !{i32 7, !"uwtable", i32 2}
    26  !4 = !{i32 7, !"frame-pointer", i32 2}
    27  !5 = !{!"Homebrew clang version 22.1.1"}
*/
// We can also use the lli interpreter to execute the LLVM IR directly without compiling it to machine code:
// ➜  hello-llvm lli test.ll
// ➜  hello-llvm echo $?
// 42