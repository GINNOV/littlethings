debugging	equ	0

;Miner Madness4.
;All levels are 320*256 but you do not have to use it all!
;You draw them in Dpaint
;and my little proggy converts it to level data cool huh.
;there is a file called levelkey.iff which says what colour does what!

;at the moment, background collision can be done on bp5











;summink else is a bit fucked. FIXED 16-09-97 (bge to noswap instead of out)
;sometimes when you go up or down.
;it just sticks at a random point (always at the start if a char)
;to correct it go down or up (reverse)
;nothing seems to be corrputed but it does need fixing
;its probably just a bgt should be a bge or something

;got rid of the glithy bits the would appear at the top and bottom,
;my origonal version had a few bug in it which meant that it was
;only doing one of the 2 things it shoulld have been doing


;question.
;why does the routine run every time when you go down
;but only on rare ocasions going up? FIXED 27-8-97


;Theres a -=>FRIG<=- its in the go_bitplanes
;when going left (with pointers set to far left)
;youd get residue blitted on the screen (dunno why!)
;so i adjusted the left to be 1word in and frigged gobitplanes...

;edited copperlist to work of A1200
	section screen,code_c		;make sure chip ram
	
	opt	c+

gap	equ	640
top	equ	2
viswid	equ	40
vishi	equ	12
pagewid	equ	2+viswid+2
pagehi	equ	top+vishi+top
screensize	equ	gap+(pagewid*(pagehi*16)*5)+gap
borderline	equ	top*16
levelwid	equ	320
levelhi	equ	256
downstrip	equ	3	(divisible by 18) (INCREASE THIS FOR FASTER Y SPEEDS)
			;downstrip = make the horiz strips in n vblanks
		

	bra	Start
	
showCOLL	dc.b	0	;show only the collision copperlist
	dc.b	"$VER:Madness4.4"
	cnop	0,4
Start
	
	lea	gfxname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_GfxBase

	lea	dosname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_DOSBase

	lea	intname,a1          ;
	moveq	#39,d0                  ; Kickstart 3.0 or higher
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase       ; store intuitionbase

	lea	iffname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_IFFBase

	
	ifeq debugging
	bsr	GetSystem		
	
	bsr	vblank
	bsr	vblank
	move.l	#new,$dff080
	endc

	move.w	#$8400,$dff096

	bsr	allocscrbase
	move.l	scrbase,scrother
	bsr	allocscrbase

	;allocate some memory for the level
	move.l	#levelwid*levelhi*4,d0
	move.l	#$10000,d1	;memory Ill have anything please
	CALLEXEC	AllocMem
	move.l	d0,level

		

	bsr	go_colour	

	bsr	get_old_cop	
	bsr	go_bitplanes

	bsr	load_level	
	bsr	convert_level

	;init screen bits!	
	move.l	scrbase,screen1
	add.l	#gap,screen1
	move.l	scrother,screen2
	add.l	#gap,screen2
	move.l	screen1,view1
	move.l	screen2,view2
	
	;init level bits!
	move.l	level,level1
	move.l	level,level2

	
	

main
	ifeq debugging
	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
;	bsr	vblank2
	endc
	
;	move.w	#$000,$dff180

	move.w	#0,joydir
	bsr	joystick

	bsr	drawing


	clr.l	d0	;left
	move.w	joydir,d0
	and.w	#%0010,d0
	cmp.w	#0,d0
	beq	.noleft
	bsr	left
.noleft


	clr.l	d0	;right
	move.w	joydir,d0
	and.w	#%0001,d0
	cmp.w	#0,d0
	beq	.noright
	bsr	right
.noright
	

	clr.l	d0	;down
	move.w	joydir,d0
	and.w	#%0100,d0
	cmp.w	#0,d0
	beq	.notdown
	bsr	down
.notdown
	clr.l	d0	;UP
	move.w	joydir,d0
	and.w	#%1000,d0
	cmp.w	#0,d0
	beq	.notup
	bsr	up
.notup

	cmp.b	#$4d,$bfec01	;F10 flip view
	bne	.notflip
	move.l	view1,a0
	move.l	view2,view1
	move.l	a0,view2
	bsr	go_bitplanes
	move.l	view1,a0
	move.l	view2,view1
	move.l	a0,view2
	move.w	#$0f00,$dff180

.notflip
	bsr	go_bitplanes

	move.w	#$0,$dff180


	
	cmp.b	#$3f,$bfec01
	bne	main
	
exit	move	#%1000000000100000,$dff096;enable sprites
	
	ifeq debugging	
	move.l	old,$dff080	

	bsr	RestSystem

	endc
		
	bsr	freescrbase
	move.l	scrother,scrbase
	bsr	freescrbase

;freelevelbase
	move.l	#levelwid*levelhi*4,d0
	move.l	level,a1
	CALLEXEC	FreeMem
	

NO_MEMORY
	bsr	CloseLibs	;close libs

	rts

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

go_bitplanes
	move.w	#5-1,d7
	move.l	view1,d0
	add.l	#2,d0
	add.l	#top*16*pagewid*5,d0
	lea	bit1h,a0
cloop
	move.w	d0,4(a0)	;bit1l
	swap	d0
	move.w	d0,(a0)	;bit1h
	swap	d0
	add.l	#pagewid,d0	;next bitplane
	add.l	#8,a0	;next copper pos.
	dbra	d7,cloop
	rts

convert_level	
	;this will convert the level from a ilbm to leveldata
	;and then it will free up the memory for the picture

	;the piccy is in leveliff	
	move.l	leveliff,a0		;start of piccy
	move.l	level,a1		;actual level
	
;.loopy	256 - 0
;.loopx	320/16 - 0
;.loop16	15-0
;	grab bit, create map
;	rotate
;	bra	.loop16
;	bra	.loopx
;	bra	.loopy

	lea	chardat,a3	;what set of 4 gfx to choose from

	move.l	a0,a2
	move.l	#(levelhi)-1,d7
.loopy	
	move.l	a2,a0


	move.l	#(levelwid/16)-1,d6
.loopx


	move.l	#$8000,d4	;bit pattern to get
	move.l	#16-1,d5
.loop16
	bsr	BitToColour
	move.l	#0,(a1)
	move.b	(a3,d0),3(a1)
;	move.w	d0,2(a1)

	move.w	2(a1),d0	;get data
;	mulu	#16*5*2,d0	;get char
	move.w	d0,2(a1)

	add.l	#4,a1	;then skip the start of the next word	

	ror.l	#1,d4
	dbra	d5,.loop16
	
 	add.l	#2,a0	;next word of pic
	dbra	d6,.loopx

	add.l	#(levelwid/8)*5,a2
	dbra	d7,.loopy
	



	;free up the iff memory now weve finished playing with it
	move.l	#((levelwid/8)*5)*levelhi,d0
	move.l	leveliff,a1
	CALLEXEC	FreeMem

	bsr	cheat	;this just makes it easier for me to see
	

	rts

BitToColour
	clr.l	d0
	clr.l	d2
	move.l	#5-1,d3	;no. bitplanes
.loop	
	ror.l	#1,d0	;shift buffer
	clr.l	d1
	move.w	(a0,d2),d1	;get a word ILBM
	and.l	d4,d1	;kill all but bit we want
	
	;do a test to see if its set!
	;if it is or bit 0
	beq	.empty
	
	
	or.l	#$10,d0	;or it into buffer

.empty	add.l	#levelwid/8,d2	;do next bitplane
	dbra	d3,.loop
	
	
	rts	
	
	
	
cheat	move.l	level,a0
	move.l	#((levelwid)*levelhi)-1,d7
.loop
	clr.l	d0
	
	
	move.w	2(a0),d0	;get data
	bsr	isedger
	
	bsr	dornd	;most blocks can be 1 of 4
	
	mulu	#16*5*2,d0	;get char
	move.w	d0,2(a0)
	add.l	#4,a0
	sub.l	#1,d7
	bne	.loop
;	dbra	d7,.loop
	rts

dornd	;this uses a hack to get the random number (from horiz vbeam)
	;all dirt blocks can be 1 of 4 with exception of the dirt block 1
	cmp.b	#1,d0
	ble	.out	;dont rand dirt 1
	cmp.b	#58,d0
	bge	.out	;all under 58 are in sets of 4
	
	bsr	gornd
	add.b	d1,d0
.out	rts

gornd
	
	clr.l	d1
	move.w	$dff006,d1
	and.l	#%00000011,d1
;	move.l	#1,d1
	rts



isedger
	;look NESW from a0 to decide which gfk to use
	;a0 has the current char no.
	;if its 0 then try the next one.
	cmp.b	#1,d0
	bne	.out	;we only want dirt
	
	;okay we have found some dirt.
	clr.l	d1	;other dirt positions
	cmp.l	#0,-levelwid*4(a0)
	beq	.noup
	;there is dirt above me!
	or.b	#UP,d1
.noup
	cmp.l	#0,levelwid*4(a0)
	beq	.nodown
	;there is dirt below me!
	or.b	#DOWN,d1
.nodown
	cmp.l	#0,-4(a0)
	beq	.noleft
	;there is dirt to the left of me
	or.b	#LEFT,d1
.noleft
	cmp.l	#0,4(a0)
	beq	.noright
	;there is dirt to the right of me
	or.b	#RIGHT,d1
.noright
	move.b	d1,dirtpos

	;now do the routine to get the diagonals!

	clr.l	d1
	cmp.l	#0,-(levelwid-1)*4(a0)
	beq	.noul
	;there is dirt upleft me!
	or.b	#UPLEFT,d1
.noul
	cmp.l	#0,-(levelwid+1)*4(a0)
	beq	.nour
	;there is dirt upright me!
	or.b	#UPRIGHT,d1
.nour
	cmp.l	#0,(levelwid-1)*4(a0)
	beq	.nodl
	;there is dirt to down left of me
	or.b	#DOWNLEFT,d1
.nodl
	cmp.l	#0,(levelwid+1)*4(a0)
	beq	.nodr
	;there is dirt to the right of me
	or.b	#DOWNRIGHT,d1
.nodr
	move.b	d1,dirtdiag




	clr.l	d1
	move.b	dirtpos,d1
	
	;if dirtpos = $f then we have to look at the diagonals
	cmp.b	#$f,d1
	bne	.notf
	
	;if dirtdiag = $f then its a solid rock block (default)
	cmp.b	#$f,dirtdiag
	beq	.notf
	;ok, now we have to decide which block to give it!
	move.b	dirtdiag,d1

	clr.l	d0
	lea	rockdiag,a3
	move.b	(a3,d1),d0
	bra	.out

.notf
		
	clr.l	d0
	lea	rockdat,a3
	move.b	(a3,d1),d0
		
.out	rts


	
drawing
	;if status=draw then draw summink!!!!!!!!!!!!
	cmp.b	#DRAW,status
	bne	.out

	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#pagewid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$09f0,$dff040

	
	cmp.b	#pagehi/downstrip,drawcnt
;	cmp.b	#9,drawcnt
	bne	.notdone
	move.b	#DONE,status
	bra	.out
.notdone

	move.l	#downstrip-1,d6
	move.l	drawscr,a3
	move.l	drawlev,a4
	
;	add.l	#4,a3
.loopy
	move.l	a3,a0
	move.l	a4,a1
	
	move.l	#(pagewid/2)-1,d7
;	move.l	#10-1,d7
.loopx

	lea	chars,a2
	clr.l	d0
	move.w	2(a1),d0	;get data
	add.l	d0,a2
	
;	lea	chars+(16*5*2),a2
	;blit a2 onto a0
	

	move.l	a2,$dff050	;A
	move.l	a0,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058
	
	add.l	#2,a0	;next screen pos
	add.l	#4,a1	;next level pos
	
	dbra	d7,.loopx
	
	add.l	#4*levelwid,a4
	add.l	#5*(pagewid*16),a3
	dbra	d6,.loopy
	
	add.l	#downstrip*(5*pagewid*16),drawscr
	add.l	#downstrip*(4*levelwid),drawlev
	
	add.b	#1,drawcnt


	
	
.out	rts
down	
	;check to see if new level complete.!!
	;and then wait for swap
	cmp.b	#borderline+borderline,flipcounter
	blt	.noswap
	
	cmp.b	#DONE,status
	beq	.noswap	;go out until were ready!
	move.b	#INIT,status
	sub.b	#borderline,flipcounter
	
	;swap views
	move.l	view1,a0
	move.l	view2,view1
	move.l	a0,view2
	sub.l	#(borderline)*(5*pagewid),view1
	sub.l	#(borderline)*(5*pagewid),view2
	
	;swap screens
	move.l	screen1,a0
	move.l	screen2,screen1
	move.l	a0,screen2
	
	;swap levels
	move.l	level1,a0
	move.l	level2,level1
	move.l	a0,level2

	clr.l	d0
	clr.l	d1
	move.b	speedy,d0
	move.b	speedy,d1
	mulu	#pagewid*5,d0
	

	add.l	d0,view1
	add.l	d0,view2
	add.b	d1,flipcounter

	bra	.out
.noswap	
	clr.l	d0
	clr.l	d1
	move.b	speedy,d0
	move.b	speedy,d1
	mulu	#pagewid*5,d0
	

	add.l	d0,view1
	add.l	d0,view2
	add.b	d1,flipcounter
	cmp.b	#borderline,flipcounter
	blt	.ok
	
.sttsr	;if status=draw or done then do nothing
	cmp.b	#DRAW,status
	beq	.noinit
	
	;setup to draw the new screen!!!!
	move.l	screen2,drawscr

	move.l	level1,level2	
	add.l	#top*(levelwid*4),level2	;go down 3 lines
	move.l	level2,drawlev
	
	move.b	#DRAW,status
	move.b	#0,drawcnt
	bra	.ok
.noinit
	
.ok	
.out
;	bsr	go_bitplanes
	rts
up	
	;check to see if new level complete.!!
	;and then wait for swap
	cmp.b	#0,flipcounter
	bgt	.noswap
	
	cmp.b	#DONE,status
	beq	.noswap	;go out until were ready!
	move.b	#INIT,status
	add.b	#borderline,flipcounter
	
	;swap views
	move.l	view1,a0
	move.l	view2,view1
	move.l	a0,view2
	add.l	#(borderline)*(5*pagewid),view1
	add.l	#(borderline)*(5*pagewid),view2
	
	;swap screens
	move.l	screen1,a0
	move.l	screen2,screen1
	move.l	a0,screen2
	
	;swap levels
	move.l	level1,a0
	move.l	level2,level1
	move.l	a0,level2

	clr.l	d0
	clr.l	d1
	move.b	speedy,d0
	move.b	speedy,d1
	mulu	#pagewid*5,d0
	

	sub.l	d0,view1
	sub.l	d0,view2
	sub.b	d1,flipcounter

	bra	.out
.noswap	
	clr.l	d0
	clr.l	d1
	move.b	speedy,d0
	move.b	speedy,d1
	mulu	#pagewid*5,d0
	

	sub.l	d0,view1
	sub.l	d0,view2
	sub.b	d1,flipcounter
	cmp.b	#borderline,flipcounter
	bgt	.ok
	
.outss	;if status=draw or done then do nothing
	cmp.b	#DRAW,status
	beq	.noinit
	
	;setup to draw the new screen!!!!
	move.l	screen2,drawscr

	move.l	level1,level2	
	sub.l	#top*(levelwid*4),level2	;go up 3 lines
	move.l	level2,drawlev
	
	move.b	#DRAW,status
	move.b	#0,drawcnt
	bra	.ok
.noinit
	
.ok	
.out
;	bsr	go_bitplanes
	rts

right
	clr.l	d0
	clr.l	d1
	move.b	speedx,d0
	move.b	speedx,d1
	rol.l	#4,d0
	or.b	speedx,d0
	
	
	clr.l	d2
	move.w	smooth,d2
	sub.w	d0,d2
	move.w	d2,smooth
;	sub.w	smooth,d0

	clr.l	d2
	move.b	scrollx,d2
	sub.b	d1,d2
	move.b	d2,scrollx
;	sub.b	#3,scrollx,d1
	cmp.b	#0,scrollx
	bge	.out
	
	add.b	#16,scrollx
	add.w	#$ff+$11,smooth

	;draw on screen1+viswid
	;draw on screen2+viswid
	
	add.l	#2,screen1
	add.l	#2,screen2
	add.l	#2,view1
	add.l	#2,view2
	add.l	#4,level1
	add.l	#4,level2
	
	;first draw  on the visible screen!
	move.l	level1,a1
	add.l	#2*viswid,a1
	
	move.l	screen1,a0
	add.l	#viswid,a0

	bsr	blitstrip

	;now draw  on the second screen!
	move.l	level2,a1
	add.l	#2*viswid,a1
	
	move.l	screen2,a0
	add.l	#viswid,a0

	bsr	blitstrip
.out	rts

left
	clr.l	d0
	clr.l	d1
	move.b	speedx,d0
	move.b	speedx,d1
	rol.l	#4,d0
	or.b	speedx,d0
	
	
	clr.l	d2
	move.w	smooth,d2
	add.w	d0,d2
	move.w	d2,smooth
;	add.w	smooth,d0

	clr.l	d2
	move.b	scrollx,d2
	add.b	d1,d2
	move.b	d2,scrollx
;	add.b	#3,scrollx,d1

	cmp.b	#15,scrollx
	ble	.out
	
	sub.b	#16,scrollx
	sub.w	#$ff+$11,smooth

	;draw on screen1
	;draw on screen2
	
	sub.l	#2,screen1
	sub.l	#2,screen2
	sub.l	#2,view1
	sub.l	#2,view2
	sub.l	#4,level1
	sub.l	#4,level2
	
	;first draw  on the visible screen!
	move.l	level1,a1
	add.l	#4,a1
	
	move.l	screen1,a0
	add.l	#2,a0

	bsr	blitstrip

	;now draw  on the second screen!
	move.l	level2,a1
	add.l	#4,a1
	
	move.l	screen2,a0
	add.l	#2,a0

	bsr	blitstrip
.out	rts
	
	
	
blitstrip
	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#pagewid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$09f0,$dff040
	
	move.l	#pagehi-1,d6
.loopy

	lea	chars,a2
	clr.l	d0
	move.w	2(a1),d0	;get data
	add.l	d0,a2
	
;	lea	chars+(16*5*2),a2
	;blit a2 onto a0
	

	move.l	a2,$dff050	;A
	move.l	a0,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058
	
	add.l	#4*levelwid,a1
	add.l	#5*(pagewid*16),a0
	dbra	d6,.loopy
	

	rts
	
joystick
	clr.l	d1
	move.w	$dff00c,d0	;$dff00a port one
	btst	#9,d0
	beq	.not_left
	bset	#1,d1		;left
.not_left
	btst	#1,d0
	beq	.not_right		
	bset	#0,d1		;right
.not_right
	move.w	d0,d2
	lsr.w	#1,d2
	eor.w	d0,d2
	btst	#0,d2
	beq	.not_down
	bset	#2,d1		;down
.not_down	btst	#8,d2
	beq	.not_up
	bset	#3,d1		;up
.not_up	
	move.l	d1,d0		;save in d0
	
	move.w	d0,joydir

	rts

load_level
	;load in the level as ILBM
	;NOTE the convert level routine will free up the ilbm pic


	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	lea	levname,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#levelwid*5,d1		;width
	move.l	#levelhi,d2		;height
	CALLGRAF	InitBitMap

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	#((levelwid/8)*5)*levelhi,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,leveliff
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	leveliff,a0
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



	

	even
	cnop	0,4	
new:
	dc.w	bpl1mod
	dc.w	(pagewid*5)-viswid
	dc.w	bpl2mod
	dc.w	(pagewid*5)-viswid
	dc.w	dmacon,$0020
scnposs	dc.w	diwstrt,$2c91
scnpose	dc.w	diwstop,$2cb1 
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,$5200
	dc.w	bplcon1
smooth	dc.w	0
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
	dc.l	$5009fffe
	dc.w	bplcon0,$5200

	dc.l	$db09fffe
	dc.l	$018000f0
	dc.w	bplcon0,$0200
	dc.l	$dc09fffe
;	dc.l	$01800000
	dc.w	$009c,$8010

	
	dc.w	$ffff,$fffe		;end of coper list

	dc.l	0
old	dc.l	0
gfxname	dc.b	"graphics.library",0
intname	dc.b	"intuition.library",0
dosname	dc.b	"dos.library",0
iffname	dc.b	"iff.library",0

wbname          dc.b  "Workbench",0
	even
	dc.l	0

_IFFBase	dc.l	0
_DOSBase	dc.l	0
_GfxBase	dc.l	0
_IntuitionBase	dc.l	0
scrbase	dc.l	0	;pointer to screen area!
scrother	dc.l	0	;pointer to 2nd screen!

screen1	dc.l	0	;location of screen1
screen2	dc.l	0	;location of screen2
level1	dc.l	0	;level pos on screen1
level2	dc.l	0	;level pos on screen2
view1	dc.l	0	;what you see! screen1
view2	dc.l	0	;what you see! screen2

leveliff	dc.l	0	;this is a pointer to the iff level

drawlev	dc.l	0	;draw level pointer
drawscr	dc.l	0	;darw screnn pointer

taglist         dc.l  VTAG_SPRITERESN_GET
resolution      dc.l  SPRITERESN_ECS
                dc.l  TAG_DONE,0

wbview          dc.l  0
oldres          dc.l  0
wbscreen        dc.l  0
oldpri	dc.l	0

iffhandle	dc.l	0	;iff handle
bitmap
	dcb.l	40

	even
	cnop	0,4
chardat	;this is to decide what gfk to use +(rnd 0-3)
	;colour 1 = 1(solid rock) not edge
	;colour 2 = 50(grass)
	dc.b	0,1,50


	;this is for the isedger prg whih will decide which rock to use
	;dir (rockdat,dirtpos)=charno.
rockdat	dc.b	54,02,02,02,14,34,46,02,14
	dc.b	38,42,10,14,06,14,01
rockdiag	dc.b	01,01,01,01,01,01,01,30,01
	dc.b	01,01,18,01,22,26,01,01,01	
	even
	cnop	0,4


joydir	dc.w	0	;direction from mr joystick

status	dc.b	0	;what am i doing
flipcounter	dc.b	borderline
drawcnt	dc.b	0	
scrollx	dc.b	0

speedx	dc.b	4
speedy	dc.b	4

dirtpos	dc.b	0	;direction of dirt in isedger (level creation)
dirtdiag	dc.b	0	;as above but diagonally

INIT	equ	0	;setting up to draw
DRAW	equ	1	;drawing
DONE	equ	2	;finished drawing ready to swap

levname	dc.b	"grafix/level.iff",0

UP	equ	8
DOWN	equ	4
LEFT	equ	2
RIGHT	equ	1

UPLEFT	equ	8
UPRIGHT	equ	4
DOWNLEFT	equ	2
DOWNRIGHT	equ	1

	even
	cnop	0,4
level	dc.l	0
;dcb.b	((levelwid)*(levelhi+2))*4	;*4 for long
chars	incbin	grafix/REWGRND.gfx
colours	incbin	grafix/REWGRND.GFX.Cmap
	dcb.w	32,0

