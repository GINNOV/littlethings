
;-------------------------------------------------
;
;OS Scroller by zeeball@interia.pl
;
;This is old crap, but maybe someone consider
;it useful. Note that it is coded 100% under OS
;therefore scroll is smooth only on real Amiga...
;
;-------------------------------------------------


FONTSIZE	=	20
xsiz		=	300
ysiz		=	FONTSIZE+16


	section	Starter,code

__:

Starter:
	lea.l	__(pc),a4

	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	pea.l	$10000
	pea.l	$20003
	pea.l	xsiz*256*256+ysiz
	clr.l	-(sp)
	clr.l	-(sp)

	move.l	a7,Kla-__(a4)

	bsr.b	.A

	lea.l	11*4(a7),a7
	rts

.A
	move.l	4.w,a6
	move.l	a6,ExecBase-__(a4)

	cmp.w	#36,$14(a6)
	bmi.b	.TooBad

	sub.l	a1,a1
	jsr	-$126(a6)		;FindTask
	move.l	d0,a5
	
	tst.l	$ac(a5)
	bne.b	.Z_CLI
.Z_WB:
	lea.l	$5c(a5),a0		;MsgPort
	jsr	-$180(a6)		;WaitPort
	lea.l	$5c(a5),a0		;MsgPort
	jsr	-$174(a6)		;GetMsg
	
	movem.l	d0/a6,-(sp)
 	
	bsr.b	.Z_CLI

	movem.l	(sp)+,a1/a6
	
	jsr	-$84(a6)		;Forbid
 	
	jsr	-$17a(a6)		;ReplyMsg
.TooBad:
	moveq	#0,d0
	rts


.openLib:
	move.l	Execbase-__(a4),a6
	moveq	#36,d0
	jmp	-$228(a6)		;OpenLibrary


.Z_CLI:

	lea.l	DiskFontName(pc),a1
	bsr.b	.OpenLib
	move.l	d0,DiskFontBase-__(a4)
	bne.s	.x0
	rts
.x0
	lea.l	Dosname(pc),a1
	bsr.b	.OpenLib
	move.l	a6,DosBase-__(a4)

	bsr.b	.Program

	move.l	Execbase-__(a4),a6
	move.l	DosBase-__(a4),a1
	jsr	-$19e(a6)		;CloseLibrary

	moveq	#0,d0
	rts


.Program:
	move.l	ExecBase-__(a4),a6
	lea.l	GraphName-__(a4),a1
	bsr.b	.openLib
	move.l	d0,GraphBase-__(a4)

	lea.l	IntuiName-__(a4),a1
	bsr.b	.openLib
	move.l	d0,IntuiBase-__(a4)

	move.l	d0,a6
	lea.l	Screen-__(a4),a2
	sub.l	a0,a0
	jsr	-$1fe(a6)		;LockPubScreen
	tst.l	d0
	beq.w	.NOPUBSCREEN

	move.l	d0,a0
	move.l	d0,(a2)
	jsr	-252(a6)		;ScreentoFront

	move.l	Screen-__(a4),a0	;width
	move.w	$c(a0),d0
	sub.w	#xsiz+8,d0
	asr.w	d0


	lea.l	NewWindow-__(a4),a0
	move.w	d0,(a0)

	clr.l	-(sp)
	clr.l	-(sp)
	pea.l	[xsiz].W
	pea.l	$80000076		;WA_InnerWidth
	pea.l	[ysiz].W
	pea.l	$80000077		;WA_InnerHeight
	move.l	a7,a1

	move.l	IntuiBase-__(a4),a6
	jsr	-$25e(a6)		;OpenWindowTagList

	lea.l	8*3(a7),a7


	tst.l	d0
	beq.w	.NOWINDOW

	move.l	d0,WindowBase-__(a4)

	move.l	d0,a1
	move.l	50(a1),a1
	lea.l	rp-__(a4),a0
	move.l	a1,(a0)
	
	moveq	#1,d0
	move.l	GraphBase-__(a4),a6
	jsr	-342(a6)		;SetAPen

	move.l	Rp-__(a4),a0
	move.l	52(a0),d0		;font

	move.l	d0,a0
	lea.l	BigFont-__(a4),a1
	move.l	DiskFontBase-__(a4),a6
	jsr	-54(a6)			;NewScaledDiskFont

	move.l	rp-__(a4),a1
	move.l	d0,a0
	lea.l	54(a0),a0		;TextFont
	move.l	d0,FontBase-__(a4)
	move.l	GraphBase-__(a4),a6
	jsr	-66(a6)			;SetFont



	lea.l	BegScroll-__(a4),a5

.loop
	move.l	GraphBase-__(a4),a6
	moveq	#0,d2
	moveq	#0,d3
	move.w	#xsiz,d4
	moveq	#ysiz,d5

	REPT	FONTSIZE/4

	move.l	rp-__(a4),a1
	moveq	#4,d0
	moveq	#0,d1
	jsr	-396(a6)		;ScrollRaster
	jsr	-270(a6)		;WaitTOF

	ENDR

	move.l	rp-__(a4),a1
	move.w	#xsiz-FONTSIZE,d0
	moveq	#FONTSIZE,d1
	jsr	-240(a6)		;Move

	move.l	rp-__(a4),a1
	moveq	#1,d0
	move.l	a5,a0
	jsr	-60(a6)			;Text

	addq.l	#1,a5
	tst.b	(a5)
	bne.b	.xx
	lea.l	BegScroll-__(a4),a5
.xx

	move.l	WindowBase-__(a4),a0
	move.l	86(a0),a0
	move.l	ExecBase-__(a4),a6
	jsr	-372(a6)		;GetMsg
	tst.l	d0
	beq.w	.loop

	move.l	d0,a1
	move.l	20(a1),d2
	move.l	28(a1),a2
	move.l	ExecBase-__(a4),a6
	jsr	-378(a6)		;ReplyMsg

	move.l	GraphBase-__(a4),a6
	move.l	FontBase-__(a4),a1
	jsr	-78(a6)			;CloseFont

	move.l	WindowBase-__(a4),a0
	move.l	IntuiBase-__(a4),a6
	jsr	-72(a6)			;CloseWindow

.NOWINDOW:

	sub.l	a0,a0
	move.l	Screen-__(a4),a1
	jsr	-$204(a6)		;UnlockPubScreen

.NOPUBSCREEN:

	lea.l	ExecBase-__(a4),a3	;TU JEST MYK!!!!
	move.l	(a3)+,a6
	move.l	(a3)+,a1
	jsr	-414(a6)		;CloseLibrary
	move.l	(a3)+,a1
	jsr	-414(a6)		;CloseLibrary
	move.l	(a3)+,a1
	jsr	-414(a6)		;CloseLibrary
	
	moveq	#0,d0
	rts



;--------------------------------------------





DiskFontName:	dc.b	"diskfont.library",0
DosName:	dc.b	"dos.library",0
IntuiName:	dc.b	"intuition.library",0
GraphName:	dc.b	"graphics.library",0





BegScroll:
 dc.b	"         Here you can enter whatever you want..."
EndScroll:
 dc.b	0,0



		cnop	0,4
BigFont:
		dc.l	0
		dc.w	FontSize
		dc.b	0
		dc.b	0
		dc.w	FontSize

		cnop	0,4
NewWindow
		dc.w	0
		dc.w	0
		dc.w	xsiz
		dc.w	ysiz
		dc.w	1
		dc.l	32+$00000200
		dc.l	$0080+$0400+$0000+$2000+$00010000
		;SuperBitmap+Gimmezerozero+Borderless+Active+RMBtrap
kla:		dc.l	0
		dc.l	0
		dc.l	0
ScreenBase:	dc.l	0
		dc.l	0
		dc.w	xsiz,ysiz
		dc.w	xsiz,ysiz
		dc.w	1


DosBase:	ds.l	1
ExecBase:	ds.l	1
IntuiBase:	ds.l	1
GraphBase:	ds.l	1
DiskFontBase:	ds.l	1
WindowBase:	ds.l	1
Screen:		ds.l	1
rp:		ds.l	1
FontBase:	ds.l	1
Chip:		ds.l	1
