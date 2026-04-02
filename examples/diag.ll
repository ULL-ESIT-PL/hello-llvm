; ModuleID = 'examples/diag.c'
source_filename = "examples/diag.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable
define void @identity(i32** noundef %a, i32 noundef %N) #0 {
entry:
  %a.addr = alloca i32**, align 8
  %N.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %i9 = alloca i32, align 4
  store i32** %a, i32*** %a.addr, align 8
  store i32 %N, i32* %N.addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc6, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %N.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end8

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %N.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body3, label %for.end

for.body3:                                        ; preds = %for.cond1
  %4 = load i32**, i32*** %a.addr, align 8
  %5 = load i32, i32* %i, align 4
  %idxprom = sext i32 %5 to i64
  %arrayidx = getelementptr inbounds i32*, i32** %4, i64 %idxprom
  %6 = load i32*, i32** %arrayidx, align 8
  %7 = load i32, i32* %j, align 4
  %idxprom4 = sext i32 %7 to i64
  %arrayidx5 = getelementptr inbounds i32, i32* %6, i64 %idxprom4
  store i32 0, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body3
  %8 = load i32, i32* %j, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond1, !llvm.loop !5

for.end:                                          ; preds = %for.cond1
  br label %for.inc6

for.inc6:                                         ; preds = %for.end
  %9 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %9, 1
  store i32 %inc7, i32* %i, align 4
  br label %for.cond, !llvm.loop !7

for.end8:                                         ; preds = %for.cond
  store i32 0, i32* %i9, align 4
  br label %for.cond10

for.cond10:                                       ; preds = %for.inc17, %for.end8
  %10 = load i32, i32* %i9, align 4
  %11 = load i32, i32* %N.addr, align 4
  %cmp11 = icmp slt i32 %10, %11
  br i1 %cmp11, label %for.body12, label %for.end19

for.body12:                                       ; preds = %for.cond10
  %12 = load i32**, i32*** %a.addr, align 8
  %13 = load i32, i32* %i9, align 4
  %idxprom13 = sext i32 %13 to i64
  %arrayidx14 = getelementptr inbounds i32*, i32** %12, i64 %idxprom13
  %14 = load i32*, i32** %arrayidx14, align 8
  %15 = load i32, i32* %i9, align 4
  %idxprom15 = sext i32 %15 to i64
  %arrayidx16 = getelementptr inbounds i32, i32* %14, i64 %idxprom15
  store i32 1, i32* %arrayidx16, align 4
  br label %for.inc17

for.inc17:                                        ; preds = %for.body12
  %16 = load i32, i32* %i9, align 4
  %inc18 = add nsw i32 %16, 1
  store i32 %inc18, i32* %i9, align 4
  br label %for.cond10, !llvm.loop !8

for.end19:                                        ; preds = %for.cond10
  ret void
}

attributes #0 = { noinline nounwind ssp uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 2}
!4 = !{!"Homebrew clang version 14.0.6"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
