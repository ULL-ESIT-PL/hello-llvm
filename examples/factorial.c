// clang -S -emit-llvm examples/factorial.c -o examples/factorial.ll
int factorial(int value) {
  if (value == 0) {
    return 1;
  } else {
    return factorial(value - 1) * value;
  }
}