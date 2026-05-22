
; Routines to draw lines and filled rectangles in window. Again, with a
;a little effort, routines could be made generic :-) MM.

;*****
;*****		Window fill and line drawing routine
;*****

; Entry		a0->desired gfx data table
;		a1->RastPort in which to draw 
; Exit		none
; Corrupt	none


_WinGfx		movem.l		d0-d3/a0-a6,-(sp)	save registers

		move.l		a1,a5			a5->RastPort
		move.l		a0,a4			a4->data table

.DWG_Loop	move.l		(a4)+,d0
		beq		.DoneGfx

		cmp.l		#5,d0
		bgt		.DoneGfx		exit if illegal

		subq.l		#1,d0			correct

; The offset into the WinGfxVectors vextor table can now be calculated. A
;pointer to the appropriate subroutine will be obtained and the subroutine
;will be called with a4 -> the data it requires. On return, a4 should point to
;the start of the next command sequence.

		lea		.WinGfxVectors,a0
		asl.l		#2,d0
		add.l		d0,a0
		move.l		(a0),a0
		jsr		(a0)

		bra.s		.DWG_Loop

.DoneGfx	movem.l		(sp)+,d0-d3/a0-a6
		rts

;*****
;*****		Vectors assosiated with function parameters is data gfx data
;*****

.WinGfxVectors	dc.l		.w_SetPen		colour
		dc.l		.w_Move
		dc.l		.w_Draw
		dc.l		.w_Rect
		dc.l		.w_FillRect

;*****
;*****		Set drawing pen to a specified colour
;*****

.w_SetPen	move.l		a5,a1
		move.l		(a4)+,d0
		CALLGRAF	SetAPen
		rts

;*****
;*****		move to a specified position in the window
;*****

.w_Move		move.l		a5,a1
		move.l		(a4)+,d0
		move.l		(a4)+,d1
		CALLGRAF	Move
		rts

;*****
;*****		Draw a line in the window
;*****

.w_Draw		move.l		a5,a1
		move.l		(a4)+,d0
		move.l		(a4)+,d1
		CALLGRAF	Draw
		rts

;*****
;*****		Draw filled rectangles in the window
;*****

.w_Rect

.w_FillRect	move.l		a5,a1
		move.l		(a4)+,d0
		move.l		(a4)+,d1
		move.l		(a4)+,d2
		move.l		(a4)+,d3
		CALLGRAF	RectFill
		rts

