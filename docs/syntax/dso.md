# How a dynamic library patches in a symbol from other library?

At a high level, it happens through dynamic linking and relocation.

1. A shared library leaves some symbol references unresolved
- Example: library A calls function foo that is defined in library B.
- In A, foo is recorded as an undefined dynamic symbol.

2. The linker emits indirection data
- On ELF systems: entries in GOT and PLT plus relocation records.
- On Mach-O (macOS): stubs + lazy/non-lazy symbol pointers + bind opcodes.
- On PE/COFF (Windows): import table / IAT.

3. At load time, the dynamic loader resolves symbols
- Linux: ld.so
- macOS: dyld
- Windows: loader
- It searches loaded images according to platform rules (dependency order, export visibility, interposition rules, etc.).

4. The loader “patches” addresses
- It writes the resolved address into the indirection slot (GOT/IAT/symbol pointer).
- Calls/jumps in A then go through that slot/stub and reach B::foo.

5. Lazy vs eager binding
- Eager: resolve all needed symbols at load time.
- Lazy: first call goes through resolver trampoline, then slot is patched for future direct dispatch via the stub path.

Minimal mental model:
- Code in A does not hardcode absolute address of B::foo.
- It calls through a linker/loader-managed pointer.
- Loader fills that pointer with B::foo address when it can.

Why this relates to `dso_local`
- If symbol is known non-preemptable/local, compiler can often avoid PLT/GOT-style indirection and emit more direct access/calls.

Tiny conceptual pseudo-flow (ELF-like):
1. call `foo@plt`
2. PLT reads `foo` address from GOT slot
3. If unresolved, jump to resolver
4. Resolver finds `foo` in B, writes address to GOT slot
5. Retry call, now jumps to real `foo` directly via patched slot