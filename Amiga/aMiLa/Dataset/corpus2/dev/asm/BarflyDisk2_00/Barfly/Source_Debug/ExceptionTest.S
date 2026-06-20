	move.l	#10,$600000	;Buserror
	jsr	1		;adresserror
	illegal			;illegal
	divu	#0,d0		;devide bye Zero
	moveq	#0,d0
	chk	4.w,d0
	trapv
	move.w	d0,sr
	dc.w	$a000
	dc.w	$ff00
	