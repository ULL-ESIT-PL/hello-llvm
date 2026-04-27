; Check the syntax with llvm-as examples/foo-ptr.ll -o /dev/null
; clang examples/foo-ptr-main.c examples/foo-ptr.ll -o tmp/foo
define i64 @foo(i64 %val, ptr %myptr) {
  %temp = load i64, ptr %myptr
  %mul = mul i64 %val, %temp
  ret i64 %mul
}
