## Phi instructions

A `phi` instruction is LLVM’s way of saying:

> Choose a value depending on which control-flow edge just arrived at this block.

In Single-Static-Assignment (SSA) form, **each register** is assigned exactly once. When two or more branches join, LLVM cannot *reassign* a variable, so it uses `phi` to merge possible incoming values.

Consider this implementation of the `factorial` function:

```ll 
define i32 @factorial(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq i32 %0, 0         ; Compare input to 0
  br i1 %2, label %7, label %3   ; If %2 (input is 0) jump to %7

3:                               ; preds = %1
  %4 = add nsw i32 %0, -1        ; Compute n-1
  %5 = call i32 @factorial(i32 noundef %4)
  %6 = mul nsw i32 %5, %0        ; Compute n * factorial(n-1)
  br label %7

7:                               ; preds = %1, %3 ; block 7 can be reached from %1 and %3
  %8 = phi i32 [ %6, %3 ], [ 1, %1 ]
  ret i32 %8
}
```

In this example:

```llvm
7:
  %8 = phi i32 [ %6, %3 ], [ 1, %1 ]
  ret i32 %8
```

means:

- if control reaches block `7` from block `%3`, then `%8 = %6`
- if control reaches block `7` from block `%1`, then `%8 = 1`

So it depends on the predecessor block, not on a runtime *switch* inside the block itself.

How it works conceptually:
1. Earlier blocks compute different candidate values.
2. Control-flow merges at a join block.
3. The `phi` instruction picks the value associated with the predecessor edge that was actually taken.

So in our factorial:

- if `%0 == 0`, execution jumps directly from `%1` to `%7`, and `%8` becomes `1`
- otherwise execution goes through block `%3`, computes `%6 = %5 * %0`, then jumps to `%7`, and `%8` becomes `%6`

Equivalent high-level idea:

```c
int tmp;
if (value == 0)
  tmp = 1;
else
  tmp = recursive_result * value;
return tmp;
```

But in SSA, `tmp` cannot be assigned twice, so LLVM uses `phi`.

Two important rules:
- `phi` instructions **must appear at the beginning of a basic block**.
- They only refer to predecessor blocks of that block.

The attribute [local_unnamed_addr](local_unnamed_addr.md) qualifying `@factorial` means that the function's address is not significant. Te `#0` is a [reference to a function attribute group](local_unnamed_addr.md#the-meaning-of-0-in-the-function-header). These two tell us the huge amount of details that have beend added by the C++ to IR translation.

