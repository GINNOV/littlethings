	XDEF	_lclr
	XDEF	_lcpy

	XDEF	_f_zero
	XDEF	_f_ten
	XDEF	_f_tenth
	XDEF	_f_e10
	XDEF	_f_em10

	CODE
_lclr:
	move.l	4(sp),a0
	move.l	8(sp),d0
	bra	L2
L1:
	clr.l	(a0)+
L2:
	dbf	d0,L1
	rts

_lcpy:
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	12(sp),d0
	bra	L4
L3:
	move.l	(a1)+,(a0)+
L4:
	dbf	d0,L3
	rts

	DATA
_f_zero:
	DC.L	$00000000
_f_ten:
	DC.L	$A0000044
_f_tenth:
	DC.L	$CCCCCD3D
_f_e10:
	DC.L	$9502F962
_f_em10:
	DC.L	$DBE6FF1F

	END
