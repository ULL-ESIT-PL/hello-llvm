## Main Goal

Create a lab to translate from [Dragon](https://github.com/ULL-ESIT-PL/dragon2js) to LLVM IR.

## Related work: The Complect project

See section [docs/related-work/complect.md)](/docs/related-work/complect.md)

## The llvm-bindings package

See section [docs/bindings-for-js/llvm-bindings.md](/docs/bindings-for-js/llvm-bindings.md)

## On the LLVM IR Syntax

See section [docs/syntax/syntax.md](/docs/syntax/syntax.md)

## Running LLVM IR in Compiler Explorer


[Compiler Explorer](https://godbolt.org/) **does** support LLVM IR as a source language. Use LLVM IR as the source language + Clang as compiler. Select:

- **Language: LLVM IR**
- **Compiler: Clang** (any version)

Clang accepts `.ll` files as input and can compile them to a binary. Then if you add an **Executor** pane, it will run the resulting binary — so you effectively write IR and execute it.

This is the closest thing to running IR directly inside Compiler Explorer. 

Given this input:

```ll
@variable = global i32 21
@fmt = constant [4 x i8] c"%d\0A\00"
declare i32 @printf(ptr, ...)
define i32 @main() {
    %1 = load i32, i32* @variable  ; load the global variable
    %2 = mul i32 %1, 2
    store i32 %2, i32* @variable   ; store instruction to write to global variable
    call i32 (ptr, ...) @printf(ptr @fmt, i32 %1)
    ret i32 %2
}
```

to make it work we have the `declare i32 @printf(ptr, ...)` declaration and also a `@main` entry point.

The picture shows the Compiler Explorer interface with LLVM IR code in the left pane, the assembly output in the middle pane, and the execution output in the right pane.


![Running LLVM IR in Compiler Explorer](/docs/images/runningLLVM-IR-on-compiler-explorer.png)


## Visualizing

Program Visualization using LLVM:

To visualize the Control Flow Graph (CFG)
With LLVM version 21:

```
➜  examples git:(main) ✗ clang -S -emit-llvm -fno-discard-value-names diag.c -o diag.ll
➜  examples git:(main) ✗ opt -passes=dot-cfg diag.ll -disable-output
Writing '.identity.dot'...
examples git:(main) ✗ dot -Tpng .identity.dot -o diag.png
```

Files:

- [diag.c](/examples/diag.c)
- [diag.ll](/examples/diag.ll)
- [.identity.dot](/examples/.identity.dot)
- [diag.png](/docs/images/diag.png) 

![/docs/images/diag.png](/docs/images/diag.png)

A **Control Flow Graph (CFG)** is a graphical representation of all paths that might be traversed through a program during its execution. 

**Key Components**

- **Nodes (Basic Blocks)**: Each node represents a Basic Block—a linear sequence of instructions with one entry point (the first instruction) and one exit point (the last instruction). There are no jumps into or out of the middle of the block.
- **Edges (Control Flow)**: Directed edges represent the flow of control. An edge from Block A to Block B means that Block B can execute immediately after Block A.
- **Entry and Exit**: The graph typically has a unique entry node (where the function starts) and may have one or more exit nodes (return statements or exits)

- Watch https://youtu.be/aFbWIJlcWww?si=JHZ5wDfqHiKO3F1X by CompilersLab

## A Translator from Simple Arithmetic Expressions to LLVM IR

See https://github.com/ULL-ESIT-PL/calc2llvmIR/blob/main/README.md


## References

* [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)
  * [fanyi-zhao/Kaleidoscope](https://github.com/fanyi-zhao/Kaleidoscope) repo at GitHub
* [Mapping High-Level Constructs to LLVM IR](https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/latest/a-quick-primer/index.html) by Michael Rodler and Mikael Egevig
* [LLVM Language Reference Manual](https://llvm.org/docs/LangRef.html)
* What Is LLVM? https://www.youtube.com/watch?v=HecW5byOrUY&list=PLDSTpI7ZVmVnvqtebWnnI8YeB8bJoGOyv by CompilersLaboratory
* See the list of LLVM videos by Dmitry Soshnikov at https://www.youtube.com/@DmitrySoshnikov-education/search?query=LLVM
  * Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw
* [Compiler Explorer](https://godbolt.org/)
  * [Compiler Explorer (part 1 of 2)](https://www.youtube.com/watch?v=4_HL3PH4wDg&list=PL2HVqYf7If8dNYVN6ayjB06FPyhHCcnhG) by Mat Godbolt
  * [Compiler Explorer | Introduction to Common Compiler Tools #4](https://www.youtube.com/watch?v=0Idx1hiz_Bk) by LLVM Social Bangalore
* [CppInsights](https://cppinsights.io/)
  * C++ Insights at YouTube: Hello, C++ Insights: https://www.youtube.com/watch?v=NhIubRbFfuM&list=PLm0Dc2Lp2ycaFyR2OqPkusuSB8LmifY8D 
* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation)
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf)
* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation)
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf) 
* Jarrod Connolly, (Kabam Games Inc) at **OpenJS World 2022** "Writing a Compiler in Node.js using Streams" 
  * [Github Complect](https://github.com/jarrodconnolly/complect)
  * [Slides](https://static.sched.com/hosted_files/openjsworld2022/78/OpenJSW%20World%202022.pdf) 
  * [Video](https://youtu.be/aPHf_-N2yTU)
* An introduction to LLVM IR: https://youtu.be/CDKuH7SIgdM?si=kDHsuQsNNXo6uDJW by revng 2025
