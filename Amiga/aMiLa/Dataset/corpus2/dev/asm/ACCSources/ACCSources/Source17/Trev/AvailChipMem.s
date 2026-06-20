		section	availmem,code
		opt	o+,c-

_LVOAvailMem	equ	-216
Total		equ	1
Chip		equ	2
Fast		equ	4

*************************************************************************************
* Open Dos Library and get CLI output base
*************************************************************************************

		lea	DosName(pc),a1
		move.l	4.w,a6
		jsr	-408(a6)
		move.l	d0,DosBase
		beq	QuitFast
 
		move.l	DosBase,a6
		jsr	-60(a6)
		move.l	d0,output
		beq	Closedos
 
*************************************************************************************
* Get Memory Figures for CHIP,FAST & TOTAL ( ALL DECIMAL )
*************************************************************************************

; chip mem
		move.l	4.w,a6
		moveq.l	#Chip,d1		; chip mem - requirements
		jsr	_LVOAvailMem(a6)
		lea	chipbuff,a0
		bsr	getdecimal
		move.l	output,d1		; output to CLI
		move.l	#chiptxt,d2		; text
		move.l	#chiptxtend-chiptxt,d3	; length
		move.l	DosBase,a6
		jsr	-48(a6)			; write text into cli

; fast mem
		move.l	4.w,a6
		moveq.l	#Fast,d1		; chip mem - requirements
		jsr	_LVOAvailMem(a6)
		lea	fastbuff,a0
		bsr.s	getdecimal
		move.l	output,d1		; output to CLI
		move.l	#fasttxt,d2		; text
		move.l	#fasttxtend-fasttxt,d3	; length
		move.l	DosBase,a6
		jsr	-48(a6)			; write text into cli

; total mem
		move.l	4.w,a6
		moveq.l	#Total,d1		; chip mem - requirements
		jsr	_LVOAvailMem(a6)
		lea	totbuff,a0
		bsr.s	getdecimal
		move.l	output,d1		; output to CLI
		move.l	#tottxt,d2		; text
		move.l	#tottxtend-tottxt,d3	; length
		move.l	DosBase,a6
		jsr	-48(a6)			; write text into cli



*************************************************************************************
* Close libraries 
*************************************************************************************

CloseDos	move.l	DosBase,a1
		move.l	4.w,a6
		jsr	-414(a6)
quitfast	moveq.l	#0,d0
		rts	


*************************************************************************************
* Gets a Decimal Value in ASCII from a Hexdecimal longword
*************************************************************************************
 
getdecimal	move.b	#" ",d5			; replace leading zero's with spaces
		lea	hextable(pc),a1

		move.w	#8,d4

ccloop		move.l	(a1)+,d1
		cmp.l	d1,d0
		bcs.s	get3
 
		move.w	#32-1,d3
		moveq.l	#0,d2
get1		asl.l	#1,d0
		roxl.l	#1,d2
		cmp.l	d1,d2
		bcs.s	get2
 
		sub.l	d1,d2
		addq.l	#1,d0
get2		dbra	d3,get1
	 
		add.b	#48,d0
		move.b	d0,(a0)+
		move.l	d2,d0
		move.b	#48,d5
		bra.s	get4
 
get3		move.b	d5,(a0)+
get4		dbra	d4,ccloop
 
		add.b	#48,d0
		move.b	d0,(a0)+
		rts

*************************************************************************************
* Data Section
*************************************************************************************

DosName		dc.b	'dos.library',0
		even
hextable	dc.l	1000000000
		dc.l	100000000
		dc.l	10000000
		dc.l	1000000
		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10
		even
dosbase		dc.l	0
output		dc.l	0
		even
chiptxt		dc.b	'Chip Memory  : '
chipbuff	dc.b	0,0,0,0,0,0,0,0,0,0,$a
chiptxtend	even
fasttxt		dc.b	'Fast Memory  : '
fastbuff	dc.b	0,0,0,0,0,0,0,0,0,0,$a
fasttxtend	even
tottxt		dc.b	'Total Memory : '
totbuff		dc.b	0,0,0,0,0,0,0,0,0,0,$a
tottxtend	even

