// Program Visualization using LLVM https://youtu.be/aFbWIJlcWww?si=JHZ5wDfqHiKO3F1X by CompilersLab
// Con la versión 21 de LLVM: 
/* 
➜  examples git:(main) ✗ clang -S -emit-llvm -fno-discard-value-names diag.c -o diag.ll
➜  examples git:(main) ✗ opt -passes=dot-cfg diag.ll -disable-output                   
Writing '.identity.dot'...
examples git:(main) ✗ dot -Tpng .identity.dot -o diag.png
*/
void identity(int **a, int N) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            a[i][j] = 0;
         }
    }
    for(int i = 0; i < N; i++) {
        a[i][i] = 1;
    }
}