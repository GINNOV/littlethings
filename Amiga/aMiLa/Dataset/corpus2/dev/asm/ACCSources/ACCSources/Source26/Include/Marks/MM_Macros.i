

; Include files required by these macros. Only included in ACC distribution
;so that examples will assemble without alteration. In practise the required
;files should be included at the start of your file.

		incdir		sys:include/		devpac2
;		incdir		sys:include2.0/		devpac3

		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		graphics/gfx.i
		include		graphics/graphics_lib.i
		include		graphics/view.i


*****************************************************************************

;--------------
;--------------	Faster library calling routine for repeat calls to same lib
;--------------


CALLSYS		macro
		ifgt		NARG-1
		FAIL
		endc
		jsr		_LVO\1(a6)
		endm

*****************************************************************************

		************************************
		*     Library Opening Macros	   *
		************************************

*****************************************************************************

* All library opening macros can be followed by an optional version number,
* eg. OPENDOS 37.
* The library opening macros depend on the CLEANUP macro to make a clean
* exit in the case of an error.

OPENDOS		macro		[version]

MMDOSOPENED	SET		1

		lea		dosname,a1

		IFC		'','\1'
		moveq.l		#0,d0
		ENDC

		IFNC		'','\1'
		move.l		#\1,d0
		ENDC

		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		MVM_Exit

		CALLDOS		Input
		move.l		d0,MM_std_in
		CALLDOS		Output
		move.l		d0,MM_std_out
		endm

*****************************************************************************

OPENINT		macro		[version]
		lea		intname,a1

		IFC		'','\1'
		moveq.l		#0,d0
		ENDC

		IFNC		'','\1'
		move.l		#\1,d0
		ENDC

		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		beq		MVM_Exit
		endm

*****************************************************************************

OPENGFX		macro		[version]
		lea		gfxname,a1

		IFC		'','\1'
		moveq.l		#0,d0
		ENDC

		IFNC		'','\1'
		move.l		#\1,d0
		ENDC

		CALLEXEC	OpenLibrary
		move.l		d0,_GfxBase
		beq		MVM_Exit
		endm

*****************************************************************************

OPENLAYER	macro		[version]
		lea		layername,a1

		IFC		'','\1'
		moveq.l		#0,d0
		ENDC

		IFNC		'','\1'
		move.l		#\1,d0
		ENDC

		CALLEXEC	OpenLibrary
		move.l		d0,_LayerBase
		beq		MVM_Exit
		endm

*****************************************************************************

* This macro closes all open libraries and exits program with optional error
* code. It is also responsible for loading in all required subroutine files
* as required. The macros themselves set flags that control which files are
* included.

CLEANUP		macro		[error code]

MVM_Exit	move.l		_DOSBase,d0
		beq		.a
		move.l		d0,a1
		CALLEXEC	CloseLibrary

.a		move.l		_IntuitionBase,d0
		beq		.bb
		move.l		d0,a1
		CALLEXEC	CloseLibrary


.bb		move.l		_GfxBase,d0
		beq		.c
		move.l		d0,a1
		CALLEXEC	CloseLibrary

.c		move.l		_LayerBase,d0
		beq		.d
		move.l		d0,a1
		CALLEXEC	CloseLibrary

		IFC		'','\1'
.d		moveq.l		#0,d0
		ENDC

		IFNC		'','\1'
.d		move.l		\1,d0
		ENDC

		rts

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

intname		dc.b		'intuition.library',0
		even
_IntuitionBase	dc.l		0

gfxname		dc.b		'graphics.library',0
		even
_GfxBase	dc.l		0

layername	dc.b		'layers.library',0
		even
_LayerBase	dc.l		0

		IFD		MMDOSOPENED

MM_std_in	dc.l		0
MM_std_out	dc.l		0
		ENDC

		ENDM

*****************************************************************************

		************************************
		*     String Handling Macros	   *
		************************************

*****************************************************************************

STRLEN		MACRO		string

MMStrLen	SET		1

		move.l		a0,-(sp)	save registers

		move.l		\1,-(sp)	addr onto stack
		jsr		MM_StrLen	call routine
		
		lea		4(sp),sp	clear stack
		
		move.l		(sp)+,a0	retrieve register
		
		ENDM

*****************************************************************************

STRCPY		MACRO		src, dest

MMStrCpy	SET		1

		move.l		a0,-(sp)	preserve registers
		move.l		a1,-(sp)
		
		move.l		\2,-(sp)	stuff params onto stack
		move.l		\1,-(sp)
		jsr		MM_StrCpy	call subroutine
		
		lea		8(sp),sp	clear stack
		move.l		(sp)+,a1	restore registers
		move.l		(sp)+,a0
		ENDM

*****************************************************************************

TOUPPER		MACRO		string

MMToUpper	SET		1

		move.l		a0,-(sp)	save register
		move.l		\1,-(sp)	param onto stack
		jsr		MM_ToUpper	call routine
		lea		4(sp),sp	flush stack
		move.l		(sp)+,a0	restore register
		
		ENDM

*****************************************************************************

TOLOWER		MACRO		string

MMToLower	SET		1

		move.l		a0,-(sp)	save register
		move.l		\1,-(sp)	param onto stack
		jsr		MM_ToLower	call routine
		lea		4(sp),sp	flush stack
		move.l		(sp)+,a0	restore register
		
		ENDM

*****************************************************************************

STRCMP		MACRO		string1,string2

MMStrCmp	SET		1

		movem.l		d1-d2/a0-a2,-(sp)	save registers
		move.l		\2,-(sp)		params onto stack
		move.l		\1,-(sp)
		jsr		MM_StrCmp		call routine
		lea		8(sp),sp		restore stack
		movem.l		(sp)+,d1-d2/a0-a2	restore registers
		
		ENDM

*****************************************************************************

; This macro preserves all registers since an external subroutine can be
;called, the effect of which cannot be known.

CASESTR		MACRO		string,ActionTable

MMCaseStr	SET		1
MMStrCmp	SET		1

		movem.l		d0-d7/a0-a6,-(sp)	save em all
		move.l		\2,-(sp)		params onto stack
		move.l		\1,-(sp)
		jsr		MM_CaseStr		call routine
		lea		8(sp),sp		flush stack
		movem.l		(sp)+,d0-d7/a0-a6	restore
		
		ENDM

*****************************************************************************

FINDS		MACRO		string,str_len,memory,mem_len

MMFindSame	SET		1

		movem.l		d1-d3/a0-a2,-(sp)	save em
		move.l		\4,-(sp)		params onto stack
		move.l		\3,-(sp)
		move.l		\2,-(sp)
		move.l		\1,-(sp)
		jsr		MM_FindSame		call routine
		lea		16(sp),sp		flush stack
		movem.l		(sp)+,d1-d3/a0-a2	restore em
		
		ENDM

*****************************************************************************

		************************************
		*        DOS Library Macros	   *
		************************************

*****************************************************************************

; Write a NULL terminated string into an open file. If no file handle is
;supplied, will attempt to use CLI handle.

PUTSTR		MACRO		string,{handle}

MMPutStr	SET		1

		movem.l		d0-d3/a0/a1/a6,-(sp)	save em
		
		IFC		'','\2'
		move.l		MM_std_out,-(sp)	CLI handle
		ENDC
		
		IFNC		'','\2'
		move.l		\2,-(sp)		user file
		ENDC
		
		move.l		\1,-(sp)		addr of text
		jsr		MM_PutStr		write it
		lea		8(sp),sp		flush stack
		movem.l		(sp)+,d0-d3/a0/a1/a6	restore em
		
		ENDM
		
*****************************************************************************

; determine the length of a file given it's length

FILELEN		MACRO		filename

MMFileLen	SET		1

		movem.l		d1-d4/a0/a1/a6,-(sp)	save em
		move.l		\1,-(sp)		param onto stack
		jsr		MM_FileLen		get length
		lea		4(sp),sp		flush stack
		movem.l		(sp)+,d1-d4/a0/a1/a6	restore
		
		ENDM
		
*****************************************************************************

; Determine the length of a file that is already open

OFILELEN	MACRO		handle

MMOFileLen	SET		1

		movem.l		d1-d4/a0/a1/a6,-(sp)	save em
		move.l		\1,-(sp)		params onto stack
		jsr		MM_OFileLen		get length
		addq.l		#4,sp			flush stack
		movem.l		(sp)+,d1-d4/a0/a1/a6	restore
		ENDM

*****************************************************************************

; Loads a specified file into memory. Required memory is allocated, but must
;be freed by the user when finished with. May specify MEMF_xxx as a parameter
;if required.

LOADFILE	MACRO		filename,{memory type}

MMLoadFile	SET		1
MMFileLen	SET		1

		movem.l		d1-d7/a1/a6,-(sp)	save em
		
		IFNC		'','\2'
		move.l		#\2,-(sp)		users requirements
		ENDC
		
		IFC		'','\2'
		move.l		#0,-(sp)		else default
		ENDC
		
		move.l		\1,-(sp)
		jsr		MM_LoadFile		call routine
		addq.l		#8,sp			flush stack
		movem.l		(sp)+,d1-d7/a1/a6	restore
		
		ENDM

*****************************************************************************

		************************************
		*     Intuition Library Macros	   *
		************************************

*****************************************************************************

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

MMOpenAWin	SET		1

		movem.l		d1-d2/d5-d7/a0-a2/a4-a6,-(sp)	save

		IFC		'','\6'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\6'
		move.l		\6,-(sp)		*Screen
		ENDC

		IFC		'','\5'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\5'
		move.l		\5,-(sp)		*MenuStrip
		ENDC

		IFC		'','\4'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\4'
		move.l		\4,-(sp)		*Border
		ENDC

		IFC		'','\3'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\3'
		move.l		\3,-(sp)		*Image
		ENDC

		IFC		'','\2'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\2'
		move.l		\2,-(sp)		*IText
		ENDC

		move.l		\1,-(sp)		*NewWindow
		jsr		MM_OpenAWin		open the window
		lea		24(sp),sp		flush stack
		movem.l		(sp)+,d1-d2/d5-d7/a0-a2/a4-a6	restore

		ENDM

*****************************************************************************

;--------------
;--------------	A macro to simplify calling OpenSBWin subroutine
;--------------

; Read doc file for information on usage.

; Preserves all registers except d0. After macro, d0=0 if window failed to
;open.

; OPENSBWIN    NewWindow,BitMap,{IText},{Image},{Border},{MenuStrip},{Screen}

***** NewWindow MUST be passed in an address register *****

OPENSBWIN	MACRO NewWindow,BitMap,IText,Image,Border,MenuStrip,Screen

MMOpenAWin	SET		1

		move.l		a0,-(sp)
		move.l		\1,a0
		move.l		\2,nw_BitMap(a0)	link BitMap-NewWindow
		move.l		(sp)+,a0

		movem.l		d1-d2/d5-d7/a0-a2/a4-a6,-(sp)	save

		IFC		'','\7'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\7'
		move.l		\7,-(sp)		*Screen
		ENDC

		IFC		'','\6'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\6'
		move.l		\6,-(sp)		*MenuStrip
		ENDC

		IFC		'','\5'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\5'
		move.l		\5,-(sp)		*Border
		ENDC

		IFC		'','\4'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\4'
		move.l		\4,-(sp)		*Image
		ENDC

		IFC		'','\3'
		move.l		#0,-(sp)		NULL
		ENDC
		
		IFNC		'','\3'
		move.l		\3,-(sp)		*IText
		ENDC

		move.l		\1,-(sp)		*NewWindow
		jsr		MM_OpenAWin		open the window
		lea		24(sp),sp		flush stack
		movem.l		(sp)+,d1-d2/d5-d7/a0-a2/a4-a6	restore

		ENDM

*****************************************************************************

;--------------
;--------------	Macro for closing a window
;--------------

CLOSEWIN	macro		Window

MMCloseWin	SET		1

		movem.l		d0-d2/a0-a4/a6,-(sp)	save em
		move.l		\1,-(sp)		param onto stack
		jsr		MM_CloseWin		call routine
		addq.l		#4,sp			flush stack
		movem.l		(sp)+,d0-d2/a0-a4/a6
	
		endm

*****************************************************************************

;--------------
;--------------	Macro to deal with IDCMP communication for a given window
;--------------

HANDLEIDCMP	MACRO		Window,{ServerRoutine}

MMWFM		SET		1

		movem.l		d1-d7/a0-a6,-(sp)	save em
		move.l		#0,-(sp)		for LastItem
		move.l		#0,-(sp)		for *Menu
		move.l		\1,-(sp)		*Window

		IFC		'','\2'
		move.l		#0,-(sp)		no server
		ENDC

		IFNC		'','\2'
		move.l		\2,-(sp)		UserRoutine
		ENDC

		jsr		MM_WFM			handle the port
		lea		16(sp),sp		flush stack
		movem.l		(sp)+,d1-d7/a0-a6	restore

		ENDM

*****************************************************************************

;--------------
;--------------	Macro to allocate and initialise a BitMap structure
;--------------

; Note, allocates mem for the planes as well.

BITMAP		MACRO		Width,Height,Depth

MMGetBitMap	SET		1

		movem.l		d1-d7/a0-a3/a6,-(sp)	save em
		move.l		\3,-(sp)		params onto stack
		move.l		\2,-(sp)
		move.l		\1,-(sp)
		jsr		MM_GetBitMap		call routine
		lea		12(sp),sp		flush stack
		movem.l		(sp)+,d1-d7/a0-a3/a6	restore
		ENDM

*****************************************************************************

;--------------
;--------------	Macro to free all memory tied up in a BitMap structure
;-------------- allocated using BITMAP.

FREEBITMAP	MACRO		BitMap

MMFreeBitMap	SET		1

		movem.l		d0-d7/a0-a6,-(sp)	save em
		move.l		\1,-(sp)		param onto stack
		jsr		MM_FreeBitMap		call routine
		addq.l		#4,sp			flush stack
		movem.l		(sp)+,d0-d7/a0-a6	restore
		ENDM

*****************************************************************************

;--------------
;--------------	Macro to save a few variables from Window structure
;--------------

; See doc file for notes on using this macro.

GETWINVARS	MACRO		Window,label

		move.l		a0,-(sp)
		move.l		a1,-(sp)
		move.l		\1,a0
		move.l		\2,a1
		move.l		a0,(a1)+
		move.l		wd_RPort(a0),(a1)+
		move.l		wd_UserPort(a0),(a1)
		move.l		(sp)+,a1
		move.l		(sp)+,a0

		ENDM

*****************************************************************************

;--------------
;--------------	Macro for opening a screen and setting its palette
;--------------

OPENSCREEN	MACRO		NewScreen,{Palette}

MMOpenScrn	SET		1

		movem.l		d1-d3/d7/a0-a4/a6,-(sp)

		IFC		'','\2'
		move.l		#0,-(sp)
		ENDC
		IFNC		'','\2'
		move.l		\2,-(sp)
		ENDC
		move.l		\1,-(sp)
		jsr		MM_OpenScrn		call routine
		addq.l		#8,sp			flush stack
		movem.l		(sp)+,d1-d3/d7/a0-a4/a6	restore
		ENDM

*****************************************************************************

;--------------
;--------------	Macro for closing a screen
;--------------

CLOSESCREEN	macro		Screen

MMCloseScrn	SET		1

		movem.l		d0-d2/a0-a2/a6,-(sp)	save em
		move.l		\1,-(sp)
		jsr		MM_CloseScrn
		addq.l		#4,sp			flush stack
		movem.l		(sp)+,d0-d2/a0-a2/a6	restore
		
		endm

*****************************************************************************

;--------------
;--------------	Macro for fading an Intuition screen to black
;--------------

FADEOUT		macro		Screen

MMFadeOut	SET		1
		movem.l		d0-d7/a0-a6,-(sp)	save em
		lea		-64(sp),sp		space for CMAP
		move.l		\1,-(sp)		*Screen
		jsr		MM_FadeOut		blank the screen
		lea		68(sp),sp		flush stack
		movem.l		(sp)+,d0-d7/a0-a6	restore
		endm

*****************************************************************************

;--------------
;--------------	Macro for fading an Intuition screen from black
;--------------

; FADEIN	Screen,Palette

FADEIN		macro

MMFadeIn	SET		1

		movem.l		d0-d7/a0-a6,-(sp)	save em
		lea		-64(sp),sp		space for CMAP
		move.l		\2,-(sp)		*palette
		move.l		\1,-(sp)		*Screen
		jsr		MM_FadeIn		blank the screen
		lea		72(sp),sp		flush stack
		movem.l		(sp)+,d0-d7/a0-a6	restore
		endm

*****************************************************************************

