;This is version 3..
;load an IFF map and convert it into an iso landscape
;This will probably be the routine used in the final version
;the iff file ive got is in 16 colours!
;but ive only got 8 different heights!
;oh, well for the moment
;ill convert it into the seedmap (i.e. just heights)
;and then worry about putting it in the proper map format
;of 1map per height. so the full game will have 8 maps, 1 for each height

;there are a lot of redundant routines in this program.
;its probably worth just cutting the code i need
;and start again

;new method which should give good rnd landscape.
;use same method as now but.
;grab seed for x,y starting position
;grab seed for xsize,ysize
;and then generate for that small area
;got to writethe program so that it fits smoothly with the landscape below it.

;Alternative method for seed generated maps
;generate a seed for every nth char (with limits in n)
;and then calculate the data that should be inbetween the 2 points



;gotto do summink to stop the scenery going up off of the screen.

;a bgt should be a blt (in single pair)


;i think that when it gets the 4 sqrs to decide what to do, it botches it!


;ok, itseems to just make a really big mountain...
;increasing each time.
;now, i think the problem is this.
;create the map properly,
;i.e. use mapsizeX
;instead of just starting at the beginning and bombing through
;if that doesnt work then its probably worth
;trying a different way to create the seed


;i think that it all works now, but
;the seed doesnot give random enough data...
;it seems to repeat after 8


;DONT RUN THIS VERSION!!!!!!!
;it creates a seed map indefinately and will soon crash on you
;rem out the bsr makeseed maps (2 1 in main 1 just before)
;edited the seed prog.

;match 3 (all 4 same) 		should work..
;match 2 (3 same)		TODO
;match 1 (2 same or 2 pair)	TODO
;match 0 			crash real badly, but should never occur


;********************************************
debugging	equ	0
;********************************************

;edited copperlist to work of A1200
	section screen,code_c		;make sure chip ram


	
	opt	c+

;	        v start drawing from here left then down
;	\-------\
;	 \-------\
; 	  \-------\
;	   \-------\

size	equ	250	;temp x,y map size
scrwid	equ	40
viswid	equ	40
scrhi	equ	256
vishi	equ	256
bitplanes	equ	5
screensize	equ	scrwid*scrhi*bitplanes
viewsize	equ	8
adjust	equ	8	;this is the value of the average height

	bra	Start
	
showCOLL	dc.b	0	;show only the collision copperlist
	dc.b	"$VER:Final3a",0
	cnop	0,4
Start	
	
	lea	gfxname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_GfxBase

	lea	intname,a1          ;
	moveq	#39,d0                  ; Kickstart 3.0 or higher
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase       ; store intuitionbase

	lea	iffname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_IFFBase
	
	
	lea	dosname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_DOSBase


	bsr	allocIsoBase
	bsr	allocmapBase

	;load isogfx (iso gfx)
	bsr	loadiso

	
	ifeq debugging
	bsr	GetSystem		
	
	bsr	vblank
	bsr	vblank
	move.l	#new,$dff080
	endc

	move.w	#$8400,$dff096

	bsr	allocscrbase
	cmp.l	#0,scrbase
	beq	NO_MEMORY	;no memory
	move.l	scrbase,screen1
	bsr	allocscrbase
	move.l	scrbase,screen2
	

	bsr	go_bitplanes
	bsr	go_colour	

	bsr	get_old_cop	

	move.w	#viewsize,d0
;	rol.w	#1,d0
	sub.w	#1,d0
	move.w	d0,mapxpos
	
	move.w	#0,mapypos

	bsr	godrawvisible

	move.l	seedORIG,seed
;	bsr	makeseedmap

;	bsr	makeseedmap

	bsr	loadiffmap	;load map and convert to bitmap
	bsr	convertmap	;store it in seedmap
	
	bsr	newseed
	bsr	copyin

	bsr	slow
main
	ifeq debugging
	bsr	vblank
	endc

;	bsr	go_bitplanes
	bsr	keys	
;	move.w	#$fff,$dff180


	
	move.w	#$0,$dff180

	
	cmp.b	#$3f,$bfec01
	bne	main
	
exit	move	#%1000000000100000,$dff096;enable sprites
	
	ifeq debugging	
	move.l	old,$dff080	

	bsr	RestSystem

	endc
		
	move.l	screen1,scrbase
	bsr	freescrbase
	move.l	screen2,scrbase
	bsr	freescrbase
	bsr	FreeIsoBase
	bsr	FreemapBase
	
	bsr	CloseLibs
NO_MEMORY	rts

	include	slyma/initial	;vblank,vblank2,go_colour,allocscrbase,freescrbase,get_old_cop
	include	slyma/setup.i

CloseLibs
	move.l	_GfxBase,a1
	cmp.l	#0,a1
	beq	.hup
	CALLEXEC	CloseLibrary
.hup
	move.l	_IFFBase,a1
	cmp.l	#0,a1
	beq	.hup2
	CALLEXEC	CloseLibrary
.hup2
	move.l	_DOSBase,a1
	cmp.l	#0,a1
	beq	.hup3
	CALLEXEC	CloseLibrary
.hup3
	move.l	_IntuitionBase,a1
	cmp.l	#0,a1
	beq	.hup4
	CALLEXEC	CloseLibrary
.hup4

	rts

keys
;cursor keys
; up = $67
; dn = $65
; rt = $63
; lt = $61
; f9 = $4f
;f10 = $4d

	cmp.b	#$4d,$bfec01
	bne	.nomap
	;change bitplane pointers to map
	move.l	mapbase,d0
	bsr	go_bitplanes2
	lea	mapcol,a0
	bsr	go_colour2
	move.w	#$0fff,$dff180
	bsr	domap
	
.nomap
	cmp.b	#$4f,$bfec01
	bne	.nonorm
	;change bitplane pointers to screen
	bsr	go_bitplanes
	bsr	go_colour
.nonorm

	cmp.b	#$67,$bfec01
	bne	.notup
	cmp.w	#0,mapypos
	beq	.notup
	sub.w	#1,mapypos
	bsr	slow
.notup
	cmp.b	#$65,$bfec01
	bne	.notdown
	clr.l	d0
	move.w	mapsizeY,d0
	sub.w	#viewsize,d0
	cmp.w	mapypos,d0
	beq	.notdown
	add.w	#1,mapypos
	bsr	slow
.notdown
	cmp.b	#$61,$bfec01
	bne	.notleft
	cmp.w	#viewsize-1,mapxpos
	beq	.notleft
	sub.w	#1,mapxpos
	bsr	slow
.notleft
	cmp.b	#$63,$bfec01
	bne	.notright
	clr.l	d0
	move.w	mapsizeX,d0
	cmp.w	mapxpos,d0
	beq	.notright
	add.w	#1,mapxpos
	bsr	slow
.notright
	rts
	
slow
	;okay we want to draw this on the screen
	;that is not being shown.
	move.l	screen1,a0
	cmp.l	scrbase,a0
	bne	.its2
	move.l	screen2,a0
.its2
	move.l	a0,scrbase
	;this routine was origonally put in to slow it all down
	;that was before i realised that i needed a cls routine.

;	move.l	scrbase,a0	;screen 
;	add.l	#2-viewsize,a0
	add.l	#(32)*(40*5),a0	;first 5 is max height from base
	
	move.l	#(viewsize+2+(viewsize/4))*16,d7
.loop2

	move.l	a0,a1
	move.w	#5-1,d6
.loop3
	move.l	#$80000000,(a1)
	move.l	#$0,4(a1)
	move.l	#$0,8(a1)
	move.l	#$0,12(a1)
	move.l	#$0,16(a1)
	move.l	#$0,20(a1)
	move.l	#$0,24(a1)
	move.l	#$0,28(a1)
	add.l	#40,a1
	dbra	d6,.loop3
	
	add.l	#40*5,a0
	sub.l	#1,d7
	bne	.loop2


;	move.w	#10,d7
;.loop
;	bsr	vblank
;	dbra	d7,.loop

	bsr	godrawvisible

	bsr	go_bitplanes

	rts	
	


go_bitplanes
	move.l	scrbase,d0
go_bitplanes2
	move.w	#5-1,d7
;	move.l	IsoBase,d0
	lea	bit1h,a0
cloop
	move.w	d0,4(a0)	;bit1l
	swap	d0
	move.w	d0,(a0)	;bit1h
	swap	d0
	add.l	#40,d0	;next bitplane
	add.l	#8,a0	;next copper pos.
	dbra	d7,cloop
	rts

allocIsoBase
	move.l	#$10002,d1	;memory Ill have chip please
	move.l	#40*256*5,d0	;this much please
	CALLEXEC	AllocMem
	move.l	d0,IsoBase
	rts

FreeIsoBase
	move.l	#40*256*5,d0
	move.l	IsoBase,a1	;memory Ill have chip please
	CALLEXEC	FreeMem
	rts

allocmapBase
	move.l	#$10002,d1	;memory Ill have chip please
	move.l	mapsize,d0	;this much please
	CALLEXEC	AllocMem
	move.l	d0,mapbase
	rts

FreemapBase
	move.l	mapsize,d0
	move.l	mapbase,a1	;memory Ill have chip please
	CALLEXEC	FreeMem
	rts

	rts	
	
loadiso
	bsr	LoadisoCmap

	lea	isoname,a0
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#256,d2		;height & mask
	CALLGRAF	InitBitMap
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	IsoBase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#40,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	
	
	rts

LoadisoCmap
;	rts	;**** REMOVE ME ****
	
	;this loads an iff file with the cmap in it!!!!
	lea	isoname,a0
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle

	move.l	iffhandle,a1		;iff handle ??
	lea	colours,a0
	CALLIFF	GetColorTab

	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	

	rts
LoadmapCmap
;	rts	;**** REMOVE ME ****
	
	;this loads an iff file with the cmap in it!!!!
	lea	iffmap,a0
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle

	move.l	iffhandle,a1		;iff handle ??
	lea	mapcol,a0
	CALLIFF	GetColorTab

	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	

	rts

godrawvisible
	;to keep the visible level on the screen we have to fart 
	;around with some things.
	;#1 grab the first square and grab that height as the average
	;if its over 5 then sub v to make it 5 then sub v from everything

	;NOTE.
	;the level is draw from the TOP RIGHT left and down

	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#40-4,$dff062	;mod b
	move.w	#scrwid-4,$dff060	;mod C
	move.w	#scrwid-4,$dff066	;mod D

	move.w	#0,$dff042	
	move.w	#$0fce,$dff040	



	clr.l	d7
	clr.l	d6
	move.w	#viewsize,d6	;max y
	sub.w	#1,d6
	
	move.l	scrbase,a0	;screen 
	add.l	#22-viewsize,a0
	add.l	#80*(40*5),a0

	lea	mapdata,a1
	clr.l	d0
	move.w	mapxpos,d0
	rol.l	#1,d0		;map data is in byte pairs
	add.l	d0,a1	
	
	clr.l	d0
	move.w	mapsizeX,d0
	rol.l	#1,d0
	mulu	mapypos,d0
	add.l	d0,a1
	
	move.l	a0,savescr
	move.l	a1,savemap
	
	;this little section is to determin the average height of the viewed section
	clr.l	d0
	clr.l	d1

	add.l	#1,d1
	move.b	(a1,d1),d0	;get first char height
	cmp.b	#adjust,d0
	blt	.ok
	;ok, he is over 5 then sub 5 from it and make that the ADJVAL
	sub.b	#adjust,d0
	move.b	d0,ADJVAL	;adjustment value
.ok
	
	
.loopy
	move.l	savescr,a0
	move.l	savemap,a1
	;set these below up for next loop
	add.l	#2,savescr
	add.l	#8*40*5,savescr

	clr.l	d5
	move.w	mapsizeX,d5
	add.w	mapsizeX,d5
	add.l	d5,savemap
;	add.l	#5*2,savemap
	
	move.w	#viewsize,d7	;max x
	sub.w	#1,d7
	
.loopx
	clr.l	d0
	clr.l	d1
	move.b	(a1)+,d0	;get char
	sub.b	#1,d0
	
	move.l	IsoBase,a2
	;each char is 32 wide so * by 4
	asl.l	#2,d0
	add.l	d0,a2
;	add.l	#8,a2

;	move.l	IsoBase,a2
	
	;if height = 0 then skip
	;if height = 1 then print char
	
	;if height > 1 then print Blank block until height =1
	
	clr.l	d0
	move.b	(a1)+,d0	;get height
	sub.b	ADJVAL,d0
	
	cmp.b	#0,d0
	ble	.next	;if its a zero or under then next
	
	cmp.b	#1,d0
	bne	.nottop
	
	;blit the char here please my good man
	bsr	blitblock
	
.next	;next block
	sub.l	#4,a1	;next square map
	sub.l	#2,a0	;next square screen
	add.l	#8*40*5,a0
	dbra	d7,.loopx

	dbra	d6,.loopy	
	rts
.nottop
	move.l	a0,temp1

.loopin

	sub.l	#8*40*5,a0	
	sub.b	#1,d0
	cmp.b	#1,d0
	bne	.loopin

	bsr	blitblock
	move.l	temp1,a0
	bra	.next		
	rts

blitblock
	;now print the top on.
	CALLGRAF	WaitBlit
	
	move.l	a2,a5
	move.l	a2,a3
	add.l	#32*40*5,a3	;goto mask (its on the next line)
	
	move.l	a3,$dff050	;get mask A
	move.l	a5,$dff04c	;src B	bob
	move.l	a0,$dff048	;src C	screen
	move.l	a0,$dff054	;dst D	screen
	move.w	#(32*5*64)+2,$dff058
	CALLGRAF	WaitBlit


	rts

getrndff
	bsr	newseed
	move.l	seed,d0
	and.l	#$ff,d0	;kill all but end bits
	cmp.l	d7,d0
	bgt	getrndff
	rts
getrndf
	bsr	newseed
	move.l	seed,d0
	and.l	#$f,d0	;kill all but end bits
	cmp.l	d7,d0
	bgt	getrndf
	rts



makeseedmap
	;this will grab the value from the seed and then put it in 
	;map correctly.

	;this horrible routine only does 1 char at a time
	;so make a little loop using d4 and d5 and isostart

	move.l	#50,repeat
.rep

	
	move.l	isostart,temp	;save it so i can play!
	move.l	isostart,temp1

	;get random map position!
	;get randomm sizes
.getx	clr.l	d1
	move.w	mapsizeX,d7
	bsr	getrndff
	move.l	d0,tempx

.gety	clr.l	d1
	move.w	mapsizeY,d7
	bsr	getrndff
	move.l	d0,tempy

	bsr	newseed
	
	lea	seedmap,a0
	move.l	tempy,d0
	mulu	mapsizeX,d0
	add.l	tempx,d0
	
	add.l	d0,a0
	move.l	a0,temp
	move.l	a0,temp1




	;get randomm sizes
.getxsz	clr.l	d1
	move.w	#50,d7
	bsr	getrndff
	move.l	d0,tempx

.getysz	clr.l	d1
	move.w	#50,d7
	bsr	getrndff
	move.l	d0,tempy




	;d4 = x ; d5 = y
;	clr.l	d5
;	move.w	mapsizeY,d5
;	sub.w	#1,d5
	move.l	tempy,d5
.loopy

;	clr.l	d4
;	move.w	mapsizeX,d4
;	sub.w	#3,d4
	move.l	tempx,d4
	move.l	temp1,isostart
.loopx	
	bsr	makeit	;go do a square
	bsr	newseed
	move.w	$dff006,$dff180	
;	add.b	#1,isostart	;NO makeit already increments it!
	dbra	d4,.loopx

	move.l	temp1,a0
;	sub.l	#1,a0
	add.w	mapsizeX,a0
	move.l	a0,temp1
	
	dbra	d5,.loopy	
	
	sub.l	#1,repeat
	cmp.l	#0,repeat
	bne	.rep	
	
	
	
	move.l	temp,isostart	;restore isostart
	rts



makeit
	clr.l	d7	;t
	move.l	isostart,a0
	sub.w	mapsizeX,a0
	sub.l	#1,a0
	lea	checkpos,a1
.nextt
	clr.l	d0
	clr.l	d1
	move.b	(a1,d7),d1	;get mappos
	move.b	(a0,d1),d0	;get map data
	move.b	#0,match
	
	move.l	d7,d6	;for v = t to 3
	add.l	#1,d6
.nextv
	move.b	(a1,d6),d1
	cmp.b	(a0,d1),d0
	bne	.nomatch
	add.b	#1,match
.nomatch
	add.b	#1,d6
	cmp.b	#4,d6
	bne	.nextv
	
	cmp.b	#3,match
	bne	.notallsame
	;They are all the same		*****ALLSAME*****
	bsr	.allsame
	rts
.notallsame
	cmp.b	#2,match		*****3SET*****
	bne	.noset3
	bsr	.set3
	rts
.noset3
	cmp.b	#1,match
	bne	.nopair
	bsr	.pair2	;check to see if its 2pair
	rts
.nopair

	;its a lone char, aahhh
	add.l	#1,d7
	cmp.l	#4,d7
	bne	.nextt
	
	;if we get here then something fucked up.....
	
	rts
		
.allsame	
	;okay this one can have a height of z-1,z,z+1
	;so a choice of 3.
	;use the bottom 2 bits of the seed,
	;00 = lower
	;01 = stay same
	;11 = stay samee
	;11 = higher
	
	;d0 has the middle height!
	move.l	isostart,a0
	sub.w	mapsizeX,a0
	sub.l	#1,a0

	clr.l	d1
	move.l	seed,d1
	and.l	#$00000003,d1	;kill all but bottom 2 bits!
	cmp.l	#0,d1
	bne	.notlower
	sub.b	#1,d0
.notlower
	cmp.l	#3,d1
	bne	.nothigher
	add.b	#1,d0
.nothigher
	move.l	isostart,a0
	move.b	d0,(a0)+
	move.l	a0,isostart
	rts
	
	rts

.pair2	
	;d0 has the map data
	clr.l	d6
.lookin	move.b	(a1,d6),d1
	cmp.b	(a0,d1),d0
	bne	.gotim	;found one that isnt the pair!
	;no its one of the pair, keep looking.
	add.l	#1,d6
	cmp.l	#4,d6
	bne	.lookin
	;somethings fucked if we get here...
	rts
.gotim
	clr.l	d2
	move.b	(a0,d1),d2	;save it for the check later on

.stillook	
	add.l	#1,d6	;cant be the last one (hopefully)
	move.b	(a1,d6),d1
	cmp.b	(a0,d1),d0
	beq	.stillook
	
	;ok, weve found the other one that isnt the origonal pair.
	;is it  another pair?
	cmp.b	(a0,d1),d2
	bne	.nope
	;its another pair		*****2PAIR*****
	;this is the lowest value or lowest +1
	;same routine as for match =2 

	;bomb through and find lowest
	;then add 0 or 1

	move.l	isostart,a0
	sub.w	mapsizeX,a0
	sub.l	#1,a0
	
	move.b	(a1,d7),d1	;get mappos
	move.b	(a0,d1),d0	;get map data

	clr.l	d6	;for v = 0 to 3
	add.l	#1,d6
.nextv3
	move.b	(a1,d6),d1
	cmp.b	(a0,d1),d0
	blt	.notthis
	;this is the lowest
	;so make it d0!
	move.b	(a0,d1),d0
.notthis
	add.l	#1,d6
	cmp.l	#4,d6
	bne	.nextv3


	;get rand no.. (1bit)
	;and add it to d0

	clr.l	d1
	move.l	seed,d1
	swap	d1
	and.l	#$1,d1	;kill all but first bit
	add.l	d1,d0


	;ok, d0 has the lowest value..
	move.l	isostart,a0
	move.b	d0,(a0)+
	move.l	a0,isostart



	rts
.nope
	;its a single pair by himself	*****1PAIR*****
	;the ONLY result here is the middle value

	;bomb through and find lowest
	;then add one.

	move.l	isostart,a0
	sub.w	mapsizeX,a0
	sub.l	#1,a0
	
	move.b	(a1,d7),d1	;get mappos
	move.b	(a0,d1),d0	;get map data

	clr.l	d6	;for v = 0 to 3
	add.l	#1,d6
.nextv4
	move.b	(a1,d6),d1
	cmp.b	(a0,d1),d0
	blt	.notthis2
	;this is the lowest
	;so make it d0!
	move.b	(a0,d1),d0
.notthis2
	add.l	#1,d6
	cmp.l	#4,d6
	bne	.nextv4

	add.b	#1,d0
	;ok, d0 has the lowest value..
	move.l	isostart,a0
	move.b	d0,(a0)+
	move.l	a0,isostart




	rts
.set3
	;this routine is for 3 heights that are the same..
	;it can be a choice of 
	;the lowest (possibly d0)
	;or the lowest +1 (possibly d0)
	
	;so, bomb through table again
	;and find the misfit.
	;decide which one is lowest and make that the base no.
	
	;get the very bottom bit (or possible bit 16)
	;and add it to the base no to get height

	move.l	isostart,a0
	sub.w	mapsizeX,a0
	sub.l	#1,a0
	
	move.b	(a1,d7),d1	;get mappos
	move.b	(a0,d1),d0	;get map data

	clr.l	d6	;for v = 0 to 3
	add.l	#1,d6
.nextv2
	move.b	(a1,d6),d1
	cmp.b	(a0,d1),d0
	bne	.gotmisfit
	add.b	#1,d6
	cmp.b	#4,d6
	bne	.nextv2
	;if we get here, somethings wrong
.gotmisfit
FEED
	cmp.b	(a0,d1),d0
	blt	.d0low
	;d1 is lowest
	nop
	move.b	(a0,d1),d0	;make this the lowest
.d0low

	;ok, d0 now has the lowest value.
	;time to do a rand on the 1st bit of word2
	;0 add nothing.
	;1 add one
	
	clr.l	d1
	move.l	seed,d1
	swap	d1
	and.l	#$1,d1	;kill all but first bit
	add.l	d1,d0
	
	move.l	isostart,a0
	move.b	d0,(a0)+
	move.l	a0,isostart

	rts
newseed
	move.l	seed,d0	;get seed
	move.l	d0,d1	;copy for 23 bit 
	move.l	d0,d2	;copy for 01 bit
	swap	d1	;get to top 16 bits now 7th bit
	lsr	#7,d1	;shift 7 bits right
	and.l	#1,d1	;isolate bit 1 (23)
	and.l	#1,d2	;isolate bit 1 (01)
	eor.l	d1,d2	;exor together
	swap	d0	;top word
	lsl	#1,d0	; left shift
	swap	d0	;bottom word
	lsl	#1,d0	; left shift
	bcc	.skip	; x tra bit
	swap	d0
	add.l	#1,d0
	swap	d0
.skip	tst	d2
	beq	.skip2
	bset	#0,d0
	bra	.skip3
.skip2	bclr	#0,d0
.skip3
	
	move.l	d0,seed
	rts	
	
	
	
	
newseed_OLD
	eor.l	#$ffffffff,seed
;	move.l	seed,d2
;	and.l	#$00000003,d2
;	move.l	#3,d2
;	add.l	#1,d2
	
;	move.w	#3,d2
.loop
	move.l	seed,d1	;this is the result
	move.l	seed,d0
	and.l	#$00000001,d0
	bne	.zero1
	;its a one
	or.l	#$00010000,d1	;set this bit
	bra	.swap2
.zero1
	or.l	#$00010000,d1	;set this bit
	eor.l	#$01010000,d1	;set this bit
	
.swap2
	move.l	seed,d0
	and.l	#$00010000,d0
	bne	.zero2
	;its a one
	or.l	#$00000001,d1
	bra	.shift
.zero2
	or.l	#$00000001,d1
	eor.l	#$00000101,d1
	
.shift
	swap	d1
	rol.w	#1,d1
	swap	d1
	ror.w	#1,d1


	swap	d0
	rol.w	#1,d0
	swap	d0
	ror.w	#1,d0
;
;	swap	d1

;	clr.l	d0
;	move.w	d1,d0
;	swap	d0
;	move.w	d1,d0
;	add.l	d0,d1

	eor.l	d0,d1	
	add.l	#$00100000,d1	
	eor.l	#$ff00ff00,d1
	
	move.l	d1,seed
	
;	dbra	d2,.loop	
	rts
copyin
	;this will grab the data in seedmap and put it correctly
	;into mapdata
	;note. mapdata = char height (both byte)
	;also 1 is flat block
	
	;also this will check that the data is within the valid range
	;of 0-32 and adjust appropriately
		
	lea	seedmap,a0
	lea	mapdata,a1
	;move.l	#16*16-1,d7
	clr.l	d7
	move.w	mapsizeX,d7
	mulu	mapsizeY,d7
	sub.w	#1,d7

.loop

	clr.l	d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	bgt	.high
	move.b	#0,d0
.high
	cmp.b	#32,d0
	blt	.low
	move.b	#32,d0
.low

	;now figure out the gfk
	move.b	#1,d1	;char no.
	cmp.b	#5,d0
	ble	.copgfk
	
	move.b	#2,d1
	cmp.b	#9,d0
	ble	.copgfk
	
	move.b	#3,d1
	cmp.b	#13,d0
	ble	.copgfk
	
	move.b	#4,d1
	cmp.b	#18,d0
	ble	.copgfk

.copgfk
	move.b	d1,(a1)+	;copy block in
	
	
	
		
	move.b	d0,(a1)+	;copy height
	dbra	d7,.loop
	
	
	rts	
	

domap
	CALLGRAF	WaitBlit

	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#2-2,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-2,$dff062	;mod b
	move.w	#scrwid-2,$dff066	;mod D

	move.w	#0,$dff042	
	
	;map a pretty map of the area.
	;use seedmap for the time being

	lea	seedmap,a0
	move.l	mapbase,a1
	move.l	a1,temp
	
	
	clr.l	d6
	move.w	mapsizeY,d6
	sub.w	#1,d6
.loopy
	move.l	temp,a1

	clr.l	d7
	move.w	mapsizeX,d7
	sub.w	#1,d7

	move.l	#$0dfc,d2	;minterm
.loopx	
	clr.l	d0
	move.b	(a0)+,d0	;got height
	mulu	#16*5*2,d0

	lea	mapbits,a2
	add.l	d0,a2
	
	move.w	d2,$dff040	
	
	
	move.l	a2,$dff050	;get mask A
	move.l	a1,$dff04c	;src B	bob
	move.l	a1,$dff054	;dst D	screen
	move.w	#(1*5*64)+1,$dff058
	
	add.w	#$1000,d2
	bcc	.ok
	move.l	#$0dfc,d2
	add.l	#2,a1
	;clr a word
	move.w	#0,(a1)
	move.w	#0,40(a1)
	move.w	#0,80(a1)
	move.w	#0,120(a1)
	move.w	#0,160(a1)
.ok

	dbra	d7,.loopx
	
	add.l	#1*scrwid*5,temp
	dbra	d6,.loopy
	
	rts	
	
loadiffmap
	bsr	LoadmapCmap

	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	lea	iffmap,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#256,d2		;height
	CALLGRAF	InitBitMap

	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	mapbase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#40,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back
	

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	
	
	rts

	rts
convertmap	
	;ok, the bitmap is in mapbase
	;its format is 320 * 256 * 5
	;the actual map however is 256*256*4
	
	;convert a byte at a time
	
	move.l	mapbase,a0	;source
	lea	seedmap,a1	;dest

	move.l	a0,savescr
	move.l	a1,savemap

	move.l	#256-1,d7	;y no of lines	
.loopy
	move.l	savescr,a0
	move.l	savemap,a1
	
	move.l	#32-1,d6	;x no of BYTES
.loopx
	move.l	#$80,d5	;starting bit pattern
	move.l	#1,d4	;multiply factor
	clr.l	d3	;result


	move.l	#8-1,d2
.loopbyte
	bsr	.dobit
	move.b	d3,(a1)+
	ror.l	#1,d5
	move.l	#1,d4	;multiply factor
	clr.l	d3	;result
	dbra	d2,.loopbyte
	
	add.l	#1,a0
	dbra	d6,.loopx

	add.l	#40*5,savescr	;next line please
	add.l	#250,savemap

	move.w	$dff006,$dff180
	dbra	d7,.loopy	
	rts




	
.dobit
	clr.l	d0
	move.b	(a0),d0	;bp1
	bsr	.getbit
	move.b	40(a0),d0	;bp2
	bsr	.getbit
	move.b	80(a0),d0	;bp3
	bsr	.getbit
	move.b	120(a0),d0	;bp4
	bsr	.getbit
	move.b	160(a0),d0	;bp5
	bsr	.getbit
	


	rts
.getbit
	and.l	d5,d0	;clear all but required bit
	cmp.b	#0,d0
	beq	.empty
	;the bit is set
	add.l	d4,d3	;increase the value
.empty
	;increase the factor
	rol.l	#1,d4
	
	
	
	rts
	even
	cnop	0,4	
new:
	dc.w	bpl1mod
	dc.w	(40*5)-40
	dc.w	bpl2mod
	dc.w	(40*5)-40
	dc.w	dmacon,$0020
scnposs	dc.w	diwstrt,$2c81
scnpose	dc.w	diwstop,$2cc1 
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,$5200
	dc.w	bplcon1,$0
	dc.w	bplcon2,0
	dc.w	bplcon3,$0c00	;bplcon3
	dc.w	bpl1h
bit1h	dc.w	0
	dc.w	bpl1l
bit1l	dc.w	0
	dc.w	bpl2h
bit2h	dc.w	0
	dc.w	bpl2l
bit2l	dc.w	0
	dc.w	bpl3h
bit3h	dc.w	0
	dc.w	bpl3l
bit3l	dc.w	0
	dc.w	bpl4h
bit4h	dc.w	0
	dc.w	bpl4l
bit4l	dc.w	0
	dc.w	bpl5h
bit5h	dc.w	0
	dc.w	bpl5l
bit5l	dc.w	0

colour	include	slyma/colclist
	
	dc.w	$ffff,$fffe		;end of coper list

	dc.l	0
old	dc.l	0
gfxname	dc.b	"graphics.library",0
intname	dc.b	"intuition.library",0
iffname	dc.b	"iff.library",0
dosname	dc.b	"dos.library",0
wbname          dc.b  "Workbench",0
isoname	dc.b	"grafix/iso2.iff",0
	even
	dc.l	0

_GfxBase	dc.l	0
_IntuitionBase	dc.l	0
_IFFBase	dc.l	0
_DOSBase	dc.l	0
scrbase	dc.l	0	;pointer to screen area!
screen1	dc.l	0	;pointer to screen1 dbuff
screen2	dc.l	0	;pointer to screen2 dbuff


IsoBase	dc.l	0	;pointer to iso bitmap gfx
mapbase	dc.l	0	;pointer to map screen
mapsize	dc.l	40*5*256	;size for iffmap bitmap

taglist         dc.l  VTAG_SPRITERESN_GET
resolution      dc.l  SPRITERESN_ECS
                dc.l  TAG_DONE,0

wbview          dc.l  0
oldres          dc.l  0
wbscreen        dc.l  0
oldpri	dc.l	0

iffhandle	dc.l	0
bitmap	dc.l	0,0,0,0,0,0,0,0,0

temp	dc.l	0
temp1	dc.l	0
savescr	dc.l	0	;these are used in drawvisible
savemap	dc.l	0


repeat	dc.l	0

tempx	dc.l	0
tempy	dc.l	0

seedORIG
;	dc.l	$12345678
;	dc.l	-1
;	dc.l	$11111111
	dc.l	$dead5151
	dc.l	$dead0001
	dc.l	$22271174
	dc.l	0
	dc.l	$aaaaaaaa
	dc.l	$deaddead	;good one

seed	dc.l	$deaddead
isostart	dc.l	seedmap+(size+1)	;where to start in map!


	even
	dc.l	0

mapxpos	dc.w	0
mapypos	dc.w	0

mapsizeX	dc.w	size
mapsizeY	dc.w	size

match	dc.b	0	;how many matches in seed map gen

ADJVAL	dc.b	0	;adjustment value! for level creation

;checkpos is used in the seedmap generation
checkpos	dc.b	0,1,2,size	;last digit is mapsizeX

;		  v = height
;		v = char
mapdata
	dcb.b	size*size*2,0
	dc.b	0,0


seedmap
	dcb.b	(size+1)*(size+1),0
	dcb.b	(size+1)*(size+1),0
	dc.b	0,0
mapbits	incbin	grafix/mapcol2.gfx
mapcol	dcb.w	32,0
colours	dcb.w	32,0
iffmap	dc.b	"grafix/land.01",0

