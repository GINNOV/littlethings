	IFND	DISKFONT_LIB_I		name changes
DISKFONT_LIB_I	set	1

* library offsets off _DiskfontBase

_LVOOpenDiskFont	equ	-30
_LVOAvailFonts		equ	-36

CALLDISKFONT	macro
	move.l	_DiskfontBase,a6
	jsr	_LVO\1(a6)
	endm

DISKFONTNAME	macro
	dc.b	'diskfont.library',0
	EVEN
	endm

	ENDC

