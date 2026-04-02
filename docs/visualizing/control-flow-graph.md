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
    * Entry: `for.cond1`
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


## References

- Watch "Program Visualization using LLVM" at https://youtu.be/aFbWIJlcWww?si=JHZ5wDfqHiKO3F1X by CompilersLab

