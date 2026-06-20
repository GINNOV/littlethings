
; Extension file for start.s, accompanies Intuition Tutorial on ACC 13.

; The subroutines open a disc based font and attach its textAttr structure
;to an Itext structure used in start.s

; © M.Meany, June 1991.

***************	The extra include files required in this module.


		include		libraries/diskfont_lib.i
		include		graphics/text.i 

***************	Extra Initalisations required for this program

; Open the diskfont library

FontAdd		
		lea		diskfname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DiskfontBase save base pointer
		beq		.error		quit if error

; Open balloon font

		lea		balloonAttr,a0	addr of font struct
		CALLDISKFONT	OpenDiskFont	and open font
		move.l		d0,font.ptr	save handle
		beq		.error		quit if error

; Attach the font to the window start.s has opened

		move.l		d0,a0		font handle
		move.l		window.rp,a1	rastport
		CALLGRAF	SetFont		and attach the font

.error		rts

***************	Extra resource releasing required by this prog.

FontFree	tst.l		font.ptr	font loaded ?
		beq.s		.no_font	if not skip next bit

; Close font.

		move.l		font.ptr,a1	get font handle
		CALLGRAF	CloseFont	and close it

; Close diskfont library

.no_font	tst.l		_DiskfontBase	lib open?
		beq.s		.no_lib		if not skip next bit

		move.l		_DiskfontBase,a1 get lib base pointer
		CALLEXEC	CloseLibrary	and close
 
.no_lib		rts				and return

***************	Data required by this extension.

diskfname	dc.b		'diskfont.library',0
		even

_DiskfontBase	dc.l		0

font.ptr	dc.l		0

balloonAttr	dc.l	.fontname
		dc.w	30
		dc.b	FS_NORMAL
		dc.b	FPF_PROPORTIONAL!FPF_DISKFONT

.fontname	dc.b	'Source:fonts/balloon.font',0
		even


