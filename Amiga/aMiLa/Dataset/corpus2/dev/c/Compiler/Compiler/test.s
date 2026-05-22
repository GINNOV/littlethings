	text
main:
	link	%a6,&-4
	movm.l	&0x1000,-(%a7)
	mov	&0,%d3
	mov.l	%d3,-(%a7)
	jsr	subr
	add.w	&4,%a7
L%0:
	movm.l	(%a7)+,&0x0008
	unlk	%a6
	rts
subr:
	link	%a6,&0
	movm.l	&0x1000,-(%a7)
	mov.l	8(%a6),%d3
	mov	&2,%d0
	muls	%d3,%d0
	mov.l	%d0,%d3
	mov.l	%d3,%d0
L%1:
	movm.l	(%a7)+,&0x0008
	unlk	%a6
	rts
	global	main
	global	subr
