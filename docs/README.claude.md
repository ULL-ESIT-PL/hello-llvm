# Pregunta

Existe algún ejemplo de como generar la representación intermedia de LLVM desde un AST compatible con Babel.JS? He escrito un parser para un lenguaje sencillo basado en uno descrito en los apéndices del libro del Dragón y que genera árboles compatibles con Babel.JS y quiero ahora producir código IR LLVM.

# Respuesta de Claude 

Hay ejemplos, pero son escasos y dispersos. El flujo más directo es usar **llvm-bindings** o **llvmjs** desde Node.js para recorrer el AST de Babel y emitir IR. Te muestro un ejemplo completo y funcional del patrón.

## La idea general

```
AST (Babel-compatible) → visitor que recorre nodos → LLVM IR via bindings
```

El recorrido usa `@babel/traverse` (o un visitor manual) sobre los nodos del AST, y por cada nodo emite instrucciones LLVM usando la API C++ expuesta en JS.

---

## Ejemplo: compilador de expresiones aritméticas a LLVM IR

Este ejemplo cubre el subconjunto del "lenguaje del Dragón": variables, asignaciones, expresiones binarias y una función `main` que devuelve el resultado.

### 1. Estructura del proyecto

```bash
npm install llvm-bindings @babel/traverse @babel/types
```

> `llvm-bindings` es el binding más mantenido actualmente. 
> Requiere LLVM instalado (`brew install llvm` / `apt install llvm-dev`).

---

### 2. El compilador

```js
// compiler.js
import llvm from 'llvm-bindings';
import traverse from '@babel/traverse';
import * as t from '@babel/types';

export function compileToIR(ast, moduleName = 'dragon') {
  // ── Inicialización del módulo LLVM ──────────────────────────
  const context = new llvm.LLVMContext();
  const module  = new llvm.Module(moduleName, context);
  const builder = new llvm.IRBuilder(context);

  const i32  = llvm.Type.getInt32Ty(context);
  const i32p = llvm.PointerType.get(i32, 0);

  // ── Crear función main: i32 main() ──────────────────────────
  const mainType = llvm.FunctionType.get(i32, [], false);
  const mainFn   = llvm.Function.Create(
    mainType,
    llvm.Function.LinkageTypes.ExternalLinkage,
    'main',
    module
  );
  const entry = llvm.BasicBlock.Create(context, 'entry', mainFn);
  builder.SetInsertPoint(entry);

  // ── Tabla de símbolos: nombre → alloca ───────────────────────
  const symbols = new Map();

  function getOrCreateVar(name) {
    if (!symbols.has(name)) {
      // alloca al inicio del bloque de entrada (práctica estándar)
      const savedIP = builder.saveIP();
      builder.SetInsertPoint(entry, entry.begin());
      const alloca = builder.CreateAlloca(i32, null, name);
      builder.restoreIP(savedIP);
      symbols.set(name, alloca);
    }
    return symbols.get(name);
  }

  // ── Emisión de expresiones ───────────────────────────────────
  function emitExpr(node) {
    // Literal numérico: 42
    if (t.isNumericLiteral(node)) {
      return llvm.ConstantInt.get(i32, node.value, true);
    }

    // Identificador: x
    if (t.isIdentifier(node)) {
      const alloca = getOrCreateVar(node.name);
      return builder.CreateLoad(i32, alloca, node.name);
    }

    // Expresión binaria: a + b, a - b, a * b, a / b
    if (t.isBinaryExpression(node)) {
      const left  = emitExpr(node.left);
      const right = emitExpr(node.right);
      switch (node.operator) {
        case '+': return builder.CreateAdd(left, right, 'addtmp');
        case '-': return builder.CreateSub(left, right, 'subtmp');
        case '*': return builder.CreateMul(left, right, 'multmp');
        case '/': return builder.CreateSDiv(left, right, 'divtmp');
        default:
          throw new Error(`Operador no soportado: ${node.operator}`);
      }
    }

    // Asignación usada como expresión: (x = expr)
    if (t.isAssignmentExpression(node) && node.operator === '=') {
      const val    = emitExpr(node.right);
      const alloca = getOrCreateVar(node.left.name);
      builder.CreateStore(val, alloca);
      return val;
    }

    throw new Error(`Nodo de expresión no soportado: ${node.type}`);
  }

  // ── Emisión de sentencias ────────────────────────────────────
  function emitStmt(node) {
    // var x = expr;  o  let x = expr;
    if (t.isVariableDeclaration(node)) {
      for (const decl of node.declarations) {
        const alloca = getOrCreateVar(decl.id.name);
        if (decl.init) {
          const val = emitExpr(decl.init);
          builder.CreateStore(val, alloca);
        }
      }
      return;
    }

    // x = expr;  (ExpressionStatement con AssignmentExpression)
    if (t.isExpressionStatement(node)) {
      emitExpr(node.expression);
      return;
    }

    // return expr;
    if (t.isReturnStatement(node)) {
      const val = node.argument
        ? emitExpr(node.argument)
        : llvm.ConstantInt.get(i32, 0, true);
      builder.CreateRet(val);
      return;
    }

    throw new Error(`Sentencia no soportada: ${node.type}`);
  }

  // ── Recorrer el cuerpo del programa ─────────────────────────
  // Asume que el AST tiene un Program > body con statements,
  // o directamente un array de nodos.
  const body = ast.type === 'Program' ? ast.body : ast;
  for (const stmt of body) {
    emitStmt(stmt);
  }

  // Si no se emitió un return explícito, retornar 0
  const lastBlock = builder.GetInsertBlock();
  if (!lastBlock.getTerminator()) {
    builder.CreateRet(llvm.ConstantInt.get(i32, 0, true));
  }

  // ── Verificar y devolver el módulo ───────────────────────────
  if (llvm.verifyModule(module)) {
    throw new Error('Módulo LLVM inválido:\n' + module.print());
  }

  return module;
}
```

---

### 3. Uso con tu parser

```js
// index.js
import { parse } from './tu-parser.js';       // tu parser del Dragón
import { compileToIR } from './compiler.js';
import { writeFileSync } from 'fs';

const source = `
  var x = 3;
  var y = 4;
  var z = x * y + 2;
  return z;
`;

const ast = parse(source);        // genera AST compatible con Babel
const mod = compileToIR(ast);

// Emitir el IR como texto (.ll) para inspeccionarlo
writeFileSync('output.ll', mod.print());
console.log(mod.print());
```

El `.ll` resultante para ese input será algo así:

```llvm
define i32 @main() {
entry:
  %x = alloca i32
  %y = alloca i32
  %z = alloca i32
  store i32 3, i32* %x
  store i32 4, i32* %y
  %x1 = load i32, i32* %x
  %y2 = load i32, i32* %y
  %multmp = mul i32 %x1, %y2
  %addtmp = add i32 %multmp, i32 2
  store i32 %addtmp, i32* %z
  %z3 = load i32, i32* %z
  ret i32 %z3
}
```

---

### 4. Compilar y ejecutar el IR

```bash
# Compilar .ll a ejecutable
llc output.ll -filetype=obj -o output.o
clang output.o -o output
./output; echo $?   # imprime 14  (3*4+2)

# O ejecutarlo directamente con el intérprete
lli output.ll
echo $? # 14
```

---

## Pasos siguientes naturales

El ejemplo cubre el núcleo. Las extensiones más directas para un lenguaje del Dragón completo son, en orden de dificultad:

**Comparaciones y control de flujo** — `if/else` requiere emitir múltiples `BasicBlock` y conectarlos con `CreateCondBr`. Es el salto más importante.

**Bucles** — `while` añade un bloque de condición, uno de cuerpo y uno de salida; se conectan con `CreateBr` y `CreateCondBr`.

**Funciones** — declarar `FunctionType`, crear un `Function` nuevo con su propio `entry` block, y pasar argumentos por valor (o por `alloca` si se reasignan dentro).

**Paso a mem2reg** — el patrón `alloca/store/load` que usa el ejemplo es deliberado: genera IR válido pero no óptimo. El pass `mem2reg` de LLVM lo convierte automáticamente a forma SSA con `phi` nodes, que es la forma canónica. Se añade con una sola llamada al `PassManager`.

¿Tienes ya el parser funcionando y quieres que adapte el `emitStmt`/`emitExpr` a los tipos de nodo exactos que genera tu parser?