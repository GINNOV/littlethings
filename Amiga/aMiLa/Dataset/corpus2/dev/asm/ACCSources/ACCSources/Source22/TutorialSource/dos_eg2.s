
*****	Title		dos_eg2
*****	Function	shows how to selectively step through DOS's device
*****			list.
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	15th March 92
*****	This Revision	
*****	Notes		
*****			
*****			I must apologise. The dol_ structure does not appear
*****			to be defined in v1.3 Devpac includes. Use dl_
*****			instead! MM.

		include		start.i

; Locate start of device list

Main		move.l		_DOSBase,a6		a6->lib base struct
		move.l		dl_Root(a6),a0		a0->Root Node
		move.l		rn_Info(a0),d0		d0=BPTR
		asl.l		#2,d0			convert
		move.l		d0,a0			a0->DosInfo
		move.l		di_DevInfo(a0),d0	d0=BPTR
		asl.l		#2,d0			convert
		move.l		d0,a4			a4->device list

; Print this entries type

Loop		move.l		dl_Type(a4),d0		d0=Type
		cmp.l		#1,d0			min value
		blt.s		Next			skip if lower
		cmp.l		#2,d0			max value
		bgt.s		Next			skip if higher
		asl.l		#2,d0			get vector offset
		lea		TypeTable,a0		a0->vector table
		move.l		0(a0,d0),a0		a0->type
		bsr		Print			display it

; Print this entries name

		move.l		dl_Name(a4),d0		BPTR
		asl.l		#2,d0			convert
		move.l		d0,a0			a0->BSTR
		bsr		BPrintNL		print it

; Step on to next entry

Next		move.l		dl_Next(a4),d0		step on
		beq		Done			exit if so
		asl.l		#2,d0			convert BPTR
		move.l		d0,a4
		bra		Loop

; All entries processed, so exit.

Done		rts					exit



TypeTable	dc.l		isDevice
		dc.l		isDirectory
		dc.l		isVolume
		dc.l		isLate
		dc.l		isNBinding

isDevice	dc.b		'<DEVICE> ',0
		even
isDirectory	dc.b		'<ASSIGN> ',0
		even
isVolume	dc.b		'<DISK>   ',0
		even
isLate		dc.b		'<LATE>   ',0
		even
isNBinding	dc.b		'<NON B>  ',0
		even

