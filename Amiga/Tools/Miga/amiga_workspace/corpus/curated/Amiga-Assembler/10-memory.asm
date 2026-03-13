START:
	; creates some values in memory
	dc.b	$5
	dc.b	$EE
	dc.w	$AAFF
	dc.b	0
	dc.b	"Hello World",0
	
	ds.w	10
	ds.b	5
	
	nop
	nop