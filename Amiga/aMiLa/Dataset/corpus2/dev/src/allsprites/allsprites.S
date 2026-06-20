;******************************************************************************
;*
;* Author: Fabio "Maverick" Bizzetti
;*
;*   Note: Use this source (and/or its know-how) as you wish, it's completely
;*         freeware. It allows you to not lose the sprites in case you enable
;*         hscroll or overscan.
;*         This source can already be assembled and executed.
;*

TEST:	JSR	View_Null
	MOVE.L	#1,Y_mode	;origin: 0=lower/left  1=upper/left
	MOVE.L	#ScreenA,screen_showed
	JSR	OpenScreen	;this is the routine that will set up the HW to
				;display a 320*256 normal PAL screen, but with
				;a DDFSTRT value of $58. This means that if you
				;use a lower value (for overscan/h_scroll) you
				;dont lose the sprites, because you need to set
				;it to $38. The trick is that it reprograms the
				;video DMA to the right.
				;It should work on every TV, but I didn't have
				;time to test/eventually_fix it.
	JSR	Wait_LMouse
	JSR	View_System
	RTS

*******************************************************************************
OpenScreen:
	MOVE.W	#$0FFF,copper_color_hi_256+10	;just to show something
	move.b	#%10111111,ScreenA_bpl0
	move.b	#%11111101,ScreenA_bpl0+(320/8)-1
	move.b	#%10001111,ScreenA_bpl0+10200
	move.b	#%11110001,ScreenA_bpl0+(320/8)+10199

	JSR	SetBplPt
	JSR	SetSync
	RTS

screen_showed	DC.L	0
Y_mode		DC.L	0

***************************************
SetSync:
	bsr.w	WaitVBL
	lea	$dff000,a0
	move.w	#$03A0,$096(a0)		;DMACON - disable bpl/cop/spr
	lea	copper_bpl_regs+2,a2
	lea	copper_spr_res+2,a3

	move.w	#$2AA1,$08E(a0)		;DIWSTRT       <--vcentering
	move.w	#$2AE1,$090(a0)		;DIWSTOP       <--vcentering
	move.w	#$0031,$1DE(a0)		;HSSTRT        <--hcentering

	move.w	#$0211,8(a2)		;BPLCON0
	move.w	#$0058,$092(a0)		;DDFSTRT
	move.w	#$00D8,$094(a0)		;DDFSTOP
	move.w	#$000F,$1FC(a0)		;FMODE
	move.w	#$001E,$1C4(a0)		;HBSTRT
	move.w	#$0034,$1C2(a0)		;HSSTOP
	move.w	#$0035,$1C6(a0)		;HBSTOP
	move.w	#$00E2,$1C0(a0)		;HTOTAL
	move.w	#$0000,$1CC(a0)		;VBSTRT
	move.w	#$0003,$1E0(a0)		;VSSTRT
	move.w	#$0005,$1CA(a0)		;VSSTOP
	move.w	#$001D,$1CE(a0)		;VBSTOP
	move.w	#$0138,$1C8(a0)		;VTOTAL
	move.w	#$0B88,$1DC(a0)		;BEAMCON0
	move.w	#$0000,$102(a0)		;BPLCON1
	move.w	#$027F,$104(a0)		;BPLCON2
	move.w	#$0063,(a3)		;BPLCON3	;spr res
	move.w	#$0011,$10C(a0)		;BPLCON4
	jsr	SetModRegs
	move.l	#copper,$080(a0)
	move.w	#$8380,$096(a0)		;DMACON - enable mast/bpl/cop/(spr)
	move.w	#$0000,$088(a0)
	RTS

;**************************************
;*

SetBplPt:
	MOVEM.L	D0/D1/A0,-(SP)
	move.l	screen_showed,d0
	tst.l	Y_mode
	bne.b	.y1
	add.l	#(320*255)/8,d0
.y1	move.l	#(320*256)/8,d1
	lea	copper_bpl_pt,a0
	move.w	d0,$06(a0)
	swap	d0
	move.w	d0,$02(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$0E(a0)
	swap	d0
	move.w	d0,$0A(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$16(a0)
	swap	d0
	move.w	d0,$12(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$1E(a0)
	swap	d0
	move.w	d0,$1A(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$26(a0)
	swap	d0
	move.w	d0,$22(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$2E(a0)
	swap	d0
	move.w	d0,$2A(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$36(a0)
	swap	d0
	move.w	d0,$32(a0)
	swap	d0
	add.l	d1,d0
	move.w	d0,$3E(a0)
	swap	d0
	move.w	d0,$3A(a0)
	MOVEM.L	(SP)+,D0/D1/A0
	rts
;*
;**************************************
;*
;* used by SetYmode and SetSynch
;*

SetModRegs:
	movem.l	d0/a0,-(sp)
	lea	copper_bpl_regs+2,a0
	tst.l	Y_mode
	bne.b	.singley1
	move.w	#-80,0(a0)		;BPL1MOD
	move.w	#-80,4(a0)		;BPL2MOD
	bra.b	.singleye
.singley1
	move.w	#0,0(a0)		;BPL1MOD
	move.w	#0,4(a0)		;BPL2MOD
.singleye
	movem.l	(sp)+,d0/a0
	rts
;*
;**************************************
;*
;*

WaitVBL:
	move.l	d0,-(sp)
	move.b	$BFE801,D0
.wait	cmp.b	$BFE801,D0
	beq.b	.wait
	move.l	(sp)+,d0
	rts

;*
*******************************************************************************
View_Null:
	MOVE.L	4.w,A6
	JSR	-132(A6)	;Forbid
	JSR	-120(A6)	;Disable
	MOVEQ	#0,D0
	LEA	.Gfx_NAME(pc),A1
	JSR	-552(A6)	;EXEC OpenLibrary
	LEA	Gfx_PT(pc),A0
	MOVE.L	D0,(A0)
	MOVE.L	D0,A6
	MOVE.L	$22(A6),system_view
	MOVE.L	$26(A6),system_copper
	SUB.L	A1,A1
	JSR	-222(A6)	;GRAPHICS LoadView (null)
	JSR	-270(A6)	;GRAPHICS WaitTOF
	JSR	-270(A6)	;GRAPHICS WaitTOF
	LEA	$DFF000,A6
	MOVE.W	2(A6),old_dmacon
	MOVE.W	$1C(A6),old_intena
	MOVE.W	$1E(A6),old_intreq
	MOVE.W	#$8000,D0
	OR.W	D0,old_dmacon
	OR.W	D0,old_intena
	OR.W	D0,old_intreq
	MOVE.W	#$0020,$96(A6)
	LEA	$140(A6),A0
	MOVEQ	#16-1,D0
.c	CLR.L	(A0)+
	DBRA	D0,.c
	RTS

.Gfx_NAME	DC.B	"graphics.library",0
		CNOP	0,4
Gfx_PT		DS.L	1
system_view	DS.L	1
system_copper	DS.L	1
system_int3	DS.L	1
old_dmacon	DS.W	1
old_intena	DS.W	1
old_intreq	DS.W	1
*******************************************************************************
View_System:
	LEA	$DFF000,A6
	MOVE.W	#$7FFF,$96(A6)
	MOVE.W	old_dmacon(PC),$96(A6)
	MOVE.W	#$7FFF,$9C(A6)
	MOVE.W	old_intreq(PC),$9C(A6)
	MOVE.W	#$7FFF,$9A(A6)
	MOVE.W	old_intena(PC),$9A(A6)
	MOVE.L	Gfx_PT(pc),A6
	MOVE.L	system_copper(pc),$DFF080
	MOVE.W	#$8020,$DFF096
	MOVE.L	system_view(pc),A1
	JSR	-222(A6)	;GRAPHICS LoadView (fix OLD view)
	MOVE.L	A6,A1
	MOVE.L	4.W,A6
	JSR	-414(A6)	;EXEC CloseLibrary
	JSR	-126(A6)	;Enable
	JSR	-138(A6)	;Permit
	RTS
*******************************************************************************
Wait_LMouse:
	BTST.B	#6,$BFE001
	BNE.B	Wait_LMouse
	RTS
*******************************************************************************

		section	chipramscreen,data_c
ScreenA
ScreenA_bpl0	ds.b	(320*256)/8
ScreenA_bpl1	ds.b	(320*256)/8
ScreenA_bpl2	ds.b	(320*256)/8
ScreenA_bpl3	ds.b	(320*256)/8
ScreenA_bpl4	ds.b	(320*256)/8
ScreenA_bpl5	ds.b	(320*256)/8
ScreenA_bpl6	ds.b	(320*256)/8
ScreenA_bpl7	ds.b	(320*256)/8
;******************************************************************************
		section	copperlist,data_c
copper:

copper_bpl_regs:
	DC.L	$01080000	;BPL1MOD
	DC.L	$010A0000	;BPL2MOD
	DC.L	$01000211	;BPLCON0

copper_bpl_pt:
	DC.L	$00E00000	;BPL1PTH
	DC.L	$00E20000	;BPL1PTL
	DC.L	$00E40000	;BPL2PTH
	DC.L	$00E60000	;BPL2PTL
	DC.L	$00E80000	;BPL3PTH
	DC.L	$00EA0000	;BPL3PTL
	DC.L	$00EC0000	;BPL4PTH
	DC.L	$00EE0000	;BPL4PTL
	DC.L	$00F00000	;BPL5PTH
	DC.L	$00F20000	;BPL5PTL
	DC.L	$00F40000	;BPL6PTH
	DC.L	$00F60000	;BPL6PTL
	DC.L	$00F80000	;BPL7PTH
	DC.L	$00FA0000	;BPL7PTL
	DC.L	$00FC0000	;BPL8PTH
	DC.L	$00FE0000	;BPL8PTL

copper_spr_pt:
	DC.L	$01200000	;SPR0PTH
	DC.L	$01220000	;SPR0PTL
	DC.L	$01240000	;SPR1PTH
	DC.L	$01260000	;SPR1PTL
	DC.L	$01280000	;SPR2PTH
	DC.L	$012A0000	;SPR2PTL
	DC.L	$012C0000	;SPR3PTH
	DC.L	$012E0000	;SPR3PTL
	DC.L	$01300000	;SPR4PTH
	DC.L	$01320000	;SPR4PTL
	DC.L	$01340000	;SPR5PTH
	DC.L	$01360000	;SPR5PTL
	DC.L	$01380000	;SPR6PTH
	DC.L	$013A0000	;SPR6PTL
	DC.L	$013C0000	;SPR7PTH
	DC.L	$013E0000	;SPR7PTL

col32	MACRO
	DC.L	$01800000
	DC.L	$01820000
	DC.L	$01840000
	DC.L	$01860000
	DC.L	$01880000
	DC.L	$018A0000
	DC.L	$018C0000
	DC.L	$018E0000
	DC.L	$01900000
	DC.L	$01920000
	DC.L	$01940000
	DC.L	$01960000
	DC.L	$01980000
	DC.L	$019A0000
	DC.L	$019C0000
	DC.L	$019E0000
	DC.L	$01A00000
	DC.L	$01A20000
	DC.L	$01A40000
	DC.L	$01A60000
	DC.L	$01A80000
	DC.L	$01AA0000
	DC.L	$01AC0000
	DC.L	$01AE0000
	DC.L	$01B00000
	DC.L	$01B20000
	DC.L	$01B40000
	DC.L	$01B60000
	DC.L	$01B80000
	DC.L	$01BA0000
	DC.L	$01BC0000
	DC.L	$01BE0000
	ENDM

copper_color_hi_256:
	DC.L	$01060063	;BANK=0 LOCT=0
	col32
	DC.L	$01062063	;BANK=1 LOCT=0
	col32
	DC.L	$01064063	;BANK=2 LOCT=0
	col32
	DC.L	$01066063	;BANK=3 LOCT=0
	col32
	DC.L	$01068063	;BANK=4 LOCT=0
	col32
	DC.L	$0106A063	;BANK=5 LOCT=0
	col32
	DC.L	$0106C063	;BANK=6 LOCT=0
	col32
	DC.L	$0106E063	;BANK=7 LOCT=0
	col32
copper_color_lo_256:
	DC.L	$01060263	;BANK=0 LOCT=1
	col32
	DC.L	$01062263	;BANK=1 LOCT=1
	col32
	DC.L	$01064263	;BANK=2 LOCT=1
	col32
	DC.L	$01066263	;BANK=3 LOCT=1
	col32
	DC.L	$01068263	;BANK=4 LOCT=1
	col32
	DC.L	$0106A263	;BANK=5 LOCT=1
	col32
	DC.L	$0106C263	;BANK=6 LOCT=1
	col32
	DC.L	$0106E263	;BANK=7 LOCT=1
	col32

copper_spr_res:
	DC.L	$01060063	;$0063=140ns  $00A3=70ns

	DC.L	$FFFFFFFE	;End of CopperList
;******************************************************************************

