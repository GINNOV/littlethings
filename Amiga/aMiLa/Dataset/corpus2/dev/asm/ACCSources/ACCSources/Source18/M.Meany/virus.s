
*	ACC Virus Killer by Mike Cross V1.3, March 1991

* Added Saddam disk-validator protection, M.Meany Nov 91.

*	Assemble to Cli or disk only!

*	Assembler Tabs = 10



	incdir	Sys:include/
	include	exec/exec_lib.i
	include	exec/execbase.i
	include	libraries/dos_lib.i
	include	hardware/custom.i

FUNCTION	equ		_LVOAllocAbs
	
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

	bsr	SADDAM


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

; Yo Mike! Added the Saddam patch just here.

; M.Meany, Nov 91.

SADDAM		lea		intname(pc),a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		lea		IntBase(pc),a0		a0->storage point
		move.l		d0,(a0)			save base pointer
		beq.s		.quit_fast			quit if no lib

; Allocate memory for patch code to add to Exec function
; If your system does not have a few bytes to spare for this code, you can
;expect a visit from the 'GURU' very soon! So I haven't bothered to write
;a close Intuition routine if memory is not available.
 
		move.l		#KillerLen,d0		size of patch code
		moveq.l		#0,d1			any memory type
		CALLEXEC	AllocMem		get some memory
		move.l		d0,d7			save it's addr
		beq.s		.quit_fast			quit if no mem

; Copy jump vector from lib base into custom routine

		lea		FUNCTION(a6),a0		addr in jump table
		lea		OldVector(pc),a1	a1->storage point
		move.w		(a0)+,(a1)+		copy jmp command
		move.l		(a0),(a1)		and addr of routine

; Copy the custom routine into the allocated mem block

		lea		Killer(pc),a0		a0->the patch code
		move.l		d0,a1			a1->it's new home
		move.l		#KillerLen,d0		d0= it's byte size
		jsr		_LVOCopyMem(a6)		moving!

; Now update the lib vector to point to the custom routine

		suba.l		a0,a0			why not?
		move.l		#FUNCTION,a0		patching FindName
		move.l		$4.w,a1			in exec library
		move.l		d7,d0			with our code
		jsr		_LVOSetFunction(a6)

	move.l	_CliBase,d1
	move.l	#TellEm,d2		* Display title text
	move.l	#TLen,d3
	CALLDOS	Write

.quit_fast	moveq.l		#0,d0			no DOS errors
		rts


dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
TellEm		dc.b		$0a,'   StopSaddam patch now operating.',$0a
		dc.b		'   This patch will stop the SADDAM file virus ( disk-validator )',$0a
		dc.b		'   from loading. Run from the CLI only with no parameters.',$0a,$0a
TLen		equ		*-TellEm


; The custom routine patched to an Exec function. Note the p+ switch which
;will report an error if a line of my code is not relocatable, this is
;necessary as the routine is copied into a block of memory obtained by
;calling AllocMem. The code is patched to AllocAbs, I see no problem with
;this as the function must be almost redundant these days. Any legit code
;calling AllocAbs should still be dealt with ok!

; M.Meany, 1991.

		opt	p+	;signal errors if not position independant

Killer		movem.l		d0-d2/a0-a2,-(sp)	save these

; This code gets the return address to the task that called AllocAbs. I
;discovered that the SADDAM virus contains it's own name at the location
;$668 bytes from this return address, so the following code checks the 
;calling task to see if the text exsists.

		lea		VirusName(pc),a0	a0->identifier
		move.l		24(sp),a1		a1=return addr
		lea		$668(a1),a1		a1->it's home
		moveq.l		#Nlen,d0		d0=it's size - 1

; See if the give-away text is encode into the calling routine.

CheckVirus	cmp.b		(a0)+,(a1)+		
		dbne		d0,CheckVirus

; It's there so jump to stopper section.

		beq.s		GotSaddam

; If we get to here, the task is not the SADDAM VIRUS, so pass control
;to the AllocAbs routine ( naughty! self modifying code ). The jump vector
;located in execbase is copied into this routine prior to initialisation!

		movem.l		(sp)+,d0-d2/a0-a2	restore these
OldVector	dc.b		0,0,0,0,0,0		jump vector!

; If we get here, there's a bloody good chance that the SADDAM virus is
;trying to get into memory. Since the virus disables interrupts, they must
;be switched back on.

GotSaddam	jsr		_LVOEnable(a6)		interrupts on!
		movem.l		(sp)+,d0-d2/a0-a2	restore our reg's
		
; To let the poor user know he has just inserted an infected disc a 'GURU'
;alert is displayed.
	
		moveq.l		#0,d0			recoverable Alert
		lea		my_msg(pc),a0		a0->alert text
		moveq.l		#100,d1			d1=Alert height
		move.l		a6,-(sp)		save SysBase
		move.l		IntBase(pc),a6		a6->intuition
		jsr		-$005a(a6)		GURU! {DisplayAlert}
		move.l		(sp)+,a6		restore SysBase

; Since I don't know how to emulate the real disk-validator, the following
;routine just restores the stack back to the state it was in when the virus
;was executed. Forcing a return after doing this fools the system into
;thinking the disk-validator has finished. This is not the ideal way to
;trap a virus, but it will stop SADDAM from getting in and doing it's nasty
;work on all your discs.

		lea		64(a7),a7		reset the stack
		moveq.l		#0,d0			no error
		rts					back to system!

; The data required by the patch routine.

IntBase		dc.l		0
VirusName	dc.b		'SADDAM VIRUS',0
Nlen		equ		*-VirusName-1
		even

; The Alert text. Note that each text line must be an even number of bytes
;long, including the 0 terminator ( Uzie 9mm .... ), this is not mentioned in the
;ROM Kernel Reference Manuals!

my_msg	dc.w	10
	dc.b	10
	dc.b	'                              !! WARNING !!                             ',0
	dc.b	$ff
	dc.w	20
	dc.b	10
	dc.b	'     The SADDAM virus has tried to load off the last disc you inserted    ',0
	dc.b	$ff
	dc.w	30
	dc.b	10
	dc.b	'       !!!! It has been stopped, but the disc is still infected !!!!      ',0
	dc.b	$ff
	dc.w	40
	dc.b	10
	dc.b	'  You will need to use the Master Virus Killer v2.2 or higher to remove it',0
	dc.b	$ff
	dc.w	50
	dc.b	10
	dc.b	'  Contact Amiganuts United ( see press ) for a copy if you do not have it ',0
	dc.b	$ff
	dc.w	60
	dc.b	10
	dc.b	'                 **** PRESS A MOUSE BUTTON TO CONTINUE ****               ',0
	dc.b	$ff
	dc.w	70
	dc.b	10
	dc.b	'   Protection routine written by: M.Meany, Sept 91. --- Thank me later !!!',0
	dc.b	0
	even
KillerLen	equ		*-Killer



	section	Data,data
	
Title	dc.b	$9b,'1;33;40m'
	dc.b	'ACC Virus Killer V1.4 ',$9b,'0;31;40m'
	dc.b	'by Mike Cross and Mark Meany.',10,0
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
	dc.b	'Vectors All Clear.'
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
	5. Added Saddam protection. 

