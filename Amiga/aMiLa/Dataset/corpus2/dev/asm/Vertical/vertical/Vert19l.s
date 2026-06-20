;its not all ok, fine if backnd-bullnd (FIXED)
;backst-backst
;bullst-bullst
;backnd-backnd
;bullnd-bullst
;------------
;-------bullnd


;its all ok now i think!!!!!!
;the reason ou get a flash of cyan every now and then is because
;the last bullet has been used before the last part of the background
;it should be allowed for in the player rtn.
;time to do the player

;okay, i think it all works except for when the line are the same


;MAIN BUG....
;you pillock, you are using the bullet structure directly....
;plonk... you should be using bullsort1 for the addr ptr

;the problem at the mo (the only one i think!)
;is if the bullet adn the background are on the same line it botches.
;to fix this, when same, inc both bull & back (allow for copnd)

;you will notice that the screen panics while you are shooting...
;this is because of the spare copper lines.
;after a bullet is initialised it gets a copper line.
;it does its stuff and then all the rest of the copper commands
;are tagged on the end of that line. leaving one big fuckoff line..
;this annoys the copper so much that he gives up...
;solution:
;at convenient points in the copper list put dummy copperlines
;you can only do this after all the rtns have setup up their lines

;the irq is up and running,
;collision is 4 bitplane (DONE) (FOREGROUND)
;collision is 4 bitplane (*********) (BACKGROUND)


;sussed out why it would return fail when i run it in hi-res mode.
;particularly on oj's..
;its the fucking iff.library. i guess it clrs some reg when it returns
;first time. and there is my proggy deciding that its an error.
;fucking libraries who needs em...
;fixed it by putting a cmp.l #0,d0	after the open.

;moved the system takeover and the irq to after all the files have been 
;loaded and everything else has been setup.

;baddy struct
;for animation have ptrs to frames

;have got to set a flag to tell the other program to check the 
;collisoin at the right time, otherwise it will still check the bullets..


;the only way i can see to get sprite -> foreground collision
;is to read clxdat on an irq.
;the copper complains when i try and write to clxdat (well it is read-only)
;but, what we may be able to do is call lots of irq in the same vblank?
;that way we can have an irq for each bullet collision..... (doubt it)

;still i will have to set up irq for the music anyway, so may as well do it
;now then...

;put keyboard controlls in for player speed (cursor keys)

;writing the player speed bits now..
;got the vars ready, but have not written the coed
;play with counterx and countery (cmp.w #$n,counterx)

;gonna do the horizontal bits now.
;only the top playfield scroll X.
;im gonna do it the lame way first.
;get player xpos
;div by 6
;and make that the x pos of the screen..

;the good way to do it is similar but,
;when the screen moves subtract something from the players xpos
;so that its still correct


;the orange flash!	USE DISABLE/ENABLE but only in scroller..
;		enable for everything else that does not
;		require 100% cert vblanking..
;		i.e. loading screens. title screens etc
;		just to give the system a chance to do whatever...
;it is none of my routines......
;ive removeed all of them and it still does it.
;it may be because of my task priority (at 127)
;but as its system friendly, there may be some system tasks of 127
;or tasks that dont use pri atall.
;could be disk or summink...

;the foreground level width is wrong in one of the sections. DONE
;its cuz its a copy of the background level.
;but where have i fogotten to change!


;debuggin....
;shuffle works
;donesnt crash if movebulls is remmed!
	;if sort is remmed



;bullsort1	;spr 2 dies ;spr 5
	
;spr 1 (10)	spr 1 (10)	spr 1 (10)
;spr 2 (20)	0	spr 5 (50) * WRONG *
;spr 3 (30)	spr 3 (30)	spr 3 (30)
;spr 4 (40)	spr 4 (40)  spr 4 (40)

;when a bullet is killed off.
;move all the bullets below it up one
;and zero the bottom one

;spr 1 (10)	spr 1 (10)	spr 1 (10)
;spr 2 (20)	spr 3 (30)	spr 3 (30) * RIGHT *
;spr 3 (30)	spr 4 (40)	spr 4 (40)
;spr 4 (40)	0	spr 5 (50)


;vert13fc fixed player1 animbug
;origonally oj gave me 16 frames for the ship.
;but that didnt have a middle frame, so sometimes the ship we
;settle on frame7 or 8.
;now we have 15 frames and the settle frame is 8


;have removed all the bullet sort rtns from vert12ahaa
;decided they were not needed,
;because every new player bullet1 is ALWAYS at the lowest position on scr

;doing proper bullet routine for the plaer now.
;starting with autofire

;new mission
;bung the sprite on the screen!
;REMEMBER the sprite data has to be on doublelong boundary!
;for the mo, the sprite is 64x128 but it may change later.

;next mission	DONE
;select pallete 0
;copy background colours in to top half
;copy forground colours in to bottom half
;select pallete 1
;copy sprite colours in


;*********************************************************************
;**********                   The Pallete                   **********
;*********************************************************************

;pallete 0
;1st 16 colours FOREGROUND cols (i.e. clouds etc)
;2nd 16 colours BACKGROUND cols (i.e. ground etc)

;pallete 1
;16 colours	sprites
;fixed the bullet bug now..
;at the mo, the bullets move at 8 pixies (not 16 a decided) cuz i think
;they look better...
;(especially if you have 8 bullets as well)

;OJ, when you draw them just use the bottom 16 colours for each pallete
;the program sorts it all out


;the program is setup for a wider level BUT
;you will have to add a little offset to go_bitplanes to centre it again
;change levwidB to new level width (*4)
;change pagewid if its gonna be different

;max screen scroll speed = 7
;but if you boost it up it will not complain uptil 16
;the only thing is that you start to see the screen
;update at the very bottom of the screen...
;but lets face it, travelling at 16 pixies a vblank
;you are not gonnna worry about a little screen glitch

debugging	equ	0	;0 for normal 1 for debug


nasty	equ	1	;not advisable as it may disrupt keyboard





;edited copperlist to work of A1200
	section screen,code_c		;make sure chip ram
	
	opt	c+

levwidB	equ	20*4	;20 longs backgoound
levhiB	equ	128	;lines
levwidF	equ	24*4	;20 longs foreground
levhiF	equ	256	;lines
pagewid	equ	48 	;bytes
pagehi	equ	528+32	;lines
bitplanes1	equ	4	;dual playfield
bitplanes2	equ	4	;dual playfield
viswid	equ	42	;bytes
vishi	equ	256+16	;lines
vishiw	equ	vishi/16	;words

bull1numF	equ	8	;number of bull1 bullets Front
bull1numB	equ	1	;number of bull1 bullets Back
backmaxB	equ	4	;max number of moving walls back

screensize	equ	pagewid*(pagehi+2)*bitplanes1	;plus 2 because iff library is a bit fucked!

	bra	Start
	
showCOLL	dc.b	0	;show only the collision copperlist
	dc.b	"$VER:Vert19l for Genocide ",0
	cnop	0,4
Start

	move.w	#$8400,$dff096

	
	clr.l	d0
	lea	gfxname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_GfxBase

	clr.l	d0
	lea	iffname,a1
	CALLEXEC	OldOpenLibrary
	cmp.l	#0,d0
	beq	NO_MEMORY
	move.l	d0,_IFFBase

	clr.l	d0
	lea	dosname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_DOSBase

	clr.l	d0
	lea	intname,a1          ;
	moveq	#39,d0                  ; Kickstart 3.0 or higher
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase       ; store intuitionbase


	
	bsr	allocscrbase
	cmp.l	#0,scrbase
	beq	NO_MEMORY	;no memory
	move.l	scrbase,screenF	;forground screen
	move.l	screenF,scrbaseF

	bsr	allocscrbase
	cmp.l	#0,scrbase
	beq	NO_MEMORY	;no memory
	move.l	scrbase,screen1	;background  screen1
	
	bsr	allocscrbase
	cmp.l	#0,scrbase
	beq	NO_MEMORY	;no memory
	move.l	scrbase,screen2	;background screen2

	bsr	allocsprbase

	bsr	loadstuff	;load iff files,colours,char,level etc..

	bsr	convert_gfx
	bsr	convert_level
	
	move.l	LevBase,ScrDat1	;MUST be before any INITIAL level drawing
	move.l	LevBase,ScrDat2	;MUST be before any INITIAL level drawing
	move.l	LevBaseF,ScrDatF	;MUST be before any INITIAL level drawing
	add.l	#(levhiB-vishiw-1)*levwidB,ScrDat1
	add.l	#(levhiB-vishiw-1)*levwidB,ScrDat2

	add.l	#(levhiF-vishiw-1)*levwidF,ScrDatF

	
	
	;display picture 640*528*4
	clr.l	d0
	move.b	scrollspy1,d0
	move.w	#272,scr1ypos
	sub.w	d0,scr1ypos
	move.w	#272,scr2ypos
	move.w	#272/16,scr1yposW
	move.w	#272/16,scr2yposW
	move.w	#15,scrolly1
	sub.w	d0,scrolly1
	move.w	#15,scrolly2

	clr.l	d0
	move.b	scrollspyF,d0
	move.w	#272,scrFypos
	sub.w	d0,scrFypos
	move.w	#272/16,scrFyposW
	move.w	#15,scrollyF
	sub.w	d0,scrollyF

	;display level initially here!!!
	CALLGRAF	OwnBlitter
	bsr	makefore		;make the initial display fore
	bsr	makeback		;make the initial display back
	CALLGRAF	DisownBlitter

	move.b	#2,onscr	;draw on screen2
	bsr	go_bitplanes
	
	
	;select pallete 0
	bsr	go_colour	;setup gfx
	;select pallete 1	
	bsr	go_colour2	;setup spr colours


	move.l	#$dff000,a6
	move.w	joy0dat(a6),oldpos	
	
	;d0 player1 x,ypos initially
	move.w	#160,xpos		;player 1 xpos	
	move.w	#160,ypos		;player 1 ypos	
	;now setup him up in the copper
	clr.l	d0
	move.w	ypos,d0
	ror.l	#8,d0
	or.l	#$0009fffe,d0
	add.l	#$20000000,d0
	move.l	d0,p1copst
	add.l	#$30000000,d0
	move.l	d0,p1copnd




	;fuck with spritedata pos to get it on a dbl long boundary

	;put all 8 sprites onto  dbl boundaries
	move.w	#8-1,d7	
	move.l	#spritedata,d0
	and.l	#%11111111111111111111111111111000,d0	;kill lower bytes
	add.l	#%00000000000000000000000000001000,d0	;go up one
	lea	SprBase0,a0	;poiter to 1st sprite
.loop
	and.l	#%11111111111111111111111111111000,d0	;kill lower bytes
	add.l	#%00000000000000000000000000001000,d0	;go up one

	move.l	d0,(a0)+	;all references to the sprite start here!
	add.l	#(4+4+4+4+(8*(256*2))),d0	;ctrl+ctrl+ctrl+ctrl+128lines of sprite
	
	dbra	d7,.loop
	

	move.l	#1,d0		;frame
	move.l	SprDBase,a1		;data
	bsr	makep1sprdata	
	bsr	makeslist

	move.b	#0,p1reload		;can shoot straight away
	move.b	#5,p1reloadmax	;time to reload

	ifeq debugging
	bsr	vblank
	bsr	vblank
	bsr	vblank
	bsr	vblank
	bsr	GetSystem		
	
	bsr	vblank
	bsr	vblank
	move.l	#new,$dff080
	endc




	bsr	get_old_cop	


	bsr	vblank
	bsr	vblank
	bsr	vblank
	bsr	vblank
	
	MOVE.W #$8010,$dff09a		
 	MOVE.L $6c,oldvec
 	MOVE.L #GenIRQ,$6c		; This sets up a level 3 interrupt



	ifeq	nasty
	CALLEXEC	Disable
	endc
	

main
	move.l	screen1,scrbase	;show screen1
	bsr	go_bitplanes
	ifeq debugging
	bsr	vblank
	endc
	move.l	#colltable,collpos
	bsr	makecollisiontable
	bsr	setupcopper

	;first vblank!	

	move.w	#$008,$dff180	
	bsr	vblankbits

	move.b	#2,onscr
	move.l	screen2,scrbase

	bsr	scrollup2		;scroll background
	bsr	scrollfore
	
	move.w	#$0,$dff180	

	;2nd vblank!

	move.l	screen2,scrbase	;show screen2
	bsr	go_bitplanes

	
	
	ifeq debugging
	bsr	vblank
	endc
	move.l	#colltable,collpos
	bsr	makecollisiontable
	bsr	setupcopper

	move.w	#$008,$dff180	
	bsr	vblankbits

	move.b	#1,onscr
	move.l	screen1,scrbase
	
	bsr	scrollup1		;sscroll background
	bsr	scrollfore		;scroll foreground

	move.w	#$0,$dff180	

	cmp.b	#$67,$bfec01
	bne	.notup
	move.w	#$fff,$dff180
	add.w	#8,p1maxspdy
.loopup
	cmp.b	#$67,$bfec01
	beq	.loopup
.notup

	cmp.b	#$65,$bfec01
	bne	.notdown
	move.w	#$fff,$dff180
	sub.w	#8,p1maxspdy
.loopdown
	cmp.b	#$65,$bfec01
	beq	.loopdown
.notdown

	cmp.b	#$61,$bfec01
	bne	.notleft
	move.w	#$fff,$dff180
	sub.w	#8,p1maxspdx
.loopleft
	cmp.b	#$61,$bfec01
	beq	.loopleft
.notleft
	cmp.b	#$63,$bfec01
	bne	.notright
	move.w	#$fff,$dff180
	add.w	#8,p1maxspdx
.loopright
	cmp.b	#$63,$bfec01
	beq	.loopright
.notright

	
	cmp.b	#$3f,$bfec01
	bne	main
	
	
exit
 	MOVE.L 	oldvec,$6c		; Restore system interrupts
	move	#%1000000000100000,$dff096;enable sprites
	
	ifeq nasty
	CALLEXEC	Enable
	endc
	
	ifeq debugging	
	move.l	old,$dff080	

	bsr	RestSystem

	endc

	move.l	screen1,scrbase		
	bsr	freescrbase
	move.l	screen2,scrbase		
	bsr	freescrbase
	move.l	screenF,scrbase		
	bsr	freescrbase

	bsr	freesprbase

	move.l	CharSize,d0
	move.l	CharBase,a1
	CALLEXEC	FreeMem

	move.l	LevSize,d0
	move.l	LevBase,a1
	CALLEXEC	FreeMem

	move.l	CharSizeF,d0
	move.l	CharBaseF,a1
	CALLEXEC	FreeMem

	move.l	LevSizeF,d0
	move.l	LevBaseF,a1
	CALLEXEC	FreeMem

		
	bsr	CloseLibs
	clr.l	d0


NO_MEMORY	rts

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

	include	initial	;vblank,vblank2,go_colour,allocscrbase,freescrbase,get_old_cop
	include	slyma/setup.i

allocsprbase
	move.l	#$10002,d1	;Mem Requirements
	move.l	#(1024/8)*4*64,d0	;Mem size
	CALLEXEC	AllocMem
	move.l	d0,SprDBase

	move.l	#$10002,d1	;Mem Requirements
	move.l	#(1024/8)*4*16,d0	;Mem size
	CALLEXEC	AllocMem
	move.l	d0,SprBullDBase
	rts
freesprbase
	move.l	#(1024/8)*4*64,d0	;Mem size
	move.l	SprDBase,a1
	CALLEXEC	FreeMem

	move.l	#(1024/8)*4*16,d0	;Mem size
	move.l	SprBullDBase,a1
	CALLEXEC	FreeMem
	rts

	rts
	
go_bitplanes
	clr.l	d1
	move.w	#4-1,d7
	move.l	scrbase,d0

;	if onscr = 1 then add scr2ypos
;	if onscr = 2 then add scr1ypos
	
	cmp.b	#1,onscr
	bne	.nope
	move.w	scr1ypos,d1
	bra	.over
.nope
	move.w	scr2ypos,d1
.over

	add.w	#32,d1	;skip the initial draw top line part
	mulu	#pagewid*bitplanes1,d1
	add.l	d1,d0

	sub.l	#2,d0	
	
	
	lea	bit2h,a0
cloop
	move.w	d0,4(a0)	;bit1l
	swap	d0
	move.w	d0,(a0)	;bit1h
	swap	d0
	add.l	#pagewid,d0	;next bitplane
	add.l	#8,a0	;next copper pos.
	dbra	d7,cloop

;now do the foreground

	clr.l	d1
	move.w	#4-1,d7
	move.l	scrbaseF,d0

	move.w	scrFypos,d1
	
	;************ do smooth scroll ****************
	;scrFxposF

	add.w	#32,d1	;skip the initial draw top line part
	mulu	#pagewid*bitplanes1,d1
	add.l	d1,d0
	
;	add.l	#4,d0
	add.w	scrFxposW,d0	;add coarse scroll
	
	lea	bit1h,a0
cloop2
	move.w	d0,4(a0)	;bit1l
	swap	d0
	move.w	d0,(a0)	;bit1h
	swap	d0
	add.l	#pagewid,d0	;next bitplane
	add.l	#8,a0	;next copper pos.
	dbra	d7,cloop2


	rts

vblankbits


;	bsr	gosprite
	
	move.l	SprBase0,a0
	or.w	#%10000000,2(a0)	;set the attach bit	
	move.w	2(a0),4(a0)
	move.w	#0,6(a0)
	move.w	2(a0),8(a0)
		
	move.l	SprBase1,a1
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)


	bsr	joystick
	
	bsr	inertia

	bsr	movebulls		;move p1 bullet1
	
	;sprite collision	

	;for ALL
	;if onscr=1 then blit on screen1
	;if onscr=2 then blit on screen2
;	bsr	restorebads
;	bsr	grabbads
;	bsr	printbase

;this make the players sprite data. has to updated to allow for the
;players main bullets.
	clr.l	d0
	move.b	p1frame,d0		;frame
	move.l	SprDBase,a1		;data
	bsr	makep1sprdata	


	move.w	#$fff,$dff180


	bsr	p1tofore
	

	rts
	
setupcopper
;	bra	rew

	;these next new lines are a frig to get a backdrop activated.
	lea	backbase,a0
	move.b	#ALIVE,backstatus(a0)
	move.l	#$7009fffe,backcopst(a0)
	move.l	#$8009fffe,backcopnd(a0)

	move.b	#0,backdone
	move.b	#0,bottflag

	bsr	copperp1bull
	
	;do next rtn with player!
	
	bsr	copperplayer1
	
	;now the players behind bullets
	;bsr	copperp1bull2	

;now terminate the clist
	;if ntsc no done
	cmp.b	#1,ntscflag		;have we done the ntsc yet?
	beq	.donent
	move.l	#$ffdffffe,(a0)+
.donent
	cmp.b	#1,bottflag		;have we done the bottom line yet?
	beq	.donebot
	move.l	#$1b09fffe,(a0)+
.donebot	move.w	#bplcon0,(a0)+
	move.w	#$0200,(a0)+	;kill off very bottom line (ill put it back in if oj complains!)

	move.l	#$fffffffe,(a0)+

	rts
	

copperplayer1
	;ok, this is difficult
	;we have to check the player with ntsc 
	;and the background
	
	;from other rtn
	;A0 = clist
	;A2 = backbase (not a start anymore!)
	;D2 = backbase line (d1 = bullet not required)
	;D7 = backbase loop
	
	;also backnd may be set...
	move.l	p1copst,a1
	move.l	backcopst(a2),d2
	cmp.b	#1,backnd
	bne	.ok
	move.l	backcopnd(a2),d2
.ok
	
	cmp.b	#0,backdone
	bne	.done
	
	move.b	#0,p1nd
	
	;find out which is lower back or player!
.loop
	move.l	a1,d1

	bsr	findbackline	;this will find the next available back
	cmp.l	#1,d0
	beq	.done


	cmp.l	d1,d2
	bne	.notsame
	;they are both on the same line.....
	;do something silly!
	
	;check ntsc	
	
	
	bra	.over
.notsame
	bcc	.p1lower
	;the background is lower
	move.l	d2,(a0)+
	move.l	#$01800fff,(a0)+
	;put a check in here for ntsc
	
	;are we on the backnd
	move.b	#0,backnd
	cmp.l	backcopnd(a2),d2
	beq	.sameback
	move.l	backcopnd(a2),d2
	move.b	#1,backnd	;set flag to say im doinf the cop nd
	bra	.loop

.sameback
	move.l	#$01800000,-4(a0)
	add.l	#(backstruct_nd-backstruct),a2
	dbra	d7,.loop
	move.b	#1,backdone
	bra	.done

	
	bra	.over
.p1lower
	;player1 is lower
	move.l	a1,(a0)+
;	move.l	#$018000f0,(a0)+
;	dc.w	intreq,$8010
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+
	
	;put a check in here for ntsc
	cmp.l	p1copst,a1
	bne	.doneall	;done all player
	move.l	p1copnd,a1
	bra	.loop
	
.over
	
.done	;done all the backdrop. do the rest of player (with ntsc)
	
	;do rest of player
	cmp.l	p1copst,a1
	bne	.justend
	;do the start of player!

	move.l	a1,d0
	bsr	checkntsc
	;if ntsc returns a 1 in d0 then your on the pal border..
	;put the ffdf line at the end of yours!!
	
	move.l	a1,(a0)+
;	move.l	#$018000f0,(a0)+
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+

	;check ntsc
	move.l	p1copnd,a1
.justend	
	cmp.l	p1copnd,a1
	bne	.doneall

	move.l	a1,d0	
	bsr	checkntsc
	;if ntsc returns a 1 in d0 then your on the pal border..
	;put the ffdf line at the end of yours!!

	;if ntsc=1 and line > 1b09fffe then line=1b09fffe
	cmp.b	#1,ntscflag
	bne	.nontsc
	cmp.l	#$1b09fffe,a1
	ble	.nontsc
	move.l	#$1b09fffe,a1
	move.b	#1,bottflag		;reached bottom of copper
.nontsc
	
	move.l	a1,(a0)+
;	move.l	#$01800000,(a0)+
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+

	;check ntsc
.doneall
	rts
	
	
checkntsc
	;for it to be over the ntsc the cline has to be under 4809
	cmp.b	#1,ntscflag
	beq	.donentsc
	cmp.l	#$ff09fffe,d0
	bne	.ok
	;on pal border
	move.l	#1,d0
	rts
.ok
	;the players forward bullets do not cross the pal border....
	sub.l	#$4809fffe,d0
;	cmp.l	#$4809fffe,d0
;	bgt	.donentsc
	bcc	.donentsc
	move.l	#$ffdffffe,(a0)+
	move.b	#1,ntscflag
.donentsc
	move.l	#0,d0
	
	rts

copperp1bull
	;can do a cheat here, because the players bullets
	;do no go anywhere near the copper!
	;main loop until backstruct is empty
	move.l	#backmaxB-1,d7
	lea	float,a0

	move.b	#0,backdone
	move.b	#0,bullnd
	move.b	#0,backnd
	
	lea	bullsort1,a4
	
	lea	backbase,a2
	move.b	#0,ntscflag
	move.l	#bull1numF-1,d6

.loop	;loop until bullet struct is empty

	cmp.l	#0,(a4)	;is sort empty?
	beq	.donebullnd
	move.l	(a4),a1
	
	;this loop bullets&back&ntsc

	bsr	findbackline	;this will find the next available back
	cmp.l	#1,d0
	beq	.noback

	;okay there is a bullet & a background. (and a ntsc)
	;if bullnd=1 then dont get bullet
	cmp.b	#1,bullnd
	beq	.nogetbull
	move.l	bull1copst(a1),d1
.nogetbull
	;if backnd=1 then dont get back
	cmp.b	#1,backnd
	beq	.nogetback
	move.l	backcopst(a2),d2	
.nogetback
.check	
	cmp.l	d1,d2
	bne	.notsame
	;fuck, they are on the same line....
	;do back first!
	move.l	d2,(a0)+
	move.l	#$018000ff,(a0)+
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+
	
	;if bullnd = d1 the bra .donebullnd2

	move.b	#0,bullnd
	cmp.l	bull1copnd(a1),d1
	beq	.samebull
	move.l	bull1copnd(a1),d1
	move.b	#1,bullnd
	bra	.bullon	
	
.samebull	
	add.l	#4,a4
	cmp.l	#0,(a4)	;is sort empty?
	bne	.ok
	dbra	d6,.samebull
	;run out a bullets
	bra	.nobullets
		
.ok	move.l	(a4),a1
	
	dbra	d6,.bullon
	bra	.nobullets
.bullon
	;if backnd = d2 then bra .doneback2 

	move.b	#0,backnd
	cmp.l	backcopnd(a2),d2
	beq	.sameback
	move.l	backcopnd(a2),d2
	move.b	#1,backnd	;set flag to say im doinf the cop nd
	bra	.backon

.sameback
	add.l	#(backstruct_nd-backstruct),a2
	dbra	d7,.backon
	move.b	#1,backdone
	bra	.done
.backon
	
	bra	.loop
.notsame
	bcs	.doback
	;bullet is first in line
	;do bullet
	move.l	d1,(a0)+	;copy copper line
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+
;	move.l	#$0180088f,(a0)+	;change colour

	;now check with everything again, to see if we can
	;just copy in bull1copnd(a1)
	;to check the rtn again setup d1 with copnd
	;and bra upto check
	
	move.b	#0,bullnd
	cmp.l	bull1copnd(a1),d1
	beq	.donebullnd2
	move.l	bull1copnd(a1),d1
	move.b	#1,bullnd	;set flag to say im doing the cop nd
	bra	.check



.donebullnd2
;	move.l	#$01800000,-4(a0)
.donebullnd
	move.b	#0,bullnd
	add.l	#4,a4
	dbra	d6,.loop
	bra	.nobullets
	


.doback
	;backdrop is first in line
	;do backdrop
	move.l	d2,(a0)+
	move.l	#$01800fff,(a0)+

	;to check the rtn again setup d2 with copnd
	;and bra upto check
	
	move.b	#0,backnd
	cmp.l	backcopnd(a2),d2
	beq	.donebacknd2
	move.l	backcopnd(a2),d2
	move.b	#1,backnd	;set flag to say im doinf the cop nd
	bra	.check

.donebacknd2	
	move.l	#$01800000,-4(a0)
.donebacknd	
	add.l	#(backstruct_nd-backstruct),a2
	dbra	d7,.loop
	move.b	#1,backdone
	
	bra	.done
.done
	
	
	
.noback
	;if bullnd=1 then we just have to do the last part of this bullet.
	cmp.b	#1,bullnd
	bne	.noback2
	move.b	#0,bullnd
	move.l	bull1copnd(a1),(a0)+
;	move.l	#$01800000,(a0)+
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+
	bra	.next
	

.noback2	
	cmp.l	#0,a4
	beq	.next
	move.l	(a4),a1
	cmp.b	#ALIVE,bull1status(a1)
	bne	.next

	;if there are no backgrounds then just do the bullets
	;(if there were no bullets rtn would goto .nobullets)
	move.l	bull1copst(a1),(a0)+	;copy copper line
;	move.l	#$0180088f,(a0)+	;change colour
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+

	move.l	bull1copnd(a1),(a0)+
;	move.l	#$01800000,(a0)+
	move.w	#intreq,(a0)+	;gimme an irq
	move.w	#$8010,(a0)+


.next	;next bullet please
	add.l	#4,a4
	dbra	d6,.noback2


.nobullets

	rts
	
findbackline
	move.l	#1,d0		;set to fail unless!
	cmp.b	#1,backdone
	beq	.out
	cmp.b	#ALIVE,backstatus(a2)
	bne	.notyet
	move.l	#0,d0
	rts
.notyet	add.l	#(backstruct_nd-backstruct),a2
	dbra	d7,findbackline
	move.b	#1,backdone



.out	rts

rew
	rts
	;best to clear clist first (hmm)
	;make a copper task list
	;go through all the bullets,player etc
	;and decide which order everything should go into the copper
	
	;the basic copper list is this
	
	;player bull
	;player bull
	;player bull
	;player bull
	;player bull
	;player bull
	;player 1
	;player bull
	;player bull
	
	;but in here some where, we have to allocate ntsc and background
	
;	for t = 0 to list above
;		if ntsc flag =1 & line > ntsc then put ntsc line in clr ntsc flag
;		if back1st flag = 1 & line > back1st put line in clr back1st flag
;		if back1nd flag = 1 & line > back1nd put line in clr back1nd flag
;		if back2st flag = 1 & line > back2st put line in clr back2st flag
;		if back2nd flag = 1 & line > back2nd put line in clr back2nd flag
;	nextt
;	
	;this rtn is run every vblank.
	;it puts the player, players bullets, ntsc line,  background scrolling
	;all into the copper list.	

	;setup players position in the copper!
COOL	clr.l	d0
	move.w	ypos,d0
	ror.l	#8,d0
	or.l	#$0009fffe,d0
	add.l	#$20000000,d0
	move.l	d0,p1strt
	add.l	#$30000000,d0
	move.l	d0,p1end


	lea	float,a0		;copper list
	move.l	p1copst,(a0)+
	move.w	#intreq,(a0)+
	move.w	#$8010,(a0)+
	
	
	move.l	p1copnd,(a0)+
	move.w	#intreq,(a0)+
	move.w	#$8010,(a0)+
		
	rts
	
p1tofore
	move.b	p1collision,d0			;clxdat
	and.b	#%00000010,d0
	beq	.ok
	move.w	#$f00,$dff180
	bra	.out
.ok
	move.w	#0,$dff180
	
.out	rts


inertia
	cmp.l	#0,counterx	
	beq	.over
	clr.l	d0
	move.w	p1maxspdx,d0	
	
	cmp.l	counterx,d0	;to change speed
	bgt	.stillow2		;play with these
	move.l	d0,counterx
.stillow2

	sub.l	#4,counterx	;increase this to give better inertia 4-7 best
	cmp.l	#0,counterx
	bgt	.ok
	;counter has gone beloq 0 so make it 0
	move.l	#0,counterx
.ok

	move.l	counterx,d0
	asr.l	#3,d0
	blt	.over
	;should have a small no.
	cmp.w	#7,d0
	blt	.good
	move.w	#7,d0
.good
	move.l	#8,d1	;this sets the players frame for LEFT
	sub.l	d0,d1
	sub.b	#1,d1
	move.b	d1,p1frame	

	;if over 7 make 7
	;if going left
	btst	#BOBB_LEFT,p1dir
	beq	.notleft
	sub.w	d0,xpos
	;do check for left off of screen
	cmp.w	#0,xpos
	bgt	.onscr
	;if off the screen
	move.w	#0,xpos
	bra	.notleft
.onscr
	
	;do foreground scroll
	sub.w	d0,scrFxposC
	cmp.w	#0,scrFxposC
	bgt	.higher
	;its gone under 6
	add.w	#6,scrFxposC
	;do smooth
	cmp.w	#$0f,scroll
	bne	.cool
	move.w	#0,scroll
	sub.w	#2,scrFxposW
	bra	.on
.cool	add.w	#$01,scroll
.on
	
.higher

.notleft
	btst	#BOBB_RIGHT,p1dir
	beq	.notright
	add.w	d0,xpos

;	move.l	#8,d1	;this sets the players frame for LEFT
;	sub.l	d0,d1
	move.b	d0,p1frame	
	add.b	#7,p1frame

	;do check for far right of screen
	cmp.w	#320,xpos
	blt	.onscr2
	;if off the screen
	move.w	#320,xpos
	bra	.notright
.onscr2
	
	;do foreground scroll
	add.w	d0,scrFxposC
.loop	cmp.w	#6,scrFxposC
	blt	.lower
	;its gone over 6
	sub.w	#6,scrFxposC
	;do smooth
	cmp.w	#$00,scroll
	bne	.cool2
	move.w	#$f,scroll
	add.w	#2,scrFxposW
	bra	.on2
.cool2	sub.w	#$01,scroll
	bra	.loop
.on2
	
.lower

.notright
.over

	cmp.l	#0,countery
	beq	.over2
	
	clr.l	d0
	move.w	p1maxspdy,d0	

	cmp.l	countery,d0
	bge	.stillow
	move.l	d0,countery
.stillow
	sub.l	#4,countery	;increase this to give better inertia 4-7 best
	cmp.l	#0,countery
	bgt	.ok2
	;counter has gone beloq 0 so make it 0
	move.l	#0,countery
.ok2

	move.l	countery,d0
	asr.l	#3,d0
	blt	.over2
	;should have a small no.
	cmp.w	#7,d0
	blt	.good2
	move.w	#7,d0
.good2
	;if over 7 make 7
	;if going UP
	btst	#BOBB_UP,p1dir
	beq	.notup
	sub.w	d0,ypos
	move.l	d0,d1
	ror.l	#8,d1
	sub.l	d1,p1copst
	sub.l	d1,p1copnd
	
	
	cmp.w	#40,ypos
	bgt	.okup
	move.w	#40,ypos
	move.l	#$4809fffe,p1copst
	move.l	#$7809fffe,p1copnd
	
	
.okup


	
.notup
	btst	#BOBB_DOWN,p1dir
	beq	.notdown
	add.w	d0,ypos
	move.l	d0,d1
	ror.l	#8,d1
	add.l	d1,p1copst
	add.l	d1,p1copnd

	cmp.w	#220,ypos
	blt	.okdown
	move.w	#220,ypos
	move.l	#$fc09fffe,p1copst
	move.l	#$2c09fffe,p1copnd
.okdown


.notdown
.over2

	rts	

movebulls
	move.l	#bull1numF-1,d7
	lea	bull1base,a3
.loop
	cmp.b	#ALIVE,bull1status(a3)
	bne	.dead
	
	;were alive at the mo, but are we dead really
	;and havent noticed??
	
	clr.l	d0
	move.b	bull1coll(a3),d0
	and.b	#%10,d0
	bne	.kill	;were dead!!!! kill it off
	
	
	clr.l	d1
	move.b	bull1speed(a3),d1
	sub.w	d1,bull1ypos(a3)
	bgt	.onscr
	;sprite has left the building.
.kill	;kill it off good and proper
	move.b	#DEAD,bull1status(a3)
	;find place in sortbuffer and delete it!
	lea	bullsort1,a4
.lo
	cmp.l	(a4),a3
	beq	.here	;found place to remove
	add.l	#4,a4
	bra	.lo
.here
	move.l	#0,(a4)
	bsr	shufflebull	;get 0 at the bottom!
	bra	.dead
.onscr
	ror.l	#8,d1
	sub.l	d1,bull1copst(a3)
	sub.l	d1,bull1copnd(a3)
	
	
	
.dead
	add.l	#(bull1struct_nd-bull1struct),a3
	dbra	d7,.loop
		
	rts
	
	

loadstuff
	lea	colnamegfxb,a0	;load in the gfx colours! background
	move.l	a0,FileName	
	bsr	loadcolours
	;copy the gfx colours to 16-32 of background pallete
	lea	colours,a0
	lea	pallete0,a1
	add.l	#16*2,a1	;get to last 16 cols	
	move.w	#16-1,d7
.col1	move.w	(a0)+,(a1)+
	dbra	d7,.col1
 
	lea	colnamegfxf,a0	;load in the gfx colours! forground
	move.l	a0,FileName	
	bsr	loadcolours
	;copy the gfx colours to 0-16 of forground pallete
	lea	colours,a0
	lea	pallete0,a1
	move.w	#16-1,d7
.col2	move.w	(a0)+,(a1)+
	dbra	d7,.col2

	lea	colnamespr,a0	;load in the spr colours!
	move.l	a0,FileName	
	bsr	loadcolourIFF
	;copy the spr colours to 0-16 of forground pallete
	lea	colours,a0
	lea	pallete1,a1
	move.w	#16-1,d7
.col3	move.w	(a0)+,(a1)+
	dbra	d7,.col3
	

	lea	charnameb,a0
	move.l	a0,FileName
	bsr	loadfilechip
	move.l	FileSize,CharSize
	move.l	FileBase,CharBase

	lea	charnamef,a0
	move.l	a0,FileName
	bsr	loadfilechip
	move.l	FileSize,CharSizeF
	move.l	FileBase,CharBaseF

	lea	levname,a0
	move.l	a0,FileName
	bsr	loadfilefast
	move.l	FileSize,LevSize
	move.l	FileBase,LevBase

	lea	levnamef,a0
	move.l	a0,FileName
	bsr	loadfilefast
	move.l	FileSize,LevSizeF
	move.l	FileBase,LevBaseF

	lea	player1,a0		;players sprite iff
	bsr	loadsprite
	
	lea	player1spr,a0
	bsr	loadsprbullets
	
	rts

loadsprite
	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#4,d0		;sprite are 16 cols 4 plane
	move.l	#1024*4,d1		;width in pixies *4 for interleaved
	move.l	#64,d2		;height in pixies
	CALLGRAF	InitBitMap

	;now copy the pointer into the bitmap structure
	move.l	#4-1,d7
	move.l	SprDBase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#1024/8,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	
	rts

loadcolourIFF

LoadCmap
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle

	move.l	iffhandle,a1		;iff handle ??
	lea	colours,a0
	CALLIFF	GetColorTab

	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	

	rts



	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#4,d0		;sprite are 16 cols 4 plane
	move.l	#1024*4,d1		;width in pixies *4 for interleaved
	move.l	#64,d2		;height in pixies
	CALLGRAF	InitBitMap

	;now copy the pointer into the bitmap structure
	move.l	#4-1,d7
	move.l	SprDBase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#1024/8,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	

	rts

loadsprbullets
	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#4,d0		;sprite are 16 cols 4 plane
	move.l	#1024*4,d1		;width in pixies *4 for interleaved
	move.l	#16,d2		;height in pixies
	CALLGRAF	InitBitMap

	;now copy the pointer into the bitmap structure
	move.l	#4-1,d7
	move.l	SprBullDBase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#1024/8,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	
	rts
	
makeslist
	move.l	SprBase0,d0		;pointer to sprite data list
	move.w	d0,spr0l
	swap	d0
	move.w	d0,spr0h
	move.l	SprBase1,d0		;pointer to sprite data list
	move.w	d0,spr1l
	swap	d0
	move.w	d0,spr1h


	move.l	#dead,d0	;pointer to sprite data list
	move.w	d0,spr2l
	move.w	d0,spr3l
	move.w	d0,spr4l
	move.w	d0,spr5l
	move.w	d0,spr6l
	move.w	d0,spr7l
	swap	d0
	move.w	d0,spr2h
	move.w	d0,spr3h
	move.w	d0,spr4h
	move.w	d0,spr5h
	move.w	d0,spr6h
	move.w	d0,spr7h


	rts


makep1sprdata
	;make player1 sprite
	
	move.l	SprBase0,a0	;sprite 0
	move.l	SprBase1,a2	;sprite 1
	
	
	lea	bull1base,a3
	move.l	#bull1numF-1,d6
	lea	bullsort1,a4
.bull
	cmp.l	#0,(a4)	;is sort empty?
	beq	.bulldead
	move.l	(a4),a3
	
	cmp.b	#ALIVE,bull1status(a3)
	bne	.bulldead
	;cool, its an alive one.
	clr.l	d7
	move.b	bull1hi(a3),d7
	
	
	clr.l	d0
	clr.l	d1
	
	move.w	bull1xpos(a3),d0		;x pos
	add.w	#94,d0	;frig
	move.w	bull1ypos(a3),d1		;y pos	;okay
	add.w	#26,d1	;frig
	move.l	d7,d2		;height of sprite (poetry!)
	bsr	gospr2

	or.w	#%10000000,2(a0)	;set the attach bit	
	move.w	2(a0),4(a0)
	move.w	#0,6(a0)
	move.w	2(a0),8(a0)
		
	move.l	(a0),(a2)
	move.l	4(a0),4(a2)
	move.l	8(a0),8(a2)
	move.l	12(a0),12(a2)


	sub.b	#1,d7

	move.l	SprBullDBase,a1		;data	FRIG
	bsr	sprgfk
	
.bulldead
	add.l	#4,a4
	dbra	d6,.bull
	
	
	
	
	

	clr.l	d0
	clr.l	d1
	
	move.w	xpos,d0		;x pos
	add.w	#94,d0	;frig
	move.w	ypos,d1		;y pos	;okay
	add.w	#30,d1	;frig
	move.l	#64-1,d2		;height of sprite (poetry!)
	bsr	gospr2

	or.w	#%10000000,2(a0)	;set the attach bit	
	move.w	2(a0),4(a0)
	move.w	#0,6(a0)
	move.w	2(a0),8(a0)
		
	move.l	(a0),(a2)
	move.l	4(a0),4(a2)
	move.l	8(a0),8(a2)
	move.l	12(a0),12(a2)

	clr.l	d0
	move.b	p1frame,d0		;frame
	move.l	SprDBase,a1		;data

	rol.l	#3,d0
	add.l	d0,a1

	move.l	#64-1,d7

sprgfk	

;	move.l	#16-1,d7

	add.l	#4*4,a0	;skip control words!
	add.l	#4*4,a2	;skip control words!
	
.loop
	move.l	(a1),(a0)+	;do sprite 0
	move.l	4(a1),(a0)+
	move.l	128(a1),(a0)+
	move.l	128+4(a1),(a0)+
	
	move.l	256(a1),(a2)+
	move.l	256+4(a1),(a2)+
	move.l	384(a1),(a2)+
	move.l	384+4(a1),(a2)+

	add.l	#128*4,a1
	dbra	d7,.loop
	
;	move.l	#0,(a0)
;	move.l	#0,4(a0)
;	move.l	#0,(a2)
;	move.l	#0,4(a2)


	rts


gospr2
	
;	add.w	#$60,d0		;FRIG X Just a little


	move.l	#0,(a0)		;kill Controll words
	move.l	#0,4(a0)		;kill Controll words
	move.l	#0,8(a0)		;kill Controll words
	move.l	#0,12(a0)		;kill Controll words

	move.w	d0,d3		;copy d0 (x0)
	 
	and.w	#%1,d3		;kill all but Lowest bit
	move.w	d3,2(a0)	;DONE H0			*

	and.w	#%1111111111111110,d0
	ror.w	#1,d0
	move.w	d0,(a0)		;DONE H1-H8			*

	move.w	d1,d3
	and.w	#%0000000100000000,d3	;kill all but E8
	ror.w	#6,d3
	or.w	d3,2(a0)	;DONE E8			*

	move.w	d1,d3
	and.w	#%1111111011111111,d3	;Kill E8 Bit
	rol.w	#8,d3		;Shift Im lieft
	or.w	d3,(a0)		;DONE E0-E7			*

	add.w	d2,d1		;add height
	move.w	d1,d3
	and.w	#%0000000100000000,d3	;Kill all but L8
	ror.w	#7,d3
	or.w	d3,2(a0)	;DONE L8			*	

	move.w	d1,d3
	and.w	#%1111111011111111,d3	;Kill L8 Bit
	rol.w	#8,d3		;Shift Im lieft
	bset	#7,d3		;attach bit
	or.w	d3,2(a0)	;DONE L0-L7			*
	rts		

	
loadfilefast
	move.l	FileName,d1	;filename
	move.l	#MODE_OLDFILE,d2	;mode read
	CALLDOS	Open
	move.l	d0,Handle
	
	move.l	FileName,d1	;filename
	move.l	#ACCESS_READ,d2
	CALLDOS	Lock
	move.l	d0,LockFile
	
	move.l	LockFile,d1
	move.l	#FileInfo,d2
	CALLDOS	Examine
	
	lea	FileInfo,a0
	move.l	fib_Size(a0),FileSize	;get size please

	clr.l	d0		;allocate some memory for it!
	move.l	FileSize,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,FileBase

	move.l	Handle,d1		;filename
	move.l	FileBase,d2		;pos in mem
	move.l	FileSize,d3		;size
	CALLDOS	Read

	move.l	LockFile,d1
	CALLDOS	UnLock

	move.l	Handle,d1	;filename
	CALLDOS	Close
	rts

loadfilechip
	move.l	FileName,d1	;filename
	move.l	#MODE_OLDFILE,d2	;mode read
	CALLDOS	Open
	move.l	d0,Handle
	
	move.l	FileName,d1	;filename
	move.l	#ACCESS_READ,d2
	CALLDOS	Lock
	move.l	d0,LockFile
	
	move.l	LockFile,d1
	move.l	#FileInfo,d2
	CALLDOS	Examine
	
	lea	FileInfo,a0
	move.l	fib_Size(a0),FileSize	;get size please

	clr.l	d0		;allocate some memory for it!
	move.l	FileSize,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,FileBase

	move.l	Handle,d1		;filename
	move.l	FileBase,d2		;pos in mem
	move.l	FileSize,d3		;size
	CALLDOS	Read

	move.l	LockFile,d1
	CALLDOS	UnLock

	move.l	Handle,d1	;filename
	CALLDOS	Close
	rts

loadcolours
	;this loads an iff file with the cmap in it!!!!
	move.l	FileName,d1	;filename
	move.l	#MODE_OLDFILE,d2	;mode read
	CALLDOS	Open
	move.l	d0,Handle
	
	move.l	FileName,d1	;filename
	move.l	#ACCESS_READ,d2
	CALLDOS	Lock
	move.l	d0,LockFile
	
	move.l	Handle,d1		;filename
	move.l	#colours,d2		;pos in mem
	move.l	#64,d3		;size
	CALLDOS	Read

	move.l	LockFile,d1
	CALLDOS	UnLock

	move.l	Handle,d1	;filename
	CALLDOS	Close

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

	;now check for fire button
	btst	#7,$bfe001		;PRA (6 for the other port)
	bne	.loop
;	move.w	#$0f00,$dff180
	bset	#BOBB_SHOOT,d0	;hey i hit the button

.loop
	move.b	d0,p1joy

	;if p1 joystick is left then go left young man!
	clr.l	d0
	move.w	p1joy,d0
	btst	#BOBB_LEFT,p1joy
	beq	.noleft
	;ok, hes pushing left

	btst	#BOBB_RIGHT,p1dir
	beq	.notright
	;if ship is going right then
		sub.l	#8,counterx
		bgt	.noleft
		bclr	#BOBB_RIGHT,p1dir	;clear the right bit (p1dir)
		bset	#BOBB_LEFT,p1dir	;set the left bit (p1dir)
		bra	.noleft
.notright
	;if ship is going left then
	bclr	#BOBB_RIGHT,p1dir
	bset	#BOBB_LEFT,p1dir
	
		add.l	#8,counterx
.noleft



	;if p1 joystick is right then go right young man or woman!
	clr.l	d0
	move.w	p1joy,d0
	btst	#BOBB_RIGHT,p1joy
	beq	.noright
	;ok, hes pushing right

	btst	#BOBB_LEFT,p1dir
	beq	.notleft
	;if ship is going left then
		sub.l	#8,counterx
		bgt	.noright
		bclr	#BOBB_LEFT,p1dir	;clr the left bit (p1dir)
		bset	#BOBB_RIGHT,p1dir	;set the right bit (p1dir)
		bra	.noright
.notleft
	;if ship is going right then
	bclr	#BOBB_LEFT,p1dir
	bset	#BOBB_RIGHT,p1dir
	
		add.l	#8,counterx
.noright


	;if p1 joystick is up then go up young man!
	clr.l	d0
	move.w	p1joy,d0
	btst	#BOBB_UP,p1joy
	beq	.noup
	;ok, hes pushing up

	btst	#BOBB_DOWN,p1dir
	beq	.notdown
	;if ship is going down then
		sub.l	#7,countery
		bgt	.noup
		bclr	#BOBB_DOWN,p1dir	;clear the down bit (p1dir)
		bset	#BOBB_UP,p1dir	;set the up bit (p1dir)
		bra	.noup
.notdown
	;if ship is going down then
	bclr	#BOBB_DOWN,p1dir
	bset	#BOBB_UP,p1dir
	
		add.l	#7,countery
.noup

	;if p1 joystick is down then go down young man!
	clr.l	d0
	move.w	p1joy,d0
	btst	#BOBB_DOWN,p1joy
	beq	.nodown
	;ok, hes pushing down

	btst	#BOBB_UP,p1dir
	beq	.notup
	;if ship is going up then
		sub.l	#7,countery
		bgt	.nodown
		bclr	#BOBB_UP,p1dir	;set the up bit (p1dir)
		bset	#BOBB_DOWN,p1dir	;clear the down bit (p1dir)
		bra	.nodown
.notup
	;if ship is going down then
	bclr	#BOBB_UP,p1dir
	bset	#BOBB_DOWN,p1dir
	
		add.l	#7,countery
.nodown

	;count down p1reload until its 0
	cmp.b	#0,p1reload
	beq	.reloaded
	sub.b	#1,p1reload
.reloaded
	
JOHN	


	;if player1 has pressed the fire butto then do this
	
	clr.l	d0
	btst	#BOBB_SHOOT,p1joy
	beq	.nofire
	cmp.b	#0,p1reload
	bne	.nofire	;not ready to shoot yet	
	move.b	p1reloadmax,p1reload
;	move.w	#$f00,$dff180
	
	bsr	findfreebull	;check to see if we have a free bullet
	cmp.b	#0,d0
	bne	.nofire		;no free bullets!!!
	
	bsr	initbull		;initialise the new bullet
	bsr	shufflebull		;shuffle the bullsort1 to make the new bullet the last one

	;a3 has the sprite struct to put in sort buffer
	lea	bullsort1,a0
	move.l	#((bull1numF-1)*4),d0
	move.l	a3,(a0,d0)

	
.nofire

	rts

findfreebull
	move.l	#bull1numF-1,d7
	lea	bull1base,a3
.looking
	cmp.b	#ALIVE,bull1status(a3)
	bne	.gotone
	add.l	#(bull1struct_nd-bull1struct),a3
	dbra	d7,.looking
	;couldnt find a free one
	move.l	#1,d0	;failed
	rts
.gotone
	clr.l	d0	;passed
	rts

initbull
	move.w	xpos,bull1xpos(a3)
	move.w	ypos,bull1ypos(a3)
	move.b	#16,bull1hi(a3)
	clr.l	d0
	move.b	bull1hi(a3),d0
	sub.w	#8,d0
	sub.w	d0,bull1ypos(a3)
	move.b	#8,bull1speed(a3)
	move.b	#ALIVE,bull1status(a3)
	move.b	#0,bull1coll(a3)	

	;setup its copper line
	clr.l	d0
	move.w	bull1ypos(a3),d0
	ror.l	#8,d0
	or.l	#$0009fffe,d0
	add.l	#$20000000,d0
	move.l	d0,bull1copst(a3)
	add.l	#$08000000,d0	;* add height *
	move.l	d0,bull1copnd(a3)


	rts
shufflebull	
	
	;are there any spaces?
	
	;0	0	0	spr1
	;0	0	spr1	0
	;0	spr1	0	0
	;spr1	0	0	0


	lea	bullsort1,a0
	move.l	#bull1numF-1,d6
.loop2
	cmp.l	#0,(a0)
	bne	.notzero
	;itsa zero
	move.l	4(a0),d0
	move.l	(a0),4(a0)
	move.l	d0,(a0)
.notzero
	add.l	#4,a0
	dbra	d6,.loop2


	

	rts


scrollup1
	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#pagewid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$09f0,$dff040

	;do smooth scroll..
	
	clr.l	d0
	move.b	scrollspy1,d0
	
	sub.w 	d0,scr1ypos		;spped
	sub.w 	d0,scr1ypos		;done twice because the other screen does half the scrolling
	sub.w	d0,scrolly1		;speed
	sub.w	d0,scrolly1		;
	cmp.w	#0,scrolly1
	bge	.doit

	;weve moved over a word
	add.w	#16,scrolly1
	sub.l	#1*levwidB,ScrDat1
	
	sub.w	#1,scr1yposW
	cmp.w	#0,scr1yposW
	bge	.ok
	
	
	;shit, were at the top of the screen!
	add.w	#vishiw,scr1yposW
	add.w	#vishi,scr1ypos
	
.ok

	move.b	#0,scroll1cnt

.doit
	;if scroll1cnt=0 then init the line
	;if scroll1cnt=ff then weve done all the blitting!
	;if its neither then blit 2(3) words until =10(5)
	
	;set up the pointers to blit

	cmp.b	#0,scroll1cnt
	bne	.noinit
		
	clr.l	d0
	clr.l	d1
	move.l	screen1,a1
	move.l	screen1,a3
	move.l	ScrDat1,a0
	move.w	scr1yposW,d0
	move.w	scr1yposW,d1
	
	add.l	#vishiw,d1		;do bottom of page too!
	mulu	#bitplanes1*pagewid*16,d0
	mulu	#bitplanes1*pagewid*16,d1
	add.l	d0,a1
	add.l	d1,a3

	move.l	a1,scrollpos1a
	move.l	a3,scrollpos1b
	move.l	a0,scrolldat1



.noinit
	cmp.b	#$ff,scroll1cnt
	beq	.out
	
	;ok, its a normal blit 2(3) words
	add.b	#1,scroll1cnt
	cmp.b	#8,scroll1cnt	(5)
	bne	.onwards
	move.b	#$ff,scroll1cnt
	bra	.out

.onwards
;	do a loop blitting

	move.l	scrolldat1,a0
	move.l	scrollpos1a,a1
	move.l	scrollpos1b,a3

	move	#3-1,d7
.loop1
	CALLGRAF	WaitBlit

	clr.l	d0

	move.w	2(a0),d0
	move.l	CharBase,a2
	add.l	d0,a2

	move.l	a2,$dff050	;A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058

	CALLGRAF	WaitBlit
	
	move.l	a2,$dff050	;A
	move.l	a3,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058
	
	add.l	#4,a0		;next level pos please
	add.l	#2,a1		;next s creen pos please
	add.l	#2,a3
	dbra	d7,.loop1

	move.l	a1,scrollpos1a
	move.l	a3,scrollpos1b
	move.l	a0,scrolldat1


.out	rts

scrollup2
	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#pagewid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$09f0,$dff040

	;do smooth scroll..
	
	clr.l	d0
	move.b	scrollspy2,d0
	
	sub.w 	d0,scr2ypos		;spped
	sub.w 	d0,scr2ypos		;done twice because the other screen does half the scrolling
	sub.w	d0,scrolly2		;speed
	sub.w	d0,scrolly2		;
	cmp.w	#0,scrolly2
	bge	.doit

	;weve moved over a word
	add.w	#16,scrolly2
	sub.l	#1*levwidB,ScrDat2
	
	sub.w	#1,scr2yposW
	cmp.w	#0,scr2yposW
	bge	.ok
	
	
	;shit, were at the top of the screen!
	add.w	#vishiw,scr2yposW
	add.w	#vishi,scr2ypos
	
.ok

	move.b	#0,scroll2cnt

.doit
	;if scroll2cnt=0 then init the line
	;if scroll2cnt=ff then weve done all the blitting!
	;if its neither then blit 2(3) words until =10(5)
	
	;set up the pointers to blit

	cmp.b	#0,scroll2cnt
	bne	.noinit
		
	clr.l	d0
	clr.l	d1
	move.l	screen2,a1
	move.l	screen2,a3
	move.l	ScrDat2,a0
	move.w	scr2yposW,d0
	move.w	scr2yposW,d1
	
	add.l	#vishiw,d1		;do bottom of page too!
	mulu	#bitplanes1*pagewid*16,d0
	mulu	#bitplanes1*pagewid*16,d1
	add.l	d0,a1
	add.l	d1,a3

	move.l	a1,scrollpos2a
	move.l	a3,scrollpos2b
	move.l	a0,scrolldat2



.noinit
	cmp.b	#$ff,scroll2cnt
	beq	.out
	
	;ok, its a normal blit 2(3) words
	add.b	#1,scroll2cnt
	cmp.b	#8,scroll2cnt	(5)
	bne	.onwards
	move.b	#$ff,scroll2cnt
	bra	.out

.onwards
;	do a loop blitting

	move.l	scrolldat2,a0
	move.l	scrollpos2a,a1
	move.l	scrollpos2b,a3

	move	#3-1,d7
.loop1
	CALLGRAF	WaitBlit

	clr.l	d0

	move.w	2(a0),d0
	move.l	CharBase,a2
	add.l	d0,a2

	move.l	a2,$dff050	;A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058

	CALLGRAF	WaitBlit
	
	move.l	a2,$dff050	;A
	move.l	a3,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058
	
	add.l	#4,a0		;next level pos please
	add.l	#2,a1		;next s creen pos please
	add.l	#2,a3
	dbra	d7,.loop1

	move.l	a1,scrollpos2a
	move.l	a3,scrollpos2b
	move.l	a0,scrolldat2


.out	rts

scrollfore
	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#pagewid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$09f0,$dff040

	;do smooth scroll..
	
	clr.l	d0
	move.b	scrollspyF,d0
	
	sub.w 	d0,scrFypos		;spped
	sub.w	d0,scrollyF		;speed
	cmp.w	#0,scrollyF
	bge	doitfore

	;weve moved over a word
	add.w	#16,scrollyF

scrollforeFORCE
	sub.l	#1*levwidF,ScrDatF
	
	sub.w	#1,scrFyposW
	cmp.w	#0,scrFyposW
	bge	.ok
	
	
	;shit, were at the top of the screen!
	add.w	#vishiw,scrFyposW
	add.w	#vishi,scrFypos
	
.ok

	move.b	#0,scrollFcnt

doitfore
	;if scrollFcnt=0 then init the line
	;if scrollFcnt=ff then weve done all the blitting!
	;if its neither then blit 2(3) words until =10(5)
	
	;set up the pointers to blit

	cmp.b	#0,scrollFcnt
	bne	.noinit
		
	clr.l	d0
	clr.l	d1
	move.l	scrbaseF,a1
	move.l	scrbaseF,a3
	move.l	ScrDatF,a0
	move.w	scrFyposW,d0
	move.w	scrFyposW,d1
	
	add.l	#vishiw,d1		;do bottom of page too!
	mulu	#bitplanes2*pagewid*16,d0
	mulu	#bitplanes2*pagewid*16,d1
	add.l	d0,a1
	add.l	d1,a3

	move.l	a1,scrollposFa
	move.l	a3,scrollposFb
	move.l	a0,scrolldatF



.noinit
	cmp.b	#$ff,scrollFcnt
	beq	.out
	
	;ok, its a normal blit 2(3) words
	add.b	#1,scrollFcnt
	cmp.b	#9,scrollFcnt	(5)
	bne	.onwards
	move.b	#$ff,scrollFcnt
	bra	.out

.onwards
;	do a loop blitting

	move.l	scrolldatF,a0
	move.l	scrollposFa,a1
	move.l	scrollposFb,a3

	move	#3-1,d7
.loop1
	CALLGRAF	WaitBlit

	clr.l	d0

	move.w	2(a0),d0
	move.l	CharBaseF,a2
	add.l	d0,a2

	move.l	a2,$dff050	;A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*bitplanes2*64)+1,$dff058

	CALLGRAF	WaitBlit
	
	move.l	a2,$dff050	;A
	move.l	a3,$dff054	;dst D	screen
	move.w	#(16*bitplanes2*64)+1,$dff058
	
	add.l	#4,a0		;next level pos please
	add.l	#2,a1		;next s creen pos please
	add.l	#2,a3
	dbra	d7,.loop1

	move.l	a1,scrollposFa
	move.l	a3,scrollposFb
	move.l	a0,scrolldatF


.out	rts


convert_gfx
	;seeing as i wrote twilite4 for non-aga machines.
	;i never saw the need to be able to save out as
	;4 bitplanes!!! 3 yeh, 1 even but not 4!!!!
	;back then dual playfield was only 3 planes...
	
	
	;convert from 5bitplanes down to 4
	;easy, zap every 5th word!!!!!!!!!
	
	move.l	CharBase,a0	;src
	move.l	CharBase,a1	;dst
	move.l	#(256*16)-1,d7
.loop
	move.w	(a0)+,(a1)+	;bit1
	move.w	(a0)+,(a1)+	;bit2
	move.w	(a0)+,(a1)+	;bit3
	move.w	(a0)+,(a1)+	;bit4
	add.l	#2,a0	;skip bit5
	dbra	d7,.loop

;now convert the forground gfx
	move.l	CharBaseF,a0	;src
	move.l	CharBaseF,a1	;dst
	move.l	#(256*16)-1,d7
.loop2
	move.w	(a0)+,(a1)+	;bit1
	move.w	(a0)+,(a1)+	;bit2
	move.w	(a0)+,(a1)+	;bit3
	move.w	(a0)+,(a1)+	;bit4
	add.l	#2,a0	;skip bit5
	dbra	d7,.loop2
	
	rts	

convert_level
	move.l	LevBase,a0
	move.l	LevSize,d7
	lsr.l	#2,d7
	sub.l	#1,d7
;	move.l	#((Levelnd-Level)/4)-1,d7
.loop
	clr.l	d0
	
	move.b	3(a0),d0	;get data
	mulu	#16*bitplanes1*2,d0	;get char
	move.w	d0,2(a0)
	add.l	#4,a0
	sub.l	#1,d7
	bne	.loop

	move.l	LevBaseF,a0
	move.l	LevSizeF,d7
	lsr.l	#2,d7
	sub.l	#1,d7
;	move.l	#((Levelnd-Level)/4)-1,d7
.loop2
	clr.l	d0
	
	move.b	3(a0),d0	;get data
	mulu	#16*bitplanes2*2,d0	;get char
	move.w	d0,2(a0)
	add.l	#4,a0
	sub.l	#1,d7
	bne	.loop2

	rts

makefore
	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#pagewid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$09f0,$dff040

	;set up the pointers to blit

	clr.l	d0
	clr.l	d1
	move.l	scrbaseF,a1
	move.l	scrbaseF,a3
	move.l	ScrDatF,a0
	move.w	scrFyposW,d0
	move.w	scrFyposW,d1
	
	add.l	#vishiw,d1		;do bottom of page too!
	mulu	#bitplanes2*pagewid*16,d0
	mulu	#bitplanes2*pagewid*16,d1
	add.l	d0,a1
	add.l	d0,a3
	
	move.l	a0,scrolldatF
	move.l	a1,scrollposFa
	move.l	a3,scrollposFb

	move.w	#vishiw-1,d6
.rp1

	;this is the blit line bit


.noinit

	move.l	scrolldatF,a0
	move.l	scrollposFa,a1
	move.l	scrollposFb,a3

	move	#24-1,d7
.loop1
	CALLGRAF	WaitBlit

	clr.l	d0

	move.w	2(a0),d0
	move.l	CharBaseF,a2
	add.l	d0,a2

	move.l	a2,$dff050	;A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*bitplanes2*64)+1,$dff058

	CALLGRAF	WaitBlit
	
	move.l	a2,$dff050	;A
	move.l	a3,$dff054	;dst D	screen
	move.w	#(16*bitplanes2*64)+1,$dff058
	
	add.l	#4,a0		;next level pos please
	add.l	#2,a1		1;next s creen pos please
	add.l	#2,a3
	dbra	d7,.loop1

	add.l	#bitplanes2*pagewid*16,scrollposFa
	add.l	#bitplanes2*pagewid*16,scrollposFb
	add.l	#levwidF,scrolldatF

	dbra	d6,.rp1


.out	rts




makeback
	move.b	#1,onscr
	move.l	screen1,scrbase
	
	bsr	scrollback1		;sscroll background

	move.b	#2,onscr
	move.l	screen2,scrbase
	
	bsr	scrollback2		;sscroll background

	rts
scrollback1

	;set up the pointers to blit

	clr.l	d0
	clr.l	d1
	move.l	screen1,a1
	move.l	screen1,a3
	move.l	ScrDat1,a0
	move.w	scr1yposW,d0
	move.w	scr1yposW,d1
	
	add.l	#vishiw,d1		;do bottom of page too!
	mulu	#bitplanes1*pagewid*16,d0
	mulu	#bitplanes1*pagewid*16,d1
	add.l	d0,a1
	add.l	d0,a3

	move.l	a0,scrolldat1
	move.l	a1,scrollpos1a
	move.l	a3,scrollpos1b

	move.w	#vishiw-1,d6
.rp1

	;this is the blit line bit


.noinit

	move.l	scrolldat1,a0
	move.l	scrollpos1a,a1
	move.l	scrollpos1b,a3

	move	#24-1,d7
.loop1
	CALLGRAF	WaitBlit

	clr.l	d0

	move.w	2(a0),d0
	move.l	CharBase,a2
	add.l	d0,a2

	move.l	a2,$dff050	;A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058

	CALLGRAF	WaitBlit
	
	move.l	a2,$dff050	;A
	move.l	a3,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058
	
	add.l	#4,a0		;next level pos please
	add.l	#2,a1		1;next s creen pos please
	add.l	#2,a3
	dbra	d7,.loop1

	add.l	#bitplanes1*pagewid*16,scrollpos1a
	add.l	#bitplanes1*pagewid*16,scrollpos1b
	add.l	#levwidB,scrolldat1

	dbra	d6,.rp1
	
	rts

scrollback2

	;set up the pointers to blit

	clr.l	d0
	clr.l	d1
	move.l	screen2,a1
	move.l	screen2,a3
	move.l	ScrDat2,a0
	move.w	scr2yposW,d0
	move.w	scr2yposW,d1
	
	add.l	#vishiw,d1		;do bottom of page too!
	mulu	#bitplanes1*pagewid*16,d0
	mulu	#bitplanes1*pagewid*16,d1
	add.l	d0,a1
	add.l	d0,a3

	move.l	a0,scrolldat2
	move.l	a1,scrollpos2a
	move.l	a3,scrollpos2b

	move.w	#vishiw-1,d6
.rp1

	;this is the blit line bit


.noinit

	move.l	scrolldat2,a0
	move.l	scrollpos2a,a1
	move.l	scrollpos2b,a3

	move	#24-1,d7
.loop1
	CALLGRAF	WaitBlit

	clr.l	d0

	move.w	2(a0),d0
	move.l	CharBase,a2
	add.l	d0,a2

	move.l	a2,$dff050	;A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058

	CALLGRAF	WaitBlit
	
	move.l	a2,$dff050	;A
	move.l	a3,$dff054	;dst D	screen
	move.w	#(16*bitplanes1*64)+1,$dff058
	
	add.l	#4,a0		;next level pos please
	add.l	#2,a1		1;next s creen pos please
	add.l	#2,a3
	dbra	d7,.loop1

	add.l	#bitplanes1*pagewid*16,scrollpos2a
	add.l	#bitplanes1*pagewid*16,scrollpos2b
	add.l	#levwidB,scrolldat2

	dbra	d6,.rp1
	
	rts


makecollisiontable
	;the irq will have created a collision table
	;bulletsF, player, bulletB as words
	;grab each word, and #%10 and store in
	;bull1coll, p1collision
	;
	lea	bullsort1,a4
	lea	colltable,a0
	move.l	#bull1numF-1,d6
	
.loop	
	cmp.l	#0,a4
	beq	.next
	move.l	(a4),a1
	cmp.b	#ALIVE,bull1status(a1)
	bne	.next
	;found an alive bullet!!!
	move.w	(a0)+,d0
	and.l	#%0000000000000010,d0
	move.b	d0,bull1coll(a1)
	
.next
	add.l	#4,a4
	dbra	d6,.loop
	
	;with luck the very last number should be the player!
	
	move.w	(a0)+,d0
	and.l	#%0000000000000010,d0
	move.b	d0,p1collision

	

	rts


	even
	cnop	0,4	
	
	
;	move.w	#%0000000000000000,$dff106
	move.w	#%0000000000001100,$dff1fc
	
new:
	include	spriteclist
	
	dc.w	$01fc,%1100		;enable sprite 64 wide!
	
	dc.w	bpl1mod
	dc.w	(pagewid*bitplanes1)-viswid
	dc.w	bpl2mod
	dc.w	(pagewid*bitplanes2)-viswid
	dc.w	dmacon,$8020
scnposs	dc.w	diwstrt,$2c81
scnpose	dc.w	diwstop,$2cc1 
	dc.w	ddfstrt,$30
	dc.w	ddfstop,$d0
	dc.w	bplcon0,$0210
	dc.w	bplcon0,%0000011000010000
;		         0000       1 	  ;8 bitplanes
;		              11       	1 ;dpf,col,ecsena



	dc.w	bplcon1
scroll	dc.w	$0
;	dc.w	bplcon2,0
	dc.w	bplcon2,%0000001000111000	;killehb, pf2 prio
;	dc.w	bplcon3,$0c00	;bplcon3
	dc.w	bplcon3,%0001000000000000	;bplcon3
	dc.w	bpl1h
bit1h	dc.w	0
	dc.w	bpl1l
bit1l	dc.w	0
	dc.w	bpl3h
bit3h	dc.w	0
	dc.w	bpl3l
bit3l	dc.w	0
	dc.w	bpl5h
bit5h	dc.w	0
	dc.w	bpl5l
bit5l	dc.w	0
	dc.w	bpl7h
bit7h	dc.w	0
	dc.w	bpl7l
bit7l	dc.w	0


	dc.w	bpl2h
bit2h	dc.w	0
	dc.w	bpl2l
bit2l	dc.w	0
	dc.w	bpl4h
bit4h	dc.w	0
	dc.w	bpl4l
bit4l	dc.w	0
	dc.w	bpl6h
bit6h	dc.w	0
	dc.w	bpl6l
bit6l	dc.w	0
	dc.w	bpl8h
bit8h	dc.w	0
	dc.w	bpl8l
bit8l	dc.w	0

	dc.w	bplcon3,%0011000000000000	;bplcon3 select pallete 1
	dc.w	bplcon4,%0000000000100010
colourspr	include	slyma/colclist


	dc.w	bplcon3,%0001000000000000	;bplcon3 select pallete 0
colourgfx	include	slyma/colclist
	;enable sprite collsion between spr0/1 and playfield1

	dc.w	$0098,%0001000000000000	;clxcon
	dc.w	$010e,%0000000001000001	;clxcon2
	dc.w	intena,$8010	;call irq to clear collision
	

	dc.l	$2009fffe
	
	;leave this 10 lines for the mo. wipe them when we ahev the floating copper going	
p1strt
;	dc.l	$3c09fffe	;p1ship start
	;hopefully these 2 will reset the collision flags!
;	dc.w	intena,$8010	;call irq to clear collision
;	dc.w	intreq,$8010


;	dc.l	$0180088f	
p1end
;	dc.l	$7c09fffe	;p1ship end
;	dc.l	$01800000

;	dc.w	intena,$8010	;call irq to read collision
;	dc.w	intreq,$8010



float	;	line/ntsc,line     ,irq	     ,bpl1l    ,bpl1h	 ,bpl3l    ,bpl3h    ,bpl5l    ,bpl5h
	dc.l	$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff
	dc.l	$01800f00,$01800f00,$01800f00,$01800f00,$01800f00,$01800f00,$01800f00,$01800f00,$01800f00
	dc.l	$018000f0,$018000f0,$018000f0,$018000f0,$018000f0,$018000f0,$018000f0,$018000f0,$018000f0
	dc.l	$0180000f,$0180000f,$0180000f,$0180000f,$0180000f,$0180000f,$0180000f,$0180000f,$0180000f
	dc.l	$01800ff0,$01800ff0,$01800ff0,$01800ff0,$01800ff0,$01800ff0,$01800ff0,$01800ff0,$01800ff0
	dc.l	$018000ff,$018000ff,$018000ff,$018000ff,$018000ff,$018000ff,$018000ff,$018000ff,$018000ff
	dc.l	$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff,$01800fff
float_nd

;	dc.l	$01800000


	dc.l	$ffdffffe
	dc.l	$01800888
	dc.w	$1b09,$fffe,bplcon0,$0200	;kill off very bottom line (ill put it back in if oj complains!)


	
	dc.w	$ffff,$fffe		;end of coper list

	dc.l	0
old	dc.l	0
gfxname	dc.b	"graphics.library",0
intname	dc.b	"intuition.library",0
iffname	dc.b	"iff.library",0
dosname	dc.b	"dos.library",0
wbname          dc.b  "Workbench",0
	even
	dc.l	0

_GfxBase	dc.l	0
_IntuitionBase	dc.l	0
_IFFBase	dc.l	0
_DOSBase	dc.l	0

screen1	dc.l	0	;screen1 background
screen2	dc.l	0	;screen2 background
screenF	dc.l	0	;screen foreground
scrbase	dc.l	0	;pointer to top of page 1
scrbaseF	dc.l	0	;pointer to top of page forground
iffhandle	dc.l	0
Handle	dc.l	0
LockFile	dc.l	0	;lock for the file
FileSize	dc.l	0	;size of the file
FileBase	dc.l	0	;where in memory the file is

taglist         dc.l  VTAG_SPRITERESN_GET
resolution      dc.l  SPRITERESN_ECS
                dc.l  TAG_DONE,0

wbview          dc.l  0
oldres          dc.l  0
wbscreen        dc.l  0
oldpri	dc.l	0
vertbase	dc.l	0
FileName	dc.l	0
CharSize	dc.l	0
CharSizeF	dc.l	0
CharBase	dc.l	0
CharBaseF	dc.l	0
LevSize	dc.l	0
LevSizeF	dc.l	0
LevBase	dc.l	0
LevBaseF	dc.l	0
SprDBase	dc.l	0	;data for the sprite gfx
SprDSize	dc.l	0	;size of data for the sprite gfx
SprBullDBase	dc.l	0	;data for sprite bullets
SprBullDSize	dc.l	0	;size of sprite bullets
SprBase0	dc.l	0	;dlw boundary sprite base (USE THIS)
SprBase1	dc.l	0
SprBase2	dc.l	0
SprBase3	dc.l	0
SprBase4	dc.l	0
SprBase5	dc.l	0
SprBase6	dc.l	0
SprBase7	dc.l	0

ScrDat1 	dc.l	0	;pointer to level data at top!
ScrDat2	dc.l	0	;pointer to level data at top!
ScrDatF	dc.l	0	;pointer to level data at top!
scrolldat1	dc.l	0	;data for scroll1
scrolldat2	dc.l	0	;data for scroll2
scrolldatF	dc.l	0	;data for scroll2
scrollpos1a	dc.l	0	;position on screen for scroll1 TOP
scrollpos2a	dc.l	0	;position on screen for scroll2 TOP
scrollposFa	dc.l	0	;position on screen for scroll2 TOP
scrollpos1b	dc.l	0	;position on screen for scroll1 BOT
scrollpos2b	dc.l	0	;position on screen for scroll2 BOT
scrollposFb	dc.l	0	;position on screen for scroll2 BOT

counterx	dc.l	0	;to do with inertia movement
countery	dc.l	0	;to do with inertia movement

bullsort1	dcb.l	bull1numF,0

	even

scr1xpos	dc.w	0
scr2xpos	dc.w	0
scr1ypos	dc.w	256	;screen scroll position Y
scr2ypos	dc.w	256
scrFypos	dc.w	256
scr1yposW	dc.w	0	;scroll counter 0-17 coarse Y
scr2yposW	dc.w	0 
scrFyposW	dc.w	0 
scrFxposW	dc.w	2	;default = 2
scrFxposF	dc.w	0	;default = 8
scrFxposC	dc.w	6	;6 shipx = 1 screenx

scrolly1	dc.w	0	;scroll counter 0-15 smooth Y
scrolly2	dc.w	0
scrollyF	dc.w	0

scrollspy1	dc.b	1	;screen scroll y speed 1
scrollspy2	dc.b	1
scrollspyF	dc.b	2	;foreground speed
scroll1cnt	dc.b	0	;scroll1 counter 0 = init line 1-10
			;do 2 words a vblank
scroll2cnt	dc.b	0
scrollFcnt	dc.b	0

count	dc.b	0	;spare count addr (used by makeback/fore)
temp	dc.b	0	;temp (used by makeback/fore)

p1frame	dc.b	8	;player1 sprite frame

charnameb	dc.b	"Genocide:grafix/hel-105.gfx",0	;background
charnamef	dc.b	"Genocide:grafix/hel-008.gfx",0	;forground
levname	dc.b	"Genocide:grafix/hel11.lvl",0	;background
levnamef	dc.b	"Genocide:grafix/hel01.lvl",0	;forground
colnamegfxb	dc.b	"Genocide:grafix/hel-105.gfx.cmap",0	;background
colnamegfxf	dc.b	"Genocide:grafix/hel-008.gfx.cmap",0	;foreground
colnamespr	dc.b	"Genocide:grafix/player1.iff",0
player1	dc.b	"Genocide:grafix/player1.iff",0
player1spr	dc.b	"Genocide:grafix/player1weap.iff",0

	even
	cnop 	0,4
FileInfo	dcb.b	240,0
bitmap	dcb.b	40,0
colours
;	incbin	grafix/Chunk.GFX.Cmap
	dcb.w	32,0
	
pallete0	dcb.w	32,0	;pallete put in copper gfx
pallete1	dcb.w	32,0	;pallete put in copper spr
onscr	dc.b	2	;what screen are we DRAWING on 1 or 2

	even
	cnop	0,4
spritedata	dcb.b	464+(8*(4+4+4+4+(8*256)))	;sprite data +(64 for dblong allign)
dead	;dead sprite data
	dc.w	0,0,0,0
	dcb.l	432*2,$ffff
	dc.w	0,0

oldpos	dc.w	0	;mouse data

	even
	cnop	0,4

p1copst	dc.l	0	;copper start line for collision
p1copnd	dc.l	0	;copper end line for collision
xpos	dc.w	160	;far left 94 far right 414
ypos	dc.w	100	;top 60 (word spare)
p1joy	dc.b	0	;reading from joystick
p1dir	dc.b	0	;players direction (will be different from joy)
p1reload	dc.b	0	;countdown for reload 0=ready
p1reloadmax	dc.b	0	;countdown MAX. copy this into reload when he fires
p1ammo	dc.w	0
p1maxspdx	dc.w	7*8	;max speed X TOP 7	(spd *8)
p1maxspdy	dc.w	5*8	;max speed Y TOP 5	(spd *8)
p1collision	dc.b	0

fred	dc.b	0

;----------------------------------
;inertia

;
;on left.
;	add.l	#$8,counterx
;	
;
;in vblank
;	sub.l	#1,counterx	;increase this to give better inertia!
;	move.l	counterx,d0
;	ror.l	4,d0
;	blzero	.out
;	;should have a small no.
;	if over 8 make 8
;	if going left
;	sub.l	d0,xpos
;.out
	
	;bit defs:-
	;the no. at the end is the actual bit effected 0-15
	;to use:
	;	BOBB_UP	3 = %0011  bset   BOBB_UP,d0
	;	BOBF_UP	8 = %1000  move.w BOBF_UP,d0
	
	BITDEF	BOB,UP,3
	BITDEF	BOB,DOWN,2
	BITDEF	BOB,LEFT,1
	BITDEF	BOB,RIGHT,0
	BITDEF	BOB,SHOOT,4	;Player only.......

NULL	equ	0	;for most player/baddy things
ALIVE	equ	1
DEAD	equ	2
	

bull1struct
	dc.l	0	copper start pos for collision
	dc.l	0	copper end pos for collision
	dc.w	0	xpos
	dc.w	0	ypos
	dc.b	0	height
	dc.b	0	status
	dc.b	0	speed
	dc.b	0	collision (00000010) = foreground
bull1struct_nd

bull1copst	equ	0	;copper start for collision
bull1copnd	equ	4	;copper end
bull1xpos	equ	8	;pix x pos
bull1ypos	equ	10	;pixel y pos
bull1hi	equ	12	;height of sprite
bull1status	equ	13	;alive dead or what
bull1speed	equ	14	;speed per vblank (at least 8)
bull1coll	equ	15	;collision with fore/back ground
	
	cnop	0,4

bull1base	ds.b	bull1numF*(bull1struct_nd-bull1struct)
	
backstruct
	dc.l	0	;copper start	
	dc.l	0	;copper end
	dc.w	0	;wall modulo
	dc.w	0	;xpos
	dc.b	0	;height of wall (pixies)
	dc.b	0	;status
backstruct_nd

backcopst	equ	0	;copper start
backcopnd	equ	4	;copper end
backmodulo	equ	8	;wall modulo
backxpos	equ	10	;default xpos
backhi	equ	12	;height of wall
backstatus	equ	13	;status

backbase	ds.b	backmaxB*(backstruct_nd-backstruct)
	

bottflag	dc.b	0	;flag for bottom of copper screen	
ntscflag	dc.b	0	;flag for copper creation
bullnd	dc.b	0	;flag for bullcop end
backnd	dc.b	0	;flag for backcop end
backdone	dc.b	0	;flag for ALL background done
p1nd	dc.b	0	;flag for p1cop end

				;bull1numF,player,bull1numB
	even
	cnop	0,4
collpos	dc.l	colltable		;pos in collision table
colltable	ds.l	(bull1numF+1+bull1numB)	;collision table created by irq


GenIRQ

	AND 	#$10,$dff01e       	; Check if interrupt is from Copper 
	BEQ.s	.out
	MOVE.W 	#$10,$dff09c		; Clear the interrupt flag
	
	;move.w	#$0666,$dff180
	bchg #1,$bfe001			; turn off low pass filter
					; on recent A500/B2000's
	;push all to stack
	movem.l	d0-d7/a0-a6,-(a7)

	;blitter fucks up if used on irq and off irq....
	
	;okay we have our IRQ.
	;read the sprite collision reg 
	;this will clear any collision flags setup by the bullets
	;leaving the copper free to check the players sprite
	
	move.l	collpos,a0
	
	move.w	$dff00e,d0
;	move.w	#$1234,d0
	cmp.b	#0,flag	;clear it or not
	bne	.itsa1
	move.b	#1,flag	;store it next go

	move.w	#0,(a0)	;clear collision from last go
;	move.w	#0,p1collision	;** REMOVE
	move.w	#$0666,$dff180
	bra	.nodwn
.itsa1
	move.b	#0,flag	;store it for next go
	move.w	d0,(a0)	;store collision (if any)
;	move.w	d0,p1collision	;** REMOVE
	add.l	#2,collpos	;next collision please (pointer is reset after each vblank [non-irq])
	move.w	#0,$dff180
	
	
	
;	bsr	loadsairqprg
	;pull all off stack
.nodwn
	movem.l	(a7)+,d0-d7/a0-a6

.okdk	
.out: 	
	;move.w	#$0,$dff180
	DC.W $4ef9			
oldvec:	DC.L 0				
flag	dc.b	0	;0 = clear 1 = read

;this bit of code is a nice cheat. During the setup routine it
;puts the system level 3 interrupt address (found at $0000006c in
;memory) into the long word at OLD. The $4ef9 before that is the
;hex value for the JMP instruction, so it jumps to the routine.
	