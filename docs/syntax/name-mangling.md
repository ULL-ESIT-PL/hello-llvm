# Name Mangling 

Name mangling is the compiler process of encoding extra information into symbol names, such as:

- namespace/class
- function name
- parameter types
- cv/ref qualifiers
- sometimes calling convention and Application Binary Interface (ABI)) details

Why:
- Linkers only see symbol names, not high-level language constructs.
- Mangling lets overloaded functions and scoped names remain unique.

Example idea in C++:
- `void f(int)` and `void f(double)` must become different linker symbols.
- The mangled names carry that signature info.

Related term:
- Demangling = converting encoded symbol names back to human-readable form.