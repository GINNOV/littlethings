		opt	a-,c-,d-,l+,ow-,x-

* ---------------------------------------------------------------------------
* -----                     FileSelect V2.0 Example                     -----
* -----                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                  -----
* -----                     AW 01.09.90 - 30.09.90                      -----
* ---------------------------------------------------------------------------

*
* Assemble with l+ to 'FileSelectExample.o'
* Use blink to link it with FileSelect.o
* Type blink FileSelectExample.o FileSelect.o TO FileSelectExample
* Or append the source of FileSelect at the end of this source, delete the
* include-lines and assemble it with l-
* You may change the 'incdir'-line 'df0:source/' to the path where the
* 'FileSelect.i'-file is.
*

		incdir	ram:include/,df0:source/
		include	exec/exec_lib.i
		include	exec/memory.i
		include	intuition/intuition_lib.i
		include	intuition/intuition.i
		include	intuition/intuitionbase.i
		include	graphics/graphics_lib.i
		include	libraries/dos_lib.i
		include	libraries/dos.i
		include	libraries/dosextens.i

		include	FileSelect.i

		XREF	FileSelect
		XDEF	_IntuitionBase,_GfxBase,_DOSBase

* Start
* ---------------------------------------------------------------------------

		SECTION	"FileSelect_Example",CODE

		include	user/WBStartup.i

_Main		lea	Intuitionname,a1		Libs öffnen
		clr.l	d0
		CALLEXEC OpenLibrary
		move.l	d0,_IntuitionBase
		lea	Graphicsname,a1
		clr.l	d0
		CALLEXEC OpenLibrary
		move.l	d0,_GfxBase
		lea	Dosname,a1
		clr.l	d0
		CALLEXEC OpenLibrary
		move.l	d0,_DosBase
		lea	Screenstruct,a0			Screen öffnen
		CALLINT OpenScreen
		tst.l	d0
		beq	Error_1
		move.l	d0,Screenptr

* FileSelect V2.0 aufrufen

		lea	FileSelect_struct,a0
		jsr	FileSelect

* Ende
* ---------------------------------------------------------------------------

_End
Error_2		move.l	Screenptr,a0
		CALLINT CloseScreen
Error_1		move.l	_DosBase,a1			Libs schließen
		CALLEXEC CloseLibrary
		move.l	_GfxBase,a1
		CALLEXEC CloseLibrary
		move.l	_IntuitionBase,a1
		CALLEXEC CloseLibrary
		clr.l	d0				-> CLI
		rts

* Data
* ---------------------------------------------------------------------------

		SECTION	"FileSelect_Example",DATA

* Strukturen

* Screen

Screenstruct	dc.w	0,0,640,200,2
		dc.b	0,1
		dc.w	$8000				HIRES
		dc.w	CUSTOMSCREEN
		dc.l	Font
		dc.l	Screentitle
		dc.l	0,0

* Topaz font

Font		dc.l	Font_name
		dc.w	TOPAZ_EIGHTY
		dc.b	FS_NORMAL
		dc.b	FPF_ROMFONT

* FileSelect V2.0 struct

FileSelect_struct
		dc.w	NFS2_CENTREPOS
		dc.w	NFS2_CENTREPOS
		dc.l	NFS2_DEFAULTTITLE
		dc.l	Pathname
		dc.l	NFS2_NODEFAULT
Screenptr	ds.l	1
		dc.w	NFS2_MAKEDIR!NFS2_DELETE!NFS2_RENAME
		dc.l	Filter_1
		dc.b	NFS2_DEFAULTPEN
		dc.b	NFS2_DEFAULTPEN
		dc.b	NFS2_DEFAULTPEN
		dc.b	NFS2_DEFAULTPEN
		dc.l	0
		dc.l	0

Filter_1	dc.l	Filter_2
		dc.b	5,0
		dc.l	String_1
		dc.l	0
String_1	dc.b	".info"
		even

Filter_2	dc.l	FS2F_LASTFILTER
		dc.b	4,0
		dc.l	String_2
		dc.l	0
String_2	dc.b	".bak"
		even

* Strings

Intuitionname	dc.b	"intuition.library",0
		even
Graphicsname	dc.b	"graphics.library",0
		even
Dosname		dc.b	"dos.library",0
		even
Font_name	dc.b	"topaz.font",0
		even
Screentitle	dc.b	"FileSelect V2.0 example screen © by André Wichmann",0
		even
Pathname	dc.b	"ram:",0
		even

* Buffers
* ---------------------------------------------------------------------------

		SECTION	"FileSelect_Example",BSS

_IntuitionBase	ds.l	1
_GfxBase	ds.l	1
_DosBase	ds.l	1
OutputBuffer	ds.b	512

