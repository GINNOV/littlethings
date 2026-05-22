
; Program to test integrity of acc.library.

; Function	: To display a list of all entries in a specified directory.
; Program size	: 232 bytes.
; Author	: M.Meany.
; Data		: 10-10-91.

; This program is a simple DIR utility. Enter the name of the directory you
;want listed as a CLI parameter.

; NOTE: 	1/ All subdirectories are preceeded with a D.
;		2/ All files are preceeded with a F.
;		3/ The first entry is the directorys 'physical' name.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		df1:project/lib_development/acc_lib.i

Start		move.b		#0,-1(a0,d0)	NULL terminate entry
		move.l		a0,a4		save addr of dirname

		lea		accname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	open it
		move.l		d0,_AccBase	save base pointer
		beq.s		.quitfast	quit if error

		lea		_DOSBase,a0	a0->addr for lib ptrs
		CALLACC		GetLibs		get lib pointers

		CALLDOS		Output
		move.l		d0,CLI_OUT

		move.l		a4,a0		a0->filename
		CALLACC		GetDirList	and get directory
		move.l		d0,d7
		beq.s		.error

		move.l		d0,a0		a0->list header
		bsr.s		PrintList	display list contents

		move.l		d7,a0
		CALLACC		FreeDirList

.error		move.l		_AccBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close it

.quitfast	rts				Byeeee!


*****************************************************************************

; Subroutine to print out all nodes in a list.

; Entry		a0->list header
; Exit		None
; Corrupted	d0,d1,a0,a1

PrintList	move.l		a4,-(sp)	save work registers
		move.l		d4,-(sp)
		move.l		a0,a4		copy header pointer

		move.l		(a4),d4		d4 = addr of next node

.loop		move.l		d4,a0		a0->node to print
		tst.l		(a0)		is this the tail?
		beq.s		.error		yep! so quit loop

		move.l		(a0),d4		d4=addr of next node

		move.l		nd_Data(a0),a0	a0->ASCII text of node
		move.l		CLI_OUT,d0	handle
		CALLACC		DOSPrint	print this nodes text

		lea		EOL,a0		a0->line feed
		move.l		CLI_OUT,d0	handle
		CALLACC		DOSPrint

		bra.s		.loop		loop back for next node

.error		move.l		(sp)+,d4	restore registers
		move.l		(sp)+,a4
		rts				all done so quit

***************
***************
***************

accname		dc.b		'df1:project/lib_development/acc.library',0
		even
_AccBase	dc.l		0
_DOSBase	dc.l		0
_IntuitionBase	dc.l		0
_GfxBase	dc.l		0

CLI_OUT		dc.l		0

EOL		dc.b		$0a,0
		even


