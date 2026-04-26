
# A simple example of translation from Dragon to LLVM IR

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

## generateIR

Notice that our translator needs a template of standard declarations and string constants to be able to generate the IR for our simple `print(0)` statement. Here is an excerpt of the code that generates the IR:

```js
const traverse = require('@babel/traverse').default;
const CodegenContext = require('./context.cjs');
const { dragonTypeToLLVM, dragonArrayTypeToLLVM, getFormatStringConst } = require('./type-helpers.cjs');
const { escapeLLVMString } = require('./string-helpers.cjs');

function generateModuleStub(sourceFile) {
    return `; ModuleID = '${sourceFile || "<stdin>"}'
source_filename = "${sourceFile || "<stdin>"}"

; Standard declarations
   ... 
`;
}
function generateIR(ast, options = {}, source, sourceFile) {
    const ctx = new CodegenContext();
    const nodeValues = new Map();
    const visitors = {
        StringLiteral(path) {
          ...
        },
        BlockStatement: {
            enter() { ctx.enterScope(); },
            exit() { ctx.exitScope(); }
        },
        VariableDeclarator: {
            ...
        },
        NumericLiteral(path) {
            const node = path.node;
            const value = node.value;
            const type = node._type || { baseType: Number.isInteger(value) ? 'int' : 'float' };
            nodeValues.set(node, {
                value: String(value),
                type: type,
                isLiteral: true
            });

        },
        Identifier(path) {
           ...
        },
        MemberExpression: {
           ...
        },
        ...
    };
    traverse(ast, { noScope: true, ...visitors });
    const preamble = generateModuleStub(sourceFile);
    const globals = ctx.globals.length ? ctx.globals.join('\n') + '\n' : '';
    const mainFunc = `\ndefine i32 @main() {\n${ctx.getCode()}\n  ret i32 0\n}\n`;
    return {
        code: preamble + globals + mainFunc,
        map: null // Source maps are not supported  by the llv compiler, so we return null here.
    };
}
```
## Module Header: generateModuleStub

```ll
; ModuleID = 'examples/llvm/llvm-0-int.drg'
source_filename = "examples/llvm/llvm-0-int.drg"
```

Metadata: identifies the source file of this IR. The semicolons (`;`) are comments.

### External Declarations (`declare`)

```ll
declare i32 @printf(i8*, ...)
declare i8* @malloc(i64)
declare void @free(i8*)
; ...etc
```

These are like **function prototypes in C** — they tell the compiler that these functions exist in an external library (libc), but don't define them here. Some types:

| LLVM Type | C Equivalent |

|-----------|-----------------|
| `i32` | `int` (32-bit) |
| `i64` | `long` (64-bit) |
| `i8*` | `char*` (pointer) |
| `void` | `void` |

---

## Globals

### Global String Constants

```ll
@.str.i32 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
```

This defines the string `"%d\n"` in global memory:
- `[4 x i8]` → 4-byte array
- `c"%d\0A\00"` → the characters `%`, `d`, `\n` (0x0A), and `\0` (null terminator)
- `private` → visible only within this module
- `align 1` → aligned to 1 byte

These are the **format strings** that `printf` and `sprintf` will use.


` ... ---

### The `main` function

```ll
define i32 @main() { 
%tmp_a = call i32 (i8*, ...) @printf( 
i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0), 
i32 0 
) 
ret i32 0
}
```

### @printf line breakdown

This line

```ll 
%tmp_a = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0), i32 0)
```

is a call to `printf("%d\n", 0)`. Let's go part by part:

---

### General Structure

```
%tmp_a = call i32 (i8*, ...) @printf( ARG1, ARG2 )
│ │ │
│ │ └─ function to call
│ └─ return type (int = number of characters printed)
└─ variable that stores the return value (how many characters were printed)
```

---

### ARG1 — the format string

```ll
i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0)
```

This gets a pointer to the string `"%d\n"`. Broken down:

| Part | Meaning |

|---|---|

`i8*` | the result is a `char*` |

`getelementptr inbounds` | "give me the address of this element" (like `&array[i]` in C) |

`[4 x i8]` | the array type (4 bytes) |

`[4 x i8]* @.str.i32` | pointer to the global array `"%d\n\0"` |

`i64 0` | index of the outer array (the array itself) |

`i64 0` | index of the inner element (first byte, `'%'`) |

In C, this is simply equivalent to: `"%d\n"` — or more precisely, `&str[0]`.

The double `0, 0` is because in LLVM IR global arrays have **two levels of indirection**, and both must be traversed to reach the first byte.

See the section [getelmentptr](/docs/arrays-and-getelementptr/README.md)

---

### ARG2 — the value to print

```ll
i32 0
```

Simply the integer `0`. It is the value that replaces `%d` in the format string.


---

$2 Execution

To execute this IR, we can use `lli`, the LLVM interpreter:

```bash
➜ dragon2js git:(LLVM-simple-assign) lli tmp/llvm-0.ll
0
```

See the sections:

- [Running LLVM IR](/docs/running-llvm.md) for more details on how to run IRs.

- [Linking LLVM IR Modules](/docs/syntax/linker.md) for details on how to combine multiple IR modules.