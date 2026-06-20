; ============================================================================ ;
; $Id: putchprocs.s,v 1.1 1996/10/20 21:35:32 d93-hyo Stab $
; ---------------------------------------------------------------------------- ;
; Various "PutChProc" functions for use with exec.library/RawDoFmt().
;
; Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
; ============================================================================ ;

	xdef	_SimplePutChar	; adds character to data
	xdef	_DummyPutChar	; does nothing
	xdef	_CountChar	; increases data with one (data is a counter)

; ============================================================================ ;

	section	code

_SimplePutChar:
	move.b	d0,(a3)+
_DummyPutChar:
	rts

_CountChar:
	addq.l	#1,(a3)
	rts

	end
