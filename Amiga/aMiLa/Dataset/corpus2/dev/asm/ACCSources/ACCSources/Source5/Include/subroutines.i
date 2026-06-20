
; Subroutines for use in MC Group disk. M.Meany June 1990

; Subroutine to display the contents of register d6 in hex, decimal and
;binary


display_reg	movem.l	d0-d2/a0-a2,-(sp)  push registers onto stack	
	moveq.l	#0,d2	clear d2
	move.l	d2,d1	and d1
	lea	hexd,a0	initialise registers for the
	move.l	d6,d1	hex conversion routine and
	bsr	hex_con	call hex converter
	lea	decd,a0	initialise registers for the
	move.l	d6,d0	decimal conversion routine 
	bsr	dec_con	and then call it
	lea	bind,a0	initialise registers for the
	move.l	d6,d0	binary conversion routine
	bsr	bin_con	and call it
	move.l	window.ptr,d1	d1=pointer to con
	move.l	#reg_data,d2	d2=addr of text to display
	moveq.l	#len_reg_data,d3 d3=length of text to display
	CALLDOS	Write	call DOS routine to print it
	movem.l	(sp)+,d0-d2/a0-a2 restore registers
	bsr	mouse_press	wait for user
	rts		all done so leave
	
; A subroutine to convert a word to a decimal number for printing
; ENTRY     d0=word to be converted.
; CORRUPTED a0,d0,d1
; ASCII string ready for printing starts at STRSTART

dec_con	moveq	#' ',d1	d1=ASCII code of space
	move.b	d1,(a0)+	1st char=space
	move.b	d1,(a0)+	2nd char=space
	move.b	d1,(a0)+	3rd char=space
	move.b	d1,(a0)+	4th char=space
	move.b	#'0',(a0)+	5th char=a zero (routine quits
;			if called with d0=0
DIVLOOP	tst.w	d0	test if d0=0
	beq.s	FIN	if it does then exit
	divu.w	#$0A,d0	divide num by 10
	move.l	d0,d1	copy result
	swap	d1	move remainder int MSW
	addi.w	#'0',d1	convert to ASCII digit
	move.b	d1,-(a0)	store this digit
	and.l	#$FFFF,d0	mask off remainder
	bra.s	DIVLOOP	loop back for next digit
	
FIN	rts		finished so exit

; Subroutine to convert a word into a binary string for printing

; Entry d0=word to convert
;       a0-->buffer to write string into

bin_con	moveq.l	#15,d1	initialise bit count
next_bit	btst.l	d1,d0	test next bit in d0
	beq.s	add_zero	branch if not set
	move.b	#'1',(a0)+	else write a 1
	bra.s	test_done	
add_zero	move.b	#'0',(a0)+	write a 0 if not set
test_done	dbra	d1,next_bit	loop back till all done
	rts
 
; routine to convert a word into a 4 byte ASCII string for printing
; ENTRY     d1=word  a0->address to store string
; CORRUPTED d0,d1,a0

hex_con	move.w	d1,d0	get copy of word
	lsr.w	#8,d0	move MSB into LSB
	swap	d1	store word safely
	jsr	hexconvert	convert MSB
	swap	d1	retrieve word
	move.w	d1,d0	copy into d0
	jsr	hexconvert	convert LSB
	rts		finished so return

; routine to convert a byte to a 2 byte ASCII string for printing
; ENTRY d0=byte  a0->address to store string
 	
hexconvert 	move.b	d0,d1
	andi.b	#$f0,d0	mask off 1st nibble
	lsr.b	#4,d0	correct nibble position
	jsr	convert	convert to ASCII
	move.b	d1,d0	get copy of byte
	andi.b	#$0f,d0	mask off 2nd nibble
	jsr	convert	convert to ASCII
	rts		leave

convert	cmpi.b	#$0a,d0	is nibble a letter
	blt.s	add1	if not branch
	addi.b	#$07,d0	add letter offset
add1	addi.b	#$30,d0	add numeric offset
	move.b	d0,(a0)+	store value
	rts		return
; Data area used by the display_reg subroutine

reg_data	dc.w	0
	dc.b	$0A,$0A
	dc.b	'Binary   %'
bind	ds.b	16
	dc.b	$0A,$0A
	dc.b	'Hex      $'
hexd	ds.b	4
	dc.b	$0A,$0A
	dc.b	'Decimal   '
decd	ds.b	5
	dc.b	$0A,$0A
	dc.b	'     Press left mouse button to continue',$0A,$0A
end_reg_data	dc.b	0,0,0,0,0
	even
len_reg_data	equ	end_reg_data-reg_data
	
; Subroutine that waits for the left mouse button to be pressed and then
;released before returning. Use this to pause a program while the looks
;at screen displays etc.	

mouse_press	btst	#6,ciaapra
	bne	mouse_press
mouse_release	btst	#6,ciaapra
	beq	mouse_release
	rts
	
