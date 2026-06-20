
; Copper example 4

; M.Meany 14th Sept 1990 

; Corrected bouncing Copper bar routine

; Set DevPac tab to 16


; Tell DevPac to optimise, no warnings and case independant

	opt	o+,ow-,c-	
	
; hardware.i is equates for all hardware registers and CIA's
; libs.i is a short file of library offsets
; colours.i is a list of some colour values from the Hardware manual p.88
	
	include	source5:include/hardware.i
	include	source5:include/libs.i
	include	source5:include/colours.i
	
; DMA off and o/s out
	
	move.l	execbase,a6	a6-->exec library
	jsr	forbid(a6)	switch out o/s
	lea	$dff000,a5	a5-->hardware reg. base
	move.w	#$01e0,dmacon(a5) stop DMA
	
; Initialise copper list

	move.l	#copperlist,cop1lch(a5) copper DMA-->our list
	clr.w	copjmp1(a5)	 start our list
	move.w	#$8280,dmacon(a5)   enable Copper DMA

; bounce the bar

loop	move.l	vposr(a5),d0	d0=beam position
	and.l	#$0001ff00,d0	mask off line number
	cmp.l	#$00001000,d0	is it line 16 ?
	bne	loop	if not loop back

	lea	copperlist,a0	a0-->copperlist
	lea	counter,a1	a1-->counter
	tst.b	direction	up or down ?
	bne.s	up	branch for up
	addq.b	#1,8(a0)	1st strip down
	addq.b	#1,16(a0)	2nd strip down
	addq.b	#1,24(a0)	3rd strip down
	addq.b	#1,32(a0)	4th strip down
	addq.b	#1,40(a0)	5th strip down
	addq.b	#1,48(a0)	background down
	bra.s	chk_direction	jump over up rountin
	
up	subq.b	#1,8(a0)	1st strip up
	subq.b	#1,16(a0)	2nd strip up
	subq.b	#1,24(a0)	3rd strip up
	subq.b	#1,32(a0)	4th strip up
	subq.b	#1,40(a0)	5th strip up
	subq.b	#1,48(a0)	background up
	
chk_direction	addq.b	#1,counter	increase counter
	cmpi.b	#100,counter	change direction ?
	bne.s	no_change	if not don't worry
	not.b	direction	else toggle flag
	move.b	#0,counter	and reset counter
	
no_change	btst	#6,ciaapra	mouse button pressed?
	bne	loop	loop back if not

; Activate system copper list

	move.l	#grname,a1	a1-->library name
	moveq.l	#0,d0	any version
	jsr	openlibrary(a6) open graphics lib
	move.l	d0,a4	a4-->graphics lib
	move.l	startlist(a4),cop1lch(a5) DMA-->sys list
	clr.w	copjmp1(a5)	start sys list
	move.w	#$83e0,dmacon(a5) enable all DMA
	jsr	permit(a6)	bring back o/s
quit_fast	rts

; Program variable area

	section	chipmem,data_c	Copper list MUST be in chip

grname	dc.b	'graphics.library',0
	even

counter	dc.b	0
direction	dc.b	0
	even
		
copperlist	dc.w	color00,black	colour 0 = black
	dc.w	$3201,$fffe	wait for (0,50)
	dc.w	$6401,$fffe	wait for (0,100)
	dc.w	color00,light_blue  colour 0 = light blue
	dc.w	$6501,$fffe	wait for (0,102)
	dc.w	color00,dark_blue   colour 0 = dark blue
	dc.w	$6701,$fffe	wait for (0,105)
	dc.w	color00,blue	colour 0 = blue
	dc.w	$6a01,$fffe	wait for (0,110)
	dc.w	color00,dark_blue   colour 0 = dark blue
	dc.w	$6c01,$fffe	wait for (0,113)
	dc.w	color00,light_blue  colour 0 = light blue
	dc.w	$6d01,$fffe	wait for (0,115)
	dc.w	color00,black	colour 0 = black
	dc.w	$ffff,$fffe	end


