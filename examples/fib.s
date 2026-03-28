	.text
	.file	"complect"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$0, 16(%rsp)
	movl	$1, 12(%rsp)
	movl	$0, 20(%rsp)
	movl	$10, 8(%rsp)
	cmpl	$0, 8(%rsp)
	jle	.LBB0_3
	.p2align	4, 0x90
.LBB0_2:                                # %body
                                        # =>This Inner Loop Header: Depth=1
	decl	8(%rsp)
	movl	16(%rsp), %eax
	movl	%eax, 20(%rsp)
	movl	12(%rsp), %esi
	movl	%esi, 16(%rsp)
	addl	%esi, %eax
	movl	%eax, 12(%rsp)
	movl	$.L.str.0, %edi
	xorl	%eax, %eax
	callq	printf@PLT
	cmpl	$0, 8(%rsp)
	jg	.LBB0_2
.LBB0_3:                                # %exit
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	window,@object                  # @window
	.comm	window,8,8
	.type	renderer,@object                # @renderer
	.comm	renderer,8,8
	.type	.L.str.0,@object                # @.str.0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.0:
	.asciz	"%d\n"
	.size	.L.str.0, 4

	.section	".note.GNU-stack","",@progbits
