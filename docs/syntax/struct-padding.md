# Struct Layout and Padding

LLVM lays out the fields of a `struct` so that each field starts at an address compatible with its alignment.

For this type:

```ll
%MyStruct = type {
  i32,
  i1,
  double
}
```

the usual layout is:

| Field | Offset | Size | Note |
| --- | ---: | ---: | --- |
| `i32` | 0 | 4 | starts at byte 0 |
| `i1` | 4 | 1 | stored after the `i32` |
| padding | 5 | 3 | inserted so the `double` starts at an 8-byte boundary |
| `double` | 8 | 8 | naturally aligned |

Total size: `16` bytes.

There are two different kinds of padding worth separating:

- Internal padding: bytes inserted between fields so the next field is properly aligned.
- Final padding: bytes added at the end of the struct so that arrays of that struct keep each element correctly aligned.

In `%MyStruct`, the 3 padding bytes are internal padding. There is no final padding beyond byte 15, because the struct already ends at a multiple of 8.

This matters for arrays:

```ll
@global_array = global [2 x %MyStruct] zeroinitializer
```

The array occupies `2 * 16 = 32` bytes, not `26`.

## `getelementptr` and offsets

`getelementptr` computes typed addresses, not raw byte indexes. For structs, the field index already accounts for any padding:

```ll
%field_i32 = getelementptr %MyStruct, ptr %p, i64 0, i32 0
%field_i1 = getelementptr %MyStruct, ptr %p, i64 0, i32 1
%field_double = getelementptr %MyStruct, ptr %p, i64 0, i32 2
```

These pointers refer to offsets `0`, `4`, and `8` respectively.

See [/examples/types.ll](/examples/types.ll) for the layout discussion and [/examples/types-gep.ll](/examples/types-gep.ll) for a version that materializes the offsets with `getelementptr`.