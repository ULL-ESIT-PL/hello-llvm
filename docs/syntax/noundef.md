# noundef and poison

## noundef

`noundef` in LLVM IR is an attribute that means:

- The value must not be `undef` or `poison`.
- The caller guarantees that for parameters marked `noundef`.
- The callee guarantees that for return values marked `noundef`.

So in:

```llvm
define i32 @factorial(i32 noundef %0)
```

it means `%0` is guaranteed to be a well-defined `i32` value when `@factorial` is called.

Why it matters:
- It gives the optimizer stronger assumptions.
- Passing an undefined/poison value to a `noundef` parameter is undefined behavior.

## poison 

In LLVM, poison is a special invalid value that can propagate through instructions and make later behavior undefined once it is used in certain ways.

Think of it like this:
- `undef`: can be any value each time it is read.
- `poison`: represents a value that is already invalid due to a broken semantic rule.
  For example, signed overflow on No Signed Wrap (nsw) operations) produces `poison`.

   `nsw` is a flag on integer arithmetic instructions (like `add`, `sub`, `mul`, `shl`) that tells LLVM:

  - Treat operands/results as signed integers.
  - If signed overflow would occur, the result is poison (not wraparound).

    Example:
    ```llvm
    %r = add nsw i32 %a, %b
    ```
    This asserts `%a + %b` does not signed-overflow in valid executions.

Key properties:
1. Poison propagates:
   - Many arithmetic/logical/vector ops fed with `poison` produce `poison`.
2. Not immediately UB:
   - Having `poison` in SSA form is not automatically `undefined` behavior.
3. UB happens when `poison` is consumed by instructions that require a concrete valid value:
   - Typical examples: branch condition, memory address used for load/store, etc.
4. Why LLVM uses it:
   - It gives optimizers stronger reasoning power while preserving language semantics.

Example intuition:
- If an `add` marked `nsw` overflows, its result is `poison`.
- If that `poison` is later used as the condition of a branch, behavior becomes `undefined`.