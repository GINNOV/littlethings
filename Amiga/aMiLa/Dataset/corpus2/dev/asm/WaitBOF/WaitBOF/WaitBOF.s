;
; $VER: WaitBOF 1.1 (20.8.95)
;
; by Bruce M. Simpson <bsimpson@touchdwn.demon.co.uk>
;
;
; void WaitBOF(void);
;
; wait for a copper interrupt
;
; builds an interrupt node on the stack like WaitTOF, but adds it to the
; system INTB_COPER queue, rather than graphics.library's private TOF list.
;
; we have a bit of a problem if we want to use this with a viewport.  One
; way of solving this is to have the cmove which enables the copint as the
; last instruction of a user copperlist after a final cwait - that way we get
; multitasking friendly WaitBOVP(). The code provided is such that you
; SHOULD NOT TRY WAITING FOR ANYTHING ELSE - it uses the task's SINGLE
; signal bit so that we don't have to AllocSignal().
;
; For this to work, you have to get the copper to request a copper
; interrupt after the line you want to wait for.  Normally you'd use it
; like this:
;
;	cwait	FINALLINE,0
;	cmove	INTF_SETCLR|INTF_COPER,intreq
;	cend
;
;

	incdir	dpinclude:

	include	exec/types.i
	include	exec/tasks.i
	include	exec/nodes.i
	include	exec/interrupts.i
	include	exec/execbase.i
	include	hardware/custom.i
	include	hardware/intbits.i

	include	exec/exec_lib.i
	include	mymacros.i

	IDNT	WaitBOF.s
	SECTION	text,CODE
	XDEF	_WaitBOF


_WaitBOF
	move.l	a6,-(sp)
	suba.w	#IS_SIZE,sp
	move.l	4.w,a6						; get SysBase

	moveq	#0,d0
	moveq	#SIGF_SINGLE,d1
	jsr		_LVOSetSignal(a6)			; clear any pending signal

	move.w	#INTF_INTEN,_custom+intena
	addq.b	#1,IDNestCnt(a6)			; disable all interrupts

	move.b	#10,LN_PRI(sp)				; build task's interrupt signaller
	move.b	#NT_INTERRUPT,LN_TYPE(sp)	; on the stack
	lea		CopSigIntName(pc),a0
	move.l	a0,LN_NAME(sp)
	move.l	ThisTask(a6),IS_DATA(sp)	; data is task ptr
	lea		CopSigIntCode(pc),a0
	move.l	a0,IS_CODE(sp)

	move.l	sp,a1
	moveq	#INTB_COPER,d0
	jsr		_LVOAddIntServer(a6)		; add it

	moveq	#SIGF_SINGLE,d0				; use the SINGLE bit.
	jsr		_LVOWait(a6)				; wait implies Enable()

	move.l	sp,a1
	moveq	#INTB_COPER,d0
	jsr		_LVORemIntServer(a6)		; remove task signaller interrupt

	subq.b	#1,IDNestCnt(a6)			; we must update counter first!
	bge.s	IntsActuallyActive
	move.w	#INTF_SETCLR!INTF_INTEN,_custom+intena

IntsActuallyActive
	adda.w	#IS_SIZE,sp
	move.l	(sp)+,a6
	rts

; single task interrupt server. Later versions of this code may fire off
; signals to a list of tasks on a private copper interrupt chain.



	alignlong

CopSigIntCode
	move.l	a1,d0				; catch NULL ptrs
	beq.s	noTask
	move.l	4.w,a6
	moveq	#SIGF_SINGLE,d0
	jsr		_LVOSignal(a6)		; signal our task
noTask
	lea		_custom,a0			; some servers expect this
	moveq	#0,d0
	rts


	alignlong

CopSigIntName	dc.b	"WaitBOF Task Signaller",0



	END							; WaitBOF.s
