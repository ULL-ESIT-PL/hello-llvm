
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

## Cabecera del módulo: generateModuleStub

```ll
; ModuleID = 'examples/llvm/llvm-0-int.drg'
source_filename = "examples/llvm/llvm-0-int.drg"
```

Metadatos: identifican de qué archivo fuente proviene este IR. Los `;` son comentarios.

### Declaraciones externas (`declare`)

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

## Globals

### Constantes globales de strings

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

### La función `main`

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

### Desglose de la línea @printf

Esta línea 

```ll
  %tmp_a = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0), i32 0)
```

es una llamada a `printf("%d\n", 0)`. Vamos parte por parte:

---

### Estructura general

```
%tmp_a = call i32 (i8*, ...) @printf( ARG1, ARG2 )
│              │               │
│              │               └─ función a llamar
│              └─ tipo de retorno (int = nº chars impresos)
└─ variable que guarda el valor de retorno (cuántos caracteres imprimió)
```

---

### ARG1 — el format string

```ll
i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.i32, i64 0, i64 0)
```

Esto obtiene un puntero al string `"%d\n"`. Desglosado:

| Parte | Significado |
|---|---|
| `i8*` | el resultado es un `char*` |
| `getelementptr inbounds` | "dame la dirección de este elemento" (como `&array[i]` en C) |
| `[4 x i8]` | el tipo del array (4 bytes) |
| `[4 x i8]* @.str.i32` | puntero al array global `"%d\n\0"` |
| `i64 0` | índice del array exterior (el array en sí) |
| `i64 0` | índice del elemento interior (primer byte, `'%'`) |

En C equivale simplemente a: `"%d\n"` — o más precisamente, `&str[0]`.

El doble `0, 0` es porque en LLVM IR los arrays globales tienen **dos niveles de indirección**, y hay que "atravesar" ambos para llegar al primer byte.

Véase la sección [getelmentptr](/docs/arrays-and-getelementptr/README.md)

---

### ARG2 — el valor a imprimir

```ll
i32 0
```

Simplemente el entero `0`. Es el valor que reemplaza al `%d` en el format string.

---


$2 Execution

To execute this IR, we can use `lli`, the LLVM interpreter:

```bash
➜  dragon2js git:(LLVM-simple-assign) lli tmp/llvm-0.ll
0
```

Véanse las secciones 

- [Running LLVM IR](/docs/running-llvm.md) para más detalles sobre cómo ejecutar IR.
- [Linking LLVM IR Modules](/docs/syntax/linker.md) para detalles sobre cómo combinar varios módulos IR.


