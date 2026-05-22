** CODE   : GFXRIPPPER
** AUTHOR : RAISTLIN
** DATE   : 10.2.91
** SIZE   : 956 BYTES
** NOTES  :
;	 This program sets up 5 bitplanes, each one pointing a screen of
; info further up in memory than the last. At the moment I have got it set-up
; to scan 1 bitplane at a time. To alter this simply alter the bplcon0 in the
; copper list. This program scrolls left,right,up & down. If you find a screen
; you like press F3. Then if you press F4 later that screen will be recalled.
; I intended this to be a ripper but I couldnt get the save routine to work!
; Can anyone help me make a gfx ripper?

; F1 SCROLLS RIGHT, F2 SCROLLS LEFT, F3 SAVE, F4 RESTORE, F5 QUIT, LEFT MOUSE
; BUTTON SCROLL DOWN, RIGHT MOUSE BUTTON SCROLL UP, BOTH MOUSE BUTTONS QUIT.


	opt	c-
	include	source10:include/hardware.i
	section	ripper,code_c

	move.l	4,a6
	jsr	-132(a6)		;forbid
	lea	$dff000,a5
	move.w	#$0020,dmacon(a5)	stop DMA

	move.l	#copperlist,cop1lch(a5)
	clr.w	copjmp1(a5)
	move.w	#$8380,dmacon(a5)


*****************************************************************************
;    Load copper list & test for F1,F2,F3,F4,F5 & left/right mouse button
*****************************************************************************
	moveq.l	#0,d0		d0=address of bitplane
	move.l	copperlist,a0	a0=address of copperlist

wait	
;test for the mouse buttons
	btst	#6,$bfe001
	beq	right
	btst	#$a,$dff016
	beq	left

;test for F1-F5
	move.b	$bfec01,d0
	not	d0
	ror.b	#1,d0
	cmpi.b	#$54,d0		;check for F5 key
	bhi	wait		;if its greater than F4 sod-it
	cmp.b	#$4f,d0		;check for F1 key
	bls	wait		;if its lower than F1 sod-it
	sub.b	#$50,d0		;Get a 1-4 value on Fkey
	add.b	#1,d0
F1	cmpi.b	#1,d0		;is it F1?
	bne.s	F2		;no, try next one
	bra	scrollleft		;DO-IT
F2	cmpi.b	#2,d0		;is it F2?
	bne.s	F3		;no, try next one
	bra	scrollright
F3	cmpi.b	#3,d0
	bne.s	F4
	bra	Save1
F4	cmpi.b	#4,d0
	bne.s	F5
	bra	Save2
F5	bra	savetodisk	

;test for the mouse buttons	
	bra	wait	
right	btst	#$a,$dff016
	bne	scrolldown
	bra	cleanup
left	btst	#6,$bfe001
	bne	scrollup
	bra	cleanup

*****************************************************************************
;	Routine to save the current gfx plane
*****************************************************************************
save1
	move.w	bph1+2,d6		move high word of bpl1pt into d6
	swap	d6		swap
	move.w	bpl1+2,d6		move low word of bpl1pt into d6
	move.l	d6,start		move d6 into start
	bra	wait		return
save2
	move.l	start,d6		get address
	move.w	d6,bpl1+2		load address in bpl1pts
	swap	d6
	move.w	d6,bph1+2
	bra	wait	
	
savetodisk	rts		not implemented (yet?)

*****************************************************************************
;		Clean-up & exit
*****************************************************************************
cleanup

	move.l	#gfxname,a1	a1-->library name
	moveq.l	#0,d0		any version
	jsr	-408(a6)		 open graphics lib
	move.l	d0,a4		a4-->graphics lib
	move.l	38(a4),cop1lch(a5) DMA-->sys list
	clr.w	copjmp1(a5)		start sys list
	move.w	#$83e0,dmacon(a5) 		nable all DMA
	jsr	-138(a6)		bring back o/s
	rts

*****************************************************************************
;			Scroll
*****************************************************************************		
;Vertical scrolling
scrollup	move.l	#1000,d0		;loop wait
scroll1	sub.l	#1,d0		;yes, I know its naughty. Use a vbl
	bne	scroll1		;wait if you prefer!
plane1
	move.w	bph1+2,d0		;bpl1pth into d0
	swap	d0		
	move.w	bpl1+2,d0		;bpl1ptl into d0
	add.l	#40,d0		;add 40 to bpl1ptx
	move.w	d0,bpl1+2		;restore ptrs
	swap	d0
	move.w	d0,bph1+2
plane2
	move.w	bph2+2,d0
	swap	d0		..............
	move.w	bpl2+2,d0
	add.l	#40,d0
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
plane3
	move.w	bph3+2,d0
	swap	d0		...............
	move.w	bpl3+2,d0
	add.l	#40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
plane4
	move.w	bph4+2,d0
	swap	d0
	move.w	bpl4+2,d0
	add.l	#40,d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
plane5
	move.w	bph5+2,d0
	swap	d0
	move.w	bpl5+2,d0
	add.l	#40,d0
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2
	bra	wait


scrolldown
	move.w	#1000,d0		;naughty, naughty!
scroll3	sub.w	#1,d0
	bne	scroll3
pplane1
	move.w	bph1+2,d0
	swap	d0
	move.w	bpl1+2,d0
	sub.l	#40,d0		;same as above exit -40
	move.w	d0,bpl1+2
	swap	d0
	move.w	d0,bph1+2
pplane2
	move.w	bph2+2,d0
	swap	d0
	move.w	bpl2+2,d0
	sub.l	#40,d0
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
pplane3
	move.w	bph3+2,d0
	swap	d0
	move.w	bpl3+2,d0
	sub.l	#40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
pplane4
	move.w	bph4+2,d0
	swap	d0
	move.w	bpl4+2,d0
	sub.l	#40,d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
pplane5
	move.w	bph5+2,d0
	swap	d0
	move.w	bpl5+2,d0
	sub.l	#40,d0
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2
	bra	wait

;Horizontal scrolling
scrollright	move.w	#4000,d0
scroll2	sub.w	#1,d0
	bne	scroll2
	add.w	#1,bpl1+2		;add 1 to scroll right
	add.w	#1,bpl2+2
	add.w	#1,bpl3+2
	add.w	#1,bpl4+2
	add.w	#1,bpl5+2
	bra	wait

scrollleft	move.w	#4000,d0
scroll4	sub.w	#1,d0
	bne	scroll4
	sub.w	#1,bpl1+2		;minus 1 to scroll left
	sub.w	#1,bpl2+2
	sub.w	#1,bpl3+2
	sub.w	#1,bpl4+2
	sub.w	#1,bpl5+2
	bra	wait

******************************************************************************
;	          	Copper List
********************************************************************************
copperlist
bph1	dc.w	bpl1pth,$0000
bpl1	dc.w	bpl1ptl,$0000
bph2	dc.w	bpl2pth,$0001
bpl2	dc.w	bpl2ptl,$0240
bph3	dc.w	bpl3pth,$0002
bpl3	dc.w	bpl3ptl,$0480
bph4	dc.w	bpl4pth,$0003
bpl4	dc.w	bpl4ptl,$0720
bph5	dc.w	bpl5pth,$0004
bpl5	dc.w	bpl5ptl,$0960
	dc.w	diwstrt,$3081
	dc.w	diwstop,$ffc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bplcon0,%0001000000000000
	dc.w	bplcon1,$0
	dc.w	bplcon2,$0
	dc.w	bpl1mod,$0
	dc.w	bpl2mod,$0
	dc.w	color00,$000
	dc.w	color01,$fff
	dc.w	color02,$111
	dc.w	color03,$222
	dc.w	color04,$333
	dc.w	color05,$444
	dc.w	color06,$555
	dc.w	color07,$666
	dc.w	color08,$777
	dc.w	color09,$888
	dc.w	color10,$999
	dc.w	color11,$aaa
	dc.w	color12,$bbb
	dc.w	color13,$ccc
	dc.w	color14,$ddd
	dc.w	color15,$eee
	dc.w	color16,$fff
	dc.w	color17,$f00
	dc.w	color18,$00f
	dc.w	color19,$0f0
	dc.w	color20,$0ff
	dc.w	color21,$ff0
	dc.w	color22,$f0f
	dc.w	$ffff,$fffe

;program variables
gfxname	dc.b	'graphics.library',0
	even
start	ds.l	1
end	ds.l	1

