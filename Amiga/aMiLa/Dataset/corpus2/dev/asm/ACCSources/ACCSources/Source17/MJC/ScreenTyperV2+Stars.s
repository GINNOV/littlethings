
*	Screen Typer V2.0.  Coded by Mike Cross,  September 1991

*	This source is totally PD.  Use and abuse as you see fit.


		opt	C-,O-,D+,M+
		
		incdir	sys:include/			
		include	exec/exec_lib.i		
		include	exec/execbase.i
		include	exec/memory.i
		include	hardware/custom.i
		include	hardware/intbits.i
		include	hardware/dmabits.i
		include	graphics/graphics_lib.i
		include	graphics/gfxbase.i
		

ScreenWidth	equ	40
ScreenHeight	equ	256
PlaneSize	equ	ScreenWidth*ScreenHeight

NumberOfPlanes	equ	2

NumberOfStars	equ	26
Max_Speed	equ	4

Ciaapra		equ	$bfe001
Custom		equ	$dff000
VERSION_NUMBER	equ	33			* 34 for V1.3 Amiga's

CALLSYS		MACRO				* Now A6 is not corrupt
		move.l	a6,-(sp)		* when a library call
		movea.l	(_SysBase).w,a6		* is used
		jsr	_LVO\1(a6)
		move.l	(sp)+,a6
		ENDM

 
		Section	Main,Code
		
		movem.l  a0-a6/d0-d7,-(sp)

		lea	Variables,a6		* A6 - Always variables

		lea     GraphicsName(pc),a1
		moveq.l	#VERSION_NUMBER,d0
		CALLSYS	OpenLibrary   
		beq	Exit
		move.l	d0,a1
		move.l	gb_copinit(a1),SystemCopper(a6)	
		CALLSYS	CloseLibrary
		
		move.l	#PlaneSize*NumberOfPlanes,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		CALLSYS	AllocMem
		move.l	d0,ScreenMemory(a6)
		beq	Exit

		move.l	ScreenMemory(a6),d0
		lea	PlaneAddresses(a6),a0	* Grab address of plane
		move.l	d0,(a0)+
		addi.l	#PlaneSize,d0
		move.l	d0,(a0)
		
		bsr	InitVariables

		CALLSYS	Forbid     

		move.w	dmaconr(a5),SystemDma(a6)
		move.w	intenar(a5),SystemInts(a6)
		move.w	#$7fff,d0
		move.w  d0,dmacon(a5)
		move.w	d0,intena(a5)
		move.w	#32,dmacon(a5)
		move.l  #TheCopperList,cop1lc(a5)   
		move.w  d0,copjmp1(a5)     
		move.w  #DMAF_SETCLR!DMAF_MASTER!DMAF_RASTER!DMAF_SPRITE!DMAF_BLITTER!DMAF_COPPER,dmacon(a5)	

InterruptLoop	move.w	intreqr(a5),d6
		move.w	#INTF_VERTB,d7
		and.w	d7,d6
		beq.s	InterruptLoop
		move.w	d7,intreq(a5)


		bsr	MoveStar
		
	
		btst	#6,Ciaapra
		bne.s	InterruptLoop

		move.w	SystemInts(a6),d0
		ori.w	#INTF_SETCLR!INTF_INTEN,d0
		move.w	d0,intena(a5)
		move.w 	SystemDma(a6),d0
		ori.w	#DMAF_SETCLR,d0
		move.w 	d0,dmacon(a5)
		CALLSYS	Permit
		move.l 	SystemCopper(a6),cop1lc(a5)
		move.l	ScreenMemory(a6),a1
		move.l	#PlaneSize*NumberOfPlanes,d0
		CALLSYS	FreeMem
Exit		movem.l (sp)+,d0-d7/a0-a6
		rts



* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Put screen in copper and load sprites. 				×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
		
UpdateCopper	lea	PlaneAddresses(a6),a0	
		lea	Planes,a1		
		move.w	(a0),(a1)		
		move.w	2(a0),4(a1)
		move.w	4(a0),8(a1)
		move.w	6(a0),12(a1)
		rts

LoadSprite	move.l	#StarSprite1,d0
		lea	Sprites,a0
		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		move.l	#StarSprite2,d0
		move.w	d0,12(a0)
		swap	d0
		move.w	d0,8(a0)
		move.l	#StarSprite3,d0
		move.w	d0,20(a0)
		swap	d0
		move.w	d0,16(a0)
		rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Starfield							×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

MakeStars	lea	StarSprite1,a0
		move.w	#NumberOfStars-1,d7
		move.b	#$2f,d0			* Start Y position
		move.b	#0,d1
		move.w	#$321f,d3
		move.w	#$5512,d5		* Random seeds
MakeLoop	bsr	Random	
		move.b	d0,(a0)+
		move.b	d5,(a0)+		* Random X Position
		add.w	#9,d0
		move.b	d0,(a0)+		* Second control word
		move.b	d1,(a0)+
		lea	StarData1,a1
		moveq.l	#18-1,d6
CopySpr		move.w	(a1)+,(a0)+		* Copy gfx data
		dbf	d6,CopySpr
		add.b	#9,d0
		cmpi.w	#240,d0
		blt	Okay
		move.b	#0,d0
		moveq.l	#6,d1	
Okay		dbf	d7,MakeLoop
		rts

MakeStars2	lea	StarSprite2,a0
		move.w	#NumberOfStars-1,d7
		move.b	#$30,d0			* Start Y position
		move.w	#0,d1
		move.w	#$321f,d3
		move.w	#$5512,d5		* Random seeds
MakeLoop2	bsr	Random	
		move.b	d0,(a0)+
		move.b	d5,(a0)+		* Random X Position
		add.w	#6,d0
		move.b	d0,(a0)+		* Second control word
		move.b	d1,(a0)+
		lea	StarData2,a1
		moveq.l	#12-1,d6
CopySpr2	move.w	(a1)+,(a0)+		* Copy gfx data
		dbf	d6,CopySpr2
		add.b	#4,d0
		cmpi.w	#240,d0
		blt	Okay2
		move.b	#0,d0
		moveq.l	#6,d1	
Okay2		dbf	d7,MakeLoop2
		rts

MakeStars3	lea	StarSprite3,a0
		move.w	#NumberOfStars-1,d7
		move.w	#$32,d0			* Start Y position
		move.w	#0,d1
MakeLoop3	bsr	Random
		move.b	d0,(a0)+
		move.b	d5,(a0)+		* Random X Position
		add.w	#1,d0
		move.b	d0,(a0)+		* Second control word
		move.b	d1,(a0)+
		move.w	#1,(a0)+		* Gfx Data
		move.w	#1,(a0)+
		add.b	#8,d0
		cmpi.w	#240,d0
		blt	Okay3
		move.b	#0,d0	
		moveq.l	#6,d1
Okay3		dbf	d7,MakeLoop3
		rts
		
Random		move.w	vhposr(a5),d4		* Random No. from beam pos'
		or.l	d3,d5
		add.l	d4,d5
		rts

MoveStar	lea	StarSprite1,a0
		lea	StarSprite2,a1
		lea	StarSprite3,a2
		move.w	#NumberOfStars-1,d0	
		moveq.b	#2,d1			* Speed counter	
StarLoop	add.b	d1,1(a0)
		add.b	d1,1(a1)
		add.b	d1,1(a2)
		add.w	#40,a0
		add.w	#28,a1
		add.w	#8,a2
		addq.b	#1,d1
		cmpi.b	#Max_Speed,d1
		ble	SpeedOkay
		moveq.b	#2,d1	
SpeedOkay	dbf	d0,StarLoop
		rts
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	MJC Screen-Typer V2.0						×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

ReadStruct	move.l	PlaneAddresses(a6),a0
		move.l	a0,a3			* 2 Bitplanes
		add.l	#PlaneSize+40,a3
		move.l	(a1)+,-(sp)		* Push next onto stack
		moveq.l	#0,d0
		move.w	(a1)+,d0		* X Pos
		add.w	d0,a0
		add.w	d0,a3			* And plane 2
		moveq.l	#0,d0
		move.w	(a1)+,d0		* Y Pos
		mulu	#ScreenWidth,d0
		add.w	d0,a0
		add.w	d0,a3			* Plane 2
		move.w	(a1)+,d7		* Ignore justify (for now)
		move.l	(a1)+,a4		* Font
		move.l	(a1),a2
		bsr	TypeString
		move.l	(sp)+,a1		* Next struct' or null
		cmpa.l	#0,a1
		bne	ReadStruct
		rts

TypeString	moveq.l	#20-1,d0
AllChars	move.l	a4,a1			* Font off stack
		moveq.l	#0,d1			* Char byte
		move.b	(a2)+,d1
		subi.w	#32,d1
		rol.w	#5,d1			* x32
		add.l	d1,a1
		moveq.l	#16-1,d2		* Char height
		moveq.l	#0,d3			* Modulo index
TypeIt		move.w	(a1),(a0,d3.w)
		move.w	(a1)+,(a3,d3.w)
		add.w	#ScreenWidth,d3
		dbf	d2,TypeIt
		addq.l	#2,a0
		addq.l	#2,a3
		dbf	d0,AllChars
		rts	

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		bsr	UpdateCopper
		bsr	LoadSprite
		bsr	MakeStars
		bsr	MakeStars2
		bsr	MakeStars3
		lea	TextStruct1,a1
		bsr	ReadStruct
		rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
		
		even

GraphicsName	GRAFNAME

		even
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Main variable list (accessed through A6)			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Variables,Bss
		
		rsreset

PlaneAddresses	rs.l	NumberOfPlanes	* Start address of each bitplane
ScreenMemory	rs.l	1		* Allocated memory	
SystemCopper	rs.l	1
SystemDma	rs.w	1
SystemInts	rs.w	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* × 	Copper list							×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Copper,Data_C

TheCopperList	dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0001,bplcon2,$0000
		dc.w	bpl1mod,0,bpl2mod,0

		dc.w 	bplcon0,$2200

		dc.w	color+$00,$0000,color+$02,$0fff
		dc.w	color+$04,$0007,color+$06,$0acc	* ACC! Our colour!!
		
		dc.w	color+$20,$0000,color+$22,$0fff
		dc.w	color+$24,$009e,color+$26,$000e
		dc.w	color+$28,$0000,color+$2a,$0fff
		dc.w	color+$2c,$009e,color+$2e,$000e
		
		dc.w	sprpt+$00
Sprites		dc.w	$0000,sprpt+$02,$0000,sprpt+$04,$0000,sprpt+$06
		dc.w	$0000,sprpt+$08,$0000,sprpt+$0a,$0000,sprpt+$0c
		dc.w	$0000,sprpt+$0e,$0000,sprpt+$10,$0000,sprpt+$12
		dc.w	$0000,sprpt+$14,$0000,sprpt+$16,$0000,sprpt+$18
		dc.w	$0000,sprpt+$1a,$0000,sprpt+$1c,$0000,sprpt+$1e
		dc.w	$0000

		dc.w	bplpt+$00
Planes 		dc.w 	$0000,bplpt+$02
		dc.w	$0000,bplpt+$04
		dc.w	$0000,bplpt+$06
		dc.w	$0000,bplpt+$08
		dc.w	$0000,bplpt+$0a
		dc.w	$0000,bplpt+$0c
		dc.w	$0000,bplpt+$0e
		dc.w	$0000

     		dc.w	$ffff,$fffe	

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	Text structure for Typer V2.0 					x
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Structures,Data

TextStruct1	dc.l	TextStruct2	* Pointer to next
		dc.w	0		* X pos (in multiples of 8 only!)
		dc.w	0		* Y pos (Max 240)
		dc.w	'L'		* Justify (L, R, or C)
		dc.l	Font3
		dc.l	Text1

TextStruct2	dc.l	TextStruct3
		dc.w	0,20,'L'
		dc.l	Font3		
		dc.l	Text2

TextStruct3	dc.l	TextStruct4
		dc.w	0,80,'L'
		dc.l	Font2		
		dc.l	Text3

TextStruct4	dc.l	0		* No next.
		dc.w	0,120,'L'
		dc.l	Font1		
		dc.l	Text4
		
		even
		
Text1		dc.b	'Screen Typer V2.0   ',0
Text2		dc.b	'Coded by Mike Cross ',0
Text3		dc.b	'Wot?  No blitter!   ',0
Text4		dc.b	'Hasta la Vista baby!',0

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	Font data
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Fonts,Data_C

Font1		incbin	source:Fonts16/Metallion.fnt01

Font2		incbin	source:Fonts16/Metallion.fnt03

Font3		incbin	source:Fonts16/PowerFont1.fnt

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	Starfield data
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section		Stars,Data_C

StarSprite1	dcb.w		38*NumberOfStars,0

StarSprite2	dcb.w		26*NumberOfStars,0

StarSprite3	dcb.w		6*NumberOfStars,0

StarData1	dc.w		$0800,$0800,$0000,$0800,$0000,$0800,$1c00
		dc.w		$1400,$9c80,$e380,$1c00,$1400,$0000,$0800
		dc.w		$0000,$0800,$0800,$0800

StarData2	dc.w		$2000,$2000,$0000,$2000,$a800,$d800
		dc.w		$0000,$2000,$2000,$2000,$0000,$0000

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		End


		

		




