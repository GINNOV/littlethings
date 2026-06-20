
* -------------	Double buffered 4 colour 1 Pixel sine scroller --------	*

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

NumberOfPlanes	equ	2

Ciaapra		equ	$bfe001			

Debug		equ	0

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
		cmpi.l	#200,d7
		bne	InterruptLoop

		IFNE	Debug
		move.w	#$0f0,color+$00(a5)	* Count those rasters!
		ENDC
		
		
		bsr	DoubleBuffer

		bsr	ClearScreen

		bsr	Scroller

		bsr	DoSine
		
		bsr	CopyPlane
		
				
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

FreeScr1	move.l	Logical(a6),a1
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
		move.l	d0,Logical(a6)
		move.l	d0,ScreenOn(a6)
		beq	Exit

		move.l	#PlaneSize*NumberOfPlanes,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1	
		CALLSYS	AllocMem
		move.l	d0,Physical(a6)
		move.l	d0,ScreenOff(a6)
		beq	FreeScr1
		rts


DoubleBuffer	move.l	ScreenOff(a6),d0
		move.l	ScreenOn(a6),ScreenOff(a6)
		move.l	d0,ScreenOn(a6)
		
		lea	Planes,a1
		moveq.l	#NumberOfPlanes-1,d2
UCLoop		move.w	d0,4(a1)
		swap	d0
		move.w	d0,(a1)
		swap	d0
		addi.w	#PlaneSize,d0
		addq.l	#8,a1
		dbf	d2,UCLoop
		rts
		

ClearScreen	movea.l	ScreenOff(a6),a0
		move.w	#%0000000100000000,bltcon0(a5)
		move.w	#0,bltdmod(a5)
		move.l	a0,bltdpt(a5)
		move.w	#136*64+21,bltsize(a5)
		bsr	TestBlitter
		rts
		

Scroller	move.l	#ScrollBuffer,d0
		move.l	d0,d1
		subq.l	#2,d1
		
		move.l	#-1,bltafwm(a5)
		move.l	#$c9f00000,bltcon0(a5)
		
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
		
		tst.b	d0
		bpl	TextOkay
		move.l	#Text,TextPtr(a6)
		bra	GetChar
		
TextOkay	subi.w	#32,d0
		mulu	#32,d0
		lea	Font,a2
		add.l	d0,a2
		
		move.l	#-1,bltafwm(a5)
		move.w	#$09f0,bltcon0(a5)
		move.w	#0,bltamod(a5)
		move.w	#40,bltdmod(a5)
		move.l	a2,bltapt(a5)
		move.l	d1,bltdpt(a5)
		move.w	#16*64+1,bltsize(a5)
				
		move.l	a1,TextPtr(a6)
		move.w	#4,Plop(a6)
NoNewChar	rts
	

DoSine		movea.l	ScreenOff(a6),a0
		move.l	a6,-(sp)
		move.l	#ScrollBuffer,d2
		move.l	SinePtr,a2
		add.l	#12,a2
		
		cmpa.l	#SinePtr+SineSize,a2
		ble	SineFine
		move.l	#Sine,SinePtr
		move.l	SinePtr,a2
		
SineFine	move.l	a2,SinePtr
		move.w	#-1,bltafwm(a5)
		
		move.w	#$0dfc,bltcon0(a5)
		
		move.w	#40,bltbmod(a5)
		move.l	#(40<<16!40),bltamod(a5)	* AMOD/DMOD = 40
		
		move.w	#16*64+1,d4
		lea	bltsize(a5),a1
		lea	bltapt(a5),a3
		lea	bltbpt(a5),a4
		lea	bltdpt(a5),a6
		lea	bltafwm(a5),a5
		moveq.l	#20-1,d1
		
SineLoop	move.w	#$8000,d5			* Mask
		
		rept	16
		move.l	a0,d3
		add.w	(a2)+,d3
		move.w	d5,(a5)				* Last word mask
		move.l	d2,(a3)				* A Source
		move.l	d3,(a4)				* B Source  
		move.l	d3,(a6)				* D Destination
		move.w	d4,(a1)				* Do the blit
		ror.w	#1,d5
		endr
		
		addq.l	#2,a0
		addq.l	#2,d2
		dbf	d1,SineLoop
		lea	Custom,a5
		move.l	(sp)+,a6
		rts


CopyPlane	move.l	ScreenOff(a6),d0
		move.l	d0,d1
		add.l	#PlaneSize,d1
		move.l	#-1,bltafwm(a5) 
		move.w	#$09f0,bltcon0(a5)
		move.l	#0,bltamod(a5)
		move.l	d0,bltapt(a5)
		move.l	d1,bltdpt(a5)
		move.w	#146*64+20,bltsize(a5)
		rts
			

* -------------	Stop sprite interferance ------------------------------	*

ClearSprites	lea	Sprites,a0
		moveq.l	#16-1,d0
ClrSpriteLoop	move.w	#0,(a0)
		addq.l	#4,a0
		dbf	d0,ClrSpriteLoop
		rts

		

* -------------	Initialise variables ----------------------------------	*

InitVariables	lea	Custom,a5		* Defined in .GS header
		bsr	ClearSprites		
		bsr	AllocateScreens		
		clr.w	QuitFlag(a6)
		move.l	#Text,TextPtr(a6)
		move.w	#4,Plop(a6)
		clr.w	Delay(a6)
		rts


* -------------	Variables ---------------------------------------------	*
		
		even

GraphicsName	GRAFNAME

		even
		
		
* -------------	BSS Variable list -------------------------------------	*

		Section	Variables,Bss
		
		rsreset

Logical		rs.l	1		
Physical	rs.l	1
ScreenOn	rs.l	1
ScreenOff	rs.l	1
SystemCopper	rs.l	1
TextPtr		rs.l	1
Plop		rs.w	1
Delay		rs.w	1
SystemDma	rs.w	1
SystemInts	rs.w	1
QuitFlag	rs.w	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF


* -------------	The copper list ---------------------------------------	*

		Section	Copper,Data_C

TheCopperList	dc.w	$0a01,$ff00
		dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0006,bplcon2,$0000
		dc.w	bpl1mod,2,bpl2mod,2
		
		dc.w 	bplcon0,((NumberOfPlanes<<12)!$200)

		dc.w	color+$00,$0000,color+$02,$0555
		dc.w	color+$04,$0ccc,color+$06,$0ccc
			
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
		dc.w	$0000	
				
     		dc.w	$ffff,$fffe	

* ---------------------------------------------------------------------	*

		Section	FontData,Data_C

Font		incbin	source:m.cross/Fonts16/Metallion.fnt01

* ---------------------------------------------------------------------	*

ScrollBuffer	dcb.b	ScreenWidth*16

* ---------------------------------------------------------------------	*

		Section	Text,Data

Text		dc.b	' THIS IS A 1 PIXEL FOUR COLOUR DOUBLE BUFFERED '
		dc.b	'SINE SCROLLER WRITTEN TO ACCOMPANY THE TUTORIAL '
		dc.b	'ON ACC 22.  ALL CODING BY MIKE CROSS     ',-1
		
* ---------------------------------------------------------------------	*

	Section	Sine,Data

SinePtr		dc.l	Sine

Sine		include	Source:Tutorialsource/Sine/BigSine2(120).i
		include	Source:Tutorialsource/Sine/BigSine2(120).i

SineSize	equ	(*-SinePtr)/2

* ---------------------------------------------------------------------	*

		End

   
