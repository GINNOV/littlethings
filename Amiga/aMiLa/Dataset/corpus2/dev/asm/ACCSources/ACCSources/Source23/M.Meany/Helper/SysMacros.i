

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

; HANDLEIDCMP	{ServerRoutine}

HANDLEIDCMP	MACRO

		IFC		'','\1'
		suba.l		a3,a3			no server
		ENDC
		
		IFNC		'','\1'
		move.l		\1,a3
		ENDC
		
		bsr		_WFM			handle the port
		
		ENDM
