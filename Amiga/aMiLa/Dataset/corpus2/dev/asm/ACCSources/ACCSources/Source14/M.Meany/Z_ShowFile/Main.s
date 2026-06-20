
; These includes are required by the More subroutine.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		graphics/graphics_lib.i
		include		source:include/arpbase.i
		

start		OPENARP				
		movem.l		(sp)+,d0/a0	
						
						
;--------------	Save library base pointers that ARP supplies

		move.l		a6,_ArpBase	;store arpbase
		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

		moveq.l		#0,d0
		
		bsr		ShowFile

		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary

		rts

_ArpBase	dc.l		0
_IntuitionBase	dc.l		0
_GfxBase	dc.l		0

		include		showfile.i
