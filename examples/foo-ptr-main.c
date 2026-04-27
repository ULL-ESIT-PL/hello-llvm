#include <stdio.h>
#include <stdint.h>

// clang examples/foo-ptr-main.c examples/foo-ptr.ll -o tmp/foo
// llc -filetype=obj examples/foo-ptr.ll -o tmp/foo.o
// clang -c examples/foo-ptr-main.c -o tmp/foo-main.o
// clang tmp/foo-main.o tmp/foo.o -o tmp/foo

// Declaración de la función externa definida en el .ll
extern int64_t foo(int64_t val, int64_t *myptr);

int main() {
    int64_t a = 10;
    int64_t b = 5;
    
    // Call the LLVM function
    int64_t result = foo(a, &b);
    
    printf("Product: %lld\n", result); // Should print 50
    return 0;
}
