*****************************************************************
* DiskMacros2.i :- Macros to move drive heads while waiting the *
*                  recommended amount of time using a CIA timer *
*                  This timer routine must be included in your  *
*                  source, and must be called 'WAIT'. It must   *
*                  accept the number of milliseconds to wait in *
*                  register D0                                  *
*                                                               *
* Version 1.2 (c)1991 Dean Ashton                               *
*****************************************************************

_CIAAPRA	EQU	$BFE001
_CIABPRB	EQU	$BFD100

***************************************************************************
* DRIVEON :- Usage  DRIVEON nnnn(,N) where nnnn is the drive bit          *
*                                    and N indicates wether to wait for   *
*                                    the DSKREADY flag.                   *
*            Example.. DRIVEON 0010,N turns on Drive 1 without wait       *
*                      DRIVEON 0100   turns on Drive 2 with wait          *
***************************************************************************
DRIVEON	MACRO
	MOVE.B	#$79,_CIABPRB
	NOP
	NOP
	MOVE.B	#$79-%0\1000,_CIABPRB	;activate drive(s)
	NOP
	NOP
	
	IFNC	'N','\2'			;Only assemble this
\@WaitForDrive				;if parameter 2 is 
	BTST	#5,_CIAAPRA		;not 'N'....
	BNE.S	\@WaitForDrive		;Hopefully this is
					;backwards compatible
	ENDC
	ENDM

***************************************************************
* DRIVEOFF :- Usage DRIVEOFF nnnn where nnnn is the drive bit *
*             Example.. DRIVEOFF 1000 turns off Drive 3       *
***************************************************************

DRIVEOFF	MACRO
	MOVE.B	#$F9,_CIABPRB
	NOP
	NOP
	MOVE.B	#$F9-%0\1000,_CIABPRB	;deactiveate drive(s)
	NOP
	NOP
	ENDM
*--------------------------------------------------------------------
UPPERHEAD	MACRO
	BCLR	#2,_CIABPRB	; Head UP
	NOP			; Give command time to be 
	NOP			; interpreted
	ENDM
*--------------------------------------------------------------------
LOWERHEAD	MACRO
	BSET	#2,_CIABPRB	; Head DOWN
	NOP			; Give command time to be
	NOP			; interpreted
	ENDM
*--------------------------------------------------------------------
STEP	MACRO
	MOVE.L	D0,-(A7)		; Stack D0
	MOVE.W	#20,D0		; 20 millisecond delay
	BSR	WAIT		; using timer routine
	IFC	'IN','\1'		; If direction is IN
	BSET	#1,_CIABPRB	; Set disk direction --> In
	ENDC			; Otherwise don't do above
	IFC	'OUT','\1'	; If direction is OUT
	BCLR	#1,_CIABPRB	; Set disk direction --> Out
	ENDC			; Otherwise don't do above
	NOP			; Give command time to get to
	NOP			; the drive!
	MOVE.L	(A7)+,D0		; Unstack D0
	ENDM
*--------------------------------------------------------------------
SEEKZERO	MACRO
	STEP	IN		; Step towards Track Zero
\@GetZero	BTST	#4,_CIAAPRA	; Are we there?
	BEQ.S	\@GotZero		; Yes! Get out of here!
	STEPTRACK	\1,\2		; Pass wait time in milliseconds
				; and Timer subroutine name.
	BRA.S	\@GetZero
\@GotZero	NOP
	ENDM
*--------------------------------------------------------------------
STEPTRACK	MACRO
	BCLR	#0,_CIABPRB	; Send first part of quick pulse
	NOP			; Give it time to send the command
	NOP			; or it might not work correctly!
	BSET	#0,_CIABPRB	; Step that track!
	MOVE.L	D0,-(A7)		; Save D0
	MOVE.W	#\1,D0		; D0 holds number of Milliseconds
	BSR	\2		; Call Timer Routine
	MOVE.L	(A7)+,D0		; Restore D0
	ENDM	
*--------------------------------------------------------------------
WAITDISK	MACRO
	MOVEM.L	D0-D1,-(A7)	; Save D0 and D1 for later
	MOVE.L	#$20000,d0	; We can only wait so long...
	MOVE.W	#$0002,INTREQ(a6)	; Clear Disk Interrupt Flag
\@WaitDMA	MOVE.W	INTREQR(A6),D1	; Get Disk Interrupt Flag
	BTST	#1,D1		; Has it finished?
	BNE.S	\@DskDone		; Yeah! Lets get out of here!
	SUBQ.L	#1,D1		; Subtract one from our counter
	BNE.S	\@WaitDMA		; Lets go and try again!
\@DskDone	MOVEM.L	(A7)+,D0-D1	; Get D0 and D1 back again!
	ENDM

