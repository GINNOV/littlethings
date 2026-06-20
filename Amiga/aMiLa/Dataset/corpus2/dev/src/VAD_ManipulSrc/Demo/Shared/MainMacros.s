; ===========================================================================
; Name:		Main macros
; File:		MainMacros.s
; Author:	Noe / Venus Art
; Copyright:	© 1995 by Venus Art
; ---------------------------------------------------------------------------
; History:
; 30.04.1995	AllocMemBlocks, FreeMemBlocks, SetView
;
; ===========================================================================

; ===========================================================================
; Macro:	AllocMemBlocks
; Function:	Allocate memory blocks
; In:
;	\1	MemList struct
; Out:
;		if error then Z flag is clear, else Z flag is set and...
;	d0.l	pointer to allocated MemList struct,
; Crash regs:
;	d0/d1/a0/a1,a6
; ===========================================================================

AllocMemBlocks	MACRO	MemList
		lea	\1,a0
		move.l	4.w,a6
		jsr	_LVOAllocEntry(a6)
		bclr.l	#31,d0
		ENDM


; ===========================================================================
; Macro:	FreeMemBlocks
; Function:	Free allocated memory blocks
; In:
;	\1	pointer to MemList struct to deallocated
; Out:
;	none
; Crash regs:
;	d0/d1/a0/a1/a6
; ===========================================================================

FreeMemBlocks	MACRO	MemListPtr
		move.l	\1,a0
		move.l	4.w,a6
		jsr	_LVOFreeEntry(a6)
		ENDM


; ===========================================================================
; Macro:	SetView
; Function:	Set view size
; In:
;	a5.l	CUSTOM base
;	\1	horizonthal offset
;	\2	vertical offset
;	\3	view width
;	\4	view hieght
;	\5	resolusion: LORES or HIRES
; Out:
;	none
; Crash regs:
;	none
; ===========================================================================

LORES		=	8
HIRES		=	4

SetView		MACRO	HOffset, VOffset, ViewWidth, ViewHeight, Resolusion

		move.w	#\2<<8+\1,diwstrt(a5)
		move.w	#((\2+\4)&$00ff)<<8+(\1+\3)&$00ff,diwstop(a5)

		move.w	#\1>>1-\5,ddfstrt(a5)
		move.w	#\1>>1-\5+(\5*(\3>>4-8/\5)),ddfstop(a5)

		ENDM


; ===========================================================================
; Macro:	WaitBlitter
; Function:	Wait until blitter is bussy
; In:
;	a5.l	CUSTOM base
; Out:
;	none
; Crash regs:
;	none
; ===========================================================================

WaitBlitter	MACRO

wb\@		btst.b	#14-8,dmaconr(a5)
		bne.b	wb\@

		ENDM
