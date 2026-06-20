

;--------------
;--------------	Faster library calling routine for repeat calls to same lib
;--------------


CALLSYS		macro
		ifgt		NARG-1
		FAIL
		endc
		jsr		_LVO\1(a6)
		endm

;--------------
;--------------	A macro to simplify calling OpenAWin subroutine
;--------------

; Read doc file for information on usage.

; Preserves all registers except d0. After macro, d0=0 if window failed to
;open.

; Allocates a small block of memory and fills in with appropriate values.
; Memory is released at end of macro.
; If unable to allocate memory ( 24bytes ), no chance of opening a window,
;so the routine aborts with d0=0.


OPENWIN		MACRO		NewWindow,IText,Image,Border,MenuStrip,Screen

		movem.l		d1-d7/a0-a6,-(sp)	save
		
		moveq.l		#24,d0			6 long words
		move.l		#MEMF_CLEAR,d1		init to NULL's
		CALLEXEC	AllocMem		and allocate it
		move.l		d0,d7			save address
		beq.s		\@			quit if error
		
		move.l		d0,a0			a0->mem block
		move.l		\1,(a0)		NewWindow
		
		IFNC		'','\2'			IText
		move.l		\2,4(a0)
		ENDC

		IFNC		'','\3'			Image
		move.l		\3,8(a0)
		ENDC

		IFNC		'','\4'			Border
		move.l		\4,12(a0)
		ENDC

		IFNC		'','\5'			MenuStrip
		move.l		\5,16(a0)
		ENDC

		IFNC		'','\6'			Screen
		move.l		\6,20(a0)
		ENDC

		bsr		OpenAWin		open the window

		move.l		d0,-(sp)		save returned value

		move.l		d7,a1			a1->memory
		moveq.l		#24,d0			size
		CALLEXEC	FreeMem			release it

		movem.l		(sp)+,d0		get Window pointer

\@		movem.l		(sp)+,d1-d7/a0-a6	restore

		ENDM

;--------------
;--------------	A macro to simplify calling OpenSBWin subroutine
;--------------

; Read doc file for information on usage.

; Preserves all registers except d0. After macro, d0=0 if window failed to
;open.

; Allocates a small block of memory and fills in with appropriate values.
; Memory is released at end of macro.
; If unable to allocate memory ( 24 bytes ), no chance of opening a window,
;so the routine aborts with d0=0.

; OPENSBWIN    NewWindow,BitMap,{IText},{Image},{Border},{MenuStrip},{Screen}


OPENSBWIN	MACRO

		movem.l		d1-d7/a0-a6,-(sp)	save
		
		moveq.l		#24,d0			6 long words
		move.l		#MEMF_CLEAR,d1		init to NULL's
		CALLEXEC	AllocMem		and allocate it
		move.l		d0,d7			save address
		beq.s		\@			quit if error
		
		move.l		d0,a0			a0->mem block
		
		move.l		\1,a1			NewWindow
		move.l		\2,nw_BitMap(a1)	link BitMap-NewWindow
		move.l		a1,(a0)
		
		IFNC		'','\3'			IText
		move.l		\3,4(a0)
		ENDC

		IFNC		'','\4'			Image
		move.l		\4,8(a0)
		ENDC

		IFNC		'','\5'			Border
		move.l		\5,12(a0)
		ENDC

		IFNC		'','\6'			MenuStrip
		move.l		\6,16(a0)
		ENDC

		IFNC		'','\7'			Screen
		move.l		\7,20(a0)
		ENDC

		bsr		OpenAWin		open the window

		move.l		d0,-(sp)		save returned value

		move.l		d7,a1			a1->memory
		moveq.l		#24,d0			size
		CALLEXEC	FreeMem			release it

		movem.l		(sp)+,d0		get Window pointer

\@		movem.l		(sp)+,d1-d7/a0-a6	restore

		ENDM

;--------------
;--------------	Macro for closing a window
;--------------

; CLOSEWIN	Window

CLOSEWIN	macro

		move.l		\1,a0
		bsr		CloseWin
		
		endm

;--------------
;--------------	Macro to deal with IDCMP communication for a given window
;--------------

; HANDLEIDCMP	Window,{ServerRoutine}

HANDLEIDCMP	MACRO

		move.l		\1,a4
		
		move.l		_menuptr,-(sp)
		move.l		wd_MenuStrip(a4),_menuptr
		
		move.l		wd_UserPort(a4),a4	a4->UserPort
		
		IFC		'','\2'
		suba.l		a3,a3			no server
		ENDC
		
		IFNC		'','\2'
		move.l		\2,a3
		ENDC
		
		bsr		_WFM			handle the port
		
		move.l		(sp)+,_menuptr
		
		ENDM

;--------------
;--------------	Macro to allocate and initialise a BitMap structure
;--------------

; Note, allocates mem for the planes as well.

; BITMAP	Width,Height,Depth

BITMAP		MACRO
		move.l		\1,d0
		move.l		\2,d1
		move.l		\3,d2
		bsr		GetBitMap
		ENDM
		
;--------------
;--------------	Macro to free all memory tied up in a BitMap structure
;-------------- allocated using BITMAP.

; FREEBITMAP	BitMap

FREEBITMAP	MACRO
		move.l		\1,a0
		bsr		FreeBitMap
		ENDM

;--------------
;--------------	Macro to save a few variables from Window structure
;--------------

; See doc file for notes on using this macro.

; GETWINVARS	Window,Label

GETWINVARS	MACRO		Window,label

		move.l		a0,-(sp)
		move.l		\1,a0
		move.l		wd_RPort(a0),\2.rp
		move.l		wd_UserPort(a0),\2.up
		move.l		a0,\2.ptr
		move.l		(sp)+,a0
		
		ENDM
		
;--------------
;--------------	Macro for opening a screen and setting its palette
;--------------

; OPENSCREEN	NewScreen,{Palette}

OPENSCREEN	MACRO

		move.l		\1,a0
		
		IFC		'','\2'
		suba.l		a1,a1
		ENDC
		IFNC		'','\2'
		move.l		\2,a1
		ENDC
		
		bsr		OpenScrn
		
		ENDM

;--------------
;--------------	Macro for closing a screen
;--------------

; CLOSESCREEN	Screen

CLOSESCREEN	macro

		move.l		\1,a0
		bsr		CloseScrn
		
		endm

;--------------
;--------------	Macro for fading an Intuition screen to black
;--------------

; FADEOUT	Screen

FADEOUT		macro
		move.l		\1,a0			a0->Screen
		bsr		FadeOut			blank the screen
		endm

;--------------
;--------------	Macro for fading an Intuition screen from black
;--------------

; FADEIN	Screen,Palette

FADEIN		macro
		move.l		\1,a0			a0->Screen
		move.l		\2,a1			a1->colour table
		bsr		FadeIn
		endm

