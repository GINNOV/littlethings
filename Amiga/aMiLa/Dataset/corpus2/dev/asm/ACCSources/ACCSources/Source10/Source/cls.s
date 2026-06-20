
*	Routine to clear the Cli window, by Mike Cross, 1991

*	Run from CLI only


	movea.l	4.w,A6
	lea	DosName,A1
	jsr	-408(A6)		* OpenLibrary() - Dos
	move.l	D0,A6
	beq.s	Exit
	jsr	-60(A6)		* Output() - Get CLI handle
	move.l	D0,D1
	lea	Buffer,A0		* Write clr codes
	move.l	A0,D2
	moveq.l	#4,D3
	jsr	-48(A6)		* Write()
	tst.l	D0
	bmi.s	Error
	moveq.l	#0,D0		
Exit	rts	
 
Error	jsr	-132(A6)		* IoErr() - Get error code for
	rts			* CLI Why command
	
	even
	 
DosName	dc.b	'dos.library',0
 
	even
	
Buffer	dc.b	$9b,$48,$9b,$4a

	

	

	
 
