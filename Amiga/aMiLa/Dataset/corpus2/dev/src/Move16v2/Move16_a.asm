	CSECT   text
	xdef	@MoveMem16
	xdef	@MoveMem
move16reg	MACRO ; move16 (a0)+,(a1)+
	dc.l	$f6209000
	endm
	cnop	0,16
@MoveMem16 EQU	* ; ptr is in A0
	lsr.w	#5,d0
	subq.l	#1,d0
	nop
ll:
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	move16reg ; move16	(a0)+,(a1)+
	
	dbra	d0,ll
	nop
	rts
	cnop	0,16
@MoveMem equ *
	lsr.w	#4,d0
	subq.l	#1,d0
lll:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,lll
	rts
	cnop	0,16
	end
