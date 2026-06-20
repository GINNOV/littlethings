**************	Parse tool types for this application

; Entry		a0->routine to parse argument list¹

; Exit		None

; Corrupt	d0

; ¹ -- Your routine will be called with the address pointers set as follows:

; a0	->	Next tool type in list
; a1	->	Next pointer in Tool Type array
; a2	->	???????
; a3	->	Start of your routine
; a4	->	The DiskObject for this icon
; a5	->	Preserved, same as when this routine called
; a6	->	???????

; You may do as you wish with these registers, they are restored after each
;call to your code.

ParseArgs	PUSHALL

		move.l		a0,a3			supplied routine

		tst.l		returnMsg		from WB?
		beq		.error			no, exit!

; First open icon library

		lea		iconame,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_IconBase		save base ptr
		beq.s		.error			quit if error

	; get into our directory

		move.l		returnMsg,a4		WB Message
		move.l		sm_ArgList(a4),a4	arg list ptr
		move.l		(a4)+,d1		1st arg = name+lock
		CALLDOS		CurrentDir		switch dir
		move.l		d0,d7			save old lock

; grab icon so we can examine it

		move.l		(a4),a0
		CALLICON	GetDiskObject		load icon
		tst.l		d0			load ok?
		beq.s		.NoIcon			nah, get out of here!
		move.l		d0,a4			save pointer

; Find tool type DEV ....... almost there

		move.l		do_ToolTypes(a4),a1	d0->tooltypes array
		cmp.l		#0,a1
		beq.s		.NoTypes

.ToolsList	move.l		(a1)+,a0
		cmp.l		#0,a0
		beq.s		.NoTypes

		PUSHALL					save all registers
		jsr		(a3)			call user routine
		PULLALL					restore registers

		bra.s		.ToolsList

; Free disk object

.NoTypes	move.l		a4,a0
		CALLICON	FreeDiskObject

; Back to original directory

.NoIcon		move.l		d7,d1
		CALLDOS		CurrentDir

; Close icon library

		move.l		_IconBase,a1
		CALLEXEC	CloseLibrary

; and exit

.error		PULLALL
		rts

.DevTool	dc.b		'DEV',0
		even

iconname	dc.b		'icon.library',0
		even
_IconBase	ds.l		1
