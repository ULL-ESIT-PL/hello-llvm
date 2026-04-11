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

But you need to have debug metadata (`!dbg`) in your IR for this to be useful. Otherwise, you’ll just see assembly-level instructions without source mapping.

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

# 🔥 8. Use `-debug` flags in LLVM tools

Some passes support:

```bash
opt -debug-pass-manager your.ll
```

👉 Shows which passes run and what they do

--