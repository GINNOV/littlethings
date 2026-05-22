
;This example shows how to use the assembled module
;before Your own sourecode...

	incbin	Start-4000.bin		;add full path if necessary!
MyCode:
	rol.w	$dff182
	btst	#$6,$bfe001
	bne.b	MyCode
	rts

