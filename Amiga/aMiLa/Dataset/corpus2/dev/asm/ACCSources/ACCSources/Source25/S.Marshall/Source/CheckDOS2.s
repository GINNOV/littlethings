*********************************************************************
*
*	Short Routine to test for DOS 2.## in startup sequences etc.
*	This could be written without opening the DOS lib. We could
*	have  used  FindResident() then  extracted  the lib version
*	from the lib structure. We wouldn't have saved much in code
*	size though.
* 
*			By Steve Marshall (18/5/92)
*		Should compile easily with most assemblers.
*
*********************************************************************
*
*	Call this prog from your startup-sequence. It will return
*	with a WARN error if DOS 2.0 or higher is not found.
*	Use something like:
*
*	if WARN
*	do this
*	else
*	do that
*	endif
*
*********************************************************************
	
	;incdir	"include:"		  ;use these with Devpac 2
	;include	"exec/exec_lib.i" ;For Devpac 3 use system.gs header

Start:
	moveq	#36,d0			;set for dos 2.00
	move.l	4.w,a6			;execbase
	lea	DosName(pc),a1		;lib name
	jsr	_LVOOpenLibrary(a6)	;open dos lib
	tst.l	d0			;tset result
	beq.s	NotDOS2			;branch on error
	
	move.l	d0,a1			;dosbase in a1
	jsr	_LVOCloseLibrary(a6)	;close dos lib
	moveq	#0,d0			;set no error
	rts				;and quit
	
NotDOS2
	moveq	#5,d0			;set WARN return
	rts
	
DosName
	dc.b	"dos.library",0
	