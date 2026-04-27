; llvm-as -opaque-pointers examples/foo-ptr.ll -o /dev/null
define i64 @foo(i64 %val, ptr %myptr) {
  %temp = load i64, ptr %myptr
  %mul = mul i64 %val, %temp
  ret i64 %mul
}
