	bopt	uf
	ppc604

	xref	xref
	xdef	a

	add	0,0,0		;$00
	add	0,0,0		;$04
	
a:
	add	0,0,1		;$08
	addis	1,0,a@ha	;$0c
	ori	1,1,a@l		;$10
	bl	xref		;$14
	blr			;$18
a_end:
	.size	a,a_end-a
	.type	a,@function

	dc.l	a		;$1c
	dc.l	xref		;$20

	data

	dc.l	$12345678

	bss

	dc.l	$0
;b:
;	ds.l	$100
