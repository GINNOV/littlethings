; An AGA test program. 
; 
; version 3.00 (7/9/93)
;
; © Copyright 1993 Paul Firth.
;

		incdir		source:include/
		include		hardware.i
		include		hw_macros.i
		include		sys:include/exec/exec_lib.i
		
;----------------------------------------------------------------------------
PLANE_WIDTH	EQU		40
PLANE_HIGHT	EQU		256
PLANE_AREA	EQU		PLANE_WIDTH*PLANE_HIGHT

BIT_PLANES	EQU		8
PLANE_SIZE	EQU		PLANE_AREA*BIT_PLANES
;-----------------------------------------------------------------------------
INITIALISE
		jsr		DISABLE_SYSTEM
		jsr		RUN_COPPER
		jsr		MAIN

		rts
;----------------------------------------------------------------------------		
DISABLE_SYSTEM
		move.l		#GRAPHICS_NAME,a1		;name of library to open in a1
		moveq.l		#0,d0				;version in d0
		CALLEXEC	OpenLibrary			;do it
		move.l		d0,GFX_BASE			;get graphics base
		beq		EXIT				;if couldn't open library, exit
		move.l		GFX_BASE,a1
		move.l		38(a1),SYS_COP			;save system copperlist address

		CALLEXEC	Forbid				;suspend task-switching

		move.w		DMACONR+CUSTOM,SYS_DMA		;save system dma
		move.w		INTENAR+CUSTOM,SYS_INT		;save system inturupts
		
		WAITVBL						;wait for vetical blank
		move.l		#BLANK,SPR0PTH+CUSTOM		;shut off sprites
		move.w		#$7FFF,DMACON+CUSTOM		;shut off all dma
		move.w		#$7FFF,INTENA+CUSTOM		;shut off all interupts not vbl
		
		or.b		#$F8,CIABPRB			;stop
		and.b		#$87,CIABPRB			;drive
		or.b		#$F8,CIABPRB			;motors
		rts
;----------------------------------------------------------------------------
RUN_COPPER
		move.w		#SETIT!DMAEN!BPLEN!COPEN,DMACON+CUSTOM			
		COPBPL		COPPER_PLANES,PICTURE,PLANE_AREA,BIT_PLANES

		STARTCOP	#COPPER_LIST
		rts
;----------------------------------------------------------------------------
MAIN
		btst		#6,CIAAPRA
		beq		ENABLE_SYSTEM

		bra.s		MAIN
;----------------------------------------------------------------------------
COPPER_LIST	CMOVE		DIWSTRT,$2C81
		CMOVE		DIWSTOP,$2CC1
		CMOVE		DDFSTRT,$0038
		CMOVE		DDFSTOP,$00D0
		CMOVE		BPLCON0,$0210			;8 planes + colour
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000
		
COPPER_PLANES	CMOVE		BPL1PTH,$0000
		CMOVE		BPL1PTL,$0000
		CMOVE		BPL2PTH,$0000
		CMOVE		BPL2PTL,$0000
		CMOVE		BPL3PTH,$0000
		CMOVE		BPL3PTL,$0000
		CMOVE		BPL4PTH,$0000
		CMOVE		BPL4PTL,$0000
		CMOVE		BPL5PTH,$0000
		CMOVE		BPL5PTL,$0000
		CMOVE		BPL6PTH,$0000
		CMOVE		BPL6PTL,$0000
		CMOVE		BPL7PTH,$0000
		CMOVE		BPL7PTL,$0000
		CMOVE		BPL8PTH,$0000
		CMOVE		BPL8PTL,$0000

		incbin		work:programming/machinecode/hardware/myroutines/development/e.cop
		
		CEND
;----------------------------------------------------------------------------
ENABLE_SYSTEM
		move.w		SYS_INT,d0			;put system's interupts in d0
		or.w		#SETIT!INTEN,d0			;add set/clr and enable bits
		move.w		d0,INTENA+CUSTOM		;do it
		
		move.w		SYS_DMA,d0			;put system's dma in d0
		or.w		#SETIT!DMAEN,d0			;add set/clr and enable bits
		move.w		d0,DMACON+CUSTOM		;do it

		STARTCOP	SYS_COP				;start system's copper

		CALLEXEC	Permit				;restart task-switching
		
		move.l		GFX_BASE,a1			;base of graphics library in a1
		CALLEXEC	CloseLibrary			;close it

EXIT
		clr.l		d0				;so no return code generated
		rts
;----------------------------------------------------------------------------		
BLANK		dc.l		0,0

PICTURE		INCBIN	WORK:programming/machinecode/hardware/myroutines/development/e

SYS_DMA		ds.w		1
SYS_INT		ds.w		1
SYS_COP		ds.l		1

GFX_BASE	ds.l		1
GRAPHICS_NAME	dc.b		'graphics.library',0