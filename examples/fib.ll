; Total Time: 28ms PreTokens: 75 Tokens: 35 AST Nodes: 0 

; ModuleID = 'complect'
source_filename = "complect"
target triple = "x86_64-pc-linux-gnu"

%SDL_Event = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }

@window = common global i8* null
@renderer = common global i8* null
@.str.0 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

declare i32 @printf(i8*, ...)

declare i8* @malloc(i64)

declare void @free(i8*)

declare i8* @strcpy(i8*, i8*)

declare i8* @strcat(i8*, i8*)

declare i32 @strcmp(i8*, i8*)

declare i32 @sprintf(i8*, i8*, ...)

declare i64 @strlen(i8*)

declare i32 @SDL_Init(i32)

declare i8* @SDL_CreateWindow(i8*, i32, i32, i32, i32, i32)

declare void @SDL_Quit()

declare void @SDL_Delay(i32)

declare i32 @SDL_PollEvent(%SDL_Event*)

declare void @exit(i32)

declare i8* @SDL_CreateRenderer(i8*, i32, i32)

declare i32 @SDL_SetRenderDrawColor(i8*, i8, i8, i8, i8)

declare i32 @SDL_RenderDrawPoint(i8*, i32, i32)

declare void @SDL_RenderPresent(i8*)

declare i32 @SDL_RenderClear(i8*)

declare i32 @SDL_RenderDrawLine(i8*, i32, i32, i32, i32)

declare double @sin(double)

declare double @cos(double)

define i32 @main() {
entry:
  %a = alloca i32, align 4
  store i32 0, i32* %a, align 4
  %b = alloca i32, align 4
  store i32 1, i32* %b, align 4
  %t = alloca i32, align 4
  store i32 0, i32* %t, align 4
  %n = alloca i32, align 4
  store i32 10, i32* %n, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %n1 = load i32, i32* %n, align 4
  %gt = icmp sgt i32 %n1, 0
  %gt2 = zext i1 %gt to i32
  %0 = icmp ne i32 %gt2, 0
  br i1 %0, label %body, label %exit

body:                                             ; preds = %cond
  %n3 = load i32, i32* %n, align 4
  %sub = sub i32 %n3, 1
  store i32 %sub, i32* %n, align 4
  %a4 = load i32, i32* %a, align 4
  store i32 %a4, i32* %t, align 4
  %b5 = load i32, i32* %b, align 4
  store i32 %b5, i32* %a, align 4
  %b6 = load i32, i32* %b, align 4
  %t7 = load i32, i32* %t, align 4
  %add = add i32 %b6, %t7
  store i32 %add, i32* %b, align 4
  %a8 = load i32, i32* %a, align 4
  %print = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.0, i32 0, i32 0), i32 %a8)
  br label %cond

exit:                                             ; preds = %cond
  ret i32 0
}
