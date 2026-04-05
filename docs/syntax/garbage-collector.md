# How is memory management in LLVM? is there some sort of garbage collector available?

The [garbage collector](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)) is a form of automatic memory management that attempts to reclaim memory that was allocated by the program, but is no longer referenced; such memory is called **garbage**. Garbage collection was invented by American computer scientist [John McCarthy](https://en.wikipedia.org/wiki/John_McCarthy_(computer_scientist)) around 1959 to simplify manual memory management in Lisp.

LLVM itself does not provide automatic memory management for your program by default.

## How memory works in LLVM IR:

1. **Stack memory**: allocated with `alloca`, automatically released when the function returns.
2. **Static/global memory**: globals live for the whole program lifetime.
3. **Heap memory**: usually done through runtime/library calls (for example [malloc/free](/examples/malloc-free.ll), or C++ new/delete). LLVM will optimize around these calls, but it does not free heap objects automatically. Conservative garbage collection often does not require any special support from either the language or the compiler: it can handle non-type-safe programming languages (such as C/C++) and does not require any special information from the compiler. The [Boehm collector](https://hboehm.info/gc/) is an example of a conservative collector.

### Heap memory malloc/free examples

- [malloc/free example](/examples/malloc-free.ll)
- [malloc/free array example](/examples/malloc-free-array.ll)

The following CFG shows the control flow of the `malloc/free-array.ll` example:
![Malloc/Free Array Example](/docs/images/malloc-free-array.png)

## About garbage collection:

1. There is no built-in, always-on GC in LLVM like in Java/.NET runtimes.
2. LLVM does have GC support infrastructure for language implementers, so [a frontend/runtime can plug in a collector](https://llvm.org/docs/GarbageCollection.html).
3. Modern integrations typically use 
   - GC [statepoints](https://llvm.org/docs/GarbageCollection.html#using-gc-statepoint) and 
   - GC [stack maps](https://llvm.org/docs/GarbageCollection.html#computing-stack-maps) so the runtime can find live references safely.
4. In practice: GC policy is owned by the language runtime, not by LLVM alone.

