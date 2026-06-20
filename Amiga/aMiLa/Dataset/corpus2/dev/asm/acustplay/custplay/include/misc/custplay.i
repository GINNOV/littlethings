;--------------------------------------------------
; CUSTOM-PLAYER ASSEMBLER ROUTINE
; JANUARY 1997, MIKAEL LUND
; $VER: Customplayer 1.0 (8.1.97) Mikael Lund
;
; CALLS:	CP_GETDATA,CP_STARTI,CP_STOPI,
;		CP_INIT,CP_PLAY,CP_END
; VARS:		CP_DATA,CP_SPEED,CP_SUBSONG
; MISC:		SEE DATA SECTION
;--------------------------------------------------
		jmp	CP_ENDOFCODE
;--------------------------------------------------
;  START CUSTOM INT. 
;--------------------------------------------------
CP_STARTI	cmp.l	#$0,CP_STARTINT
		beq.s	CP_STARTI0
		move.l	CP_STARTINT,a0
		jsr	(a0)
CP_STARTI0	rts
;--------------------------------------------------
; STOP CUSTOM INT. 
;--------------------------------------------------
CP_STOPI	cmp.l	#$0,CP_STOPINT
		beq.s	CP_STOPI0
		move.l	CP_STOPINT,a0
		jsr	(a0)
CP_STOPI0	rts
;--------------------------------------------------
; Play music
;--------------------------------------------------
CP_PLAY		add.b	#$1,CP_PLAYCNT
		move.b	CP_SPEED,d0
		move.b	CP_PLAYCNT,d1
		cmp.b	d0,d1
		bne.s	CP_PLAY0
		move.l	CP_INTERRUPT,a0
		cmp.l	#$0,(a0)
		beq.s	CP_PLAY0
		jsr	(a0)
		clr.b	CP_PLAYCNT
CP_PLAY0	rts
;--------------------------------------------------
; Init music
;--------------------------------------------------
CP_INIT		move.l	CP_SUBSONGRANGE,a0
		cmp.l	#$0,(a0)
		beq.s	CP_INIT0
		jsr	(a0)
		move.b	d0,CP_MINSONG
		move.b	d1,CP_MAXSONG
		move.l	#CP_SUBSONG-$2c,a5
CP_INIT0	move.l	CP_INITSOUND,a0
		cmp.l	#$0,(a0)
		beq.s	CP_Init1
		jsr	(a0)
CP_INIT1	rts
;--------------------------------------------------
; End music
;--------------------------------------------------
CP_END		move.l	CP_ENDSOUND,a0
		cmp.l	#$0,(a0)
		beq.s	CP_END0
		jsr	(a0)
CP_END0		rts
;--------------------------------------------------
; Reads important data from module
;--------------------------------------------------
CP_GETDATA	move.l	#$80004465,d1
		lea	CP_INITSOUND,a2
		bsr.w	CP_GD0
		cmp.l	#$0,CP_INITSOUND
		beq.s	CP_GD3
		move.l	#$8000445e,d1
		lea	CP_INTERRUPT,a2
		bsr.w	CP_GD0
		move.l	#$80004466,d1
		lea	CP_ENDSOUND,a2
		bsr.w	CP_GD0
		move.l	#$80004467,d1
		lea	CP_STARTINT,a2
		bsr.w	CP_GD0
		move.l	#$80004468,d1
		lea	CP_STOPINT,a2
		bsr.w	CP_GD0
		move.l	#$80004462,d1
		lea	CP_SUBSONGRANGE,a2
		bsr.w	CP_GD0
		rts
CP_GD0:		lea	CP_DATA,a0
		lea	CP_DATA+$280,a1
		add.w	CP_DUMMY,a0
		add.w	CP_DUMMY,a1
CP_GD1		move.l	(a0)+,d0
		cmp.l	a0,a1
		beq.s	CP_GD2
		cmp.l	d1,d0
		bne.s	CP_GD1
		move.l	(a0)+,d0
		move.l	d0,(a2)
CP_GD2		rts
CP_GD3		move.w	#$2,CP_DUMMY
		bsr.w	CP_GETDATA
		rts
;--------------------------------------------------
; Data section
;--------------------------------------------------
CP_INITSOUND	dc.l	0	Init. music routine address
CP_INTERRUPT	dc.l	0	Int. music routine address
CP_ENDSOUND	dc.l	0	End music routine address
CP_STARTINT	dc.l	0	Custum int. routine START address
CP_STOPINT	dc.l	0	Custum int. routine STOP address
CP_SUBSONGRANGE	dc.l	0	Adr. where subsong num. are set
CP_PLAYCNT	dc.b	0	<internal>
CP_DUMMY	dc.w	0	<internal>
CP_MINSONG	dc.b	0	Min. subsong
CP_MAXSONG	dc.b	0	Max. subsong
CP_SUBSONG	dc.w	1	Subsong number to play
CP_SPEED	dc.b	1	Speed (1 Fastest)
EVEN
CP_ENDOFCODE
