# `local_unnamed_addr` Attribute

In the header of the `@factorial` function in `examples/factorial.ll`, we see the `local_unnamed_addr` attribute:

```ll 
define i32 @factorial(i32 noundef %0) local_unnamed_addr #0 {
    ...
}

attributes #0 = { nofree nosync nounwind readnone ssp uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
```

`local_unnamed_addr` means the exact address of that symbol is not significant inside the current module.

For a function like:

```llvm
define i32 @factorial(...) local_unnamed_addr { ... }
```

it tells LLVM:

- Calls/cmp/use should care about function behavior, not its unique pointer identity (locally).
- The optimizer may merge/deduplicate equivalent symbols more aggressively within the module.

Why *“local”*:
- The non-local form `unnamed_addr` is a stronger claim (address insignificance globally).
- `local_unnamed_addr` is weaker: only guaranteed within this module; across modules the address may still matter.

**It is an optimization hint about pointer identity of the symbol’s address**:
Knowing that an address is not significant lets LLVM optimize based on behavior, not identity.

## Simple example

Imagine you have two internal functions with identical behavior:

```ll
    define internal i32 @plus1(i32 %x) local_unnamed_addr {
      %r = add i32 %x, 1
      ret i32 %r
    }

    define internal i32 @inc(i32 %x) local_unnamed_addr {
      %r = add i32 %x, 1
      ret i32 %r
    }
```

After optimization, LLVM may keep only one implementation and make both call sites use it (or make one an alias/thunk).

Why this is safe:
- The program only depends on returned values.
- It does not rely on `plus1` and `inc` having different function addresses.

If address identity were semantically used (for example, comparing function pointers), this optimization could be restricted. That is exactly the kind of constraint `local_unnamed_addr` helps relax inside the current module.

# The meaning of `#0` in the function header

The `#0` in the function header refers to a set of attributes defined later in the IR file. In this case, it points to the attributes defined as:

```llvm
attributes #0 = { nofree nosync nounwind readnone ssp uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
```
This means that the function `@factorial` has all the attributes listed in `#0`. These attributes provide additional information about the function's behavior and how it should be optimized by the compiler. For example:
- `nofree` indicates that the function does not free memory.
- `nosync` indicates that the function does not perform synchronization operations.
- `nounwind` indicates that the function does not unwind the stack (i.e., it does not throw exceptions).
- `readnone` indicates that the function does not read or write memory.
- `ssp` indicates that the function should use [stack smashing protection](https://llvm.org/docs/LangRef.html#function-attributes).
- `uwtable` indicates that the function should have an [unwind table for exception handling](https://llvm.org/docs/LangRef.html#function-attributes).
- The [other attributes](https://llvm.org/docs/LangRef.html#function-attributes) provide information about the target architecture and optimization hints.