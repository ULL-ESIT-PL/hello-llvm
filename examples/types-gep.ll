; source llvm-version.sh 21
; llc -filetype=obj examples/types-gep.ll -o tmp/types-gep.o
; llvm-objdump -s tmp/types-gep.o
; The constant section stores four i64 values: 0, 4, 8, and 16.
; Those are the offsets of i32, i1, double, and the total size of %MyStruct.

; Same layout as in examples/types.ll:
;   offset 0  -> i32
;   offset 4  -> i1
;   offset 5  -> 3 bytes of internal padding
;   offset 8  -> double
;   total size -> 16 bytes
%MyStruct = type {
    i32,
    i1,
    double
}

; A GEP from null acts like a typed byte-offset computation.
; ptrtoint converts the resulting pointer into a numeric offset.
@offset_i32 = constant i64 ptrtoint (ptr getelementptr (%MyStruct, ptr null, i64 0, i32 0) to i64)
@offset_i1 = constant i64 ptrtoint (ptr getelementptr (%MyStruct, ptr null, i64 0, i32 1) to i64)
@offset_double = constant i64 ptrtoint (ptr getelementptr (%MyStruct, ptr null, i64 0, i32 2) to i64)
@size_of_struct = constant i64 ptrtoint (ptr getelementptr (%MyStruct, ptr null, i64 1) to i64)

define void @write_fields(ptr %out_struct) {
entry:
  %field_i32 = getelementptr inbounds %MyStruct, ptr %out_struct, i64 0, i32 0
  %field_i1 = getelementptr inbounds %MyStruct, ptr %out_struct, i64 0, i32 1
  %field_double = getelementptr inbounds %MyStruct, ptr %out_struct, i64 0, i32 2

  store i32 42, ptr %field_i32, align 8
  store i1 true, ptr %field_i1, align 4
  store double 3.500000e+00, ptr %field_double, align 8

  ret void
}