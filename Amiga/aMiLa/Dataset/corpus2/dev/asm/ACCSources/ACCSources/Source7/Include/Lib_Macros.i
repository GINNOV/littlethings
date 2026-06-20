; This include files defines macros that simplify the opening and closing
;of libraries. There is a macro called LIBNAMES that defines all the
;library names and reserves space for the base pointer. There is also a
;function calling macro for each library.

; Note that the LIBNAMES macro should be at the end of your source so that
;the data is not accidentaly mistaken for source.

; M.Meany 1990

_SysBase	equ		$4

; Library calling macros

CALLDISKFONT	macro
		move.l		_DiskfontBase,a6
		jsr		\1(a6)
		endm
		
CALLDOS		macro
		move.l		_DOSBase,a6
		jsr		\1(a6)
		endm

CALLEXEC	macro
		move.l		(_SysBase),a6
		jsr		\1(a6)
		endm

CALLGRAF	macro
		move.l		_GfxBase,a6
		jsr		\1(a6)
		endm
		
CALLICON	macro
		move.l		_IconBase,a6
		jsr		\1(a6)
		endm
		
CALLINT		macro
		move.l		_IntuitionBase,a6
		jsr		\1(a6)
		endm
		
CALLFFP		macro
		move.l		_MathBase,a6
		jsr		\1(a6)
		endm
		
CALLIEEEDOUB	macro
		move.l		_MathIeeeDoubBasBase,a6
		jsr		\1(a6)
		endm
		
CALLMATHTRANS	macro
		move.l		_MathTransBase,a6
		jsr		\1(a6)
		endm
		
CALLTRANS	macro
		move.l		_TranslatorBase,a6
		jsr		\1(a6)
		endm
		
; Macros to open libraries and store base pointers

OPENDISKFONT	macro
		lea		diskfontname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DiskfontBase
		endm

OPENDOS		macro
		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		endm

OPENGRAPHICS	macro
		lea		gfxname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_GfxBase
		endm
		
OPENICON	macro
		lea		iconame,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IconBase
		endm
		
OPENINTUITION	macro
		lea		intname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		endm
		
OPENMATHFFP	macro
		lea		ffpname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_MathBase
		endm
		
OPENMATHDOUBLE	macro
		lea		mathdoubname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_MathIeeeDoubBasBase
		endm
		
OPENMATHTRANS	macro
		lea		mathtransname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_MathTransBase
		endm
		
OPENTRANSLATOR	macro
		lea		translatorname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_TranslatorBase
		endm
		
; Macros to close libraries

CLOSEDISKFONT	macro
		move.l		_DiskfontBase,a1
		CALLEXEC	CloseLibrary	endm
		endm

CLOSEDOS	macro
		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary	
		endm

CLOSEGRAPHICS	macro
		move.l		_GfxBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
CLOSEICON	macro
		move.l		_IconBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
CLOSEINTUITION	macro
		move.l		_IntuitionBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
CLOSEMATHFFP	macro
		move.l		_MathBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
CLOSEMATHDOUBLE	macro
		move.l		_MathIeeeDoubBasBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
CLOSEMATHTRANS	macro
		move.l		_MathTransBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
CLOSETRANSLATOR	macro
		move.l		_TranslatorBase,a1
		CALLEXEC	CloseLibrary	
		endm
		
; Macro that defines all library names and base pointers
		
LIBNAMES	macro
diskfontname	dc.b		'diskfont.library',0
		even
_DiskFontBase	dc.l		0
dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0
gfxname		dc.b		'graphics.library',0
		even
_GfxBase	dc.l		0
iconame		dc.b		'icon.library',0
		even
_IconBase	dc.l		0
intname		dc.b		'intuition.library',0
		even
_IntuitionBase	dc.l		0
ffpname		dc.b		'mathffp.library',0
		even
_MathBase	dc.l		0
mathdoubname	dc.b		'mathdouble.library',0
		even
_MathIeeeDoubBase dc.l		0
mathtransname	dc.b		'mathtrans.library',0
		even
_MathTransBase	dc.l		0
translatorname	dc.b		'translator.library',0
		even
_TranslatorBase	dc.l		0
		endm
		
