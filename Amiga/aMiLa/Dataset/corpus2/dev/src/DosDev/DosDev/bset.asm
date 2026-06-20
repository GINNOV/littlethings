
;BSET.ASM
;BZERO.ASM
;
;   Uses longword operations if data is aligned on a longword boundry
;   and the size is a mulitple of 4.  Otherwise, uses byte operations.

	xdef  _bset
	xdef  _bzero

_bzero
	clr.l	D1
	bra	begin
_bset
	move.b	15(A7),D1	;12(A7)-> msb . . lsb	(D1 = data)
begin
	move.l	4(A7),A0	;A0 = address
	move.l	8(A7),D0	;D0 = byte count
	andi.b	#3,11(A7)	;byte count on long word boundry?
	bne	drop
	andi.b	#3,7(A7)	;address on longword boundry?
	bne	drop
	bra	lwb
loop	move.b	D1,(A0)+	;BYTE SET LOOP
drop	dbf.w	D0,loop 	;remember, only effects lower word
	sub.l	#$10000,D0	;for buffers >65535
	bpl	loop		;branch to loop because D0.W now is FFFF
	rts

lwb	lsr.l	#2,D0		;byte count / 4 (longword chunks)
	tst.l	D1		;BZERO
	beq	dropl
	move.b	D1,14(A7)	;15(A7) already contains the byte
	move.w	14(A7),D1	;D1 0..15 set
	swap	D1
	move.w	14(A7),D1	;D1 16..31 set
	bra	dropl

loopl	move.l	D1,(A0)+	;BYTE SET LOOP
dropl	dbf.w	D0,loopl	;remember, only effects lower word
	sub.l	#$10000,D0	;for buffers >65535
	bpl	loopl		;branch to loop because D0.W now is FFFF
	rts



