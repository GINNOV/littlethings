CD_PLAY	EQU 1
CD_RWD	EQU 2
CD_FFW	EQU 3
CD_G	EQU 4
CD_Y	EQU 5
CD_R	EQU 6
CD_B	EQU 7


;***********************************************************************
;Reads CD 32 Controller
;You must read joystick positions or button in normal way
;BEFORE you call this.
;One VBL MUST have elapsed before repeating this!

ReadCD32:
		movem.l	d0-d2/a0,-(sp)
		bset	#7,$bfe201
		bclr	#7,$bfe001
		move.w	#$6f00,$dff034
		moveq.l	#0,d0
		moveq.l	#7,d1
		bra.b	.gamecont4		
.gamecont3:
		tst.b	$bfe001
		tst.b	$bfe001
		tst.b	$bfe001
.gamecont4:
		tst.b	$bfe001
		tst.b	$bfe001
		tst.b	$bfe001
		tst.b	$bfe001
		tst.b	$bfe001
		move.w	$dff016,d2
		bset	#7,$bfe001
		bclr	#7,$bfe001
		btst	#14,d2
		bne.b	.gamecont5
		bset	d1,d0
.gamecont5:
		dbf	d1,.gamecont3
		
		bclr	#7,$bfe201
		move.w	#$ffff,$dff034
		lea	cd32,a0
		move.b	d0,(a0)
		movem.l	(sp)+,d0-d2/a0
		rts
cd32:		dc.b	0
		CNOP 0,2

;***********************************************************************
