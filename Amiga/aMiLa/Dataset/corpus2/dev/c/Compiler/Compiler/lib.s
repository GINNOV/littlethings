	text
#
#	c%lmul	long signed multiply
#
#	multiplies two long operands on the stack and returns the
#	result on the stack with no garbage.
#
	global	c%lmul
c%lmul:
	movm.l	&0xf000,-(%a7)		#save registers
	mov.l	20(%a7),%d0		#get parameter 1
	mov.w	%d0,%d2
	mov.w	%d0,%d1
	ext.l	%d1
	swap	%d1
	swap	%d0
	sub.w	%d0,%d1
	mov.w	26(%a7),%d0		#get msw of parameter 2
	mov.w	%d0,%d3
	ext.l	%d3
	swap	%d3
	sub.l	24(%a7),%d3		#subtract lsw of parameter 2
	muls	%d0,%d1
	muls	%d2,%d3
	add.w	%d1,%d3
	muls	%d2,%d0
	swap	%d0
	sub.w	%d3,%d0
	swap	%d0
	mov.l	%d0,24(%a7)
	mov.l	16(%a7),20(%a7)		#move return address
	movm.l	(%a7)+,&0x000f		#restore registers
	add.w	&4,%a7			#adjust stack
	rts
#
#	c%switch - execute c switch statement
#
#	the switch table is encoded as follows:
#
#		long	label1,case1
#		long	label2,case2
#		long	label3,case3
#		... for all cases
#		long	0,defaultcase
#
#	the case variable is passed in d0
#
	global	c%switch
c%switch:
	mov.l	(%a7)+, %a0		#get table address
c%sw1:
	mov.l	(%a0)+, %a1		#get a label
	mov.l	%a1, %d1		#test it for default
	beq	c%sw2			#jump if default case
	cmp.l	%d0,(%a0)+		#see if this case
	bne	c%sw1			#next case if not
	jmp	(%a1)			#jump to case
c%sw2:
	mov.l	(%a0), %a0		#get default address
	jmp	(%a0)			#jump to default case
