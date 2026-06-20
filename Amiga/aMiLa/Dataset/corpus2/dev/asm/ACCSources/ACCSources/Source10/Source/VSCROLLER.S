*	AT LONG LAST! MY FIRST DEMO! IT`S BASIC, BUT IT WORKS, (QUITE A
*	NOVELTY WITH MY CODE!) JUST A SIMPLE SCREEN BEING BOUNCED UP
*	AND DOWN TO A NEAT SOUNDTRACK.

*	EXTRA:
*	OH DEAR! I SEEM TO HAVE LOST THE NOVELTY OF HAVING MY CODE WORK!
*	SOMETIMES THE SCREEN IS TRASHED, AND THE INTERRUPT ROUTINE CAUSES
*	PROBLEMS ON EXIT! (READ MY DOC FILE.) CAN SOMEBODY HELP! PLEASE!
*	WHAT AM I DOING WRONG?

**********

	SECTION DEMO1,CODE_C		CODE 2 CHIPMEM
	OPT	C-			NO CASE SENSITIVITY

**********

	INCDIR	SYS:INCLUDE/
	INCLUDE	HARDWARE/CUSTOM.I
	INCLUDE	EXEC/EXEC_LIB.I

**********

START	MOVE.L	A7,STPOINT		SAVE STACK POINTER
	MOVEM.L	A0-A6/D0-D7,-(A7)	SAVE ALL REGISTERS
	MOVE.L	#$DFF000,A5		I USE A5 AS MY HW REG. (SOMETIMES!!!)
	CALLEXEC FORBID			TURN OFF MULTITASKING
	LEA	GFXNAME(PC),A1
	
	CLR.L	D0
	CALLEXEC OPENLIBRARY		OPEN GFX LIBRARY
	MOVE.L	D0,GFXBASE
	MOVE.W	DMACONR(A5),DMASAVE	SAVE CLI DMA SETTINGS
	MOVE.W	INTENAR(A5),INTENSAVE	SAVE CLI INT SETTINGS
	MOVE.W	INTREQR(A5),INTRQSAVE	SAVE CLI INT SETTINGS

WAIT1	BTST	#0,VPOSR(A5)		WAIT FOR VBL
	BNE.S	WAIT1			BEFORE TURNING
WAIT2	CMPI.B	#55,VHPOSR(A5)		SPRITE DMA OFF TO
	BNE.S	WAIT2			PREVENT CRAP APPEARING

SET_UP	MOVE.L	#NEWCOP,COP1LC(A5)	STICK MY NEW COPPER IN...
	MOVE.L	COPJMP1(A5),D0		...AND STROBE IT
	MOVE.W	#%1000001110100000,DMACON(A5)	BPL+COP+SPR DMA ONLY!!!!
	
**********

	JSR	SETUP_STARS		SETUP STARS...
	JSR	MT_INIT			SETUP TRACKER...	
	JSR	SET_UP_INT		SETUP INTERUPT...

***********


	MOVE.L	#BMP,D0			POINTERS TO MY 320*512 PIC.
	MOVE.W	D0,PL1L
	SWAP	D0
	MOVE.W	D0,PL1H
	SWAP	D0
	ADDI.L	#20480,D0
	MOVE.W	D0,PL2L
	SWAP	D0
	MOVE.W	D0,PL2H
	SWAP	D0
	ADDI.L	#20480,D0
	MOVE.W	D0,PL3L
	SWAP	D0
	MOVE.W	D0,PL3H
	
	MOVEQ.L	#$0,D7			CLEAR COUNTER
	MOVEQ.L	#$0,D6			CLEAR FLAG
	
	JSR	PAUSE			HOLD THE SCREEN FOR A WHILE

BOUNCE	JSR	BOUNCER			GOTO MY PIC BOUNCE ROUTINE...


LOOP	BTST	#6,$BFE001		BORED OF DEMO YET?
	BNE.S	BOUNCE			NAAAAHHHH!

**********

QUIT	MOVE.L	OLDINT+2,$6C
	JSR	MT_END
	
	MOVE.W	DMASAVE,D7		RESTORE THE DMA.
	BSET	#$F,D7
	MOVE.W	D7,DMACON(A5)

	
	MOVE.L	GFXBASE,A0
	MOVE.L	$26(A0),COP1LC(A5)	FIND/REPLACE SYSTEM COPPER
	MOVEQ.L	#0,D0
	MOVE.L	GFXBASE,A1
	CALLEXEC CLOSELIBRARY		CLOSE GRAPHICS LIBRARY
	CALLEXEC PERMIT			TURN ON MULTITASKING
	MOVEM.L	(A7)+,A0-A6/D0-D7	RESTORE REGISTERS...
	MOVE.L	STPOINT,A7		...AND OLD STACK
	RTS				GOODBYE CRUEL WORLD (SOB!)

********************************************************************
*								   *
*		THIS IS THE START OF MY MAIN ROUTINE		   *
*								   *
********************************************************************

BOUNCER	
	MOVE.L	#5,D1			INCREASE `5` FOR SLOWER SCROLLING
BOUNC	CMPI.B	#255,$DFF006		WAIT FOR LINE 255
	BNE.S	BOUNCER			WAIT FOR A NEW FRAME
	DBRA	D1,BOUNC

	CMPI.L	#0,D7			D7: #0=DOWN, #F=UP
	BEQ	GO_DN
	BRA	GO_UP

GO_DN	CMPI.L	#256,D6			D6: UP/DN COUNTER
	BEQ	DN_LIMIT		REACHED BOTTOM OF PIC?

	ADDI.W	#40,PL1L		DOWN 1 LINE (40 WORDS)
	ADDI.W	#40,PL2L
	ADDI.W	#40,PL3L
	ADDI.L	#1,D6			ADD 1 TO COUNTER

	RTS

DN_LIMIT
	MOVEQ.L	#$F,D7			GO UP FROM NOW ON
	MOVEQ.L	#0,D6			RESET COUNTER

	JSR	PAUSEX			WAIT A WHILE (LONGER)

	RTS

GO_UP	CMPI.L	#256,D6			CHECK PIC POSITION
	BEQ	UP_LIMIT		REACHED TOP OF PIC?
	
	SUBI.W	#40,PL1L		UP 1 LINE (40 WORDS)
	SUBI.W	#40,PL2L
	SUBI.W	#40,PL3L
	ADDI.L	#1,D6			ADD 1 TO COUNTER

	RTS

UP_LIMIT
	MOVE.L	#$0,D7			GO DOWN FROM NOW ON
	MOVEQ.L	#0,D6			RESET COUNTER

	JSR	PAUSE			WAIT A WHILE

	RTS

**********

PAUSE	MOVE.L	#1000,D3		YES, I KNOW DELAYS WHICH DECREMENT
PAWS	CMPI.B	#255,$DFF006		A COUNTER ARE NOT VERY ACCURATE, BUT
	BNE.S	PAWS			IT WORKS (PROBABLY ONLY JUST!).
	BTST	#6,$BFE001
	BEQ	QUIT			QUICK EXIT
	DBRA	D3,PAWS			TIME WASTING...YAWN!
	RTS

PAUSEX	MOVE.L	#2000,D3		...JUST TO GIVE YOU A BIT LONGER
	BRA	PAWS			TO READ THE STUFF AT THE BOTTOM.


**********

SET_UP_INT
	MOVE.L	$6C,OLDINT+2		THANKS TO MIKE CROSS FOR THIS BIT.
	MOVE.L	#NEWINT,$6C		BUT I STILL DON`T KNOW HOW TO SET 
	RTS				UP A `LEGAL` INTERUPT! (YET)

**********

NEWINT	MOVEM.L	A0-A6/D0-D7,-(A7)
	JSR	MT_MUSIC		WHAT AN ORIGINAL INTERUPT ROUTINE!!!
	JSR	STARS
	MOVEM.L	(A7)+,A0-A6/D0-D7

OLDINT	JMP	$0			SELF-MODIFYING-CODE? NAUGHTY!

**********
NEWCOP	DC.W	BPLCON0,$3200		STANDARD COPPER SETUP 
	DC.W	BPLCON1,$0000
	DC.W	DIWSTRT,$2281		
	DC.W	DIWSTOP,$22C1
	DC.W	DDFSTRT,$0038		
	DC.W	DDFSTOP,$00D0
	DC.W	BPL1MOD,$0000		
	DC.W	BPL2MOD,$0000
	
	DC.W	BPLPT+$00			BITPLANE POINTERS:
PL1H	DC.W	0,BPLPT+$02
PL1L	DC.W	0,BPLPT+$04
PL2H	DC.W	0,BPLPT+$06	
PL2L	DC.W	0,BPLPT+$08
PL3H	DC.W	0,BPLPT+$0A		
PL3L	DC.W	0

	dc.w	$0180,$0000		PALETTE DATA
	dc.w	$0182,$0FFF		COURTESY OF IFFMASTER!
	dc.w	$0184,$0BCE		(MY FAV IFF CONVERTER!)
	dc.w	$0186,$089D
	dc.w	$0188,$056C
	dc.w	$018A,$023B
	dc.w	$018C,$000A
	dc.w	$018E,$0777

*			STARS STUFF IS `BORROWED` STRAIGHT FROM
*			A ROUTINE OFF AN EARLY ACC DISK.

Sp_Ptr	DC.L $01200000,$01220000	Sprite0 PTH/L
	DC.L $01240000,$01260000	Sprite1 PTH/L
	DC.L $01280000,$012A0000	Sprite2 PTH/L
	DC.L $012C0000,$012E0000	Sprite3 PTH/L
	DC.L $01300000,$01320000	Sprite4 PTH/L
	DC.L $01340000,$01360000	Sprite5 PTH/L
	DC.L $01380000,$013A0000	Sprite6 PTH/L
	DC.L $013C0000,$013E0000	Sprite7 PTH/L
Sp_Col	DC.L $01A20999			COLOR 17
	DC.L $01A40BBB			COLOR 18
	DC.L $01A80000			COLOR 19

	DC.W	$FFFF,$FFFE		AND WAIT FOR THE IMPOSSIBLE!

**********				LABELS CRAP FOLLOWS...

GFXNAME		DC.B	'graphics.library'
		EVEN

GFXBASE		DC.L	0
STPOINT		DC.L	0
DMASAVE		DC.W	0
INTENSAVE	DC.W	0
INTRQSAVE	DC.W	0
Sprite_Empty    DCB.B 10,0
BMP		INCBIN	source10:bitmaps/TECHDEMO1.BMP
		EVEN

*******************	TRACKER PLAY ROUTINE FROM ACC DISKS AS WELL!!!



**************************************
*   NoisetrackerV1.0 replayroutine   *
* Mahoney & Kaktus - HALLONSOFT 1989 *
**************************************


mt_init:BSET	#1,$BFE001		FILTER OFF
	lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	BCHG	#1,$BFE001			FILTER ON
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts




mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0

mt_data incbin "source10:modules/mod.killer"

* NOTE: METALSYNTH IS MY FAVOURITE ST. MODULE!

********************		GUESS WHERE THIS ROUTINE CAME FROM?!?!

SetUp_STARS
	MOVE.L	#Sprite,D0		Address of Stars
	LEA  	Sp_Ptr,A0  		pointers in Coperlist
        MOVE.W  D0,6(A0)		Load high word
	SWAP 	D0			swap words
	MOVE.W  D0,2(A0)		Load low words
        MOVE.L  #Sprite_Empty,D0	Empty Sprite
	LEA  	Sp_Ptr,A0		Pointers in copper
	ADD.L   #8,A0			Point Past Sprite0
	MOVE.L  #6,D1			Loop Value
Sp_Lp	MOVE.W  D0,6(A0) 		Load Blank Sprites Loop
	SWAP    D0
	MOVE.W  D0,2(A0)
	SWAP    D0
	ADD.L	#8,A0			Next pointer in Copper
	DBF     D1,Sp_Lp		Loop
	RTS



****************************************************************************
*				STARS					   *
****************************************************************************

Stars   MOVE.L	#SpriteE-Sprite,D2	Length (N) of Star data block
	DIVU	#(8*3),D2		No.Layers (3)
	MOVE.L	#Sprite,A0		Address of stars
Ch	CMPI.B	#$DF,1(A0)		Reached far right of screen?
	BNE.S   Mv			No,branch
	MOVE.B	#$38,1(A0)		Yes,reset to far left 
Mv	ADDQ.B  #$1,1(A0)		1st layer speed
	ADDQ.B	#$2,9(A0)		2nd layer speed
	ADDQ.B	#$3,17(A0)		3rd layer speed
	ADD.L	#24,A0			Next 3 stars
	DBF.W	D2,Ch			Loop N times
	RTS				Cool Routine Huh?

****************************************************************************
*				STAR POS				   *
****************************************************************************


Sprite
	dc.w    $307A,$3100,$1000,$0000,$3220,$3300,$1000,$0000
	dc.w    $34C0,$3500,$1000,$0000,$3650,$3700,$1000,$0000
	dc.w    $3842,$3900,$1000,$0000,$3A6D,$3B00,$1000,$0000
	dc.w    $3CA2,$3D00,$1000,$0000,$3E9C,$3F00,$1000,$0000
	dc.w    $40DA,$4100,$1000,$0000,$4243,$4300,$1000,$0000
	dc.w    $445A,$4500,$1000,$0000,$4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000,$4A68,$4B00,$1000,$0000
	dc.w    $4CB8,$4D00,$1000,$0000,$4EB4,$4F00,$1000,$0000
	dc.w    $5082,$5100,$1000,$0000,$5292,$5300,$1000,$0000
	dc.w    $54D0,$5500,$1000,$0000,$56D3,$5700,$1000,$0000
	dc.w    $58F0,$5900,$1000,$0000,$5A6A,$5B00,$1000,$0000
	dc.w    $5CA5,$5D00,$1000,$0000,$5E46,$5F00,$1000,$0000
	dc.w    $606A,$6100,$1000,$0000,$62A0,$6300,$1000,$0000
	dc.w    $64D7,$6500,$1000,$0000,$667C,$6700,$1000,$0000
	dc.w    $68C4,$6900,$1000,$0000,$6AC0,$6B00,$1000,$0000
	dc.w    $6C4A,$6D00,$1000,$0000,$6EDA,$6F00,$1000,$0000
	dc.w    $70D7,$7100,$1000,$0000,$7243,$7300,$1000,$0000
	dc.w    $74A2,$7500,$1000,$0000,$7699,$7700,$1000,$0000
	dc.w    $7872,$7900,$1000,$0000,$7A77,$7B00,$1000,$0000
	dc.w    $7CC2,$7D00,$1000,$0000,$7E56,$7F00,$1000,$0000
	dc.w    $805A,$8100,$1000,$0000,$82CC,$8300,$1000,$0000
	dc.w    $848F,$8500,$1000,$0000,$8688,$8700,$1000,$0000
	dc.w    $88B9,$8900,$1000,$0000,$8AAF,$8B00,$1000,$0000
	dc.w    $8C48,$8D00,$1000,$0000,$8E68,$8F00,$1000,$0000
	dc.w    $90DF,$9100,$1000,$0000,$924F,$9300,$1000,$0000
	dc.w    $9424,$9500,$1000,$0000,$96D7,$9700,$1000,$0000
	dc.w    $9859,$9900,$1000,$0000,$9A4F,$9B00,$1000,$0000
	dc.w    $9C4A,$9D00,$1000,$0000,$9E5C,$9F00,$1000,$0000
	dc.w    $A046,$A100,$1000,$0000,$A2A6,$A300,$1000,$0000
	dc.w    $A423,$A500,$1000,$0000,$A6FA,$A700,$1000,$0000
	dc.w    $A86C,$A900,$1000,$0000,$AA44,$AB00,$1000,$0000
	dc.w    $AC88,$AD00,$1000,$0000,$AE9A,$AF00,$1000,$0000
	dc.w    $B06C,$B100,$1000,$0000,$B2D4,$B300,$1000,$0000
	dc.w    $B42A,$B500,$1000,$0000,$B636,$B700,$1000,$0000
	dc.w    $B875,$B900,$1000,$0000,$BA89,$BB00,$1000,$0000
	dc.w    $BC45,$BD00,$1000,$0000,$BE24,$BF00,$1000,$0000
	dc.w    $C0A3,$C100,$1000,$0000,$C29D,$C300,$1000,$0000		
	dc.w    $C43F,$C500,$1000,$0000,$C634,$C700,$1000,$0000		
	dc.w    $C87C,$C900,$1000,$0000,$CA1D,$CB00,$1000,$0000		
	dc.w    $CC6B,$CD00,$1000,$0000,$CEAC,$CF00,$1000,$0000		
	dc.w    $D0CF,$D100,$1000,$0000,$D2FF,$D300,$1000,$0000		
	dc.w    $D4A5,$D500,$1000,$0000,$D6D6,$D700,$1000,$0000		
	dc.w    $D8EF,$D900,$1000,$0000,$DAE1,$DB00,$1000,$0000		
	dc.w    $DCD9,$DD00,$1000,$0000,$DEA6,$DF00,$1000,$0000		
	dc.w    $E055,$E100,$1000,$0000,$E237,$E300,$1000,$0000		
	dc.w    $E47D,$E500,$1000,$0000,$E62E,$E700,$1000,$0000		
	dc.w    $E8AF,$E900,$1000,$0000,$EA46,$EB00,$1000,$0000
	dc.w	$EC65,$ED00,$1000,$0000,$EE87,$EF00,$1000,$0000
	dc.w	$F0D4,$F100,$1000,$0000,$F2F5,$F300,$1000,$0000
	dc.w	$F4FA,$F500,$1000,$0000,$F62C,$F700,$1000,$0000
	dc.w	$F84D,$F900,$1000,$0000,$FAAC,$FB00,$1000,$0000
	dc.w	$FCB2,$FD00,$1000,$0000,$FE9A,$FF00,$1000,$0000
	dc.w	$009A,$0106,$1000,$0000,$02DF,$0306,$1000,$0000
	dc.w	$0446,$0506,$1000,$0000,$0688,$0706,$1000,$0000
	dc.w	$0899,$0906,$1000,$0000,$0ADD,$0B06,$1000,$0000
	dc.w	$0CEE,$0D06,$1000,$0000,$0EFF,$0F06,$1000,$0000
	dc.w	$10CD,$1106,$1000,$0000,$1267,$1306,$1000,$0000
	dc.w	$1443,$1506,$1000,$0000,$1664,$1706,$1000,$0000
	dc.w	$1823,$1906,$1000,$0000,$1A6D,$1B06,$1000,$0000
	dc.w	$1C4F,$1D06,$1000,$0000,$1E5F,$1F06,$1000,$0000
	dc.w	$2055,$2106,$1000,$0000,$2267,$2306,$1000,$0000
	dc.w	$2445,$2506,$1000,$0000,$2623,$2706,$1000,$0000
	dc.w	$2834,$2906,$1000,$0000,$2AF0,$2B06,$1000,$0000
	dc.w	$2CBC,$2D06,$1000,$0000
SpriteE	dc.w 	$0000,$0000










