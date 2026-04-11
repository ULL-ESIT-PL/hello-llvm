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

## Goals of the IR

In the compilation pipeline, the IR sits between representations specific to
source languages and representations specific to the target machine:

![](https://github.com/felipepiovezan/felipepiovezan.github.io/raw/main/docs/compilers/llvm_ir_p1/ir_position.svg)

We can derive some of its design goals from where the IR is positioned in the
compilation pipeline. It must be:

* Able to represent concepts from any high level language,
* Amenable to analysis required by "optimizing" transformations,
* Able to represent concepts required by target specific representations.

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

See also [signed vs unsigned in LLVM IR](signed-or-unsigned.md)

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

## Garbage Collection and Memory Management

See section [How is memory management in LLVM? is there some sort of garbage collector available?](garbage-collector.md)

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
`Functions`, the memory allocated by an `alloca` is [automatically freed when
the `Function` exits](garbage-collector.md).

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

Modules may be combined together with the [LLVM linker](linker.md), which merges function (and global variable) definitions, resolves forward declarations, and merges symbol table entries. 

## Target Information 

The target information section describes the architecture and platform for which the IR is intended. For example, in the data layout it may specify the endianness, the Executable and Linkable Format ([ELF](elf.md)) [mangling](name-mangling.md), the Application Binary Interface ([ABI](abi.md)) alignment, the native integer widths, etc. The target triple specifies the architecture, vendor, operating system, the ABI and sometimes the environment to refine an ABI variant of the runtime ecosystem. 


![](/docs/images/target-information.png)

See [docs/syntax/target-information.md](target-information.md)

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

### Function Declarations 
A function _declaration_ in LLVM IR has the following syntax:

```llvm
declare i64 @foo(i64, ptr)
```

* A keyword `declare`,
* The return type (`i64`),
* The symbol name (`foo`),
* The list of parameter types (`i64`, `ptr`).

### Function Definitions

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

### The structure of functions

![](/docs/images/functions.png)

## Further Reading

It is a useful exercise to read the LLVM documentation on some of the topics
discussed:

* The existing [linkage types](https://llvm.org/docs/LangRef.html#linkage-types). There are a lot of subtle variations between
the two extremes of: "this symbol is only visible in this Module" and "this
symbol is visible in all Modules"
* The full specification for [functions](https://llvm.org/docs/LangRef.html#functions) and [global variables](https://llvm.org/docs/LangRef.html#global-variables). Don't try to understand everything there, but note how many details can be added to those
global symbols.

# The Body of a Function

## Basic Blocks 

A basic block is straight-line code sequence with no branches in except to the entry and no branches out except at the exit. Basic blocks are used to structure the control flow of a function.

1. A function is made up of one or more basic blocks. 
2. Each basic block has a unique name, and 
3. the first instruction of a basic block is called its **header**. 
4. The last instruction of a basic block is called its **terminator**, and it must be a control flow instruction that determines where the control goes next.

## Virtual Registers

Virtual registers are "local" variables.They come in two flavors: **named** and **unnamed**. 

- **Named** virtual registers have names starting with the `%` symbol, for example: `%result`, `%hi`, `%___`. 
- **Unnamed** virtual registers are automatically generated by the IR parser/printer and have names like `%1`, `%2`, etc. **They must be sequentially numbered**.

## Terminator Instructions 

A **terminator** is the last instruction of a basic block.
It decides where control goes next (or ends execution of the function path). Every basic block must end with exactly one terminator.

Common terminators:
* `ret`
* `br`
* `switch`
* `indirectbr`
* `invoke`
* `callbr`
* `resume`
* `catchswitch`
* `catchret`
* `cleanupret`
* `unreachable`


## Labels

LLVM IR uses two forms for the same basic block name:

1. **Definition form** (block header): no percent sign
    ```llvm
    3:
    ```
2. **Reference form** (used by branch/phi): with percent sign
    ```llvm
    br i1 %2, label %7, label %3
    %8 = phi i32 [ %6, %3 ], [ 1, %1 ]
    ```

So `3:` defines block `%3`.

How labels work in practice:

- A basic block is defined as `label_name`:.
- Any instruction that points to that block uses label `%label_name`.
- Auto-generated numeric labels are common (`1`, `3`, `7`, etc.).
- Human-readable labels are also valid:

  ```llvm
  entry:
  br label %recurse
  
  recurse:
  br label %exit
  
  exit:
  ret i32 0
  ```

The same rule applies: defined as `entry:`, referenced as `%entry`.

## Phi instructions

A `phi` instruction is LLVM’s way of saying:

> Choose a value depending on which control-flow edge just arrived at this block.

In Single-Static-Assignment (SSA) form, **each register** is assigned exactly once. When two or more branches join, LLVM cannot *reassign* a variable, so it uses `phi` to merge possible incoming values.

Consider this implementation of the `factorial` function:

```ll 
define i32 @factorial(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq i32 %0, 0         ; Compare input to 0
  br i1 %2, label %7, label %3   ; If %2 (input is 0) jump to %7

3:                               ; preds = %1
  %4 = add nsw i32 %0, -1        ; Compute n-1
  %5 = call i32 @factorial(i32 noundef %4)
  %6 = mul nsw i32 %5, %0        ; Compute n * factorial(n-1)
  br label %7

7:                               ; preds = %1, %3 ; block 7 can be reached from %1 and %3
  %8 = phi i32 [ %6, %3 ], [ 1, %1 ]
  ret i32 %8
}
```

In this example:

```llvm
7:
  %8 = phi i32 [ %6, %3 ], [ 1, %1 ]
  ret i32 %8
```

means:

- if control reaches block `7` from block `%3`, then `%8 = %6`
- if control reaches block `7` from block `%1`, then `%8 = 1`

So it depends on the predecessor block, not on a runtime *switch* inside the block itself.

How it works conceptually:
1. Earlier blocks compute different candidate values.
2. Control-flow merges at a join block.
3. The `phi` instruction picks the value associated with the predecessor edge that was actually taken.

So in our factorial:

- if `%0 == 0`, execution jumps directly from `%1` to `%7`, and `%8` becomes `1`
- otherwise execution goes through block `%3`, computes `%6 = %5 * %0`, then jumps to `%7`, and `%8` becomes `%6`

Equivalent high-level idea:

```c
int tmp;
if (value == 0)
  tmp = 1;
else
  tmp = recursive_result * value;
return tmp;
```

But in SSA, `tmp` cannot be assigned twice, so LLVM uses `phi`.

Two important rules:
- `phi` instructions **must appear at the beginning of a basic block**.
- They only refer to predecessor blocks of that block.

The attribute [local_unnamed_addr](local_unnamed_addr.md) qualifying `@factorial` means that the function's address is not significant. Te `#0` is a [reference to a function attribute group](local_unnamed_addr.md#the-meaning-of-0-in-the-function-header). These two tell us the huge amount of details that have beend added by the C++ to IR translation.

# Visualizing the Control Flow Graph, Regions, Dominator Trees, Call Graphs, etc.   

See section [docs/visualizing/control-flow-graph.md](/docs/visualizing/control-flow-graph.md)


# Arrays and getelementptr

## One dimensional arrays

To create an array in LLVM IR, we can use the `alloca` instruction to allocate memory for the array:

```ll
%arr = alloca [5 x i32], align 16
```
This allocates memory for an array of 5 integers (`i32`) and returns a pointer to the array, which is stored in the register `%arr`. The `align 16` specifies that the memory should be aligned to a 16-byte boundary.

To access elements of the array, we can use the `getelementptr` instruction, which computes the address of a specific element in the array. For example, to access the first element of the array, we can do:

```ll
%p0 = getelementptr [5 x i32], ptr %arr, i64 0, i64 2
```
The first index `0` is convenient because each index reduces the type of the pointer by one level. The first index reduces the pointer from `ptr` to `[5 x i32]*` to `i32*`. This means "get the address of the element at index 2 of the array pointed to by `%arr` at offset `0`". For one dimensional arrays, we can omit the first index, which is always `0`, and simplify it to

```ll
%p0 = getelementptr [5 x i32], ptr %arr, i64 2
```
This computes the address of the third element of the array and stores it in the register `%p0`. The `i64 2` is the index for the element. See file [/examples/hello-array.ll](/examples/hello-array.ll) for the actual code.

```ll
declare i32 @printf(ptr noundef, ...)

define void @printArray(ptr noundef %arr, i32 noundef %N) { 
    ;... ommitted for brevity
}

define i32 @main() {
entry:
  %arr = alloca [5 x i32], align 16

  %p0 = getelementptr i32, ptr %arr, i64 0
  store i32 1, ptr %p0, align 4

  %p1 = getelementptr i32, ptr %arr, i64 1 ; Notice the i32 base type used 
  store i32 2, ptr %p1, align 4

  %p2 = getelementptr i32, ptr %arr, i64 2
  store i32 3, ptr %p2, align 4

  %p3 = getelementptr i32, ptr %arr, i64 3
  store i32 4, ptr %p3, align 4

  %p4 = getelementptr i32, ptr %arr, i64 4
  store i32 5, ptr %p4, align 4

  %arr0 = getelementptr i32, ptr %arr, i64 0
  call void @printArray(ptr noundef %arr0, i32 noundef 5)

  ret i32 0
}
```

The `@printArray(ptr noundef %arr, i32 noundef %N)` function takes a pointer to the first element of the array `%arr` and its size `%N`, and prints the elements of the array. Both parameters are given the [noundef attribute](noundef.md), which means that they cannot be `undef` values.

## Multi-dimensional arrays

To create a multi-dimensional array, we can use nested `alloca` instructions. For example, to create a 3x3 matrix `%M` of `i32`integers, we can do:

```ll
%M = alloca [3 x [3 x i32]], align 16
```

To set the element in the second row and third column of the matrix to `4`, the resulting instruction looks like this:

```ll
%p12 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 2
store i32 4, ptr %p12, align 4
```

The `getelementptr` instruction computes the address of the element at position `[1,2]`.

**We need three indices** to access the element at position `[1,2]` (remember that indices are zero-based).

- **The first index must be `0`** because it reduces the dimension of the pointer from `ptr` to `[3 x [3 x i32]]*` to `[3 x i32]`.
- The second index is `1` because it reduces the dimension of the pointer from `[3 x i32]` to `i32`, and it also selects the second row of the matrix. 
- The third index `2` is now an `i32` offset. 

## Alignment and Padding: struct types and getelementptr

For `struct` types, `getelementptr` also accounts for field alignment and padding automatically. See [struct-padding.md](struct-padding.md) for a short note and the examples [/examples/types.ll](/examples/types.ll) and [/examples/types-gep.ll](/examples/types-gep.ll).


See [/examples/hello-array2.ll](/examples/hello-array2.ll) for the actual code.

```ll 
@.fmt = private unnamed_addr constant [4 x i8] c"%d \00"
@.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
declare i32 @printf(ptr noundef, ...)
define void @printMatrix(ptr noundef %m, i32 noundef %N) {
; ... ommitted for brevity
}

define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %p00 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 0
  store i32 1, ptr %p00, align 4

  %p01 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 1 ; Notice the base type [3 x [3 x i32]] used here.
  store i32 0, ptr %p01, align 4 

  %p02 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 2
  store i32 0, ptr %p02, align 4

  %p10 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 0
  store i32 0, ptr %p10, align 4

  %p11 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 1
  store i32 1, ptr %p11, align 4

  %p12 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 2
  store i32 0, ptr %p12, align 4

  %p20 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 0
  store i32 0, ptr %p20, align 4

  %p21 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 1
  store i32 0, ptr %p21, align 4

  %p22 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 2
  store i32 1, ptr %p22, align 4

  %base = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}
```

## Simplifying access specificating the base type

The `getelementptr` instruction can be simplified by specifying the base type of the pointer. For example, if we specify the base type as `[3 x i32]` instead of `[3 x [3 x i32]]`, we can omit the first index, which is always `0`, and simplify the instruction to:

```ll 
define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %p00 = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  store i32 1, ptr %p00, align 4

  %p01 = getelementptr [3 x i32], ptr %M, i64 0, i64 1
  store i32 0, ptr %p01, align 4

  %p02 = getelementptr [3 x i32], ptr %M, i64 0, i64 2
  store i32 0, ptr %p02, align 4

  %p10 = getelementptr [3 x i32], ptr %M, i64 1, i64 0
  store i32 0, ptr %p10, align 4

  %p11 = getelementptr [3 x i32], ptr %M, i64 1, i64 1
  store i32 1, ptr %p11, align 4

  %p12 = getelementptr [3 x i32], ptr %M, i64 1, i64 2
  store i32 0, ptr %p12, align 4

  %p20 = getelementptr [3 x i32], ptr %M, i64 2, i64 0
  store i32 0, ptr %p20, align 4

  %p21 = getelementptr [3 x i32], ptr %M, i64 2, i64 1
  store i32 0, ptr %p21, align 4

  %p22 = getelementptr [3 x i32], ptr %M, i64 2, i64 2
  store i32 1, ptr %p22, align 4

  %base = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}
```

See the file [/examples/hello-array2-simplified.ll](/examples/hello-array2-simplified.ll) for the actual code.

Example [examples/hello-array2-simplified2.ll](/examples/hello-array2-simplified2.ll) shows how can we access to thw rows of the matrix by specifying the base type as `[3 x i32]` :

```ll
define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %firstRow = getelementptr [3 x i32], ptr %M, i64 0
  call void @initializeRow(ptr noundef %firstRow, i32 noundef 3, i32 0)

  %secondRow = getelementptr [3 x i32], ptr %M, i64 1
  call void @initializeRow(ptr noundef %secondRow, i32 noundef 3, i32 1)
    
  %thirdRow = getelementptr [3 x i32], ptr %M, i64 2
  call void @initializeRow(ptr noundef %thirdRow, i32 noundef 3, i32 2)

  %base = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}
```

## The getelementptr syntax

![/docs/images/getelementptr-syntax.png](/docs/images/getelementptr-syntax.png)

The **base type** determines how offsets are calculated. The first index multiplies by the size of the base type, the second index multiplies by the size of the type of the first index, and so on. 




# References

* https://blog.piovezan.ca/ by Felipe de Azevedo
* Felipe de Azevedo full animation of the LLVM IR presentation:https://blog.piovezan.ca/compilers/llvm_ir_animation/llvm_ir.html
* [LLVM IR Tutorial - Phis, GEPs and other things, oh my!](https://youtu.be/m8G_S5LwlTo?si=aquQxzfpFCdZtdEi) By Vince Bridgers (Intel Corporation), Felipe de Azevedo Piovezan (Intel Corporation)
    * [Slides](https://llvm.org/devmtg/2019-04/slides/Tutorial-Bridgers-LLVM_IR_tutorial.pdf)
