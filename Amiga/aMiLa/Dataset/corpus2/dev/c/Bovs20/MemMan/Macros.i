*********************************************************************
*
*				    Macros.i
*		     Bryan's obfuscated macros for A68k
*
*			Copyright (C) 1990 Bryan Ford
*			     All Rights	Reserved
*
*********************************************************************
	ifnd	BRY_MACROS_I
BRY_MACROS_I	set	1

b	macro	; <label>		; Branch
	bra.\0	\1
	endm

bhs	macro	; <label>		; Branch if higher or same (unsigned)
	bcc.\0	\1
	endm

blo	macro	; <label>		; Branch if lower (unsigned)
	bcs.\0	\1
	endm

bz	macro	; <label>		; Branch if zero
	beq.\0	\1
	endm

bnz	macro	; <label>		; Branch if zero
	bne.\0	\1
	endm

macm	macro	; <source> <dest>	; Macro	used by	move macros
	ifc	'\3',''
	move.\0	\1,\2
	endc
	ifnc	'\3',''
	ifc	'\4',''
	move.\0	\1,\2,\3
	endc
	ifnc	'\4',''
	move.\0	\1,\2,\3,\4
	endc
	endc
	endm

ml	macro	; <source>,<dest>	; Move long
	macm.l	\1,\2,\3,\4
	endm

mw	macro	; <source>,<dest>	; Move word
	macm.w	\1,\2,\3,\4
	endm

mb	macro	; <source>,<dest>	; Move byte
	macm.b	\1,\2,\3,\4
	endm

mq	macro	; <const>,<dest>	; Move quick
	moveq	\1,\2
	endm

cq	macro	; <dn>			; Clear	quick D	reg
	moveq	#0,\1
	endm

push	macro	; <registers>		; Push (long) registers	on stack
	movem.l	\1,-(sp)
	endm

pop	macro	; <registers>		; Pop (long) registers off of stack
	movem.l	(sp)+,\1
	endm

apush	macro				; Automatically	save registers
	autoreg				; Clear	autoreg	list
	push	\aregs
	endm

apop	macro				; Restore registers
	pop	\aregs
\aregs	autoreg	d0-d1/a0-a1/sp
	endm

apush4	macro				; Automatically	save registers
	autoreg				; Clear	autoreg	list
	push	\aregs
	endm

apop4	macro				; Restore registers
	pop	\aregs
\aregs	autoreg	d0-d1/a0-a1/a4/sp
	endm

dcb	macro	; <count>		; Alternative to ds
	ds.\0	\1
	endm

jl	macro	; <libfunc>		; Call library function
	jsr	_LVO\1(a6)
	endm

casl	macro	; bits,Dn		; Shift	Dn left	by constant number of bits
	ifgt	\1-8
	asl.\0	#8,\2
	casl.\0	\1-8,\2
	endc
	ifle	\1-8
	asl.\0	#\1,\2
	endc
	endm

clsl	macro	; bits,Dn		; Shift	Dn left	by constant number of bits
	casl.\0	\1,\2
	endm

casr	macro	; bits,Dn		; Arithmetic shift Dn right by constant
	ifgt	\1-8
	asr.\0	#8,\2
	casr.\0	\1-8,\2
	endc
	ifle	\1-8
	asr.\0	#\1,\2
	endc
	endm

clsr	macro	; bits,Dn		; Logical shift	Dn right by constant
	ifgt	\1-8
	lsr.\0	#8,\2
	clsr.\0	\1-8,\2
	endc
	ifle	\1-8
	lsr.\0	#\1,\2
	endc
	endm

xds	macro	; label,count		; Externally visible ds	(for both C and	asm)
\1:
_\1:	ds.\0	\2
	endm

dcx	macro				; Define long external
	xref	\1
	dc.\0	\1
	endm


	endc
