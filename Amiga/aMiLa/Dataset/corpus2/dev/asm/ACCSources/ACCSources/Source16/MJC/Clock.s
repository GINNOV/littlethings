
*		Simple clock coded for ACC by Mike Cross, July 1991

*		PD source - Use and abuse as you please.

*		Note: This clock does NOT count in seconds!

*		Use Powerfonts16 fonts for timer.


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
		include	source:include/mymacros.i		

ScreenWidth	equ	40
ScreenHeight	equ	256
PlaneSize	equ	ScreenWidth*ScreenHeight

NumberOfPlanes	equ	1

Ciaapra		equ	$bfe001
Custom		equ	$dff000
VERSION_NUMBER	equ	33			* 33 for V1.2 Amiga's




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
		move.l	d0,(a0)			
		
		bsr	InitVariables

		CALLSYS	Forbid     

		move.l	$68.w,SystemLev2Int(a6)
		move.l	$6c.w,SystemLev3Int(a6)
		move.w	dmaconr(a5),SystemDma(a6)
		move.w	intenar(a5),SystemInts(a6)
		move.w	#$7fff,d0
		move.w  d0,dmacon(a5)
		move.w	d0,intena(a5)
		move.l  #TheCopperList,cop1lc(a5)   
		move.w  d0,copjmp1(a5)     
		move.w  #DMAF_SETCLR!DMAF_MASTER!DMAF_RASTER!DMAF_BLITTER!DMAF_COPPER,dmacon(a5)	

InterruptLoop	move.w	intreqr(a5),d6
		move.w	#INTF_VERTB,d7
		and.w	d7,d6
		beq.s	InterruptLoop
		move.w	d7,intreq(a5)


		bsr	DrawTime
		bsr	IncTimer
		

		btst	#6,Ciaapra
		bne.s	InterruptLoop

		move.w	SystemInts(a6),d0
		ori.w	#INTF_SETCLR!INTF_INTEN,d0
		move.w	d0,intena(a5)
		move.w 	SystemDma(a6),d0
		ori.w	#DMAF_SETCLR,d0
		move.w 	d0,dmacon(a5)
		move.l	SystemLev2Int(a6),$68.w
		move.l	SystemLev3Int(a6),$6c.w
		CALLSYS	Permit
		move.l 	SystemCopper(a6),cop1lc(a5)
		move.l	ScreenMemory(a6),a1
		move.l	#PlaneSize*NumberOfPlanes,d0
		CALLSYS	FreeMem
Exit		movem.l (sp)+,d0-d7/a0-a6
		rts


IncTimer	lea	Time,a0
		cmpi.b	#'9',7(a0)
		beq	IncOne
		addi.b	#1,7(a0)
		rts
	
IncOne		move.b	#'0',7(a0)
		cmpi.b	#'9',6(a0)
		beq	IncTwo
		addi.b	#1,6(a0)
		rts

IncTwo		move.b	#'0',6(a0)
		cmpi.b	#'9',4(a0)
		beq	IncThree
		addi.b	#1,4(a0)
		rts
		
IncThree	move.b	#'0',4(a0)
		cmpi.b	#'9',3(a0)
		beq	IncFour
		addi.b	#1,3(a0)
		rts

IncFour		move.b	#'0',3(a0)
		cmpi.b	#'9',1(a0)
		beq	IncFive
		addi.b	#1,1(a0)
		rts

IncFive		move.b	#'0',1(a0)
		cmpi.b	#'9',(a0)
		beq	ResetAll
		addi.b	#1,(a0)
		rts

ResetAll	move.l	#'00:0',(a0)+
		move.l	#'0:00',(a0)
		rts
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Put screen in copper,clear sprite pointers & load colour map	×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

UpdateCopper	lea	PlaneAddresses(a6),a0	
		lea	Planes,a1		
		move.w	(a0),(a1)		
		move.w	2(a0),4(a1)		
		rts

ClearSprites	lea	Sprites,a0
		moveq.l	#16-1,d0
ClrSpriteLoop	move.w	#0,(a0)
		addq.l	#4,a0
		dbf	d0,ClrSpriteLoop
		rts


ClearScreen	move.l	PlaneAddresses(a6),a0
		moveq.l	#NumberOfPlanes-1,d0
		move.l	#$01f00000,bltcon0(a5)		* bltcon0/bltcon1
		move.l	#-1,bltafwm(a5)			* bltafwm/bltalwm
		move.w	#0,bltamod(a5)
		move.w	#0,bltdmod(a5)
TstBBusy2	btst	#14,dmaconr(a5)
		bne.s	TstBBusy2
		move.w	#0,bltadat(a5)
		move.l	a0,bltdpt(a5)
		move.w	#256*64+20,bltsize(a5)
		add.w	#PlaneSize,a0
		dbf	d0,TstBBusy2
		rts

DrawTime	move.l	PlaneAddresses(a6),a1
		add.w	#40*20,a1		* Move down
		add.w	#6*2,a1			* Centre
		move.l	#-1,bltafwm(a5)		* Both masks
		move.l	#$09f00000,bltcon0(a5)	* Both control registers
		move.l	#38,bltamod(a5)		* A mod and D mod
		
		moveq.l	#8-1,d7			* No. of characters
		lea	Time(pc),a2
CharLoop	lea	Font,a0
		moveq.l	#0,d0
		move.b	(a2)+,d0		* String
		subi.w	#32,d0
		rol.w	#5,d0
		add.w	d0,a0			* Font offset
		
TstBlitter	btst	#6,dmaconr(a5)
		bne	TstBlitter
		move.l	a0,bltapt(a5)
		move.l	a1,bltdpt(a5)
		move.w	#16*64+1,bltsize(a5)
		
		addq.l	#2,a1
		dbf	d7,CharLoop
		rts

		even
		
Time		dc.b	'00:00:00'

		even
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		bsr	ClearSprites
		bsr	UpdateCopper
		lea	Time,a0
		move.l	#'00:0',(a0)+
		move.l	#'0:00',(a0)
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
SystemLev2Int	rs.l	1
SystemLev3Int	rs.l	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* × 	Copper list							×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Copper,Data_C

TheCopperList	dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0000,bplcon2,$0000
		dc.w	bpl1mod,0,bpl2mod,0

		dc.w 	bplcon0,$1200

		dc.w	color+$00
Colours		dc.w	$0000,color+$02,$0046,color+$04,$0000,color+$06
		dc.w	$0000,color+$08,$0000,color+$0a,$0000,color+$0c
		dc.w	$0000,color+$0e,$0000,color+$10,$0000,color+$12
		dc.w	$0000,color+$14,$0000,color+$16,$0000,color+$18
		dc.w	$0000,color+$1a,$0000,color+$1c,$0000,color+$1e
		dc.w	$0000
		
		dc.w	sprpt+$00
Sprites		dc.w	$0000,sprpt+$02,$0000,sprpt+$04,$0000,sprpt+$06
		dc.w	$0000,sprpt+$08,$0000,sprpt+$0a,$0000,sprpt+$0c
		dc.w	$0000,sprpt+$0e,$0000,sprpt+$10,$0000,sprpt+$12
		dc.w	$0000,sprpt+$14,$0000,sprpt+$16,$0000,sprpt+$18
		dc.w	$0000,sprpt+$1a,$0000,sprpt+$1c,$0000,sprpt+$1e
		dc.w	$0000

		dc.w	bplpt+$00
Planes 		dc.w 	$0000,bplpt+$02,$0000

		dc.w	$3009,$fffe,color+$00,$0eee
		dc.w	$3109,$fffe,color+$00,$0003
		
		dc.w	$6009,$fffe,color+$00,$0eee
		dc.w	$6109,$fffe,color+$00,$0000
		
     		dc.w	$ffff,$fffe	

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	Choose between two fonts					x
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Font,Data_C

Font		incbin	Df1:Fonts16/Metallion.fnt02
*		incbin	Df1:Fonts16/Metallion.fnt03
	
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		End




