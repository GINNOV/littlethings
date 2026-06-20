
* ------------- BIG SCROLLER intro ©1992 M J Cross --------------------	*

* -------------	Coded on Devpac V3.01 ---------------------------------	*


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


ScreenWidth	equ	80
ScreenHeight	equ	256
PlaneSize	equ	ScreenWidth*ScreenHeight

NumberOfPlanes	equ	1

Ciaapra		equ	$bfe001
VERSION_NUMBER	equ	34

Debug		equ	0

		opt	d+,ow-,o+
		
CALLSYS		MACRO
		move.l	a6,-(sp)
		move.l	$4,a6
		jsr	_LVO\1(a6)
		move.l	(sp)+,a6
		ENDM
		
		
		Section	Main,Code_C
		
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
		move.l	d0,Screen1(a6)
		beq	FreeScr1

		move.l	#(PlaneSize/2)*NumberOfPlanes,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		CALLSYS	AllocMem
		move.l	d0,Screen2(a6)
		beq	Exit

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
		cmpi.l	#60,d7
		bne	InterruptLoop

		IFNE	Debug
		move.w	#$0f0,color+$00(a5)	
		ENDC

		bsr	Scroll
		
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
		
		move.l	Screen2(a6),a1
		move.l	#(PlaneSize/2)*NumberOfPlanes,d0
		CALLSYS	FreeMem

FreeScr1	move.l	Screen1(a6),a1
		move.l	#PlaneSize*NumberOfPlanes,d0
		CALLSYS	FreeMem
Exit		movem.l (sp)+,d0-d7/a0-a6
		moveq.l	#0,d0
		rts


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Put screen in copper,clear sprite pointers & load colour map	×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

Mouse		btst	#6,Ciaapra
		seq	QuitFlag(a6)
		rts

UpdateCopper	move.l	Screen1(a6),d0	
		lea	Planes,a1		
		move.w	d0,4(a0)	
		swap	d0
		move.w	d0,(a0)
		
		addq.l	#8,a0
		move.l	Screen2(a6),d0
		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		rts
		

ClearSprites	lea	Sprites,a0
		moveq.l	#16-1,d0
ClrSpriteLoop	move.w	#0,(a0)
		addq.l	#4,a0
		dbf	d0,ClrSpriteLoop
		rts


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Scroll that screen						×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

Scroll		move.l	Screen1(a6),d0
		move.l	d0,d1
		subq.l	#2,d1
		move.w	#$89f0,bltcon0(a5)
		move.l	#$00080008,bltamod(a5)
		move.l	d0,bltapt(a5)
		move.l	d1,bltdpt(a5)
		move.w	#256*64+36,bltsize(a5)
		
		subq.w	#1,PlopWait(a6)
		bne	NoDraw
		
		add.l	#ScreenWidth/2,d0	* Still points to screen
		move.l	d0,d2			* Save for later
		lea	Block,a0
		move.w	#$09f0,bltcon0(a5)
		move.l	#78,bltamod(a5)		* AMOD=0 DMOD=78
		lea	BigFont,a1		
ReadChar	move.l	TextPtr(a6),a2
		moveq.l	#0,d3
		move.b	(a2)+,d3
		bne	CharOkay
		move.l	#Text,TextPtr(a6)
		bra	ReadChar
CharOkay	subi.b	#32,d3
		rol.l	#8,d3			* x256		
		add.w	d3,a1
		moveq.l	#16-1,d7		* No. of vertical blocks
VertLoop	moveq.l	#16-1,d6		* No. of horiz blocks
HorizLoop	move.b	(a1)+,d1
		cmpi.b	#'0',d1
		beq	NullBlock
		move.l	a0,bltapt(a5)
		move.l	d0,bltdpt(a5)
		move.w	#16*64+1,bltsize(a5)
NullBlock	addq.l	#2,d0
		dbf	d6,HorizLoop	
		move.l	d2,d0
		add.l	#16*ScreenWidth,d0
		move.l	d0,d2
		dbf	d7,VertLoop
		move.l	a2,TextPtr(a6)
		move.w	#32,PlopWait(a6)
NoDraw		rts



WriteCredits	move.l	Screen2(a6),a0
		lea	Credits,a1
		
		moveq.l	#17-1,d4		* No. of lines
WCLoop3		moveq.l	#40-1,d3		* Width of each line
		
WCLoop2		moveq.l	#0,d0
		move.b	(a1)+,d0
		subi.w	#32,d0
		asl.w	#3,d0			* ×8
		lea	Font8,a2
		adda.w	d0,a2

		moveq.l	#8-1,d1
		moveq.l	#0,d2
WCLoop		move.b	(a2)+,(a0,d2)
		addi.w	#ScreenWidth/2,d2
		dbf	d1,WCLoop
		addq.l	#1,a0
		dbf	d3,WCLoop2
		add.w	#(ScreenWidth/2)*10,a0
		dbf	d4,WCLoop3
		rts

		

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		bsr	ClearSprites
		bsr	UpdateCopper
		move.l	#-1,bltafwm(a5)		* No Masking
		move.l	#Text,TextPtr(a6)
		move.w	#32,PlopWait(a6)
		clr.w	QuitFlag(a6)
		bsr	WriteCredits
		rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
		
		even

GraphicsName	GRAFNAME

		even
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Main variable list (accessed through A6)			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		rsreset

Screen1		rs.l	1		* Allocated memory	
Screen2		rs.l	1
SystemCopper	rs.l	1
SystemDma	rs.w	1
SystemInts	rs.w	1
TextPtr		rs.l	1
PlopWait	rs.w	1
QuitFlag	rs.w	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* × 	Copper list							×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Copper,Data_C

TheCopperList	dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0000,bplcon2,$0040
		dc.w	bpl1mod,40,bpl2mod,0

		dc.w 	bplcon0,$2600

		dc.w	color+$00,$0000,color+$02,$044f
		dc.w	color+$12,$0eea
		 
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
		
		dc.w	$ed09,$fffe,color+$00,$0002
		dc.w	$ee09,$fffe,color+$00,$0003
		dc.w	$ef09,$fffe,color+$00,$0004
		dc.w	$f009,$fffe,color+$00,$0005
		dc.w	$f109,$fffe,color+$00,$0006
		dc.w	$f309,$fffe,color+$00,$0007
		dc.w	$f609,$fffe,color+$00,$0008
		dc.w	$fa09,$fffe,color+$00,$0009
		dc.w	$ff09,$fffe,color+$00,$000a
		dc.w	$ffe1,$fffe
		dc.w	$0609,$fffe,color+$00,$000b
		dc.w	$0d09,$fffe,color+$00,$000c
		dc.w	$1509,$fffe,color+$00,$000d
		dc.w	$1e09,$fffe,color+$00,$000e
		dc.w	$2809,$fffe,color+$00,$000f
		
		
     		dc.w	$ffff,$fffe	

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	The blocks which make up the big letters			x
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

*Block		dc.l	-1,-1,-1,-1,-1,-1,-1,-1
 
*Block		dc.w	-1,0,-1,0,-1,0,-1,0
		dc.w	-1,0,-1,0,-1,0,-1,0

Block		dc.w	%0000000000000000
		dc.w	%0001111111110000
		dc.w	%0111111111111100
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%1111111111111110
		dc.w	%0111111111111100
		dc.w	%0001111111110000
	
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		section	Font,Data_C

BigFont		incbin	source:m.cross/Bitmaps/BigFont1.raw

		section	Font,Data_C
		
Font8		incbin	source:m.cross/Fonts8/Metallion.fnt06

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	The text.  Lower case CAN be used but looks bad on spacing	x 
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Text,Data

Text		dc.b	'HUGE SCROLLER BY MIKE CROSS.  IS THIS THE '
		dc.b	'BIGGEST SCROLLER EVER CODED????  MAYBE, MAYBE '
		dc.b	'NOT.   HI TO MARK, BLAINE AND ALL MY OTHER '
		dc.b	'CONTACTS.       ',0
		
		even

Credits		dc.b	'                                        '
		dc.b	'                                        '
		dc.b	'       Huge scroller text screen.       '
		dc.b	'       --------------------------       '
		dc.b	'                                        '
		dc.b	'      Design and 68000 programming      '
		dc.b	'                                        '
		dc.b	'            -- Mike Cross --            '
		dc.b	'                                        '
		dc.b	'                                        '
		dc.b	'       Greetings to the following       '
		dc.b	'                                        '
		dc.b	' Mark Meany, Blaine Evans, Gary Wright, '
		dc.b	'                                        '
		dc.b	'      Steve Netting, Dave Docwards,     '
		dc.b	'                                        '
		dc.b	' Ian Faichnie and all at Commodore UK!! '
			
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		End



		

