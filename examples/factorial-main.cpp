// write a main that produces factorial-main.ll, 
// which calls the factorial function in factorial.ll and prints the result. 
// Compile and run it to check that it works.
// clang -S -emit-llvm examples/factorial.c -o examples/factorial.ll
// clang -S -emit-llvm examples/factorial-main.c -o examples/factorial-main.ll 
// clang examples/factorial-main.ll examples/factorial.ll -o tmp/f
#include <stdio.h>

extern int factorial(int value);
int main() {
    int result = factorial(5);
    printf("%d\n", result);
    return 0;
}