
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

See [docs/syntax/target-information.md](/docs/syntax/target-information.md)

## Global Symbols

Global symbols are top-level `Value`s visible to the entire Module. Their names
always start with the `@` symbol, for example: `@x`, `@__foo` and `@main`.

Unlike registers, the name of a global symbol may have semantic meaning in the
program; in other words, global symbols have **[linkage](https://en.wikipedia.org/wiki/Linkage_(software))**. For example, a global
symbol may have `external` linkage, which means its name is visible to _other
Modules_. Or `internal` linkage, which means its name is only visible within the
same Module. For such a symbol, it would be illegal to rename it: doing so could
invalidate code in other Modules.

**Global symbols define memory regions allocated at compilation time**. For this
reason, the `Value` of a global symbol has a pointer type.

For example, if we declare a global variable of type `i32` called `x`, the type
of the `Value` `@x` is `i32*`. To access the underlying integer, we must first
load from that address.

There are two kinds of global symbols: **global variables** and **functions**.

## Global Variables

As a global symbol, global variables have a **name** and **linkage**. Additionally,
they require a **type** and a _constant_ **initial** `Value`:

### Example: `@gv1 = external global float 1.0`

```llvm
@gv1 = external global float 1.0
```

In this example, we have a global symbol that:

* Has name `gv1`.
* Has `external` linkage (its name is visible to other Modules).
* Is a `global` variable.
* Contains a `float` `Value`.
* Is initialized with `Value` `float 1.0`.

External linkage is the default and can be omitted:

```llvm
@gv1 = global float 1.0
```

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


### Another example `@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1`

See the code at [examples/factorial-main.ll](https://github.com/ULL-ESIT-PL/hello-llvm/blob/main/examples/factorial-main.ll#L6):

```ll
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
```

- `unnamed_addr`: This attribute tells LLVM that *the address of this global variable is not significant*—only its contents matter. This allows the optimizer to merge identical constants or move them around, since their address is not used for identity.
- `[4 x i8] c"%d\0A\00"`: This defines a constant array of 4 bytes (characters) initialized with the string `"%d\n"`. The `\0A` is the newline character, and `\00` is the null terminator. The type `[4 x i8]` indicates that this is an array of 4 bytes (8-bit integers).
- `align 1`: This specifies the alignment requirement for the variable in memory. align 1 means the variable can be placed at any byte boundary (no special alignment needed). 

### More examples in Compiler Explorer

You can see the following examples in action [in Godbolt Compiler Explorer](https://godbolt.org/z/4nbdede45).

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

* Name [mangling](/docs/syntax/name-mangling.md) can now be observed.
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
