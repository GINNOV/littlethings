
* DATE:	
* TIME:	
* NAME:	
* CODE:	
* NOTE:		This is a note from M.Meany. Try assembling the following
*		program as it stands using Devpac2. Does it crash with an
*		illegal address error? If so, PLEASE inform HiSoft.
*		 There is not a bug in Devpac2's optimisation routines, I
*		have it in writing! However, remove the line so marked
*		below, uncomment the other and you will see that Axal was
*		right after all! To prove a point, Devpac3 does not crash
*		if this program is assembled and run as is, without
*		removing the optimisation request!
*		 If the Devpac3 editor didn't crash so often, I'd say HiSoft
*		had finaly got their act together and produced a program
*		worth the best part of a weeks pay :-(


;	opt	c-   			;,ow-,o+	Uncomment this line!



; Beware Devpac2 users, the following line will cause this program to crash!

	opt	c-,ow-,o+				Delete this line!

; Uncomment the following line to see what optimisations have been made, I
;bet the problem is due to an incorrect short word addressing substition!

;	opt	c-,o+

; Refer to your Devpac2 manual, Page 51. Nowhere does it say that using
;opt o+ may cause your program to be incorrectly assembled and so crash
;when run!

	incdir	source:include/
	include	hardware.i
	include	axal_lib.i
	incdir	source:axal/

wk1cop	=	$26
wk2cop	=	$32

	section	Chipmem,code_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save the stack address

	opengfx				open gfx library
	move.l	d0,a1			copy base
	beq	gfxerror1		branch if error

	move.l	wk1cop(a1),syscop1	save copper list 1
	move.l	wk2cop(a1),syscop2	save copper list 2
	callexe	closelibrary		close lib
	bsr	med_init		get music ready

*---------------------------------------
	callexe	forbid			forbid multi-tasking

	lea	$dff000,a5		pointer to custom chips
	move.w	dmaconr(a5),d0		get system dma
	or.w	#$8000,d0		set enable
	move.w	d0,sysdma		save it
	move.w	intenar(a5),d0		get system interrup enable
	or.w	#$c000,d0		set enable bit
	move.w	d0,systen		save it
	move.w	intreqr(a5),d0		get system interrup request
	or.w	#$8000,d0		set enable
	move.w	d0,systrq		save it

	lea	$64.w,a0		point to interrupts
	lea	sysintlev(pc),a1	address holders
	moveq	#6-1,d0			save 6 levels
kill_loop1
	move.l	(a0)+,(a1)+		save address
	dbra	d0,kill_loop1		do all 6
waitmsb
	btst	#$0,vposr(a5)		test msb of vpos
	bne.s	waitmsb			branch if not 0
wait310
	cmpi.b	#$55,vhposr(a5)		wait for line 310
	bne.s	wait310			branch until reached
	move.w	#$20,beamcon0(a5)	set update to 50hz (pal)
	
	lea	$64.w,a0		point to interrupts
	move.l	#death_init,d0		rte command
	moveq	#6-1,d1			do all 6
rteset_loop1
	move.l	d0,(a0)+		kill interrupt
	dbra	d1,rteset_loop1		do all 6

	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request
	move.w	d0,dmacon(a5)		clear dma

	lea	axalcopper(pc),a0	point to my copper
	move.l	a0,d1			copy pointer
	move.l	d1,cop1lch(a5)		show normal copper
	clr.w	copjmp1(a5)		strode it
*---------------------------------------
	bsr	setupscreens		do the screen stuff
	bsr	setupcopper		do the copper info
	bsr	setupcolours		do the colours
	bsr	setupinterrupts		do interrups stuff + dma
*---------------------------------------
vertloop
	cmpi.b	#$ff,vhposr(a5)		vertical blank
	bne.s	vertloop
	btst	#6,$bfe001		left mouse button
	bne.s	vertloop
*---------------------------------------
quit_program
	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request
	move.w	d0,dmacon(a5)		clear dma

	move.l	syscop1(pc),cop1lch(a5)	restore system copper 1
	move.l	syscop2(pc),cop2lch(a5)	restore system copper 2
	move.w	copjmp1(a5),d0		strode it

	lea	$64.w,a0		point to interrupts
	lea	sysintlev(pc),a1	address holders
	moveq	#6-1,d0			save 6 levels
.restore_loop1
	move.l	(a1)+,(a0)+		restore address
	dbra	d0,.restore_loop1	do all 6

	move.w	sysdma(pc),dmacon(a5)	restore system dma
	move.w	systen(pc),intena(a5)	restore system interrup enable
	move.w	systrq(pc),intreq(a5)	restore system interrup request

	callexe	enable			enable multi-tasking
	bsr	med_end			kill the music
*---------------------------------------
gfxerror1
	move.l	stack,sp		restore stack
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	moveq	#0,d0			keep cli happy
	rts
*---------------------------------------
setupinterrupts
	move.l	#lev3_interrupt,$6c.w	insert my commands
	move.w	#$83e0,dmacon(a5)	set dma
	move.w	#$c010,intena(a5)	copper set
	rts
lev3_interrupt
	and.w	#$10,intreqr(a5)	check if copper
	beq.s	.notready		quit if not
	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	bsr	med_music		play music
	bsr	volume_meters		show the music
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
.notready
	move.w	#$70,intreq(a5)		clear vert/copper/blitter
death_init
	rte
*---------------------------------------
setupscreens
	rts
scrcopsave
	move.w	d0,6(a0)		save low word
	swap	d0			swap words
	move.w	d0,2(a0)		save high word
	swap	d0			swap words
	addq.l	#8,a0			next plane pointers
	add.l	d1,d0			next plane
	dbra	d2,scrcopsave		decrement et branch
	rts
*---------------------------------------
setupcopper
	lea	copvu1(pc),a0		copper vu 1
	move.l	#$f081fffe,d0		grey start position
	move.l	#$01800000,d1		colour for greys & reds & blacks
	move.l	#$f089fffe,d2		stop position for reds
	move.l	#$f08dfffe,d3		stop position for greys
	move.l	#$01000000,d4		what to add
	move.w	#16-1,d5		d0 14 lines
	bsr	.coploop1		place in copper

	lea	copvu2(pc),a0		copper vu 2
	move.l	#$0081fffe,d0		grey start position
	move.l	#$0089fffe,d2		stop position for reds
	move.l	#$008dfffe,d3		stop position for greys
	move.w	#16-1,d5		do 30 lines
	bsr	.coploop1		place in copper

	lea	copvu3(pc),a0		copper vu 3
	move.l	#$1081fffe,d0		grey start position
	move.l	#$1089fffe,d2		stop position for reds
	move.l	#$108dfffe,d3		stop position for greys
	move.w	#16-1,d5		do 30 lines
	bsr	.coploop1		place in copper

	lea	copvu4(pc),a0		copper vu 4
	move.l	#$2081fffe,d0		grey start position
	move.l	#$2089fffe,d2		stop position for reds
	move.l	#$208dfffe,d3		stop position for greys
	move.w	#16-1,d5		do 30 lines
	bsr	.coploop1		place in copper

	lea	plasma_copper(pc),a0	point to copper
	move.l	#$6033fffe,d0		start position
	move.l	#$01800000,d1		colour reg
	move.l	#$01000000,d2		next line
	move.w	#80-1,d5		many lines to do
.coploop2
	move.l	d0,(a0)+		new line position
	moveq	#44-1,d4		many colour reg to save
.coploop3
	move.l	d1,(a0)+		colour reg
	not.w	d1
	dbra	d4,.coploop3		do it 10 times
	add.l	d2,d0			next line

	dbra	d5,.coploop2		do it 64 times
	rts
.coploop1
	move.l	d0,(a0)+		new line position
	move.l	d1,(a0)+		colour reg
	move.l	d1,(a0)+		colour reg
	move.l	d2,(a0)+		new position
	move.l	d1,(a0)+		colour reg
	move.l	d1,(a0)+		colour reg
	move.l	d3,(a0)+		new position
	add.l	d4,d0			next line
	add.l	d4,d2			next line
	add.l	d4,d3			next line
	dbra	d5,.coploop1
	rts
*---------------------------------------
setupcolours
	lea	copvu1(pc),a0		copper volume meter
	lea	copvu2(pc),a1		copper volume meter
	lea	copvu3(pc),a2		copper volume meter
	lea	copvu4(pc),a3		copper volume meter
	lea	vertcolgrey(pc),a4	colour list
	move.w	#16-1,d0		many lines
	bsr.s	.coploop1		save in copper

	lea	vertcolred(pc),a4	colour list
	bsr.s	.coploop2		save in copper
	rts
.coploop1
	movem.l	d0/a0-a3,-(sp)		save vm pointers
.loop1
	move.w	(a4)+,d1		get first grey
	move.w	d1,6(a0)		new colour vm 1
	move.w	d1,6(a1)		new colour vm 2
	move.w	d1,6(a2)		new colour vm 3
	move.w	d1,6(a3)		new colour vm 4
	move.w	d1,18(a0)		new colour vm 1
	move.w	d1,18(a1)		new colour vm 2
	move.w	d1,18(a2)		new colour vm 3
	move.w	d1,18(a3)		new colour vm 4
	move.l	#28,d1			28 bytes to new line
	add.l	d1,a0			next line
	add.l	d1,a1			next line
	add.l	d1,a2			next line
	add.l	d1,a3			next line
	dbra	d0,.loop1
	movem.l	(sp)+,d0/a0-a3		restore vm pointers
	rts
.coploop2
	move.w	(a4)+,d1		get first grey
	move.w	d1,10(a0)		new colour vm 1
	move.w	d1,10(a1)		new colour vm 2
	move.w	d1,10(a2)		new colour vm 3
	move.w	d1,10(a3)		new colour vm 4
	move.w	#28,d1			28 bytes to new line
	add.l	d1,a0			next line
	add.l	d1,a1			next line
	add.l	d1,a2			next line
	add.l	d1,a3			next line
	dbra	d0,.coploop2
	rts
*---------------------------------------
*---------------------------------------

volume_meters
	moveq	#0,d0			clear do for note
	lea	med_chan0note(pc),a1	point to notes
	lea	copvu1(pc),a0		copper list
	bsr.s	vum_midcopper		show note
	lea	copvu2(pc),a0		copper list
	bsr.s	vum_midcopper		show note
	lea	copvu3(pc),a0		copper list
	bsr.s	vum_midcopper		show note
	lea	copvu4(pc),a0		copper list
vum_midcopper
	move.w	#16-1,d7		many lines to do
	move.l	#28,d6			many bytes to add
	move.b	(a1)+,d0		get note
	beq.s	vum_nonote		branch if not a note

	move.b	#$4b,d2			where to start left
	move.b	#$c7,d3			where to start right
	move.b	#$c5,d4			where to start middle
.vum_loop1
	move.b	d2,1(a0)		show colour
	move.b	d4,13(a0)		show colour
	move.b	d3,25(a0)		show colour
	add.l	d6,a0			next line
	dbra	d7,.vum_loop1		do all lines
	rts
vum_nonote
	cmpi.b	#$81,1(a0)		is it at end of line
	ble.s	vum_end			is so die!!!
	moveq.b	#2,d2			amount to sub
.vum_loop2
	add.b	d2,1(a0)		pull back copper
	sub.b	d2,13(a0)		push right copper
	sub.b	d2,25(a0)		push right copper
	add.l	d6,a0			next line
	dbra	d7,.vum_loop2		do all lines!
vum_end
	rts

*---------------------------------------
	include	axl-medplayer.s
*---------------------------------------

gfxname		dc.b	"graphics.library",0
		even
gfxbase		ds.l	1
stack		ds.l	1
syscop1		ds.l	1
syscop2		ds.l	1
sysintlev	ds.l	6
sysdma		ds.w	1
systen		ds.w	1
systrq		ds.w	1

*---------------------------------------

axalcopper
	dc.w	intreq,$8010
	dc.w	diwstrt,$2881,diwstop,$2cc1
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	bplcon1,$0000,bplcon2,$0000
	dc.w	bpl1mod,$0000,bpl2mod,$0000
	dc.w	beamcon0,$0020,bplcon0,$200
copper_sprites
	dc.w	spr0pth,0,spr0ptl,0,spr1pth,0,spr1ptl,0
	dc.w	spr2pth,0,spr2ptl,0,spr3pth,0,spr3ptl,0
	dc.w	spr4pth,0,spr4ptl,0,spr5pth,0,spr5ptl,0
	dc.w	spr6pth,0,spr6ptl,0,spr7pth,0,spr7ptl,0
copper_colours
	dc.w	$180,$000,$182,$000,$184,$000,$186,$000
	dc.w	$188,$000,$18a,$000,$18c,$000,$18e,$000
	dc.w	$190,$000,$192,$000,$194,$000,$196,$000
	dc.w	$198,$000,$19a,$000,$19c,$000,$19e,$000
	dc.w	$1a0,$000,$1a2,$000,$1a4,$000,$1a6,$000
	dc.w	$1a8,$000,$1aa,$000,$1ac,$000,$1ae,$000
	dc.w	$1b0,$000,$1b2,$000,$1b4,$000,$1b6,$000
	dc.w	$1b8,$000,$1ba,$000,$1bc,$000,$1be,$000
copper_planes
	dc.w	bpl1pth,0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0,bpl4pth,0,bpl4ptl,0
	dc.w	bpl5pth,0,bpl5ptl,0,bpl6pth,0,bpl6ptl,0
plasma_copper
	ds.w	90*80
	dc.w	$180,$000
copvu1	ds.w	(14*16)
	dc.w	$ffe1,$fffe		enable pal
copvu2	ds.w	(14*16)
copvu3	ds.w	(14*16)
copvu4	ds.w	(14*16)
	dc.w	$ffff,$fffe

*---------------------------------------
vertcolgrey
	dc.w	$111,$333,$555,$777,$999,$bbb,$ddd,$fff
	dc.w	$eee,$ccc,$aaa,$888,$666,$444,$222,$000
vertcolred
	dc.w	$100,$300,$500,$700,$900,$b00,$d00,$f00
	dc.w	$e00,$c00,$a00,$800,$600,$400,$200,$000
*---------------------------------------

med_module	incbin	source:modules/med.mod
