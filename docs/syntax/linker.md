# Linking LLVM IR Modules

In LLVM, you can have multiple IR modules (files) that define different functions and global variables. To create a complete program, you often need to link these modules together. The LLVM linker (`llvm-link`) is a tool that merges multiple LLVM IR files into a single module.

Link at LLVM IR level first, then build executable
```bash
llvm-link examples/factorial-main.ll examples/factorial.ll -o tmp/combined.ll
```
Then compile the combined IR to an executable:
```
clang tmp/combined.ll -o tmp/f
```

Let clang do it directly from multiple IR files
```bash
clang examples/factorial-main.ll examples/factorial.ll -o tmp/f
```

On Linux/Codespaces, these sample `.ll` files may need an explicit Linux target because they were generated on macOS:

```bash
clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f
```

So:
- [llvm-link](https://llvm.org/docs/CommandGuide/llvm-link.html) merges modules into one LLVM module. The linker resolves references between the modules, so if `a.ll` calls a function defined in `b.ll`, the linker will connect them.

- clang can absolutely be used for linking, and in practice it is usually the easiest driver.

- If you go through [llc](https://llvm.org/docs/CommandGuide/llc.html) (producing `.s`), then use `clang` for final link:
  
    ```bash
    llc examples/factorial.ll -o tmp/factorial.s
    llc examples/factorial-main.ll -o tmp/factorial-main.s 
    clang tmp/factorial-main.s tmp/factorial.s -o tmp/f
    ```

## Example

The following example is the translation of the Dragon source code:


`➜  dragon2js git:(LLVM-simple-factorized) cat examples/char/charsum.drg`
```C  
{
    print("hello" + " world!"); // Since we rely on JS it will concatenate
}
```

```
➜  dragon2js git:(LLVM-simple-factorized) bin/drg2js.cjs -g llvm examples/char/charsum.drg -o tmp/charsum.ll
Output saved to tmp/charsum.ll
``` 

The resulting LLVM IR code is in `tmp/charsum.ll`:

```ll
➜  dragon2js git:(LLVM-simple-factorized) cat tmp/charsum.ll
; ModuleID = 'examples/char/charsum.drg'
source_filename = "examples/char/charsum.drg"

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

@.strlit.0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@.strlit.3 = private unnamed_addr constant [8 x i8] c" world!\00", align 1

define i32 @main() {
  %tmp_b = call i8* @malloc(i64 6)
  %tmp_c = getelementptr inbounds [6 x i8], [6 x i8]* @.strlit.0, i64 0, i64 0
  call i8* @strcpy(i8* %tmp_b, i8* %tmp_c)
  %tmp_e = call i8* @malloc(i64 8)
  %tmp_f = getelementptr inbounds [8 x i8], [8 x i8]* @.strlit.3, i64 0, i64 0
  call i8* @strcpy(i8* %tmp_e, i8* %tmp_f)
  %tmp_g = call i64 @strlen(i8* %tmp_b)
  %tmp_h = call i64 @strlen(i8* %tmp_e)
  %tmp_i = add i64 %tmp_g, %tmp_h
  %tmp_j = add i64 %tmp_i, 1
  %tmp_k = call i8* @malloc(i64 %tmp_j)
  call i8* @strcpy(i8* %tmp_k, i8* %tmp_b)
  call i8* @strcat(i8* %tmp_k, i8* %tmp_e)
  %tmp_l = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.char, i64 0, i64 0), i8* %tmp_k)
  ret i32 0
}
```

## LLVM IR — Explicación

Este código es **LLVM IR** (Intermediate Representation), el "lenguaje ensamblador de alto nivel" que usa el compilador LLVM como paso intermedio antes de generar código máquina.

---

### La cabecera: declaraciones externas

```ll
declare i32 @printf(i8*, ...)
declare i8* @strcpy(i8*, i8*)
...
```

Son declaraciones de funciones externas de la **libc estándar de C** — le dice a LLVM "estas funciones existen en alguna librería, no las definas aquí".

---

### Constantes globales

```ll
@.str.char.0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@.str.char.1 = private unnamed_addr constant [8 x i8] c" world!\00", align 1
```

Dos strings almacenados en memoria estática (como `const char*` en C). El `\00` es el **null terminator**.

---

### La función `main` — paso a paso

Lo que hace en conjunto es equivalente a este C:

```c
int main() {
    char *a = "hello";
    char *b = " world!";
    char *buf = malloc(strlen(a) + strlen(b) + 1);
    strcpy(buf, a);
    strcat(buf, b);
    printf("%s\n", buf);
    return 0;
}
```

| Instrucción IR | Qué hace |
|---|---|
| `getelementptr` | Obtiene el puntero al primer carácter de cada string (`&str[0]`) |
| `call @strlen` x2 | Mide la longitud de cada string |
| `add ... +1` | Suma las longitudes + 1 byte para el `\0` final |
| `call @malloc` | Reserva memoria dinámica del tamaño exacto |
| `call @strcpy` | Copia `"hello"` al buffer |
| `call @strcat` | Concatena `" world!"` al buffer |
| `call @printf` | Imprime el resultado: **`hello world!`** |
| `ret i32 0` | Retorna 0 (éxito) |

---

### Detalles del tipo system

- `i8*` → puntero a byte (equivale a `char*` en C)
- `i32` → entero de 32 bits
- `i64` → entero de 64 bits (usado para tamaños/punteros en 64-bit)
- `[6 x i8]` → array de 6 bytes

---

### Contexto general

El comentario `ModuleID = 'examples/char/charsum.drg'` sugiere que este IR fue **generado por un compilador propio** (extensión `.drg`), no escrito a mano — es el output de un frontend de compilador que compila a LLVM.
Sí. Cuando invocas `clang archivo.ll -o salida`, clang actúa como **driver** y automáticamente:

1. **Compila** el IR a código objeto (`.o`)
2. **Linkea** contra la libc del sistema

Por eso los `declare` de `printf`, `malloc`, etc. funcionan sin que tú hagas nada — clang pasa por defecto algo equivalente a:

```bash
clang archivo.ll -o salida -lc
```

aunque ni siquiera necesitas escribir `-lc` explícitamente porque está incluido en los flags por defecto del driver.

---

### Si quisieras evitarlo

Para compilar **sin** linkear automáticamente:

```bash
clang -c archivo.ll -o archivo.o   # Solo compila, no linkea
```

O si quieres ver exactamente qué flags está pasando clang al linker:

```bash
clang archivo.ll -o salida -v
```

El `-v` te muestra el comando `ld` (o `lld`) completo que ejecuta internamente, donde verás cosas como `-lc`, el crt startup, etc.