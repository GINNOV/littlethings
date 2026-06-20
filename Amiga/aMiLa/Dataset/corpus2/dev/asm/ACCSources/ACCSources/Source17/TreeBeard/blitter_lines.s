; Draws a line using the blitter directly onto the screen

	opt	c-

width	=	40		; Width of screen

; Variable `address' is set later to prevent forward reference errors, but 
; equals the the top of the screen (or workspace, or whatever), so in this
; examle it equals screen.

	section	Treeb,code_c
	include source:include/hardware.i
	move.l	4,a6		; Open Gfx library
	lea	library,a1
	jsr	-408(a6)
	move.l	d0,base
	move.l	#screen,d0	; Put the address of my (2 colour) bitplane
	move.w	d0,b1l		; into the copper list
	swap	d0
	move.w	d0,b1h
	lea	$dff000,a5	; a5 = hardware offset
	move.l	#copper,cop1lch(a5)	; Put our copper in
	move.w	#0,copjmp1(a5)
	lea	screen,a1	; Clear the screen
	move.l	#2559,d0	; (256 * 40) / 4 long words -1
clear	move.l	#0,(a1)+
	dbra	d0,clear
	move.l	#160,d0		; d0 = x co-ord of start point (160,128)
	move.l	#128,d1		; d1 = y co-ord of start point
	move.l	#200,d2		; d2 = x co-ord of end point (200,240)
	move.l	#240,d3		; d3 = y co-ord of end point
	bsr	drawline	; Draw the line (never ave guessed eh)
wait	btst	#6,$bfe001	; LMB ?
	bne.s	wait
	move.l	base,a2		; Re-enter old copper list
	move.l	38(a2),cop1lch(a5)
	rts			; Quit

; d0 = xpos of start
; d1 = ypos
; d2 = xpos of end
; d3 = ypos

; On exit all regs preserved

drawline

; If the start and end points are the same (this might happen in 3D
; vectors, etc.) we must exit without doing anything

	cmp.w	d0,d2			; x1 and x2 the same?
	bne.s	draw1			; no, carry on
	cmp.w	d1,d3			; y1 and y2 the same?
	beq	exit			; Yes, quit now
draw1	movem.l	d0-d5/a0,-(sp)
.loop	btst	#14,dmaconr(a5)	; Wait for BBusy, suprise, supries
	bne.s	.loop
	move.w	#width,bltcmod(a5)	; C and D modulos = width of screen
	move.w	#width,bltdmod(a5)	

; Gets address at which the start of the line is situated:
; = `address' + ypos * 40 + xpos / 8
;    (start of screen)

	move.w	d1,d5		; d5 = ypos * 40
	mulu	#width,d5
	move.w	d0,d6		; d6 = xpos / 8
	lsr.w	#3,d6
	bclr	#0,d6		; Make it an even address
	add.l	d6,d5		; Add them together
	add.l	#address,d5	; Add start of screen
	move.l	d5,bltcpth(a5)	; Put it into C and D pointers
	move.l	d5,bltdpth(a5)
	clr.l	d5		; d5 is octant counter

; The octant counter is a number which has bits set according to certain
; events

; bit 2 set if x2-x1 is negative
;     1 set if y2-y1 is negative
;     0 set if dy>dx

; This does not provide the octant number the blitter uses, but it still
; does identify the octant, and a table is used to get the number the
; blitter needs: eg. if x2-x1 is positive, bit 2 is clear
; 			y2-y1 is negative, bit 1 is set
;			dy>dx, bit 0 is set, which gives us 3.
; Looking at the fourth (3+1) entry in the octant table, this will give
; the octant number the blitter recognises it by - %001.  In the table
; the number is in the place it is needed in bltcon1, and bit 0 is set
; since bit 0 of bltcon1 is the line draw mode.  So in the table the
; actual number is %00101.

	move.w	d2,dx		; dx = ABS (x2 - x1)
	sub.w	d0,dx
	bpl.s	dl1		; Branch if result positive
	bset	#2,d5		; Set bit 2 of octant counter
	neg.w	dx		; Make dx positive (the ABS bit)
dl1	move.w	d3,dy		; dy = ABS (y2 - y1)
	sub.w	d1,dy
	bpl.s	dl2		; Branch if the result is positive
	bset	#1,d5		; Set bit 1 of octant counter
	neg.w	dy		; Make dy positive

; This part makes ds = the smallest out of dx and dy
;		  dl = the largest out of dx and dy

dl2	move.w	dy,a0		; Compare dx and dy (can't be done in a
	cmp.w	dx,a0		; single command)
	bcs	dl3		; if dy is smaller branch
	move.w	dy,dl		; dy is largest
	move.w	dx,ds		; dx is smallest
	bset	#0,d5		; Set bit 0 of octant counter
	bra	dl4		; do next part
dl3	move.w	dy,ds		; dy is smallest
	move.w	dx,dl		; dx is largest

; We now have our version of the octant number, so get the blitter's

dl4	lea	octants,a0	; Start of octant table in a4
	lsl.l	d5		; Times our number by 2 - entries in table
				; are a word long
	add.l	d5,a0		; Add to start of octant table
	move.w	(a0),d5		; Get it
	move.w	d5,bltcon1(a5)

; Just a case of calculating the registers for the blitter now...

	and.w	#%1111,d0	; get lowest 4 bits of start xpos
	lsl.w	#6,d0		; put it in the highest 4 bits of word
	lsl.w	#6,d0
	or.w	#%101111001001,d0	; Or it with registers (ACD) and minterms
	move.w	d0,bltcon0(a5)		; to get bltcon0 value
	move.w	#$8000,bltadat(a5)	; Constant variable
	move.w	#$ffff,bltbdat(a5)	; The line pattern ($ffff = a solid line)
	move.w	#$ffff,bltafwm(a5)	; set masks
	move.w	#$ffff,bltalwm(a5)
	move.w	ds,d5		; bmod = ds * 2
	lsl.l	#1,d5
	move.w	d5,bltbmod(a5)
	sub.w	dl,d5		; aptl = ds * 2 - dl
	move.w	d5,bltaptl(a5)
	sub.w	dl,d5		; amod = ds * 2 - dl * 2
	move.w	d5,bltamod(a5)
	move.w	dl,d5		; size = dl * 64 + 2 (height of dl, width of 2)
	lsl.l	#6,d5		
	or.w	#2,d5
	move.w	d5,bltsize(a5)	; And that's it done!
	movem.l	(sp)+,d0-d5/a0
exit	rts

	even
spare	dc.w	0
dx	dc.w	0
dy	dc.w	0
ds	dc.w	0
dl	dc.w	0
octants
	dc.w	%1111000000010001
	dc.w	%1111000000000001
	dc.w	%1111000000011001
	dc.w	%1111000000000101
	dc.w	%1111000000010101
	dc.w	%1111000000001001
	dc.w	%1111000000011101
	dc.w	%1111000000001101

copper	dc.w	bplcon0,%0001100100000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2981
	dc.w	diwstop,$29c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0
	dc.w	color00,0
	dc.w	color01,$fff
	dc.w	$ffff,$fffe
base	dc.l	0
library	dc.b	'graphics.library',0,0

	even

screen	ds.l	256*40
address	=	screen
