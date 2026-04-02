
## Visualizing

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

```
opt -passes=dot-cfg-only examples/diag.ll -disable-output
```
This writes a `.dot` file for each function in the IR, containing only the CFG information (basic blocks and edges). The nodes are labeled with the basic block names, and the edges represent the control flow between them.

Now we can visualize the CFG with:

```
➜  hello-llvm git:(main) ✗ dot -Tpng .identity.dot -o diag.png
➜  hello-llvm git:(main) ✗ open diag.png
```

![/docs/images/diag-dot-cfg-only.png](/docs/images/diag-dot-cfg-only.png)

## References

- Watch "Program Visualization using LLVM" at https://youtu.be/aFbWIJlcWww?si=JHZ5wDfqHiKO3F1X by CompilersLab

