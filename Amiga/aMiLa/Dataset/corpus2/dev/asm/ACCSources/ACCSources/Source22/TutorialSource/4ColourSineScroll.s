
* -------------	Single buffered 2 Pixel sine scroller -----------------	*

* -------------	Coding by Mike Cross February 1992 --------------------	*

* -------------	Use Devpac V3.01 to assemble --------------------------	*

		incdir	sys:include/
		include	exec/exec_lib.i
		include	exec/memory.i
		include	graphics/graphics_lib.i
		include	graphics/gfxbase.i
		include	hardware/custom.i
		include	hardware/dmabits.i
		include	hardware/intbits.i
		include	hardware/blit.i

Custom		equ	$dff000



ScreenWidth	equ	42
ScreenHeight	equ	256
PlaneSize	equ	ScreenWidth*ScreenHeight

NumberOfPlanes	equ	4

Ciaapra		equ	$bfe001

Debug		equ	0

Shake		equ	1			* Set to 0 to disable shake

Stack		equr	a7
All		reg	d0-d7/a0-a6

CALLSYS		MACRO				
		move.l	a6,-(sp)	
		move.l	$4,a6	
		jsr	_LVO\1(a6)
		move.l	(sp)+,a6
		ENDM

	

		opt	d+,ow-,o+
		
		

		Section	Main,Code
		
		movem.l  All,-(Stack)

		lea	Variables,a6		* A6 - Always variables

		lea     GraphicsName(pc),a1
		CALLSYS	OldOpenLibrary   
		beq	Exit
		move.l	d0,a1
		move.l	gb_copinit(a1),SystemCopper(a6)	
		CALLSYS	CloseLibrary
		
		bsr	InitVariables

		CALLSYS	Forbid     

		move.w	dmaconr(a5),SystemDma(a6)
		move.w	intenar(a5),SystemInts(a6)
		move.w	#$7fff,d0
		move.w  d0,dmacon(a5)
		move.w	d0,intena(a5)
		move.l  #TheCopperList,cop1lc(a5)   
		move.w  d0,copjmp1(a5)     
		move.w  #DMAF_SETCLR!DMAF_BLITHOG!DMAF_MASTER!DMAF_RASTER!DMAF_SPRITE!DMAF_BLITTER!DMAF_COPPER,dmacon(a5)	

InterruptLoop	move.l	vposr(a5),d7
		andi.l	#$1ff00,d7
		lsr.l	#8,d7
		cmpi.l	#240,d7
		bne	InterruptLoop

		IFNE	Debug
		move.w	#$084,color+$00(a5)	* Count those rasters!
		ENDC
	
		bsr	ClearScreen

		bsr	Scroller

		bsr	DoSine
		 
		bsr	CopyPlane
		
		IFNE	Shake
		bsr	CycleBar
		ENDC
		
		IFNE	Debug
		move.w	#$000,color+$00(a5)
		ENDC

		
		bsr	Mouse
		
		tst.w	QuitFlag(a6)
		beq	InterruptLoop
		
		move.w	SystemInts(a6),d0
		ori.w	#INTF_SETCLR!INTF_INTEN,d0
		move.w	d0,intena(a5)
		move.w 	SystemDma(a6),d0
		ori.w	#DMAF_SETCLR,d0
		move.w 	d0,dmacon(a5)
		CALLSYS	Permit
		move.l 	SystemCopper(a6),cop1lc(a5)

		move.l	Physical(a6),a1
		move.l	#PlaneSize*NumberOfPlanes,d0
		CALLSYS	FreeMem

Exit		movem.l (Stack)+,All
		moveq.l	#0,d0
		rts
		
			
* -------------	Test mouse and blitter --------------------------------	*

Mouse		btst	#6,Ciaapra
		seq	QuitFlag(a6)
		rts

TestBlitter	btst	#14,dmaconr(a5)
Wait		btst	#14,dmaconr(a5)
		bne	Wait
		rts



* -------------	Memory & screen handling routines ---------------------	*

AllocateScreens	move.l	#PlaneSize*NumberOfPlanes,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1	
		CALLSYS	AllocMem
		move.l	d0,Physical(a6)
		beq	Exit
		rts


UpdateCopper	move.l	Physical(a6),d0
		lea	Planes,a1
		moveq.l	#NumberOfPlanes-1,d2
UCLoop		move.w	d0,4(a1)
		swap	d0
		move.w	d0,(a1)
		swap	d0
		addi.l	#PlaneSize,d0
		addq.l	#8,a1
		dbf	d2,UCLoop
		rts
		

ClearScreen	movea.l	Physical(a6),a0
		move.w	#%0000000100000000,bltcon0(a5)
		move.w	#2,bltdmod(a5)
		move.l	a0,bltdpt(a5)
		move.w	#136*64+20,bltsize(a5)
		bsr	TestBlitter
		rts
		

Scroller	tst.w	Delay(a6)
		beq	NoDelay
		sub.w	#1,Delay(a6)
		rts
				
NoDelay		move.l	#ScrollBuffer,d0
		move.l	d0,d1
		subq.l	#2,d1
		
		move.l	#-1,bltafwm(a5)
		move.w	#$c9f0,bltcon0(a5)
		
		move.l	#0,bltamod(a5)
		
		move.l	d0,bltapt(a5)
		move.l	d1,bltdpt(a5)
		move.w	#16*64+22,bltsize(a5)
		
		sub.w	#1,Plop(a6)
		bne	NoNewChar
		
		move.l	#ScrollBuffer,d1
		add.l	#40,d1
		
GetChar		movea.l	TextPtr(a6),a1
		moveq.l	#0,d0
		move.b	(a1)+,d0
		cmpi.b	#'@',d0
		bne	NoPause
		move.w	#200,Delay(a6)
		move.b	(a1)+,d0


NoPause		tst.b	d0
		bpl	TextOkay
		move.l	#Text,TextPtr(a6)
		bra	GetChar
		
TextOkay	subi.w	#32,d0
		mulu	#32,d0
		lea	Font,a2
		add.l	d0,a2
		
		move.w	#$09f0,bltcon0(a5)
		move.l	#40,bltamod(a5)
		move.l	a2,bltapt(a5)
		move.l	d1,bltdpt(a5)
		move.w	#16*64+1,bltsize(a5)
				
		move.l	a1,TextPtr(a6)
		move.w	#4,Plop(a6)
NoNewChar	rts
		

DoSine		move.l	#ScrollBuffer,d2
		move.l	SinePtr,a2
		add.w	Y_Add(a6),a2
		move.l	a2,SinePtr
		
		cmpa.l	#SinePtr+SineSize,a2
		ble	SineFine
		move.l	#Sine,SinePtr
		move.l	SinePtr,a2
			
SineFine	move.w	#-1,bltafwm(a5)
		
		movea.l	Physical(a6),a0
		move.l	a6,-(sp)
		
		move.w	#$0dfc,bltcon0(a5)
		
		move.w	#40,bltbmod(a5)
		move.l	#(40<<16!40),bltamod(a5)	* AMOD/DMOD = 40
		
		lea	bltapt(a5),a3
		lea	bltbpt(a5),a4
		lea	bltdpt(a5),a6
		lea	bltsize(a5),a1
		lea	bltafwm(a5),a5
		moveq.l	#20-1,d1
		move.w	#16*64+1,d4
		
		moveq.l	#0,d0
		
SineLoop	move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%1100000000000000,(a5)
		move.l	d2,(a3)				* A Source
		move.l	d3,(a4)				* B Source  
		move.l	d3,(a6)
		move.w	d4,(a1)

		move.l	a0,d3
		add.w	(a2)+,d3
		add.l	d0,d3
		move.w	#%0011000000000000,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%0000110000000000,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%0000001100000000,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%0000000011000000,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%0000000000110000,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%0000000000001100,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	#%0000000000000011,(a5)
		move.l	d2,(a3)
		move.l	d3,(a4)
		move.l	d3,(a6)
		move.w	d4,(a1)
		
		addq.l	#2,d2
		addq.l	#2,a0	
		dbf	d1,SineLoop
		lea	Custom,a5
		move.l	(sp)+,a6
		rts

		

* -------------	Stop sprite interferance ------------------------------	*

ClearSprites	lea	Sprites,a0
		moveq.l	#16-1,d0
ClrSpriteLoop	move.w	#0,(a0)
		addq.l	#4,a0
		dbf	d0,ClrSpriteLoop
		rts

		IFNE	Shake
MakeCopper	lea	Bars,a0
		move.l	#$2d09fffe,d0		* Start Pos
		move.l	#$01020000,d1		* bplcon1, 0
		move.l	#140-1,d3		* No. of raster lines
		
MCL2		move.l	d0,(a0)+
		move.l	d1,(a0)+
		addi.l	#$01000000,d0
		dbf	d3,MCL2
		rts

CycleBar	movea.l	WigglePtr,a0
		addq.l	#2,a0
		move.l	a0,WigglePtr
		
		cmpa.l	#WiggleSize+WigglePtr,a0
		ble	SineFine2
		
		move.l	#Wiggle,WigglePtr
		bra	CycleBar
		
SineFine2	move.l	#Bars+6,d1
		move.w	#$09f0,bltcon0(a5)
		move.l	#6,bltamod(a5)			* DMOD = 14
		move.l	#-1,bltafwm(a5)
		
		move.l	a0,bltapt(a5)
		move.l	d1,bltdpt(a5)	
		move.w	#140*64+1,bltsize(a5)	
		rts
		ENDC

CopyPlane	move.l	Physical(a6),d0		* Copy the first plane to
		move.l	d0,d1			* the second - and shift
		add.l	#PlaneSize,d1		* it at the same time so as
		move.l	#$fffffffc,bltafwm(a5)	* to create the drop shadow
		move.w	#$29f0,bltcon0(a5)
		move.w	#2,bltamod(a5)
		move.w	#2,bltdmod(a5)
		move.l	d0,bltapt(a5)
		move.l	d1,bltdpt(a5)
		move.w	#136*64+20,bltsize(a5)
		rts
		
		

* -------------	Initialise variables ----------------------------------	*

InitVariables	lea	Custom,a5		* Defined in .GS header
		bsr	ClearSprites		
		bsr	AllocateScreens	
		bsr	UpdateCopper	
		IFNE	Shake
		bsr	MakeCopper
		ENDC
		clr.w	QuitFlag(a6)
		move.l	#Text,TextPtr(a6)
		move.w	#4,Plop(a6)
		clr.w	Delay(a6)
		move.w	#10,Y_Add(a6)
		rts


* -------------	Variables ---------------------------------------------	*
		
		even

GraphicsName	GRAFNAME

		even
		
		
* -------------	BSS Variable list -------------------------------------	*

		Section	Variables,Bss
		
		rsreset
		
Physical	rs.l	1
SystemCopper	rs.l	1
TextPtr		rs.l	1
Plop		rs.w	1
Delay		rs.w	1
Y_Add		rs.w	1
SystemDma	rs.w	1
SystemInts	rs.w	1
QuitFlag	rs.w	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF


* -------------	The copper list ---------------------------------------	*

		Section	Copper,Data_C

TheCopperList	dc.w	$0a01,$fffe
		dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0000,bplcon2,$0000
		dc.w	bpl1mod,2,bpl2mod,2
		
		dc.w 	bplcon0,((NumberOfPlanes<<12)!$200)

		dc.w	color+$00,$0000,color+$02,$0555
		dc.w	color+$04,$0fff,color+$06,$0aaa
				
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
		
		IFNE	Shake
Bars		dcb.b	140*8
		ENDC
			
     		dc.w	$ffff,$fffe	

* ---------------------------------------------------------------------	*

		Section	FontData,Data_C

Font		incbin	source:m.cross/fonts16/Metallion.fnt01

* ---------------------------------------------------------------------	*

ScrollBuffer	dcb.b	ScreenWidth*16

* ---------------------------------------------------------------------	*

		Section	Text,Data

Text		dc.b	' THIS IS A 2 PIXEL SINGLE BUFFERED SINE SCROLLER!!'
		dc.b	' THE SHAKING EFFECT IS MADE BY CHANGING THE '
		dc.b	'BPLCON1 SCROLL VALUE EVERY RASTER LINE.  '
		dc.b	'HI TO ALL MY CONTACTS.         ',-1
		
* ---------------------------------------------------------------------	*

		Section	Sine,Data

SinePtr		dc.l	Sine

Sine		include	source:Tutorialsource/Sine/BigSine2(120).i

SineSize	equ	(*-SinePtr)/2

* ---------------------------------------------------------------------	*
		
		IFNE	Shake
		
		Section	Wiggle,Data_C

WigglePtr	dc.l	Wiggle

Wiggle		
		Rept	6
		dc.w	15*17,15*17,15*17,15*17
		dc.w	14*17,14*17,14*17
		dc.w	13*17,13*17
		dc.w	12*17,12*17
		dc.w	11*17
		dc.w	10*17,10*17
		dc.w	9*17
		dc.w	8*17
		dc.w	7*17,7*17
		dc.w	6*17
		dc.w	5*17,5*17
		dc.w	4*17
		dc.w	3*17,3*17
		dc.w	2*17,2*17
		dc.w	1*17,1*17,1*17
		dc.w	0*17,0*17,0*17,0*17,0*17,0*17,0*17
		dc.w	1*17,1*17,1*17
		dc.w	2*17,2*17
		dc.w	3*17,3*17
		dc.w	4*17
		dc.w	5*17,5*17
		dc.w	6*17
		dc.w	7*17,7*17
		dc.w	8*17
		dc.w	9*17
		dc.w	10*17,10*17
		dc.w	11*17
		dc.w	12*17,12*17
		dc.w	13*17,13*17
		dc.w	14*17,14*17,14*17
		dc.w	15*17,15*17,15*17
		Endr

WiggleSize	equ	(*-WigglePtr)/2

		ENDC

* ---------------------------------------------------------------------	*

		End

   
