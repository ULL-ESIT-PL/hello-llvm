
# Arrays and getelementptr

## One dimensional arrays

To create an array in LLVM IR, we can use the `alloca` instruction to allocate memory for the array:

```ll
%arr = alloca [5 x i32], align 16
```
This allocates memory for an array of 5 integers (`i32`) and returns a pointer to the array, which is stored in the register `%arr`. The `align 16` specifies that the memory should be aligned to a 16-byte boundary.

To access elements of the array, we can use the [getelementptr](https://llvm.org/docs/LangRef.html#getelementptr-instruction) instruction, which computes the address of a specific element in the array. For example, to access the third element of the array, we can do:

```ll
%p0 = getelementptr [5 x i32], ptr %arr, i64 0, i64 2
```
The first index `0` is convenient because each index reduces the type of the pointer by one level. The first index reduces the pointer from `ptr` to `[5 x i32]*` to `i32*`. This means "get the address of the element at index 2 of the array pointed to by `%arr` at offset `0`". 

For one dimensional arrays, we can omit the first index, which is always `0`, and simplify it to

```ll
%p0 = getelementptr [5 x i32], ptr %arr, i64 2
```
This computes the address of the third element of the array and stores it in the register `%p0`. The `i64 2` is the index for the element. See file [/examples/hello-array.ll](/examples/hello-array.ll) for the actual code.

```ll
declare i32 @printf(ptr noundef, ...)

define void @printArray(ptr noundef %arr, i32 noundef %N) { 
    ;... ommitted for brevity
}

define i32 @main() {
entry:
  %arr = alloca [5 x i32], align 16

  %p0 = getelementptr i32, ptr %arr, i64 0
  store i32 1, ptr %p0, align 4

  %p1 = getelementptr i32, ptr %arr, i64 1 ; Notice the i32 base type used 
  store i32 2, ptr %p1, align 4

  %p2 = getelementptr i32, ptr %arr, i64 2
  store i32 3, ptr %p2, align 4

  %p3 = getelementptr i32, ptr %arr, i64 3
  store i32 4, ptr %p3, align 4

  %p4 = getelementptr i32, ptr %arr, i64 4
  store i32 5, ptr %p4, align 4

  %arr0 = getelementptr i32, ptr %arr, i64 0
  call void @printArray(ptr noundef %arr0, i32 noundef 5)

  ret i32 0
}
```

The `@printArray(ptr noundef %arr, i32 noundef %N)` function takes a pointer to the first element of the array `%arr` and its size `%N`, and prints the elements of the array. Both parameters are given the [noundef attribute](noundef.md), which means that they cannot be `undef` values.

## Multi-dimensional arrays

To create a multi-dimensional array, we can use nested `alloca` instructions. For example, to create a 3x3 matrix `%M` of `i32`integers, we can do:

```ll
%M = alloca [3 x [3 x i32]], align 16
```

To set the element in the second row and third column of the matrix to `4`, the resulting instruction looks like this:

```ll
%p12 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 2
store i32 4, ptr %p12, align 4
```

The `getelementptr` instruction computes the address of the element at position `[1,2]`.

**We need three indices** to access the element at position `[1,2]` (remember that indices are zero-based).

- **The first index must be `0`** because it reduces the dimension of the pointer from `ptr` to `[3 x [3 x i32]]*` to `[3 x i32]`.
- The second index is `1` because it reduces the dimension of the pointer from `[3 x i32]` to `i32`, and it also selects the second row of the matrix. 
- The third index `2` is now an `i32` offset. 

See [/examples/hello-array2.ll](/examples/hello-array2.ll) for the actual code.

```ll 
@.fmt = private unnamed_addr constant [4 x i8] c"%d \00"
@.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
declare i32 @printf(ptr noundef, ...)
define void @printMatrix(ptr noundef %m, i32 noundef %N) {
; ... ommitted for brevity
}

define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %p00 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 0
  store i32 1, ptr %p00, align 4

  %p01 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 1 ; Notice the base type [3 x [3 x i32]] used here.
  store i32 0, ptr %p01, align 4 

  %p02 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 2
  store i32 0, ptr %p02, align 4

  %p10 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 0
  store i32 0, ptr %p10, align 4

  %p11 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 1
  store i32 1, ptr %p11, align 4

  %p12 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 1, i64 2
  store i32 0, ptr %p12, align 4

  %p20 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 0
  store i32 0, ptr %p20, align 4

  %p21 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 1
  store i32 0, ptr %p21, align 4

  %p22 = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 2, i64 2
  store i32 1, ptr %p22, align 4

  %base = getelementptr [3 x [3 x i32]], ptr %M, i64 0, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}
```

## Simplifying access specificating the base type

The `getelementptr` instruction can be simplified by specifying the base type of the pointer. For example, if we specify the base type as `[3 x i32]` instead of `[3 x [3 x i32]]`, we can omit the first index, which is always `0`, and simplify the instruction to:

```ll 
define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %p00 = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  store i32 1, ptr %p00, align 4

  %p01 = getelementptr [3 x i32], ptr %M, i64 0, i64 1
  store i32 0, ptr %p01, align 4

  %p02 = getelementptr [3 x i32], ptr %M, i64 0, i64 2
  store i32 0, ptr %p02, align 4

  %p10 = getelementptr [3 x i32], ptr %M, i64 1, i64 0
  store i32 0, ptr %p10, align 4

  %p11 = getelementptr [3 x i32], ptr %M, i64 1, i64 1
  store i32 1, ptr %p11, align 4

  %p12 = getelementptr [3 x i32], ptr %M, i64 1, i64 2
  store i32 0, ptr %p12, align 4

  %p20 = getelementptr [3 x i32], ptr %M, i64 2, i64 0
  store i32 0, ptr %p20, align 4

  %p21 = getelementptr [3 x i32], ptr %M, i64 2, i64 1
  store i32 0, ptr %p21, align 4

  %p22 = getelementptr [3 x i32], ptr %M, i64 2, i64 2
  store i32 1, ptr %p22, align 4

  %base = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}
```

See the file [/examples/hello-array2-simplified.ll](/examples/hello-array2-simplified.ll) for the actual code.

Example [examples/hello-array2-simplified2.ll](/examples/hello-array2-simplified2.ll) shows how can we access to thw rows of the matrix by specifying the base type as `[3 x i32]` :

```ll
define i32 @main() {
entry:
  %M = alloca [3 x [3 x i32]], align 16

  %firstRow = getelementptr [3 x i32], ptr %M, i64 0
  call void @initializeRow(ptr noundef %firstRow, i32 noundef 3, i32 0)

  %secondRow = getelementptr [3 x i32], ptr %M, i64 1
  call void @initializeRow(ptr noundef %secondRow, i32 noundef 3, i32 1)
    
  %thirdRow = getelementptr [3 x i32], ptr %M, i64 2
  call void @initializeRow(ptr noundef %thirdRow, i32 noundef 3, i32 2)

  %base = getelementptr [3 x i32], ptr %M, i64 0, i64 0
  call void @printMatrix(ptr noundef %base, i32 noundef 3)

  ret i32 0
}
```

## The getelementptr syntax

![/docs/images/getelementptr-syntax.png](/docs/images/getelementptr-syntax.png)

The **base type** determines how offsets are calculated. The first index multiplies by the size of the base type, the second index multiplies by the size of the type of the first index, and so on. 

## Alignment and Padding: struct types and getelementptr

For `struct` types, `getelementptr` also accounts for field alignment and padding automatically. See [struct-padding.md](struct-padding.md) for a short note and the examples [/examples/types.ll](/examples/types.ll) and [/examples/types-gep.ll](/examples/types-gep.ll).


