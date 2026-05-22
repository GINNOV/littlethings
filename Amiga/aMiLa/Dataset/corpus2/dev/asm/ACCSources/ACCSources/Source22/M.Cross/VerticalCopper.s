
* -------------	Interrupt handler V8.0 ©1992 Mike Cross ---------------	*

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



ScreenWidth	equ	40
ScreenHeight	equ	256
PlaneSize	equ	ScreenWidth*ScreenHeight

NumberOfPlanes	equ	3

Ciaapra		equ	$bfe001		

Stack		equr	a7
All		reg	d0-d7/a0-a6

Debug		equ	0

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
		move.w  #DMAF_SETCLR!DMAF_BLITHOG!DMAF_MASTER!DMAF_RASTER!DMAF_BLITTER!DMAF_COPPER,dmacon(a5)	


InterruptLoop	move.l	vposr(a5),d7
		andi.l	#$1ff00,d7
		lsr.l	#8,d7
		cmpi.l	#260,d7
		bne	InterruptLoop

		IFNE	Debug
		move.w	#$0f0,color+$00(a5)	* Count those rasters!
		ENDC
		
		bsr	ClearScreen
		
		bsr	DoBars
		
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
		addi.w	#PlaneSize,d0
		addq.l	#8,a1
		dbf	d2,UCLoop
		rts
		
				
* -------------	Stop sprite interferance ------------------------------	*

ClearSprites	lea	Sprites,a0
		moveq.l	#16-1,d0
ClrSpriteLoop	move.w	#0,(a0)
		addq.l	#4,a0
		dbf	d0,ClrSpriteLoop
		rts

* -------------	Do the bars! ------------------------------------------	*

ClearScreen	movea.l	Physical(a6),a0
		move.w	#%000100000000,bltcon0(a5)
		move.l	#-1,bltafwm(a5)
		move.w	#0,bltdmod(a5)
		
		move.l	a0,bltdpt(a5)
		move.w	#(1<<6)!20,bltsize(a5)
Wait1		btst	#14,dmaconr(a5)
		bne	Wait1
		
		add.l	#PlaneSize,a0
		move.l	a0,bltdpt(a5)
		move.w	#(1<<6)!20,bltsize(a5)
Wait2		btst	#14,dmaconr(a5)
		bne	Wait2
		
		add.l	#PlaneSize,a0
		move.l	a0,bltdpt(a5)
		move.w	#(1<<6)!20,bltsize(a5)
Wait3		btst	#14,dmaconr(a5)
		bne	Wait3
		rts


DoBars		move.l	#$ffff0000,bltafwm(a5)
		move.l	#(-2<<16)!36,bltamod(a5)
		move.l	#(-2<<16)!36,bltbmod(a5)
				
		move.l	XSinePtr,a0
		addq.l	#2,a0
		
		cmpa.l	#XSinePtr+XSineSize,a0
		ble	SineFine
		move.l	#XSine,XSinePtr
		move.l	XSinePtr,a0
		
SineFine	move.l	a0,XSinePtr
		
		moveq.l	#54-1,d7
		
		move.l	Physical(a6),d1
		
SineLoop	move.l	d1,d5
		move.l	#Gfx,d0
		
		move.w	(a0),d3			* Get sine pos
		divu	#16,d3			* Into words
		move.w	d3,d4			* Preserve 
		clr.w	d3			
		swap	d3			* Remainder for X Shift
		
		ror.w	#4,d3			* Into correct bits
		move.w	d3,bltcon1(a5)		* B Shift (Mask)
		ori.w	#$0fca,d3		* Minterms = D = AB OR aC
		move.w	d3,bltcon0(a5)		* A Shift (Data)
		
		add.w	d4,d4			* ×2
		add.w	d4,d5			* Calc' X word position
		
		moveq.l	#NumberOfPlanes-1,d2
		
BarsLoop	move.l	#Mask,bltapt(a5)
		move.l	d0,bltbpt(a5)
		move.l	d5,bltcpt(a5)
		move.l	d5,bltdpt(a5)
		move.w	#1*64+2,bltsize(a5)
		addq.l	#2,d0
		addi.l	#PlaneSize,d5
		dbf	d2,BarsLoop
		
		adda.w	#10,a0
		dbf	d7,SineLoop
		rts
		
		
		
* -------------	Initialise variables ----------------------------------	*

InitVariables	lea	Custom,a5		* Defined in .GS header
		bsr	ClearSprites		
		bsr	AllocateScreens		
		bsr	UpdateCopper
		clr.w	QuitFlag(a6)
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
SystemDma	rs.w	1
SystemInts	rs.w	1
QuitFlag	rs.w	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF


* -------------	The copper list ---------------------------------------	*

		Section	Copper,Data_C

TheCopperList	dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0000,bplcon2,$0000
		dc.w	bpl1mod,-40
		dc.w	bpl2mod,-40
		
		dc.w	color+$00,$0000,color+$02,$0fff,color+$04,$0bdb
		dc.w	color+$06,$08c8,color+$08,$0595,color+$0a,$0383
		dc.w	color+$0c,$0181,color+$0e,$0040
		
		dc.w	sprpt+$00
Sprites		dc.w	$0000,sprpt+$02,$0000,sprpt+$04,$0000,sprpt+$06
		dc.w	$0000,sprpt+$08,$0000,sprpt+$0a,$0000,sprpt+$0c
		dc.w	$0000,sprpt+$0e,$0000,sprpt+$10,$0000,sprpt+$12
		dc.w	$0000,sprpt+$14,$0000,sprpt+$16,$0000,sprpt+$18
		dc.w	$0000,sprpt+$1a,$0000,sprpt+$1c,$0000,sprpt+$1e
		dc.w	$0000

		dc.w	$2c09,$fffe,color+$00,$000a
		dc.w	$2d09,$fffe,color+$00,$0000
		dc.w	bplcon0,((NumberOfPlanes<<12)!$200)
		
		dc.w	bplpt+$00
Planes 		dc.w 	$0000,bplpt+$02
		dc.w	$0000,bplpt+$04
		dc.w	$0000,bplpt+$06
		dc.w	$0000,bplpt+$08
		dc.w	$0000,bplpt+$0a
		dc.w	$0000
		
		dc.w	$fe09,$fffe,color+$00,$000a,bplcon0,$0200
		dc.w	$ff09,$fffe,color+$00,$0000
		
		dc.w	$ffff,$fffe	

* ---------------------------------------------------------------------	*

Gfx		dc.w	%0101010110101010
		
		dc.w	%0110011001100110
		
		dc.w	%0111100000011110
		
Mask		dc.w	-1

* ---------------------------------------------------------------------	*

		Section	Sine,Data

XSinePtr	dc.l	XSine

XSine
		rept	2
		dc.w	0,0,0,1,1,1,2,2
		dc.w	3,3,4,5,6,7,8,9
		dc.w	10,11,12,14,15,16,18,19
		dc.w	21,23,24,26,28,30,32,34
		dc.w	36,38,40,42,45,47,49,52
		dc.w	54,57,59,62,64,67,70,72
		dc.w	75,78,81,84,86,89,92,95
		dc.w	98,101,104,107,110,113,116,120
		dc.w	123,126,129,132,135,138,141,145
		dc.w	148,151,154,157,160,163,166,170
		dc.w	173,176,179,182,185,188,191,194
		dc.w	197,200,202,205,208,211,214,216
		dc.w	219,222,224,227,229,232,234,237
		dc.w	239,241,244,246,248,250,252,254
		dc.w	256,258,260,262,263,265,267,268
		dc.w	270,271,272,274,275,276,277,278
		dc.w	279,280,281,282,283,283,284,284
		dc.w	285,285,285,286,286,286
		dc.w	286,286,286,286,285,285,285,284
		dc.w	284,283,283,282,281,280,279,278
		dc.w	277,276,275,274,272,271,270,268
		dc.w	267,265,263,262,260,258,256,254
		dc.w	252,250,248,246,244,241,239,237
		dc.w	234,232,229,227,224,222,219,216
		dc.w	214,211,208,205,202,200,197,194
		dc.w	191,188,185,182,179,176,173,170
		dc.w	166,163,160,157,154,151,148,145
		dc.w	141,138,135,132,129,126,123,120
		dc.w	116,113,110,107,104,101,98,95
		dc.w	92,89,86,84,81,78,75,72
		dc.w	70,67,64,62,59,57,54,52
		dc.w	49,47,45,42,40,38,36,34
		dc.w	32,30,28,26,24,23,21,19
		dc.w	18,16,15,14,12,11,10,9
		dc.w	8,7,6,5,4,3,3,2
		dc.w	2,1,1,1,0,0,0,0
		endr
		
XSineSize	equ	(*-XSinePtr)/2

* ---------------------------------------------------------------------	*

		End

   
