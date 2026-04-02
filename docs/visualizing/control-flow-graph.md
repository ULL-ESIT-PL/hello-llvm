## Visualizing the Control Flow Graph (CFG)

Program Visualization using LLVM:

To visualize the Control Flow Graph (CFG)
With LLVM version 21:

```
➜  examples git:(main) ✗ clang -S -emit-llvm -fno-discard-value-names diag.c -o diag.ll
➜  examples git:(main) ✗ opt -passes=dot-cfg diag.ll -disable-output
Writing '.identity.dot'...
examples git:(main) ✗ dot -Tpng .identity.dot -o diag.png
```

Files:

- [diag.c](/examples/diag.c)
- [diag.ll](/examples/diag.ll)
- [.identity.dot](/examples/.identity.dot)
- [diag.png](/docs/images/diag.png) 

![/docs/images/diag.png](/docs/images/diag.png)

A **Control Flow Graph (CFG)** is a graphical representation of all paths that might be traversed through a program during its execution. 

**Key Components**

- **Nodes (Basic Blocks)**: Each node represents a Basic Block—a linear sequence of instructions with one entry point (the first instruction) and one exit point (the last instruction). There are no jumps into or out of the middle of the block.
- **Edges (Control Flow)**: Directed edges represent the flow of control. An edge from Block A to Block B means that Block B can execute immediately after Block A.
- **Entry and Exit**: The graph typically has a unique entry node (where the function starts) and may have one or more exit nodes (return statements or exits)

## dot-cfg-only vs dot-cfg

If we use `dot-cfg-only` instead of `dot-cfg`, the resulting `.dot` file will contain only the CFG information, without the instruction details. This can make the graph simpler and easier to read, especially for larger functions.

```
opt -passes=dot-cfg-only examples/diag.ll -disable-output
```
This writes a `.dot` file for each function in the IR, containing only the CFG information (basic blocks and edges). The nodes are labeled with the basic block names, and the edges represent the control flow between them.

Now we can visualize the CFG with:

```
dot -Tpng .identity.dot -o diag.png
```

and open the resulting `diag.png` file to see the CFG. On a Mac, you can

```
open diag.png
```

![/docs/images/diag-dot-cfg-only.png](/docs/images/diag-dot-cfg-only.png)

## Regions 

A **region** is a subgraph of the CFG that has a single-entry point and a single-exit point (SESE). Regions are useful for various compiler optimizations and analyses, as they represent a portion of the program that can be treated as a unit.

A region must satisfy:

1. **Single entry**:All nodes in the region must be dominated by the entry
2. **Single exit**:All nodes must be post-dominated by the exit

To visualize regions, we can use the `-dot-regions-only` pass:

```
➜  hello-llvm git:(main) opt -dot-regions-only examples/diag.ll -disable-output 
Writing 'reg.identity.dot'...
```

This command generates a `.dot` file for each function in the IR, containing only the region information. The nodes represent regions, and the edges represent the control flow between them.

```
dot -Tpng reg.identity.dot -o reg-diag.png
Warning: transparent is not a known color.
```

```
open reg-diag.png 
```

![/docs/images/reg-diag.png](/docs/images/reg-diag.png)

- [diag.c](/examples/diag.c)
- [diag.ll](/examples/diag.ll)

Reading our diagram we have:

- 🔵 Outer region (blue)
    * Entry: `entry`
    * Exit: function exit (`ret`)
- 🟢 First green region
    * Entry: `for.cond`
    * Exit: `for.end8`
    * 👉 This corresponds to the outer loop:

      ```c
      for (i = 0; i < N; i++) {
        ...
      }
      ```
- 🔴 Inner red region
    * Entry: `for.cond1`fdiag.c
    * Exit: `for.end`
    * 👉 This is the inner loop:

      ```c
      for (j = 0; j < N; j++) {
        ...
      }
      ```
- 🟢 Second green region (on the right)
  * Entry: `for.cond10`
  * Exit: `for.end19`
  * 👉 This is the second loop after the first one.
    
    ```
    for (i = 0; i < N; i++) {
      a[i][i] = 1;
    }
    ```

**There are more valid SESE regions than the ones LLVM shows**

LLVM chooses the regions it shows according to some heuristics, for example:

- canonical
- maximal under structural constraints
- nicely nested

Think of regions like structured programming blocks:

| CFG pattern       | Region          |
| ----------------- | --------------- |
| `if`              | region          |
| `while` / `for`   | region          |
| nested loops      | nested regions  |
| sequence of loops | sibling regions |


## Dominator Trees

A **dominator** of a node `B` in a CFG is a node `A` such that every path from the entry node to `B` must go through `A`. The **dominator tree** is a tree where each node's parent is its immediate dominator (the closest dominator).

To visualize the dominator tree, we can use the `-dot-dom` pass:

```
✗ opt --version
Homebrew LLVM version 14.0.6
  Optimized build.
  Default target: x86_64-apple-darwin25.3.0
  Host CPU: skylake
```
With LLVM 14, we can generate the dominator tree with:
```
✗ opt -enable-new-pm=0 -dot-dom examples/diag.ll -disable-output 
Writing 'dom.identity.dot'...
```
and then produce the image with:
```
➜  hello-llvm git:(main) ✗ dot -Tpng dom.identity.dot -o tmp/dom.identity.png
```

![](/docs/images/dom.identity.png)

- [diag.c](/examples/diag.c)
- [diag.ll](/examples/diag.ll)

For LLVM version 21, using the `dot-dom-only` pass on the macOS setup I am using,
we first compile the IR with:

```
clang -S -emit-llvm -Xclang  -disable-O0-optnone examples/diag.c -o examples/diag.ll -fno-discard-value-names
```
The `-fno-discard-value-names` option preserves variable names in the IR, which makes the output more readable. Without this option, LLVM may assign generic names to variables, which makes CFG interpretation harder.

Then we generate the `.dot` file with:

```
opt -passes=dot-dom-only examples/diag.ll -disable-output
```
```
Writing 'domonly.identity.dot'...
```
To visualize the result, run:
```
dot -Tpng domonly.identity.dot -o tmp/domonly.identity.png
```
```
open tmp/domonly.identity.png
```

See the resulting image:


| Dominator tree     | CFG with dominators highlighted |
| ------------------ | --------------- |
| ![](/docs/images/domonly.identity.png) | ![/docs/images/diag-dot-cfg-only.png](/docs/images/diag-dot-cfg-only.png) |


- [diag.c](/examples/diag.c)
- [diag.ll](/examples/diag.ll)

For example, `for.cond10` is dominated by `for.cond` because all paths from program entry to `for.cond10` pass through `for.cond`. However, `for.cond10` does not dominate `for.cond` because there is a path from entry to `for.cond` that does not pass through `for.cond10` (for example, the path that goes directly from entry to `for.inc6`).

## Callgraph

```
opt -p dot-callgraph examples/factorial-main.ll -disable-output 
```
```
Writing 'examples/factorial-main.ll.callgraph.dot'...
```

```
dot -Tpng examples/factorial-main.ll.callgraph.dot -o tmp/factorial.ll.callgraph.png
```
```
open tmp/factorial.ll.callgraph.png
```

![](/docs/images/factorial.ll.callgraph.png)

## Dot options of `opt`

For version 21.1.8 of LLVM, 
```
➜  hello-llvm git:(main) ✗ opt --version
Homebrew LLVM version 21.1.8
  Optimized build.
  Default target: x86_64-apple-darwin25.3.0
  Host CPU: skylake
```

the `opt` tool has the following options for generating `.dot` files:

| Option | Description |
| --- | --- |
| `--dot-callgraph` | Print call graph to `.dot` file |
| `--dot-dom` | Print dominance tree of function to `.dot` file |
| `--dot-dom-only` | Print dominance tree of function to `.dot` file (with no function bodies) |
| `--dot-postdom` | Print postdominance tree of function to `.dot` file |
| `--dot-postdom-only` | Print postdominance tree of function to `.dot` file (with no function bodies) |
| `--dot-regions` | Print regions of function to `.dot` file |
| `--dot-regions-only` | Print regions of function to `.dot` file (with no function bodies) |
| `--dot-scops` | Polly: print Scops of function |
| `--dot-scops-only` | Polly: print Scops of function (with no function bodies) |
| `--dot-cfg-mssa=<file name for generated dot file>` | File name for generated `.dot` file |
| `--pgo-view-block-coverage-graph` | Create a `.dot` file of CFGs with block coverage inference information |

## References

- Watch "Program Visualization using LLVM" at https://youtu.be/aFbWIJlcWww?si=JHZ5wDfqHiKO3F1X by CompilersLab
- [Slides of the LLVM course](https://homepages.dcc.ufmg.br/~fernando/classes/dcc888/ementa/slides/YouTubeLLVM/) by CompilersLab
- [Compilers Lab GitHub page](https://lac-dcc.github.io/index.html)

