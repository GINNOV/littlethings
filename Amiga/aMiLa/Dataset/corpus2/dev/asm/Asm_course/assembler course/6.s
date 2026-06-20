
; this is the same as 5, but a bit more structured.


top:	movem.l	d0-d7/a0-a6,-(a7)	; save regs on the stack.

loop:
	clr.l	d0			; move zeros to d0
	bsr	checkleft		; execute subroutines
	bsr	checkright		;    "		"
	bsr	selectaction		;    "		"

	cmp.l	#3,d0			; d0 = 3 ?
	bne.s	loop			; not yet !!
	
endofprogram:

	movem.l	(a7)+,d0-d7/a0-a6	; load the regs from stack
	rts

************************ subroutines ************************

checkleft:

	btst	#6,$bfe001		; check left button
	bne.s	endcheckleft		; not pressed -> end checkl.

	add.l	#1,d0			; pressed -> add 1 to d0

endcheckleft:

	rts				; back to calling point

; -------------------------------------

checkright:

	btst	#10,$dff016		; this is how you check RMB
	bne.s	endcheckright		; not pressed -> end checkr.

	add.l	#2,d0			; pressed -> add 2 to d0

endcheckright:

	rts				; back to calling point

; -------------------------------------

selectaction:

	cmp.l	#1,d0			; d0 = 1 ?
	bne.s	nobackgroundflash	; no !

	add.w	#1,$dff180		; yes !

nobackgroundflash:

	cmp.l	#2,d0			; d0 = 2 ?
	bne.s	notextflash		; no !

	add.w	#1,$dff182		; yes !

notextflash:

	rts

; -------------------------------------

; ok, this looks better ain't it ?  You see, the program has changed
; quite a bit:    we used 'SUBROUTINES'. Using them, you can
; put smaller problems (like checking the left- and the right button)
; in separate, smaller 'programs' and jump to it each time you need
; it. You will agree that it's easier to follow than example 5.

; THERE'S ONE CONSEQUENCE WHEN USING SUBROUTINES: you must keep track
; of where you enter and leave the subroutine ! An example:
;
; You write a program that is intended to execute a subroutine, over
; and over again...
;
;	main:	BSR routine
;		BRA main
;
;	routine:instruction 1
;		instruction 2
;		...
;		BRA main
;
; when you do a BSR, the computer saves this point in a list (called
; 'STACK'), so when he encounters a RTS, he can jump back to that
; point. This point will then be removed from the stack.
;	BSR (append this address to stack)
;	RTS (jump to current address in stack, remove stack-entry)
; If you do more BSR after eachother, he will store all these
; points, and the first RTS will cause him to jump back to the last
; saved point. Something like this :
;	BSR (save in stack, position 1)
;	 BSR (save in stack, position 2)
;	  ...
;	 RTS (get position 2 from stack, remove it)
;	RTS (get position 1 from stack, remove it)
;	RTS (stack empty -> back to SEKA)

; In our example, we never did a RTS, so the list would become larger
; and larger, After a while, memory will be full, and the Guru will
; awaken...
; These kind of mistakes are often pretty hard to trace :
; You dont see that there something wrong: the routine is indeed
; executed time after time, but in fact, you're about to crash !!

; NOTE: the stack can be considered as a heap of notes. On each note
;	you can write something, then you put it on top of the heap.
;	if you take one from this heap, you take the one that is on
;	top, in other words: the one you put down the latest.
;	The computer does the same, so if you put something on the
;	stack, remember only to take it back when it's there.
;	This would be wrong, for example:
;
;		BSR routine
;		...
;
;
;	routine:MOVEM.L d0-d7/a0-a6,-(a7)
;		RTS
;
; BSR causes the computer to save this point on the stack, to be
; able to jump back later...
; 'routine' puts values on the stack, using the MOVEM .. -(a7), and
; then tries to jump back from the subroutine. The last value on 
; the stack will however NOT be the address that was saved when
; jumping to the routine, but it will be one of the registers we 
; just saved. so we will jump to a completely unknown value, which
; will probably cause a GURU !!!

