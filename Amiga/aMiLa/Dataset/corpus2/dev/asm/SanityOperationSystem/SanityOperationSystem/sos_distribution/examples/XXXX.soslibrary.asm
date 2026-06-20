; ===================================================================
;
;                            XXXX.soslibrary
;   
;                         start-code für SOSlibs
;
;                                 V 1.0
;
;
;                                 source
;
; ===================================================================

; Exampe source
; replace XXXX with your library name.

; use this as your library autodoc header. remove the # to activate it. 

*#***** XXXX.library/ *******************************************************
*
*   NAME
*
*   SYNOPSIS
*
*   FUNCTION
*
*   INPUTS
*
*   RESULT
*
*   ERRORS
*
*   EXAMPLE
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
****************************************************************************

		include	"include:sos/sos.i"
		include	"include:sos/XXXX.i"

		moveq	#-1,d0			; AmigaDos save return
		rts

Start		lea	XXXXBase,a0		; Library initialisation code
		rts

		jmp	cmd2			; Jumptable
		jmp	cmd1
		jmp	_nothing		; this one's free for ext.
XXXXBase	ds.b	XXXXB_SIZEOF		; your local variables.

_nothing	moveq	#0,d0			; code for dummy call
		rts


