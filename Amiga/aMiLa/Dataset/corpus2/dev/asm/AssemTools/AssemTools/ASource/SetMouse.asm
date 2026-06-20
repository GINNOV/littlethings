;
; ### SetMouse by JM v 1.00 ###
;
; - Created 880801 by JM -
;
;
; This file is a direct translation from the one written in 'C'
; by Kodiak, Commodore-Amiga Inc.
;
; Translated for use in The Grid II.
;
;
;
;
; Bugs: yet unknown
;
;
; Edited:
;
;
;



		include	"exec.xref"
		include	"JMPLibs.i"


		subq.l	#2,d0
		bmi	setmouse

		move.b	(a0),d0
		and.b	#1,d0
		move.b	d0,mouseport


setmouse	lea	indevname(pc),a0	input.device
		moveq.l	#0,d0			unit#
		lea	iorequest(pc),a1	IoReq
		moveq.l	#0,d1			flags
		lib	Exec,OpenDevice
		move.l	d0,ODerror		flag: error if > 0
		bne	cleanup			if error

		lea	msgport(pc),a2
		move.b	#4,8(a2)		msgport.mp_Node.ln_Type = 4
		clr.b	14(a2)			msgport.mp_Flags = 0

		moveq.l	#-1,d0
		lib	Exec,AllocSignal	get a signal bit
		move.l	d0,ASerror
		bmi	cleanup

		move.b	d0,15(a2)		msgport.mp_SigBit = d0

		sub.l	a1,a1
		lib	Exec,FindTask		find this task
		move.l	d0,16(a2)		msgport.mp_SigTask

		move.l	a2,a0			NewList(list)
		move.l	a0,(a0)
		addq.l	#4,(a0)			#lh_Tail
		clr.l	4(a0)			lh_Tail
		move.l	a0,8(a0)		lh_TailPred

		move.l	a2,d0
		lea	iorequest(pc),a2
		move.l	d0,14(a2)		ioreq.io_Message.mn_ReplyPort

		move.w	#14,28(a2)		ioreq.io_Command = IND_SETMPORT
		lea	mouseport(pc),a0
		move.l	a0,40(a2)		ioreq.io_Data = &mouseport
		move.l	#1,36(a2)		ioreq.io_Length = 1

		move.l	a2,a1
		lib	Exec,DoIO		set mouseport



cleanup		move.l	ODerror(pc),d0		test if input.device open
		bne	cleanup1
		lea	iorequest(pc),a1
		lib	Exec,CloseDevice	close input.device

cleanup1	move.l	ASerror,d0		test if a signal allocated
		bmi	cleanup2
		lib	Exec,FreeSignal		free it

cleanup2	rts


iorequest	dcb.b	48,0			struct IOStdReq
msgport		dcb.b	34,0			struct MsgPort
ODerror		dc.l	-1
ASerror		dc.l	-1

indevname	dc.b	'input.device',0
mouseport	dc.b	0

		libnames
		end

