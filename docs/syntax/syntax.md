## Many Transformations

The compiler performs many behaviour-preserving _transformations_
before producing the final program; along the way, it uses many different
representations for the program, like graphs, high-level instruction sequences,
and real machine instructions. Let's look at one possible flow that an
LLVM-based compiler may follow.

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/behavior_preserving_transformation.svg)


We start with the source program, and then we:

1. _Transform_ it into a Parse Tree.
   * Usually, this step can fail for ill-formed programs.
2. _Transform_ it into an Abstract Syntax Tree (AST).
3. _Transform_ it into a semantically valid AST.
   * Usually, this step can fail for ill-formed programs.
4. _Transform_ it into Intermediate Representation (IR).
5. _Transform_ it into equivalent IR.
   * Often referred to as "optimizations".
6. _Transform_ it into a Selection DAG.
7. _Transform_ it into sequence of machine instructions.
8. _Transform_ it into the final program.

The list is not comprehensive, the important observation is the number of _transformations_ and
how __all__ of them must preserve behavior.

Each representation in the list above is "intermediate" in the sense that it is
neither the input program nor the final executable, but we usually define
Intermediate Representation to mean the IR generated in Step 4, "optimized"
(_transformed_) in Step 5, and lowered in Step 6.

## Different Languages, Same IR

Steps 1-5 are specific to the source language of the input program, whereas all
other steps are agnostic to the language; the IR is the first such agnostic
representation. Using this scheme, one can conceive different compilers that
all share the "middle" and "back"-ends of the sequence above:

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/more_frontends.svg){style="display:block; margin: auto;"}

As a side-effect of a language-agnostic IR, the behavior required by the input
language specification must be captured using generic mechanisms provided by
the IR; the language specification can't exist in that level, otherwise it
would no longer be language-agnostic. Because of this, one can inspect IR and
understand how language concepts are mapped to simpler and lower level code
abstractions.


## On the LLVM IR Syntax

See https://llvm.org/docs/LangRef.html#syntax

LLVM programs are composed of Module’s, each of which is a translation unit of the input programs. Each module consists of 
- functions, 
- global variables, and 
- symbol table entries. 

Modules may be combined together with the LLVM linker, which merges function (and global variable) definitions, resolves forward declarations, and merges symbol table entries. Here is an example of the `“hello world”` module:

```ll 
; Declare the string constant as a global constant.
@.str = private unnamed_addr constant [13 x i8] c"hello world\0A\00"

; External declaration of the puts function
declare i32 @puts(ptr captures(none)) nounwind

; Definition of main function
define i32 @main() {
  ; Call puts function to write out the string to stdout.
  call i32 @puts(ptr @.str)
  ret i32 0
}

; Named metadata
!0 = !{i32 42, null, !"string"}
!foo = !{!0}
```

``` 
module      ::= (function | global)*

function    ::= 'define' type '@' name '(' params ')' '{' block* '}'

block       ::= label ':' instruction*

instruction ::= assignment | terminator

assignment  ::= '%' name '=' op

op          ::= 'add' type value ',' value
              | 'sub' type value ',' value
              | 'load' type ',' type '*'
              | ...

terminator  ::= 'ret' type value
              | 'br' 'label' '%' name
              | 'br' 'i1' value ',' 'label' '%' name ',' 'label' '%' name
```

- LLVM IR is strongly typed.
- Global symbols begin with an at sign (`@`).
- Local symbols begin with a percent symbol (`%`).
- All symbols must be declared or defined.
- If in doubt, consult the Language Reference Manual: https://llvm.org/docs/LangRef.html

