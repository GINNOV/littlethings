
; This routine was given to me by spanner.

; the routine itself is used to load various hardware registers into
; either the background colour (180) or the foreground colour (182)

; look in the back of the hardware reference manual for registers that
; are read, you can also use write only registers (at your own choice)
; but this is more trial and error.

loop:
	move.w	$dff006,$dff180	; = background
	move.w	$dff006,$dff182	; = foreground
   	btst	#$a,$dff016	; = test for right mouse button
   	bne	loop		
   	moveq	#0,d0
   	rts

; some registers to try:-

;  * dff010 * dff058 * dff0e0 * dff0e2 * dff00e * dff080 * dff088 *
;  * dff08a * dff094 * dff092 * dff090 * dff08e * dff002 * dff01a *
;  * dff020 * dff01c * dff01e * dff00a * dff00c * dff036 * dff014 *
;  * dff142 * dff038 * dff03c * dff02a	
