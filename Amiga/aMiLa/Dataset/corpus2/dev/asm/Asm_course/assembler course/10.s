
; the final example for this time is a coloured bar which moves up
; and down on the screen. This is done like the previous example,
; except we make 2 waitlines in the copperlist, and change the color
; from black to white and back to black. We change the position of
; both waitcommands, so they move over the screen. When they reach
; the bottom, we change the direction and when they reach the top,
; we change it again...
; try to expand this little demo, that you get more lines moving,
; or change colors, or anything !! have fun & courage !!!



top:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	$4,a6		; start of execlib

	move.l	#libname,a1	; open the gfxlibrary...
	jsr	-408(a6)	; 
	move.l	d0,gfxbase	; store the result

				; start our own copperlist:
	move.w	#%0000001110100000,$dff096
	move.l	#copperlist,$dff080
	clr.w	$dff088
	move.w	#%1000001010000000,$dff096

	
;-------------------------------  the mainroutine of the demo

loop:	bsr	waitvblank

	bsr	movethebar

	btst	#6,$bfe001	; wellknown wait-for-click
	bne.s	loop

;------------------------------- end of the mainroutine

	move.l	gfxbase,a6		; restore the old cpprlist
	move.l	38(a6),$dff080		;
	clr.w	$dff088			;
	move.w	#%1000001111100000,$dff096

	move.l	$4,a6			; close gfxlib
	move.l	gfxbase,a1
	jsr	-414(a6)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;------------------------------- subroutines

waitvblank:
	cmp.b	#0,$dff006
	bne.s	waitvblank
	rts

;-------------------------------

movethebar:
	move.b	direction,d0
	add.b	d0,line1
	add.b	d0,line2
test1:	cmp.b	#$40,line1		; bar reached top ?
	bne.s	test2			; seems not !
	move.b	#1,direction
test2:	cmp.b	#$ff,line2		; bar reached bottom ?
	bne.s	endtest			; no !
	move.b	#-1,direction
endtest:rts

;-------------------------------

direction:	dc.b	1	; we add 'direction' to the 
		even		; current position of the bar.
				; direction can be 1 or -1...

libname:	dc.b	"graphics.library",0
		even
gfxbase:	dc.l	0	; reserve a longword for the
				; start of the library	

copperlist:
		dc.l	$01800000
line1:		dc.l	$500ffffe
		dc.l	$01800fff
line2:		dc.l	$600ffffe
		dc.l	$01800000
		dc.l	$fffffffe	; end of copperlist

