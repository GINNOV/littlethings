;DeltaTracker ReplaySource
;Coded By Matthew Wakeling (Wig of Exile)
;Coded on 27/01/91

	opt	ow-,w-,c-		;Optomise,Warnings off, capitialise

start:
	bset 	#1,$bfe001		;Disable L.E.D
	jsr 	DeltaPlay		;Initialise DeltaModule

wait_raster:
	cmp.b	#200,$dff006		;Pause until line 200
	bne.s	wait_raster		;Loop
	jsr 	DeltaPlay		;Play DeltaModule
	btst 	#6,$bfe001		;Test for Left Button
	bne.s 	wait_raster		;Loop

exit:
	bchg 	#1,$bfe001		;Reanble L.E.D
	clr.w	$dff0a8			;Clear Channel 1
	clr.w	$dff0b8			;Clear Channel 2
	clr.w	$dff0c8			;Clear Channel 3
	clr.w	$dff0d8			;Clear Channel 4
	rts				;Exit to dos	

	section	DeltaChip,Code_C	;Place DeltaModule in Chipram

DeltaPlay	incbin "df1:synchro"	;DeltaModule File Name
