
;- [ MAIN loop ] -

;///XDEF
	xdef	_Main
	xdef	_fx
	xdef	_chunky
	xdef    _starttime
	xdef	_timer
;///
;///XREF
	xref	_CGX
	xref	_blit
	xref	_window
	xref	_newpal
	xref	_gettime
	xref    _P61_Pos
;///
;///Include
	include	basemacros.i

        incdir	include:

	include	intuition/intuition.i
	include LVO/exec_lib.i
	include	LVO/intuition_lib.i
	include	LVO/graphics_lib.i
;///
;///time macro
time	macro
	jsr	_gettime
	move.l	_starttime,d1
	sub.l	d1,d0
	move.l	d0,_timer
	endm
;///

_Main
	;Initialization
	;-------------------------------[ init ]---------------------

        ;Set palette
	lea	pal,a0
	move.l	a0,_newpal	


	;Initialize timer
	jsr	_gettime
	move.l	d0,_starttime



	bsr.s	ShowTESTPic

	
        ;Main demo loop
.mainloop
        move.w	_P61_Pos,_fx

	move.w	_fx,d0
	bne.s	.fx1
.fx0	;-------------------------------[ fx #0 ]--------------------

	;do the first effect

	bra.s	.refresh
	
.fx1	;-------------------------------[ fx #1 ]--------------------
	cmp.w	#1,d0
	bne.s	.fx2

        ;do the second effect

	bra.s	.refresh

.fx2	;-------------------------------[ fx #2 ]--------------------

	;...
	;...




	;--------------------------[ refresh screen ]----------------
.refresh
        ;Blit graphics
	lea	_chunky,a0
	jsr     _blit

        ;Check for pressed mouse buttons/close window
	move.l	_window,a0
	move.l	wd_UserPort(a0),a0
	callExe	GetMsg
	tst.l	d0
	bne.s	.getout

	bra.s	.mainloop
.getout
	rts


_starttime
	dc.l	0
_timer	 dc.l	 0

_fx	dc.w	0

;--------------------------------[ effects ]-------------------
;///ShowTESTPic
ShowTESTPic
	lea	_chunky,a0
	lea	pic,a1

        move.w	#320*250/4-1,d0
.l      move.l	(a1)+,(a0)+
        dbf	d0,.l

	
        rts
;///
;--------------------------------[ various data ]--------------

;///Test Graphics
	even
pal	incbin  gfx/test.pal
pic	incbin	gfx/test.chunky
;///
	section bss,bss
;///_chunky
	ds.b	320*10	;SECURITY AREA 4 BAD CODERS ;>
_chunky	ds.b	320*256
	ds.b	320*10  ;SECURITY AREA
;///


