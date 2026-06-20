
; Sprite DMA reusage

; M.Meany 1st Oct 1990 

; Using 1 sprite DMA channel 2 sprites are displayed and moved across
; the display. The copper bars are still here from a previous prog.
; 3 bouncing Copper bars. Note that WAIT values in Copper list were
; obtained by trial and error.

; Set DevPac tab to 16


; Tell DevPac to optimise, no warnings and case independant

	opt	o+,ow-,c-	
	
; hardware.i is equates for all hardware registers and CIA's
; libs.i is a short file of library offsets
; colours.i is a list of some colour values from the Hardware manual p.88
	
	incdir	source5:include/
	include	hardware.i
	include	libs.i
	include	colours.i
	
; DMA off and o/s out
	
	move.l	execbase,a6	a6-->exec library
	jsr	forbid(a6)	switch out o/s
	lea	$dff000,a5	a5-->hardware reg. base
	move.w	#$01e0,dmacon(a5) stop DMA
	
; Initialise 1 bitplane display 320x200

	move.l	#screen,d0
	move.w	d0,scl
	swap	d0
	move.w	d0,sch

	move.w	#$1200,bplcon0(a5)
	move.w	#$0000,bpl1mod(a5)
	move.w	#$0000,bplcon1(a5)
	move.w	#$0024,bplcon2(a5)
	move.w	#$0038,ddfstrt(a5)
	move.w	#$00d0,ddfstop(a5)
	move.w	#$2c81,diwstrt(a5)
	move.w	#$f4c1,diwstop(a5)
	
; Initialise sprite data pointer

	lea	copperlist,a0
	move.l	#sprite_data,d0
	move.w	d0,10(a0)
	swap	d0
	move.w	d0,6(a0)
	
; Initialise sprites colours
	
	move.w	#$0ff0,color17(a5)
	move.w	#$00ff,color18(a5)
	move.w	#$0f0f,color19(a5)
	
; Initialise copper list

	move.l	#copperlist,cop1lch(a5) copper DMA-->our list
	clr.w	copjmp1(a5)	 start our list
	move.w	#$83A0,dmacon(a5)   Copper + sprite DMA

; bounce the bar

loop	move.l	vposr(a5),d0	d0=beam position
	and.l	#$0001ff00,d0	mask off line number
	cmp.l	#$00001000,d0	is it line 16 ?
	bne	loop	if not loop back

	lea	sprite_data,a0
	addi.b	#1,1(a0)
	subi.b	#2,25(a0)

	lea	bar1,a0	a0-->first bar in list
	tst.b	direction1	up or down ?
	bne.s	up1	branch for up
	addq.b	#1,0(a0)	1st strip down
	addq.b	#1,8(a0)	2nd strip down
	addq.b	#1,16(a0)	3rd strip down
	addq.b	#1,24(a0)	4th strip down
	addq.b	#1,32(a0)	5th strip down
	addq.b	#1,40(a0)	background
	bra.s	chk_direction1	jump over up rountine
	
up1	subq.b	#1,0(a0)	1st strip up
	subq.b	#1,8(a0)	2nd strip up
	subq.b	#1,16(a0)	3rd strip up
	subq.b	#1,24(a0)	4th strip up
	subq.b	#1,32(a0)	5th strip up
	subq.b	#1,40(a0)	background
	
chk_direction1	addq.b	#1,counter1	increase counter
	cmpi.b	#50,counter1	change direction ?
	bne.s	bounce_2	if not don't worry
	not.b	direction1	else toggle flag
	move.b	#0,counter1	and reset counter

bounce_2	lea	bar2,a0	a0-->second bar in list
	tst.b	direction2	up or down ?
	bne.s	up2	branch for up
	addq.b	#1,0(a0)	1st strip down
	addq.b	#1,8(a0)	2nd strip down
	addq.b	#1,16(a0)	3rd strip down
	addq.b	#1,24(a0)	4th strip down
	addq.b	#1,32(a0)	5th strip down
	addq.b	#1,40(a0)	background
	bra.s	chk_direction2	jump over up rountine
	
up2	subq.b	#1,0(a0)	1st strip up
	subq.b	#1,8(a0)	2nd strip up
	subq.b	#1,16(a0)	3rd strip up
	subq.b	#1,24(a0)	4th strip up
	subq.b	#1,32(a0)	5th strip up
	subq.b	#1,40(a0)	background
	
chk_direction2	addq.b	#1,counter2	increase counter
	cmpi.b	#100,counter2	change direction ?
	bne.s	bounce_3	if not don't worry
	not.b	direction2	else toggle flag
	move.b	#0,counter2	and reset counter

bounce_3	lea	bar3,a0	a0-->third bar in list
	tst.b	direction3	up or down ?
	bne.s	up3	branch for up
	addq.b	#1,0(a0)	1st strip down
	addq.b	#1,8(a0)	2nd strip down
	addq.b	#1,16(a0)	3rd strip down
	addq.b	#1,24(a0)	4th strip down
	addq.b	#1,32(a0)	5th strip down
	addq.b	#1,40(a0)	background
	bra.s	chk_direction3	jump over up rountine
	
up3	subq.b	#1,0(a0)	1st strip up
	subq.b	#1,8(a0)	2nd strip up
	subq.b	#1,16(a0)	3rd strip up
	subq.b	#1,24(a0)	4th strip up
	subq.b	#1,32(a0)	5th strip up
	subq.b	#1,40(a0)	background
	
chk_direction3	addq.b	#1,counter3	increase counter
	cmpi.b	#50,counter3	change direction ?
	bne.s	no_change	if not don't worry
	not.b	direction3	else toggle flag
	move.b	#0,counter3	and reset counter

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

counter1	dc.b	49
direction1	dc.b	0
counter2	dc.b	0
direction2	dc.b	0
counter3	dc.b	0
direction3	dc.b	0
	even
		
copperlist	dc.w	color00,black	colour 0 = black
	dc.w	spr0pth,0
	dc.w	spr0ptl,0
	dc.w	spr1pth,0
	dc.w	spr1ptl,0
	dc.w	spr2pth,0
	dc.w	spr2ptl,0
	dc.w	spr3pth,0
	dc.w	spr3ptl,0
	dc.w	spr4pth,0
	dc.w	spr4ptl,0
	dc.w	spr5pth,0
	dc.w	spr5ptl,0
	dc.w	spr6pth,0
	dc.w	spr6ptl,0
	dc.w	spr7pth,0
	dc.w	spr7ptl,0
	dc.w	bpl1pth
sch	dc.w	0
	dc.w	bpl1ptl
scl	dc.w	0

	dc.w	$3601,$fffe	wait for (0,40)
	
bar1	dc.w	$5e01,$fffe	wait for (0,100)
	dc.w	color00,light_blue  colour 0 = light blue
	dc.w	$5f01,$fffe	wait for (0,102)
	dc.w	color00,dark_blue   colour 0 = dark blue
	dc.w	$6101,$fffe	wait for (0,105)
	dc.w	color00,blue	colour 0 = blue
	dc.w	$6401,$fffe	wait for (0,110)
	dc.w	color00,dark_blue   colour 0 = dark blue
	dc.w	$6601,$fffe	wait for (0,113)
	dc.w	color00,light_blue  colour 0 = light blue
	dc.w	$6701,$fffe	wait for (0,115)
	dc.w	color00,black	colour 0 = black
	
bar2	dc.w	$6401,$fffe	wait for (0,100)
	dc.w	color00,light_green  colour 0 = light green
	dc.w	$6501,$fffe	wait for (0,102)
	dc.w	color00,dark_green   colour 0 = dark green
	dc.w	$6701,$fffe	wait for (0,105)
	dc.w	color00,green	colour 0 = green
	dc.w	$6a01,$fffe	wait for (0,110)
	dc.w	color00,dark_green   colour 0 = dark green
	dc.w	$6c01,$fffe	wait for (0,113)
	dc.w	color00,light_green  colour 0 = light green
	dc.w	$6d01,$fffe	wait for (0,115)
	dc.w	color00,black	colour 0 = black
	
bar3	dc.w	$cd01,$fffe	wait for (0,100)
	dc.w	color00,light_blue  colour 0 = light blue
	dc.w	$ce01,$fffe	wait for (0,102)
	dc.w	color00,dark_blue   colour 0 = dark blue
	dc.w	$d001,$fffe	wait for (0,105)
	dc.w	color00,blue	colour 0 = blue
	dc.w	$d301,$fffe	wait for (0,110)
	dc.w	color00,dark_blue   colour 0 = dark blue
	dc.w	$d501,$fffe	wait for (0,113)
	dc.w	color00,light_blue  colour 0 = light blue
	dc.w	$d601,$fffe	wait for (0,115)
	dc.w	color00,black	colour 0 = black
	
	dc.w	$ffff,$fffe	end


sprite_data	dc.w	$6d60,$7200
	dc.w	$0990,$07e0
	dc.w	$13c8,$0ff0
	dc.w	$23c4,$1ff8
	dc.w	$13c8,$0ff0
	dc.w	$0990,$07e0
	
	dc.w	$8080,$8d00
	dc.w	$1818,$0000
	dc.w	$7e7e,$0000
	dc.w	$7f7e,$0000
	dc.w	$ffff,$2000
	dc.w	$ffff,$2000
	dc.w	$ffff,$3000
	dc.w	$ffff,$3000
	dc.w	$7ffe,$1800
	dc.w	$7ffe,$0c00
	dc.w	$3ffc,$0000
	dc.w	$0ff0,$0000
	dc.w	$03c0,$0000
	dc.w	$0180,$0000
	dc.w	$0000,$0000
	
screen	dcb.b	200*320/8,0
