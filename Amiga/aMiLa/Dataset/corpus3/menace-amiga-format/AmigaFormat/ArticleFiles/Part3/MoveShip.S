*****************************************************************************
*						    			    *
*	Amiga system takeover framework			    		    *
*	1988 Dave Jones, DMA Design			    		    *
*						    			    *
* Allows killing of system, allowing changing of all display & blitter	    *
* hardware, restoring to normal after exiting.			    	    *
* Memory must still be properly allocated/deallocated upon entry/exit       *
* DOS routines for loading must be called BEFORE killing the system   	    *
*						    			    *
* Written using Devpac2					    		    *
*						    			    *
*****************************************************************************

	section	Framework,code_c	

*****************************************************************************
* Conditional Code (as last month) to make source code compatible with 
* Argonaut`s ArgAsm. If you have a meg, this code may have to be assembled
* using the CLI-based version of the Arg assembler, due to memory constraints
*							- Jason H
*****************************************************************************

	ifd	__ArgAsm

	incdir	"include:"
	include 	exec/funcdef.i
_SysBase	equ	$04

	elseif

	incdir	"include/"

	endc

* End of conditional block


	include 	libraries/dos_lib.i
	include 	exec/exec_lib.i
	include 	hardware/custom.i

Hardware		equ	$dff000
SystemCopper1		equ	$26
SystemCopper2		equ	$32
PortA			equ	$bfe001
ICRA			equ	$bfed01
LeftMouse		equ	6

BackgroundWidth		equ	100	100 bytes wide
ForegroundWidth		equ	92	92  bytes wide
ScreenHeight		equ	192	playing area 192 lines high (12 blocks)
NumberPlanes		equ	3	3 planes in each playfield

BytesPerBackPlane	equ	BackgroundWidth*ScreenHeight
BytesPerForePlane	equ	ForegroundWidth*ScreenHeight
BackgroundMemory	equ	2*NumberPlanes*BytesPerBackPlane
ForegroundMemory	equ	NumberPlanes*BytesPerForePlane
MemNeeded		equ	BackgroundMemory+ForegroundMemory

FullFirepower		equ	1

*******************************************************************************

start	lea	GraphicsName(pc),a1	open the graphics library purely
	move.l	_SysBase,a6		to find the system copper
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,GraphicsBase
	lea	DOSName(pc),a1		open the DOS library to allow
	clr.l	d0			the loading of data before
	jsr	_LVOOpenLibrary(a6)	killing the system
	move.l	d0,DOSBase

	move.l	#MemNeeded,d0		properly allocate some chip
	moveq.l	#2,d1			memory for screens etc.
	jsr	_LVOAllocMem(a6)	d1 = 2, specifies chip memory
	tst.l	d0			where screens,samples etc
	beq	MemError		must be (bottom 512K)
	move.l	d0,MemBase

*******************************************************************************

	lea	variables(pc),a5	a5 is the variables pointer
	lea	rasters(a5),a0
	lea	displayraster(a5),a1
	move.l	d0,(a0)+		calculate the address of each plane
	move.l	d0,(a1)+		store them in the variables area,
	add.l	#BytesPerBackPlane,d0	twice for the background as it is
	move.l	d0,(a0)+		double buffered			
	move.l	d0,(a1)+
	add.l	#BytesPerBackPlane,d0
	move.l	d0,(a0)+			
	move.l	d0,(a1)+
	add.l	#BytesPerBackPlane,d0
	move.l	d0,(a0)+			
	add.l	#BytesPerForePlane,d0
	move.l	d0,(a0)+			
	add.l	#BytesPerForePlane,d0
	move.l	d0,(a0)+			
	add.l	#BytesPerForePlane,d0
	move.l	d0,(a0)+			
	move.l	d0,(a1)+
	add.l	#BytesPerBackPlane,d0
	move.l	d0,(a0)+			
	move.l	d0,(a1)+
	add.l	#BytesPerBackPlane,d0
	move.l	d0,(a0)+			
	move.l	d0,(a1)+

	move.l	#Hardware,a6
	jsr	TakeSystem

*******************************************************************************

	move.l	#$dff000,a6		a6 ALWAYS point to base of
	move.l	#-1,bltafwm(a6)		custom chips
	bsr	GameInit
	move.l	#clist,cop1lc(a6)
	move.w	#$87e0,dmacon(a6)	enable copper,sprite,blitter
	move.w	#$7fff,intreq(a6)	clear all int request flags

*******************************************************************************

* Main game loop with the routines we are yet to cover commented out

*******************************************************************************

vloop	bsr	waitline223		interrupt set at vertical 
	not.b	vcount(a5)		position 223 (panel start)
	beq	twoblanks		alternate every frame

	lea	copperlist(pc),a1	set up registers for routine
	move.w	pf2scroll(a5),d0	checkpf2
	move.w	pf1scroll(a5),d1
	bsr	checkpf2		and branch to it
	bsr	moveship	
*	bsr	check.collision
*	bsr	erase.missiles
*	bsr	levels.code
*	bsr	update.missiles
	bsr	drawfgnds
*	bsr	print.score
*	bsr	check.keys
*	bsr	check.path
	bra	vloop
twoblanks	
	bsr	checkpf1		the following routines are only
	bsr	flipbgnd		executed every second frame
	bsr	moveship
*	bsr	restorebgnds
*	bsr	process.aliens
*	bsr	save.aliens
*	bsr	draw.aliens

	btst	#LeftMouse,PortA	lest mouse button to exit
	bne	vloop
	bra	finished	

**************************************************************************

waitline223
	btst	#4,intreqr+1(a6)	wait for vertical line 223
	beq	waitline223		interrupt set by the
	move.w	#$10,intreq(a6)		copperlist
return	rts

**************************************************************************

checkpf1
	cmp.w	#3,level.end(a5)	level.end = 3 means 
	beq	return			guardian on, so no scroll
	lea	copperlist(pc),a1
	move.w	pf2scroll(a5),d0	d0 = pf2 scroll value (0-15)
	move.w	pf1scroll(a5),d1	d1 = pf1 scroll value (0-15)
	subq.w	#1,d1			scroll a pixel
	bcs	resetpf1		reset back to 15
checkpf2
	cmp.w	#3,level.end(a5)	as above
	beq	return
	subq.w	#1,d0			scroll a pixel
	bcs	resetpf2		reset to 15 and update pointers
storescroll					
	move.w	d1,pf1scroll(a5)	resave the values
	move.w	d0,pf2scroll(a5)
	move.w	pf1count(a5),d2
	subq.w	#1,d2			check if at the end of the two
	or.w	d1,d2			screens and flag for the sprite
	move.w	d2,screenend(a5)	routine if true	
	lsl.w	#4,d0
	or.w	d0,d1
	move.w	d1,54(a1)		put the new scroll value into 
	rts				the copper list

resetpf1
	moveq	#$f,d1			reset scroll to 15
	subq.w	#1,pf1count(a5)		decrement words scrolled
	bne	storepf1		carry on if not zero
	move.w	#23,pf1count(a5)	otherwise reset the number of
	lea	rasters(a5),a4		words to scroll and reset the 
	lea	displayraster(a5),a3	display planes back to the very
	move.l	(a4)+,(a3)+		start.
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+		six planes in all
	add.w	#12,a4
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	bra	checkpf2		now check pf2
storepf1
	lea	displayraster(a5),a3	increment the plane pointers
	addq.l	#2,(a3)			by a word each
	addq.l	#2,4(a3)		these are background planes
	addq.l	#2,8(a3)		and are therefore double
	addq.l	#2,12(a3)		buffered
	addq.l	#2,16(a3)
	addq.l	#2,20(a3)
	bra	checkpf2

resetpf2
	lea	rasters(a5),a4
	moveq	#$f,d0			reset scroll back to 15
	subq.w	#1,pf2count(a5)		decrement the word scroll
	bne	respf2			value and reset if zero
	move.w	#23,pf2count(a5)
	clr.w	pf2offset(a5)		offset is reverse of pf2count
	cmp.w	#1,level.end(a5)	and is used for the copper
	bne	respf2			level.end = 1 when map finished
	addq.w	#1,level.end(a5)	so start to draw guardian
*	bsr	change.colours		setup the guardian colours
*	move.w	#6*72,guard.offset(a5)	changes the missiles
respf2 
	move.l	12(a4),d2		get the foreground plane 
	move.l	16(a4),d3		pointers and add the offset to
	move.l	20(a4),d4		them
	addq.w	#2,pf2offset(a5)
	add.w	pf2offset(a5),d2	store these in the copper list
	add.w	pf2offset(a5),d3
	add.w	pf2offset(a5),d4
storepf2
	move.w	d2,30(a1)
	move.w	d3,38(a1)
	move.w	d4,46(a1)
	bra	storescroll

**************************************************************************

flipbgnd	
	lea	copperlist(pc),a1	swap the background displays
	lea	displayraster(a5),a3	every second frame
	move.l	(a3),d4
	move.l	4(a3),d5
	move.l	8(a3),d6
	move.l	12(a3),(a3)
	move.l	16(a3),4(a3)
	move.l	20(a3),8(a3)
	move.l	d4,12(a3)
	move.l	d5,16(a3)
	move.l	d6,20(a3)
	addq	#4,d4			add 4 bytes (32 pixels) to the
	addq	#4,d5			pointers so that clipping can
	addq	#4,d6			be carried out on the left
	move.w	d4,6(a1)		hand side
	swap	d4
	move.w	d4,2(a1)		store the new ones in the copper
	move.w	d5,14(a1)		list
	swap	d5
	move.w	d5,10(a1)
	move.w	d6,22(a1)
	swap	d6
	move.w	d6,18(a1)
	not.b	screen.num(a5)
	rts

**************************************************************************

drawfgnds
	cmp.w	#3,level.end(a5)	3 for guardian fully on
	beq	return
	cmp.w	#2,level.end(a5)	2 for drawing guardian
	beq	return
	tst.w	pf2scroll(a5)		every 16 pixels a new strip
	beq	drawbegin		of foreground graphics are
	cmp.w	#$e,pf2scroll(a5)	drawn into a hidden part
	beq	drawend			of the screen
	rts
drawbegin
	bsr	setupblit
	clr.l	d6			d6 = offset into the screen
	move.l	fgndpointer(a5),a0	for the start of the screen
	bsr	drawfgnd		this will be zero
	subq	#1,a0
	move.l	a0,fgndpointer(a5)
	rts

drawend
	bsr	setupblit
	moveq	#46,d6			as the screen is 46 bytes
	move.l	fgndpointer(a5),a0	wide, this is the offset
	cmp.b	#$ff,(a0)		at which to draw the strip
	bne	drawfgnd
	sub.w	#12,a0			the end of map is flagged
	move.l	a0,fgndpointer(a5)	by an FF block number
	move.w	#1,level.end(a5)	flag the end of the map

drawfgnd
	clr.l	d0
	move.b	(a0)+,d0		d0 = block number (0-254)
	lea	rasters(a5),a4		get the current foreground
	move.l	12(a4),d1		plane pointers in d1,d2,d3
	move.l	16(a4),d2
	move.l	20(a4),d3
	add.l	d6,d1			add the offset passed
	add.l	d6,d2
	add.l	d6,d3
	add.w	pf2offset(a5),d1	add the scrolled words
	add.w	pf2offset(a5),d2	offset to each plane
	add.w	pf2offset(a5),d3
	moveq	#11,d7			12 blocks in height
	move.l	#graphics,a4		a4 = base address of the graphics
fgndloop					
	move.l	a4,d4
	mulu	#96,d0			96 bytes per graphic blocks
	ext.l	d0			(2 bytes wide x 16 high
	add.l	d0,d4			 x 3 planes)
	bsr	blitfgnd
	add.l	#ForegroundWidth*16,d1	work out address of 16 scanlines
	add.l	#ForegroundWidth*16,d2	down 
	add.l	#ForegroundWidth*16,d3
	clr.l	d0
	move.b	(a0)+,d0		get next block number
	dbf	d7,fgndloop		and repeat for all 12
	rts

blitfgnd
	move.l	d1,bltdpt(a6)		blit a 16x16 pixel block
	move.l	d4,bltapt(a6)		into the foreground screen
	move.w	#$0401,bltsize(a6)	unmasked with no shift
	add.l	#32,d4
	move.l	d2,bltdpt(a6)
	move.l	d4,bltapt(a6)
	move.w	#$0401,bltsize(a6)
	add.l	#32,d4
	move.l	d3,bltdpt(a6)
	move.l	d4,bltapt(a6)
	move.w	#$0401,bltsize(a6)
	rts

setupblit
	move.w	#$09f0,bltcon0(a6)		minterm for D = A
	clr.w	bltcon1(a6)
	clr.w	bltamod(a6)			data is stored sequentially
	move.w	#ForegroundWidth-2,bltdmod(a6)
	rts

**************************************************************************

buildbackgnd
	lea	rasters(a5),a0
	move.l	(a0),a1			get the background plane pointers
	move.l	4(a0),a2		in a1-a4 (double buffered so 2 sets)
	move.l	24(a0),a3		background graphics are only 4 colour
	move.l	28(a0),a4		(2 planes) so third plane is ignored
	addq	#4,a1			skip the hidden words used for
	addq	#4,a2			clipping
	addq	#4,a3
	addq	#4,a4
	move.l	#backgroundtable,a0	a0 = the background map
	move.w	level.number(a5),d0
	mulu	#144,d0			144 bytes per background map
	add.w	d0,a0
	moveq	#11,d0			12 blocks high
build1	moveq	#11,d1			24 blocks across
	movem.l	a1-a4,-(sp)
build2	move.b	(a0),d2			this loop draws 2 across
	lsr.b	#4,d2			block number stored in 4 bits
	bsr	drawback
	move.b	(a0)+,d2
	and.b	#$f,d2
	tst.w	d1
	beq	skipit
	bsr	drawback
skipit	dbf	d1,build2		do all 24 across
	movem.l	(sp)+,a1-a4
	add.l	#BackgroundWidth*16,a1	next block down the way
	add.l	#BackgroundWidth*16,a2
	add.l	#BackgroundWidth*16,a3
	add.l	#BackgroundWidth*16,a4
	dbf	d0,build1		do all 12 high
	move.l	#$dff000,a6
	rts

drawback
	lea	backgrounds,a6		a6 = the background graphics
	move.w	level.number(a5),d3
	mulu	#1024,d3		1024 bytes per level of background
	add.w	d3,a6			graphics (16 blocks)
	and.w	#$f,d2
	mulu	#64,d2			64 bytes per block
	add.l	d2,a6			(2 bytes x 16 high x 2 planes)
	movem.l	a1-a4,-(sp)
	moveq	#15,d3
drawb1	move.w	(a6),(a1)		draw into both the screens
	move.w	(a6),(a3)
	move.w	(a6),46(a1)		
	move.w	(a6),46(a3)
	move.w	32(a6),(a2)
	move.w	32(a6),(a4)
	move.w	32(a6),46(a4)
	move.w	32(a6),46(a2)
	add.w	#BackgroundWidth,a1
	add.w	#BackgroundWidth,a2
	add.w	#BackgroundWidth,a3
	add.w	#BackgroundWidth,a4
	addq	#2,a6
	dbf	d3,drawb1
	movem.l	(sp)+,a1-a4
	addq	#2,a1			next block along
	addq	#2,a2
	addq	#2,a3
	addq	#2,a4
	rts

**************************************************************************

GameInit
	lea	map,a0
	move.l	a0,fgndpointer(a5)	set up the map index
	move.w	#23,pf1count(a5)	width of the foreground in words
	move.w	#24,pf2count(a5)	width of the background in words
	move.w	#15,pf1scroll(a5)	initial scroll value
	move.w	#15,pf2scroll(a5)
	move.w	#100,xpos(A5)		ships initial x,y & speed
	move.w	#80,ypos(a5)
	move.w	#2,ship.speed(a5)
	move.w	#1,mult.number(a5)
	move.l	#ship1.2,shipaddress(a5) setup address of initial ship

	lea	copperlist(pc),a1
	lea	rasters(a5),a0
	move.w	(a0),2(a1)		copy the plane adresses into the
	move.w	2(a0),6(a1)		copperlist
	move.w	4(a0),10(a1)
	move.w	6(a0),14(a1)
	move.w	8(a0),18(a1)
	move.w	10(a0),22(a1)
	move.w	12(a0),26(a1)
	move.w	14(a0),30(a1)
	move.w	16(a0),34(a1)
	move.w	18(a0),38(a1)
	move.w	20(a0),42(a1)
	move.w	22(a0),46(a1)
	addq.w	#4,6(a1)		skip the hidden words in the
	addq.w	#4,14(a1)		background
	addq.w	#4,22(a1)
	lea	scroll.value(pc),a0
	move.w	#$ff,2(a0)

	move.l	#panel+32,d0		put the address of the panel
	lea	rastersplit2(pc),a1	graphics into the copper
	moveq	#3,d1			the panel is 4 planes
setup1	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#1408,d0		panel size is 352x32 (1408 bytes
	addq	#8,a1			per plane)
	dbf	d1,setup1

	lea	level.colours(pc),a0	copy the level colours into the
	lea	colours(pc),a1		copperlist
	moveq	#31,d0
.copy	move.w	(a0)+,2(a1)
	addq	#4,a1
	dbf	d0,.copy

	lea	panel.colours(pc),a0	copy the panel colours into the
	lea	colours2(pc),a1		copperlist
	moveq	#15,d0
.copy2	move.w	(a0)+,2(a1)
	addq	#4,a1
	dbf	d0,.copy2

	bsr	ship.to.copper		setup the hardware sprite pointers

	bsr	clear.screen
	bsr	buildbackgnd		and draw the background
	bsr	setup.mouse

	IFNE	FullFirepower
	st.b	mult1.on(a5)
	st.b	mult2.on(a5)
	st.b	canons.on(a5)
	st.b	lasers.on(A5)
	move.w	#2,ship.speed(A5)
	move.b	#3,ship.status(a5)	
	bsr	change.ship
	ENDC
	rts


clear.screen
	move.l	rasters(a5),a0		clear all the screen memory
	move.w	#MemNeeded/4-1,d0
clear.scr1
	clr.l	(a0)+
	dbf	d0,clear.scr1
	rts

**************************************************************************

moveship
	bsr	joy			read joystick & mouse
	tst.w	ypos(a5)		upper y limit of 0
	bge	up.ok
	clr.w	d0			reset up flag if not allowed
	clr.w	yvector(a5)		and no y movement
up.ok	cmp.w	#150,ypos(a5)		maximum y value is 150
	ble	down.ok
	clr.w	d1			if at max signal down no more
	clr.w	yvector(a5)
down.ok	tst.w	xpos(a5)		minimum x position is 0
	bge	left.ok
	clr.w	d3
	clr.w	xvector(a5)
left.ok	cmp.w	#266,xpos(a5)		maximum x position is 266
	ble	right.ok
	clr.w	d2
	clr.w	xvector(a5)
right.ok

	move.w	ship.speed(a5),d4	d4 = ship speed
	move.w	d4,d5			d5 = -ve ship speed
	neg.w	d5				
	clr.w	up.down(a5)		make ship untilt
	move.w	yvector(a5),d7		change the y vector first
up	tst.w	d0			are we going up?
	beq	down			no, so check down	
	move.w	#-560,up.down(a5)	yes, so tilt ship up (anims 560 bytes apart)
	cmp.w	d7,d5			are we at max y speed
	beq	right			yes, so go and check x movement
	subq.w	#1,d7			no, so decrease the vector
	bra	right
down	tst.w	d1			are we going down?
	beq	right			no, so check right
	move.w	#560,up.down(a5)	yes, so tilt the ship down
	cmp.w	d7,d4			are we at max y speed
	beq	right			yes, so check x movement
	addq.w	#1,d7			no, so increase the y vector
right	move.w	d7,yvector(a5)		store the new y vector
	move.w	xvector(a5),d7
	clr.w	d6			now do the x vector which is
	tst.w	d2			virtually identical to the y above
	beq	left
	moveq	#1,d6
	cmp.w	d7,d4
	beq	add.vectors
	addq	#1,d7
	bra	add.vectors
left	tst.w	d3
	beq	add.vectors
	moveq	#-1,d6
	cmp.w	d7,d5
	beq	add.vectors
	subq	#1,d7
add.vectors
	move.w	d7,xvector(a5)

	or.w	d2,d3			if we have moved left or right we
	bne	checky			may have to alter the animation
	move.w	#4,mult.delay(a5)	of the multiples

	moveq	#1,d7			if the ship is not being moved but
	tst.w	xvector(a5)		still has some inertia then decrease
	beq	checky			the x & y vectors until they hit 0
	bmi	xto0
	neg.w	d7
xto0	add.w	d7,xvector(a5)
checky	or.w	d0,d1
	bne	add.vectors2
	moveq	#1,d7
	tst.w	yvector(a5)
	beq	add.vectors2
	bmi	yto0
	neg.w	d7
yto0	add.w	d7,yvector(a5)

add.vectors2
	move.w	xpos(a5),d4		finally add the new vectors to
	move.w	ypos(a5),d5		the x & y coordinates
	add.w	xvector(a5),d4
	add.w	yvector(a5),d5
	move.w	d4,xpos(a5)
	move.w	d5,ypos(a5)
	bsr	xytosprite		convert the xy coords into
	move.l	shipaddress(a5),a0	hardware sprite format
	add.w	up.down(a5),a0		add the up/down offset


	* now set up the four hardware sprite control words

	move.l	d0,(a0)			ship 1.1 (rear end)
	bset	#7,d0
	move.l	d0,184(a0)		ship 1.2 with attach bit set
	add.l	#$0b080000,d0		add 11 to vstart & 16 to hstart
	bclr	#7,d0			reset attach bit
	sub.w	#$0b00,d0		vstop is 11 less
	move.l	d0,2*184(a0)		ship 1.3 (front)
	bset	#7,d0			set attach
	move.l	d0,2*184+96(a0)		ship 1.4
	bsr	ship.to.copper		put the address of the current
	subq.w	#1,mult.delay(a5)	ship in the copper
	bne	same.outrider		and finally work out which multiple 
	move.w	#4,mult.delay(a5)	to display
	add.w	d6,mult.number(a5)	outriders must be between
	bne	max.mult		1 & 5
	move.w	#1,mult.number(a5)
max.mult
	cmp.w	#6,mult.number(a5)
	bne	same.outrider
	move.w	#5,mult.number(a5)
same.outrider
	bsr	draw.outrider		draw the multiple into the sprite
	rts

**************************************************************************

xytosprite
*	d4 = x coordinate
*	d5 = y coordinate
*	returns d0.l as the control words

	clr.l	d0			return longword in do
	add.w	#44-11,d5		hardware offset vertical
	lsl.w	#8,d5			into bits 8-15
	add.w	#128,d4			horizontal offset
	lsr.w	#1,d4			/2 low bit into extend
	or.w	d5,d4			X intact
	move.w	d4,d0			X still intact
	swap	d0			ditto
	roxl.w	#1,d0			get low bit of hstart into bit 0
	add.w	#$2c00,d5		calcualate vstop (+44 lines)
	or.w	d5,d0			low word set up
	rts

**************************************************************************

draw.outrider
	move.w	mult.number(a5),d0	get the animation number
	tst.b	mult1.on(a5)		for the multiple
	bne	mult1ok
	clr.w	d0
mult1ok
	lea	outriders,a0		base address of outriders
	mulu	#44,d0			44 bytes per plane for pair
	add.w	d0,a0
	move.l	a0,a1			a0 = plane 1
	add.w	#264,a1			a1 = plane 2
	move.l	shipaddress(a5),a2	current ship address
	add.w	up.down(a5),a2
	addq	#4,a2			get past sprite header
	movem.l	a0-a2,-(sp)
	moveq	#10,d7			11 lines high
out1	move.w	(a0)+,(a2)+
	move.w	(a1)+,(a2)+
	dbf	d7,out1
	tst.b	mult2.on(a5)
	bne	mult2ok
	lea	outriders,a0		if mult 2 not on then
	move.l	a0,a1			point the data to zeroes
mult2ok
	add.w	#22*2*2,a2		pass the ship graphics
	moveq	#10,d7			and draw the bottom one
out2	move.w	(a0)+,(a2)+
	move.w	(a1)+,(a2)+
	dbf	d7,out2			planes 1 & 2 done

	movem.l	(sp)+,a0-a2		get back pointers
	add.w	#528,a0			a0 = plane 3
	add.w	#528,a1			a1 = plane 4
	add.w	#44*4+8,a2		next sprite
	moveq	#10,d7			11 lines high
out3	move.w	(a0)+,(a2)+
	move.w	(a1)+,(a2)+
	dbf	d7,out3
	tst.b	mult2.on(a5)
	bne	mult3ok
	lea	outriders,a0		if mult 2 not on then
	move.l	a0,a1			point the data to zeroes
mult3ok
	add.w	#22*2*2,a2		pass the ship graphics
	moveq	#10,d7			and draw the bottom one
out4	move.w	(a0)+,(a2)+
	move.w	(a1)+,(a2)+
	dbf	d7,out4			planes 3 & 4 done
	rts


**************************************************************************

setup.mouse
	move.w	joy0dat(a6),d4		read the mouse x,y position so
	move.w	d4,-(sp)
	and.w	#$ff,d4			the ship doesnt jump when we
	move.w	d4,oldmousex(a5)	start
	move.w	(sp)+,d4
	lsr.w	#8,d4
	move.w	d4,oldmousey(a5)
	rts

joy	move.w	#$0100,d0		setup the mask for each bit in
	move.w	#$0001,d1		the joystick register
	move.w	#$0002,d2		the routine returns left/right
	move.w	#$0200,d3		/up/down in d0..d3
	move.w	joy1dat(a6),d4		if the corresponding data register
	and.w	d4,d0			is not = 0 then the joystick
	and.w	d4,d1			had been pressed in that direction
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#1,d0
	lsl.w	#1,d1
	eor.w	d2,d1
	eor.w	d3,d0

	move.w	joy0dat(a6),d4		read the mouse counters, if a move
	move.w	d4,-(sp)		has been detected then set the
	and.w	#$ff,d4			appropiate joystick registers
	sub.w	oldmousex(a5),d4	to mimick a joystick move
	beq	noxmove
	bmi	leftmove		this is not a proper proportional
	moveq	#1,d2			read but a simple up/dowm/left/right
	bra	noxmove			check
leftmove
	moveq	#1,d3
noxmove	move.w	(sp),d4
	lsr.w	#8,d4
	sub.w	oldmousey(a5),d4
	beq	joyend
	bmi	upmove
	moveq	#1,d1
	bra	joyend
upmove	moveq	#1,d0
joyend	move.w	(sp),d4
	and.w	#$ff,d4
	move.w	d4,oldmousex(a5)	save the mouse values for comparison
	move.w	(sp)+,d4		next time around
	lsr.w	#8,d4
	move.w	d4,oldmousey(a5)
	rts

**************************************************************************

ship.to.copper
	move.l	shipaddress(a5),a1	get the current ship address
	add.w	up.down(a5),a1		and update the four sprite
	move.l	a1,d0			pointers in the copperlist
	move.l	a1,d1			
	move.l	a1,d2
	move.l	a1,d3	
	add.w	#184,d1			work out the address of each		
	add.w	#184*2,d2		hardware sprite
	add.w	#184*2+96,d3
	lea	sprite(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d1,14(a0)
	swap	d1
	move.w	d1,10(a0)
	move.w	d2,22(a0)
	swap	d2
	move.w	d2,18(a0)
	move.w	d3,30(a0)
	swap	d3
	move.w	d3,26(a0)
	rts

**************************************************************************

change.ship
	clr.w	d0
	move.b	ship.status(a5),d0	1 = canons, 2 = lasers, 3 = both
	lea	ship1.2(pc),a0
	mulu	#1680,d0		968 bytes for the four sprites
	add.l	d0,a0			per ship
	move.l	a0,shipaddress(a5)	store the ship address
	rts

**************************************************************************


clist		DC.W	$0A01,$FF00
copperlist	DC.W	bplpt+0,$0000,bplpt+2,$0000
		DC.W	bplpt+8,$0000,bplpt+10,$0000
		DC.W	bplpt+16,$0000,bplpt+18,$0000
		DC.W	bplpt+4,$0000,bplpt+6,$0000
		DC.W	bplpt+12,$0000,bplpt+14,$0000
		DC.W	bplpt+20,$0000,bplpt+22,$0000
		DC.W	bplcon0,$6600
scroll.value	DC.W	bplcon1,$00FF,bpl1mod,$0036
		DC.W	bpl2mod,$002E,bplcon2,$0044
		DC.W	ddfstrt,$0028,ddfstop,$00D8
		DC.W	diwstrt,$1F78,diwstop,$FFC6
colours		DC.W	color+0,$0000,color+2,$0000
		DC.W	color+4,$0000,color+6,$0000
		DC.W	color+8,$0000,color+10,$0000
		DC.W	color+12,$0000,color+14,$0000
		DC.W	color+16,$0000,color+18,$0000
		DC.W	color+20,$0000,color+22,$0000
		DC.W	color+24,$0000,color+26,$0000
		DC.W	color+28,$0000,color+30,$0000
		DC.W	color+32,$0000,color+34,$0000
		DC.W	color+36,$0000,color+38,$0000
		DC.W	color+40,$0000,color+42,$0000
		DC.W	color+44,$0000,color+46,$0000
		DC.W	color+48,$0000,color+50,$0000
		DC.W	color+52,$0000,color+54,$0000
		DC.W	color+56,$0000,color+58,$0000
		DC.W	color+60,$0000,color+62,$0000

sprite		DC.W	sprpt+0,$0000,sprpt+2,$0000
		DC.W	sprpt+4,$0000,sprpt+6,$0000
		DC.W	sprpt+8,$0000,sprpt+10,$0000
		DC.W	sprpt+12,$0000,sprpt+14,$0000
		DC.W	sprpt+16,$0000,sprpt+18,$0000
		DC.W	sprpt+20,$0000,sprpt+22,$0000
		DC.W	sprpt+24,$0000,sprpt+26,$0000
		DC.W	sprpt+28,$0000,sprpt+30,$0000

		DC.W	$DF01,$FF00
		DC.W	bplcon1,$0000,bplcon0,$4200,ddfstrt,$0030
rastersplit2	DC.W	bplpt+0,$0000,bplpt+2,$0000
		DC.W	bplpt+4,$0000,bplpt+6,$0000
		DC.W	bplpt+8,$0000,bplpt+10,$0000
		DC.W	bplpt+12,$0000,bplpt+14,$0000
colours2	DC.W	color+20,$0000,color+30,$0000
		DC.W	color+2,$0000,color+4,$0000
		DC.W	color+6,$0000,color+8,$0000
		DC.W	color+10,$0000,color+12,$0000
		DC.W	color+14,$0000,color+16,$0000
		DC.W	color+18,$0000,color+22,$0000
		DC.W	color+24,$0000,color+26,$0000
		DC.W	color+28,$0000,color+0,$0000
		DC.W	bpl1mod,$0000,bpl2mod,$0000
		DC.W	$DF01,$FF00,intreq,$8010
		DC.W	$FFFF,$FFFE


panel.colours	DC.W	$0600,$0333,$0fb3,$0d00,$0b00,$0720,$0fc2,$0c90
		DC.W	$0a40,$0eb0,$0eca,$0456,$0577,$0252,$0444,$0000

	rsreset
screen.num	RS.B	1	
vcount		RS.B	1	vertical blank counter
mult1.on	RS.B	1	byte set if a multiple is attached to ship
mult2.on	RS.B	1	same for another multiple (2 max)
canons.on	RS.B	1	bytes are set to signify what weapons
lasers.on	RS.B	1	are attached
ship.status	RS.B	1	values to indicate which ship to draw

ship.speed	RS.W	1	speed in pixels
xpos		RS.W	1	ship x position
ypos		RS.W	1	ship y position
mult.number	RS.W	1	multiple animation number
mult.delay	RS.W	1	multiple animation delay
xvector		RS.W	1	inertia vectors for the ship
yvector		RS.W	1
oldmousex	RS.W	1	store the old mouse values to reference
oldmousey	RS.W	1	the new ones to
up.down		RS.W	1	this holds the graphic offset for a ship tilt

pf1count	RS.W	1	number of background words to scroll
pf2count	RS.W	1	number of foreground words to scroll
pf1scroll	RS.W	1	pixel scroll value (0-15) background
pf2scroll	RS.W	1	pixel scroll value (0-15) foreground
pf1scroll2	RS.W	1
pf2offset	RS.W	1
screenend	RS.W	1
level.end	RS.W	1
level.number	RS.W	1

fgndpointer	RS.L	1	foreground map pointer
displayraster	RS.L	6	holds the addresses of the planes
rasters 	RS.L	9	updated plane addresses
shipaddress	RS.L	1	ship animation address

vars.length	RS.B	0
variables	DS.B	vars.length

backgroundtable	DC.W	$0123,$0123,$0123,$0123,$0123,$0123 background
		DC.W	$4567,$4567,$4567,$4567,$4567,$4567 map
		DC.W	$89AB,$89AB,$89AB,$89AB,$89AB,$89AB
		DC.W	$0123,$0123,$0123,$0123,$0123,$0123
		DC.W	$4567,$4567,$4567,$4567,$4567,$4567
		DC.W	$89AB,$89AB,$89AB,$89AB,$89AB,$89AB
		DC.W	$0123,$0123,$0123,$0123,$0123,$0123
		DC.W	$4567,$4567,$4567,$4567,$4567,$4567
		DC.W	$89AB,$89AB,$89AB,$89AB,$89AB,$89AB
		DC.W	$0123,$0123,$0123,$0123,$0123,$0123
		DC.W	$4567,$4567,$4567,$4567,$4567,$4567
		DC.W	$89AB,$89AB,$89AB,$89AB,$89AB,$89AB

backgrounds	DC.W  $1430,$0C30,$0C10,$0413,$8403,$4442,$2142,$3120
		DC.W  $3110,$2810,$141C,$1417,$140B,$0C71,$0A00,$DC08
		DC.W  $8A08,$9208,$0229,$8208,$4244,$2221,$12A1,$0891
		DC.W  $0888,$148A,$0A03,$2A48,$8A44,$9208,$8524,$2204

		DC.W  $0210,$0230,$1118,$0118,$8128,$414C,$314C,$10CA
		DC.W  $1005,$1013,$5103,$31C3,$5023,$D011,$3018,$6304
		DC.W  $0129,$0908,$0884,$0884,$4294,$22A2,$08A2,$0825
		DC.W  $0842,$0908,$2880,$C824,$2890,$2808,$0904,$1092

		DC.W  $0300,$4220,$0461,$0451,$0850,$08C8,$38C8,$1848
		DC.W  $0848,$0848,$0848,$08C8,$0148,$1050,$E060,$4041
		DC.W  $2084,$2110,$2210,$0228,$0429,$1424,$0424,$0424
		DC.W  $8424,$8424,$8424,$8424,$80A4,$8828,$1011,$2420

		DC.W  $1430,$0C08,$0800,$0413,$8083,$4442,$2242,$2120
		DC.W  $2110,$2810,$040C,$1487,$104B,$0C71,$0A10,$D908
		DC.W  $8A08,$9000,$042D,$8008,$4244,$2221,$1121,$0091
		DC.W  $0888,$048A,$0A03,$2240,$8220,$9208,$8124,$2004

		DC.W  $7028,$6218,$8218,$C208,$C210,$C210,$6420,$2420
		DC.W  $4820,$4820,$8843,$0882,$108C,$2118,$2220,$4421
		DC.W  $0914,$1104,$4104,$2504,$2508,$2508,$9250,$1250
		DC.W  $2450,$2410,$4420,$8441,$0840,$1080,$1110,$A210

		DC.W  $C60C,$C60A,$4609,$2209,$A201,$A223,$9011,$901F
		DC.W  $900C,$8C18,$0620,$060F,$0213,$0404,$1405,$1419
		DC.W  $2102,$2105,$2104,$5104,$5124,$5110,$4908,$4900
		DC.W  $4902,$4204,$8912,$0900,$2508,$0212,$4A02,$EA04

		DC.W  $0080,$0100,$0110,$0918,$0A14,$0A33,$8A31,$0621
		DC.W  $0220,$8204,$8204,$860D,$860A,$8A0C,$0108,$0101
		DC.W  $4940,$0888,$8888,$8484,$852A,$8508,$4508,$8110
		DC.W  $4911,$4902,$490A,$4102,$4905,$4502,$8084,$9088

		DC.W  $7028,$4318,$8298,$C248,$8250,$C210,$6120,$20A0
		DC.W  $5820,$4820,$8813,$188A,$108C,$2100,$2220,$4421
		DC.W  $0914,$1004,$4144,$2504,$4528,$2528,$9290,$1010
		DC.W  $2010,$2410,$4428,$8405,$0842,$1080,$1100,$A210

		DC.W  $8820,$0440,$0204,$1202,$8221,$8220,$8300,$8410
		DC.W  $C080,$0180,$20C0,$6040,$7060,$31A1,$2820,$2820
		DC.W  $4410,$8A24,$0122,$8921,$4910,$4110,$4090,$4208
		DC.W  $2448,$8048,$1020,$1220,$0910,$0850,$9492,$1412

		DC.W  $CE02,$4A02,$5402,$0442,$0844,$9048,$E148,$4150
		DC.W  $23A0,$31C4,$3185,$3842,$2820,$11A0,$23A0,$6322
		DC.W  $0101,$2501,$2A01,$9221,$9422,$68A4,$10A4,$A0A8
		DC.W  $1050,$0822,$0842,$04A1,$1412,$8850,$5051,$1091

		DC.W  $3100,$11C0,$10C1,$10E1,$4862,$8850,$9850,$88F0
		DC.W  $E830,$7031,$0028,$8248,$4088,$4018,$2018,$3018
		DC.W  $0881,$0821,$0820,$0810,$2411,$5429,$44A9,$4408
		DC.W  $0408,$0808,$8114,$4124,$2144,$2104,$1224,$0844

		DC.W  $C820,$4440,$2204,$1002,$8225,$8224,$8308,$8418
		DC.W  $C980,$1188,$20C4,$6040,$6260,$2121,$2820,$2820
		DC.W  $0410,$AA24,$1122,$8921,$4912,$0110,$4094,$4380
		DC.W  $2448,$8844,$1020,$1220,$0110,$0850,$9492,$1412

level.colours
		DC.W	$0332,$0055,$0543,$0000,$0000,$0000,$0000,$0000
		DC.W	$0000,$0F55,$0B05,$0700,$08A7,$0182,$0065,$0055
		DC.W	$0000,$0FF6,$0000,$0FD0,$0A00,$0BDF,$06AF,$004F
		DC.W	$0FFF,$0CDD,$0ABB,$0798,$0587,$0465,$0243,$0E32


*******************************************************************************
*******************************************************************************

finished
	bsr	FreeSystem

MemError	move.l	_SysBase,a6
	move.l	MemBase,a1
	move.l	#MemNeeded,d0		free the memory we took
	jsr	_LVOFreeMem(a6)
	move.l	GraphicsBase,a1	
	jsr	_LVOCloseLibrary(a6)
	move.l	DOSBase,a1		finally close the 
	jsr	_LVOCloseLibrary(a6)	libraries
	clr.l	d0
	rts

*******************************************************************************

TakeSystem
	move.w	intenar(a6),SystemInts		save system interupts
	move.w	dmaconr(a6),SystemDMA		and DMA settings
	move.w	#$7fff,intena(a6)		kill everything!
	move.w	#$7fff,dmacon(a6)
	move.b	#%01111111,ICRA			kill keyboard
	move.l	$68,Level2Vector		save these interrupt vectors
	move.l	$6c,Level3Vector		as we will use our own 
	rts					keyboard & vblank routines

FreeSystem
	move.l	Level2Vector,$68	restore the system vectors
	move.l	Level3Vector,$6c		and interrupts and DMA
	move.l	GraphicsBase,a1			and replace the system
	move.l	SystemCopper1(a1),Hardware+cop1lc	copper list
	move.l	SystemCopper2(a1),Hardware+cop2lc
	move.w	SystemInts,d0
	or.w	#$c000,d0
	move.w	d0,intena(a6)
	move.w	SystemDMA,d0
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)
	move.b	#%10011011,ICRA	keyboard etc back on
	rts

*******************************************************************************

Level2Vector		dc.l	0
Level3Vector		dc.l	0
SystemInts		dc.w	0
SystemDMA		dc.w	0
MemBase			dc.l	0
DOSBase			dc.l	0
GraphicsBase		dc.l	0

	even
GraphicsName	dc.b	'graphics.library',0
	even
DOSName		dc.b	'dos.library',0

*******************************************************************************

shipbase	include	ships.s
graphics	incbin	foregrounds
map		incbin	map
panel		incbin	panel


	end

