# Is there a way to debug LLVM IR?

Yes — and this is a *very* important skill once you start generating IR yourself. The good news is: LLVM gives you several complementary ways to “debug” IR, depending on what you mean by debugging.

Let me structure it in a way that fits your compiler work.

---

# 🧰 Debug like a normal program (with lldb)

Compile with debug info:

```bash
clang -g program.ll -o program
```

Then use [lldb](https://lldb.llvm.org/):

```bash
➜  hello-llvm git:(main) ✗ lldb tmp/struct 
(lldb) target create "tmp/struct"
Current executable set to '/Users/casianorodriguezleon/campus-virtual/2526/learning/llvm-learning/hello-llvm/tmp/struct' (x86_64).
```

👉 You can:

* set breakpoints (`main`)
* step instructions
* inspect variables

---
# 🧠 First level: **validate the IR (catch bugs early)**

Before even running anything:

👉 Use opt as a verifier (>= v21):

```bash
opt -passes=verify examples/struct.ll -disable-output
```
or 
```
opt -p=verify examples/struct.ll -disable-output
```

✔ Catches:

* type mismatches
* malformed CFG
* invalid `phi`
* broken SSA

---

# 🔍  Inspect transformations (super useful)

```bash
opt -S -passes=mem2reg your.ll
```

or:

```bash
opt -S -passes=instcombine your.ll
```

👉 This helps you understand:

* what *correct* IR looks like
* how your code compares to optimized IR

---

# 🧭 3. Visualize control flow 

See [/docs/visualizing/control-flow-graph.md](/docs/visualizing/control-flow-graph.md)
for details on how to visualize CFGs with Graphviz.

# 🧪 4. Execute IR step-by-step

Use the LLVM interpreter:

👉 lli

```bash
lli program.ll
```


# 🧠 Important caveat

Your IR must include debug metadata (`!dbg`) to get meaningful source mapping.

Without it:

* debugging still works
* but you’ll see assembly-level behavior

---

# 🔬 6. Print IR during compilation (very useful for you)

Since you generate IR:

👉 dump intermediate versions:

```js
console.log(ir);
```

or better:

* dump per function
* dump per AST node

---

# 🧱 7. Instrument your IR (my favorite for compilers)

Insert debug prints directly:

```llvm
call i32 (ptr, ...) @printf(ptr @.str, i32 %value)
```

👉 This is often the fastest way to debug:

* wrong values
* loop behavior
* array indexing

---

# 🔥 8. Use `-debug` flags in LLVM tools

Some passes support:

```bash
opt -debug-pass-manager your.ll
```

👉 Shows which passes run and what they do

---

# 🧪 9. Reduce bugs with `-O0` equivalent IR

Your IR currently looks like Clang `-O0` style (lots of `alloca`, `load`, `store`).

👉 That’s GOOD for debugging:

* easier to follow
* matches your AST closely

Later:

```bash
opt -passes=mem2reg
```

👉 converts to SSA → harder to debug but cleaner

---

# 🧠 10. Golden trick (very useful for your project)

👉 Compare your IR with Clang-generated IR

Example:

```c
// test.c
int x = 0;
while (x < 10) x++;
```

```bash
clang -S -emit-llvm test.c
```

👉 Then diff:

```bash
diff your.ll clang.ll
```

---

# 🧭 What I recommend for YOU

Given your setup (Babel AST → LLVM IR):

### Step 1

```bash
opt -verify your.ll
```

### Step 2

```bash
lli your.ll
```

### Step 3

Add `printf` instrumentation

### Step 4

Compare with Clang output

---

# 🚀 Advanced (later)

When you’re ready:

* generate `!dbg` metadata
* use `-fsanitize=address` via Clang
* use `opt -analyze` passes (domtree, loops, etc.)

---

# ✅ Summary

“Debugging LLVM IR” = combination of:

* ✔ verification (`opt -verify`)
* ✔ execution (`lli`)
* ✔ visualization (`-dot-cfg`)
* ✔ instrumentation (`printf`)
* ✔ comparison with Clang

---

# 💬 If you want next step

I can show you something very relevant to your compiler:

👉 how to map your Babel AST nodes → LLVM debug metadata (`!dbg`)
👉 so you can debug *your source language*, not just IR

That’s a big step toward a real compiler toolchain.
