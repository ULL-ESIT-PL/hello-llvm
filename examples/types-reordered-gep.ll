; source llvm-version.sh 21
; llc -filetype=obj examples/types-reordered-gep.ll -o tmp/types-reordered-gep.o
; llvm-objdump -s tmp/types-reordered-gep.o
; The constant section stores four i64 values: 0, 8, 12, and 16.
; Those are the offsets of double, i32, i1, and the total size of %MyStructReordered.

; Reordering changes where padding appears:
;   offset 0  -> double
;   offset 8  -> i32
;   offset 12 -> i1
;   offset 13 -> 3 bytes of final padding
;   total size -> 16 bytes
%MyStructReordered = type {
    double,
    i32,
    i1
}

@offset_double = constant i64 ptrtoint (ptr getelementptr (%MyStructReordered, ptr null, i64 0, i32 0) to i64)
@offset_i32 = constant i64 ptrtoint (ptr getelementptr (%MyStructReordered, ptr null, i64 0, i32 1) to i64)
@offset_i1 = constant i64 ptrtoint (ptr getelementptr (%MyStructReordered, ptr null, i64 0, i32 2) to i64)
@size_of_struct = constant i64 ptrtoint (ptr getelementptr (%MyStructReordered, ptr null, i64 1) to i64)

define void @write_fields_reordered(ptr %out_struct) {
entry:
  %field_double = getelementptr inbounds %MyStructReordered, ptr %out_struct, i64 0, i32 0
  %field_i32 = getelementptr inbounds %MyStructReordered, ptr %out_struct, i64 0, i32 1
  %field_i1 = getelementptr inbounds %MyStructReordered, ptr %out_struct, i64 0, i32 2

  store double 3.500000e+00, ptr %field_double, align 8
  store i32 42, ptr %field_i32, align 8
  store i1 true, ptr %field_i1, align 4

  ret void
}