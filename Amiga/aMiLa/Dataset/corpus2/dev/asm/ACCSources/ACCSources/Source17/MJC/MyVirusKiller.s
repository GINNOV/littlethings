
*	ACC Virus Killer by Mike Cross V1.3, March 1991

*	Assemble to Cli or disk only!

*	Assembler Tabs = 10



	incdir	Sys:include/
	include	exec/exec_lib.i
	include	exec/execbase.i
	include	libraries/dos_lib.i
	include	hardware/custom.i
	
	opt	d+,o-,ow+
	
	
Ciaapra	equ	$bfe001
Custom	equ	$dff000

	
	cmpi.b	#'?',(a0)		* ? in command line?
	bne	StartOk		* No
	
	bsr	OpenAll		* Yes - Open dos, then 
	move.l	_CliBase,d1	* display title message
	move.l	#Options,d2
	move.l	#OptionsE,d3
	CALLDOS	Write
	bra	ChkVector		* Check vectors
	rts
	
StartOk	bsr	OpenAll	
	bra	ChkVector
	rts
		
OpenAll	lea	DosName,a1	* Open dos library
	CALLEXEC	OldOpenLibrary
	move.l	d0,_DOSBase
	beq	Exit
	CALLDOS	Output		* Get Cli Handle
	move.l	d0,_CliBase
	move.l	_CliBase,d1
	move.l	#Title,d2		* Display title text
	move.l	#TitleE,d3
	CALLDOS	Write
	lea	Custom,a4
	lea	Variables,a3	* A3 - Variable Pointer
	rts
	
ChkVector	movea.l	$4.w,a6
	move.l	ColdCapture(a6),_ColdCapture(a3)	* Save them all	
	move.l	CoolCapture(a6),_CoolCapture(a3)
	move.l	WarmCapture(a6),_WarmCapture(a3)	
	move.l	KickTagPtr(a6),_KickTagPtr(a3)
	move.l	KickCheckSum(a6),_KickCheckSum(a3)
	move.l	KickMemPtr(a6),_KickMemPtr(a3)

	cmpi.l	#0,_ColdCapture(a3)
	bne	Problem
	
	
	move.l	_CliBase,d1	* No viri found, display the
	move.l	#Nothing,d2	* All Clear message amd quit
	move.l	#NothingE,d3
	CALLDOS	Write
	
Exit2	move.l	_DOSBase,a1
	CALLEXEC	CloseLibrary
	moveq.l	#0,d0
Exit	rts

Problem	move.w	#4095,d0		* This block briefly flashes
CLoop	move.w	d0,color+$00(a4)	* the screen upon detection
	dbeq	d0,CLoop		* of altererd vectors
	
	move.l	_CliBase,d1	* Found one! Display found a 
	move.l	#FoundV,d2	* possible virus message
	move.l	#FoundVE,d3
	CALLDOS	Write
	
Wait	btst	#6,Ciaapra	* Lmb - clear vectors
	beq	Clr_Vect
	btst	#2,potinp(a4)	* Rmb - No action	
	beq	Exit2	
	btst	#7,Ciaapra	* Fire - Hard reset
	beq	Hrd_Rset
	bra	Wait		* Loop until decision made
	rts
	
Clr_Vect	movea.l	$4.w,a6		
	clr.l	ColdCapture(a6)	* Clear All important 
	clr.l	CoolCapture(a6)	* Exec vectors
	clr.l	WarmCapture(a6)
	clr.l	KickTagPtr(a6)
	clr.l	KickCheckSum(a6)
	clr.l	KickMemPtr(a6)
	cmpi.l	#7,d7
	beq	Hrd_Rset2
	bra	ChkVector		* Check again for All Clear
	rts
	
Hrd_Rset	moveq.l	#7,d7		* Crude pointer!
	bsr	Clr_Vect
Hrd_Rset2	lea	ResetAll,a5	* This block handles the
	CALLEXEC	Supervisor	* hard reset
	rts
	
ResetAll	lea.l	2,a0		* This is the only official 
	reset			* reset code (according to HRM)
	jmp	(a0)



	section	Data,data
	
Title	dc.b	$9b,'1;33;40m'
	dc.b	'ACC Virus Killer V1.3 ',$9b,'0;31;40m'
	dc.b	'by Mike Cross',10,0
TitleE	equ	*-Title

FoundV	dc.b	$9b,'3;31;40m'	
	dc.b	'Warning - Possible virus found!',10,10,0
	dc.b	'Options :- ',10
	dc.b	'    Left mouse - Clear Exec vectors',10
	dc.b	'    Right mouse - No action',10
	dc.b	'    Joystick fire - Hard Reset',10,10,0
	dc.b	$9b,'0;31;40m'
FoundVE	equ	*-FoundV

Nothing	dc.b	$9b,'3;31;40m'
	dc.b	'All Clear.'
	dc.b	$9b,'0;31;40m',10,10,0
NothingE	equ	*-Nothing

Options	dc.b	$9b,'3;31;40m'
	dc.b	'No options available in V1.3',10,10
	dc.b	'Release Date : 1st October1991',10
	dc.b	'Coded using Devpac V2.14 on a V1.3 2.5 Meg A500.',10,10
	dc.b	$9b,'0;31;40m'
OptionsE	equ	*-Options

	even
	
_DOSBase	dc.l	0

_CliBase	dc.l	0

DosName	dc.b	'dos.library',0

	even


	section	Variable,bss

	rsreset
	
_ColdCapture	rs.l	1
_CoolCapture	rs.l	1
_WarmCapture	rs.l	1
_KickTagPtr	rs.l	1
_KickCheckSum	rs.l	1
_KickMemPtr	rs.l	1
Var_Lngth		rs.b	1

Variables		ds.b	Var_Lngth

		end

	V1.2	First release version  	March 1991
	V1.3	Tidied code - Split hunks	October 1991
		
	Options to be added :-

	1. Check and clear individual vectors (instead of all at once)
	2. Check bootblocks for standard dos block, if not present
	   give option to install standard Dos block.
	3. Different parameters to check different options
	4. Give program a proper WorkBench startup handler
 
