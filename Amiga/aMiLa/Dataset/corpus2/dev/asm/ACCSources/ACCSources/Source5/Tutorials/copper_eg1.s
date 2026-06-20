
; Copper example 1

; M.Meany 10th Sept 1990 

; Changes colour 0 from black to white at line 120

; Set DevPac tab to 16


; Tell DevPac to optimise, no warnings and case independant

	opt	o+,ow-,c-	
	
; hardware.i is equates for all hardware registers and CIA's
; libs.i is a short file of library offsets
	
	include	source5:include/hardware.i
	include	source5:include/libs.i
	
; section 1 : Kill multi-tasking

	move.l	execbase,a6
	jsr	forbid(a6)

; section 2 : Stop DMA access

	lea	$dff000,a5
	move.w	#$03a0,dmacon(a5)

; section 3 : Initialise our Copper list

	move.l	#copperlist,cop1lch(a5)
	clr.w	copjmp1(a5)

; section 4 : Enable Copper DMA

	move.w	#$8280,dmacon(a5)

; section 5 : Wait for left mouse button to be pressed

mouse_wait	btst	#6,ciaapra
	bne	mouse_wait

; section 6 : Restore system Copper list

	move.l	#gfxname,a1
	moveq.l	#0,d0
	jsr	openlibrary(a6)
	move.l	d0,a4
	move.l	startlist(a4),cop1lch(a5)
	clr.w	copjmp1(a5)
	move.l	a4,a1
	jsr	closelibrary(a6)

; section 7 : Enable all DMA

	move.w	#$83e0,dmacon(a5)

; section 8 : Enable multi-tasking and quit

	jsr	permit(a6)
	rts
	
; Program data area:

gfxname	dc.b	'graphics.library',0
	even
	
; The next instruction ensures that the copper list is in chip ram.

	section	copper,data_c

copperlist	dc.w	color00,$0000	colour 0 = black
	dc.w	$7801,$fffe	wait for (0,120)
	dc.w	color00,$0fff	colour 0 = white
	dc.w	$ffff,$fffe	end
		
