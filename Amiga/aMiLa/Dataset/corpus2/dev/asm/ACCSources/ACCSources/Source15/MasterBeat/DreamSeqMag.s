; й 1991 Simon Windmill (Master Beat)
; Code help from various, you'll be given credit (honest!)

; Yo! This is the second real version of the Dream Sequence mag.


	SECTION SlightlyTart,CODE_C
	OPT	O+,OW-,C-,D+			; No more Mr. Fussy!

**********

	INCLUDE	source:include/execware.i

; This include file is just the great 'hardware.i' file found on ACC
; and the 'exec_lib.i' standard include, joined together.


**********

TopPage		equ	0		; First Page
BottomPage	equ	3		; Last Page
SizeofPage	equ	1840		; 80 chars wide * 23 lines 
SizeofTit	equ	40		; 80 chars wide * 1 line

**********

	
Start
	MOVEM.L	A0-A6/D0-D7,-(A7)	; Save those registers...
	MOVE.L	A7,StPoint		; ...and the stack pointer
	MOVE.L	#$DFF000,A5		; Use A5 as our custom base

	CALLEXEC FORBID			; Atari ST emulation on

	LEA	GfxName(PC),A1
	CLR.L	D0
	CALLEXEC OPENLIBRARY		; Open that Gfx libby!
	MOVE.L	D0,GfxBase
	MOVE.W	DMACONR(A5),DMASave	; Save DMA setup

**********

SprWait1
	BTST	#0,VPOSR(A5)		; Wait for a non-sprite pos.
	BNE.S	SprWait1		; before turning off Sprite DMA,	
SprWait2
	CMPI.B	#55,VHPOSR(A5)		; coz otherwise we get the shitty
	BNE.S	SprWait2		; mouse pointer line! 

**********

Set_Up
	MOVE.W	#$7FFF,DMACON(A5)	; No DMA at all
	MOVE.L	#NewCop,COP1LCH(A5)	; Move in the new copper list
	MOVE.L	COPJMP1(A5),D0		; And start it (strobe)

	MOVE.W	#(SETIT!DMAEN!BPLEN!COPEN),DMACON(a5)

	move.l	$6c,oldirq	** interupt here Simon
	move.l	#newirq,$6c	
	bsr	mt_init

	move.w	#0,PageOffset		; Reset all the offsets
	move.w	#0,PageCount
	move.w	#0,TitOffset

	
************

; Load the bitplane pointers for the logo...

	move.l	#DSLogo,d0
	move.w	d0,lpl1l
	swap	d0
	move.w	d0,lpl1h
	swap	d0	
	add.l	#(40*50),d0
	move.w	d0,lpl2l
	swap	d0
	move.w	d0,lpl2h
	swap	d0
	add.l	#(40*50),d0
	move.w	d0,lpl3l
	swap	d0
	move.w	d0,lpl3h
	swap	d0
	add.l	#(40*50),d0
	move.w	d0,lpl4l
	swap	d0
	move.w	d0,lpl4h
	swap	d0

	jsr	ShowPage
	jsr	ShowTit
		
***********

Loop
	MOVE.L	#$DFF000,A5		; Use A5 as our custom base
	cmp.b	#200,VHPOSR(a5)
	bne.s	Loop
	
	btst	#10,$016(a5)		; Right Mouse?
	beq.s	TurnPageUp		; Yes, move forward 1 page
	
	btst	#6,CIAAPRA		; Left mouse?
	beq	TurnPageDown		; Yes, move forward 1 page
	
	btst	#7,CIAAPRA		; Fire on Joy1?
	bne.s	Loop			; No, so loop back
	
**********

; It's time to go home, time to go home...

QUIT	
	move.l	oldirq,$6c		; ** replace interupt
	bsr	mt_end

	MOVE.W	DMASave,D7
	BSET	#$F,D7
	MOVE.W	D7,DMACON(A5)		; Restore DMA

	MOVE.L	GfxBase,A0
	MOVE.L	$26(A0),COP1LCH(A5)	; Restore old copper list
	CLR.L	D0			
	MOVE.L	GfxBase,A1
	CALLEXEC CLOSELIBRARY		; Bye, GFX libby
	CALLEXEC PERMIT			; PC emulation off
	MOVE.L	StPoint,A7		; Get back, stack!
	MOVEM.L	(A7)+,A0-A6/D0-D7	; Go home, registers!
	RTS				; Nice to know you're here,
					; nice to know you're here,
					; It's nice to know you're here -
					; Now FUCK OFF!

**********				

TurnPageUp
	cmpi.w	#BottomPage,PageCount		; Are we at the last page?
	beq.s	FinishedUp			; Yes, so reset
YesTurnUp
	add	#1,PageCount			
	add	#SizeOfPage,PageOffset		; Increase text pointer by a page
	bsr	ShowPage			; Show new page		
	add	#SizeofTit,TitOffset
	bsr	ShowTit
	bra	Loop				; Return to main Loop
	
FinishedUp
	move.w	#0,PageCount			; Reset pointers to first page
	move.w	#0,PageOffset
	bsr	ShowPage			; Show first page
	move.w	#0,TitOffset
	bsr	ShowTit
	bra	Loop				; Return to main Loop
	
****

TurnPageDown
	cmpi.w	#TopPage,PageCount		; Are we at first page?
	bne.s	YesTurnDown			; No, so move back 1 page 
	bra	Loop
	
YesTurnDown
	sub	#1,PageCount
	sub	#SizeOfPage,PageOffset		; Decrease text pointer by 1 page
	bsr	ShowPage			; Show new page
	sub	#SizeOfTit,TitOffset
	bsr	ShowTit
	bra	Loop				; Return to loop
	
	
**********


; Now, let's show a page!

ShowPage

	move.w	#$000f,InkCol		; Make text blue
FadeLoop
	jsr	Pause			; A little pause
	subi.w	#$0001,InkCol		; Fade the text down
	cmpi.w	#$0005,InkCol		; Have we finished?
	bne.s	FadeLoop		; No, so loop

	clr.l	StrtPos			; Clear these counts before routine,
	clr.l	LineStrt		; otherwise the screen fucks up
	clr.w	HCount			; badly, eventually gurus!

	move.l	#Page1,a3
	MOVE.L	#Screen,D0		; Load pointers for text
	MOVE.W	D0,Pl1l
	SWAP	D0
	MOVE.W	D0,Pl1h

	MOVEQ.L	#0,D0

	add	PageOffset,a3
	MOVE.L	a3,A0			; Text address --> D0

	MOVE.L	#Screen,A2		; Screen address --> A2

	MOVE.L	A2,StrtPos		; Save current screen pointer
	MOVE.L	A2,LineStrt		; and current line start pointer


	move.w	#SizeofPage-1,d2		; Loop for 80*23 characters
ShowLoop
	MOVE.L	#Font,A1		; Address of font --> A1
	MOVE.B	(A0)+,D0		; Read the character

Spd_Dne
	CMPI.W	#80,HCount		; Screen width
	BNE.S	Not_Eol

	MOVE.W	#0,HCount
	MOVE.L	LineStrt,A2
	ADDA.L	#80*8,A2
	MOVE.L	A2,StrtPos
	MOVE.L	A2,LineStrt

Not_Eol
	CMPI.B	#96,D0			
	BGT.S	Lower_Char		; It's a-z
	CMPI.B	#63,D0
	BGT.S	Upper_Char		; It's A-Z
	CMPI.B	#31,D0
	BGT.S	Punc_Char		; Punctuation
	BRA	Skip			; Dunno what the fuck this is, so
					; don't write a char

Lower_Char
	SUBI.L	#97,D0			; Ascii --> Pointer
	ADD.L	D0,A1			; Add pointer to font pointer
	BRA	StrtPlt			; Print it!

Upper_Char
	SUBI.L	#65,D0			; Ascii --> Pointer
	addi.l	#26,d0			; Skip Lowercase chars
	ADD.L	D0,A1			; Add pointer to font pointer
	BRA	StrtPlt			; Print it!

Punc_Char
	SUBI	#32,D0			; Get offset
	ADDI.L	#52,D0			; Skip the alpha chars
	ADD.L	D0,A1			; Add the offset

StrtPlt
	MOVE.L	#7,D1			; The char is 8 lines high

PlotLp
	MOVE.B	(A1),(A2)		; Move 8 bits from font to screen
	ADDA.L	#84,A1			; Next line, font
	ADDA.L	#80,A2			; Next line, screen

	DBRA	D1,PlotLp		; Do the other lines

Skip
	ADDI.L	#1,StrtPos		; Next Horiz. position
	MOVE.L	StrtPos,A2		; Re-load screen pointer

	ADDI.W	#1,HCount		; Move along 1
	
	DBRA	d2,ShowLoop		; Do the whole page

*******************

FadeDnLoop
	jsr	Pause			; Une petite pause
	addi.w	#$0001,InkCol		; Fade text up
	cmpi.w	#$000f,InkCol		; Have we finished?
	bne.s	FadeDnLoop		; No, so repeat
	
	move.w	#$0fff,InkCol		; Make text white

	rts

************


; Now, let's show a title! Essentially, this is the same as showing
; a page, but just one line and lo-res.

ShowTit

	clr.l	TitStrtPos			; Clear these counts before routine,
	clr.l	TitLineStrt		        ; otherwise the screen fucks up
	clr.w	TitHCount			; badly, eventually gurus!

	move.l	#Page1Tit,a3
	MOVE.L	#TitScreen,D0			; Load pointers for title
	MOVE.W	D0,Tit1l
	SWAP	D0
	MOVE.W	D0,Tit1h
	swap	d0

	MOVEQ.L	#0,D0

	add	TitOffset,a3
	MOVE.L	a3,A0			; Text address --> D0

	MOVE.L	#TitScreen,A2		; Screen address --> A2

	MOVE.L	A2,TitStrtPos		; Save current screen pointer
	MOVE.L	A2,TitLineStrt		; and current line start pointer

	move.w	#SizeofTit-1,d2		; Loop for 40*1 characters
TitShowLoop
	MOVE.L	#Font,A1		; Address of font --> A1
	MOVE.B	(A0)+,D0		; Read the character

TitSpd_Dne
	CMPI.W	#40,TitHCount		; Screen width
	BNE.S	TitNot_Eol

	MOVE.W	#0,TitHCount
	MOVE.L	TitLineStrt,A2
	ADDA.L	#40*8,A2
	MOVE.L	A2,TitStrtPos
	MOVE.L	A2,TitLineStrt

TitNot_Eol
	CMPI.B	#96,D0
	BGT.S	TitLower_Char		; It's a-z
	CMPI.B	#63,D0
	BGT.S	TitUpper_Char		; It's A-Z
	CMPI.B	#31,D0
	BGT.S	TitPunc_Char		; It's punctuation
	BRA	TitSkip			; Dunno what the fuck this is, so
					; don't write a char
					
TitLower_Char
	SUBI.L	#97,D0			; Ascii --> Pointer
	ADD.L	D0,A1			; Add pointer to font pointer
	BRA	TitStrtPlt		; Print it!

TitUpper_Char
	SUBI.L	#65,D0			; Ascii --> Pointer
	addi.l	#26,d0
	ADD.L	D0,A1			; Add pointer to font pointer
	BRA	TitStrtPlt		; Print it!

TitPunc_Char
	SUBI	#32,D0			; Get offset
	ADDI.L	#52,D0			; Skip the alpha chars
	ADD.L	D0,A1			; Add the offset

TitStrtPlt
	MOVE.L	#7,D1			; The char is 8 lines high

TitPlotLp
	MOVE.B	(A1),(A2)		; Move 8 bits from font to screen
	ADDA.L	#84,A1			; Next line, font
	ADDA.L	#40,A2			; Next line, screen

	DBRA	D1,TitPlotLp		; Do the other lines

TitSkip
	ADDI.L	#1,TitStrtPos		; Next Horiz. position
	MOVE.L	TitStrtPos,A2		; Re-load screen pointer

	ADDI.W	#1,TitHCount		; Move along 1
	
	DBRA	d2,TitShowLoop		; Do whole line

	rts

***********************

; Wait for VBL 5 times

Pause
	moveq	#4,d0
PauseLoop
	cmp.b	#200,vhposr(a5)
	bne.s	PauseLoop
	
	dbra	d0,PauseLoop
	rts
	
************************

newirq					; ** interupt routine contains
	movem.l	d0-d7/a0-a6,-(a7)	
	Bsr	mt_music		; ** replayer call
	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9		
oldirq	
	dc.l		0		

;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн

mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_oldirq-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_speed-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_samplestarts-$7c(a1)
	move.b	d0,mt_counter-mt_samplestarts-$7c(a1)
	move.w	d0,mt_pattpos-mt_samplestarts-$7c(a1)
	rts


mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts


mt_music:
	lea	mt_data,a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1

	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	lea	mt_playvoice(pc),a6
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	jsr	(a6)

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	moveq	#0,d0
	move.b	d0,$e00(a3)
	move.b	#$a8,$400(a3)
	move.b	d0,$500(a3)
	or.w	#$8000,mt_dmacon-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_pattpos-mt_voice4(a4)
	cmp.w	#$400,mt_pattpos-mt_voice4(a4)
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos-mt_voice4(a4)
	clr.b	mt_break-mt_voice4(a4)
	addq.b	#1,mt_songpos-mt_voice4(a4)
	and.b	#$7f,mt_songpos-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos-mt_voice4(a4)
	clr.b	mt_songpos                <------ Bug Fix by MASTER BEAT!
mt_exit:tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_nonew:
	lea	$dff0a0,a5
	lea	mt_com(pc),a6
	jsr	(a6)
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	jsr	(a6)
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	jsr	(a6)
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	jsr	(a6)
	tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dmacon(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
	move.l	mt_oldirq(pc),$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_oldinstr

	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	move.l	mt_mulu(pc,d2.w),a3
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	moveq	#0,d3
	move.w	(a3)+,d3
	beq	mt_noloop
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:dcb.l	$20,0

mt_noloop:
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)
	move.w	$12(a4),8(a5)

mt_oldinstr:
	move.w	(a4),d3
	and.w	#$fff,d3
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	d3,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0
	or.w	d0,mt_dmacon-mt_playvoice(a6)
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:moveq	#0,d0
	move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	move.b	d0,3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_normper
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
mt_arp3:cmp.w	(a0)+,d1
	blt.s	mt_arp3
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	beq.s	mt_arp
	cmp.b	#6,d0
	beq.s	mt_volvib
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:move.w	$12(a4),8(a5)
	rts

mt_com2:move.b	2(a4),d0
	and.b	#$f,d0
	beq	mt_rts
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break-mt_playvoice(a6)
	rts

mt_songjmp:
	move.b	#1,mt_break-mt_playvoice(a6)
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_playvoice(a6)
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed-mt_playvoice(a6)
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8
mt_oldirq:	dc.l	0


*********************

; A few funky little variables for your delight (or St. Ivel Gold...)

GfxName		DC.B	'graphics.library'
		EVEN

HCount		DC.W	0
StrtPos		DC.L	0
GfxBase		DC.L	0
StPoint		DC.L	0
DMASave		DC.W	0
LineStrt	DC.L	0
PageOffset		dc.w	0
PageCount	dc.w	0

TitHCount	dc.w	0
TitStrtPos	dc.l	0
TitLineStrt	dc.l	0
TitOffset	dc.w	0
	even

**********

; The binaries!

Font	
	incbin	source:bitmaps/mbfont.raw

DSLogo	incbin source:bitmaps/dslogo2

	even
	
**********

; The titles!
; NB. 40 chars wide, 1 line = 40 bytes

		;1234567890123456789012345678901234567890
Page1Tit
	DC.B	"                Welcome                 "
Page2Tit
	dc.b	"            Credits & Greets            "
Page3Tit	
	dc.b	"          What's gonna be in it?        "
Page4Tit
	dc.b	"               About Me!                "
	even
	
**********

; The text is here!
; NB.   80 chars wide, 23 lines = 1840 bytes


Page1		;12345678901234567890123456789012345678901234567890123456789012345678901234567890

	DC.B	"                            M A S T E R  B E A T                                "
	DC.B	"                                                                                "
	DC.B	"                          Is Very Proud to Present                              "
	DC.B	"                           the Prototype for.....                               "
	DC.B	"                                                                                "
	DC.B	"                       ******************************                           "
	DC.B	"                       * D R E A M  S E Q U E N C E *                           "
	DC.B	"                       ******************************                           "
	DC.B	"                                                                                "
	DC.B	"                                                                                "
	DC.B	"            Which will hopefully become the Official UNITY Diskmag.             "
	DC.B	"                                                                                "
	DC.B	"      That is, if.....                                                          "
	DC.B	"                                                                                "
	DC.B	"                     A. Enough people are interested, and                       "
	DC.B	"                     B. I can be bothered doing it!                             "
	DC.B	"                                                                                "
	DC.B	"  I hope I can get something off the ground, even in a small way, as I have     "
	DC.B	"always enjoyed writing, and I relish the thought of being able to edit a whole  "
	DC.B	"magazine!   More details about this magazine idea on another page, but first... "
	DC.B	"                                                                                "
	DC.B	"                                                                                "
	DC.B	"RIGHT MOUSE TO MOVE FORWARD 1 PAGE, LEFT MOUSE TO GO BACK, FIRE ON STICK 1 QUITS"                        
	

Page2
	DC.B	"I think we need some credits for this prototype, so here we go....              "
	DC.B	"                                                                                "
	DC.B	"                                    CODE                                        "
	DC.B	"                                   ------                                       "
	DC.B	"                              MASTER BEAT (Me!)                                 "
	DC.B	"                                                                                "
	DC.B	"                                    LOGO                                        "
	DC.B	"                                   ------                                       "
	DC.B	"                                 Moi Aussi!                                     "
	DC.B	"                                                                                "
	DC.B	"  Well, that wasn't difficult, hehehe!  Okay, You've twisted my arm! Here are a "
	DC.B	"few thank yous and regards to some people who have helped in some way with the  "
	DC.B	"coding of this prototype...                                                     "
	DC.B	"                                                                                "
	DC.B	"TECH - Well Neil, you are first seeing as I would not have been able to do any  "
	DC.B	"of this without first looking at your ScreenTyper code!  Thanks also for the    "
	DC.B	"nice letter, but speaking as a dead goldfish, I think we are very talented!     "
	DC.B	"FM - Thanks for sorting out the music routine, I still don't like interrupts... "
	dc.b	"Oh yeah Blaine, isn't this a big improvement over the original???               "
	dc.b	"                                                                                "
	DC.B	"And of course, thanks to all other members of ACC, such as Mr. Hardware, (MIKE!)"
	DC.B	"Messrs. Intuition (MARK AND STEVE!) and Mr. Docs (DAVE!) as well as the rest of "
	DC.B	"you, like Raistlin, Nipper, and all other contributers!!!                       "	          


Page3
	DC.B	"So what will be in this mag, if it ever starts.   Well, hardly any coding, as   "
	DC.B	"ACC is definitely the best coding mag available.  And no real Scene news, as the"
	DC.B	"mag would then be the same as a myriad of others.  Instead, I want to see varied"
	DC.B	"articles about absolutely !ANYTHING!  Whether its computer related or not.      "
	DC.B	" As an example, if you've had any weird dreams lately, write in and tell me them"
	DC.B	"and I will try to analyse them!  Sounds freaky, but nobody else has done this!  "
	DC.B	"I'm also considering writing an article about UFOs, after reading one of Timothy"
	DC.B	"Goods excellent books on the subject of Governmental cover-ups...               "
	DC.B	"  On a distinctly lighter note, I am planning a Name That Tune competition, with"
	DC.B	"a sampled snatch of a song. People can enter by sending in a disk and the winner"
	DC.B	"collects every disk sent in.  Charts for all sorts of things will probably be in"
	DC.B	"split up into  Amiga stuff such as Best Gfx, Coders, etc. and Non-Amiga stuff   "
	DC.B	"like best TV programme, Real Music etc.  Also, there can be other compos,  GFX  "
	DC.B	"and Music, or a best Demo competition.  And there will be a classified adverts  "
	DC.B	"section with free adverts!     And really, anything else I can think of, or if  "
	DC.B	"any of you lot can think of a cool idea it goes in!  Something like a send me 10"
	DC.B	"quid competition would be rather nice....                                       "
	DC.B	"                                                                                "
	DC.B	"                                                                                "
	DC.B	"To contact me for anything, especially UNITY information and DREAM SEQUENCE     "
	DC.B	"articles, suggestions, offers of help in organising it etc., write to...        "
	DC.B	"                                                                                "
	DC.B	"15, HOLT FARM CLOSE, HOLT PARK, LEEDS, WEST YORKSHIRE, ENGLAND   LS16 7SE.      "		 


Page4
	include source:masterbeat/aboutme2.doc	

	EVEN

**********

; Ooooh! That naughty copperlist!

	SECTION LoLoLo,CODE_C
NewCop
	DC.W	BPLCON0,(COLOR)
	DC.W	BPLCON1,$0000
	DC.W	DIWSTRT,$2281		
	DC.W	DIWSTOP,$30c1
	DC.W	DDFSTRT,$0038		
	DC.W	DDFSTOP,$00D0
	DC.W	BPL1MOD,$0000		
	DC.W	BPL2MOD,$0000

	DC.W	COLOR00,$0000
	
	dc.w	$2401,$fffe,COLOR00,$0B00
	DC.W	$2701,$FFFE,COLOR00,$0800
	dc.w	$2901,$fffe,BPLCON0,(BPU2!COLOR)

************************

; Logo
	
	DC.W	BPL1PTH
lpl1h	DC.W	0,BPL1PTL
lpl1l	DC.W	0,BPL2PTH
lpl2h	dc.w	0,BPL2PTL
lpl2l	dc.w	0,BPL3PTH
lpl3h	dc.w	0,BPL3PTL
lpl3l	dc.w	0,BPL4PTH
lpl4h	dc.w	0,BPL4PTL
lpl4l	dc.w	0

	dc.w	$0180,$0800,$0182,$070f,$0184,$0f0f,$0186,$003e
	dc.w	$0188,$003f,$018a,$014f,$018c,$035f,$018e,$046f
	dc.w	$0190,$067f,$0192,$079f,$0194,$08af,$0196,$0abf
	dc.w	$0198,$0bcf,$019a,$0cdf,$019c,$0eef,$019e,$0fff
	
	dc.w	$5b01,$fffe,BPLCON0,(COLOR)
	DC.W	$5C01,$FFFE,COLOR00,$0400

	DC.W	$5E01,$FFFE,COLOR00,$0005
	DC.W	$6301,$FFFE

	dc.w	BPLCON0,(HIRES!BPU0!COLOR)
	dc.w	DDFSTRT,$3c,DDFSTOP,$d4

*************************
; Text

	DC.W	BPL1PTH
Pl1h	DC.W	0,BPL1PTL
Pl1l	DC.W	0
	
	DC.W	$180,$0005,$182
InkCol	dc.w	$0fff
	
	DC.W	$FFE1,$FFFE

	DC.W	$2101,$FFFE,COLOR00,$0080
	DC.W	$2401,$FFFE,COLOR00,$0060
	dc.w	$2701,$fffe,BPLCON0,(BPU0!COLOR)
	dc.w	DDFSTRT,$38,DDFSTOP,$d0

**********************
; Title

	DC.W	BPL1PTH
Tit1h	dc.w	0,BPL1PTL
Tit1l	dc.w	0

	dc.w	COLOR01,$0fff
	dc.w	$3001,$fffe,BPLCON0,$0200
	dc.w	$3201,$fffe,COLOR00,$0040
	dc.w	$3501,$fffe,COLOR00,$0000

	dc.w	$ffff,$fffe

*****************************************

Screen	dcb.b	18000,0
TitScreen dcb.b	(80*10),0
	even
mt_data		incbin		"source:modules/mod.music"					
					
   END

