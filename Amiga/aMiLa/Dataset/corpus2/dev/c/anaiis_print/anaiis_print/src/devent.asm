;
; devent.asm
;

	include "exec/resident.i"
	include "exec/nodes.i"
	include	"exec/libraries.i"
	include	"exec/devices.i"

	xref	DevName
	xref	DevID
	xref	DevInitData

	section	text,code
	moveq	#-1,D0
	rts
_DevRomTag:
	dc.w	RTC_MATCHWORD
	dc.l	_DevRomTag
	dc.l	endtag
	dc.b	RTF_AUTOINIT
	dc.b	0
	dc.b	NT_DEVICE
	dc.b	0
	dc.l	DevName
	dc.l	DevID
	dc.l	DevInitData
endtag:

	END
