;	Remove the semi-colon before the AUTO below to put it to write mode.
;	The workspace should be previously cleared with zeros.
;	Convertion routines by Robster 1994
;	-  This source will depack "Old SoundTracker" type modules

;	AUTO	j\wb\WORKSPACE\a1\

WORKSPACE	= $180000

	move.l	Module(pc),a0
	move.l	WorkSpc(pc),a1

	moveq	#19,d7
SOMove1	move.b	(a0)+,(a1)+
	dbf	d7,SOMove1

	moveq	#14,d6
SOMove2	moveq	#12,d7
SOMove3	move.w	(a0)+,(a1)+
	dbf	d7,SOMove3
	move.w	(a0)+,d0
	lsr.w	#1,d0
	move.w	d0,(a1)+
	move.w	(a0)+,(a1)+
	dbf	d6,SOMove2

	moveq	#0,d0
	moveq	#15,d7
SOMove4	moveq	#13,d6
SOMove5	move.w	d0,(a1)+
	dbf	d6,SOMove5
	move.w	#1,(a1)+
	dbf	d7,SOMove4

	move.b	(a0)+,(a1)+
	addq.l	#1,a0
	move.b	#127,(a1)+
	moveq	#63,d7
SOMove6	move.w	(a0)+,(a1)+
	dbf	d7,SOMove6

	move.l	#"M.K.",(a1)+

	move.l	Module(pc),a2
	add.l	ModSize(pc),a2
SOMove7	cmp.l	a0,a2
	beq	SOMvEnd
	move.b	(a0)+,(a1)+
	bra	SOMove7
SOMvEnd	rts

;Periodtable for Tuning 0, Normal
PerTble:dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

Module	dc.l	mt_Data
ModSize	dc.l	mt_DataEnd-mt_Data
WorkSpc	dc.l	WORKSPACE

mt_Data	incbin	"DH1:ST15Module"
mt_DataEnd
	END

 _____byte 1_____   byte2_    _____byte 3_____   byte4_
/                \ /      \  /                \ /      \
0000          0000-00000000  0000          0000-00000000

Unused        12 bits for    sample num-   Effect command.
              note period.   ber.
