; this source is a bit more complex. It does the following:
; left mousebutton: add 1 to the backgroundcolor (hardware register)
; right mousebutton: add 1 to the textcolor (also hardware register)
; if you press both buttons, the program will quit.
; we check the pressing of the buttons this way:
;	- move 0 to D0
;	- left button  ->  add 1 to D0
;	- right button ->  add 2 to D0
;	- now, if D0 is 0, no button was pressed
;	-      if D0 is 1, left button pressed
;	-      if D0 is 2, right MB pressed
;	-      if D0 is 3, both buttons pressed !!
; this may look complex, but think about it ! it's the simplest way!
; If a button is pressed or not can be seen in (again) some hardware
; registers. As you see: these addresses are pretty often used, and
; lists are indispendable !!

; please note: this program adds 1 to the color each time it passes
; the loop. If you run the program, you can imagine the speed of 
; the processor... the colors are changed ca a million times/second

top:	movem.l	d0-d7/a0-a6,-(a7)	; save regs

loop:
	clr.l	d0			; move zeros to d0

checkleft:

	btst	#6,$bfe001		; check left button
	bne.s	checkright		; not pressed -> checkright

	add.l	#1,d0			; pressed -> add 1 to d0

checkright:

	btst	#10,$dff016		; this is how you check RMB
	bne.s	selectaction		; not pressed -> selectact.

	add.l	#2,d0			; pressed -> add 2 to d0

selectaction:

	cmp.l	#1,d0			; d0 = 1 ?
	beq	backgroundflash		; yes it is !!

	cmp.l	#2,d0			; d0 = 2 ?
	beq	textflash		; yes it is !!

	cmp.l	#3,d0			; d0 = 3 ?
	beq	endofprogram		; yes it is !!

	bra	loop			; go back to LOOP

endofprogram:

	movem.l	(a7)+,d0-d7/a0-a6
	rts

backgroundflash:

	add.w	#1,$dff180	; the WORD at $dff180 contains the
				; backgroundcolor (see lists)
	bra	loop

textflash:

	add.w	#1,$dff182	; the WORD at $dff182 contains the
				; textcolor (see also list)
	bra	loop


; this program is very badly written. In example 6, you'll see a
; good version of it, which is much more structured, and thus 
; much better readable.  You should try to be structured when
; you write a program.
