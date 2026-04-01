# What is an Intermediate Representation?

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

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/more_frontends.svg)

As a side-effect of a language-agnostic IR, the behavior required by the input
language specification must be captured using generic mechanisms provided by
the IR; the language specification can't exist in that level, otherwise it
would no longer be language-agnostic. Because of this, one can inspect IR and
understand how language concepts are mapped to simpler and lower level code
abstractions.

## Different Languages, Same IR

Steps 1-5 are specific to the source language of the input program, whereas all
other steps are agnostic to the language; the IR is the first such agnostic
representation. Using this scheme, one can conceive different compilers that
all share the "middle" and "back"-ends of the sequence above:

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/more_frontends.svg)

As a side-effect of a language-agnostic IR, the behavior required by the input
language specification must be captured using generic mechanisms provided by
the IR; the language specification can't exist in that level, otherwise it
would no longer be language-agnostic. Because of this, one can inspect IR and
understand how language concepts are mapped to simpler and lower level code
abstractions.

## Goals of the IR

In the compilation pipeline, the IR sits between representations specific to
source languages and representations specific to the target machine:

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/ir_position.svg)

We can derive some of its design goals from where the IR is positioned in the
compilation pipeline. It must be:

* Able to represent concepts from any high level language,
* Amenable to analysis required by "optimizing" transformations,
* Able to represent concepts required by target specific representations.

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/ir_position_and_goals.svg)

LLVM's IR attempts to achieve these design goals by:

* Being a RISC-like language,
* Having a type system,
* Being highly configurable.


# LLVM's IR Core Concepts - Values, Registers, Memory

There are three key abstractions on top of which LLVM IR is built: values,
registers and memory.

## Values

In LLVM IR, **a `Value` is a piece of data described by a type**. For example,
the `Value` `42` of type 32-bit integer is written `i32 42`. This notion is so
important that we will be writing `Value` with a special font to emphasize that
this definition is being used.

There are two places where `Value`s may live: in a register or in memory.

## Registers

A register is an entity that holds exactly one `Value`. `Value`s are placed
into registers through instructions; once a register is assigned a value, its
`Value` - and also its type - never changes. As such, we say that a register is
**defined** when it is assigned a value.

A register will have a "size" big enough to hold its `Value` regardless of the
`Value`'s type; for example, a register may hold a single integer or even an
entire array.

Registers have _names_, and we use their _name_ to access the underlying `Value`.
Any name starting with the `%` symbol is the name of a register. For example:
`%0, %hi, %___` are all register names.

![registers.svg](https://github.com/ULL-ESIT-PL/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p2/registers.svg)

The exact name of a register carries no semantic meaning in the program,
therefore registers may be renamed at will.

When working with LLVM IR, we have access to infinitely many registers.

In this definition of registers, we see why the IR is in this intermediate
state of being a lower level abstraction, but not too low level; the concept of
a register is in itself a low level idea, but IR registers are infinite, may
have arbitrary sizes, and have a type, all of which are ideas of higher-level
languages.

## Memory

Memory is a sequence of bytes, each of which has an address. Addresses, also
known as pointers, are `Value`s and therefore may be placed into a register.
The type of an address is `ptr`.

![memory.svg](https://github.com/ULL-ESIT-PL/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p2/memory.svg)

`Value`s are typically moved from or to memory using `load` or `store` instructions.

In this characterization, memory is _just_ a sequence of bytes. Memory does not
hold information about the types of `Value`s that were previously stored in it;
it is how we use memory addresses that give meaning (a type) to a sequence of
bytes. We will come back to this when we talk about instructions.

## Registers have Names, Memory has Addresses

Note the difference in the definition of registers and memory: registers have
names but not addresses (registers are _not_ memory locations). Memory does not
have names, it only has addresses.

This is a core principle, so excuse the repetition: to access a `Value` inside a
register, we use the _register's name_; to access a `Value` in memory, we
use its _memory address_, which may be placed into a register.


## Instructions

Having defined `Values`, registers, and memory, we're now ready to talk about
instructions.

An instruction is an operation that may have `Value`s as input, may define a
register as output, and may modify state in a program (like writing `Value`s to
memory). Each instruction has semantics describing the expected input, the
produced output and changes it makes to the program state ("side effects").

Here's an example instruction:

```llvm
  %result = add i32 10, %two
```

Its inputs are `i32 10` and `%two`, the latter being a register defined
previously. Its output is `%result`, which is a new register definition. The
`add` instruction sums the `Value` `i32 10` and the `Value` inside register
`%two`, placing the resulting `Value` into `%result`.

LLVM's type system is very strict, so the `add` instruction requires both
operands to be `Value`s of the same type; this is statically checked, and the
IR is invalid otherwise. In our example, the type of `i32 10` is spelled out
explicitly; to find the type of `%result`, we would need to check the
instruction that defined it. This is made possible because **registers are
defined once and never allowed to change, so there is exactly one instruction
defining that register**.

Instructions can also interact with memory:

```llvm
%address = alloca i32
store i32 %result, ptr %address
```

The `alloca i32` instruction allocates enough memory to contain an `i32` `Value`.
It returns a `Value` corresponding to the address of that memory location, and
that `Value` is placed in the register named `%address`. What is the type of this
`Value`? It is a pointer type: `ptr`. While we haven't yet talked about
`Functions`, the memory allocated by an `alloca` is automatically freed when
the `Function` exits.

The second instruction, `store` , does not produce a `Value`. It takes the integer `i32` value in the register`%result`, and stores the value into the memory location stored in the register `%address`.

## Memory Does Not Have a Type!

Recall this paragraph from our memory definition:

> [!IMPORTANT] 
> Memory does not hold information about the types of `Value`s that were
> previously stored in it; it is how we use memory addresses that give meaning
> (a type) to a sequence of bytes.

In the case of the `store i32` instruction, it interprets the input address as
a memory region containing a `Value` of type `i32`. In other words, the store
instruction gave meaning (a type) to that address.

If you're using a version of LLVM prior to April 2022, you may see pointer
types that carry a "base type" with them, like `i32*`. These are being phased
out, soon there will only be `ptr`.

# Modules

One LLVM IR file (`.ll`) represents an LLVM IR Module, a top-level entity
encapsulating all other sections in the IR. There are four such sections:

1. A structure describing the target architecture and platform.
2. Global Symbols:
   1. Global Variables
   2. Functions
3. Metadata: debug information, optimization hints, etc.
4. Other stuff: symbol table entries, unnamed metadata, etc.
   
<!-- ![LLVM IR Module Anatomy](https://github.com/ULL-ESIT-PL/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p3/module_anatomy.svg)-->

![LLM IR Layout](/docs/images/llvm-module-layout.png)
We will focus on global symbols (variables and functions).

## Target Information 

The target information section describes the architecture and platform for which the IR is intended. For example, in the data layout it may specify the endianness, the Executable and Linkable Format ([ELF](elf.md)) [mangling](name-mangling.md), the Application Binary Interface ([ABI](abi.md)) alignment, the native integer widths, etc. The target triple specifies the architecture, vendor, operating system, the ABI and sometimes the environment to refine an ABI variant of the runtime ecosystem. 


![](/docs/images/target-information.png)


## Global Symbols

Global symbols are top-level `Value`s visible to the entire Module. Their names
always start with the `@` symbol, for example: `@x`, `@__foo` and `@main`.

Unlike registers, the name of a global symbol may have semantic meaning in the
program; in other words, global symbols have **[linkage](https://en.wikipedia.org/wiki/Linkage_(software))**. For example, a global
symbol may have `external` linkage, which means its name is visible to _other
Modules_. Or `internal` linkage, which means its name is only visible within the
same Module. For such a symbol, it would be illegal to rename it: doing so could
invalidate code in other Modules.

Global symbols define memory regions allocated at compilation time. For this
reason, the `Value` of a global symbol has a pointer type.

For example, if we declare a global variable of type `i32` called `x`, the type
of the `Value` `@x` is `ptr`. To access the underlying integer, we must first
load from that address.

There are two kinds of global symbols: **global variables** and **functions**.

## Global Variables

As a global symbol, global variables have a **name** and **linkage**. Additionally,
they require a **type** and a _constant_ **initial** `Value`:

```llvm
@gv1 = external global float 1.0
```

In this example, we have a global symbol that:

* Has name `gv1`.
* Has external linkage (its name is visible to other Modules).
* Is a global variable.
* Contains a `float` `Value`.
* Is initialized with `Value` `float 1.0`.

External linkage is the default and can be omitted:

```llvm
@gv1 = global float 1.0
```

From here on, we will be omitting linkage for all global symbols.

Recall that, because all global symbols define a memory region, the `Value`
`@gv1` has a pointer type. As such, to read or write the `Value` in that memory
location we use loads and stores:

```llvm
%1 = load float, ptr @gv1
store float 2.0, ptr @gv1
```

There is one other important variation of global variables, we may replace
`global` with the `constant` keyword:

```llvm
@gv1 = constant float 1.0
```

This means that stores to this memory region are illegal and the optimizer can
assume they do not exist.

## Global Variables: examples from C++ to LLVM IR

Let's compile some C++ global declarations and look at the corresponding IR
global variable:

```cpp
int just_int;
// @just_int = dso_local global i32 0, align 4
```

The keyword `dso_local` (`dso` stands for [Dynamic Shared Object](dso.md), so `dso_local`literally means *local to this dynamic shared object*) is used to indicate, roughly, that this variable is
`not` going to be "patched in" at runtime, like in the case of dynamic
libraries. This information is useful for the optimizer.

Note that, while we didn't explicitly initialize the C++ variable, it is
zero-initialized in IR. Zero initialization is required by C++ in this case, so
we see it captured in the C++ to IR translation.

Finally, there is alignment information: the address of this variable is
guaranteed to be a multiple of 4.

```cpp
extern int extern_int;
// @extern_int = external global i32, align 4
```

If we make our variable `extern`, a few things change:

* The `external` linkage is explicitly written out. This is just a quirk of
the IR parser/printer. The variable `just_int` also had `external` linkage
implicitly.
* This variable is _not_ `dso_local`: it could be defined in some shared
library that will be linked later.

Let's look at more examples:

```cpp
const int const_int = 1;
// @_ZL9const_int = internal constant i32 1

static int static_int = 2;
// @_ZL10static_int = internal global i32 2

static const int static_const_int = 3;
// @_ZL16static_const_int = internal constant i32 3
```

* Name [mangling](name-mangling.md) can now be observed.
* All three variables have internal linkage (which means their names are only visible within the same module).


Compare these static variables to what happens with a _class_ static variable:

```cpp
class MyClass {
public:
    static int static_class_member;
    // @_ZN7MyClass19static_class_memberE = external global i32, align 4

    static const int static_const_class_member;
    // @_ZN7MyClass25static_const_class_memberE = external constant i32, align 4
};

```

* Even though they are "static", they have `external` linkage. This shows
the completely different meanings of static in a C++ program: where before we
were using static to mean "local to this translation unit", and so it gets
`internal` linkage, in the class example we are essentially providing a
namespace to the variable, but it can still be accessed by other translation
units.

You can see these in action [in Godbolt](https://godbolt.org/z/4nbdede45).


## Functions

A function _declaration_ in LLVM IR has the following syntax:

```llvm
declare i64 @foo(i64, ptr)
```

* A keyword `declare`,
* The return type (`i64`),
* The symbol name (`foo`),
* The list of parameter types (`i64`, `ptr`).

A function _definition_ is very similar to the declaration, but we use a
different keyword (`define`), provide names to the parameters and include the
body of the function:

```llvm
define i64 @foo(i64 %val, ptr %myptr) {
  %temp = load i64, ptr %myptr
  %mul = mul i64 %val, %temp
  ret %mul
}
```

This function loads an `i64` `Value` from `%ptr`, multiplies it with `%val` and
returns the result (`ret` instruction).

What is the type of `@foo`? Like all global symbols, it defines a memory region
and therefore its type is a pointer type (`ptr`).

![](/docs/images/functions.png)

## Further Reading

It is a useful exercise to read the LLVM documentation on some of the topics
discussed:

* The existing [linkage types](https://llvm.org/docs/LangRef.html#linkage-types). There are a lot of subtle variations between
the two extremes of: "this symbol is only visible in this Module" and "this
symbol is visible in all Modules"
* The full specification for [functions](https://llvm.org/docs/LangRef.html#functions) and [global variables](https://llvm.org/docs/LangRef.html#global-variables). Don't try to
understand everything there, but note how many details can be added to those
global symbols.

# The Body of a Function

## Virtual Registers

Virtual registers are "local" variables.They come in two flavors: named and unnamed. Named virtual registers have names starting with the `%` symbol, for example: `%result`, `%hi`, `%___`. Unnamed virtual registers are automatically generated by the IR parser/printer and have names like `%1`, `%2`, etc. **They must be sequentially numbered**.

# On the LLVM IR Syntax

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

- LLVM IR is strongly typed.
- Global symbols begin with an at sign (`@`).
- Local symbols begin with a percent symbol (`%`).
- All symbols must be declared or defined.
- If in doubt, consult the Language Reference Manual: https://llvm.org/docs/LangRef.html


# References

* https://blog.piovezan.ca/ by Felipe de Azevedo
* Felipe de Azevedo full animation of the LLVM IR presentation:https://blog.piovezan.ca/compilers/llvm_ir_animation/llvm_ir.html
* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation)
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf)
