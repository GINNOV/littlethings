***************************************************************************
*** 3D Star Routine 			      (c) 1990 by McDeal/D-TECT ***
*** This is a (Master-) Devpac source!					***
***************************************************************************

;		opt	o+

*** Use joystick to control the stars !!! ***

* The control of the stars is lame, I know! I had a better version but the
* source would have been bigger so I decide to use this version. (The other
* included a x,y,z rotation with matrix calculation, etc.)
* Don't forget to press the firebottom!!!

PlaneHeight	= 255
PlaneWidth	= 40
PlaneLen	= PlaneHeight*PlaneWidth
PL		= PlaneLen
PlaneBLTSIZE	= 3*PlaneHeight*64+(PlaneWidth/2)

MaxTiefe	= $2000
StarCount	= 335
X		= 160
Y		= 128
Z		= 256
ClipX		= 319
ClipY		= 254
JoySpeed	= 5

***************************************************
*** MACRO-Definition				***
***************************************************

WAITBLITT:	MACRO
		btst	#6,$02(a6)
.\@:		btst	#6,$02(a6)
		bne.s	.\@
		ENDM

***************************************************
*** ProgrammStart				***
***************************************************

		section	a,code_c

Start:		lea	$dff000,a6
		move.w	#$4000,$9a(a6)

		bsr	RandomStars
		bsr.s	CalcTab
		bsr.s	MakePerspTab
		bsr.s	StartCopper
		bsr	Main
		bsr.s	StopCopper

		move.w	#$c000,$9a(a6)
		moveq	#0,d0
		rts

***************************************************
*** Copper Init					***
***************************************************

StartCopper:	move.w	#$0780,$96(a6)
		move.l	#NCList,$84(a6)
		move.w	d0,$8a(a6)
		move.w	#0,$1fc(a6)	; reset AGA
		move.w	#$8380,$96(a6)
		rts

StopCopper:	move.w	#$0380,$96(a6)
		clr.w	$88(a6)
		move.w	#$8380,$96(a6)
		rts

***************************************************
*** Build Y Table				***
***************************************************

CalcTab:	lea	YTab(pc),a0
		moveq	#0,d0
		move.w	#PlaneHeight-1,d7
.Loop:		move.w	d0,(a0)+
		add.w	#PlaneWidth,d0
		dbra	d7,.Loop
		rts

***************************************************
*** Build Division Table			***
***************************************************

MakePerspTab:	lea	PerspTab,a1
		move.w	#Z,d0
		add.w	d0,a1
		add.w	d0,a1
		move.w	#Z,d2
		mulu	#$7fff,d2
.Loop:		move.l	d2,d1
		divu	d0,d1
		move.w	d1,(a1)+
		addq.w	#1,d0
		cmp.w	#MaxTiefe,d0
		bne.s	.Loop
		rts

***************************************************
*** Random Stars				***
***************************************************

RandomStars:	lea	StarDatas,a0
		move.w	#$1fff,d3
		move.w	#StarCount-1,d7

.Loop:		bsr.s	GetWord			;X Word
		add.w	#X,d2
		and.w	d3,d2
		sub.w	#X,d2
		move.w	d2,(a0)+
		bsr.s	GetWord			;Y Word
		add.w	#Y,d2
		and.w	d3,d2
		sub.w	#Y,d2
		move.w	d2,(a0)+
		bsr.s	GetWord			;Z Word
		add.w	#Z,d2
		and.w	d3,d2
		sub.w	#Z,d2
		move.w	d2,(a0)+
		dbf	d7,.Loop
		rts

GetWord:	bsr.s	GetByte
		move.b	d0,d2
		lsl.w	#8,d2
		bsr.s	GetByte
		move.b	d0,d2
		rts

GetByte:	move.b	$dff007,d0
		move.b	$bfd800,d1
		eor.b	d1,d0
		moveq	#0,d1
		move.b	d0,d1
		ror.b	#1,d1
.loop:		dbf	d1,.loop
		rts

***************************************************
*** Main Loop					***
***************************************************

Main:		btst	#10,$16(a6)
		beq.s	Main
		move.l	$04(a6),d0
		and.l	#$1ff00,d0
		cmp.l	#300*256,d0
		bne.s	Main

		bsr	ClearPlane
		bsr	JoyControl
		bsr.s	New3DStars
		lea	$dff000,a6
		bsr	ChangePlanes

;		move.w	#$444,$180(a6)
;		moveq	#20,d7
;.Loop:		dbra	d7,.Loop
;		move.w	#$000,$180(a6)

		btst	#6,$bfe001
		bne.s	Main
		WAITBLITT
		rts

***************************************************
*** 3D Star Routine				***
***************************************************

New3DStars:	move.w	#StarCount-1,d7		;64 Stars
		lea	StarDatas,a0		;Ptr StarDatas
		lea	PerspTab,a1		;Projection Table
		movem.w	XAdd(pc),a4-a6		;Put coordinate adds in regs
		move.w	#ClipX,a3		;Clipping constante
		move.w	#ClipY,d5
		move.w	#$1fff,d3
		move.w	#$1000,d4		;middle value
		add.w	d4,a4			;+x add
		add.w	d4,a5			;+y add

.Loop:		movem.w	(a0),d0-d2		;Get coordinate

		add.w	a4,d0			;add middle and de/increase x
		and.w	d3,d0			;check overflow
		sub.w	d4,d0			;sub middle
		add.w	a5,d1			;add middle and de/increase y
		and.w	d3,d1			;check overflow
		sub.w	d4,d1			;sub middle
		add.w	a6,d2			;de/increase z
		and.w	d3,d2			;check overflow

		movem.w	d0-d2,(a0)		;save coords
		addq.w	#6,a0			;(there is no movem.w d0,(a0)+)

; >--- Projection, vlipping und plot
;/

.SetStar:	cmp.w	#Z,d2			;z<d2?
		blt.s	.Next			;-> Next star
		add.w	d2,d2			;Z*2
		move.w	(a1,d2.w),d6		;Projektionswert holen

;It's very important to do the following commands in this order. It's very
;stupid of you do it like this:
;			muls	d6,d0
;			muls	d6,d1
;			swap	d0
;			swap	d1
;			etc...
;Ok, the source looks better but there is one BIG disadvantage!!! If e.g.
;the x value isn't in the screen you don't have the plot this pixel. But
;if the pixel musn't be plot it is really stupid to check/calculate the
;y value!!! Understood??? The following routine is much better! It first
;checks if the x value is within the screen. If it is, the y value will be
;calculated. If not, the y value won't be calculated (We can't save the
;unneccessary 'muls d6,d1' in this case!!!

		muls	d6,d0			;projection
		swap	d0			;
		add.w	#X,d0			;X middle of screen (160)
		cmp.w	a3,d0			;a3=ClipX (Clipping)
		bhi.s	.Next			;Don't plot

		muls	d6,d1			;projection
		swap	d1
		add.w	#Y,d1			;Y middle of screen (128)
		cmp.w	d5,d1			;a4=ClipY
		bhi.s	.Next			;Don't plot

		move.l	WorkPlane(pc),a2	;plot pixel
		move.w	d0,d6
		lsr.w	#3,d6
		add.w	d6,a2
		add.w	d1,d1
		add.w	YTab(pc,d1.w),a2
		not.w	d0

		rol.w	#6,d2			;get color
		and.w	#$e,d2
		move.w	.JT(pc,d2.w),d2
		jmp	.JT(pc,d2.w)

.JT:		dc.w	.r6-.JT,.r6-.JT,.r5-.JT,.r4-.JT
		dc.w	.r3-.JT,.r2-.JT,.r1-.JT,.r0-.JT

.r0:		bset	d0,(a2)			;plot routines...
.next:		dbf	d7,.Loop
		rts
.r1:		bset	d0,PL(a2)
		dbf	d7,.Loop
		rts
.r2:		bset	d0,(a2)
		bset	d0,PL(a2)
		dbf	d7,.Loop
		rts
.r3:		bset	d0,PL*2(a2)
		dbf	d7,.Loop
		rts
.r4:		bset	d0,(a2)
		bset	d0,PL*2(a2)
		dbf	d7,.Loop
		rts
.r5:		bset	d0,PL(a2)
		bset	d0,PL*2(a2)
		dbf	d7,.Loop
		rts
.r6:		bset	d0,(a2)
		bset	d0,PL(a2)
		bset	d0,PL*2(a2)
		dbf	d7,.Loop
		rts

XAdd:		dc.w	0
YAdd:		dc.w	0
ZAdd:		dc.w	-100

YTab:		ds.w	PlaneHeight

***************************************************
*** Joystick Control				***
***************************************************

JoyControl:	lea	XAdd(pc),a0
		lea	ZAdd(pc),a1
		tst.b	$bfe001			;Y or Z?
		bpl.s	.Pressed		;Z-> Pressed

		lea	YAdd(pc),a1		;otherwise Y

.Pressed:	move.w	$0c(a6),d0
		btst	#1,d0
		beq.s	.TstLinks
		subq.w	#JoySpeed,(a0)
		bra.s	.DoY
.TstLinks:	btst	#9,d0
		beq.s	.DoY
		addq.w	#JoySpeed,(a0)

.DoY:		move.w	d0,d1
		lsr.w	#1,d1
		eor.w	d0,d1
		btst	#0,d1
		beq.s	.TstVorne
		addq.w	#JoySpeed,(a1)
		bra.s	.Exit
.TstVorne:	btst	#8,d1
		beq.s	.Exit
		subq.w	#JoySpeed,(a1)
.Exit:		rts

***************************************************
*** clear DelPlane				***
***************************************************

ClearPlane:	WAITBLITT

		move.l	DelPlane(pc),$54(a6)
		clr.w	$66(a6)
		move.l	#$01000000,$40(a6)
		move.w	#PlaneBLTSIZE,$58(a6)
		rts

***************************************************
*** Tripple Buffering				***
***************************************************

ChangePlanes:	lea	Plane(pc),a0
		movem.l	(a0),d0-d2
		exg	d0,d1
		exg	d1,d2
		movem.l	d0-d2,(a0)
		lea	PlanePtrs(pc),a0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		add.l	#PlaneLen,d0
		move.w	d0,6+8(a0)
		swap	d0
		move.w	d0,2+8(a0)
		swap	d0
		add.l	#PlaneLen,d0
		move.w	d0,6+16(a0)
		swap	d0
		move.w	d0,2+16(a0)
		swap	d0
		rts

Plane:		dc.l	Plane1
WorkPlane:	dc.l	Plane2
DelPlane:	dc.l	Plane3

***************************************************
*** Datas					***
***************************************************

* Try Germany/0+$4498a7c!!! (Ask for Karsten!)

NCList:		dc.l	$01200000,$01220000,$01240000,$01260000
		dc.l	$01280000,$012a0000,$012c0000,$012e0000
		dc.l	$01300000,$01320000,$01340000,$01360000
		dc.l	$01380000,$013a0000,$013c0000,$013e0000

		dc.l	$008e2c81,$00902bc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
		dc.l	$01000200

PlanePtrs:	dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$01003200

		dc.l	$01800000,$01820333,$01840555,$01860777
		dc.l	$01880999,$018a0bbb,$018c0ddd,$018e0fff
		dc.l	-2

***************************************************
*** BSS Data segment				***
***************************************************

		section	b,bss_c

Plane1:		ds.b	PlaneLen*3
Plane2:		ds.b	PlaneLen*3
Plane3:		ds.b	PlaneLen*3
PerspTab:	ds.w	MaxTiefe
StarDatas:	ds.w	StarCount*3

