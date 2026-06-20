

*		Processor horizontal colour cycle for ACC by Mike Cross.

*		The flicker lines going down the screen are because
*		the cycle code is too slow!   I will need to use a
*		super charged blitter routine to get rid of them!

*		PD source.


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


BuildCop	lea	Cop,a0
		move.l	#$3b31fffe,d0
		move.l	#$01800000,d1
		move.w	#168-1,d2		* No. of bars
BuildLoop2	moveq.l	#48-1,d3		* Elements in 1 row
		move.l	d0,(a0)+
BuildLoop	move.l	d1,(a0)+
		dbf	d3,BuildLoop
		addi.l	#$01000000,d0
		dbf	d2,BuildLoop2
		
		lea	Cop+4,a0
		move.w	#168-1,d1
CopLoop2	lea	Cols3,a1
		moveq.l	#48-1,d0
CopLoop		move.w	(a1)+,2(a0)
		addq.l	#4,a0
		dbf	d0,CopLoop
		add.w	#4,a0
		dbf	d1,CopLoop2


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


		bsr	Cycle
		
		

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



Cycle		lea	Cop+4,a0
		move.w	#168-1,d1
CycleLoop2	moveq.l	#47-1,d0
		lea	6(a0),a1
		move.w	2(a0),-(sp)
CycleLoop	move.w	(a1),2(a0)
		add.w	#4,a0
		add.w	#4,a1
		dbf	d0,CycleLoop
		move.w	(sp)+,-4(a1)
		add.w	#8,a0
		dbf	d1,CycleLoop2
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

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		bsr.s	ClearSprites
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

TheCopperList	dc.w	diwstrt,$0981,diwstop,$2cc1
		dc.w	ddfstrt,$0038,ddfstop,$00d0
		dc.w	bplcon1,$0000,bplcon2,$0000
		dc.w	bpl1mod,0,bpl2mod,0

		dc.w 	bplcon0,$0200

		dc.w	color+$00
Colours		dc.w	$0000,color+$02,$0fff,color+$04,$0000,color+$06
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

Cop		dcb.b	(192+4)*168
		dc.w	color+$00,$0000

     		dc.w	$ffff,$fffe	


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

Cols1	dc.w	$0111,$0100,$0222,$0200,$0333,$0300,$0444,$0400
	dc.w	$0555,$0500,$0666,$0600,$0777,$0700,$0888,$0800
	dc.w	$0999,$0a00,$0aaa,$0b00,$0bbb,$0c00,$0ccc,$0c00
	dc.w	$0bbb,$0b00,$0aaa,$0a00,$0999,$0900,$0888,$0800
	dc.w	$0777,$0700,$0666,$0600,$0555,$0500,$0444,$0400
	dc.w	$0333,$0300,$0222,$0200,$0111,$0100,$0000,$0000
	
Cols2	dc.w	$0101,$0001,$0202,$0002,$0303,$0003,$0404,$0004
	dc.w	$0505,$0005,$0606,$0006,$0707,$0007,$0808,$0008
	dc.w	$0909,$000a,$0a0a,$000b,$0b0b,$000c,$0c0c,$000c
	dc.w	$0b0b,$000b,$0a0a,$000a,$0909,$0009,$0808,$0008
	dc.w	$0707,$0007,$0606,$0006,$0505,$0005,$0404,$0004
	dc.w	$0303,$0003,$0202,$0002,$0101,$0001,$0000,$0000
	
Cols3	dc.w	$0001,$0002,$0003,$0004,$0005,$0006,$0007,$0008
	dc.w	$0009,$000a,$000b,$000c,$000d,$000c,$000b,$000a
	dc.w	$0009,$0008,$0007,$0006,$0005,$0004,$0003,$0002
	dc.w	$0001,$0002,$0003,$0004,$0005,$0006,$0007,$0008
	dc.w	$0009,$000a,$000b,$000d,$000c,$000b,$000a,$0009
	dc.w	$0008,$0007,$0006,$0005,$0004,$0003,$0002,$0001

Cols4	dc.w	$0100,$0200,$0300,$0400,$0500,$0600,$0700,$0800
	dc.w	$0900,$0a00,$0b00,$0c00,$0d00,$0c00,$0b00,$0a00
	dc.w	$0900,$0800,$0700,$0600,$0500,$0400,$0300,$0200
	dc.w	$0100,$0200,$0300,$0400,$0500,$0600,$0700,$0800
	dc.w	$0900,$0a00,$0b00,$0d00,$0c00,$0b00,$0a00,$0900
	dc.w	$0800,$0700,$0600,$0500,$0400,$0300,$0200,$0100

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		End

	Note.  Format of single raster line is as follows :-

	dc.w	$3031,$fffe	- Start pos
	
	followed by 48 of :-
	
	dc.w	color+$00,$0000
	
	These fill the horizontal line with 'different' colours
		


