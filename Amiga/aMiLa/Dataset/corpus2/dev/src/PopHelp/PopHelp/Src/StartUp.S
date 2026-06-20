; StartUp.S For Resident PopHelp By MpL 08.06.1993
;-------------------------------------------------
; $VER: StartUp.S v1.00
; This source code is freeware, but (C) Mika Lundell.
; This source code is part of the PopHelp package.
; Use it as you like. Compiles straight with A68k.

	;	incdir	"Include"
		include	"Equs21.i"

		xref	_main

		move.l	$4,a6
		sub.l	a1,a1
		jsr	FindTask(a6)
		move.l	d0,a4

		move.l	pr_CLI(a4),d0
		beq.s	FromWB

		moveq	#0,d0
		move.l	d0,-(sp)
		bra.s	DoMain

FromWB		lea	pr_MsgPort(a4),a0	; GetWBMsg
		jsr	WaitPort(a6)
		lea	pr_MsgPort(a4),a0
		jsr	GetMsg(a6)
		move.l	d0,-(sp)

DoMain		jsr	_main

		move.l	$4,a6
		move.l	(sp)+,d0
		beq.s	WasCLI

		jsr	Forbid(a6)
		move.l	d0,a1
		jsr	ReplyMsg(a6)

WasCLI		moveq	#0,d0
		rts
		end
