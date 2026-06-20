	dc.b	"DOS",0
	dc.l	0,$370
 	move.w	#2,28(a1)
 	move.l	#$30000,40(a1)		load address
 	move.l	#0*512,44(a1)		offset
 	move.l	#2*512,36(a1)		length in sectors
	move.l	$4.w,a6
	jsr	-456(a6)
	
;	jmp	$30000
loop	move.w	$dff006,$dff180
	bra	loop
		
	dc.b	"This is a boot_loader not a virus",0,0,0,0,0
	dc.b	" Loader by SEA HAWK with the help of SPANNER",0
