; A general hardware safe type base 
; 
; version 2.05 (3/8/93)
;
; © Copyright 1993 Paul Firth.
;
; This version should be system friendly as it
; requests ram, and frees it properly.


		incdir		source:include/
		include		hardware.i
		include		hw_macros.i
		include		sys:include/exec/exec_lib.i
		
;----------------------------------------------------------------------------

x		EQUR		d0
y		EQUR		d1
z		EQUR		d2
xv		EQUR		d3

byte		EQUR		d4
temp		EQUR		d5
bitinbyte	EQUR		d6
pointer		EQUR		a5

value		EQUR		d0
min		EQUR		d1
max		EQUR		d2
seed		EQUR		d3
range		EQUR		d4
bit		EQUR		d5
bits		EQUR		d6

POINTS		EQU		999

PLANE_WIDTH	EQU		40
PLANE_HIGHT	EQU		256
BIT_PLANES	EQU		1
PLANE_SIZE	EQU		PLANE_WIDTH*PLANE_HIGHT*BIT_PLANES
	
SHIFTY		EQU		6

;-----------------------------------------------------------------------------
INITIALISE
		jsr		ALLOC_PLANE_RAM
		jsr		DISABLE_SYSTEM
		jsr		SETUP_MOUSE
		jsr		RUN_COPPER
		jsr		MAIN

		rts
;----------------------------------------------------------------------------
ALLOC_STAR_RAM
		move.l		#((POINTS+1)*3)*4,d0
		moveq.l		#CHIPMEM,d1
		CALLEXEC	AllocMem
		move.l		d0,DATA_POINTER
		beq		EXIT
		rts
;----------------------------------------------------------------------------
ALLOC_PLANE_RAM
		move.l		#PLANE_SIZE,d0
		move.l		#CHIPMEM+CLEARMEM,d1
		CALLEXEC	AllocMem
		move.l		d0,PHYSIC_SCRN
		beq		EXIT
		move.l		#PLANE_SIZE,d0
		move.l		#CHIPMEM+CLEARMEM,d1
		CALLEXEC	AllocMem
		move.l		d0,LOGIC_SCRN
		beq		EXIT
		rts
;----------------------------------------------------------------------------		
DISABLE_SYSTEM
		move.l		#GRAPHICS_NAME,a1		;name of library to open in a1
		moveq.l		#0,d0				;version in d0
		CALLEXEC	OpenLibrary			;do it
		move.l		d0,GFX_BASE			;get graphics base
		beq		FREE_PLANE_RAM			;if couldn't open library, exit
		move.l		GFX_BASE,a1
		move.l		38(a1),SYS_COP			;save system copperlist address

		CALLEXEC	Forbid				;suspend task-switching

		lea		CUSTOM,a0			;custom chips base address in a0

		move.w		DMACONR(a0),SYS_DMA		;save system dma
		move.w		INTENAR(a0),SYS_INT		;save system inturupts
		
		WAITVBL						;wait for vetical blank
		move.l		#NULL_SAMPLE,SPR0PTH(a0)	;shut off sprites
		move.w		#%0111111111111111,DMACON(a0)	;shut off all dma
		move.w		#%0111111111111111,INTENA(a0)	;shut off all interupts not vbl
		
		or.b		#$F8,CIABPRB			;stop
		and.b		#$87,CIABPRB			;drive
		or.b		#$F8,CIABPRB			;motors

		
		rts
;----------------------------------------------------------------------------
RUN_COPPER
		move.w		#SETIT!BPLEN!DMAEN!COPEN,DMACON(a0)	;enable set/clr bit, dma, bpl control and copper
		move.w		#SETIT!INTEN!VERTB,INTENA(a0)
			
		RCOPBPL		COPPER_PLANES,PHYSIC_SCRN,PLANE_SIZE,BIT_PLANES
								;loads copperlist with bitplane pointers
								;pointer to copperplanes, screen base, screen length, bitplanes
		STARTCOP	#COPPER_LIST			;starts copperlist
		rts
;----------------------------------------------------------------------------
CLEAR_SCREEN
		move.l		LOGIC_SCRN,a0			;start of screen in a0
		lea		PLANE_SIZE(a0),a0		;end of screem in a0
		move.w		#255,d0				;number of times to loop-1

		moveq.l		#0,d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		moveq.l		#0,d4
		moveq.l		#0,d5
		moveq.l		#0,d6
		moveq.l		#0,d7
		
		move.l		d1,a1
		move.l		d1,a2
		move.l		d1,a3

.LOOP		
		movem.l		d1-d7/a1-a3,-(a0)		;write 40 bytes
		dbra		d0,.LOOP			;256 times; 10240 bytes is the whole screen	
		rts
;----------------------------------------------------------------------------
MAIN
		btst		#6,CIAAPRA
		beq		ENABLE_SYSTEM
		
HIP
		jsr		CLEAR_SCREEN
		jsr		READ_MOUSE

		SUB.l		#160,NEW_MOUSE_X
		SUB.l		#128,NEW_MOUSE_Y

		move.l		(BUDGIE),d7		
		add.l		d7,(PINHEAD)
		cmp.l		#(10<<6),(PINHEAD)
		blt		PAVLOVA
		move.l		#(10<<6)-1,(PINHEAD)
		neg.l		(BUDGIE)
				
PAVLOVA
		cmp.l		#-(20<<6),(PINHEAD)
		bgt		MOAN
		move.l		#1-(20<<6),(PINHEAD)
		neg.l		(BUDGIE)
		
MOAN
		
		move.l		#-100,d4	
XLOOP
		move.l		#-100,d5

YLOOP
		move.L		#10,d6

ZLOOP
		move.l		NEW_MOUSE_X,x
		move.l		NEW_MOUSE_Y,y
		add.l		d4,x
		add.l		d5,y
		move.l		d6,z

		asl.l		#SHIFTY,x
		asl.l		#SHIFTY,y
		asl.l		#SHIFTY,z
	
		jsr		DOT
	
		subq.l		#1,d6
		cmpi.l		#1,d6
		bge		ZLOOP
		
		add.l		#50,d5
		cmpi.l		#100,d5
		ble		YLOOP
		
		add.l		#50,d4
		cmpi.l		#100,d4
		ble		XLOOP
		
		jsr		SWAP_SCREENS
		WAITVBL
			
		
		bra		MAIN
;----------------------------------------------------------------------------
MOST
		add.w		#1,(DIST)
		bra		HIP


SETUP_MOUSE
		PUSH	d0-d1
    
    		move.w  JOY0DAT+CUSTOM,D0
    		and.w   #$00ff,D0
    		move.w  D0,OLD_MOUSE_X
    		move.w  JOY0DAT+CUSTOM,D0
    		move.w  #8,D1
    		lsr.w   D1,D0
    		move.w  D0,OLD_MOUSE_Y
    		PULL	d0-d1
    		rts

READ_MOUSE
		move.w	JOY0DAT+CUSTOM,D0
		and.w	#$00ff,D0
		
		move.w	OLD_MOUSE_X,D1
		move.w	D0,OLD_MOUSE_X
		
		sub.w	D1,D0
		cmp.w	#127,D0
		ble.s	.NO_X_SUB
		sub.w	#256,D0
		
.NO_X_SUB
		cmp.w	#-127,D0
		bge.s	.NO_X_ADD
		add.w	#256,D0
		
.NO_X_ADD 
   		add.w	BIG_MOUSE_X,D0
		bpl.s	.X_IS_PLUS
		move.w  #0,D0
		
.X_IS_PLUS  
  		cmp.w	#639,D0
		ble.s	.X_IN_BOUNDS
		move.w	#639,D0
		
.X_IN_BOUNDS    
		move.w	D0,BIG_MOUSE_X
		lsr.w	#1,D0
		move.l	D0,NEW_MOUSE_X
		
		move.w	JOY0DAT+CUSTOM,D0
		move.w	#8,D1
		
		lsr.w	D1,D0

		move.w	OLD_MOUSE_Y,D1
		move.w	D0,OLD_MOUSE_Y

		sub.w	D1,D0
		cmp.w	#127,D0
		ble.s	.NO_Y_SUB

		sub.w	#256,D0
		
.NO_Y_SUB
		cmp.w	#-127,D0
		bge.s	.NO_Y_ADD
		add.w	#256,D0
		
.NO_Y_ADD
		add.w	BIG_MOUSE_Y,D0
		bpl.s	.Y_IS_PLUS
		move.w	#0,D0
		
.Y_IS_PLUS    
		cmp.w	MOUSE_LIMIT,D0
		ble	.Y_IN_BOUNDS
		move.w	MOUSE_LIMIT,D0
		
.Y_IN_BOUNDS
		move.w	D0,BIG_MOUSE_Y
		lsr.w	#1,D0
		move.l	d0,NEW_MOUSE_Y
		rts
;----------------------------------------------------------------------------		
DOT
		move.l		(PINHEAD),d7
		sub.l		d7,z		
		cmp.l		#0,z
		ble		COLIN
		
		asl.l		#SHIFTY,x
		divs.w		z,x
		muls.w		(DIST),x
		asr.l		#SHIFTY,x
		add.l		#160,x

		asl.l		#SHIFTY,y		
		divs.w		z,y
		muls.w		(DIST),y
		asr.l		#SHIFTY,y
		add.l		#128,y

		PUSH		d4-d6		
		jsr		PLOT
		PULL		d4-d6

COLIN		
		rts
;----------------------------------------------------------------------------
COPPER_LIST
		CMOVE		DIWSTRT,$2C81
		CMOVE		DIWSTOP,$2CC1
		CMOVE		DDFSTRT,$0038
		CMOVE		DDFSTOP,$00D0
		CMOVE		BPLCON0,$1200
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000
		
COPPER_PLANES
		CMOVE		BPL1PTH,0
		CMOVE		BPL1PTL,0

		CMOVE		BPLCON3,$0000			;first clear bit 9 of bplcon3
		CMOVE		COLOR00,$0000			;then move high nibbles of each colour into color00
		CMOVE		BPLCON3,$0200			;now set bit 9 of bplcon3
		CMOVE		COLOR00,$0000			;then move low nibbles of each colour into color00
		
		CMOVE		BPLCON3,$0000			;note: colour definitions go after screen!!
		CMOVE		COLOR01,$0FFF
		CMOVE		BPLCON3,$0200
		CMOVE		COLOR01,$0FFF
		
		CEND
;----------------------------------------------------------------------------
PLOT
		cmpi.l		#320,x
		bge		TO_MUCH
		cmpi.l		#-1,x
		ble		TO_MUCH
		cmpi.l		#256,y
		bge		TO_MUCH
		cmpi.l		#-1,y
		ble		TO_MUCH
		
		move.l		x,byte
		lsr.l		#3,byte

		move.l		byte,temp
		lsl.l		#3,temp
		move.l		x,bitinbyte
		sub.l		temp,bitinbyte

		move.l		LOGIC_SCRN,pointer
	
		move.l		y,temp
		lsl.l		#2,temp
		add.l   	y,temp
		lsl.l		#3,temp
		
		add.l		temp,pointer
		add.l		byte,pointer
		neg.l		bitinbyte
		addq.l		#7,bitinbyte

		bset.b		bitinbyte,(pointer)
		rts
		
TO_MUCH
		rts		
;----------------------------------------------------------------------------
ENABLE_SYSTEM
		lea		CUSTOM,a0			;get custom chip base

		move.w		SYS_INT,d0			;put system's interupts in d0
		or.w		#SETIT!INTEN,d0			;add set/clr and enable bits
		move.w		d0,INTENA(a0)			;do it
		
		move.w		SYS_DMA,d0			;put system's dma in d0
		or.w		#SETIT!DMAEN,d0			;add set/clr and enable bits
		move.w		d0,DMACON(a0)			;do it

		STARTCOP	SYS_COP				;start system's copper

		CALLEXEC	Permit				;restart task-switching
		
		move.l		GFX_BASE,a1			;base of graphics library in a1
		CALLEXEC	CloseLibrary			;close it

FREE_PLANE_RAM
		move.l		LOGIC_SCRN,a1			;address of screen in a1
		move.l		#PLANE_SIZE,d0			;size in d0
		CALLEXEC	FreeMem				;free ram
		
		move.l		PHYSIC_SCRN,a1
		move.l		#PLANE_SIZE,d0
		CALLEXEC	FreeMem		
		
EXIT
		clr.l		d0				;so no return code generated
		rts
;----------------------------------------------------------------------------
SWAP_SCREENS
		move.l		LOGIC_SCRN,a0
		move.l		PHYSIC_SCRN,LOGIC_SCRN
		
		move.l		a0,PHYSIC_SCRN
		
		RCOPBPL		COPPER_PLANES,PHYSIC_SCRN,PLANE_SIZE,BIT_PLANES
		rts
;----------------------------------------------------------------------------		
OLD_MOUSE_X	dc.w		0
OLD_MOUSE_Y	dc.w		0
BIG_MOUSE_X	dc.w		0
BIG_MOUSE_Y	dc.w		0
NEW_MOUSE_X	dc.l		0
NEW_MOUSE_Y	dc.l		0
MOUSE_LIMIT	dc.w		510

NULL_SAMPLE
		dc.l		0
		dc.l		0
		
DATA_POINTER	ds.l		1
DIST		dc.w		9


PINHEAD		dc.l     	-(40<<6)
BUDGIE		dc.l		(1<<2)

RANDOM_DATA	ds.l		1

PHYSIC_SCRN	ds.l		1
LOGIC_SCRN	ds.l		1

SYS_DMA		ds.w		1
SYS_INT		ds.w		1
SYS_COP		ds.l		1

GFX_BASE	ds.l		1
GRAPHICS_NAME	dc.b		'graphics.library',0