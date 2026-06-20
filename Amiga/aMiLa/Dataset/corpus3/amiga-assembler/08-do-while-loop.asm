START:
	; fußgesteuerte Schleife
	move.w #10,d0
.loop:
	; do something
	;
	;
	dbf d0,.loop
.done:
	nop
	rts
	