# Signed vs Unsigned in LLVM IR

## Is `i32` signed or unsigned?

In LLVM IR, `i32` is neither — it's just a 32-bit integer with no inherent signedness. Signedness is determined by the instruction used on it: `add`/`sub`/`mul` are **sign-agnostic (two's complement)**, while `sdiv`/`udiv`, `icmp slt`/`icmp ult`, `sext`/`zext` **encode the sign semantics explicitly**.

## What does it mean "sign-agnostic"?

It means the bit-level result is identical regardless of whether you interpret the operands as signed or unsigned. For example, `add i32` on the bit patterns `0xFFFFFFFF + 0x00000001` gives `0x00000000` — which is correct whether you read those as `-1 + 1 = 0` (signed) or `4294967295 + 1 = 0` (unsigned overflow). Same instruction, same bits, same result.

Contrast with division: `5 / -1` is `-5` signed but a huge positive number unsigned — so LLVM needs separate `sdiv` and `udiv` instructions.

## How sdiv encodes the sign semantic explictly?

The instruction name itself is the encoding — `sdiv` tells LLVM "treat these bits as two's complement signed integers and divide accordingly." There's no extra flag or bit in the operands; the opcode choice *is* the semantic declaration.

So when LLVM lowers `sdiv i32 %a, %b` to machine code, it emits a signed divide instruction (e.g., `idiv` on x86, which sign-extends the dividend). If you wrote `udiv` instead on the same bit patterns, it would emit an unsigned divide (e.g., `div` on x86).

Same bits in `%a` and `%b` — different behavior — because the opcode carries the interpretation.

## Example

See [/examples/signed-unsigned.ll](/examples/signed-unsigned.ll)