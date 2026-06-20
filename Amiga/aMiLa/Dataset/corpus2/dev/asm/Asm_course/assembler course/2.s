; this program shows the working of indirect addressing with post-
; increment. We move first 'data' to a0 and a1.
; With a0 nothing happens, a1 is used for 3 moves with postincrement
; When you executed this source, you will again get a list with the
; status of the registers. Have a look at the contents of d0,d1 & d3
; a0 contains the address that seka assigned to label 'data'
; (type ?data, it will show the same value)
; a1 is the address after the 3 postincrements. You see that a1 is
;  3 bigger than a0, because of the postincrements.

; try to change this program, that we get WORDS moved in d0,d1 & d3.
; you'll then see that a1 will be 6 bigger than a0, after 3 postincrements
; After a MOVE.W with postincrement, the addr.reg will be increased
; with 1 WORD (=2 bytes !!), after 3 MOVE.W's that will be 6 bytes.

top:
	move.l	#data,a0	; address of 'data'-label in a0
	move.l	a0,a1		; copy value currently stored in a0
				;			       to a1
	move.b	(a1)+,d0	; byte contained in (a1) to d0, 
	move.b	(a1)+,d1	; byte contained in (a1) to d1,
	move.b	(a1)+,d2	; byte contained in (a1) to d2

	rts

data:	dc.b	1,2,3,4,5,6,7,8,9,10,11,12
	even

; note: DC.x (.B, .W or .L) means: DECLARE BYTE (or word or longword) 
;	so the values behind a 'dc.b' have the size of a byte, the ones
;	behind a 'dc.l' have a length of 4 bytes (1 longword)
;	Also note that if you have done a certain amount of dc.b's
;	and you want to put a dc.l or dc.w now, you must put 'even' first,
;	coz longwords and words can only be placed on EVEN adresses.
;	Don't worry if you forget, you will get an error message

