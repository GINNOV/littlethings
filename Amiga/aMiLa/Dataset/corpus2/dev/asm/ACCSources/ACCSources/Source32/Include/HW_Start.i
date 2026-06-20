
; Hardware Startup Module by M.Meany.

; Handles both CLI & Workbench startups. In both cases, system requesters
;are subdued.

; To use include at the start of a program, after 'include hardware.i'.
; Your program must start with the label Main.
; eg.
;		include		hardware.i
;		include		hw_macros.i
;
;Main		btst		#6,CIAAPRA		LMB pressed?
;		bne.s		Main			nope, keep waiting!
;		rts

; When your program gets called there are no active DMA or interrupts.
; Register a5 will hold the address $dff000.
; On exit, your program must return $dff000 in register a5.

		LIST
*** HW_Start.i v1.00, by M.Meany ***
		NOLIST

*****	The hardware startup code

start		lea		$dff000,a5		hardware base

; Save stack pointer

		move.l		a7,_initStack		save pointer

; Find our process structure and disable DOS requesters

		suba.l		a1,a1			clear
		move.l		$4,a6			SysBase
		jsr		-$126(a6)		FindTask()
		move.l		d0,a3
		move.l		#-1,184(a3)		no DOS requesters
		
; Determine if from CLI or WBench and act accordingly

		tst.l		172(a3)			from CLI?
		bne		_hwsGo			yep!, skip

		lea		92(a3),a0		a0->MsgPort
		jsr		-$180(a6)		WaitPort()
		lea		92(a3),a0
		jsr		-$174(a6)		GetMsg()
		move.l		d0,_WBmsg		and save it!

; Obtain address of systems Copper List so we can restore it later

_hwsGo		lea		_grafname,a1		library name
		moveq.l		#0,d0			any version
		move.l		$4,a6			exec base
		jsr		-$228(a6)		OpenLibrary()
		tst.l		d0			check!
		beq		_HW_Error		whoops, quit now!

		move.l		d0,a1			a1->GFXBase
		move.l		$26(a1),_sysCOP		save address

		jsr		-$19e(a6)		CloseLibrary()

; Open dos library

		lea		_dosname,a1		library name
		moveq.l		#0,d0			any version
		jsr		-$228(a6)		OpenLibrary()
		move.l		d0,_DOSBase
		beq		_HW_Error

; Stop multitasking right now!

		jsr		-$84(a6)		Forbid()

; Clear mem list structure

		lea		_mem_list,a0		a0->list head
		NEWLIST					clear structure

; Save systems DMA settings

		move.w		DMACONR(a5),_sysDMA	save DMA settings

; Save systems interrupt requirements

		move.w		INTENAR(a5),_sysINTS	save bits

; Preserve system autovectors

		lea		$64,a0			autovectors
		lea		_sysVECTS,a1		storage area
		move.l		(a0)+,(a1)+		level 1
		move.l		(a0)+,(a1)+		level 2
		move.l		(a0)+,(a1)+		level 3
		move.l		(a0)+,(a1)+		level 4
		move.l		(a0)+,(a1)+		level 5
		move.l		(a0)+,(a1)+		level 6

; Stop all DMA, paying particular attention to sprite0, the nasty little
;devil!

		CATCHVBL
		move.l		#0,COLOR16(a5)
		move.l		#0,COLOR18(a5)
		move.l		#0,COLOR20(a5)
		move.l		#0,COLOR22(a5)
		move.l		#0,COLOR24(a5)
		move.l		#0,COLOR26(a5)
		move.l		#0,COLOR28(a5)
		move.l		#0,COLOR30(a5)
		

		move.w		#$7fff,DMACON(a5)	stop 'em

; Stop all interrupts

		move.w		#$7fff,INTENA(a5)	stop 'em

; Set all autovectors to a safe handler -- just in case :-)

		lea		_MVM_Hand,a0		safe handler
		lea		$64,a1			autovectors
		move.l		a0,(a1)+		level 1
		move.l		a0,(a1)+		level 2
		move.l		a0,(a1)+		level 3
		move.l		a0,(a1)+		level 4
		move.l		a0,(a1)+		level 5
		move.l		a0,(a1)			level 6

; Stop drive motors

		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB

*****	Main is called here

; Call main program -- Must start at label Main --

		jsr		Main 

*****	The system revival code

; Reset stack pointer

QuitFast	move.l		_initStack,a7		restore stack

		lea		$dff000,a5		hardware base

; Stop all interrupts and DMA

		move.w		#$7fff,DMACON(a5)	stop 'em
		move.w		#$7fff,INTENA(a5)	stop 'em

; Free all allocated memory

		bsr		FreeAllMem
		
; Restore system autovectors

		lea		_sysVECTS,a0		autovectors
		lea		$64,a1			storage area
		move.l		(a0)+,(a1)+		level 1
		move.l		(a0)+,(a1)+		level 2
		move.l		(a0)+,(a1)+		level 3
		move.l		(a0)+,(a1)+		level 4
		move.l		(a0)+,(a1)+		level 5
		move.l		(a0)+,(a1)+		level 6

; Restore system interrupt requirements

		move.w		_sysINTS,d0		get bits
		or.w		#SETIT!INTEN,d0		set bits 14 & 15
		move.w		d0,INTENA(a5)		set requirements

; Restore system DMA requirements

		move.w		_sysDMA,d0		DMA settings
		or.w		#SETIT!DMAEN,d0		set enable bits
		move.w		d0,DMACON(a5)		restore DMA

; Restart systems Copper List

		move.l		_sysCOP,COP1LCH(a5)	write address
		move.w		#0,COPJMP1(a5)		start list

; Restart multitasking

_HW_Error	move.l		$4,a6			exec base
		jsr		-$8a(a6)		Permit()

; Report any errors

		bsr.s		_hw_test_error

; If started from WorkBench, reply the message now

		tst.l		_WBmsg
		beq.s		_hwsdone

		move.l		$4,a6
		jsr		-$084(a6)		Forbid()
		move.l		_WBmsg,a1
		jsr		-$17a(a6)		ReplyMsg()
		
; Return to system

_hwsdone		moveq.l		#0,d0			be kind to DOS
		rts

*****	A safe interrupt handler in case Main does something naughty!

_MVM_Hand	lea		$dff000,a0
		move.w		INTREQR(a0),d0		request bits
		and.w		#$7fff,d0		clear bit 15
		move.w		d0,INTREQ(a0)		clear request
		rte					and exit

*****	Error handler

; To use error function, put a pointer to null terminated text in _ErrText. 

_hw_test_error	tst.l		_ErrText
		beq		_hwsdone

; Open intuition library

		lea		_intname,a1
		moveq.l		#0,d0
		move.l		$4,a6
		jsr		-$228(a6)		OpenLibrary()
		move.l		d0,d7
		beq		_hwsdone1

; Open error window

		move.l		d0,a6
		lea		_err_win_defs,a0
		jsr		-$0cc(a6)		OpenWindow()
		move.l		d0,d6
		beq		_hwswin_error

; Print error message

		move.l		d0,a0
		move.l		86(a0),d5		*UserPort
		move.l		50(a0),a0		*RastPort
		lea		_err_win_text,a1	*IntuiText
		moveq.l		#0,d0
		move.l		d0,d1
		jsr		-$0d8(a6)		PrintIText()

; Wait for a message to arrive

		move.l		$4,a6		SysBase

_hwsWaitForMsg	move.l		d5,a0		a0-->user port
		jsr		-$180(a6)	WaitPort()
		move.l		d5,a0		a0-->window pointer
		jsr		-$174(a6)	GetMsg()
		tst.l		d0		was there a message ?
		beq.s		_hwsWaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		20(a1),d2	d2=IDCMP flags
		jsr		-$17a(a6)	ReplyMsg()
		cmp.l		#$40,d2		gadget clicked?
		bne.s		_hwsWaitForMsg	loop if not

; Close the window

		move.l		d6,a0
		move.l		d7,a6
		jsr		-$048(a6)	CloseWindow()

; Close intuition.library

_hwswin_error	move.l		d7,a1
		move.l		$4,a6
		jsr		-$19e(a6)	CloseLibrary()

_hwsdone1		rts

*****	Routine to define an error message. Will not copy over an earlier one

; Entry		a0->null terminated text

SetError	tst.l		_ErrText
		bne.s		_hwsdone2
		move.l		a0,_ErrText
_hwsdone2		rts

*****	Data for error message window

_err_win_defs	dc.w		75,85
		dc.w		500,50
		dc.b		0,1
		dc.l		$40
		dc.l		$21002
		dc.l		_err_OK_gadg
		dc.l		0
		dc.l		_err_win_name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		$1

_err_win_name	dc.b		'                     Program Error Report',0
		even

_err_OK_gadg	dc.l		_hwsgadg1
		dc.w		1,-17
		dc.w		1,1
		dc.w		$8
		dc.w		$82
		dc.w		$1
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

_hwsgadg1		dc.l		0
		dc.w		222,-13
		dc.w		52,9
		dc.w		$8
		dc.w		$81
		dc.w		$1
		dc.l		_hwsBorder
		dc.l		0
		dc.l		_hwsIText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

_hwsBorder		dc.w		0,0
		dc.b		1,0,0
		dc.b		5
		dc.l		_hwsVectors
		dc.l		0

_hwsVectors	dc.w		0,0
		dc.w		52,0
		dc.w		52,9
		dc.w		0,9
		dc.w		0,0

_hwsIText		dc.b		1,0,1,0
		dc.w		2,1
		dc.l		0
		dc.l		_hwsText
		dc.l		0

_hwsText		dc.b		'* OK *',0
		cnop 0,2


_err_win_text	dc.b		1,0,1,0
		dc.w		12,19
		dc.l		0
		dc.l		_hwsText1
		dc.l		_hwsIText1

_hwsText1		dc.b		'Error:',0
		even

_hwsIText1		dc.b		1,0,1,0
		dc.w		65,19
		dc.l		0
_ErrText	dc.l		0
		dc.l		0

*****	Data

_grafname	dc.b		'graphics.library',0
		even
_dosname	dc.b		'dos.library',0
		even
_intname	dc.b		'intuition.library',0
		even

_DOSBase	ds.l		1			for lib base addr
_sysINTS	ds.w		1			for interrupt bits
_sysCOP		ds.l		1			for Copper address
_sysDMA		ds.w		1			for DMA bits
_sysVECTS	ds.l		6			for autovectors
_initStack	ds.l		1			for stack pointer
_WBmsg		ds.l		1			workbench message

		ifnd		mem_routines
		include		HW_Memory.i
		endc
