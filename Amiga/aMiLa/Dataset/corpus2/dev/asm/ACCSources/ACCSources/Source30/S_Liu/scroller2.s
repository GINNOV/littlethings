	*********************************************************
	*	Basic Scroller 2 coded by Khul in Feb 1993	*
	*	Capital letters are only printed		*
	*	a-o sets speed from 1 (slow) to 15 (fast)	*
	*********************************************************

WIDTH		=	40
HEIGHT		=	200
PLANESIZE	=	WIDTH*HEIGHT
NO_PLANES	=	1

		opt c-

BlitWait	Macro
.bw\@	btst	#14,$dff002
	bne.s	.bw\@
		EndM

	section program,code_c
	include	"source:include/hardware.i"

	bsr.b	KillSys
	bsr.b	Initialize
	bsr.w	Main
	bsr.b	RestoreSys
	rts

*************************************************************************
* "Quick Trash" routine by Khul, Feb 93					*
*************************************************************************
KillSys:lea	$dff000,a5
	move.w	#$4000,intena(a5)	Disable all interrupts
	move.w	#$01a0,dmacon(a5)	Disable DMACON
	rts
RestoreSys:
	lea	$dff000,a5
	move.l	4,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080		Get system copper
	move.w	#$8020,$96(a5)		Activate
	moveq	#0,d0
	rts
*****************************************************************************
INITIALIZE:
	move.l	#screen,d0		Set copper plane addresses
	lea	planes,a0
	moveq	#NO_PLANES-1,d1		no.of bitplanes-1
set_planes:
	move.w	d0,6(a0)		get lower
	swap 	d0
	move.w	d0,2(a0)		get higher
	swap	d0			revert the screen ad to normal
	add.l	#PLANESIZE,D0		size of screen bitplane
	add.l	#8,a0
	dbra	D1,Set_planes

	lea	$dff000,a5		New Copperlist on
        move.l 	#new,$80(a5)
	move.l	#new+1,$84(a5)
	move.w 	$88(a5),d0
	move.w	#$87f0,$96(a5)

	move.l	$6c,oldirq
	move.l	#newirq,$6c
	move.w	#$c010,intena(a5)

	bsr.w	InitScroller
	rts
*****************************************************************************
newirq:	movem.l	d0-d7/a0-a6,-(a7)
	btst	#$0a,$dff016
	beq	out
	bsr	Scroller
out:	movem.l	(a7)+,d0-d7/a0-a6
	dc.w	$4ef9
oldirq:	dc.l	0
*****************************************************************************
Main:
loop:	move.l	$dff004,d0		VBlank routine
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#257,d0
	bne.s	loop
	
	btst	#6,$bfe001
	bne.s	loop
	rts
*****************************************************************************

		********************************
		* Basic scroll routine by Khul *
		* using BplCon1 to shift chars *
		********************************
InitScroller:
	move.l	#scrolltext,scrollpos
	rts
			
Scroller:move.w	ScrollSpeed,d0		d0=speed
	sub.w	d0,HSC
	bge	ScrEnd			If HSC=>0 then exit

	lea	ScrollArea,a0		--Shift scroll to left--
	lea	2(a0),a1
	BlitWait
	move.l	a1,$dff050		ptr A
	move.l	a0,$dff054		ptr D
	move.w	#2,$dff064		mod A
	move.w	#2,$dff066		mod D
	move.l	#-1,$dff044		mask
	move.w	#%0000100111110000,$dff040
	move.w	#0,$dff042
	move.w	#20+64*16,$dff058	BltSize

	moveq	#0,d0			--Get new character--
	move.l	scrollpos,a0		get current position
	move.b	(a0)+,d0		get letter of scrolltext
	cmp.b	#"a",d0			is it a command?
	bge	ScrCom			yes so branch to ScrCom
	cmp.b	#0,d0			end of text?
	bne.b	ScrNotNew		no, so branch to NotNew text
	move.l	#scrolltext,a0		yes, so reset scrollpos
	move.b	#32,d0			and print a space instead
	bra	ScrNotNew
ScrCom:	sub.b	#96,d0
	move.w	d0,ScrollSpeed		Set new speed
	move.l	a0,scrollpos		update scroll pos
	bra	ScrNo
ScrNotNew:
	move.l	a0,scrollpos		update scroll pos
	sub.b	#32,d0			--Get character offset--
	lsl.w	#5,d0			Get char offset
	lea	font16,a0
	lea	(a0,d0.w),a0		Get source address
	lea	scrollarea+40,a1	Get dest address

	BlitWait			--Print new character--
	move.l	a0,$dff050		ptr A
	move.l	a1,$dff054		ptr D
	move.w	#0,$dff064		mod A
	move.w	#40,$dff066		mod D
	move.l	#-1,$dff044		mask
	move.w	#%0000100111110000,$dff040
	move.w	#0,$dff042
	move.w	#1+64*16,$dff058	BltSize

ScrNo:	add.w	#16,HSC			Add 16 to counter to reset
ScrEnd:	rts

ScrollPos:	dc.l	0
ScrollSpeed:	dc.w	6
****************************************************************************

		*****************************************
		*		New Copper List		*
		*****************************************

cw = $fffe
new:	dc.w	dmacon,$20
	dc.w	bplcon0,$1200,bplcon1,$0000
	dc.w	bpl1mod,$0000,bpl2mod,$0000
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	diwstrt,$2c81,diwstop,$f4c1
planes:	dc.w	bpl1pth,0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0
	dc.w	bpl4pth,0,bpl4ptl,0
	dc.w	bpl5pth,0,bpl5ptl,0
spr_ptrs:
	dc.l	$01200000,$01220000		SPR0PTH/L
	dc.l	$01240000,$01260000		SPR1PTH/L
	dc.l	$01280000,$012a0000		SPR2PTH/L
	dc.l	$012c0000,$012e0000		SPR3PTH/L
	dc.l	$01300000,$01320000		SPR4PTH/L
	dc.l	$01340000,$01360000		SPR5PTH/L
	dc.l	$01380000,$013a0000		SPR6PTH/L
	dc.l	$013c0000,$013e0000		SPR7PTH/L
	dc.w	color17,$88d,color18,$568,color19,$335

	dc.w	color00,$0

	dc.w	Bpl1Mod,2
	dc.w	bplcon1
HSC:	dc.w	$f
	dc.w	color01,$fff
	dc.w	$2c0f,cw,color01,$f00
	dc.w	$2d0f,cw,color01,$f20
	dc.w	$2e0f,cw,color01,$f40
	dc.w	$2f0f,cw,color01,$f60
	dc.w	$300f,cw,color01,$f80
	dc.w	$310f,cw,color01,$fa0
	dc.w	$320f,cw,color01,$fc0
	dc.w	$330f,cw,color01,$fe0
	dc.w	$3c0f,cw
	dc.w	bplcon1,0
	dc.w	bpl1mod,0
NTSC:	dc.w	$ffe1,cw
	dc.w 	$ffff,cw
****************************************************************************
screen:
scrollarea:	ds.b	(PLANESIZE*NO_PLANES)+(2*16)
	even
****************************************************************************
			****** Font 16 ******
Font16:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;" "
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0300,$0300,$0300,$0300,$0300,$0300,$0300	;"!"
	dc.w	$0300,$0000,$0300,$0300,$0000,$0000,$0000,$0000
	dc.w	$0000,$1CE0,$1CE0,$1CE0,$18C0,$1080,$0000,$0000	;"""
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0660,$0660,$3FF8,$3FF8,$0CC0,$0CC0,$0CC0	;"#"
	dc.w	$7FF0,$7FF0,$1980,$1980,$0000,$0000,$0000,$0000
	dc.w	$0000,$0300,$0300,$0FE0,$1FE0,$1B00,$1FC0,$0FE0	;"$"
	dc.w	$0360,$1FE0,$1FC0,$0300,$0300,$0000,$0000,$0000
	dc.w	$0000,$3800,$7C60,$6CE0,$7DC0,$3B80,$0700,$0EE0	;"%"
	dc.w	$1DF0,$39B0,$31F0,$00E0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0E00,$1F00,$1B00,$1B00,$1F00,$1E00,$3F60	;"&"
	dc.w	$33E0,$31C0,$3FE0,$1F60,$0000,$0000,$0000,$0000
	dc.w	$0000,$0700,$0700,$0700,$0600,$0400,$0000,$0000	;"'"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0700,$0F00,$0C00,$1C00,$1800,$1800,$1800	;"("
	dc.w	$1C00,$0C00,$0F00,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0380,$03C0,$00C0,$00E0,$0060,$0060,$0060	;")"
	dc.w	$00E0,$00C0,$03C0,$0380,$0000,$0000,$0000,$0000
	dc.w	$0000,$0300,$0300,$3B70,$3FF0,$0FC0,$0FC0,$3FF0	;"*"
	dc.w	$3B70,$0300,$0300,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0300,$0300,$0300,$1FE0,$1FE0,$0300	;"+"
	dc.w	$0300,$0300,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;","
	dc.w	$0000,$0700,$0700,$0700,$0600,$0400,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$1FE0,$1FE0,$0000	;"-"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;"."
	dc.w	$0000,$0700,$0700,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0060,$00E0,$01C0,$0380,$0700,$0E00	;"/"
	dc.w	$1C00,$3800,$3000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FC0,$1FE0,$3870,$3030,$3030,$3030,$3030	;"0"
	dc.w	$3030,$3870,$1FE0,$0FC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0300,$0700,$0F00,$0F00,$0300,$0300,$0300	;"1"
	dc.w	$0300,$0300,$0300,$0300,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FC0,$1FE0,$3870,$3030,$0070,$0FE0,$1FC0	;"2"
	dc.w	$3800,$3000,$3FF0,$3FF0,$0000,$0000,$0000,$0000
	dc.w	$0000,$1F80,$3FC0,$30E0,$00E0,$03C0,$03C0,$00E0	;"3"
	dc.w	$0060,$30E0,$3FC0,$1F80,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01E0,$03E0,$0760,$0E60,$1C60,$3E70	;"4"
	dc.w	$3E70,$0060,$0060,$0060,$0000,$0000,$0000,$0000
	dc.w	$0000,$3FE0,$3FE0,$3000,$3000,$3F80,$3FC0,$00E0	;"5"
	dc.w	$0060,$30E0,$3FC0,$1F80,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FE0,$1FE0,$3800,$3000,$33C0,$33E0,$3070	;"6"
	dc.w	$3030,$3870,$1FE0,$0FC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$3FE0,$3FE0,$0060,$00E0,$01C0,$0380,$0700	;"7"
	dc.w	$0E00,$0C00,$0C00,$0C00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FC0,$1FE0,$3870,$3870,$1FE0,$1FE0,$3870	;"8"
	dc.w	$3030,$3870,$1FE0,$0FC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FC0,$1FE0,$3870,$3030,$3830,$1F30,$0F30	;"9"
	dc.w	$0030,$0070,$1FE0,$1FC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0700,$0700,$0700,$0000,$0000	;":"
	dc.w	$0700,$0700,$0700,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0700,$0700,$0700,$0000,$0000	;";"
	dc.w	$0700,$0700,$0700,$0600,$0400,$0000,$0000,$0000
	dc.w	$0000,$0070,$01F0,$07C0,$1F00,$7C00,$7000,$7C00	;"<"
	dc.w	$1F00,$07C0,$01F0,$0070,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$1FE0,$1FE0,$0000,$0000,$1FE0	;"="
	dc.w	$1FE0,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$7000,$7C00,$1F00,$07C0,$01F0,$0070,$01F0	;">"
	dc.w	$07C0,$1F00,$7C00,$7000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0F80,$1FC0,$38E0,$3060,$00E0,$03C0,$0780	;"?"
	dc.w	$0700,$0000,$0700,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$1FE0,$3FF0,$7038,$6798,$6FD8,$6CD8	;"@"
	dc.w	$6CD8,$6FF8,$67F0,$7000,$3FF8,$1FF8,$0000,$0000
	dc.w	$0000,$0FC0,$1FE0,$3870,$3030,$3030,$33F0,$33F0	;"A"
	dc.w	$3030,$3030,$3030,$3030,$0000,$0000,$0000,$0000
	dc.w	$0000,$3F80,$3FC0,$30E0,$30E0,$33C0,$33C0,$30E0	;"B"
	dc.w	$3060,$30E0,$3FC0,$3F80,$0000,$0000,$0000,$0000
	dc.w	$0000,$03F0,$0FF0,$1E00,$1800,$3800,$3000,$3800	;"C"
	dc.w	$1800,$1E00,$0FF0,$03F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$3F00,$3FC0,$31E0,$3060,$3070,$3030,$3070	;"D"
	dc.w	$3060,$31E0,$33C0,$3300,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FF0,$1FF0,$3800,$3000,$3F80,$3F80,$3000	;"E"
	dc.w	$3000,$3800,$1FF0,$0FF0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FF0,$1FF0,$3800,$3000,$3F80,$3F80,$3000	;"F"
	dc.w	$3000,$3000,$3000,$3000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0780,$1FE0,$3CE0,$3000,$7000,$61F0,$71F0	;"G"
	dc.w	$3030,$3CF0,$1FE0,$0780,$0000,$0000,$0000,$0000
	dc.w	$0000,$3060,$3060,$3060,$3060,$3FE0,$3FE0,$3060	;"H"
	dc.w	$3060,$3060,$3060,$3060,$0000,$0000,$0000,$0000
	dc.w	$0000,$0300,$0300,$0300,$0300,$0300,$0300,$0300	;"I"
	dc.w	$0300,$0300,$0300,$0300,$0000,$0000,$0000,$0000
	dc.w	$0000,$0060,$0060,$0060,$0060,$0060,$0060,$0060	;"J"
	dc.w	$3060,$38E0,$1FC0,$0F80,$0000,$0000,$0000,$0000
	dc.w	$0000,$1860,$1860,$1860,$18E0,$19C0,$1F80,$1F80	;"K"
	dc.w	$19C0,$18E0,$1860,$1860,$0000,$0000,$0000,$0000
	dc.w	$0000,$1800,$1800,$1800,$1800,$1800,$1800,$1800	;"L"
	dc.w	$1800,$1C00,$0FE0,$07E0,$0000,$0000,$0000,$0000
	dc.w	$0000,$7CE0,$7EF0,$6738,$6318,$6318,$6018,$6018	;"M"
	dc.w	$6018,$6018,$6018,$6018,$0000,$0000,$0000,$0000
	dc.w	$0000,$3060,$3060,$3860,$3C60,$3E60,$3760,$33E0	;"N"
	dc.w	$31E0,$30E0,$3060,$3060,$0000,$0000,$0000,$0000
	dc.w	$0000,$0780,$1FE0,$3CF0,$3030,$7038,$6018,$7038	;"O"
	dc.w	$3030,$3CF0,$1FE0,$0780,$0000,$0000,$0000,$0000
	dc.w	$0000,$3F80,$3FC0,$30E0,$3060,$30E0,$33C0,$3380	;"P"
	dc.w	$3000,$3000,$3000,$3000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0780,$1FE0,$3CF0,$3030,$7038,$6018,$70D8	;"Q"
	dc.w	$30F8,$3C70,$1FF8,$07D8,$0000,$0000,$0000,$0000
	dc.w	$0000,$3F80,$3FC0,$30E0,$3060,$30E0,$33C0,$3380	;"R"
	dc.w	$31C0,$30E0,$3060,$3060,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FF0,$1FF0,$3800,$3800,$1FC0,$0FE0,$0070	;"S"
	dc.w	$0030,$0070,$3FE0,$3FC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$3FF0,$3FF0,$0300,$0300,$0300,$0300,$0300	;"T"
	dc.w	$0300,$0300,$0300,$0300,$0000,$0000,$0000,$0000
	dc.w	$0000,$3030,$3030,$3030,$3030,$3030,$3030,$3030	;"U"
	dc.w	$3030,$3830,$1FF0,$0FF0,$0000,$0000,$0000,$0000
	dc.w	$0000,$31F0,$31F8,$3818,$1818,$1838,$1C70,$0CE0	;"V"
	dc.w	$0DC0,$0F80,$0700,$0600,$0000,$0000,$0000,$0000
	dc.w	$0000,$6018,$6018,$6018,$6018,$6018,$6318,$6318	;"W"
	dc.w	$6318,$7398,$3DF8,$1CF8,$0000,$0000,$0000,$0000
	dc.w	$0000,$3060,$3060,$38E0,$1DC0,$0F80,$0700,$0F80	;"X"
	dc.w	$1DC0,$38E0,$3060,$3060,$0000,$0000,$0000,$0000
	dc.w	$0000,$3030,$3030,$3870,$1CE0,$0FC0,$0780,$0300	;"Y"
	dc.w	$0300,$0300,$0300,$0300,$0000,$0000,$0000,$0000
	dc.w	$0000,$3FE0,$3FE0,$00E0,$01C0,$0380,$0700,$0E00	;"Z"
	dc.w	$1C00,$3800,$3FE0,$3FE0,$0000,$0000,$0000,$0000

****************************************************************************
scrolltext:
	dc.b	"hWELCOME TO THE BASIC SCROLLER 2!      "
	dc.b	"eCODED BY KHUL/INDY    "
	dc.b	"bTHIS SCROLL ROUTINE IS CAPABLE OF "
	dc.b	"gDIFFERENT SPEEDS LIKE ---- "
	dc.b	"aSLLOOOWWW    "
	dc.b	"gOR     "
	dc.b	"oFFFFFFAAAAAAAAAAASSSSSSSSSTTTTTTTTTTTTTTT!!!!!!!!!!!!   "
	dc.b	"fTHATS ALL        "
	dc.b	0
	even
