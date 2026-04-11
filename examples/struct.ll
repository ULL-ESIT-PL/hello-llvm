; source llvm-version.sh 21
; lli examples/struct.ll

%MyStruct = type {
		i32,
		i1,
		double
}

@.fmt_i32 = private unnamed_addr constant [9 x i8] c"i32: %d\0A\00"
@.fmt_i1 = private unnamed_addr constant [8 x i8] c"i1: %d\0A\00"
@.fmt_double = private unnamed_addr constant [14 x i8] c"double: %.2f\0A\00"

declare i32 @printf(ptr noundef, ...)

define void @print_struct_fields(ptr %s) {
entry:
	%field_i32_ptr = getelementptr inbounds %MyStruct, ptr %s, i64 0, i32 0
	%field_i1_ptr = getelementptr inbounds %MyStruct, ptr %s, i64 0, i32 1
	%field_double_ptr = getelementptr inbounds %MyStruct, ptr %s, i64 0, i32 2

	%field_i32 = load i32, ptr %field_i32_ptr, align 8
	%field_i1 = load i1, ptr %field_i1_ptr, align 4
	%field_double = load double, ptr %field_double_ptr, align 8

	%field_i1_as_i32 = zext i1 %field_i1 to i32

	%fmt_i32_ptr = getelementptr inbounds [9 x i8], ptr @.fmt_i32, i64 0, i64 0
	%fmt_i1_ptr = getelementptr inbounds [8 x i8], ptr @.fmt_i1, i64 0, i64 0
	%fmt_double_ptr = getelementptr inbounds [14 x i8], ptr @.fmt_double, i64 0, i64 0

	call i32 (ptr, ...) @printf(ptr noundef %fmt_i32_ptr, i32 noundef %field_i32)
	call i32 (ptr, ...) @printf(ptr noundef %fmt_i1_ptr, i32 noundef %field_i1_as_i32)
	call i32 (ptr, ...) @printf(ptr noundef %fmt_double_ptr, double noundef %field_double)

	ret void
}

define i32 @main() {
entry:
	%s = alloca %MyStruct, align 8

	%field_i32_ptr = getelementptr inbounds %MyStruct, ptr %s, i64 0, i32 0
	%field_i1_ptr = getelementptr inbounds %MyStruct, ptr %s, i64 0, i32 1
	%field_double_ptr = getelementptr inbounds %MyStruct, ptr %s, i64 0, i32 2

	store i32 42, ptr %field_i32_ptr, align 8
	store i1 true, ptr %field_i1_ptr, align 4
	store double 3.500000e+00, ptr %field_double_ptr, align 8

	call void @print_struct_fields(ptr %s)

	ret i32 0
}
