## Building and Installing LLVM

See section [docs/installing/README.md](/docs/installing/README.md)

## Introduction to LLVM IR 

See section [docs/syntax/README.md](/docs/syntax/README.md)


## Related work

### Arithmetic expressions to LLVM IR translator

These two repos are private. Students do not have access to them:
  - A Translator from Simple Arithmetic Expressions to LLVM IR at https://github.com/ULL-ESIT-PL/calc2llvmIR/ .
  - Labs [Dragon](https://github.com/ULL-ESIT-PL/dragon2js) has a translator to LLVM IR.

### The Complect project

See section [docs/related-work/complect.md](/docs/related-work/complect.md)

### The llvm-bindings package

See section [docs/bindings-for-js/llvm-bindings.md](/docs/bindings-for-js/llvm-bindings.md)

## References

* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation). Youtube.
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf)
* [2019 LLVM Developers’ Meeting: J. Paquette & F. Hahn “Getting Started With LLVM: Basics”](https://youtu.be/3QQuhL-dSys?si=0abGYKChBLKHMTIr) Youtube
  * [Compiler Explorer](https://godbolt.org/)
  * [Compiler Explorer (part 1 of 2)](https://www.youtube.com/watch?v=4_HL3PH4wDg&list=PL2HVqYf7If8dNYVN6ayjB06FPyhHCcnhG) by Mat Godbolt
  * [Compiler Explorer | Introduction to Common Compiler Tools #4](https://www.youtube.com/watch?v=0Idx1hiz_Bk) by LLVM Social Bangalore
* [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html). This tutorial at llvm.org assumes you know C++
  *  Code at [llvm/examples/Kaleidoscope/](https://github.com/llvm/llvm-project/tree/main/llvm/examples/Kaleidoscope)
  * [fanyi-zhao/Kaleidoscope](https://github.com/fanyi-zhao/Kaleidoscope) repo at GitHub
* [Mapping High-Level Constructs to LLVM IR](https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/latest/a-quick-primer/index.html) by Michael Rodler and Mikael Egevig. This is a gitbook dedicated to providing a description on how LLVM based compilers map high-level language constructs into the LLVM intermediate representation (IR).
* [LLVM Language Reference Manual](https://llvm.org/docs/LangRef.html)
* [What Is LLVM?](https://www.youtube.com/watch?v=HecW5byOrUY&list=PLDSTpI7ZVmVnvqtebWnnI8YeB8bJoGOyv) by CompilersLaboratory.Fernando Pereira. Youtube.
* See the list of LLVM videos by Dmitry Soshnikov at https://www.youtube.com/@DmitrySoshnikov-education/search?query=LLVM
  * Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw
* Jarrod Connolly, (Kabam Games Inc) at **OpenJS World 2022** "Writing a Compiler in Node.js using Streams" 
  * [Github Complect](https://github.com/jarrodconnolly/complect)
  * [Slides](https://static.sched.com/hosted_files/openjsworld2022/78/OpenJSW%20World%202022.pdf) 
  * [Video](https://youtu.be/aPHf_-N2yTU)
* An introduction to LLVM IR: https://youtu.be/CDKuH7SIgdM?si=kDHsuQsNNXo6uDJW by revng 2025. Alessandro di Federico. Youtube.
* [CppInsights](https://cppinsights.io/)
  * C++ Insights at YouTube: [Hello, C++ Insights](https://www.youtube.com/watch?v=NhIubRbFfuM&list=PLm0Dc2Lp2ycaFyR2OqPkusuSB8LmifY8D ). A web sit that shows C++ source‑to‑source transformations, 
