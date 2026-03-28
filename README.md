La instalación de llvm-bindings es complicada. La versión de llvm que hay que instalar es la 14.

## Instalación en macOS:

brew install cmake llvm@14
npm install llvm-bindings

Se podría intentar hacer las instalación "custom": 

https://github.com/ApsarasX/llvm-bindings?tab=readme-ov-file#custom-llvm-installation
```

## Notas de brew 

To use the bundled libc++ please add the following LDFLAGS:
  LDFLAGS="-L/usr/local/opt/llvm@14/lib/c++ -Wl,-rpath,/usr/local/opt/llvm@14/lib/c++"

llvm@14 is keg-only, which means it was not symlinked into /usr/local, because this is an alternate version of another formula.

If you need to have llvm@14 first in your PATH, run:
  echo 'export PATH="/usr/local/opt/llvm@14/bin:$PATH"' >> /Users/casianorodriguezleon/.zshrc

For compilers to find llvm@14 you may need to set:
  export LDFLAGS="-L/usr/local/opt/llvm@14/lib"
  export CPPFLAGS="-I/usr/local/opt/llvm@14/include"

For cmake to find llvm@14 you may need to set:
  export CMAKE_PREFIX_PATH="/usr/local/opt/llvm@14"
==> Summary
🍺  /usr/local/Cellar/llvm@14/14.0.6: 5,831 files, 1GB
==> Running `brew cleanup llvm@14`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
```

## Mi .zshrc:

```zsh
➜  complect git:(main) ✗ tail -n 4 ~/.zshrc 
export PATH="/usr/local/opt/llvm@14/bin:$PATH"
export LDFLAGS="$LDFLAGS -L/usr/local/opt/llvm@14/lib"
export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/llvm@14/include"
export CMAKE_PREFIX_PATH="/usr/local/opt/llvm@14"% 
```

## Error installing llvm-bindings

When trying to install llvm-bindings, I got the following error:

```
➜  complect git:(main) npm i
npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
npm warn deprecated rimraf@2.7.1: Rimraf versions prior to v4 are no longer supported
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
npm warn deprecated gauge@1.2.7: This package is no longer supported.
npm warn deprecated npmlog@1.2.1: This package is no longer supported.
npm warn deprecated are-we-there-yet@1.0.6: This package is no longer supported.
npm warn deprecated fstream@1.0.12: This package is no longer supported.
npm error code 1
npm error path /Users/casianorodriguezleon/campus-virtual/2526/learning/llvm-learning/complect/node_modules/llvm-bindings
npm error command failed
npm error command sh -c cmake-js compile
```

See Issue:

https://github.com/ApsarasX/llvm-bindings/issues/54

> Hey, if you are still looking at this for an answer, you could run `$env:CMAKE_PREFIX_PATH="C:\Users\risharan\scoop\apps\llvm\current\lib\cmake\llvm"` and then run npm install. You can look at the cmake (not cmake-js) documentation for details the CMAKE_PREFIX_PATH env variable.


### Funciona?

Al final co  LLVM 14 parece que se completa la instalación

Lo he intentado en un codespace de GitHub y no ha funcionado.

No puedes instalar LLVM 14 directamente con apt en Ubuntu 24.04 (noble) porque el repositorio no existe. Debes compilar desde fuente, usar paquetes de otra versión, o usar un contenedor.

## References

* What Is LLVM?https://www.youtube.com/watch?v=HecW5byOrUY&list=PLDSTpI7ZVmVnvqtebWnnI8YeB8bJoGOyv by CompilersLaboratory
* Watch "Programming Language with LLVM [1/20] Introduction to LLVM IR and tools" by Dmitry Soshnikov at https://youtu.be/Lvc8qx8ukOI?si=u-toTGVKTV7sHguw 
* See the list of LLVM videos by Dmitry Soshnikov at https://www.youtube.com/@DmitrySoshnikov-education/search?query=LLVM

