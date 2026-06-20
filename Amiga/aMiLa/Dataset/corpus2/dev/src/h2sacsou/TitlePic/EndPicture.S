ùúùúÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgRaster=0

Track=1		;0=ASM-One version
		;1=Track version

MyDmacon=%01111101111
;	  abcdefghhhh
; a = Blitter nasty
; b = Enable DMA activity (always set this!)
; c = Bitplane enable
; d = Copper enable
; e = Blitter enable
; f = Sprite enable
; g = Disk enable
; h = Audio channels enable

MyIntena=%100000000100000
;	  abcdeeeefghijkl
; a = Enable interrupts
; b = Lev. 6 External interrupt
; c = Lev. 5 Disk sync found
; d = Lev. 5 Serial port receive buffer full
; e = Lev. 4 Audio ch. 3-0 block finished
; f = Lev. 3 Blitter finished
; g = Lev. 3 Vertical blank
; h = Lev. 3 Copper
; i = Lev. 2 I/O Ports and timers
; j = Lev. 1 Software
; k = Lev. 1 Disk block finished
; l = Lev. 1 Serial port transmit buffer empty

		SECTION	Kode,code_c


		JumpPtr	Begin

*******************************************************************************
**Macros
*******************************************************************************
WaitBlt:	macro
.vent\@:	btst	#14,$dff002
		bne	.vent\@
		endm

*******************************************************************************
**Initialisering
*******************************************************************************
Begin:
		IF	Track=0
		move.w	Intenar+Base,OldIntena
		move.w	Dmacon+Base,OldDmacon
		move.w	#$7fff,Intena+Base
		move.w	#$7fff,Dmacon+Base
		move.w	#$7fff,Intreq+Base

		move.l	(Lev3Base).w,OldIrq3
		ELSE
		move.l	#Lev3Irq,(Lev1Base).w
		rts
		ENDC


		lea	Planer+2,a0
		move.l	#(Pic+64+0*40),d0
		moveq	#6-1,d1
.loop		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		swap	d0
		add.l	#40,d0
		addq.w	#8,a0
		dbra	d1,.loop


		IF	Track=0
		move.l	#Lev3Irq,(Lev3Base).w
		waitblt

		move.w	#MyDmacon+$8000,Dmacon+Base
		move.w	#MyIntena+$8000,Intena+Base

Wait:
		move.w	IWantOut(pc),d0
		beq.b	wait

*******************************************************************************
**Exit to AmigaDOS
*******************************************************************************
ExitToDos:
		move.w	#$7fff,Intena+Base
		move.w	#$7fff,Dmacon+Base
		ENDC
		rts

VBlank:		dc.w	0
		IF	Track=0
OldIntena:	dc.w	0
OldDmacon:	dc.w	0
OldIrq3:	dc.l	0
IWantOut:	dc.w	0
		ELSE
IWantOut:	EQU	$80
		ENDC
MegaPause:	dc.w	500

*******************************************************************************
**Level 3 interrupt
*******************************************************************************
Lev3Irq:
		movem.l	d0-a6,-(sp)
		move.l	#Copper,Cop2lch+Base
		move.w	d0,Copjmp2+Base
		move.w	#1,VBlank
*******************************************************************************
		bsr	Faders
		cmp.w	#3,Story
		bne.b	.NoLeft
*******************************************************************************
		move.w	#-1,IWantOut
.NoLeft:	if	Raster=1
		move.w	#$f00,Color00+Base
		endif
		waitblt
		if	Raster=1
		move.w	#$00f,Color00+Base
		endif
		movem.l	(sp)+,d0-a6
		IFEQ	Track-0
		move.w	#$0020,Intreq+Base
		ELSE
		move.w	#$0004,Intreq+Base
		ENDC
		rte


Faders:		move.w	Story(pc),d0
		beq	FadeUp
		subq.w	#1,d0
		beq	CountDown
		subq.w	#1,d0
		beq	FadeDn
		rts

CountDown:	subq.w	#1,MegaPause
		bne.b	.ud
		addq.w	#1,Story
.ud:		rts

*******************************************************************************
**FadeUpDn
*******************************************************************************
Story:		dc.w	0
FadeUp:
		lea	Colors+2,a0
		lea	Pic,a1
		moveq	#32-1,d7
		moveq	#0,d6
.loop:		move.w	(a0),d0
		move.w	(a1)+,d1
		bsr	fader
		move.w	d0,(a0)
		cmp.w	d0,d1
		bne	.notens
		addq.w	#1,d6
.notens:	addq.w	#4,a0
		dbra	d7,.loop
		cmp.w	#32,d6
		bne	.ud
		addq.w	#1,Story
.ud:		rts

FadeDn:
		lea	Colors+2,a0
		moveq	#32-1,d7
		moveq	#0,d6
.loop:		move.w	(a0),d0
		moveq	#0,d1
		bsr	fader
		move.w	d0,(a0)
		cmp.w	d0,d1
		bne	.notens
		addq.w	#1,d6
.notens:	addq.w	#4,a0
		dbra	d7,.loop
		cmp.w	#32,d6
		bne	.ud
		addq.w	#1,Story
.ud:		rts

**d0=fade from
**d1=fade to
**out: d0=newcol
fader:		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#8,d2
		lsr.w	#8,d3
		cmp.w	d2,d3
		beq	.nored
		blt	.redsub
		add.w	#$100,d0
		bra	.nored
.redsub:	sub.w	#$100,d0
.nored:		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#4,d2
		lsr.w	#4,d3
		and.w	#$f,d2
		and.w	#$f,d3
		cmp.w	d2,d3
		beq	.nogreen
		blt	.greensub
		add.w	#$10,d0
		bra	.nogreen
.greensub:	sub.w	#$10,d0
.nogreen:	move.w	d0,d2
		move.w	d1,d3
		and.w	#$f,d2
		and.w	#$f,d3
		cmp.w	d2,d3
		beq	.noblue
		blt	.bluesub
		addq.w	#$1,d0
		bra	.noblue
.bluesub:	subq.w	#$1,d0
.noblue:	rts

*******************************************************************************
**Copperlist
*******************************************************************************
Copper:
		dc.w	Spr0pth,$0000
		dc.w	Spr0ptl,$0000
		dc.w	Spr1pth,$0000
		dc.w	Spr1ptl,$0000
		dc.w	Spr2pth,$0000
		dc.w	Spr2ptl,$0000
		dc.w	Spr3pth,$0000
		dc.w	Spr3ptl,$0000
		dc.w	Spr4pth,$0000
		dc.w	Spr4ptl,$0000
		dc.w	Spr5pth,$0000
		dc.w	Spr5ptl,$0000
		dc.w	Spr6pth,$0000
		dc.w	Spr6ptl,$0000
		dc.w	Spr7pth,$0000
		dc.w	Spr7ptl,$0000

		dc.w	Diwstrt,$4081
		dc.w	Diwstop,$08c1
		dc.w	Ddfstrt,$0038
		dc.w	Ddfstop,$00d0

		dc.w	$106,$0c40

Colors:	dc.w	$0180,$000,$0182,$000,$0184,$000,$0186,$000
	dc.w	$0188,$000,$018a,$000,$018c,$000,$018e,$000
	dc.w	$0190,$000,$0192,$000,$0194,$000,$0196,$000
	dc.w	$0198,$000,$019a,$000,$019c,$000,$019e,$000
	dc.w	$01a0,$000,$01a2,$000,$01a4,$000,$01a6,$000
	dc.w	$01a8,$000,$01aa,$000,$01ac,$000,$01ae,$000
	dc.w	$01b0,$000,$01b2,$000,$01b4,$000,$01b6,$000
	dc.w	$01b8,$000,$01ba,$000,$01bc,$000,$01be,$000

		dc.w	$1001,$fffe
Planer:		dc.w	Bpl1pth,0	;(Pic+32+0*40)>>16
		dc.w	Bpl1ptl,0	;(Pic+32+0*40)&$ffff
		dc.w	Bpl2pth,0	;(Pic+32+1*40)>>16
		dc.w	Bpl2ptl,0	;(Pic+32+1*40)&$ffff
		dc.w	Bpl3pth,0	;(Pic+32+2*40)>>16
		dc.w	Bpl3ptl,0	;(Pic+32+2*40)&$ffff
		dc.w	Bpl4pth,0	;(Pic+32+3*40)>>16
		dc.w	Bpl4ptl,0	;(Pic+32+3*40)&$ffff
		dc.w	Bpl5pth,0	;(Pic+32+3*40)>>16
		dc.w	Bpl5ptl,0	;(Pic+32+3*40)&$ffff
		dc.w	Bpl6pth,0	;(Pic+32+3*40)>>16
		dc.w	Bpl6ptl,0	;(Pic+32+3*40)&$ffff

		dc.w	Bpl1mod,5*40
		dc.w	Bpl2mod,5*40

		dc.w	Bplcon0,$6200
		dc.w	Bplcon1,$0000
		dc.w	Bplcon2,$0024

		dc.w	$ffff,$fffe

*******************************************************************************
**Screens+Gfx
*******************************************************************************
		INCDIR	"Work:Code/Sources/HTSAC/TitlePic/"
Pic:		INCBIN	"IHATECAT.raw320*200*6+cmap"

TheEnd:

*******************************************************************************
**Hardware registers
*******************************************************************************
Bltddat=$000
Dmaconr=$002
Vposr=$004
Vhposr=$006
Dskdatr=$008
Joy0dat=$00a
Joy1dat=$00c
Clxdat=$00e
Adkconr=$010
Pot0dat=$012
Pot1dat=$014
Potgor=$016
Serdatr=$018
Dskbytr=$01a
Intenar=$01c
Intreqr=$01e
Dskpth=$020
Dskptl=$022
Dsklen=$024
Dskdat=$026
Refptr=$028
Vposw=$02a
Vhposw=$02c
Copcon=$02e
Serdat=$030
Serper=$032
Potgo=$034
Joytest=$036
Strequ=$038
Strvbl=$03a
Strhor=$03c
Strlong=$03e
Bltcon0=$040
Bltcon1=$042
Bltafwm=$044
Bltalwm=$046
Bltcpth=$048
Bltcptl=$04a
Bltbpth=$04c
Bltbptl=$04e
Bltapth=$050
Bltaptl=$052
Bltdpth=$054
Bltdptl=$056
Bltsize=$058
Bltcmod=$060
Bltbmod=$062
Bltamod=$064
Bltdmod=$066
Bltcdat=$070
Bltbdat=$072
Bltadat=$074
Dsksync=$07e
Cop1lch=$080
Cop1lcl=$082
Cop2lch=$084
Cop2lcl=$086
Copjmp1=$088
Copjmp2=$08a
Copins=$08c
Diwstrt=$08e
Diwstop=$090
Ddfstrt=$092
Ddfstop=$094
Dmacon=$096
Clxcon=$98
Intena=$09a
Intreq=$09c
Adkcon=$09e
Aud0dat=$0aa
Aud1dat=$0ba
Aud2dat=$0ca
Aud3dat=$0da
Aud0lch=$0a0
Aud1lch=$0b0
Aud2lch=$0c0
Aud3lch=$0d0
Aud0len=$0a4
Aud1len=$0b4
Aud2len=$0c4
Aud3len=$0d4
Aud0per=$0a6
Aud1per=$0b6
Aud2per=$0c6
Aud3per=$0d6
Aud0vol=$0a8
Aud1vol=$0b8
Aud2vol=$0c8
Aud3vol=$0d8
Aud0lcl=$0a2
Aud1lcl=$0b2
Aud2lcl=$0c2
Aud3lcl=$0d2
Bpl1pth=$0e0
Bpl1ptl=$0e2
Bpl2pth=$0e4
Bpl2ptl=$0e6
Bpl3pth=$0e8
Bpl3ptl=$0ea
Bpl4pth=$0ec
Bpl4ptl=$0ee
Bpl5pth=$0f0
Bpl5ptl=$0f2
Bpl6pth=$0f4
Bpl6ptl=$0f6
Bplcon0=$100
Bplcon1=$102
Bplcon2=$104
Bpl1mod=$108
Bpl2mod=$10a
Bpl1dat=$110
Bpl2dat=$112
Bpl3dat=$114
Bpl4dat=$116
Bpl5dat=$118
Bpl6dat=$11a
Spr0pth=$120
Spr0ptl=$122
Spr1pth=$124
Spr1ptl=$126
Spr2pth=$128
Spr2ptl=$12a
Spr3pth=$12c
Spr3ptl=$12e
Spr4pth=$130
Spr4ptl=$132
Spr5pth=$134
Spr5ptl=$136
Spr6pth=$138
Spr6ptl=$13a
Spr7pth=$13c
Spr7ptl=$13e
Spr0pos=$140
Spr0ctl=$142
Spr0data=$144
Spr0datb=$146
Spr1pos=$148
Spr1ctl=$14a
Spr1data=$14c
Spr1datb=$14e
Spr2pos=$150
Spr2ctl=$152
Spr2data=$154
Spr2datb=$156
Spr3pos=$158
Spr3ctl=$15a
Spr3data=$15c
Spr3datb=$15e
Spr4pos=$160
Spr4ctl=$162
Spr4data=$164
Spr4datb=$166
Spr5pos=$168
Spr5ctl=$16a
Spr5data=$16c
Spr5datb=$16e
Spr6pos=$170
Spr6ctl=$172
Spr6data=$174
Spr6datb=$176
Spr7pos=$178
Spr7ctl=$17a
Spr7data=$17c
Spr7datb=$17e
Color00=$180
Color01=$182
Color02=$184
Color03=$186
Color04=$188
Color05=$18a
Color06=$18c
Color07=$18e
Color08=$190
Color09=$192
Color10=$194
Color11=$196
Color12=$198
Color13=$19a
Color14=$19c
Color15=$19e
Color16=$1a0
Color17=$1a2
Color18=$1a4
Color19=$1a6
Color20=$1a8
Color21=$1aa
Color22=$1ac
Color23=$1ae
Color24=$1b0
Color25=$1b2
Color26=$1b4
Color27=$1b6
Color28=$1b8
Color29=$1ba
Color30=$1bc
Color31=$1be
Base=$dff000

*******************************************************************************
**Interrupt addresses
*******************************************************************************
Lev1Base=$64
Lev2Base=$68
Lev3Base=$6c
Lev4Base=$70
Lev5Base=$74
Lev6Base=$78
Lev7Base=$7c

