
*		Simple 1 pixel starfield by Mike Cross - August1991

*		Coded for ACC.  This Source is PD - Use and abuse at will.


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

NumberOfStars	equ	127
Max_Speed	equ	4

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
		move.w  #DMAF_SETCLR!DMAF_MASTER!DMAF_RASTER!DMAF_SPRITE!DMAF_COPPER,dmacon(a5)	

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
		move.l	SystemLev2Int(a6),$68.w
		move.l	SystemLev3Int(a6),$6c.w
		CALLSYS	Permit
		move.l 	SystemCopper(a6),cop1lc(a5)
		move.l	ScreenMemory(a6),a1
		move.l	#PlaneSize*NumberOfPlanes,d0
		CALLSYS	FreeMem
Exit		movem.l (sp)+,d0-d7/a0-a6
		rts



MoveStar	lea	StarSprite,a0
		move.w	#NumberOfStars-1,d0	
		moveq.b	#2,d1			* Speed counter	
StarLoop	sub.b	d1,1(a0)
		add.w	#8,a0
		addq.b	#1,d1
		cmpi.b	#Max_Speed,d1
		ble	SpeedOkay
		moveq.b	#2,d1	
SpeedOkay	dbf	d0,StarLoop
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

LoadSprite	move.l	#StarSprite,d0
		lea	Sprites,a0
		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		rts

MakeStars	lea	StarSprite,a0
		move.w	#NumberOfStars-1,d7
		move.w	#$20,d0			* Start Y position
		move.w	#1,d1
		moveq.l	#0,d2
		
		move.w	#$321f,d3
		move.w	#$5512,d5
MakeLoop	move.w	vhposr(a5),d4		* Random No. from beam pos'
		or.l	d3,d5
		add.l	d4,d5
		
		move.b	d0,(a0)+
		move.b	d5,(a0)+		* Random X Position
		
		add.w	#1,d0
		move.b	d0,(a0)+		* Second control word
		move.b	d2,(a0)+
		
		move.w	d1,(a0)+		* Gfx Data
		move.w	#1,(a0)+
		eori.w	#1,d1
		
		addq.b	#1,d0
		
		cmpi.w	#238,d0
		bls	Okay
		
		move.w	#0,d0
		move.w	#6,d2	
		
Okay		dbf	d7,MakeLoop
		rts
		
	
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		bsr	ClearSprites
		bsr	LoadSprite
		bsr	MakeStars
		bsr	UpdateCopper
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

		dc.w	color+$00,$0000,color+$02,$0fff
		
		dc.w	color+$20,$0000,color+$22,$0fff
		dc.w	color+$24,$0aaa,color+$26,$0666
		
		dc.w	sprpt+$00
Sprites		dc.w	$0000,sprpt+$02,$0000,sprpt+$04,$0000,sprpt+$06
		dc.w	$0000,sprpt+$08,$0000,sprpt+$0a,$0000,sprpt+$0c
		dc.w	$0000,sprpt+$0e,$0000,sprpt+$10,$0000,sprpt+$12
		dc.w	$0000,sprpt+$14,$0000,sprpt+$16,$0000,sprpt+$18
		dc.w	$0000,sprpt+$1a,$0000,sprpt+$1c,$0000,sprpt+$1e
		dc.w	$0000

		dc.w	bplpt+$00
Planes 		dc.w 	$0000,bplpt+$02,$0000

		
     		dc.w	$ffff,$fffe	


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

StarSprite	dcb.w	4*NumberOfStars,0

			
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		End

	
		
		
		
		
		


		



