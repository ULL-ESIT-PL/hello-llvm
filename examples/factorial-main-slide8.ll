declare i32 @factorial(i32) 

define i32 @main(i32 %argc, i8** %argv) {
  %1 = call i32 @factorial(i32 2) 
  %2 = mul i32 %1, 7 
  %3 = icmp eq i32 %2, 42 
  %result = zext i1 %3 to i32 
  ret i32 %result
}