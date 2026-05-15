;;/*
;; * Queue software for scheduler v0.0
;; *
;; * Written by Billy Newport
;; *
;; */
 
		public		_InsQue
		public		_RemQue

;- - - - - - - - - - - - InsQue - - - - - - - - - - - - - - - - - 
;
; FUNCTION InsQue(SCH_queue Head, SCH_queue Elem)
;
; ACTION
;    Inserts the queue element elem before Head in the queue
;    Head is resident in.
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

_InsQue:	movea.l		4(a7),a0	; Head
		movea.l		8(a7),a1	; Elem
                move.l		4(a0),d0	; Head->Blink
                move.l		a1,4(a0)	; Head->Blink=Elem
                move.l		a0,(a1)		; Elem->Flink=Head
                movea.l		d0,a0		; A0=Head->Blink
                move.l		a1,(a0)		; kdsjfjhdks
                move.l		d0,4(a1)	; Elem->Blink=Head->Blink
		rts

_RemQueR:	reg	a0/a1

;- - - - - - - - - - - - RemQue - - - - - - - - - - - - - - - - - 
;
; FUNCTION RemQue(SCH_queue Elem)
;
; ACTION
;    Removes elem from the queue it is currently resident in.
;
; RETURNS
;    The element removed
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

_RemQue:	move.l	a1,-(sp)
		movea.l	8(sp),a0
		movem.l	(a0),_RemQueR	;Save flink (a0) and blink (a1)
                move.l	a1,4(a0)	;ftemp.b=btmep
                move.l	a0,(a1)		;btmep.f=ftemp
                movea.l	(sp)+,a1
                move.l	4(sp),d0
                rts
                

