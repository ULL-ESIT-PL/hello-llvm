
## On the LLVM IR Syntax

See https://llvm.org/docs/LangRef.html#syntax

LLVM programs are composed of Module’s, each of which is a translation unit of the input programs. Each module consists of 
- functions, 
- global variables, and 
- symbol table entries. 

Modules may be combined together with the LLVM linker, which merges function (and global variable) definitions, resolves forward declarations, and merges symbol table entries. Here is an example of the `“hello world”` module:

```ll 
; Declare the string constant as a global constant.
@.str = private unnamed_addr constant [13 x i8] c"hello world\0A\00"

; External declaration of the puts function
declare i32 @puts(ptr captures(none)) nounwind

; Definition of main function
define i32 @main() {
  ; Call puts function to write out the string to stdout.
  call i32 @puts(ptr @.str)
  ret i32 0
}

; Named metadata
!0 = !{i32 42, null, !"string"}
!foo = !{!0}
```

``` 
module      ::= (function | global)*

function    ::= 'define' type '@' name '(' params ')' '{' block* '}'

block       ::= label ':' instruction*

instruction ::= assignment | terminator

assignment  ::= '%' name '=' op

op          ::= 'add' type value ',' value
              | 'sub' type value ',' value
              | 'load' type ',' type '*'
              | ...

terminator  ::= 'ret' type value
              | 'br' 'label' '%' name
              | 'br' 'i1' value ',' 'label' '%' name ',' 'label' '%' name
```

- LLVM IR is strongly typed.
- Global symbols begin with an at sign (`@`).
- Local symbols begin with a percent symbol (`%`).
- All symbols must be declared or defined.
- If in doubt, consult the Language Reference Manual: https://llvm.org/docs/LangRef.html

