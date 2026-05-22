
*	More copper cycling by Mike Cross.  June 1991.


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
		

		addi.w	#1,Delay(a6)
		
		
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
Exit		movem.l (sp)+,d0-d7/a0-a6
		rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×		Cycle copper basr behind logo				×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

Cycle		cmpi.w	#50,Delay(a6)
		ble.s	NotYet
		lea	CopStart,a0
		lea	8(a0),a1		* Bar 2
		
		move.w	6(a0),-(sp)
CycleLoop	move.w	6(a1),6(a0)
		add.w	#8,a0
		add.w	#8,a1
		cmp.l	#CopEnd,a1
		blt.s	CycleLoop
		move.w	(sp)+,-2(a1)
NotYet		rts


BuildCopperBars	lea	CopStart,a0		* Build copper bars
		lea	CopColours,a1
		lea	CopColours2,a2
		move.l	#28-1,d7
		move.l	#$3a09fffe,d0
		
CopLoop		move.l	d0,(a0)+
		move.w	#color+$00,(a0)+
		move.w	(a1)+,(a0)+
		addi.l	#$03000000,d0
		
		move.l	d0,(a0)+
		move.w	#color+$00,(a0)+
		move.w	(a2)+,(a0)+
		addi.l	#$03000000,d0
		dbf	d7,CopLoop
		rts


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		move.w	#0,Delay(a6)
		bsr	BuildCopperBars
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


SystemCopper	rs.l	1
SystemDma	rs.w	1
SystemInts	rs.w	1
SystemLev2Int	rs.l	1
SystemLev3Int	rs.l	1
Delay		rs.w	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* × 	Copper list							×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Copper,Data_C

TheCopperList	dc.w	diwstrt,$2c81,diwstop,$2cc1
		dc.w	ddfstrt,$0030,ddfstop,$00d0
		dc.w	bplcon1
ScrollRegister	dc.w	$0000,bplcon2,$0000
		dc.w	bpl1mod,38,bpl2mod,38
		dc.w 	bplcon0,$0200

		dc.w	$3909,$fffe,color+$00,$0fff
		
CopStart	dcb.b	56*8,0

CopEnd		dc.w	color+$00,$0fff
		dc.w	bplcon0,$0200
		
		dc.w	$e009,$fffe,color+$00,$0000
		
     		dc.w	$ffff,$fffe	


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

CopColours	dc.w	$100,$200,$300,$400,$500,$600,$700
		dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
		dc.w	$e00,$d00,$c00,$b00,$a00,$900,$800,$700
		dc.w	$600,$500,$400,$300,$200,$100,$000

CopColours2	dc.w	$111,$222,$333,$444,$555,$666,$777
		dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
		dc.w	$eee,$ddd,$ccc,$bbb,$aaa,$999,$888,$777
		dc.w	$666,$555,$444,$333,$222,$111,$000


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
		
		End

