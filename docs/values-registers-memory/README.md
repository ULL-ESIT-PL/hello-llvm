
# LLVM's IR Core Concepts - Values, Registers, Memory, Instructions,  Phi Instructions

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

## Phi Instructions

See section [phi-instructions/README.md](/docs/phi-instructions/README.md)

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

## A simple example of translation from Dragon to LLVM IR

Let us consider the following simple Dragon program:


`➜  dragon2js git:(LLVM-simple-assign) cat examples/llvm/llvm-0-int.drg`
```C
{
    print(0);
}
```     
When we compile this program to LLVM IR, with the dragon transpiler using the option `-g llvm`:

`➜  dragon2js git:(LLVM-simple-assign) bin/drg2js.cjs -g llvm examples/llvm/llvm-0-int.drg -o tmp/llvm-0.ll`
```                                   
Output saved to tmp/llvm-0.ll
➜  dragon2js git:(LLVM-simple-assign) cat tmp/llvm-0.ll
```

we get the following LLVM IR code:
```ll
; ModuleID = 'examples/llvm/llvm-0-int.drg'
source_filename = "examples/llvm/llvm-0-int.drg"

; Standard declarations
declare i32 @printf(i8*, ...)
declare i32 @sprintf(i8*, i8*, ...)
declare i8* @strcpy(i8*, i8*)
declare i8* @strcat(i8*, i8*)
declare i64 @strlen(i8*)
declare i8* @malloc(i64)
declare void @free(i8*)
declare i32 @memcmp(i8*, i8*, i64)

; LLVM intrinsics for memory operations
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)

; String constants for print (will be populated when needed)
@.str.i32 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.double = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@.str.char = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
; String constants for sprintf (no newline)
@.str.i32.noline = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.double.noline = private unnamed_addr constant [3 x i8] c"%f\00", align 1


define i32 @main() {
  %tmp_a = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0), i32 0)
  ret i32 0
}
```


### 1. Cabecera del módulo

```ll
; ModuleID = 'examples/llvm/llvm-0-int.drg'
source_filename = "examples/llvm/llvm-0-int.drg"
```

Metadatos: identifican de qué archivo fuente proviene este IR. Los `;` son comentarios.

### 2. Declaraciones externas (`declare`)

```ll
declare i32 @printf(i8*, ...)
declare i8* @malloc(i64)
declare void @free(i8*)
; ...etc
```

Son como los **prototipos de funciones en C** — le dicen al compilador que estas funciones existen en alguna librería externa (libc), pero no las define aquí. Algunos tipos:

| Tipo LLVM | Equivalente en C |
|-----------|-----------------|
| `i32` | `int` (32 bits) |
| `i64` | `long` (64 bits) |
| `i8*` | `char*` (puntero) |
| `void` | `void` |

---

### 3. Constantes globales de strings

```ll
@.str.i32 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
```

Esto define el string `"%d\n"` en memoria global:
- `[4 x i8]` → array de 4 bytes
- `c"%d\0A\00"` → los caracteres `%`, `d`, `\n` (0x0A), y `\0` (terminador nulo)
- `private` → solo visible dentro de este módulo
- `align 1` → alineado a 1 byte

Son los **format strings** que usará `printf` y `sprintf`.

---

### 4. La función `main`

```ll
define i32 @main() {
  %tmp_a = call i32 (i8*, ...) @printf(
    i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0),
    i32 0
  )
  ret i32 0
}
```

Esto equivale exactamente a este código en C:

```c
int main() {
    printf("%d\n", 0);
    return 0;
}
```

Desglosando la llamada a `printf`:

- `%tmp_a` → variable temporal que guarda el valor de retorno de printf (cuántos caracteres imprimió)
- `getelementptr inbounds (...)` → es como hacer `&str[0]`, obtiene un puntero al primer byte del string `"%d\n"`
- `i32 0` → el entero `0` que se imprime

---


### Execution

To execute this IR, we can use `lli`, the LLVM interpreter:

```bash
➜  dragon2js git:(LLVM-simple-assign) lli tmp/llvm-0.ll
0
```

Véase sección [Running LLVM IR](/docs/running-llvm.md) para más detalles sobre cómo ejecutar IR.