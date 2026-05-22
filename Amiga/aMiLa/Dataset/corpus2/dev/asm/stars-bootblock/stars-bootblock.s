
		INCDIR	INCLUDES:
		INCLUDE	Exec/Macros.i
		INCLUDE	Exec/ExecBase.i
		INCLUDE	Exec/Exec.i
		INCLUDE	Lvo/Exec.i

SCREEN		EQU	(320/8)*200
SPRITE		EQU	768*3
_AbsExecBase	EQU	4

		SECTION	OLDSCHOOL_SCENE_AMIGA_BOOTBLOCK,CODE_C

**********************************************************************
***
***	OLDSCHOOL AMIGA BOOTBLOCK WITH STARS FROM LEFT TO RIGHT
***	CODED BY STRICHER OF ANAL INFECT (A SUBGROUP OF ANAL FATAL)
***	CALL ALL OUR BOARDS:	HOUSE OF BOOBS
***				ASS WIDE OPEN (RINGDOWN)
***
***	AND DONT FORGET TO ORDER THE BEST CATALOG FILE MAKER
***	FOR THE AMIGA !
***
***	-*- CFM V1.0 OUT NOW -*- CFM V1.0 OUT NOW -*- CFM V1.0 OUT NOW -*-
***
**********************************************************************

BOOTBLOCK	DB	"DOS",0
		DL	$0F714DDA
		DL	880

START		Movem.l	d0-d7/a0-a6,-(sp)

		Move.l	#SCREEN+SPRITE,d0
		Move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		Move.l	(_AbsExecBase).w,a6
		JSRLIB	AllocMem
		Tst.l	d0
		Beq	OUT

		Move.l	d0,a5
		Add.l	#SCREEN,d0
		Move.l	d0,a4

		Move.l	a5,a0
		Lea	(SCREEN_PTR,pc),a1
		Moveq	#1-1,d1
		CLEAR	d2
		Bsr	InitBPL

		Move.l	a4,a0
		Lea	(SPRITE_PTR,pc),a1
		Moveq	#3-1,d1
		Move.l	#SPRITE/3,d2
		Bsr	InitBPL

		Bsr	INIT_SPRITES
		Bsr.s	COPY_IMAGE

		Move.w	#$4000,$dff09a
		Move.w	#$8020,$dff096

		Lea	(COPPERLIST,pc),a0
		Move.l	a0,$dff084
		Clr.w	$dff08a

LMB		Move.l	$dff004,d0
		And.l	#$fff00,d0
		Cmp.l	#$0b000,d0
		Bne.s	LMB

		Bsr.s	MOVE_SPRITES

		Btst	#6,$bfe001
		Bne.s	LMB

		Move.w	#$c000,$dff09a

		Move.l	#SCREEN+SPRITE,d0
		Move.l	a5,a1
		Move.l	(_AbsExecBase).w,a6
		JSRLIB	FreeMem

OUT		Movem.l	(sp)+,d0-d7/a0-a6
		Rts

InitBPL		Movem.l	d0-d2/a0-a1,-(sp)
		Move.l	a0,d0
.\bpl		Move.w	d0,6(a1)
		Swap	d0
		Move.w	d0,2(a1)
		Swap	d0
		Addq.l	#8,a1
		Add.l	d2,d0
		Dbra	d1,.\bpl
		Movem.l	(sp)+,d0-d2/a0-a1
		Rts

COPY_IMAGE	Moveq	#4-1,d0
		Moveq	#21-1,d1
		Lea	(IMAGE,pc),a0
		Move.l	a5,a2
		Lea	(((320/8)*60)+11,a2),a2
lab0		Move.l	a0,a1
		Move.l	a2,a3
		Move.l	d0,d2
lab1		Move.l	(a1)+,(a3)+
		Dbra	d2,lab1
		Lea	(16,a0),a0
		Lea	(40,a2),a2
		Dbra	d1,lab0
		Rts

MOVE_SPRITES	Move.l	a4,a0
		Move.l	a0,a1
		Move.l	#768,d0
		Moveq	#3-1,d1
		Moveq	#3,d2

.next		Moveq	#96-1,d3
.spr0		Add.b	d2,(1,a0)
		Addq.l	#8,a0
		Dbra	d3,.spr0

		Subq.l	#1,d2
		Add.l	d0,a1
		Move.l	a1,a0
		Dbra	d1,.next
		Rts

INIT_SPRITES	Move.l	a4,a0
		Lea	(POS_TAB,pc),a1
		Move.l	a0,a2
		Move.l	#768,d0
		Moveq	#3-1,d1
		Moveq	#1,d2
		Moveq	#0,d3

.@\next		Moveq	#96-1,d4
		Move.w	#163,d5
.@\init		Move.w	(a1),(a0)+
		Move.w	(2,a1),(a0)+
		Move.w	d2,(a0)+
		Move.w	d3,(a0)+
		Add.b	#2,(a1)
		Move.b	$dff006,d6
		Sub.b	d6,d5
		Add.b	d5,(1,a1)
		Add.w	#512,(2,a1)
		Dbra	d4,.@\init

		Addq.l	#4,a1
		Add.l	d0,a2
		Move.l	a2,a0
		Exg	d2,d3
		Dbra	d1,.@\next
		Rts

POS_TAB		DW	$5c67,$5d00,$5d47,$5e00,$5ea4,$5f00

COPPERLIST	DW	$008e,$6081,$0090,$f4c1,$0092,$0038,$0094,$00d0

SPRITE_PTR	DW	$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000
		DW	$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000
		DW	$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
		DW	$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000

		DW	$01a2,$0ccc,$01a4,$0999,$01aa,$0666

		DW	$01fc,$0000		; Fetchmode off
		DW	$0100,$1200
		DW	$0102,$0000
		DW	$0104,$0000
		DW	$0106,$0000
		DW	$0108,$0000
		DW	$010a,$0000

		DW	$0180,$0204
		DW	$5a09,$fffe,$0180,$0fff
		DW	$5b09,$fffe,$0180,$0213

		DW	$0182,$0fff
SCREEN_PTR	DW	$00e0,$0000,$00e2,$0000

		DW	$f509,$fffe,$0180,$0fff
		DW	$f609,$fffe,$0180,$0204

		DL	-2

IMAGE		DW	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF	; 128x21
		DW	$FFFF,$FFFE,$C000,$0000,$0000,$0000
		DW	$0000,$0000,$0000,$0003,$81E3,$81B6
		DW	$F367,$01CF,$03C7,$1CF7,$9871,$CD81
		DW	$81B6,$C1B6,$DB6C,$036D,$836D,$B666
		DW	$D8DB,$6D81,$81B6,$C1B6,$F36F,$836D
		DW	$83CD,$B667,$98DB,$0F01,$81B6,$C0E6
		DW	$DB61,$836D,$836D,$B666,$D8DB,$6D81
		DW	$81B3,$8046,$D9CF,$01CD,$83C7,$1C67
		DW	$8E71,$CD81,$8000,$0000,$0000,$0000
		DW	$0000,$0000,$0000,$0001,$81E7,$8F38
		DW	$E062,$2F03,$CE03,$8E79,$EDE6,$CF01
		DW	$81B6,$D861,$8063,$6D81,$9B06,$DB6C
		DW	$CDB6,$D801,$81E7,$9C7D,$F063,$EF01
		DW	$9B06,$1B6C,$CDB6,$DC01,$8186,$D80C
		DW	$3063,$6D81,$9B06,$DB6C,$CDB6,$D801
		DW	$8186,$CF79,$E03B,$6F01,$8E03,$8E6C
		DW	$CDB3,$8F01,$8000,$0000,$0000,$0000
		DW	$0000,$0000,$0000,$0001,$80E3,$98C1
		DW	$806C,$E6CE,$3C0E,$3C1E,$38E7,$8E01
		DW	$81B6,$D8C1,$806D,$B6D8,$601B,$601B
		DW	$6DB6,$D801,$8187,$D8C0,$007D,$B6DF
		DW	$701B,$701E,$6DB7,$9F01,$81B6,$D8C1
		DW	$806D,$B6C3,$601B,$601B,$6DB6,$C301
		DW	$80E6,$CE71,$806C,$E39E,$3C0E,$601E
		DW	$38E7,$9E01,$C000,$0000,$0000,$0000
		DW	$0000,$0000,$0000,$0003,$7FFF,$FFFF
		DW	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
FIDO
		DS.B	1024-(FIDO-BOOTBLOCK)

		END
