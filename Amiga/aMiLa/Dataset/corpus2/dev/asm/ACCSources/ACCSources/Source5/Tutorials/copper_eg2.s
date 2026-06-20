
; Copper example 2

; M.Meany 10th Sept 1990 

; Displays a 3 colour Copper bar

; Set DevPac tab to 16


; Tell DevPac to optimise, no warnings and case independant

	opt	o+,ow-,c-	
	
; hardware.i is equates for all hardware registers and CIA's
; libs.i is a short file of library offsets
; colours.i is a list of some colour values from the Hardware manual p.88
	
	include	source5:include/hardware.i
	include	source5:include/libs.i
	include	source5:include/colours.i
	
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

copperlist	dc.w	color00,black	colour 0 = black
	dc.w	$6401,$fffe	wait for (0,100)
	dc.w	color00,light_blue	colour 0 = light blue
	dc.w	$6501,$fffe	wait for (0,102)
	dc.w	color00,dark_blue	colour 0 = dark blue
	dc.w	$6701,$fffe	wait for (0,105)
	dc.w	color00,blue	colour 0 = blue
	dc.w	$6a01,$fffe	wait for (0,110)
	dc.w	color00,dark_blue	colour 0 = dark blue
	dc.w	$6c01,$fffe	wait for (0,113)
	dc.w	color00,light_blue	colour 0 = light blue
	dc.w	$6d01,$fffe	wait for (0,115)
	dc.w	color00,black	colour 0 = black
	dc.w	$ffff,$fffe	end
		
