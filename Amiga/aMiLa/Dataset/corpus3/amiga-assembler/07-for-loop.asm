START:
	; kopfgesteuerte Schleife zählt hoch
	clr d0 
.loop:
	cmp.w #10,d0
	beq .done
	add.w #1,d0
	; do something
	;
	;
	bra .loop
.done: 

	; kopfgesteuerte Schleife zählt runter
	move.w #10,d0
.loop:
	cmp.w #0,d0
	beq .done
	sub.w #1,d0
	; do something
	;
	;
	bra .loop
.done: