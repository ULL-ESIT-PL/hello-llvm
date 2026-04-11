; source llvm-version.sh 21
; llc -filetype=obj examples/types.ll -o tmp/types.o
; nm tmp/types.o   
; 0000000000000070 S _global_array
; 0000000000000050 S _global_struct_array
; 0000000000000000 T _my_function

; Total per struct: 16 bytes 
; Offsets summary:
;   i32    -> 0
;   i1     -> 4
;   double -> 8
;   sizeof -> 16
%MyStruct = type { 
    i32,     ; 4 bytes from 0 to 3 for the i32
    i1,      ; 1 byte 4 for the i1
             ; 3 bytes from 5 to 7 of padding to align the next field to an 8-byte boundary
    double } ; 8 bytes from 8 to 15 for the double

; Permanent allocation in binary's data/BSS section
@global_struct_array = global [2 x %MyStruct] zeroinitializer
; GLOBAL - Allocated in data segment
@global_array = global [2 x %MyStruct] zeroinitializer 
; 2 structs: 32 bytes total = 2 structs * 16 bytes each

define void @my_function() {
    ; LOCAL - Allocated on stack (at runtime)
    %local_array = alloca [2 x %MyStruct]
    
    ; This also allocates memory on the stack
    %local_zeroed = alloca [2 x %MyStruct], align 8
    ; equivalent of C's memset() function - it sets a range of memory to a repeated byte value.
    call void @llvm.memset.p0.i64(
        ptr %local_zeroed, ; pointer to the start of memory to fill
        i8 0,              ; byte value to set (0 means zero-initialization)
        i64 32,            ; number of bytes to set (2 structs * 16 bytes each = 32 bytes, including padding)
        i1 false           ; whether the writes are volatile (like volatile in C)
    )
    
    ret void
}