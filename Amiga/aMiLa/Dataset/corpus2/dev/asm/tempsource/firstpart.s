;нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн-------------
;  Source code for the first part of the Triumph demo: No Temptations.
;  The demo was released early winter 1990, and it won a demo competition
;  on a small party.
;
;  This is now public domain. Use whatever you want, and don't give any
;  credits at all!!
; 
;  Most of the code was written in summer 1989, in Seka assembler.
;
;  Revision history 18-Jun-98:
;  - Made it startable from aga modes
;  - Multiple sections added, original version had all located in chip memory
;  - Removed the music
;  - Cleaned up the source a bit
;  - Made it compatible to Asm-Pro, if you don't have this assembler, get it!
;    It's fantastic!!!!
;  - Added some more comments to the source
;
;  The source can be assembled by Asm-Pro and PhxAss with no changes.
;  If you want to assemble it with genam change all the _p section to _f
;  Should be compatible with other assemblers as well, with very little modifications
;нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн-------------
_LVOOpenLibrary		equ	-552
_LVOCloseLibrary	equ	-414
_LVOLoadView		equ	-222
_LVOWaitTOF		equ	-270
_LVOPermit		equ	-138
_LVOForbid		equ	-132
gb_ActiView		equ	$22
gb_copinit		equ	$26
	section	code,code_p

	move.l	4.w,a6
	lea	GfxName,a1
	moveq	#33,d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq	End

	move.l	d0,gfxbase
	move.l	d0,a6
active:
	move.l	gb_ActiView(a6),wbview

	sub.l	a1,a1
	jsr 	_LVOLoadView(a6)
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)

	move.l	4,a6
	jsr	_LVOForbid(a6)
	bset	#1,$bfe001		; turn off led

	move.w	#$01a0,$dff096
	move.w	#$4000,$dff09a		; turn of interupts
	move.w	#$8020,$dff096		; turn on sprite DMA

	lea	spritepointers,a1	; initialize sprite pointers
	lea	sprite1,a0
	moveq	#7,d1
spriteloop:
	move.l	a0,d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	add.l	#60,a0
	add.l	#8,a1
	dbra	d1,spriteloop

	lea	screen,a1		; initalize the bitplane pointers
	move.l	a1,d1
	lea	bplcop+2,a2
	moveq	#3,d0
.bplloop:
	swap	d1
	move.w	d1,(a2)
	addq.l	#4,a2
	swap	d1
	move.w	d1,(a2)
	addq.l	#4,a2

	add.l	#11776,d1		; size of bitplane
	dbra	d0,.bplloop

	lea	copper,a1
	move.l	a1,$dff080		; load copper list
	move.w	#$8180,$dff096		; turn on DMA
main:
	move.l	$dff004,d0
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#300,d0
	bne	main

	bsr	clear
	bsr	newsprite
	bsr	effectcheckfashion
	bsr	effectcheckwhipe
	bsr	effectcheckout
	bsr	effectcheckraise
	bsr	effectchecklower
	bsr	blitscroll
	bsr	movesprite

	btst	#2,$dff016		; right mouse pressed?
	beq	main

	bsr	scroll
	bsr	frontside
	bsr	backside
	btst	#6,$bfe001		; left mouse button pressed?
	bne	main

	move.w	#$c000,$dff09a		; turn in interrupts

	move.l	wbview,a1
	move.l	gfxbase,a6
	jsr	_LVOLoadView(a6)
        jsr	_LVOWaitTOF(a6)
        jsr	_LVOWaitTOF(a6)
cop:
	move.l	gb_copinit(a6),$dff080

	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

	move.l	4.w,a6
	jsr	_LVOPermit(a6)
End:
	moveq   #0,d0
	rts
gfxbase:
	dc.l	0
;------------------
;!! The scroller !!
;------------------
scroll:
	tst.w	waitcounter
	beq	ps1
	sub.w	#1,waitcounter
	rts
ps1:					; move the scrolltext to the left
	move.l	#scrollbuffer+1194,a1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit

	move.w	#%0111100111110000,$dff040
	move.w	#2,$dff042
	move.w	#0,$dff044
	move.w	#-1,$dff046
	move.l	#0,$dff064
	move.l	a1,$dff050
	move.l	a1,$dff054
	move.w	#1687,$dff058

newchar:
	sub.w	#1,count
;	tst.w	count			; sub command sets the Zero flag
	beq	pchar
	rts
pchar:
	move.w	#5,count
	moveq	#0,d0
	move.l	TEXTP,a1
	move.b	(a1)+,d0
	move.l	a1,TEXTP
	tst.w	d0
	beq	restart
	cmp.w	#33,d0
	beq	calcsign
	cmp.w	#65,d0			;A stops the scroll for a moment
	beq	wait
	cmp.w	#66,d0			;B for Triumphlogo
	beq	fashion
	cmp.w	#67,d0			;C for Questlogo
	beq	whipe
	cmp.w	#68,d0			;D for whipeout
	beq	whipeouttest
	cmp.w	#69,d0			;E for Warplogo	
	beq	raise
	cmp.w	#70,d0			;F starts the messyroll
	beq	messystart
	cmp.w	#71,d0			;G for Smeagollogo
	beq	lower
	cmp.w	#72,d0			;H starts the sprites
	beq	spritestart
	cmp.w	#58,d0
	beq	kolon

	cmp.w	#105,d0
	beq	calci
	cmp.w	#117,d0			;u-z
	bge	calcuz
	cmp.w	#107,d0			;k-t
	bge	calckt	
	cmp.w	#97,d0			;a-j
	bge	calcaj
	cmp.w	#63,d0
	bge	idiotsigns3
	cmp.w	#48,d0
	bge	calcnumbers
	cmp.w	#43,d0
	bge	idiotsigns2
	cmp.w	#39,d0
	bge	idiotsigns1
;------------------------------------------------------------------------
;	If no char is supposed to be printed then execute 
;	one of the following routines.
;------------------------------------------------------------------------
nochar:
	move.l	#introfont+2104,d0
	rts
wait:
	move.w	#100,waitcounter
	rts
fashion:				; start the triumphlogo
	move.l	#0,logolinesfashion
	move.l	#0,screenaddfashion
	move.w	#4372,blitsizefashion

	lea	triumphlogoc,a1
	lea	farge+2,a2
	moveq	#15,d0
.colourloop:
	move.w	(a1)+,(a2)+
	addq	#2,a2
	dbra	d0,.colourloop
	rts
whipe:					; start the quest logo
	move.l	#1742,logolineswhipe
	move.l	#3128,screenaddwhipe
	lea	questlogoc,a1
	lea	farge+2,a2
	moveq	#15,d0
.colourloop:
	move.w	(a1)+,(a2)+
	addq	#2,a2
	dbra	d0,.colourloop
	bra	pchar
whipeouttest:				; begin clear the logo area
	move.l	#0,screenaddout
	rts
raise:					; start the warp logo
	move.l	#2668,screenaddraise
	move.w	#77,blitsizeraise
	lea	warplogoc,a1

	lea	farge+2,a2
	moveq	#15,d0
.colourloop:
	move.w	(a1)+,(a2)+
	addq	#2,a2
	dbra	d0,.colourloop
	rts
lower:					; start the smeagol logo
	move.w	#78,blitsizelower
	move.l	#1372,logolineslower
	lea	smeagollogoc,a1
	lea	farge+2,a2
	moveq	#15,d0
.colourloop:
	move.w	(a1)+,(a2)+
	addq	#2,a2
	dbra	d0,.colourloop
	rts
messystart:				; start the tube scroll
	move.l	#0,messylines1
	move.l	#0,messylines2
	rts
spritestart:				; start the TRIUMPH sprites
	move.b	#1,spritech
	rts
restart:				;Restart scrolltext
	move.l	#TEXT,TEXTP
	move.l	#introfont+2104,d0
	bra	blitchar
;------------------------------------------------------------------------
calcaj:
	sub.l	#97,d0
	lsl.l	#2,d0
	add.l	#introfont,d0
	bra	blitchar
calckt:
	sub.l	#107,d0
	lsl.l	#2,d0
	add.l	#introfont+1040,d0
	bra	blitchar
calcuz:
	sub.l	#117,d0
	lsl.l	#2,d0
	add.l	#introfont+2080,d0
	bra	blitchar
calcnumbers:
	sub.l	#48,d0
	lsl.l	#2,d0
	add.l	#introfont+3120,d0
	bra	blitchar
calci:
	move.l	#introfont+32,d0
	move.w	#2,count
	bra	blitchar
calcsign:
	move.l	#introfont+4160,d0
	bra	blitchar
idiotsigns1:
	sub.l	#39,d0
	lsl.l	#2,d0
	add.l	#introfont+4168,d0
	bra	blitchar
idiotsigns2:
	sub.l	#43,d0
	lsl.l	#2,d0
	add.l	#introfont+4180,d0
	bra	blitchar
idiotsigns3:
	sub.l	#63,d0
	lsl.l	#2,d0
	add.l	#introfont+5200,d0
	bra	blitchar
kolon:	
	move.l	#introfont+4196,d0
	bra	blitchar
blitchar:				; place the letter in the scrollbuffers right position
	move.l	#scrollbuffer+40,a1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#%0000100111110000,$dff040
	move.w	#00,$dff042
	move.l	#-1,$dff044
	move.w	#36,$dff064
	move.w	#42,$dff066
	move.l	d0,$dff050
	move.l	a1,$dff054
	move.w	#1666,$dff058
	rts
;------------------------------------------
;!! This routine makes the scroller jump !!
;------------------------------------------
blitscroll:
	move.l	heightpointer,a1
	move.l	(a1)+,d0
	cmp.l	#0,(a1)
	bne	continue
	move.l	#heighttable,a1
continue:
	move.l	a1,heightpointer	
	lea	screen,a2
	add.l	d0,a2
	lea	scrollbuffer,a1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#%0000100111110000,$dff040
	move.w	#00,$dff042
	move.l	#-1,$dff044
	move.w	#0,$dff064
	move.w	#0,$dff066
	move.l	a1,$dff050
	move.l	a2,$dff054
	move.w	#1687,$dff058
	rts

clear:
	lea	screen+8372,a1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#$0100,$dff040	
	move.w	#0,$dff042
	move.l	a1,$dff054
	move.w	#0,$dff066
	move.w	#6413,$dff058	
	rts
;-----------------------------------------------------------
;!! A stream effect for inserting a logo to the screen    !!
;-----------------------------------------------------------
effectcheckfashion:
	cmp.l	#2680,logolinesfashion		; test if effect is finished
	bne	effectfashion
	rts
effectfashion:
	lea	triumphlogo,a1
	add.l	logolinesfashion,a1
	lea	screen,a2
	add.l	screenaddfashion,a2
	moveq	#3,d1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#$09f0,$dff040	
	move.w	#0,$dff042
	move.w	#-1,$dff044
	move.l	a1,$dff050
	move.l	a2,$dff054
	move.w	#-40,$dff064
	move.w	#6,$dff066
	move.w	blitsizefashion,$dff058	

	add.l	#11776,a2
	add.l	#2720,a1
	dbra	d1,.waitblit

	add.l	#40,logolinesfashion
	add.l	#46,screenaddfashion
	sub.w	#64,blitsizefashion
	rts
;---------------------------------------------------------
;!! A effect which inserts a line one by one of a logo  !!
;---------------------------------------------------------
effectcheckwhipe:
	tst.l	logolineswhipe			; test if effect is finished
	bne	effectwhipe
	rts
effectwhipe:
	lea	questlogo,a1
	add.l	logolineswhipe,a1
	lea	screen+6,a2
	add.l	screenaddwhipe,a2
	moveq	#3,d1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#$09f0,$dff040	
	clr.w	$dff042
	move.w	#-1,$dff044
	move.l	a1,$dff050
	move.l	a2,$dff054
	clr.w	$dff064
	move.w	#20,$dff066
	move.w	#77,$dff058	

	add.l	#11776,a2
	add.l	#1768,a1
	dbra	d1,.waitblit

	sub.l	#26,logolineswhipe
	sub.l	#46,screenaddwhipe
	rts
;----------------------------------------
;!! Routine for clearing the logo area !!
;----------------------------------------
effectcheckout:
	cmp.l	#3220,screenaddout		; test if effect is finished
	bne	whipeout
	rts
whipeout:
	lea	screen,a1
	add.l	screenaddout,a1
	moveq	#3,d1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#$0100,$dff040	
	move.w	#0,$dff042
	move.l	a1,$dff054
	move.w	#0,$dff066
	move.w	#84,$dff058	

	add.l	#11776,a1
	dbra	d1,.waitblit
	add.l	#46,screenaddout
	rts
;-----------------------------------
;!! Raise a logo up to the screen !!
;-----------------------------------
effectcheckraise:
	tst.l	screenaddraise			; test if effect is finished
	bne	effectraise
	rts
effectraise:
	lea	warplogo,a1
	lea	screen+6,a2
	add.l	screenaddraise,a2
	moveq	#3,d1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#$09f0,$dff040	
	clr.w	$dff042
	move.w	#-1,$dff044
	move.l	a1,$dff050
	move.l	a2,$dff054
	clr.w	$dff064
	move.w	#20,$dff066
	move.w	blitsizeraise,$dff058	

	add.l	#11776,a2
	add.l	#1508,a1
	dbra	d1,.waitblit

	sub.l	#46,screenaddraise
	add.w	#64,blitsizeraise
	rts
;--------------------------------
;!! Lower a logo on the screen !!
;--------------------------------
effectchecklower:
	tst.l	logolineslower			; test if effect is finished
	bne	effectlower
	rts
effectlower:
	lea	smeagollogo,a1
	add.l	logolineslower,a1
	lea	screen+6,a2
	moveq	#3,d1
.waitblit:
	btst	#6,$dff002
	bne	.waitblit
	move.w	#$09f0,$dff040	
	clr.w	$dff042
	move.w	#-1,$dff044
	move.l	a1,$dff050
	move.l	a2,$dff054
	clr.w	$dff064
	move.w	#18,$dff066
	move.w	blitsizelower,$dff058	

	add.l	#11776,a2
	add.l	#1400,a1
	dbra	d1,.waitblit

	add.w	#64,blitsizelower
	sub.l	#28,logolineslower
	rts
;------------------------------------------------------
;!! Roll the greetings tube			     !!
;------------------------------------------------------
backside:
	cmp.l	#1300,messylines2
	bhi	contback
	rts
contback:
	cmp.l	#18694,messylines1
	bne	back
	rts
back:
	lea	messy,a1
	add.l	messylines1,a1
	lea	screen+6906,a2		;blit at 1st bitplane
	tst.b	messycount1
	beq	blitbackside
	addq.b	#1,messycount1
	cmp.b	#3,messycount1
	beq	resetmessy1
	rts
blitbackside:
	btst	#$6,$dff002
	bne	blitbackside
	move.w	#$09f0,$dff040	
	clr.w	$dff042
	move.w	#-1,$dff044
	move.l	a1,$dff050
	move.l	a2,$dff054
	clr.w	$dff064
	move.w	#-72,$dff066
	move.w	#3213,$dff058	
	
	add.l	#26,messylines1
	move.b	#1,messycount1
	rts

frontside:
	cmp.l	#18694,messylines2
	bne	front
	rts
front:
	lea	messy,a1
	add.l	messylines2,a1
	lea	screen+16382,a2		;blit at 2nd bitplane
	tst.b	messycount2
	beq	blitfrontside
	addq.b	#1,messycount2
	cmp.b	#3,messycount2
	beq	resetmessy2
	rts
blitfrontside:
	btst	#$6,$dff002
	bne	blitfrontside
	move.w	#$09f0,$dff040	
	move.w	#0,$dff042
	move.w	#-1,$dff044
	move.l	a1,$dff050
	move.l	a2,$dff054
	move.w	#0,$dff064
	move.w	#20,$dff066
	move.w	#3213,$dff058	
	
	add.l	#26,messylines2
	move.b	#1,messycount2
	rts

resetmessy1:
	move.b	#0,messycount1
	rts
resetmessy2:
	move.b	#0,messycount2
	rts
;-------------------------------------------
;		The stars
;-------------------------------------------
movesprite:
	lea	AA,a1		;Last time I gonna make a starfield with
	cmp.b	#240,(a1)	;only one sprite. Still it could have
	bne	notaa		;been done a thousand times better.
	move.b	#$38,(a1)	;There is something called loops and
notaa:				;tables, you know!!!!!!!!!!!!!!!
	addq.b	#1,(a1)

	lea	AB,a1
	cmp.b	#240,(a1)
	bne	notab
	move.b	#$38,(a1)
notab:
	addq.b	#3,(a1)

	lea	ACd,a1
	cmp.b	#240,(a1)
	bne	notac
	move.b	#$38,(a1)
notac:
	addq.b	#1,(a1)

	lea	A,a1
	cmp.b	#240,(a1)
	bne	nota
	move.b	#$38,(a1)
nota:
	addq.b	#2,(a1)

	lea	B,a1
	cmp.b	#240,(a1)
	bne	nota
	move.b	#$38,(a1)
notb:
	addq.b	#2,(a1)

	lea	C,a1
	cmp.b	#240,(a1)
	bne	notc
	move.b	#$38,(a1)
notc:
	addq.b	#3,(a1)

	lea	D,a1
	cmp.b	#240,(a1)
	bne	notd
	move.b	#$38,(a1)
notd:
	addq.b	#1,(a1)

	lea	E,a1
	cmp.b	#240,(a1)
	bne	note
	move.b	#$38,(a1)
note:
	addq.b	#1,(a1)

	lea	F,a1
	cmp.b	#240,(a1)
	bne	notf
	move.b	#$38,(a1)
notf:
	addq.b	#3,(a1)

	lea	G,a1
	cmp.b	#240,(a1)
	bne	notg
	move.b	#$38,(a1)
notg:
	addq.b	#2,(a1)

	lea	H,a1
	cmp.b	#240,(a1)
	bne	noth
	move.b	#$38,(a1)
noth:
	addq.b	#3,(a1)

	lea	I,a1
	cmp.b	#240,(a1)
	bne	noti
	move.b	#$38,(a1)
noti:
	addq.b	#1,(a1)

	lea	J,a1
	cmp.b	#240,(a1)
	bne	notj
	move.b	#$38,(a1)
notj:
	addq.b	#2,(a1)

	lea	K,a1
	cmp.b	#240,(a1)
	bne	notk
	move.b	#$38,(a1)
notk:
	addq.b	#1,(a1)

	lea	L,a1
	cmp.b	#240,(a1)
	bne	notl
	move.b	#$38,(a1)
notl:
	addq.b	#3,(a1)

	lea	M,a1
	cmp.b	#240,(a1)
	bne	notm
	move.b	#$38,(a1)
notm:
	addq.b	#1,(a1)

	lea	N,a1
	cmp.b	#240,(a1)
	bne	notn
	move.b	#$38,(a1)
notn:
	addq.b	#2,(a1)

	lea	O,a1
	cmp.b	#240,(a1)
	bne	noto
	move.b	#$38,(a1)
noto:
	addq.b	#1,(a1)

	lea	P,a1
	cmp.b	#240,(a1)
	bne	notp
	move.b	#$38,(a1)
notp:
	addq.b	#3,(a1)

	lea	Q,a1
	cmp.b	#240,(a1)
	bne	notq
	move.b	#$38,(a1)
notq:
	addq.b	#2,(a1)

	lea	R,a1
	cmp.b	#240,(a1)
	bne	notr
	move.b	#$38,(a1)
notr:
	addq.b	#1,(a1)

	lea	S,a1
	cmp.b	#240,(a1)
	bne	nots
	move.b	#$38,(a1)
nots:
	addq.b	#2,(a1)

	lea	T,a1
	cmp.b	#240,(a1)
	bne	nott
	move.b	#$38,(a1)
nott:
	addq.b	#3,(a1)

	lea	U,a1
	cmp.b	#240,(a1)
	bne	notu
	move.b	#$38,(a1)
notu:
	addq.b	#3,(a1)
	rts
;-------------------------
;!! The moveing sprites !!
;-------------------------
newsprite:				; This is very ineffective code, I could have
	cmp.b	#1,spritech		; used the same table for all the sprites, and
	beq	gosprite		; done the whole operation in a loop.
	rts
gosprite:
	move.l	xprt1,a0
	move.l	yprt1,a1
	bsr	calculate
	move.w	d3,sprite1
	move.w	d2,sprite1+2
	addq.l	#2,xprt1
	addq.l	#2,yprt1
	cmp.l	#sprite1xpositionend,xprt1
	bne	noend1
	move.l	#sprite1xposition,xprt1
noend1:
	cmp.l	#sprite1ypositionend,yprt1
	bne	noend2
	move.l	#sprite1yposition,yprt1
noend2:
	move.l	xprt2,a0
	move.l	yprt2,a1
	bsr	calculate
	move.w	d3,sprite2
	move.w	d2,sprite2+2
	addq.l	#2,xprt2
	addq.l	#2,yprt2
	cmp.l	#sprite2xpositionend,xprt2
	bne	noend3
	move.l	#sprite2xposition,xprt2
noend3:
	cmp.l	#sprite2ypositionend,yprt2
	bne	noend4
	move.l	#sprite2yposition,yprt2
noend4:
	move.l	xprt3,a0
	move.l	yprt3,a1
	bsr	calculate
	move.w	d3,sprite3
	move.w	d2,sprite3+2
	addq.l	#2,xprt3
	addq.l	#2,yprt3
	cmp.l	#sprite3xpositionend,xprt3
	bne	noend5
	move.l	#sprite3xposition,xprt3
noend5:
	cmp.l	#sprite3ypositionend,yprt3
	bne	noend6
	move.l	#sprite3yposition,yprt3
noend6:
	move.l	xprt4,a0
	move.l	yprt4,a1
	bsr	calculate
	move.w	d3,sprite4
	move.w	d2,sprite4+2
	addq.l	#2,xprt4
	addq.l	#2,yprt4
	cmp.l	#sprite4xpositionend,xprt4
	bne	noend7
	move.l	#sprite4xposition,xprt4
noend7:
	cmp.l	#sprite4ypositionend,yprt4
	bne	noend8
	move.l	#sprite4yposition,yprt4
noend8:
	move.l	xprt5,a0
	move.l	yprt5,a1
	bsr	calculate
	move.w	d3,sprite5
	move.w	d2,sprite5+2
	addq.l	#2,xprt5
	addq.l	#2,yprt5
	cmp.l	#sprite5xpositionend,xprt5
	bne	noend9
	move.l	#sprite5xposition,xprt5
noend9:
	cmp.l	#sprite5ypositionend,yprt5
	bne	noend10
	move.l	#sprite5yposition,yprt5
noend10:
	move.l	xprt6,a0
	move.l	yprt6,a1
	bsr	calculate
	move.w	d3,sprite6
	move.w	d2,sprite6+2
	addq.l	#2,xprt6
	addq.l	#2,yprt6
	cmp.l	#sprite6xpositionend,xprt6
	bne	noend11
	move.l	#sprite6xposition,xprt6
noend11:
	cmp.l	#sprite6ypositionend,yprt6
	bne	noend12
	move.l	#sprite6yposition,yprt6
noend12:
	move.l	xprt7,a0
	move.l	yprt7,a1
	bsr	calculate
	move.w	d3,sprite7
	move.w	d2,sprite7+2
	addq.l	#2,xprt7
	addq.l	#2,yprt7
	cmp.l	#sprite7xpositionend,xprt7
	bne	noend13
	move.l	#sprite7xposition,xprt7
noend13:
	cmp.l	#sprite7ypositionend,yprt7
	bne	noend14
	move.l	#sprite7yposition,yprt7
noend14:
	rts

calculate:
	move.w 	(a0),d1
	clr.l	d2
	move.w	d1,d2
	add.w	#13,d2		;height of sprites-controll words
	move.w	(a1),d3
	asl.w	#$8,d1
	or.w	d1,d3
	asl.w	#$8,d2
	rts

	section	data,data_p
;---------------------------------
;!! Colour tables for the logos !!
;---------------------------------
triumphlogoc:
	dc.w	$0000,$0fff,$0dde,$0bbd
	dc.w	$0aac,$088c,$077b,$066a
	dc.w	$0559,$0348,$0337,$0226
	dc.w	$0116,$0115,$0004,$0003
smeagollogoc:
	dc.w	$0000,$0fff,$0000,$0000
	dc.w	$0f0d,$0e0c,$0d0b,$0c0a
	dc.w	$0b09,$0a08,$0907,$0806
	dc.w	$0705,$0604,$0503,$0402
warplogoc:
	dc.w	$0000,$0fff,$00b0,$01ff
	dc.w	$0c8c,$0b7b,$0a6a,$0959
	dc.w	$0848,$0838,$0727,$0616
	dc.w	$0515,$0404,$0dad,$0ebe
questlogoc:
	dc.w	$0000,$0ffb,$0ee9,$0dc6
	dc.w	$0cb5,$0ca3,$0b81,$0a70
	dc.w	$0960,$0850,$0840,$0730
	dc.w	$0620,$0520,$0510,$0410
;---------------------------
;! Variabels and constants !
;---------------------------
logolinesfashion:
	dc.l	2680
screenaddfashion:
	dc.l	0
blitsizefashion:
	dc.w	0
logolineswhipe:
	dc.l	0
screenaddwhipe:
	dc.l	0	
screenaddout:
	dc.l	3220
screenaddraise:
	dc.l	0
blitsizeraise:
	dc.w	0
blitsizelower:
	dc.w	0
logolineslower:
	dc.l	0
messylines1:
	dc.l	18694
messylines2:
	dc.l	18694
messycount1:
	dc.b	0
messycount2:
	dc.b	0
spritech:
	dc.b	0
musicch:
	dc.b	0
TEXTP:
	dc.l	TEXT
count:
	dc.w	1
waitcounter:
	dc.w	0			; only move the scroller if this is 0
heightpointer:
	dc.l	heighttable
GfxName:
	dc.b	"graphics.library",0
	even
wbview:
	dc.l	0
TEXT:					; I did not change the text. I know it's stupid, but
	dc.b	"B@triumph@A"		; the effects are timed by the scrolltext.
	dc.b	" FH presents another intro."
	dc.b	" let us put down the credits.coding"
	dc.b	"D and smeagol logo Gby: "
	dc.b	" smeagol A" 
	dc.b	"   triumph logo by: "
	dc.b	"  ninja  A"
	dc.b	"  Dfont quest and warp logCo by:  "
	dc.b	"  quest  A"	
	dc.b	"this intro was mainly madeD to introduce the three"
	dc.b	" newB members of triumph:smeagol,questD and warp."
	dc.b	"             ok...  this is qCuest taking over the "
	dc.b	"keyboard...yes,this is a production by three new members "
	dc.b	"in triumph...                                    "
	dc.b	"Fquest(me):graphix and sounds    smeagol:coding "
	dc.b	"and sounds   and last but not least warp:coding        ok now "
	dc.b	"here is the story... D      in the beginning there was "
	dc.b	"the undeErworld which was nothing but lame.....it consisted "
	dc.b	"of unknown members and warp(then warlord)      after a long "
	dc.b	"with laming warp,smeagol,Dcyberpunk(was swapping),the ruler("
	dc.b	"ex-Gphobia),menzoni(very lame but an ok dude),slayer(quest)"
	dc.b	"plus more started organizing a bit and called ourselves "
	dc.b	"beDyond reality(now usedF by someone else!)   as beyond reali"
	dc.b	"Bty we made(not released)."
	dc.b	"one intro(not too many people saw that one)."
	dc.b	"after a while the lazyest and lamest members were kicked out."
	dc.b	"and we began a new era Dof computing....:"
	dc.b	" hysteria A"
	dc.b	"   we made one demo and oneC intro (not very good)  this group "	
	dc.b	"did not last too long bacause we realized that a three member-"	
	dc.b	"group was not good enough...    nor enough organized.....     "
	dc.b	"so warp and smeagol wrote some letters to a couple of "
	dc.b	"Fgroups.... we got answers from most of the groups we had"
	dc.b	" written to,and we decidDed that we would join triumph."
	dc.b	"      the enEd...     "
	dc.b	0
	even
;-----------------------------------
;		tables
;-----------------------------------
heighttable:
	dc.l	8372,8372,8418,8418,8464,8464,8510,8510,8556,8556
	dc.l	8602,8602,8648,8694,8740,8786,8832,8878
	dc.l	8970,9062,9154,9246,9292,9384,9430,9568,9706
	dc.l	9844,9982,10120,10258,10442,10626
	dc.l	10442,10258,10120,9982,9844
	dc.l	9706,9568,9430,9384,9292,9246,9154,9062,8970
	dc.l	8878,8832,8786,8740,8694,8648,8602,8602
	dc.l	8556,8556,8510,8510,8464,8464,8418,8418,8372,8372	
	dc.l	0
;------------------------------------------------------
;!! Tables and controll data for the TRIUMPH sprites !!
;------------------------------------------------------
xprt1:
	dc.l	sprite1xposition
yprt1:
	dc.l	sprite1yposition
sprite1xposition:
        dc.w      135,140,144,149,154,158,163,167
        dc.w      171,175,179,183,187,190,194,197
        dc.w      200,203,205,208,210,211,213,214
        dc.w      215,216,217,217,217,217,216,215
        dc.w      214,213,211,210,208,205,203,200
        dc.w      197,194,190,187,183,179,175,171
        dc.w      167,163,158,154,149,144,140,135
        dc.w      130,126,121,116,112,107,103,99
        dc.w      95,91,87,83,80,76,73,70
        dc.w      67,65,62,60,59,57,56,55
        dc.w      54,53,53,53,53,54,55,56
        dc.w      57,59,60,62,65,67,70,73
        dc.w      76,80,83,87,91,95,99,103
        dc.w      107,112,116,121,126,130,135

sprite1xpositionend:
sprite1yposition:
        dc.w      140,144,148,152,156,160,164,168
        dc.w      172,175,179,182,186,189,192,195
        dc.w      198,200,202,205,207,208,210,211
        dc.w      212,213,214,215,215,215,215,214
        dc.w      214,213,212,211,209,208,206,204
        dc.w      201,199,196,193,190,187,184,181
        dc.w      177,174,170,166,162,158,154,150
        dc.w      146,142,138,134,130,126,122,118
        dc.w      114,110,106,103,99,96,93,90
        dc.w      87,84,81,79,76,74,72,71
        dc.w      69,68,67,66,66,65,65,65
        dc.w      65,66,67,68,69,70,72,73
        dc.w      75,78,80,82,85,88,91,94
        dc.w      98,101,105,108,112,116,120,124
        dc.w      128,132,136
sprite1ypositionend:


xprt2:
	dc.l	sprite2xposition
yprt2:
	dc.l	sprite2yposition
sprite2xposition:
	dc.w	179,183,187,190,194,197
        dc.w      200,203,205,208,210,211,213,214
        dc.w      215,216,217,217,217,217,216,215
        dc.w      214,213,211,210,208,205,203,200
        dc.w      197,194,190,187,183,179,175,171
        dc.w      167,163,158,154,149,144,140,135
        dc.w      130,126,121,116,112,107,103,99
        dc.w      95,91,87,83,80,76,73,70
        dc.w      67,65,62,60,59,57,56,55
        dc.w      54,53,53,53,53,54,55,56
        dc.w      57,59,60,62,65,67,70,73
        dc.w      76,80,83,87,91,95,99,103
        dc.w      107,112,116,121,126,130,135
        dc.w      135,140,144,149,154,158,163,167,171,175
sprite2xpositionend:
sprite2yposition:
	dc.w	179,182,186,189,192,195
        dc.w      198,200,202,205,207,208,210,211
        dc.w      212,213,214,215,215,215,215,214
        dc.w      214,213,212,211,209,208,206,204
        dc.w      201,199,196,193,190,187,184,181
        dc.w      177,174,170,166,162,158,154,150
        dc.w      146,142,138,134,130,126,122,118
        dc.w      114,110,106,103,99,96,93,90
        dc.w      87,84,81,79,76,74,72,71
        dc.w      69,68,67,66,66,65,65,65
        dc.w      65,66,67,68,69,70,72,73
        dc.w      75,78,80,82,85,88,91,94
        dc.w      98,101,105,108,112,116,120,124
        dc.w      128,132,136
        dc.w      140,144,148,152,156,160,164,168,172,175
sprite2ypositionend:


xprt3:
	dc.l	sprite3xposition
yprt3:
	dc.l	sprite3yposition
sprite3xposition:
	dc.w	210,211,213,214
        dc.w	215,216,217,217,217,217,216,215
        dc.w	214,213,211,210,208,205,203,200
        dc.w	197,194,190,187,183,179,175,171
        dc.w	167,163,158,154,149,144,140,135
        dc.w	130,126,121,116,112,107,103,99
        dc.w	95,91,87,83,80,76,73,70
        dc.w	67,65,62,60,59,57,56,55
        dc.w	54,53,53,53,53,54,55,56
        dc.w	57,59,60,62,65,67,70,73
        dc.w	76,80,83,87,91,95,99,103
        dc.w	107,112,116,121,126,130,135
        dc.w	135,140,144,149,154,158,163,167,171,175
	dc.w	179,183,187,190,194,197
        dc.w	200,203,205,208
sprite3xpositionend:
sprite3yposition:
	dc.w	207,208,210,211
        dc.w    212,213,214,215,215,215,215,214
        dc.w    214,213,212,211,209,208,206,204
        dc.w    201,199,196,193,190,187,184,181
        dc.w    177,174,170,166,162,158,154,150
        dc.w    146,142,138,134,130,126,122,118
        dc.w    114,110,106,103,99,96,93,90
        dc.w    87,84,81,79,76,74,72,71
        dc.w    69,68,67,66,66,65,65,65
        dc.w    65,66,67,68,69,70,72,73
        dc.w    75,78,80,82,85,88,91,94
        dc.w    98,101,105,108,112,116,120,124
        dc.w    128,132,136
        dc.w    140,144,148,152,156,160,164,168,172,175
	dc.w	179,182,186,189,192,195
        dc.w    198,200,202,205
sprite3ypositionend:


xprt4:
	dc.l	sprite4xposition
yprt4:
	dc.l	sprite4yposition
sprite4xposition:
	dc.w	216,215
        dc.w    214,213,211,210,208,205,203,200
        dc.w    197,194,190,187,183,179,175,171
        dc.w    167,163,158,154,149,144,140,135
        dc.w    130,126,121,116,112,107,103,99
        dc.w    95,91,87,83,80,76,73,70
        dc.w    67,65,62,60,59,57,56,55
        dc.w    54,53,53,53,53,54,55,56
        dc.w    57,59,60,62,65,67,70,73
        dc.w    76,80,83,87,91,95,99,103
        dc.w    107,112,116,121,126,130,135
        dc.w    135,140,144,149,154,158,163,167,171,175
	dc.w	179,183,187,190,194,197
        dc.w    200,203,205,208
	dc.w	210,211,213,214
        dc.w    215,216,217,217,217,217
sprite4xpositionend:
sprite4yposition:
	dc.w	215,214
        dc.w    214,213,212,211,209,208,206,204
        dc.w    201,199,196,193,190,187,184,181
        dc.w    177,174,170,166,162,158,154,150
        dc.w    146,142,138,134,130,126,122,118
        dc.w    114,110,106,103,99,96,93,90
        dc.w    87,84,81,79,76,74,72,71
        dc.w    69,68,67,66,66,65,65,65
        dc.w    65,66,67,68,69,70,72,73
        dc.w    75,78,80,82,85,88,91,94
        dc.w    98,101,105,108,112,116,120,124
        dc.w    128,132,136
        dc.w    140,144,148,152,156,160,164,168,172,175
	dc.w	179,182,186,189,192,195
        dc.w    198,200,202,205
	dc.w	207,208,210,211
        dc.w    212,213,214,215,215,215
sprite4ypositionend:

xprt5:
	dc.l	sprite5xposition
yprt5:
	dc.l	sprite5yposition
sprite5xposition:
        dc.w    197,194,190,187,183,179,175,171
        dc.w    167,163,158,154,149,144,140,135
        dc.w    130,126,121,116,112,107,103,99
        dc.w    95,91,87,83,80,76,73,70
        dc.w    67,65,62,60,59,57,56,55
        dc.w    54,53,53,53,53,54,55,56
        dc.w    57,59,60,62,65,67,70,73
        dc.w    76,80,83,87,91,95,99,103
        dc.w	107,112,116,121,126,130,135
        dc.w	135,140,144,149,154,158,163,167,171,175
	dc.w	179,183,187,190,194,197
        dc.w    200,203,205,208
	dc.w	210,211,213,214
        dc.w    215,216,217,217,217,217
	dc.w	216,215
        dc.w    214,213,211,210,208,205,203,200
sprite5xpositionend:

sprite5yposition:
        dc.w    201,199,196,193,190,187,184,181
        dc.w    177,174,170,166,162,158,154,150
        dc.w    146,142,138,134,130,126,122,118
        dc.w    114,110,106,103,99,96,93,90
        dc.w    87,84,81,79,76,74,72,71
        dc.w    69,68,67,66,66,65,65,65
        dc.w    65,66,67,68,69,70,72,73
        dc.w    75,78,80,82,85,88,91,94
        dc.w    98,101,105,108,112,116,120,124
        dc.w    128,132,136
        dc.w    140,144,148,152,156,160,164,168,172,175
	dc.w	179,182,186,189,192,195
        dc.w    198,200,202,205
	dc.w	207,208,210,211
        dc.w    212,213,214,215,215,215
	dc.w	215,214
        dc.w    214,213,212,211,209,208,206,204
sprite5ypositionend:

xprt6:
	dc.l	sprite6xposition
yprt6:
	dc.l	sprite6yposition
sprite6xposition:
	dc.w	158,154,149,144,140,135
        dc.w    130,126,121,116,112,107,103,99
        dc.w    95,91,87,83,80,76,73,70
        dc.w    67,65,62,60,59,57,56,55
        dc.w    54,53,53,53,53,54,55,56
        dc.w    57,59,60,62,65,67,70,73
        dc.w    76,80,83,87,91,95,99,103
        dc.w    107,112,116,121,126,130,135
        dc.w    135,140,144,149,154,158,163,167,171,175
	dc.w	179,183,187,190,194,197
        dc.w    200,203,205,208
	dc.w	210,211,213,214
        dc.w    215,216,217,217,217,217
	dc.w	216,215
        dc.w    214,213,211,210,208,205,203,200
        dc.w    197,194,190,187,183,179,175,171
        dc.w    167,163
sprite6xpositionend:
sprite6yposition:
	dc.w	170,166,162,158,154,150
        dc.w    146,142,138,134,130,126,122,118
        dc.w    114,110,106,103,99,96,93,90
        dc.w    87,84,81,79,76,74,72,71
        dc.w    69,68,67,66,66,65,65,65
        dc.w    65,66,67,68,69,70,72,73
        dc.w    75,78,80,82,85,88,91,94
        dc.w    98,101,105,108,112,116,120,124
        dc.w    128,132,136
        dc.w    140,144,148,152,156,160,164,168,172,175
	dc.w	179,182,186,189,192,195
        dc.w    198,200,202,205
	dc.w	207,208,210,211
        dc.w    212,213,214,215,215,215
	dc.w	215,214
        dc.w    214,213,212,211,209,208,206,204
        dc.w    201,199,196,193,190,187,184,181
        dc.w    177,174
sprite6ypositionend:


xprt7:
	dc.l	sprite7xposition
yprt7:
	dc.l	sprite7yposition
sprite7xposition:
	dc.w	112,107,103,99
        dc.w    95,91,87,83,80,76,73,70
        dc.w    67,65,62,60,59,57,56,55
        dc.w    54,53,53,53,53,54,55,56
        dc.w    57,59,60,62,65,67,70,73
        dc.w    76,80,83,87,91,95,99,103
        dc.w    107,112,116,121,126,130,135
        dc.w    135,140,144,149,154,158,163,167,171,175
	dc.w	179,183,187,190,194,197
        dc.w    200,203,205,208
	dc.w	210,211,213,214
        dc.w    215,216,217,217,217,217
	dc.w	216,215
        dc.w    214,213,211,210,208,205,203,200
        dc.w    197,194,190,187,183,179,175,171
        dc.w    167,163
	dc.w	158,154,149,144,140,135
        dc.w    130,126,121,116
sprite7xpositionend:
sprite7yposition:
	dc.w	130,126,122,118
        dc.w    114,110,106,103,99,96,93,90
        dc.w    87,84,81,79,76,74,72,71
        dc.w    69,68,67,66,66,65,65,65
        dc.w    65,66,67,68,69,70,72,73
        dc.w    75,78,80,82,85,88,91,94
        dc.w    98,101,105,108,112,116,120,124
        dc.w    128,132,136
        dc.w    140,144,148,152,156,160,164,168,172,175
	dc.w	179,182,186,189,192,195
        dc.w    198,200,202,205
	dc.w	207,208,210,211
        dc.w    212,213,214,215,215,215
	dc.w	215,214
        dc.w    214,213,212,211,209,208,206,204
        dc.w    201,199,196,193,190,187,184,181
        dc.w    177,174
	dc.w	170,166,162,158,154,150
        dc.w    146,142,138,134
sprite7ypositionend:

;-----------------
;!! Sprite data !!
;-----------------
	section sprite,data_c
sprite1:
	dc.w	0,0
	dc.w	$f87c,$0000
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8004,$7ffc
	dc.w	$8fc4,$7ffc
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$f87c,$783c
	dc.w	$0,$0
sprite2:
	dc.w	0,0
	dc.w	$fff8,$0000
	dc.w	$8004,$7ffc
	dc.w	$8044,$787c
	dc.w	$8044,$787c
	dc.w	$8044,$787c
	dc.w	$8044,$787c
	dc.w	$8004,$7ffc
	dc.w	$8ff8,$7ff8
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$f800,$7800
	dc.w	$0,$0
sprite3:
	dc.w	0,0
	dc.w	$7ffc,$0000
	dc.w	$8002,$7ffe
	dc.w	$9292,$718e
	dc.w	$9292,$718e
	dc.w	$9292,$718e
	dc.w	$9292,$718e
	dc.w	$9392,$718e
	dc.w	$9012,$700e
	dc.w	$9012,$700e
	dc.w	$9012,$700e
	dc.w	$9012,$700e
	dc.w	$9012,$700e
	dc.w	$f01e,$700e
	dc.w	$0,$0
sprite4:
	dc.w	0,0
	dc.w	$f87c,$0000
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$8004,$7ffc
	dc.w	$7ff8,$7ff8
	dc.w	$0,$0
sprite5:
	dc.w	0,0
	dc.w	$f800,$0000
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$8800,$7800
	dc.w	$f800,$7800
	dc.w	$0,$0
sprite6:
	dc.w	0,0
	dc.w	$fff8,$0000
	dc.w	$8004,$7ffc
	dc.w	$8004,$787c
	dc.w	$8004,$787c
	dc.w	$8004,$787c
	dc.w	$8004,$787c
	dc.w	$8788,$7ff8
	dc.w	$8004,$7ffc
	dc.w	$8844,$783c
	dc.w	$8844,$783c 
	dc.w	$8844,$783c
	dc.w	$8844,$783c
	dc.w	$f87c,$f87c
	dc.w	$0,$0
sprite7:
	dc.w	0,0
	dc.w	$fff8,$0000
	dc.w	$f8f8,$fff8
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0880,$0780
	dc.w	$0f80,$0780
	dc.w	$0,$0

sprite8:
	dc.b	$30
AA:	dc.b	$a0
	dc.w	$3100
	dc.w	$0000,$0000

	dc.b	$40
AB:	dc.b	$c5
	dc.w	$4900
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$4a
ACd:	dc.b	$6c
	dc.w	$4f00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$50
A:	dc.b	$24
	dc.w	$5700
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$58
B:	dc.b	$70
	dc.w	$5f00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$60
C:	dc.b	$aa
	dc.w	$6900
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$72
D:	dc.b	$45
	dc.w	$7700
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$78
E:	dc.b	$83
	dc.w	$7d00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$7e
F:	dc.b	$3e
	dc.w	$8700
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$88
G:	dc.b	$af
	dc.w	$8f00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$90
H:	dc.b	$20
	dc.w	$9900
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$9a
I:	dc.b	$30
	dc.w	$9f00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$a0
J:	dc.b	$50
	dc.w	$a700
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$a8
K:	dc.b	$80
	dc.w	$ad00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$ae
L:	dc.b	$35
	dc.w	$b700
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$b8
M:	dc.b	$3a
	dc.w	$bd00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$be
N:	dc.b	$8e
	dc.w	$c500
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$c6
O:	dc.b	$c0
	dc.w	$cb00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$cc
P:	dc.b	$77
	dc.w	$d500
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$d6
Q:	dc.b	$e9
	dc.w	$dd00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$de
R:	dc.b	$6c
	dc.w	$e300
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$5400,$6c00
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$e4
S:	dc.b	$2f
	dc.w	$eb00
	dc.w	$1000,$1000
	dc.w	$0000,$1000
	dc.w	$1000,$0000
	dc.w	$ba00,$c600
	dc.w	$1000,$0000
	dc.w	$0000,$1000
	dc.w	$1000,$1000

	dc.b	$ec
T:	dc.b	$49
	dc.w	$f500
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800

	dc.b	$f6
U:	dc.b	$99
	dc.w	$ff00
	dc.w	$0800,$0800
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$1c00,$1400
	dc.w	$9c80,$e380
	dc.w	$1c00,$1400
	dc.w	$0000,$0800
	dc.w	$0000,$0800
	dc.w	$0800,$0800
	dc.w	0,0
;---------------------
;!! The copper list !!
;---------------------
copper:
	dc.w	$0100,$4200
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0006
	dc.w	$010a,$0006
	dc.w	$008e,$2c81
	dc.w	$0090,$f4c1
	dc.w	$0090,$38c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0

	dc.w	$0106,$0000		; low resolution sprites

spritepointers:
	dc.w	$0120,$0000
	dc.w	$0122,$0000
	dc.w	$0124,$0000
	dc.w	$0126,$0000
	dc.w	$0128,$0000
	dc.w	$012A,$0000
	dc.w	$012C,$0000
	dc.w	$012E,$0000
	dc.w	$0130,$0000
	dc.w	$0132,$0000
	dc.w	$0134,$0000
	dc.w	$0136,$0000
	dc.w	$0138,$0000
	dc.w	$013A,$0000
	dc.w	$013c,$0000
	dc.w	$013e,$0000

	dc.w	$2c01,$fffe
	dc.w	$0100,$4200

	dc.w	$0182,$0fff
	dc.w	$0184,$0dde
	dc.w	$0186,$0bbd

bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
farge:					; Here we load the colours of the logos
	dc.w	$0180,$0000
	dc.w	$0182,$0000
	dc.w	$0184,$0000
	dc.w	$0186,$0000
	dc.w	$0188,$0000
	dc.w	$018a,$0000
	dc.w	$018c,$0000
	dc.w	$018e,$0000
	dc.w	$0190,$0000
	dc.w	$0192,$0000
	dc.w	$0194,$0000
	dc.w	$0196,$0000
	dc.w	$0198,$0000
	dc.w	$019a,$0000
	dc.w	$019c,$0000
	dc.w	$019e,$0000

;spritecolors
	dc.w	$01a0,$0000,$01a2,$0fd3,$01a4,$0c50,$01a6,$0a41
	dc.w	$01a8,$0730,$01aa,$0fd3,$01ac,$0c50,$01ae,$0a41
	dc.w	$01b0,$0e75,$01b2,$0fd3,$01b4,$0c50,$01b6,$0a41
	dc.w	$01b8,$0eb8,$01ba,$0fd3,$01bc,$0c50,$01be,$0a41
;colour and scroll effect for the tube scroller
	dc.w	$9001,$fffe,$0182,$0111,$0184,$0111,$0186,$0111,$0102,$0087
	dc.w	$9101,$fffe,$0182,$0111,$0184,$0222,$0186,$0222,$0102,$0096
	dc.w	$9201,$fffe,$0182,$0222,$0184,$0333,$0186,$0333,$0102,$00a5
	dc.w	$9301,$fffe,$0182,$0222,$0184,$0444,$0186,$0444,$0102,$00a5
	dc.w	$9401,$fffe,$0182,$0333,$0184,$0555,$0186,$0555,$0102,$00b4
	dc.w	$9501,$fffe,$0182,$0333,$0184,$0666,$0186,$0666,$0102,$00b4
	dc.w	$9601,$fffe,$0182,$0444,$0184,$0777,$0186,$0777,$0102,$00c3
	dc.w	$9701,$fffe,$0182,$0444,$0184,$0888,$0186,$0888,$0102,$00c3
	dc.w	$9801,$fffe,$0182,$0555,$0184,$0999,$0186,$0999,$0102,$00c3
	dc.w	$9901,$fffe,$0182,$0555,$0184,$0aaa,$0186,$0aaa,$0102,$00d2
	dc.w	$9a01,$fffe,$0182,$0666,$0184,$0bbb,$0186,$0bbb,$0102,$00d2
	dc.w	$9b01,$fffe,$0182,$0666,$0184,$0ccc,$0186,$0ccc,$0102,$00d2
	dc.w	$9c01,$fffe,$0182,$0777,$0184,$0ddd,$0186,$0ddd,$0102,$00e1
	dc.w	$9d01,$fffe,$0182,$0777,$0184,$0eee,$0186,$0eee,$0102,$00e1
	dc.w	$9e01,$fffe,$0182,$0777,$0184,$0fff,$0186,$0fff,$0102,$00e1
	dc.w	$9f01,$fffe,$0102,$00e1,$0184,$0fff,$0186,$0fff

	dc.w	$a001,$fffe,$0102,$00e1
	dc.w	$a101,$fffe,$0102,$00f0

	dc.w	$b101,$fffe,$0102,$00f0
	dc.w	$b201,$fffe,$0102,$00e1
	dc.w	$b301,$fffe,$0102,$00e1,$0184,$0fff,$0186,$0fff
	dc.w	$b401,$fffe,$0182,$0777,$0184,$0fff,$0186,$0fff,$0102,$00e1
	dc.w	$b501,$fffe,$0182,$0777,$0184,$0eee,$0186,$0eee,$0102,$00e1
	dc.w	$b601,$fffe,$0182,$0777,$0184,$0ddd,$0186,$0ddd,$0102,$00e1
	dc.w	$b701,$fffe,$0182,$0666,$0184,$0ccc,$0186,$0ccc,$0102,$00d2
	dc.w	$b801,$fffe,$0182,$0666,$0184,$0bbb,$0186,$0bbb,$0102,$00d2
	dc.w	$b901,$fffe,$0182,$0555,$0184,$0aaa,$0186,$0aaa,$0102,$00d2
	dc.w	$ba01,$fffe,$0182,$0555,$0184,$0999,$0186,$0999,$0102,$00c3
	dc.w	$bb01,$fffe,$0182,$0444,$0184,$0888,$0186,$0888,$0102,$00c3
	dc.w	$bc01,$fffe,$0182,$0444,$0184,$0777,$0186,$0777,$0102,$00c3
	dc.w	$bd01,$fffe,$0182,$0333,$0184,$0666,$0186,$0666,$0102,$00b4
	dc.w	$be01,$fffe,$0182,$0333,$0184,$0555,$0186,$0555,$0102,$00b4	
	dc.w	$bf01,$fffe,$0182,$0222,$0184,$0444,$0186,$0444,$0102,$00a5
	dc.w	$c001,$fffe,$0182,$0222,$0184,$0333,$0186,$0333,$0102,$00a5
	dc.w	$c101,$fffe,$0182,$0111,$0184,$0222,$0186,$0222,$0102,$0096
	dc.w	$c201,$fffe,$0182,$0111,$0184,$0111,$0186,$0111,$0102,$0087
	dc.w	$c301,$fffe,$0102,$0000

;colour effect for the scrolltext

	dc.w	$e001,$fffe,$0182,$0f70
	dc.w	$e101,$fffe,$0182,$0f60
	dc.w	$e201,$fffe,$0182,$0f50
	dc.w	$e301,$fffe,$0182,$0f40
	dc.w	$e401,$fffe,$0182,$0f30
	dc.w	$e501,$fffe,$0182,$0f20
	dc.w	$e601,$fffe,$0182,$0f10
	dc.w	$e701,$fffe,$0182,$0f00
	dc.w	$e801,$fffe,$0182,$0f10
	dc.w	$e901,$fffe,$0182,$0f20	
	dc.w	$ea01,$fffe,$0182,$0f30
	dc.w	$eb01,$fffe,$0182,$0f40
	dc.w	$ec01,$fffe,$0182,$0f50
	dc.w	$ed01,$fffe,$0182,$0f60
	dc.w	$ee01,$fffe,$0182,$0f70
	dc.w	$ef01,$fffe,$0182,$0f80
	dc.w	$f001,$fffe,$0182,$0f90
	dc.w	$f101,$fffe,$0182,$0fa0
	dc.w	$f201,$fffe,$0182,$0fb0
	dc.w	$f301,$fffe,$0182,$0fc0
	dc.w	$f401,$fffe,$0182,$0fd0
	dc.w	$f501,$fffe,$0182,$0fe0
	dc.w	$f601,$fffe,$0182,$0ff0
	dc.w	$f701,$fffe,$0182,$0fe0
	dc.w	$f801,$fffe,$0182,$0fd0
	dc.w	$f901,$fffe,$0182,$0fc0
	dc.w	$fa01,$fffe,$0182,$0fb0
	dc.w	$fb01,$fffe,$0182,$0fa0
	dc.w	$fc01,$fffe,$0182,$0f90
	dc.w	$fd01,$fffe,$0182,$0f80
	dc.w	$fe01,$fffe,$0182,$0f70
	dc.w	$ff01,$fffe,$0182,$0f60

	dc.w	$ffdf,$fffe
	dc.w	$0001,$fffe,$0182,$0f50
	dc.w	$0101,$fffe,$0182,$0f40
	dc.w	$0201,$fffe,$0182,$0f30
	dc.w	$0301,$fffe,$0182,$0f20
	dc.w	$0401,$fffe,$0182,$0f10
	dc.w	$0501,$fffe,$0182,$0f00
	dc.w	$0601,$fffe,$0182,$0f10
	dc.w	$0701,$fffe,$0182,$0f20
	dc.w	$0801,$fffe,$0182,$0f30
	dc.w	$0901,$fffe,$0182,$0f40
	dc.w	$0a01,$fffe,$0182,$0f50
	dc.w	$0b01,$fffe,$0182,$0f60
	dc.w	$0c01,$fffe,$0182,$0f70
	dc.w	$0d01,$fffe,$0182,$0f80
	dc.w	$0e01,$fffe,$0182,$0f90
	dc.w	$0f01,$fffe,$0182,$0fa0
	dc.w	$1001,$fffe,$0182,$0fb0
	dc.w	$1101,$fffe,$0182,$0fc0
	dc.w	$1201,$fffe,$0182,$0fd0
	dc.w	$1301,$fffe,$0182,$0fe0
	dc.w	$1401,$fffe,$0182,$0ff0
	dc.w	$1501,$fffe,$0182,$0fe0
	dc.w	$1601,$fffe,$0182,$0fd0
	dc.w	$1701,$fffe,$0182,$0fc0
	dc.w	$1801,$fffe,$0182,$0fb0
	dc.w	$1901,$fffe,$0182,$0fa0
	dc.w	$1a01,$fffe,$0182,$0f90
	dc.w	$1b01,$fffe,$0182,$0f80
	dc.w	$1c01,$fffe,$0182,$0f70
	dc.w	$1d01,$fffe,$0180,$0000,$0182,$0000
	dc.w	$2b01,$fffe,$0180,$0000

	dc.w	$0180,$0000

	dc.w	$2c01,$fffe
	dc.w	$0182,$099f
	dc.w	$0100,$0200
	dc.w	$ffff,$fffe
introfont:
	incbin	"introfont"
messy:
	incbin	"roll"
triumphlogo:
	incbin	"triumphlogo"
smeagollogo:
	incbin	"newsmeagol"
warplogo:
	incbin	"warplogo"
questlogo:
	incbin	"questlogo"
;-------------------------------
;!! Screen and scroll buffers !!
;-------------------------------
	section	screen,bss_c
screen:
	ds.b	47104
scrollbuffer:				; I place the scrolltext here
	ds.b	1242
