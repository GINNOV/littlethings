
; Boot Code for Non Fast Mem routine.

; M.Meany. March 15, 1991.

; This is a corrected ( and commented ) version of Dave Shaws code that he
;sent to me. Assemble ( no DEBUG info ) to disk and then use BootWriter to
;put it on boot block of drive 0.

; In an effort to please the multitudes ( Raistlin ) I have not used any
;Include files here, so it assembles quicker. I have used the correct offset
;for OpenLibrary. Put a couple of macros at the front to make things easier
;to follow. MM.

;--------------	Macros

CALLEXEC	macro
		move.l		$4.w,a6
		jsr		\1(a6)
		endm

CALLINT		macro
		move.l		_IntuitionBase,a6
		jsr		\1(a6)
		endm

;--------------	Library offsets

OpenLibrary	=		-552
CloseLibrary	=		-414
FindResident	=		-96
AvailMem	=		-216
AllocMem	=		-198
DisplayAlert	=		-90

;--------------	Constants

RECOVERY_ALERT	=		$0
MEMF_FAST	=		$4
MEMF_LARGEST	=		$20000

;--------------	Standard Boot Code

		movem.l		d0-d7/a0-a6,-(sp)	;save reg
		bsr.s		Main			;branch to main
		movem.l		(sp)+,d0-d7/a0-a6	;restore regs

;--------------	Standard Boot Exit Code

		lea		dosname(pc),a1		lib name
		CALLEXEC	FindResident		check exsistance
		tst.l		d0			well ?
		beq.s		not_there		if not flag error
		move.l		d0,a0			else get safe addr
		move.l		$16(a0),a0		into a0 from ROM TAG
		moveq.l		#0,d0			flag all is OK
exit:		rts					and KickStart

not_there:
		moveq.l		#-1,d0			flag error (re-boot)
		bra.s		exit			and KickStart

;--------------	First open the intuition library

Main		lea		intname(pc),a1		a1->lib name
		moveq.l		#0,d0			d0=0, any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		error			leave if error

;--------------	Now display the alert

		moveq.l		#RECOVERY_ALERT,d0	alert number
		move.l		#150,d1			height
		lea		alert_text(pc),a0	ptr to message
		CALLINT		DisplayAlert		do Guru
bp1		tst.l		d0
		beq.s		all_done

;--------------	LMB pressed, so gobble up all FAST memory

mem_loop	move.l		#MEMF_FAST!MEMF_LARGEST,d1 mem type
		CALLEXEC	AvailMem		get largest
		tst.l		d0			is it 0 bytes ?
		beq.s		all_done		if so leave
		moveq.l		#MEMF_FAST,d1		mem type
		CALLEXEC	AllocMem		gobble it
		tst.l		d0			did we get it
		bne.s		mem_loop		if so go get more

;--------------	Close intuition library

all_done	move.l		_IntuitionBase,a1	a1=base ptr
		CALLEXEC	CloseLibrary		and close it

error		rts

;--------------	Data Section
	
dosname		dc.b	'dos.library',0
		even

intname		dc.b		'intuition.library',0
		even
_IntuitionBase	dc.l		0

; Undocumented bug in DisplayAlert. All Texts must be an even number of bytes
;long, including the terminating 0. Failure to follow this will crash the
;system and will corrupt the display of your alert. MM.

alert_text	dc.w		150
		dc.b		15
		dc.b		'MEMORY CONTROL V1,000,000',0
		dc.b		$ff

		dc.w		150
		dc.b		25
		dc.b		'    CODED BY THE DJ',0
		dc.b		$ff

		dc.w		150
		dc.b		35
		dc.b		'       14/3/91 ',0
		dc.b		$ff

		dc.w		100
		dc.b		50
		dc.b		'Special thanks go to Mark, Mike and Steve',0
		dc.b		$ff

		dc.w		100
		dc.b		60
		dc.b		'for all their help. Keep up the good work. ',0
		dc.b		$ff

		dc.w		50
		dc.b		100
		dc.b		'LEFT BUTTON : MEM-OFF',0
		dc.b		$ff

		dc.w		400
		dc.b		100
		dc.b		'RIGHT BUTTON : MEM-ON',0
		dc.b		$00
		
		even
