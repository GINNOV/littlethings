***************************************************************************
*
*	Simple example of the use of my DOS2Start.i include file.
*	This include replaces the standard startup code supplied
*	by Commodore. It uses the new DOS2 functions ReadArgs etc.
*	and is much smaller than the original. It will however
*	only work on DOS V2.04 upwards. Earlier (V2.00 etc) had
*	these functions but were bugged.
*
*			By Steve Marshall 21/6/92
* 
***************************************************************************

	include		misc/dos2start.i

_Start
	move.l		ArgList(pc),a5		;get arglist
	beq.s		error
	
	move.l		#ConName,d1		;get console name
	move.l		#MODE_OLDFILE,d2	;access mode
	CALLDOS		Open			;open a console
	move.l		d0,d7			;save file handle
	beq.s		error			;branch if error
	
Again	
	move.l		d7,d1			;filehandle
	move.l		(a5)+,d2		;get arg
	beq.s		Done			;branch if no arg
	jsr		_LVOFPuts(a6)		;write string

	move.l		d7,d1			;filehandle
	moveq		#$0a,d2			;get linefeed char
	jsr		_LVOFPutC(a6)		;write char
	bra.s		Again
	
Done
;------	This shouldn't be nesessary as buffers should be flushed with
;	each newline, but is put here as a demo of it's use.
	move.l		d7,d1			;filehandle
	jsr		_LVOFlush(a6)		;flush buffers
	
	move.l		d7,d1			;filehandle
	jsr		_LVOClose(a6)		;close console
	
error	
	moveq		#0,d0			;return message		
	rts
	
;===========================================================================

ConName
	dc.b	'CON:0/100/640/100/Output Console/CLOSE/WAIT',0
	EVEN
	
;this should be an array large enough to hold a pointer to all the 
;arguments supplied. That is one long for each /S,/K,/N,/T/A,/F or /M.
;Note that for /M (multiple) you will need one long. This will point
;to an array of strings.
ArgList
	dc.l	0
	
TEMPLATE
	dc.b	'Files/A/M',0
	EVEN
	
ExtHelp
	dc.b	'Enter FileNames Please',0	
	
