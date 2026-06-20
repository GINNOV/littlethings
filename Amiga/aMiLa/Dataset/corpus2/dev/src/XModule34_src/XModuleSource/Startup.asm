**
** TinyC.asm
**
** Copyright (C) 1994,95 Bernardo Innocenti
**


	INCLUDE	"exec/types.i"
	INCLUDE	"exec/alerts.i"
	INCLUDE	"exec/nodes.i"
	INCLUDE	"exec/lists.i"
	INCLUDE	"exec/ports.i"
	INCLUDE	"exec/libraries.i"
	INCLUDE	"exec/tasks.i"
	INCLUDE	"exec/memory.i"
	INCLUDE	"exec/macros.i"
	INCLUDE	"exec/execbase.i"
	INCLUDE	"libraries/dos.i"
	INCLUDE	"libraries/dosextens.i"
	INCLUDE	"workbench/startup.i"



AbsExecBase	EQU	4

	xdef	@_XCEXIT
	xdef	_SysBase,_DOSBase
	xdef	_ThisTask
	xdef	_StdOut
	xdef	_WBenchMsg

	xdef	_SPrintf
	xdef	_VSPrintf
	xdef	_AsmAllocVecPooled
	xdef	_AsmFreeVecPooled
	xdef	_AsmCAllocPooled

	xref	_LinkerDB		; linker defined base value
	xref	__BSSBAS		; linker defined base of BSS
	xref	__BSSLEN		; linker defined length of BSS
	xref	___stack
	xref	___main			; Name of C entry point

	xref	_AsmAllocPooled
	xref	_AsmFreePooled



	section text,code

start:
	movem.l	d2-d7/a2-a6,-(a7)	; save registers

	NEAR
	lea _LinkerDB,a4		; load base register
	move.l	AbsExecBase.W,a6

;	lea	__BSSBAS,a3		; get base of BSS
;	moveq	#0,d1
;	move.l	#__BSSLEN,d0		; get length of BSS in longwords
;	bra.s	clr_lp			; and clear for length given
;clr_bss move.l	d1,(a3)+
;clr_lp  dbf	d0,clr_bss

	move.l	a7,_StackPtr(A4)	; Save stack ptr
	move.l	a6,_SysBase(A4)

; get the size of the stack, if CLI use cli_DefaultStack
; if WB use a7 - TC_SPLOWER

	move.l	ThisTask(A6),A3
	move.l	A3,_ThisTask(A4)
	move.l	pr_CLI(A3),d0
	beq.s	fromwb
	lsl.l	#2,D0
	move.l	D0,A0
	move.l	cli_DefaultStack(A0),D0
	lsl.l	#2,D0			; # longwords -> # bytes
	bra.s	dostack

fromwb:
	move.l	a7,d0
	sub.l	TC_SPLOWER(a3),d0
dostack:

	cmp.l	___stack(a4),d0
	bcc.s	nochange

	cmpi.w	#36,LIB_VERSION(a6)
	blt.s	nochange

; current stack is not as big as __stack says it needs
; to be. Allocate a new one.
	move.l	___stack(a4),d0
	move.l	d0,newstacksize(a4)

	move.l	#MEMF_PUBLIC,d1
	JSRLIB	AllocMem
	tst.l	d0
	beq.w	return

	move.l	d0,newstack(a4)

	add.l	___stack(a4),d0
	move.l	d0,d1

; Call StackSwap to set up the new stack.

	move.l	d0,mystk_Pointer(a4)
	move.l	d1,mystk_Upper(a4)
	sub.l	newstacksize(a4),d1
	lea	mystk_Lower(a4),a0
	move.l	d1,(a0)
	JSRLIB	StackSwap

nochange:

; clear any pending signals

	moveq	#0,d0
	move.l	#$00003000,d1
	JSRLIB	SetSignal

	move.l	ThisTask(a6),A3


; attempt to open DOS library version 37 or higher:

	lea	DOSName(PC),a1
	moveq.l	#37,d0
	JSRLIB	OpenLibrary
	move.l	d0,_DOSBase(a4)
	bne.s	ok2
	moveq.l	#100,d0
	bra.w	return

ok2:

; Find output
	move.l	d0,a6			; Load DOSBase
	JSRLIB	Output			; Call Output()
	move.l	d0,_StdOut(a4)		; Save result
	move.l	_SysBase(a4),a6		; Restore SysBase in A6

; are we running as a son of Workbench?
	move.l	pr_CurrentDir(a3),__curdir(a4)
	tst.l	pr_CLI(a3)
	bne.w	do_main


*==============================
*=== Workbench Startup Code ===
*==============================

fromWorkbench:

; we are now set up.  wait for a message from our starter
	lea	pr_MsgPort(A3),a0	; our process base
	JSRLIB	WaitPort
	lea	pr_MsgPort(A3),a0	; our process base
	JSRLIB	GetMsg
	move.l	d0,_WBenchMsg(a4)
	move.l	d0,-(SP)

	move.l	d0,a2			; get first argument
	move.l	sm_ArgList(a2),d0
	beq.s	do_main

	move.l	_DOSBase(a4),a6		; CurrentDir()
	move.l	d0,a0
	move.l	wa_Lock(a0),d1
	JSRLIB	DupLock
	move.l	d0,__curdir(A4)
	move.l	d0,d1
	JSRLIB	CurrentDir


; Call main()

do_main:
	jsr	___main(PC)	; call C entrypoint

@XCEXIT:
@_XCEXIT:

; Save Return Code
	move.l		_StackPtr(a4),a2
	move.l		d0,-(a2)

; Swap back to original stack
; If we're running under 2.0, call StackSwap
; Otherwise, just jam the new value into a7
	move.l	_SysBase(A4),A6
	tst.l	mystk_Lower(a4)
	beq.s	noswap

	lea	mystk_Lower(a4),a0
	subq.l	#4,mystk_Pointer(a4)		; make room for the ret code
	JSRLIB	StackSwap

noswap:
	movea.l	a2,a7			; restore stack ptr

; free the stack if we allocated one
	move.l	newstacksize(a4),d0
	beq.s	exit4
	move.l	newstack(A4),A1
	move.l	_SysBase(A4),A6
	JSRLIB	FreeMem

exit4:
; if we ran from CLI, skip workbench cleanup:
	tst.l	_WBenchMsg(A4)
	beq.s	ExitToDOS
	move.l	_DOSBase(A4),A6
	move.l	__curdir(a4),d1
	beq.s	done_5
	JSRLIB	UnLock

done_5:
; return the startup message to our parent
; we forbid so Workbench can't UnLoadSeg() us
; before we are done.

	move.l	_SysBase(A4),A6
	JSRLIB	Forbid
	move.l	_WBenchMsg(a4),a1
	JSRLIB	ReplyMsg



ExitToDOS:

; this rts sends us back to DOS:

	move.l	_DOSBase(A4),a1
	JSRLIB	CloseLibrary		; Close DOS

	move.l	(a7)+,d0			; Return code

return:
	movem.l	(a7)+,d2-d7/a2-a6
	rts

;*********************************
;*** Simple (V)SPrintf routine ***
;*********************************

_SPrintf:
	movem.l	a2/a3/a6,-(sp)		; Save registers

	move.l	 4+12(sp),a3		; Get destination buffer
	move.l	 8+12(sp),a0		; Get format string
	lea.l	12+12(sp),a1		; Get arguments
	lea.l	StuffChar(pc),a2	; Get formatting routine

	move.l	_SysBase(a4),a6		; Get ExecBase
	JSRLIB	RawDoFmt		; Format the string

	movem.l	(sp)+,a2/a3/a6		; Restore registers

	rts


_VSPrintf:
	movem.l	a2/a3/a6,-(sp)

	move.l	 4+12(sp),a3
	move.l	 8+12(sp),a0
	move.l	12+12(sp),a1
	lea	StuffChar(pc),a2

	move.l	_SysBase(a4),a6
	JSRLIB	RawDoFmt

	movem.l	(sp)+,a2/a3/a6

	rts

StuffChar:
	move.b	d0,(a3)+
	rts

;****************************
;*** Memory pools support ***
;****************************

;
; AsmAllocVecPooled (Pool, memSize, SysBase)
;                    a0    d0       a6
;
_AsmAllocVecPooled:
	addq.l	#4,d0		; Get space for tracking
	move.l	d0,-(sp)	; Save the size
	jsr	_AsmAllocPooled	; Call pool...
	move.l	(sp)+,d1	; Get size back...
	tst.l	d0		; Check for error
	beq.s	.fail		; If NULL, failed!
	move.l	d0,a0		; Get pointer...
	move.l	d1,(a0)+	; Store size
	move.l	a0,d0		; Get result
.fail	rts			; Return



;
; AsmFreeVecPooled (Pool, Memory, SysBase)
;                   a0    a1      a6

_AsmFreeVecPooled:
	move.l	a1,d0		; Test for NULL
	beq.s	.noblock
	move.l	-(a1),d0	; Get size / ajust pointer
	jmp	_AsmFreePooled

.noblock
	rts

;
; CAllocPooled (Pool, memSize, SysBase)
;               a0    d0       a6

_AsmCAllocPooled:
	move.l	d0,-(sp)	; Save the size
	jsr	_AsmAllocPooled	; Call pool...
	move.l	(sp)+,d1	; Get size back...
	move.l	d0,a0
	tst.l	d0		; Check for error
	beq.s	.fail		; If NULL, failed!

	move.l	d0,-(sp)	; Save result
	moveq	#0,d0
	addq	#3,d1		; Round up to longword
	lsr.l	#2,d1
	subq.l	#1,d1		; dbra does one more cycle!
.clear	move.l	d0,(a0)+	; Clear memory block
	dbra	d1,.clear
	swap	d1		; dbra only works on words
	subq.w	#1,d1
	bmi.s	.endclear
	swap	d1
	bra.s	.clear
.endclear

	move.l	(sp)+,d0	; Get result back...
.fail	rts			; Return



DOSName	dc.b	'dos.library',0

	section	__MERGED,BSS

_DOSBase	ds.l	1
_SysBase	ds.l	1
_ThisTask	ds.l	1
_StdOut		ds.l	1
_StackPtr	ds.l	1
_WBenchMsg	ds.l	1
__curdir	ds.l	1
mystk_Lower	ds.l	1
mystk_Upper	ds.l	1
mystk_Pointer	ds.l	1

newstack	ds.l	1	; pointer to new stack (if needed)
newstacksize	ds.l	1	; size of new stack

	END
