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
