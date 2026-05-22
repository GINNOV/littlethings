
***** Program Name	:	StopSaddam
***** Function		:	Virus Protection
***** Size		:	1010 bytes
***** Author		:	Mark Meany
***** Date		:	9th September 1991


; This program was written after I was plagued by the SADDAM VIRUS. This is
;the worst file virus I've seen so far, so bad it knocked me for six. I was
;out of action for just over three weeks because of this beast ( believe me
;I called it worse names than that! ).

; The problem arrises because the virus corrupts the disc bitmap. This means
;that if you replace an infected disk-validator with a good one, your disc
;becomes unreadable. The only way round this that I've found is using
;Master Virus Killer v2.2 to remove the virus. This is OK if you know it's
;there, that's where this proggy comes in. This code modifies AllocAbs so
;that you are notified if SADDAM tries to load. It also stops the little
;bast--- in it's tracks and prevents it from loading.

; I have made the code position independant ( PC relative or whatever buzz
;word applies ) so it can be easily converted into a boot-block routine if
;required. Very soon, probably by the time you read this, the code will have
;been added to Mike Cross's virus checker, the ACC virus checker as it's
;called.

; If the program ever identifies the virus, I suggest you save whatever you
;were working on and reset. Then use MKV v2.2 to cleanse your infected disc.

; The Master Virus Killer is available from :

;						Amiganuts United,
;						169 Dale Valley Road,
;						Southampton,
;						Hant's.

; No, I'm not on commission!!! This program is ESSENTIAL to any user who
;values his discs. 

; I hope you never have need for this program, but the day you ignore it....

; Quick greets as there is no scroll-text to be found:

; Hi to : Mike Cross ( Zaphod ), Steve Marshall, Raistlin, Blaine, Dave S,
;TreeBeard, Gary Wright and all others from Pendle Europa, Neil J, Dave
;Edwards ( The Man of Many Words ), MasterBeat, Frank ( Artwerks ), Mark
;Flemans and everyone else who keeps writing and making life interesting!

; To the idiots behind SADDAM, | , translated that's 'the finger' in smily.

; 'Live fast, code hard and die in a beautiful way', quote from DE.

; The relevant assembler include files

		incdir		df0:include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dos_lib.i

FUNCTION	equ		_LVOAllocAbs		assign function here

		opt		o+

; Open Intuition as the trapper code needs to call DisplayAlert

Start		lea		dosname(pc),a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,d7			save base ptr
		beq.s		.no_dos			quit if no lib

; NOTE: Do not include this part in a boot-block, it wont work!!!!!

		move.l		d7,a6
		jsr		_LVOOutput(a6)

		move.l		d0,d1			handle
		move.l		#TellEm,d2		text
		move.l		#TLen,d3		text len
		jsr		_LVOWrite(a6)		print it

		move.l		d7,a1			a1->lib base
		CALLEXEC	CloseLibrary

.no_dos		lea		intname(pc),a1		a1->lib name
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

.quit_fast	moveq.l		#0,d0			no DOS errors
		rts


dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
TellEm		dc.b		'StopSaddam '
		dc.b		$9b,'3;33;40m'
		dc.b		'by M.Meany, Sept 91. '
		dc.b		$9b,'0;31;40m'
		dc.b		'Written for ACC.',$0a
		dc.b		'This program will stop the SADDAM file virus ( disk-validator )',$0a
		dc.b		'from loading. Run from the CLI only with no parameters.',$0a,$0a
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

