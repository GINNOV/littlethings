
; we will now make a copperlist with 1 wait line. 
; the starting and ending of the copperlist is the same as in the
; previous program, but we now change the position of the wait-line
; in the copperlist, so the 'colorbar' seems to move over the screen

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

loop:	cmp.b	#00,$dff006	; check if the electronbeam of the
	bne.s	loop		; monitor has reached the top of the
				; screen. This moment is the famous
				; VERTICAL BLANK. Most demos use the
				; verticale blank to start a routine
				; We will do this to. Remove these 
				; 2 lines, and have a look what
				; happens...

	; this is our 'demoroutine' :

	add.b	#1,waitline	; waitline is a label in our cpprlst
				; by changing the first byte in it,
				; we change the vertic.waitposition
				; of the waitcommand (check it out!)

	btst	#6,$bfe001	; wellknown wait-for-click
	bne.s	loop

	move.l	gfxbase,a6		; restore the old cpprlist
	move.l	38(a6),$dff080		;
	clr.w	$dff088			;
	move.w	#%1000001111100000,$dff096

	move.l	$4,a6			; close gfxlib
	move.l	gfxbase,a1
	jsr	-414(a6)

	movem.l	(a7)+,d0-d7/a0-a6
	rts


libname:	dc.b	"graphics.library",0
		even
gfxbase:	dc.l	0	; reserve a longword for the
				; start of the library	

copperlist:
		dc.l	$01800444
waitline:	dc.l	$400ffffe
		dc.l	$01800888
		dc.l	$fffffffe	; end of copperlist

