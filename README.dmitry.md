## Programming Language with LLVM. Introduction to LLVM IR and tools

-  Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw 
- See the list of LLVM videos by Dmitry Soshnikov at https://www.youtube.com/@DmitrySoshnikov-education/search?query=LLVM

## Emitting LLVM IR from C++ with clang++

```C++
int main(int argc, char const *argv[]) { return 42; }
```

```
clang++ -S -emit-llvm test.cpp
```

Options:

```
  -S                      Only run preprocess and compilation steps
  -emit-llvm              Emit LLVM IR
  -o <file>              Place the output into <file>
```
Produces the file test.ll, which contains the LLVM IR representation of the original C++ code.

## Producing an executable from LLVM IR with clang

We can compile the LLVM IR to machine code and execute it using `clang`:

```
➜  hello-llvm clang test.ll -o test
➜  hello-llvm ./test
➜  hello-llvm echo $?
42
``` 

## Contents of test.ll

The content of test.ll will look something like this:

``` 
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
17  attributes #0 = { mustprogress noinline norecurse nounwind optnone ssp uwtable "frame-pointer"="all" -legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" get-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
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
```

## lli interpreter: Executing LLVM IR directly

We can also use the lli interpreter to execute the LLVM IR directly without compiling it to machine code:

```
➜  hello-llvm lli test.ll
➜  hello-llvm echo $?
42
```

## Assembler: From LLVM IR to .bc

We can also use the llvm-as assembler to convert the LLVM IR into a binary format (.bc):

```
llvm-as test.ll -o test.bc
```

and then execute it with lli:

```
lli test.bc
```

We can dump the contents of the .bc file with `xxd`:

```
➜  hello-llvm xxd test-simplified.bc | head -n 20
00000000: dec0 170b 0000 0000 1400 0000 5807 0000  ............X...
00000010: 0700 0001 4243 c0de 3514 0000 0500 0000  ....BC..5.......
00000020: 620c 3024 4a59 bea6 6dfb b55f 0b51 804c  b.0$JY..m.._.Q.L
00000030: 0100 0000 210c 0000 9a01 0000 0b02 2100  ....!.........!.
00000040: 0200 0000 2200 0000 0781 2391 41c8 0449  ....".....#.A..I
00000050: 0610 3239 9201 840c 2505 0819 1e04 8b62  ..29....%......b
00000060: 800c 4502 4292 0b42 6410 3214 3808 184b  ..E.B..Bd.2.8..K
00000070: 0a32 3288 48b0 6421 4386 8804 471c 3242  .22.H.d!C...G.2B
00000080: 2471 c808 1124 2940 868c 104b 0132 6484  $q...$)@...K.2d.
00000090: 0892 1c20 2343 88e5 0019 1942 0419 2a28  ... #C.....B..*(
000000a0: 2a90 515c 2023 b940 860c 19c3 07cb 1519  *.Q\ #.@........
000000b0: 328c 8c24 0719 3262 2c39 c890 1123 c812  2..$..2b,9...#..
000000c0: 880e 1d3a 6444 47c8 1022 4346 0219 1a00  ...:dDG.."CF....
000000d0: 8920 0000 0a00 0000 2266 0410 b242 82c9  . ......"f...B..
000000e0: 1052 4282 c990 71c2 5048 0a09 2643 c605  .RB...q.PH..&C..
000000f0: 4232 2608 0a9a 2300 8312 6420 6004 0000  B2&...#...d `...
00000100: 5118 0000 0200 0000 1b88 0000 4801 0000  Q...........H...
00000110: 4918 0000 0100 0000 1382 0000 1332 7cc0  I............2|.
00000120: 033b f805 3ba0 8336 0807 7880 0776 2887  .;..;..6..x..v(.
00000130: 3668 8770 1887 7798 077c 9003 3b70 0338  6h.p..w..|..;p.8
```

## llvm-dis disassembler: From .bc back to LLVM IR

We can also use the llvm-dis disassembler to convert the .bc file back into human-readable LLVM IR:

```
llvm-dis test.bc -o test_dis.ll
```

## clang++ -S: Generating native assembly code from llvm IR

Using the option `-S` with `clang++` allows us to generate native assembly code (in our case for x86-64 architecture) from the LLVM IR:

```console
➜  hello-llvm clang++ -S test.ll 
```
```
➜  hello-llvm ls -tr test.*
test.ll  test.cpp test.s
➜  hello-llvm cat -n test.s
     1          .build_version macos, 26, 0     sdk_version 26, 2
     2          .section        __TEXT,__text,regular,pure_instructions
     3          .globl  _main                           ## -- Begin function main
     4          .p2align        4
     5  _main:                                  ## @main
     6          .cfi_startproc
     7  ## %bb.0:
     8          pushq   %rbp
     9          .cfi_def_cfa_offset 16
    10          .cfi_offset %rbp, -16
    11          movq    %rsp, %rbp
    12          .cfi_def_cfa_register %rbp
    13          movl    $0, -4(%rbp)
    14          movl    %edi, -8(%rbp)
    15          movq    %rsi, -16(%rbp)
    16          movl    $42, %eax
    17          popq    %rbp
    18          retq
    19          .cfi_endproc
```                             

We can see that the generated assembly code in test.s , and we can compile and execute it as well:

```
➜  hello-llvm clang++ test.s -o test
➜  hello-llvm ./test; echo $?
42
```