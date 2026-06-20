
; This program demonstrates how to set up a custom bitmap screen and load
;a raw data picture file into it. Yes ! its my Postman Pat picture again.

; M.Meany 1990

		opt 		o+,ow-

		incdir		":include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"exec/ports.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		
ciaapra		equ		$bfe001
NULL		equ		0

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things

start		OPENARP				
		movem.l		(sp)+,d0/a0	
						
						
		move.l		a6,_ArpBase	
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use.

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase
		
		bsr		screen

;--------------	Close the ARP library, this closes Intuition + Graphics libs.

		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary
		rts
*****************************************************************************
;------------------------------	SUBROUTINES
*****************************************************************************

;-------------- Open the intuition screen.

screen		

; First we must set up a custom bit map structure.
; See the file  Include/graphics/gfx.i for more info on structure.
		
		lea		bitmap,a0	a0->uninitialised bm struct
		move.l		a0,a3		store a copy for later
		moveq.l		#5,d0		d0=screen depth
		move.l		#320,d1		d1=screen width
		move.l		#200,d2		d2=screen height
		CALLGRAF	InitBitMap

; Now copy address of each bitplane into the bitmap structure.

		move.l		a3,a0		a0->bitmap structure
		add.l		#bm_Planes,a0	a0->addr of plane pointers
		move.l		#Picture,d0	d0=addr of picture
		move.l		#(320/8)*200,d1	d1=size of each plane
		moveq.l		#4,d2		d2=num of planes - 1
loop		move.l		d0,(a0)+	addr of next plane into struct
		add.l		d1,d0		d0=addr of next plane
		dbra		d2,loop		for all planes
		move.l		d0,a3		a3->colours
		
; Open the screen

		lea		custom_screen,a0 a0->new screen structure
		CALLINT		OpenScreen	open the screen
		move.l		d0,screen.ptr	store pointer returned
		beq.s		error1		leave if screen failed to open
		
; Load correct colours into this screens viewport.

		move.l		d0,a0		a0->screen structure
		add.l		#sc_ViewPort,a0 a0->screens viewport struct
		move.l		a3,a1		a1->colours
		moveq.l		#32,d0		d0=number of colours
		CALLGRAF	LoadRGB4
		
; Wait for 5 seconds

		move.l		#5*50,d1	d1=time in 1/50 seconds
		CALLARP		Delay		call delay routine
		
; Close the screen

		move.l		screen.ptr,a0	a0->screen 
		CALLINT		CloseScreen	and close it

error1		rts

*****************************************************************************
;------------------------------	DATA
*****************************************************************************

;-------------- Data Section

custom_screen	dc.w		0,0		x,y starting position
		dc.w		320,200		width,height
		dc.w		5		depth
		dc.b		0,0		fgr pen,bgr pen
		dc.w		2		normal mode
		dc.w		CUSTOMSCREEN!CUSTOMBITMAP	screen type
		dc.l		0		standard font
		dc.l		0		no title
		dc.l		0		no gadgets
		dc.l		bitmap		addr of bitmap struct
		
		section		piccy,bss

_ArpBase	ds.l		1
_GfxBase	ds.l		1
_IntuitionBase	ds.l		1

screen.ptr	ds.l		1

bitmap		ds.b		bm_SIZEOF
		even
		
		section		pic,code_c
		
Picture		incbin		'workdisk:bitmaps/piccy.bm'
