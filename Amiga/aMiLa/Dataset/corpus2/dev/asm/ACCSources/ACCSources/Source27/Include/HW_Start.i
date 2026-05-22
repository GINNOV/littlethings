
; Hardware Startup Module by M.Meany.

; To use include at the start of a program, after 'include hardware.i'.
; Your program must start with the label Main.
; eg.
;		include		hardware.i
;		include		hw_start.i
;
;Main		btst		#6,CIAAPRA		LMB pressed?
;		bne.s		Main			nope, keep waiting!
;		rts

; When your program gets called there are no active DMA or interrupts.
; Register a5 will hold the address $dff000.
; On exit, your program must return $dff000 in register a5.

*****	The hardware startup code

start		lea		$dff000,a5		hardware base


; Obtain address of systems Copper List so we can restore it later

		lea		_grafname,a1		library name
		moveq.l		#0,d0			any version
		move.l		$4,a6			exec base
		jsr		-$228(a6)		OpenLibrary()
		tst.l		d0			check!
		beq		_HW_Error		whoops, quit now!

		move.l		d0,a1			a1->GFXBase
		move.l		$26(a1),_sysCOP		save address

		jsr		-$19e(a6)		CloseLibrary()

; Stop multitasking right now!

		jsr		-$84(a6)		Forbid()

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

; Stop all DMA

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

		lea		$dff000,a5		hardware base

; Stop all interrupts and DMA

		move.w		#$7fff,DMACON(a5)	stop 'em
		move.w		#$7fff,INTENA(a5)	stop 'em

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

; Return to system

		moveq.l		#0,d0			be kind to DOS
		rts

*****	A safe interrupt handler in case Main does something naughty!

_MVM_Hand	lea		$dff000,a0
		move.w		INTREQR(a0),d0		request bits
		and.w		#$7fff,d0		clear bit 15
		move.w		d0,INTREQ(a0)		clear request
		rte					and exit

*****	Data

_grafname	dc.b		'graphics.library',0
		even

_sysINTS	ds.w		1			for interrupt bits
_sysCOP		ds.l		1			for Copper address
_sysDMA		ds.w		1			for DMA bits
_sysVECTS	ds.l		6			for autovectors

