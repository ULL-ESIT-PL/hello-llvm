# ABI

ABI is the Application Binary Interface.

It is the low-level contract that lets compiled code pieces work together at runtime, defining things like:

- calling conventions (how arguments/returns are passed)
- register usage
- data type sizes and alignment
- object file/binary format details
- symbol naming/linking conventions
- system call interface conventions

If two components use the same ABI, they can interoperate in binary form without recompiling.