	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0_d2p0"
	.file	"lab03.c"
	.globl	read
	.p2align	2
	.type	read,@function
read:
	addi	sp, sp, -32
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a3, -12(s0)
	lw	a4, -16(s0)
	lw	a5, -20(s0)
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	li	a7, 63	# syscall write code (63) 
	ecall		# invoke syscall 
	mv	a3, a0	# move return value to ret_val

	#NO_APP
	sw	a3, -28(s0)
	lw	a0, -28(s0)
	sw	a0, -24(s0)
	lw	a0, -24(s0)
	lw	ra, 28(sp)
	lw	s0, 24(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	read, .Lfunc_end0-read

	.globl	write
	.p2align	2
	.type	write,@function
write:
	addi	sp, sp, -32
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a3, -12(s0)
	lw	a4, -16(s0)
	lw	a5, -20(s0)
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	li	a7, 64	# syscall write (64) 
	ecall	
	#NO_APP
	lw	ra, 28(sp)
	lw	s0, 24(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	write, .Lfunc_end1-write

	.globl	exit
	.p2align	2
	.type	exit,@function
exit:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a1, -12(s0)
	#APP
	mv	a0, a1	# return code
	li	a7, 93	# syscall exit (64) 
	ecall	
	#NO_APP
.Lfunc_end2:
	.size	exit, .Lfunc_end2-exit

	.globl	_start
	.p2align	2
	.type	_start,@function
_start:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	addi	s0, sp, 16
	call	main
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	call	exit
.Lfunc_end3:
	.size	_start, .Lfunc_end3-_start

	.globl	char_to_int
	.p2align	2
	.type	char_to_int,@function
char_to_int:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	addi	s0, sp, 16
	sb	a0, -9(s0)
	lbu	a0, -9(s0)
	addi	a0, a0, -48
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end4:
	.size	char_to_int, .Lfunc_end4-char_to_int

	.globl	int_to_char
	.p2align	2
	.type	int_to_char,@function
int_to_char:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	addi	a0, a0, 48
	sb	a0, -13(s0)
	lbu	a0, -13(s0)
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end5:
	.size	int_to_char, .Lfunc_end5-int_to_char

	.globl	main
	.p2align	2
	.type	main,@function
main:
	addi	sp, sp, -48
	sw	ra, 44(sp)
	sw	s0, 40(sp)
	addi	s0, sp, 48
	li	a0, 0
	sw	a0, -36(s0)
	sw	a0, -12(s0)
	addi	a1, s0, -23
	sw	a1, -40(s0)
	li	a2, 20
	call	read
	sw	a0, -28(s0)
	lw	a0, -28(s0)
	call	int_to_char
	sb	a0, -31(s0)
	lb	a0, -31(s0)
	sb	a0, -30(s0)
	li	a0, 10
	sb	a0, -29(s0)
	li	a0, 1
	sw	a0, -44(s0)
	addi	a1, s0, -30
	li	a2, 2
	call	write
	lw	a0, -44(s0)
	lw	a1, -40(s0)
	lw	a2, -28(s0)
	call	write
	lw	a0, -36(s0)
	lw	ra, 44(sp)
	lw	s0, 40(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end6:
	.size	main, .Lfunc_end6-main

	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym read
	.addrsig_sym write
	.addrsig_sym exit
	.addrsig_sym int_to_char
	.addrsig_sym main
