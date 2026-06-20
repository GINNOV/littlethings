		section	showdec,code
		opt	o+,c-

		lea	DosName(pc),a1
		move.l	4.w,a6
		jsr	-408(a6)
		move.l	d0,DosBase
		beq.s	QuitFast
 
		move.l	DosBase,a6
		jsr	-60(a6)
		move.l	d0,output
		beq.s	Closedos
 
***************************************************

		lea	Buffer,a0
		move.l	#$0f000000,d0		;hex number

		bsr.s	getdecimal

		move.l	output,d1	 ; output to CLI
		move.l	#hexno,d2	 ; text
		move.l	#hexend-hexno,d3 ; length
		move.l	DosBase,a6
		jsr	-48(a6)		 ; write text into cli


w		btst	#6,$bfe001
		bne.s	w
 

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

DosBase		ds.l	1
output		ds.l	1
		even
hexno		dc.b	'Dec Number is : '
Buffer		dc.b	'0000000000',$a
hexend		even

