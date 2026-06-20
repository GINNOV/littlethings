*****************************************************************************
* COPPERLIST COLOURS BUFFER (GOES IN COPPERLIST)
*****************************************************************************
 
cop1:         dcb.b	22*4,0
copend1:

*****************************************************************************
* INIT COLOURS ( CALL ONCE ON STARTUP TO INITIALISE COLOURS)
*****************************************************************************

copset:		lea     cop1(pc),a0
		move.l  #$3109fffe,d1
		move.w  #$180,d2
		lea     colours(pc),a3    
		move.l  #$80000,d3
		move.w  #21,d0
loop1:		move.l  d1,(a0)+
		move.w  d2,(a0)+
		move.w  (a3)+,(a0)+
		add.l   d3,d1
		dbf     d0,loop1
		rts    

*****************************************************************************
* CYCLE THROUGH COLOURS ( CALL EVERY VBLANK )
*****************************************************************************

movecols:	cmpi.b	#4,count1
		bne.s	skipit
		lea	cop1+6(pc),a0
		lea	cop1+14(pc),a1
		move.w	(a0),colstore1 
		moveq.l	#21,d0
shift1:		move.w	(a1),(a0)

		addi.l	#8,d2
		move.l	d2,a0
 
		addi.l	#8,d2 
		move.l	d2,a1

		dbf	d0,shift1
		move.w	colstore1,copend1-2
		move.b	#0,count1
		rts
skipit:		addq.b	#1,count1
		rts


*****************************************************************************
* COLOR DATA
*****************************************************************************

colours:	dc.w $0527,$0828,$0926
		dc.w $0914,$0a11,$0c21,$0d32,$0d52
		dc.w $0c73,$0c93,$0aa3,$0693,$0373
		dc.w $0395,$02b8,$01dd,$00ab,$017a
		dc.w $0159,$0248,$0237,$0226

count1:		dcb.b 1,0
colstore1:	dcb.w 1,0

*****************************************************************************

