V123
;Fixed it to work on any amiga (whatever screen mode [not pal/ntsc]!!!!)
;Fixed sprite problems on return to WB

;YOBTRIS -=> see history

;big marble at top of screen rolls down. Try and get it in the hole
;marble bounces!

;drawn new fuck off weapon for baddies n player.(above^)
;big beam (full width screen) destorys ANYTHING on contact (inc pforms)

;Layzee Beam..
;4words wide (use baddy bullets) and goes up the entire screen!
;freezes players and baddies for a few seconds

debugging	equ	0	;no copper (using monam)
slowly	equ	1	;do everything (slow lmb)

	section screen,code_c		;make sure chip ram
	



	include	iconstartup2.i

	bra	YOBBING
	
showCOLL	dc.b	0	;show only the collision copperlist
	dc.b	"$VER:Yobbin 123fa4a"
	cnop	0,4
YOBBING

	opt	c+
bullgfxline	equ	5	;how many bullet gfx lines (for iff conv)
yobtitnum	equ	24	;how many yob title bars!

_CUSTOM	equ	$dff000	
scrwid	equ	42
scrhi	equ	19	;1+16+2
screensize	equ	scrwid*(scrhi*16)*5
collsize	equ	scrwid*(scrhi*16)
level_wid	equ	20
level_hi	equ	16
players_max	equ	2	;max no. players

baddygfx	equ	5	;no baddies in iff file
bad_max	equ	6	;max no. of baddies
bullet_max	equ	2	;max no. baddy bullets
gun_max	equ	2*players_max	;no. bullets per player

bnb_max	equ	8	;* MAKE ME THE MAX OF BADDIES AND BULLETS * used in play to baddy/bull collision

gravity	equ	40	;max pos in fall table
HitPoints	equ	20	;player hit points (BYTE)
hittime	equ	20	;how long is player hit for	
pamax	equ	4	;how many vblank between player anim update!
SmartLife	equ	$200	;how long the smart bullets lasts seeking!

	move.w	#$8400,$dff096

	lea	gfxname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_GfxBase

	lea	iffname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_IFFBase

	lea	dosname,a1
	CALLEXEC	OldOpenLibrary
	beq	NO_MEMORY
	move.l	d0,_DOSBase



	lea	intname,a1          ;
	moveq	#39,d0                  ; Kickstart 3.0 or higher
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase       ; store intuitionbase


	ifeq debugging

	
	CALLGRAF	OwnBlitter
	endc

	bsr	alloccollbase
	cmp.l	#0,collbase
	beq	NO_MEMORY

	bsr	allocscrbase
	cmp.l	#0,scrbase
	beq	NO_MEMORY	;no memory
	move.l	scrbase,screen1

	bsr	allocscrbase
	cmp.l	#0,scrbase
	beq	NO_MEMORY	;no memory
	move.l	scrbase,screen2

	move.b	#001,LevelNum		;start at level 1

	bsr	LoadNProcess	;load all gfx in and process
	bsr	AllocTemps		;alloc all the tempory storage for gfx
	

	bsr	go_bitplanes
	bsr	go_colour	
	bsr	copycolour		;copy it for the title screen

	bsr	get_old_cop

	bsr	init_bulls	
	bsr	SetupALL
	move.l	#bads_list,badcheck
	move.b	#0,badcnt
		
	ifeq debugging

	move.l	_GfxBase,a6
	move.l	gb_ActiView(a6),wbview  ; store current view address

	bsr	FixSpritesSetup         ; fix V39 sprite bug...

	move.l	_GfxBase,a6
.skip	sub.l	a1,a1                   ; clear a1
	CALLGRAF	LoadView        ; Flush View to nothing
	CALLGRAF	WaitTOF         ; Wait once
	CALLGRAF	WaitTOF         ; Wait again.



	;^^^^^^^^ before anything


        sub.l   a1,a1                   ; Zero - Find current task
        CALLEXEC	FindTask

        move.l  d0,a1
        moveq   #127,d0                 ; task priority to very high...
        CALLEXEC	SetTaskPri
        move.l	d0,oldpri

	move.w	#$0200,bitplanes	;planes OFF
	
	bsr	vblank
	bsr	vblank
	move.l	#new,$dff080
	endc


	move.b	#0,TitleON		;go straight into title screen!
	move.b	#0,TitleONFT	;make first timer
			

main:
	ifeq debugging
	bsr	vblank2
	
	endc

	ifeq slowly
	btst	#6,$bfe001
	beq	over
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
	bsr	vblank2
over
	endc

	cmp.b	#1,TitleON
	bne	.notitle
	bsr	title_code
	bra	.mainreturn
.notitle

		
	bsr	go_bitplanes

	bsr	go_switch

	move.l	#0,d7
.loop
	add.l	#1,d7
	cmp.l	#$1500,d7
;	bne	.loop

	bsr	go_flash		;flash the screen (white to black)
	
	bsr	go_restorebullets
	bsr	go_restoreplayer1
	bsr	go_restorebads
	bsr	go_restoreguns

	bsr	go_movebads
	bsr	go_moveplayer1
	bsr	go_moveguns
	PUSHALL
	bsr	go_movebullets
	PULLALL

	bsr	go_printlazer
	bsr	go_lazerzone

	bsr	go_grabguns
	bsr	go_grabbads
	bsr	go_grabplayer1
	bsr	go_grabbullets


 	bsr	go_printguns
	bsr	go_printbads
	bsr	go_printplayer1
	bsr	go_printbullets


	bsr	go_collision
	
	add.b	#1,random

	bsr	randplayer

;	move.w	#$fff,$dff180
	nop
	nop
	nop
	nop
	nop
;	move.w	#$0,$dff180

	move.l	badcheck,a0
	cmp.b	#DEAD,bad_status(a0)
	bne	.notdead
	
	add.l	#(bad_type1_nd-bad_type1),badcheck	;next struct
	add.b	#1,badcnt
	clr.l	d0
	move.b	badcnt,d0
	cmp.b	#bad_max-1,d0
	bne	.deadcheck
	;hes done the level!
	bsr	NewLevel
	
	
	
.notdead
	move.l	#bads_list,badcheck
	move.b	#0,badcnt
.deadcheck
	
	
	;swap display collision or normal!
	cmp.b	#$4f,$bfec01	;COLL F9
	bne	.notCOLL
	move.b	#1,showCOLL
.notCOLL
	cmp.b	#$4d,$bfec01	;NORM F10
	bne	.notNORM
	move.b	#0,showCOLL
.notNORM
	cmp.b	#$5f,$bfec01	;F1 Next Lev
	bne	.noNlev
	
	move.b	#1,TitleON		;go straight into title screen!
;	bsr	NewLevel
;	move.w	$dff006,d0
;	and.l	#$fff,d0
;	move.w	d0,$dff180
	
.noNlev

.mainreturn
	cmp.b	#$3f,$bfec01
	bne	main
	
exit	move	#%1000000000100000,$dff096;enable sprites
	
	ifeq debugging	
	move.l	old,$dff080	
	endc

	;free up intset memory
	move.l	IntSize,d0
	move.l	IntBase,a1
	CALLEXEC	FreeMem

	bsr	FreeTemps
	bsr	FreeGfxMem

	bsr	freecollbase		
	move.l	screen1,scrbase
	bsr	freescrbase
	move.l	screen2,scrbase
	bsr	freescrbase

NO_MEMORY
	ifeq debugging	
	CALLGRAF	DisownBlitter
	endc

	sub.l	a1,a1                   ; Zero - Find current task
	CALLEXEC	FindTask

	move.l	d0,a1
	move.l	oldpri,d0                 ; task priority to very low...
	CALLEXEC	SetTaskPri

	;VVVVVVVV after everything


	bsr	ReturnSpritesToNormal

	move.l	wbview,a1
	move.l	_GfxBase,a6
	CALLGRAF	LoadView        ; Fix view
	CALLGRAF	WaitTOF
	CALLGRAF	WaitTOF         ; wait for LoadView()

	move.l	gb_copinit(a6),$dff080.L  ; Kick it into life

	CALLINT	RethinkDisplay     ; and rethink....


	bsr	CloseLibs
FEXIT	clr.l	d0
	rts

	include	initial.inc	;vblank,vblank2,go_colour,allocscrbase,freescrbase,get_old_cop

go_switch	
	bchg	#1,switch
	bne	.over
	move.l	screen1,scrbase
	bra	.skip
.over
	move.l	screen2,scrbase
.skip
	rts

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
alloccollbase
	move.l	#$10002,d1	;memory Ill have chip please
	move.l	#collsize,d0	;this much please
	CALLEXEC	AllocMem
	move.l	d0,collbase
	rts
freecollbase
	move.l	#collsize,d0
	move.l	collbase,a1
	CALLEXEC	FreeMem
	rts

FixSpritesSetup:
	lea	wbname,a0
	CALLINT	LockPubScreen

	tst.l	d0                         ; Could I lock Workbench?
	beq.s	.error                     ; if not, error
	move.l	d0,wbscreen
	move.l	d0,a0

	move.l	sc_ViewPort+vp_ColorMap(a0),a0
	lea	taglist,a1
	CALLGRAF	VideoControl       ;

	move.l	resolution,oldres          ; store old resolution

	move.l	#SPRITERESN_140NS,resolution
	move.l	#VTAG_SPRITERESN_SET,taglist

	move.l	wbscreen,a0
	move.l	sc_ViewPort+vp_ColorMap(a0),a0
	lea	taglist,a1
	CALLGRAF	VideoControl       ; set sprites to lores

	move.l	wbscreen,a0
	CALLINT	MakeScreen
	CALLINT	RethinkDisplay     ; and rebuild system copperlists

; Sprites are now set back to 140ns in a system friendly manner!

.error
        rts

ReturnSpritesToNormal:
; If you mess with sprite resolution you must return resolution
; back to workbench standard on return! This code will do that...

        move.l   wbscreen,d0
        beq.s    .error
        move.l   d0,a0

        move.l   oldres,resolution          ; change taglist
        lea      taglist,a1
        move.l   sc_ViewPort+vp_ColorMap(a0),a0
	CALLGRAF	VideoControl       ; return sprites to normal.

        move.l   wbscreen,a0
	CALLINT	MakeScreen         ; and rebuild screen

        move.l   wbscreen,a1
        sub.l    a0,a0
	CALLINT	UnlockPubScreen

.error
        rts
	




	
back_to_screen	;blit background on screen
	move.l	BackBase,a0
	move.l	scrbase,a1
	add.l	#(16*scrwid*5)+2,a1

	move.l	#256-1,d6		;no. lines
.lines

	move.l	#5-1,d5		;no. bitplanes
.bplanes
	;copy 1 bpl line
	move.l	#40-1,d4	;no. bytes per row
.bplline
	move.b	(a0)+,(a1)+
	dbra	d4,.bplline
	
	add.l	#scrwid-40,a1
	dbra	d5,.bplanes
	
	dbra	d6,.lines
	rts
;	CALLGRAF	WaitBlit
	
;	move.l	#$ffffffff,$dff044
;	move.w	#40-40,$dff064	;mod A
;	move.w	#scrwid-40,$dff066	;mod D
;	move.w	#$0,$dff042
;	move.w	#$09f0,$dff040

;	move.l	BackBase,a0
;	move.l	scrbase,a1
;	add.l	#(16*scrwid*5)+2,a1
;	move.l	a0,$dff050	;A
;	move.l	a1,$dff054	;dst D	screen
;	move.w	#(128*5*64)+20,$dff058
	
;	add.l	#128*5*40,a0	;next block of back
;	add.l	#128*5*scrwid,a1	;next block of screen

;	CALLGRAF	WaitBlit
;	move.l	a0,$dff050	;A
;	move.l	a1,$dff054	;dst D	screen
;	move.w	#(128*5*64)+20,$dff058

;	rts
go_bitplanes
	cmp.b	#0,showCOLL
	bne	goCOLLbplanes

	move.w	#5-1,d7
	move.l	screen1,d0
	cmp.l	scrbase,d0
	bne	.ok
	move.l	screen2,d0
.ok
	add.l	#(16*scrwid*5)+2,d0
	lea	bit1h,a0
cloop
	move.w	d0,4(a0)	;bit1l
	swap	d0
	move.w	d0,(a0)	;bit1h
	swap	d0
	add.l	#scrwid,d0	;next bitplane
	add.l	#8,a0	;next copper pos.
	dbra	d7,cloop
	move.w	#(scrwid*5)-40,modeven	;screen modulos
	move.w	#(scrwid*5)-40,mododd
	move.w	#$5200,bitplanes	;make 5 bitplane please

	rts

goCOLLbplanes
	move.l	collbase,d0
	add.l	#(16*scrwid)+2,d0

;	move.l	BaddyCOLLBase,d0
	lea	bit1h,a0
	move.w	d0,4(a0)	;bit1l
	swap	d0
	move.w	d0,(a0)	;bit1h
	move.w	#scrwid-40,modeven	;screen modulos
	move.w	#scrwid-40,mododd
	move.w	#$1200,bitplanes	;make 1 bitplane please
	rts

init_bitplanes2
	;init the YOB title piccy!
	lea	yobclist,a0		;yob clist
	move.l	#yobtitnum-1,d7		;no. lines to do!
	move.l	screen1,d0
	add.l	#2,d0
	move.l	#$0d09fffe,d1	;copper line
.yoloop
	move.l	d1,(a0)+		;copy copper line
	move.w	#bplcon0,(a0)+		;bplcon0
	move.w	#$0200,(a0)+

	move.w	#bpl1h,(a0)+
	move.w	#0,(a0)+
	move.w	#bpl1l,(a0)+
	move.w	#0,(a0)+

	move.w	#bpl2h,(a0)+
	move.w	#0,(a0)+
	move.w	#bpl2l,(a0)+
	move.w	#0,(a0)+

	move.w	#bpl3h,(a0)+
	move.w	#0,(a0)+
	move.w	#bpl3l,(a0)+
	move.w	#0,(a0)+

	move.w	#bpl4h,(a0)+
	move.w	#0,(a0)+
	move.w	#bpl4l,(a0)+
	move.w	#0,(a0)+

	move.w	#bpl5h,(a0)+
	move.w	#0,(a0)+
	move.w	#bpl5l,(a0)+
	move.w	#0,(a0)+


	add.l	#$01000000,d1
	dbra	d7,.yoloop
	
	;init the press fire to start copper list
	lea	pfts,a0		;press fire to start (clist)
	move.l	#40-1,d7		;no. lines to do
	move.l	screen1,d0		
	add.l	#114*scrwid*5,d0	;press fire
;	add.l	#162*scrwid*5,d0	;to start
	move.l	#$0109fffe,d1
.pfloop
	move.l	d1,(a0)+		;copy copper line
	move.l	d0,d2
	move.w	#bpl1h,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#bpl1l,(a0)+
	swap	d0
	move.w	d0,(a0)+
	
	add.l	#scrwid,d0
	move.w	#bpl2h,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#bpl2l,(a0)+
	swap	d0
	move.w	d0,(a0)+
	
	add.l	#scrwid,d0
	move.w	#bpl3h,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#bpl3l,(a0)+
	swap	d0
	move.w	d0,(a0)+
	
	add.l	#scrwid,d0
	move.w	#bpl4h,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#bpl4l,(a0)+
	swap	d0
	move.w	d0,(a0)+
	
	add.l	#scrwid,d0
	move.w	#bpl5h,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#bpl5l,(a0)+
	swap	d0
	move.w	d0,(a0)+

	add.l	#scrwid*5,d2
	move.l	d2,d0
	add.l	#$01000000,d1	
	dbra	d7,.pfloop
			
	rts

go_pfts
	;line 114 is start of press fire
	;line 162 is start of  to start

	;these 2 rtns will scroll the to start into the press fire
	
	cmp.b	#0,pftswait
	beq	.ok
	sub.b	#1,pftswait
	bra	.out
.ok
	bsr	tophalf
	bsr	bothalf
	
.out	rts

tophalf
	clr.l	d0
	clr.l	d1
	move.b	inbaset,d0		;the new words (to start first)
	move.b	inpost,d1		;the new place

	lea	pfts,a0
	add.l	#20*(4+(5*(4+4)))+4,a0	;+4 to skip line pointer!

	;find starting pos	
	move.l	#20,d7
	sub.b	d1,d7
.spos	
	cmp.b	#0,d7
	beq	.foundit
	sub.l	#4+(5*(4+4)),a0
	sub.l	#1,d7
	bra	.spos

.foundit	
	;a0 has starting place in clist
	move.l	screen1,a1
	sub.l	#1,d0
.ppos
	add.l	#(5*scrwid),a1
	dbra	d0,.ppos
	
	;a1 has the piccy pos
	
	;now copy in so many
	move.l	a1,d0
	move.l	#20,d7
	sub.l	d1,d7		;d7 has how many to copy

	move.l	a0,a2
	move.l	d0,d2

.copy
	move.l	a2,a0
	move.l	d2,d0
	
	move.l	#5-1,d6
.plan
	move.w	d0,6(a0)	;bit1l
	swap	d0
	move.w	d0,2(a0)	;bit1h
	swap	d0
	
	add.l	#8,a0	;next cplane
	add.l	#scrwid,d0	;next bitplane
	dbra	d6,.plan
	
	add	#4+(5*(4+4)),a2	;next line
	add.l	#5*scrwid,d2
	dbra	d7,.copy
	
	;okay now dec inpost
	
	sub.b	#1,inpost
	cmp.b	#0,inpost
	bne	.nodone
	;hes finished!
	move.b	#100,pftswait
	move.b	#20,inpost
	cmp.b	#114,inbaset
	beq	.go162
	move.b	#114,inbaset
	bra	.nodone
.go162
	move.b	#162,inbaset
	
.nodone

	rts
bothalf
	clr.l	d0
	clr.l	d1
	move.b	inbaseb,d0		;the new words (to start first)
	move.b	inposb,d1		;the new place

	;first find the end place in the copper list
	lea	pfts,a0
	add.l	#20*(4+(5*(4+4)))+4,a0	;+4 to skip line pointer!
	
	move.l	#20,d7
	sub.l	d1,d7
.cline	cmp.b	#0,d7
	beq	.gotline
	add.l	#(4+(5*(4+4))),a0
	sub.b	#1,d7
	bra	.cline
.gotline
	;copper line in a0
	
	move.l	screen1,a1
	sub.l	#1,d0
.ppos
	add.l	#(5*scrwid),a1
	dbra	d0,.ppos
	;that get to the middle of the piccy
	;add 40 lines to get to the bottom
	add.l	#40*(5*scrwid),a1
	
	;now place that line in a0 and sub all
	
	move.l	#20,d7
	sub.l	d1,d7

	move.l	a1,d0
	
	move.l	d0,d1
	move.l	a0,a2
.pline

	move.l	#5-1,d6	
	move.l	d1,d0
	move.l	a2,a0

.plane	move.w	d0,6(a0)	;bit1l
	swap	d0
	move.w	d0,2(a0)	;bit1h
	swap	d0
	
	add.l	#4+4,a0	;next cline
	add.l	#scrwid,d0	;next gline
	dbra	d6,.plane

	sub.l	#(5*(4+4))+4,a2
	sub.l	#scrwid*5,d1
	dbra	d7,.pline
	
	
















	;okay now dec inposb
	
	sub.b	#1,inposb
	cmp.b	#0,inposb
	bne	.nodone
	;hes finished!
	move.b	#100,pftswait
	move.b	#20,inposb
	cmp.b	#114,inbaseb
	beq	.go162
	move.b	#114,inbaseb
	bra	.nodone
.go162
	move.b	#162,inbaseb
	
.nodone

	rts	


SetupALL
	move.l	screen2,scrbase
	bsr	back_to_screen	;blit background on screen
	move.l	screen1,scrbase
	bsr	back_to_screen	;blit background on screen
	bsr	go_findlazer	;search level for lazer cannon and copy strip

	move.l	screen1,scrbase
	bsr	go_makelevel
	bsr	go_findbads	;search through level map for baddies!
	bsr	go_findplayers	;search through level map for player(s)
	bsr	go_grabbads	;grab baddies off screen (make coarse & smooth)
	bsr	go_grabplayer1
	bsr	go_grabbullets
	move.l	screen2,scrbase
	bchg	#1,switch
	bsr	go_makelevel
	bsr	go_grabbads	;grab baddies off screen (make coarse & smooth)
	bsr	go_grabplayer1
	bsr	go_grabbullets

	lea	liveplayers,a1
	clr.l	d0
	clr.l	d7
	move.b	num_players,d7	
	sub.b	#1,d7	;sub for dbra
loop
	move.b	d0,(a1,d0)
	add.b	#1,d0
	dbra	d7,loop
	move.b	#$ff,(a1,d0)	;terminate with ff
	rts

go_findlazer
	move.l	lazertempBase,a5
	move.l	LevBase,a0	;point to start of level
	;level data is in longs.
	;and #$ffff0000	to kill all but attr
	;the lazers are 55,56
	move.l	#level_wid*level_hi-1,d7
	clr.l	d1		;counter
.loop
	move.l	(a0)+,d0
	and.l	#$ffff0000,d0	;kill all but attr
	swap	d0

	cmp.b	#55,d0
	bne	.notR
	bsr	.gotR
	
.notR	cmp.b	#56,d0
	bne	.notL
	bsr	.gotL
.notL
	add.l	#1,d1		;next one please
	dbra	d7,.loop
	
	rts
.gotR
	;copy 40 chars from here!->
	;d1 has got the char pos (div scr level_wid)
	move.l	d1,d2
	divu	#level_wid,d2
	;bottom word is line
	;high word is across
	move.l	screen1,a2		;source
	add.l	#16*scrwid*5,a2
	
	move.l	d2,d3
	and.l	#$0000ffff,d3
.findy
	cmp.w	#0,d3
	beq	.foundy
	sub.w	#1,d3
	add.l	#16*scrwid*5,a2
	bra	.findy	
.foundy
	
	move.l	#(scrwid/2)*16*5-1,d6
.copy1
	move.w	(a2)+,(a5)+
	dbra	d6,.copy1
	rts
	
.gotL
	;copy 40 chars from here <-
	;d1 has got the char pos (div scr level_wid)
	move.l	d1,d2
	divu	#level_wid,d2
	;bottom word is line
	;high word is across
	move.l	screen1,a2		;source
	add.l	#16*scrwid*5,a2
	
	move.l	d2,d3
	and.l	#$0000ffff,d3
.findy2
	cmp.w	#0,d3
	beq	.foundy2
	sub.w	#1,d3
	add.l	#16*scrwid*5,a2
	bra	.findy2	
.foundy2

	
	move.l	#(scrwid/2)*16*5-1,d6
.copy2
	move.w	(a2)+,(a5)+
	dbra	d6,.copy2

	rts

go_makelevel

	move.l	LevBase,a0	;start of the level
	
	move.l	scrbase,a1
	add.l	#(16*scrwid*5)+2,a1

	move.l	#level_hi-1,d6		;how many down
.loop2
	move.l	#level_wid-1,d7	;how many across
	move.l	a0,a3	;data
	move.l	a1,a4	;dest
.loop
	move.l	CharBase,a2
	clr.l	d0
	move.b	3(a3),d0	;get data
	move.l	d0,d1	;save it for mask
	mulu	#16*5*2,d0	;get char
	add.l	d0,a2
	
	bsr	go_make_mask
	
	bsr	go_blit_char

		
	add.l	#4,a3	;next longword data please
	add.l	#2,a4	;next screen pos please
	dbra	d7,.loop
	
	add.l	#level_wid,a0
	add.l	#level_wid,a0
	add.l	#level_wid,a0
	add.l	#level_wid,a0
	
	add.l	#scrwid*5*16,a1
	dbra	d6,.loop2

	rts
go_blit_char
	;blit a2 onto a4
	
	CALLGRAF	WaitBlit
	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#scrwid-2,$dff062	;mod B
	move.w	#scrwid-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$0dfc,$dff040

	move.l	a2,$dff050	;A
	move.l	a4,$dff04c	;dst B	screen
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058
	rts

go_make_mask
	move.l	MaskBase,a5
	mulu	#16*1*2,d1	;get mask
	add.l	d1,a5
	;a4 has the dest!
	move.l	a4,d1	;save for later
	
	move.l	#5-1,d5	;how many bitplanes!
.loop	CALLGRAF	WaitBlit

	move.l	#$ffffffff,$dff044
	move.w	#0,$dff064		;mod A
	move.w	#(scrwid*5)-2,$dff062	;mod B
	move.w	#(scrwid*5)-2,$dff066	;mod D
	move.w	#$0,$dff042
	move.w	#$0d0c,$dff040

	move.l	a5,$dff050	;A
	move.l	a4,$dff04c	;dst B	screen
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*1*64)+1,$dff058
	add.l	#scrwid,a4	;next bitplane!
	dbra	d5,.loop

	move.l	d1,a4
	rts
	
randplayer
	;do random player bit (0/1)
	clr.l	d6
.randloop	

	add.l	#1,d6	;max time checking!
	cmp.l	#players_max*2,d6
	beq	.out

	clr.l	d0
	move.b	randplay,d0
	add.b	#1,d0
	cmp.b	#players_max,d0
	bne	.ok
	move.b	#0,d0
.ok
	move.b	d0,randplay
	
	move.l	d0,d7
	lea	player1,a1
.loop
	cmp.b	#0,d7
	beq	.gotim
	sub.b	#1,d7
	add.l	#player1_nd-player1,a1	;next player
	bra	.loop
.gotim	
	cmp.b	#DEAD,play_status(a1)
	beq	.randloop
	
	
.out
	rts
go_findbads
	move.l	#0,spare
	
	;first clear out bad_no table to kill all existing ones
	lea	bad_no,a1	;pointer to baddy struct
	move.l	#bad_max-1,d7
.loop	move.l	#0,(a1)+
	dbra	d7,.loop

	;look through level data for baddies
	move.l	LevBase,a0	;point to start of level
	lea	bad_no,a1	;pointer to baddy struct
	lea	bads_list,a4	;baddy structure
		
	move.b	#bad_max,temp
	
	move.l	#16,d1	;clear y
	move.w	#level_hi-1,d6
.loop3
	clr.l	d0	;clear x
	move.w	#level_wid-1,d7
	move.l	a0,a2	;pointer to level
.loop2
	move.l	(a2)+,d5
	and.l	#$ffff0000,d5	;kill gfk information!
	swap	d5	;switch words

	lea	bad_nums,a3	;baddy numbers (attr)
	clr.l	d4
	
.loop4	cmp.l	#0,(a3,d4)	;is it a baddy anyway?
	beq	.no_bad
;	add.b	#1,random
	
	cmp.l	(a3,d4),d5	;search for baddy number
	bne	.no_bad1
	;found baddy!
	move.l	a4,(a1)+
	lea	bad_type1,a3
	PUSHALL
	bsr	create_baddy
	PULLALL
	add.l	#(bad_type1_nd-bad_type1),a4	;next struct!
	sub.b	#1,temp
	cmp.b	#0,temp
	beq	.out
	bra	.no_bad
.no_bad1
	add.l	#4,d4
	bra	.loop4
.no_bad
	add.l	#16,d0	;next x please
	dbra	d7,.loop2
	add.l	#level_wid*4,a0	;next line please
	add.l	#16,d1	;next y please
	dbra	d6,.loop3
.out	rts
create_baddy	
	;send me the following
	;a3 the baddy type structure
	;a4 the structure of the baddy
	;and i will copy the type structure (a3) in the baddy (a4)

	;*** d4 has baddy number! *4 ***
	move.b	d5,spare+1		;save for later

	move.l	a4,a5
	move.w	#(bad_type1_nd-bad_type1)-1,d5
.loop
	move.b	(a3)+,(a4)+
	dbra	d5,.loop
		
	;also you should work out x & y pos
	move.w	d0,bad_x(a5)	;save baddy x
	move.w	d1,bad_y(a5)	;save baddy y
	
	;now work out map pos
	move.w	d0,d2		;
	and.l	#$0000fff0,d2	;kill all orrible bits
	ror.w	#4,d2		;shift down
	move.b	d2,bad_mapx(a5)		;save baddy mapx

	move.w	d1,d2		;
	and.l	#$0000fff0,d2	;kill all orrible bits
	ror.w	#4,d2		;shift down
	move.b	d2,bad_mapy(a5)		;save baddy mapy

	clr.l	d2	;x
	clr.l	d3	;y
	move.w	bad_x(a5),d2	;get baddy xpos
	move.w	bad_y(a5),d3	;get baddy ypos
	
	mulu	#scrwid*5,d3	;got y
	and.w	#$fff0,d2	;do corse scrol
	ror.w	#3,d2
	add.w	d2,d3	;got coarse
	
	move.l	d3,bad_act_was(a5)	;save actual (just add scrbase)
	move.b	#OKAY,bad_status(a5)	;hey im alright 

	move.b	#3,bad_hp(a5)	

	;if its a lazer, do all this crap!
	cmp.b	#55,spare+1
	beq	.yes
	cmp.b	#56,spare+1
	beq	.yes
	bra	.no
.yes
	move.b	spare,bad_LBnk(a5)
	add.b	#1,spare
.no
BUM	ror.l	#2,d4		;get down to normal
	
	move.l	d4,d0
	add.l	#1,d0	

	;no. in d0	
	lea	asciinum,a0
	bsr	numtoasc
	
	lea	asciinum,a0
	lea	badascii,a3	;copy the numbers across
	move.b	1(a0),5(a3)
	move.b	2(a0),6(a3)
	move.b	#0,7(a3)

	move.l	BadBase,a3
	sub.l	#10,a3		;get to the start of its name again
	move.l	LDBase,d0
	add.l	LDSize,d0		;go max size
	add.l	#20,d0		;allow for fuckups!
.loop2
	move.l	#7-1,d7		;how many chars
	lea	badascii,a4		;(8 bytes)
	cmp.l	d0,a3
	bge	.lost
	cmp.b	(a4)+,(a3)+		;are they the same?
	bne	.loop2		;no
	;groovy, ive found a match
.match2	cmp.b	(a4)+,(a3)+
	bne	.loop2
	dbra	d7,.match2
	;a3 has start of baddy taglist!!!!
	
	clr.l	d0
	clr.l	d1
.taggin	cmp.b	#0,(a3)		;2 zeros terminates taglist
	bne	.workin
	cmp.b	#0,1(a3)
	beq	.donetags
.workin	
	clr.l	d0
	clr.l	d1
	move.b	(a3)+,d0		;get addr
	move.b	(a3)+,d1		;get data
	move.b	d1,(a5,d0)		;store them wherever
	bra	.taggin
.donetags
	

.lost	rts
	
go_grabbads
	lea	bad_no,a0	;point to baddy list
	move.l	bad_temp1Base,a4	;temp storage for grab
	btst	#1,switch
	bne	.loop
	move.l	bad_temp2Base,a4
	
.loop	
	move.l	(a0)+,a1		;get baddy
	cmp.l	#0,a1
	beq	.no_bads
	;a1 has baddy structure!
	cmp.b	#DYING,bad_status(a1)
	beq	.dead
	cmp.b	#DEAD,bad_status(a1)
	beq	.dead
	
	clr.l	d0	;x
	clr.l	d1	;y
	move.w	bad_x(a1),d0	;get baddy xpos
	move.w	bad_y(a1),d1	;get baddy ypos
	
	mulu	#scrwid*5,d1	;got y
	move.w	d0,d2	;save x
	and.w	#$000f,d0
	rol.w	#8,d0
	rol.w	#4,d0	;got minterm
	and.w	#$fff0,d2	;do corse scrol
	ror.w	#3,d2
	add.w	d2,d1	;got coarse
	
	move.l	bad_actual(a1),d2
	move.l	d2,bad_act_was(a1)	;save out the old actual
	move.l	d1,bad_actual(a1)	;save actual (just add scrbase)
	move.w	d0,bad_smooth(a1)	;save smooth (just add minterm)

	move.l	scrbase,a3
	add.l	d1,a3	;got grab start
	;blit a3 to a4 (screen to temp)
	
	CALLGRAF	WaitBlit

	cmp.b	#WeapLazer,bad_gun(a1)	;is he a lazer weapon (1 word wide!)	
	bne	.nolaz
	move.w	#scrwid-2,$dff064	;mod A
	move.w	#4-2,$dff066	;mod D
	move.l	a3,$dff050	;src A
	move.l	a4,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(16*5*64)+1,$dff058	;bltsize 
	
	bra	.ov
.nolaz
	;do a little loop here to check if the baddy is in a lazerzone!
	;dont use :=A0,A1,A3,A4,D0,D1,D2
	
	move.l	#bullet_max+1,d7
	
	lea	bullet_list,a2
.lazloop
	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.deadlazer
	cmp.w	#0,bull_lazx(a2)
	bne	.ok1	;its a lazer
	cmp.w	#0,bull_lazy(a2)
	beq	.deadlazer
.ok1
	;ok, its a lazer beam..... do summink!
	
	;if bad_x > bull_lazx AND bad_x2 < bull_lazx then possible kill
	;if bad_y > bull_lazy AND bad_y2 < bull_layx then possible kill
	;if both of these are TRUE then KILL murder death hurtalot
	;	destruction of the poor little baddy!
	
	clr.l	d3
	move.w	bad_x(a1),d3
	
	cmp.w	bull_lazx(a2),d3
	blt	.safe
	cmp.w	bull_lazx2(a2),d3
	bgt	.safe
	
	
	clr.l	d3
	move.w	bad_y(a1),d3
	
	cmp.w	bull_lazy(a2),d3
	blt	.safe
	cmp.w	bull_lazy2(a2),d3
	bgt	.safe
	;HAHHHAHAHAHHHHAAX KILL KILL BANG BANG YOUR DEAD KILL KILL
;	move.b	#DYING,bad_status(a1)	
	move.b	#DEAD,bad_status(a1)	
	move.w	#$fff,flash


.safe	
.deadlazer	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.lazloop
	
	move.w	#scrwid-4,$dff064	;mod A
	move.w	#4-4,$dff066	;mod D
	move.l	a3,$dff050	;src A
	move.l	a4,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(16*5*64)+2,$dff058	;bltsize 
.ov
.dead	add.l	#16*5*4,a4		;next gfk please
	bra	.loop		;repeat until skipped!

.no_bads
	rts	

go_restorebads
	lea	bad_no,a0		;baddy structure
	move.l	bad_temp1Base,a2		;grabbed space
	btst	#1,switch
	bne	.loop
	move.l	bad_temp2Base,a2

	
	
.loop	move.l	(a0)+,a1		;get bad structure
	cmp.l	#0,a1		;is end of structure
	beq	.rest_all

	cmp.b	#DEAD,bad_status(a1)
	beq	.next
	move.l	scrbase,a3
	add.l	bad_act_was(a1),a3	;add coarse
	;blit a2 to a3 please
	
	CALLGRAF	WaitBlit
	cmp.b	#WeapLazer,bad_gun(a1)	;if lazer weapon (1 word wide)
	bne	.nolazer
	move.w	#4-2,$dff064	;mod A
	move.w	#scrwid-2,$dff066	;mod D
	move.l	a2,$dff050	;src A
	move.l	a3,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(16*5*64)+1,$dff058	;bltsize 
	bra	.ov
	
.nolazer

	move.w	#4-4,$dff064	;mod A
	move.w	#scrwid-4,$dff066	;mod D
	move.l	a2,$dff050	;src A
	move.l	a3,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(16*5*64)+2,$dff058	;bltsize 
.ov	
.next	add.l	#16*5*4,a2		;next 1 please
	
	cmp.b	#DYING,bad_status(a1)
	bne	.nodying
	add.b	#1,bad_dedcnt(a1)
	cmp.b	#2,bad_dedcnt(a1)
	bne	.nodying
	move.b	#DEAD,bad_status(a1)
.nodying
	bra	.loop
.rest_all
	rts
	
go_printbads
	lea	bad_no,a0		;baddy structure
	
.loop	move.l	(a0)+,a1		;get bad structure
	cmp.l	#0,a1		;is end of structure
	beq	.plot_all

	cmp.b	#DYING,bad_status(a1)
	beq	.loop
	cmp.b	#DEAD,bad_status(a1)
	beq	.loop
	
	move.l	scrbase,a3
	add.l	bad_actual(a1),a3	;add coarse scroll

	;A = mask
	;B = source
	;C = dest
	;D = dest. (obvious really!!)
	
	CALLGRAF	WaitBlit
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm

	move.w	bad_smooth(a1),d0	;get smooth
	move.w	d0,$dff042	
	or.w	#$0fce,d0
	move.w	d0,$dff040	
	
	move.l	scrbase,a4		;get coarse
	add.l	bad_actual(a1),a4
	
	clr.l	d0
	move.l	Baddy1Base,a5

	move.b	bad_gfxnum(a1),d0
.findgfx
	cmp.l	#0,d0
	beq	.nogfx
	add.l	#80*5*32,a5
	dbra	d0,.findgfx
.nogfx
	
	clr.l	d0
;	lea	baddies,a5		;get baddies
	move.b	bad_anim(a1),d0	;get anim no.
	
	;figure out what gfk to display
	;get direction to suss which gfks to use
	clr.l	d1
	lea	bad_an_rcnt(a1),a2	;get actuall addr
	move.b	bad_an_off(a1),d1
	add.l	#1,a2		;skip counter
	add.l	d1,a2		;found bank!
	add.l	d0,a2		;found char
	
	clr.l	d0
	move.b	(a2),d0		;get char
	
	rol.l	#2,d0		;make long!
	add.l	d0,a5		;got baddy
	
	move.l	a5,a3		;get baddy mask
	add.l	#(80*16*5),a3

	cmp.b	#WeapLazer,bad_gun(a1)	;is he a lazer weapon (only 1 word wide!)
	bne	.nolaz
	move.w	#80-2,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#80-2,$dff062	;mod b
	move.w	#scrwid-2,$dff060	;mod C
	move.w	#scrwid-2,$dff066	;mod D
	
	move.l	a3,$dff050	;get mask A
	move.l	a5,$dff04c	;src B	bob
	move.l	a4,$dff048	;src C	screen
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058
	
	bra	.ov
.nolaz
	move.w	#80-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#80-4,$dff062	;mod b
	move.w	#scrwid-4,$dff060	;mod C
	move.w	#scrwid-4,$dff066	;mod D
	
	move.l	a3,$dff050	;get mask A
	move.l	a5,$dff04c	;src B	bob
	move.l	a4,$dff048	;src C	screen
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*5*64)+2,$dff058
.ov	
	bra	.loop
.plot_all

	rts

go_find_speed
	move.w	bad_x(a1),d1
	and.l	#$0000fff0,d1	;kill off old xpos fine

	clr.l	d0
	
	btst	#LOOKB_MARIO,bad_look(a1);am i in mario mode?
	beq	.marior		;nope
	;in mario mode so work out speed
	;dont corrupt d1 and put speed into d0
	lea	bad_walk,a2
	clr.l	d0
	;dont add if falling!
	btst	#BOBB_FALL,bad_doing(a1);hey! am I falling....
	bne	.dont
	
	add.b	#1,bad_mar(a1)	;next table pos
.dont	move.b	bad_mar(a1),d0
	cmp.b	bad_mar_max(a1),d0	;at max speed?
	blt	.nope
	;reached max
	sub.b	#1,bad_mar(a1)
	sub.b	#1,d0
.nope
	move.b	(a2,d0),d0		;get speed
	
	bra	.mariomoder

.marior
	move.b	bad_speed(a1),d0

.mariomoder

	rts	
setup_fall
	btst	#BOBB_FALL,bad_doing(a1)	;if already falling then dont setup
	bne	.oldun
	;first time to fall, set it all up please!
	move.b	#0,bad_fal(a1)	;reset his fall thingy
	bset	#BOBB_FALL,bad_doing(a1)	;hey! im falling....
	bset	#BOBB_DOWN,bad_go(a1)	;set going down bit please 
.oldun	cmp.b	#0,bad_mar(a1)	;slow down his x movement
	beq	.slowedx
	sub.b	#1,bad_mar(a1)	;slow down now please X
.slowedx	add.b	#1,bad_fal(a1)	;fall ya bastard!
	move.b	bad_fal(a1),d0
	cmp.b	bad_fal_max(a1),d0	;is it max
	blt	.out
	sub.b	#1,bad_fal(a1)	;at max go down 1

.out	rts
go_movebads
	lea	bad_no,a0		;baddy structure
	
.loop	move.l	(a0)+,a1		;get bad structure
	cmp.l	#0,a1		;is end of structure
	beq	.moved_all

	cmp.b	#DEAD,bad_status(a1)
	beq	.loop
	bsr	do_bad_norm
	

	bra	.loop
.moved_all
	rts

go_rand
	move.b	bad_rand2(a1),d0
	cmp.b	random,d0
	bne	.out
	btst	#BOBB_JUMP,bad_ability(a1)	;can i jump?
	beq	.no_jump		;no
	btst	#BOBB_JUMP,bad_doing(a1)	;am i already jumping?
	bne	.no_jump		;yes
	btst	#BOBB_FALL,bad_doing(a1)	;dont jump if falling
	bne	.no_jump		;sorry, falling
	bset	#BOBB_JUMP,bad_doing(a1)	;hey jump!
	move.b	#24,bad_jmp_pos(a1)	;starting jump no.!
.no_jump
.out
	rts
do_bad_norm	;dont corrupt a0 (a1 is your structure)


	bsr	go_rand
	bsr	go_shoot
	bsr	anim_baddy

	btst	#BOBB_RIGHT,bad_go(a1)	;am i going right?
	beq	.not_right

;	bsr	anim_baddy

	bsr	go_find_speed	;gets baddy speed (d0=new/d1=old)

	add.w	d0,bad_x(a1)	;move right please

	;if not a platform dude then skip all this crap
	btst	#BOBB_PLAT,bad_ability(a1)
	beq	.nock
	
	add.b	d0,bad_platx(a1)
	cmp.b	#32,bad_platx(a1)
	ble	.nock
	sub.b	#16,bad_platx(a1)

	cmp.b	#21,bad_mapx(a1)
	blt	.onscree
	move.b	#21,bad_mapx(a1)
	move.w	#21*16,bad_x(a1)
	move.b	#16,bad_platx(a1)
	bra	.jumpsu
.onscree
	add.b	#1,bad_mapx(a1)
.jumpsu

	;if hes jumping then dont check collision
	btst	#BOBB_JUMP,bad_doing(a1)
	bne	.nock
	btst	#BOBB_FALL,bad_doing(a1)
	bne	.nock
	
	;if bit 8 is set then check what he walking on
	btst	#BOBB_PLAT,bad_ability(a1)
	beq	.nock
;this will check what to the right!
	move.b	bad_mapx(a1),d0
;	add.b	#1,d0		;check 1 extra to the right
	move.b	bad_mapy(a1),d1
	bsr	find_char		;get whats below me (d0)
	lea	walk_thru,a2	;what chars can you walk thru
.find_side1
	cmp.b	#0,(a2)
	beq	.ok		;hes not running into anything
	
	cmp.b	(a2)+,d0	;is it thru char?
	beq	.turn	;yes
	bra	.find_side1
.ok

;this will check what to the right up!
	;if jumping or falling!
	btst	#BOBB_JUMP,bad_doing(a1)
	bne	.docheckur
	btst	#BOBB_FALL,bad_doing(a1)
	bne	.docheckur
	bra	.okur
.docheckur
	move.b	bad_mapx(a1),d0
	move.b	bad_mapy(a1),d1
	add.b	#1,d1		;check 1 extra above right
	bsr	find_char		;get whats below me (d0)
	lea	walk_thru,a2	;what chars can you walk thru
.find_topside1
	cmp.b	#0,(a2)
	beq	.okur		;hes not running into anything
	
	cmp.b	(a2)+,d0	;is it thru char?
	beq	.turn	;yes
	bra	.find_topside1
.okur

;this will check what hes walking on!
	move.b	bad_mapx(a1),d0
	btst	#BOBB_FALL,bad_ability(a1)
	bne	.canf
	add.b	#1,d0		;check 1 extra to the right
.canf
;	add.b	#1,d0		;check 1 extra to the right
	move.b	bad_mapy(a1),d1
	add.b	#1,d1
	bsr	find_char		;get whats below me (d0)
	lea	walk_on,a2		;what chars can you walk on
.find_floor2
	cmp.b	#0,(a2)
	beq	.setup_fallr
	cmp.b	(a2)+,d0
	bne	.find_floor2
	bra	.same
.setup_fallr
	btst	#BOBB_FALL,bad_ability(a1)
	beq	.turn		;cant fall!! so turn him

	bsr	setup_fall
.same
	
.nock
	
	cmp.w	#320+16-16,bad_x(a1)	;edge of screen?
	blt	.okay
	move.w	#320+16-16,bad_x(a1)	;edge of screen?
	move.b	#20,bad_mapx(a1)

.turn	;at edge, please turn around

	move.w	bad_x(a1),d0
	and.w	#$fff0,d0
	move.w	d0,bad_x(a1)
	move.b	#16,bad_platx(a1)
	;if a mario baddy then reset bad_mar counter to 0
	btst	#LOOKB_MARIO,bad_look(a1)	;am i in mario mode?
	beq	.no_reset_marior		;nope
	move.b	#0,bad_mar(a1)
.no_reset_marior

	bclr	#BOBB_RIGHT,bad_go(a1)	;clear right
	bset	#BOBB_LEFT,bad_go(a1)	;set left
	move.b	#9,bad_an_off(a1)	;set his gfx left
.okay
	bra	.not_left
.not_right
	btst	#BOBB_LEFT,bad_go(a1)	;am i going left?
	beq	.not_left

;	bsr	anim_baddy

	bsr	go_find_speed	;gets baddy speed (d0=new/d1=old)
	
	sub.w	d0,bad_x(a1)	;move left please

	;if not a platform dude then skip all this crap
	btst	#BOBB_PLAT,bad_ability(a1)
	beq	.same2

	sub.b	d0,bad_platx(a1)
	cmp.b	#0,bad_platx(a1)
	bge	.same2
	add.b	#16,bad_platx(a1)

	cmp.b	#0,bad_mapx(a1)
	bgt	.onscreen
	;shit off screen
	move.w	#0,bad_x(a1)	;reset
	bra	.jumpsub
.onscreen
	sub.b	#1,bad_mapx(a1)
.jumpsub

	;if hes jumping then dont check collision
	btst	#BOBB_JUMP,bad_doing(a1)
	bne	.same2
	btst	#BOBB_FALL,bad_doing(a1)
	bne	.same2

	;if bit 8 is set then check what he walking on
	btst	#BOBB_PLAT,bad_ability(a1)
	beq	.same2
;this will check what to the left!
	move.b	bad_mapx(a1),d0
	move.b	bad_mapy(a1),d1
	bsr	find_char		;get whats below me (d0)
	lea	walk_thru,a2	;what chars can you walk thru
.find_side2
	cmp.b	#0,(a2)
	beq	.ok2		;hes not running into anything
	
	cmp.b	(a2)+,d0	;is it thru char?
	beq	.turn2	;yes
	bra	.find_side2
.ok2
;this will check what to the left up!
	;if jumping or falling!
	btst	#BOBB_JUMP,bad_doing(a1)
	bne	.docheckul
	btst	#BOBB_FALL,bad_doing(a1)
	bne	.docheckul
	bra	.okul
.docheckul
	move.b	bad_mapx(a1),d0

	move.b	bad_mapy(a1),d1
	add.b	#1,d1		;check 1 extra above right
	bsr	find_char		;get whats below me (d0)
	lea	walk_thru,a2	;what chars can you walk thru
.find_topside2
	cmp.b	#0,(a2)
	beq	.okul		;hes not running into anything
	
	cmp.b	(a2)+,d0	;is it thru char?
	beq	.turn2	;yes
	bra	.find_topside2
.okul

;this will check what hes walking on
	move.b	bad_mapx(a1),d0
	btst	#BOBB_FALL,bad_ability(a1)
	bne	.canfa
	sub.b	#1,d0		;check 1 extra to the right
.canfa

	move.b	bad_mapy(a1),d1
	add.b	#1,d1
	bsr	find_char		;get whats below me (d0)	
	lea	walk_on,a2		;what chars can you walk on
.find_floor	cmp.b	#0,(a2)
	beq	.setup_falll
	cmp.b	(a2)+,d0
	bne	.find_floor
	bra	.same2
.setup_falll
	btst	#BOBB_FALL,bad_ability(a1)
	beq	.turn2
	
	bsr	setup_fall

.same2

	cmp.w	#16,bad_x(a1)	;edge of screen?
	bgt	.okay2
	move.w	#16,bad_x(a1)
	bra	.banana
.turn2	;at edge, please turn around
	move.w	bad_x(a1),d0
	or.w	#$000f,d0
	move.w	d0,bad_x(a1)
	move.b	#16,bad_platx(a1)
.banana
	;if a mario baddy then reset bad_mar counter to 0
	btst	#LOOKB_MARIO,bad_look(a1)		;am i in mario mode?
	beq	.no_reset_mariol		;nope
	move.b	#0,bad_mar(a1)
.no_reset_mariol


	bclr	#BOBB_LEFT,bad_go(a1)	;clear left
	bset	#BOBB_RIGHT,bad_go(a1)	;set right
	move.b	#0,bad_an_off(a1)	;set his gfx right
.okay2
	bra	.not_left
.not_left

	;dont do this routine if im jumping
	btst	#BOBB_JUMP,bad_doing(a1);am i jumping?
	bne	.not_down		;yes, skip it all
	
	btst	#BOBB_DOWN,bad_go(a1)	;am i going down?
	beq	.not_down

	btst	#BOBB_FALL,bad_doing(a1);hey! am i falling....
	beq	.notfall
	move.b	bad_fal(a1),d0
	cmp.b	bad_fal_max(a1),d0	;is it max
	blt	.fallmax
	sub.b	#1,bad_fal(a1)	;at max go down 1
.fallmax
	bra	.falling


.notfall

.falling
	move.w	bad_y(a1),d1
	and.l	#$0000fff0,d1	;kill off old xpos fine


	lea	bad_walk,a2
	clr.l	d0
	
	add.b	#1,bad_fal(a1)	;next table pos
	move.b	bad_fal(a1),d0
	cmp.b	bad_fal_max(a1),d0	;at max speed?
	blt	.freefal
	;reached max
	sub.b	#1,bad_fal(a1)
	sub.b	#1,d0
.freefal
	move.b	(a2,d0),d0		;get speed
	


	add.w	d0,bad_y(a1)	;move down please

	move.w	bad_y(a1),d0	;
	and.l	#$0000fff0,d0	;kill off new xpos fine
	cmp.b	d0,d1
	beq	.same3		;hasnt crossed boundary!
	add.b	#1,bad_mapy(a1)

	btst	#BOBB_PLAT,bad_ability(a1)
	beq	.nock
;this will check under
	move.b	bad_mapx(a1),d0
	move.b	bad_mapy(a1),d1
	add.b	#1,d1
	;if moving to the right then add #1,d0 (unless speed = 0????)
;	add.b	#1,d0


	bsr	find_char		;get whats below me (d0)
	lea	walk_on,a2	;what chars can you walk on
.find_under1
	cmp.b	#0,(a2)
	beq	.morefall		;hes not running on anything
	
	cmp.b	(a2)+,d0	;is it on char?
	bne	.find_under1	;no
	;right, summink i can walk on!
	bclr	#BOBB_DOWN,bad_go(a1)	;clear going down?
	bclr	#BOBB_FALL,bad_doing(a1)	;clear falling....
	move.b	#0,bad_fal(a1)	;clear fall couhter
	move.w	bad_y(a1),d0
	and.w	#$fff0,d0		;put him on the top of the char
	move.w	d0,bad_y(a1)	;store it again
	bra	.not_down
	
.morefall
	;get platx if under 16 then sub 1 d0
	;if over 16 then add 1 d0
	clr.l	d0
	clr.l	d1
	move.b	bad_mapx(a1),d0
	move.b	bad_mapy(a1),d1
	add.b	#1,d1

	
	cmp.b	#16,bad_platx(a1)	;check smooth scroll
	bgt	.over16
	blt	.under16
	beq	.same3
.over16
	add.l	#1,d0
	bra	.check
.under16
	sub.l	#1,d0
.check
	bsr	find_char		;get whats below me (d0)
	lea	walk_on,a2	;what chars can you walk on
.find_underm
	cmp.b	#0,(a2)
	beq	.same3		;hes not running on anything
	
	cmp.b	(a2)+,d0	;is it on char?
	bne	.find_underm	;no
	;right, summink i can walk on!
	bclr	#BOBB_DOWN,bad_go(a1)	;clear going down?
	bclr	#BOBB_FALL,bad_doing(a1)	;clear falling....
	move.b	#0,bad_fal(a1)	;clear fall couhter
	move.w	bad_y(a1),d0
	and.w	#$fff0,d0		;put him on the top of the char
	move.w	d0,bad_y(a1)	;store it again
	bra	.not_down

.same3

	cmp.w	#(scrhi*16)-16,bad_y(a1)	;edge of screen?
	blt	.okay3

	;if falling off screen reset him to top
	move.b	#0,bad_mapy(a1)
	move.w	#0,bad_y(a1)
	
	;at edge, please turn around
;	bclr	#BOBB_DOWN,bad_go(a1)	;clear down
;	bset	#BOBB_UP,bad_go(a1)	;set up
.okay3
	bra	.not_up
.not_down

	;am i jumping?
	btst	#BOBB_JUMP,bad_doing(a1)
	bne	.over
	
	btst	#BOBB_UP,bad_go(a1)	;am i going up?
	beq	.not_up

.over	move.w	bad_y(a1),d1
	and.l	#$0000fff0,d1	;kill off old xpos fine

	clr.l	d0
	;if in jump mode then get speed!
	btst	#BOBB_JUMP,bad_doing(a1)
	beq	.skipd0		;not jumping
	cmp.b	#0,bad_jmp_pos(a1)
	bne	.no_climax
	;reached top of jump. now switch off jump and gravity do the rest!
	bclr	#BOBB_JUMP,bad_doing(a1)	;stop jumpping ya bastard
	bset	#BOBB_FALL,bad_doing(a1)	;fall ya bastard
	bset	#BOBB_DOWN,bad_go(a1)	;set going down bit please 
	move.b	#0,bad_fal(a1)
	;if char under is walkonable then sort out ypos
;	move.w	bad_y(a1),d0
;	and.w	#$fff0,d0
;	move.w	d0,bad_y(a1)
;	sub.b	#1,bad_mapy(a1)
	bra	.not_up
.no_climax
	sub.b	#1,bad_jmp_pos(a1)
	move.b	bad_jmp_pos(a1),d0	;get the counter
	lea	bad_jump,a2
	move.b	(a2,d0),d0		;got the speed!
	bra	.skipd0
	
	
	move.b	bad_speed(a1),d0
.skipd0
	sub.w	d0,bad_y(a1)	;move up please

	move.w	bad_y(a1),d0	;
	and.l	#$0000fff0,d0	;kill off new xpos fine
	cmp.b	d0,d1
	beq	.same4		;hasnt crossed boundary!
	sub.b	#1,bad_mapy(a1)
	;check above baddy just for walk_thru chars
	move.b	bad_mapx(a1),d0
	move.b	bad_mapy(a1),d1
;	add.b	#1,d1
	;if moving to the right then add #1,d0 (unless speed = 0????)
;	add.b	#1,d0


	bsr	find_char		;get whats below me (d0)
	lea	walk_thru,a2	;what chars can you walk thru
.find_above1
	cmp.b	#0,(a2)
	beq	.same4		;its ok.
	cmp.b	(a2)+,d0
	bne	.find_above1	;keep looking!
	;damn, he cant jump up through this block. kill off his jump!
	add.b	#1,bad_mapy(a1)	;reset coarse
	add.w	#16,bad_y(a1)
	move.w	bad_y(a1),d0
	and.l	#$0000fff0,d0
	move.w	d0,bad_y(a1)
	bclr	#BOBB_JUMP,bad_doing(a1)	;clr jumping bit
	move.b	#0,bad_jmp_pos(a1)	;reset jump counter!
	bra	.not_up




.same4

	cmp.w	#0,bad_y(a1)	;edge of screen?
	bgt	.okay4
	;at edge, please turn around
	move.w	#0,bad_y(a1)
	move.b	#0,bad_mapy(a1)
	bclr	#BOBB_UP,bad_go(a1)	;clear up
	bset	#BOBB_DOWN,bad_go(a1)	;set down
.okay4
	bra	.not_up
.not_up


	rts

go_printguns

	move.b	#1,PlayerGun

	move.l	#gun_max-1,d7

	lea	gun_list,a2
	bra	mainprintbull



go_printbullets

;change the next 2 lines to acc.....

	move.l	#bullet_max-1,d7

	lea	bullet_list,a2


mainprintbull
	
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#40-4,$dff062	;mod b
	move.w	#scrwid-4,$dff060	;mod C
	move.w	#scrwid-4,$dff066	;mod D

.loop
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.bulldead

	cmp.b	#DEAD,bull_status(a2)
	beq	.bulldead
	cmp.b	#DYING,bull_status(a2)	;on his way
	beq	.bulldead

	;A = mask
	;B = source
	;C = dest
	;D = dest. (obvious really!!)

	move.w	bull_smooth(a2),d0	;get smooth
	move.w	d0,$dff042	
	or.w	#$0fce,d0
	move.w	d0,$dff040	
	
	move.l	scrbase,a4		;get coarse
	add.l	bull_actual(a2),a4

	clr.l	d0
	move.b	bull_wantgo(a2),d0	;find what gfk to use
	btst	#BOBB_LEFT,d0
	beq	.goingr
	move.l	#4,d0
	bra	.skip
.goingr
	clr.l	d0
.skip		
	move.l	Bullet1Base,a5
	clr.l	d1
	move.w	bull_gfk(a2),d1
	
	
	;if d1 > 40 then add 40*16*5,a5
.loopin
	cmp.b	#40,d1
	bmi	.ok
	add.l	#80*16*5,a5
	sub.l	#40,d1
	bra	.loopin
.ok
	add.l	d1,a5
	

	move.l	a5,a3
	add.l	#40*16*5,a3		;get to mask!
	add.l	d0,a3
	add.l	d0,a5
	
	move.l	a3,$dff050	;get mask A
	move.l	a5,$dff04c	;src B	bob
	move.l	a4,$dff048	;src C	screen
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*5*64)+2,$dff058

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL

.bulldead
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop

	move.b	#0,PlayerGun
	rts

go_printlazer

;change the next 2 lines to acc.....

	move.l	#bullet_max-1,d7

	lea	bullet_list,a2

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL

	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-2,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-2,$dff066	;mod D

	move.w	#0,$dff042	
	move.w	#$09f0,$dff040	


.loop
	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.bulldead
	
	cmp.b	#DEAD,bull_status(a2)
	beq	.bulldead
;	cmp.b	#DYING,bull_status(a2)	;on his way
;	beq	.bulldead

	;if bull_life = 0 then the lazer has done enough damage for one da
	;bull_Lest has the screen offset to restore!
	;bull_cnt has the counter for restoring

	cmp.b	#0,bull_life(a2)
	bne	.norest
	;fuck, the lazer has finished and watns to be restored!
	bsr	restlazer
	bra	.bulldead
.norest
	move.l	Bullet1Base,a5
	clr.l	d1
	move.w	bull_gfk(a2),d1
	
	
	;if d1 > 40 then add 40*16*5,a5
.loopin
	cmp.b	#40,d1
	bmi	.ok
	add.l	#80*16*5,a5
	sub.l	#40,d1
	bra	.loopin
.ok
	add.l	d1,a5


	move.l	screen1,a4		;get coarse
	add.l	bull_actual(a2),a4

	move.l	a5,$dff050	;get mask A
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL

	move.l	screen2,a4		;get coarse
	add.l	bull_actual(a2),a4

	move.l	a5,$dff050	;get mask A
	move.l	a4,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL

	PUSHALL
	clr.l	d0
	clr.l	d1
	move.w	bull_xpos(a2),d0
	move.w	bull_ypos(a2),d1
	move.l	LevBase,a0
	bsr	DestroyPform
	PULLALL


.bulldead
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL

	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-4,$dff066	;mod D

	rts
restlazer
	move.l	#0,spare
	;DONT TRASH A2 or D7
;	move.w	$dff006,d0
;	and.l	#$fff,d0
;	move.w	d0,$dff180

	;source
	move.l	lazertempBase,a1 *** screen+ whatever for testing ***

	clr.l	d0
	move.b	bull_LBnk(a2),d0
	mulu	#scrwid*16*5,d0
	add.l	d0,a1

	move.l	screen1,a0
	add.l	bull_Lrest(a2),a0	;that there is the destination
	;now get the bullets direction to see if we add or sub 2

	;if bullet = right then a0=a0+2
	;	add.l	(bull_Lcnt(a2)*2),a1

	btst	#BOBB_RIGHT,bull_go(a2)
	beq	.notright
	;hes heading to the right!
	add.w	#16,bull_xpos(a2)
	add.w	#16,bull_lazx(a2)
	clr.l	d5
	move.b	bull_Lcnt(a2),d5
	add.l	d5,a1
	add.l	d5,a1
	add.l	#2,a0
	add.l	#2,bull_Lrest(a2)
	
	add.l	#2,a1
	
	move.l	a0,spare
	
	move.l	#16-1,d5		;no lines!
.copyr1
	move.w	(a1),(a0)
	move.w	1*scrwid(a1),1*scrwid(a0)
	move.w	2*scrwid(a1),2*scrwid(a0)
	move.w	3*scrwid(a1),3*scrwid(a0)
	move.w	4*scrwid(a1),4*scrwid(a0)
	add.l	#scrwid*5,a1
	add.l	#scrwid*5,a0
	dbra	d5,.copyr1
	
	add.b	#1,bull_Lcnt(a2)
	cmp.b	#scrwid/2,bull_Lcnt(a2)
	bne	.notright
	bsr	kill_bullet
	
.notright
	btst	#BOBB_LEFT,bull_go(a2)
	beq	.notleft
	;hes heading to the leftt!
	sub.w	#16,bull_xpos(a2)
	sub.w	#16,bull_lazx2(a2)
	clr.l	d5
	move.b	bull_Lcnt(a2),d5
	add.l	d5,a1
	add.l	d5,a1
	add.l	#2,a0
	sub.l	#2,bull_Lrest(a2)
	
	add.l	#2,a1
	move.l	a0,spare

	
	move.l	#16-1,d5		;no lines!
.copyl1
	move.w	(a1),(a0)
	move.w	1*scrwid(a1),1*scrwid(a0)
	move.w	2*scrwid(a1),2*scrwid(a0)
	move.w	3*scrwid(a1),3*scrwid(a0)
	move.w	4*scrwid(a1),4*scrwid(a0)
	add.l	#scrwid*5,a1
	add.l	#scrwid*5,a0
	dbra	d5,.copyl1
	
	sub.b	#1,bull_Lcnt(a2)
	cmp.b	#-2,bull_Lcnt(a2)
	bne	.notleft
	bsr	kill_bullet
.notleft	
	;spare should have the screen address to blit
	cmp.l	#0,spare
	beq	.out
	
	move.l	spare,a1
	move.l	spare,a0	;source
	sub.l	screen1,a1
	add.l	screen2,a1	;dest

	;the mintermws have been set up by the print lazer rtn

	move.w	#scrwid-2,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-2,$dff066	;mod D

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL

	move.l	a0,$dff050	;get mask A
	move.l	a1,$dff054	;dst D	screen
	move.w	#(16*5*64)+1,$dff058

.out	
	rts

DestroyPform
	;ok, d0,d1 have x&y in pixies!
	;and A0 has the start pointer to the level!
	
	sub.w	#1,d0	;minor frigging
	sub.w	#1,d1
	;now work out map pos
	clr.l	d2
	move.w	d0,d2		;
	and.l	#$0000fff0,d2	;kill all orrible bits
	ror.w	#4,d2		;shift down
	and.l	#$0000ffff,d2
	add.l	d2,a0	;
	add.l	d2,a0	;
	add.l	d2,a0	;
	add.l	d2,a0	;add map xpos to level

	move.w	d1,d2		;
	and.l	#$0000fff0,d2	;kill all orrible bits
	ror.w	#4,d2		;shift down
	mulu	#level_wid*4,d2
	add.l	d2,a0
	
	;this points to a long word on the map
	;the forst word is the attr (I think)
	;and the 2nd word is the block..
	;so zap if youd be so kind, the 2nd word...
	
	add.l	#2,a0
	move.w	#0,(a0)		;kill it till dead!


	rts

go_lazerzone
	move.l	#bullet_max-1,d7

	lea	bullet_list,a0
.loop
	cmp.b	#WeapLazer,bull_gun(a0)
	bne	.bulldead
	
	cmp.b	#DEAD,bull_status(a0)
	beq	.bulldead
	
	lea	player1,a1
	move.b	num_players,d6
.chkplay
	cmp.b	#DEAD,play_status(a1)	
	beq	.playdead
	
.playdead


.bulldead
	add.l	#bullet_nd-bullet,a0	;next bullet
	dbra	d7,.loop

	rts	

go_grabguns	
	move.b	#1,PlayerGun


	move.l	#gun_max-1,d7

	lea	gun_list,a2		;point to 1st bullet structure
	move.l	gun_temp1Base,a4	;temp storage for grab
	btst	#1,switch
	bne	maingrabbull
	move.l	gun_temp2Base,a4	;grab/rest place
	bra	maingrabbull

go_grabbullets

;for the players, change the next 6 numbers to acc.


	move.l	#bullet_max-1,d7

	lea	bullet_list,a2		;point to 1st bullet structure
	move.l	bullet_temp1Base,a4	;temp storage for grab
	btst	#1,switch
	bne	maingrabbull
	move.l	bullet_temp2Base,a4	;grab/rest place



maingrabbull
.loop
	cmp.b	#DEAD,bull_status(a2)
	beq	.bulldead
;	cmp.b	#DYING,bull_status(a2)	;on his way
;	beq	.bulldead












	;do a little loop here to check if the baddy is in a lazerzone!
	;dont use :=A2,A4,D0,D1,D2,D7
	
	;if the gun is a lazer then dont check it!!!!!!
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.nolazchk
;	bra	.nolazchk
	
	
	move.l	#bullet_max+1,d6
	
	lea	bullet_list,a3
.lazloop
	cmp.b	#WeapLazer,bull_gun(a3)
	bne	.deadlazer
	cmp.w	#0,bull_lazx(a3)
	bne	.ok1	;its a lazer
	cmp.w	#0,bull_lazy(a3)
	beq	.deadlazer
.ok1
	;ok, its a lazer beam..... do summink!
	
	;if bad_x > bull_lazx AND bad_x2 < bull_lazx then possible kill
	;if bad_y > bull_lazy AND bad_y2 < bull_layx then possible kill
	;if both of these are TRUE then KILL murder death hurtalot
	;	destruction of the poor little baddy!
	
	clr.l	d3
	move.w	bull_xpos(a2),d3
	
	cmp.w	bull_lazx(a3),d3
	blt	.safe
	cmp.w	bull_lazx2(a3),d3
	bgt	.safe
	
	
	clr.l	d3
	move.w	bull_ypos(a2),d3
	
	cmp.w	bull_lazy(a3),d3
	blt	.safe
	cmp.w	bull_lazy2(a3),d3
	bgt	.safe
	;HAHHHAHAHAHHHHAAX KILL KILL BANG BANG YOUR DEAD KILL KILL
;	move.b	#DYING,bull_status(a2)	
	move.b	#DEAD,bull_status(a2)	

	move.l	a1,spare
	move.l	bull_paddr(a2),a1
	;if bullet is from the player then dec the players bullet counter..
	cmp.b	#1,PlayerGun
	bne	.ok
	;its the players bullet...
	sub.b	#1,play_maxbullscnt(a1)
.ok
	move.l	spare,a1
	
	bsr	kill_bullet

	move.w	#$fff,flash


.safe	
.deadlazer	add.l	#bullet_nd-bullet,a3	;next bullet
	dbra	d6,.lazloop
.nolazchk
























	CALLGRAF	WaitBlit
	move.l	bull_actual(a2),bull_was(a2)
	clr.l	d0
	clr.l	d1
	clr.l	d2
	move.w	bull_xpos(a2),d0
	move.w	bull_ypos(a2),d1
	mulu	#scrwid*5,d1

	move.w	d0,d2	;save x
	and.w	#$000f,d0
	rol.w	#8,d0
	rol.w	#4,d0	;got minterm
	and.w	#$fff0,d2	;do corse scrol
	ror.w	#3,d2
	add.w	d2,d1	;got coarse
	move.l	d1,bull_actual(a2)	;save coarse scroll
	move.w	d0,bull_smooth(a2)	;save smooth	
	
	;if playwas = 0 then copy actual into it
	cmp.l	#0,bull_was(a2)
	bne	.okay
	move.l	bull_actual(a2),bull_was(a2)
.okay

	;if bullet is a Lazer then dont restore it!
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.bulldead

	add.l	scrbase,d1	
	move.w	#scrwid-4,$dff064	;mod A
	move.w	#4-4,$dff066	;mod D
	move.l	d1,$dff050	;src A
	move.l	a4,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(16*5*64)+2,$dff058	;bltsize 

	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL	
.bulldead
	add.l	#16*4*5,a4	;next grab place please
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop

	move.b	#0,PlayerGun

	rts

go_restoreguns
;the is for the players gun
	move.b	#1,PlayerGun

	move.l	#gun_max-1,d7
	lea	gun_list,a2	;bullet structure
	move.l	gun_temp1Base,a4	;grabbed space
	btst	#1,switch
	bne	mainbull
	move.l	gun_temp2Base,a4
	bra	mainbull


go_restorebullets
;origonal idea was
;if bull_status = NEW then dont retore yet (as I may not have been setup yet)
;	then bull_status = OKAY dont restore.
;but afterwards i thought it was not needed.



;for the players bullet restore rtn.
;copy n change the next 6 lines to work with the gun bits



	move.l	#bullet_max-1,d7
	lea	bullet_list,a2	;bullet structure
	move.l	bullet_temp1Base,a4	;grabbed space
	btst	#1,switch
	bne	mainbull
	move.l	bullet_temp2Base,a4





mainbull	
.loop
	cmp.b	#DEAD,bull_status(a2)
	beq	.bulletdead

	cmp.b	#NEW,bull_status(a2)
	bne	.notnew
	move.b	#OKAY,bull_status(a2)
	bra	.bulletdead
.notnew
	cmp.b	#DYING,bull_status(a2)	;just restore when dying then make DEAD
	bne	.notdying
;	add.b	#1,bull_dedcnt(a2)
;	cmp.b	#2,bull_dedcnt(a2)
;	bne	.notdying
	move.b	#DEAD,bull_status(a2)

	;if bullet is from the player then dec the players bullet counter..
	cmp.b	#1,PlayerGun
	bne	.notdying
	;its the players bullet...
	move.l	a1,RegSave
	move.l	bull_paddr(a2),a1
	sub.b	#1,play_maxbullscnt(a1)
	move.l	RegSave,a1
.notdying
	
	;if bullet is a Lazer then dont restore it!
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.bulletdead
	


	move.l	scrbase,a3
	add.l	bull_was(a2),a3	;add coarse
	;blit a4 to a3 please
	
	move.w	#4-4,$dff064	;mod A
	move.w	#scrwid-4,$dff066	;mod D
	move.l	a4,$dff050	;src A
	move.l	a3,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(16*5*64)+2,$dff058	;bltsize 
	PUSHALL
	CALLGRAF	WaitBlit
	PULLALL	
	
.bulletdead
	add.l	#16*5*4,a4		;next 1 please
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop

	move.b	#0,PlayerGun
	rts

kill_bullet
	;bullets died. kill him off properly!
	move.b	#DYING,bull_status(a2)
	move.b	#0,bull_dedcnt(a2)
	move.l	a1,spare
	move.l	bull_paddr(a2),a1
	bclr	#BOBB_GUN2,bad_doing(a1)
	move.w	#0,bull_lazx(a1)
	move.w	#0,bull_lazx2(a1)
	move.w	#0,bull_lazy(a1)
	move.w	#0,bull_lazy2(a1)

	move.l	spare,a1



	
	rts

how_fastx	
	clr.l	d2

	cmp.b	#0,bull_waitx(a2)
	beq	.normal
	cmp.b	#0,waitflag
	bne	.hop
	add.b	#1,bull_waitx(a2)	;bullet is moving slower than 1pix vblank
.hop	cmp.b	#0,bull_waitx(a2)
	bge	.notdone
	move.l	#1,d2
	rts
.notdone
	move.l	#1,d0	;END of Waiting. move 1 pixxie please
	move.l	#0,d2
	rts
.normal
	move.w	bull_life(a2),d1
	cmp.w	#0,d1
	bne	.notzero

	;if bull_life=0 and gun type is smart then bull_life = ffff
	cmp.b	#WeapSmart,bull_gun(a2)
	bne	.notsmart
	bclr	#BOBB_UP,bull_go(a2)
	bset	#BOBB_DOWN,bull_go(a2)
	move.w	#$ffff,bull_life(a2)
	move.w	#SmartLife,bull_life2(a2)
	bra	.notzero
.notsmart
	;its zero, so ive run out of puff
	clr.l	d1
	move.b	bull_speedx(a2),d1
	cmp.b	#0,d1
	bne	.slowme

	cmp.l	#1,d2
	bne	.slowing	;slowing down to change dir
	;im turning around
	bchg	#BOBB_LEFT,bull_go(a2)
	bchg	#BOBB_RIGHT,bull_go(a2)
	move.l	#2,d2
	rts
.slowing
	;bullets died. kill him off properly!
	
	;unless falling to gravity
	btst	#ATTRB_GRAV,bull_attr(a2)
	bne	.out	
	
	bsr	kill_bullet
.out	move.l	#2,d2
	rts
.slowme
	;if bits GRAV or AGRAV are set then just set down!
	;        ^^^^
	btst	#ATTRB_GRAV,bull_attr(a2)
	beq	.nogravity
	bset	#BOBB_DOWN,bull_go(a2)
	bset	#BOBB_DOWN,bull_cango(a2)
	bset	#BOBB_DOWN,bull_wantgo(a2)
	move.b	#1,bull_stepx(a2)
	move.b	#2,bull_stepy(a2)
	
.nogravity

	clr.l	d1
	move.b	bull_stepx(a2),d1
	sub.b	d1,bull_speedx(a2)
	clr.l	d1
		
	bra	.over1
.notzero
	btst	#ATTRB_SEEKX,bull_attr(a2)	;if not seek x then .notzero2
	beq	.notzero2
;	cmp.b	#WeapSmart,bull_gun(a2)
;	bne	.notzero2
	clr.l	d0
	clr.l	d1
	move.b	bull_wantgo(a2),d0
	move.b	bull_go(a2),d1
	and.b	#BOBF_LEFT|BOBF_RIGHT,d0
	and.b	#BOBF_LEFT|BOBF_RIGHT,d1
	cmp.b	d0,d1
	beq	.notzero2
	;bull wants to change direction, so slow him down
	move.l	#1,d2	;trigger notsmarts slow rtn
	bra	.notsmart
	
.notzero2	
	clr.l	d1
	move.b	bull_speedx(a2),d1
	cmp.b	bull_maxx(a2),d1
	bge	.over1
	move.b	bull_stepx(a2),d1
	add.b	d1,bull_speedx(a2)
.over1
	clr.l	d0
	lea	bull_table,a3
	move.b	bull_speedx(a2),d1
	move.b	(a3,d1),d0	

	btst	#7,d0
	beq	.positive
	;number is negative, so wait a while
	move.b	d0,bull_waitx(a2)
	move.l	#2,d2
	rts
.positive	
	move.l	#0,d2
	rts

how_fasty
	clr.l	d2

	cmp.b	#0,bull_waity(a2)
	beq	.normal
	cmp.b	#0,waitflag
	bne	.hop
	add.b	#1,bull_waity(a2)	;bullet is moving slower than 1pix vblank
.hop	cmp.b	#0,bull_waity(a2)
	bge	.notdone
	move.l	#1,d2
	rts
.notdone
	move.l	#1,d0	;END of Waiting. move 1 pixxie please
	move.l	#0,d2
	rts
.normal

	move.w	bull_life(a2),d1
	cmp.w	#0,d1
	bne	.notzero

	;if its a lazer then it doesnt all to gravity!!!!!
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.oopuff
	
	btst	#ATTRB_GRAV,bull_attr(a2)
	beq	.carryon
	btst	#BOBB_DOWN,bull_go(a2)
	bne	.notzero2	;accelerate please

.carryon	;if bull_life=0 and gun type is smart then bull_life = ffff
	cmp.b	#WeapSmart,bull_gun(a2)
	bne	.notsmart
	bclr	#BOBB_UP,bull_go(a2)
	bset	#BOBB_DOWN,bull_go(a2)
	move.w	#$ffff,bull_life(a2)
	move.w	#SmartLife,bull_life2(a2)
	bra	.notzero
.notsmart

.oopuff
	;its zero, so ive run out of puff
	clr.l	d1
	move.b	bull_speedy(a2),d1
	cmp.b	#0,d1
	bne	.slowme
	
	;GRAV ive slowed down so now make me go down
	btst	#ATTRB_GRAV,bull_attr(a2)
	bne	.change
	
	cmp.l	#1,d2
	bne	.slowing	;slowing down to change dir
.change	;im turning around

	move.w	#$999,d7
.llo
	move.w	#$f00,$dff180
	dbra	d7,.llo
	
	
	bchg	#BOBB_UP,bull_go(a2)
	bchg	#BOBB_DOWN,bull_go(a2)	;falling ....aaaahhh....
	move.l	#2,d2
	rts
.slowing
	bsr	kill_bullet
	move.l	#2,d2
	rts
.slowme
	clr.l	d1
	move.b	bull_stepy(a2),d1
	sub.b	d1,bull_speedy(a2)
	clr.l	d1
		
	bra	.over1
.notzero
	btst	#ATTRB_SEEKY,bull_attr(a2)
	beq	.notzero2
;	cmp.b	#WeapSmart,bull_gun(a2)
;	bne	.notzero2
	clr.l	d0
	clr.l	d1
	move.b	bull_wantgo(a2),d0
	move.b	bull_go(a2),d1
	and.b	#BOBF_UP|BOBF_DOWN,d0
	and.b	#BOBF_UP|BOBF_DOWN,d1
	cmp.b	d0,d1
	beq	.notzero2
	;bull wants to change direction, so slow him down
	move.l	#1,d2	;trigger notsmarts slow rtn
	bra	.notsmart
	
.notzero2	
	clr.l	d1
	move.b	bull_speedy(a2),d1
	cmp.b	bull_maxy(a2),d1
	bge	.over1
	move.b	bull_stepy(a2),d1
	add.b	d1,bull_speedy(a2)
.over1
	clr.l	d0
	lea	bull_table,a3
	move.b	bull_speedy(a2),d1
	move.b	(a3,d1),d0	

	btst	#7,d0
	beq	.positive
	;number is negative, so wait a while
	move.b	d0,bull_waity(a2)
	move.l	#2,d2
	rts
.positive	
	move.l	#0,d2
	rts
	
go_seek
	;only do this rtn if life = ffff
	cmp.w	#$ffff,bull_life(a2)
	bne	.out

	
	cmp.b	#WeapSmart,bull_gun(a2)
	bne	.out
	;okay if its this weapon then he chasing the player
	;so copy players x/y into seekx/y
	
	;find player structure please
	lea	player1,a1
	clr.l	d6
	move.b	bull_player(a2),d6
	
	;if the player im seeking is DEAD  then kill me off!
	
	;re-write this rtn to make bullets fall to gravity (out of puff)
	lea	liveplayers,a3
	;if liveplayer = fe or ff then kill bullet off (player DEAD)
	cmp.b	#$fe,(a3,d6)
	bne	.okay1
;	move.b	#DEAD,bull_status(a2)	;kill bullet off again

	move.b	#WeapNorm,bull_gun(a2)	;turn into normal bullet
	
	move.b	#0,bull_attr(A2)		;clear me
	bset	#ATTRB_EDGE,bull_attr(A2)	;bounce off edges
	bset	#ATTRB_GRAV,bull_attr(A2)	;fall when out of puff
	bset	#KBULB_BOTTOM,bull_death(a2)	;die when on bottom of screen

	bclr	#BOBB_UP,bull_go(a2)
	bclr	#BOBB_UP,bull_wantgo(a2)
	bset	#BOBB_DOWN,bull_go(a2)
	bset	#BOBB_DOWN,bull_wantgo(a2)


.not_norm1

.okay1	

.loop
	cmp.b	#0,d6
	beq	.got_struct

	add.l	#player1_nd-player1,a1	;next player please
	dbra	d6,.loop
.got_struct
	move.w	play_xpos(a1),bull_seekx(a2)
	move.w	play_ypos(a1),bull_seeky(a2)
	add.w	#0,bull_seekx(a2)	;half way through
	add.w	#6,bull_seeky(a2)	;half way through
		
	
	clr.l	d0
	clr.l	d1
	move.w	bull_seekx(a2),d0
	cmp.w	bull_xpos(a2),d0
	beq	.checkud
	bgt	.lower
	;its to the right
	bclr	#BOBB_RIGHT,bull_wantgo(a2)
	bset	#BOBB_LEFT,bull_wantgo(a2)
	bra	.checkud
.lower
	bclr	#BOBB_LEFT,bull_wantgo(a2)
	bset	#BOBB_RIGHT,bull_wantgo(a2)
.checkud
	clr.l	d0
	clr.l	d1
	move.w	bull_seeky(a2),d0
	cmp.w	bull_ypos(a2),d0
	beq	.out
	bgt	.lowerd
	;its to the up
	bclr	#BOBB_DOWN,bull_wantgo(a2)
	bset	#BOBB_UP,bull_wantgo(a2)


	bra	.out
.lowerd
	bclr	#BOBB_UP,bull_wantgo(a2)
	bset	#BOBB_DOWN,bull_wantgo(a2)

.out	rts

moving_bulls
	move.b	#0,waitflag
	bsr	go_seek
	;if life = 0 then bullet has run out of puff. slow it down
	clr.l	d1
	move.w	bull_life(a2),d1
	cmp.w	#$ffff,d1
	beq	.onwards	;infinite energy
	cmp.w	#0,d1
	beq	.onwards
	sub.w	#1,bull_life(a2)

.onwards	
	cmp.w	#0,d1
	bne	.loadsapuff
	;no puff
	bclr	#BOBB_UP,bull_go(a2)
	bset	#BOBB_DOWN,bull_go(a2)
.loadsapuff
	cmp.b	#WeapSmart,bull_gun(a2)
	bne	.notsmart
	cmp.w	#$ffff,bull_life(a2)
	bne	.notsmart
	;its a smart bullet, so sub from bull life2
	cmp.b	#0,bull_life2(a2)
	bne	.onagain
	;kill off bullet!
;	move.w	#0,bull_life(a2)	;make normal dead bullet!
	bclr	#BOBB_UP,bull_wantgo(a2)
	bset	#BOBB_DOWN,bull_wantgo(a2)
	move.b	#WeapNorm,bull_gun(a2)
	bra	.notsmart
.onagain
	sub.w	#1,bull_life2(a2)
.notsmart


	btst	#BOBB_RIGHT,bull_go(a2)
	beq	.not_right
	;bullets going to the right!


	bsr	how_fastx	
	;if d2=2 then bra notleftright
	;if d2=0 then all is groovy
	;if d2=1 then bra .not_right
	;d0 will have speed increment (if d2=0)
	cmp.l	#2,d2
	beq	.not_leftright
	cmp.l	#1,d2
	beq	.not_right

	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.notlazer
	;if its a lazer then do not use acc.
	;move in 16 pixies!
	move.l	#16,d0
	move.b	d0,bull_speedx(a2)
	
.notlazer
	add.w	d0,bull_xpos(a2)
	
	cmp.w	#320+16,bull_xpos(a2)
	blt	.ok
	
	bsr	is_edger
	tst.l	d2
	bne	.ok
		
	sub.w	#320+16,bull_xpos(a2)
.ok
	;if its a lazer then store the value in lazercoll(a2)
	;store it in bull_lazx2
	move.w	bull_xpos(a2),bull_lazx2(a2)


.not_right
	btst	#BOBB_LEFT,bull_go(a2)
	beq	.not_left
	;bullets going to the left!

	bsr	how_fastx	
	;if d2=2 then bra notleftright
	;if d2=0 then all is groovy
	;if d2=1 then bra .not_right
	;d0 will have speed increment (if d2=0)
	cmp.l	#2,d2
	beq	.not_leftright
	cmp.l	#1,d2
	beq	.not_left

	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.notlazerl
	;if its a lazer then do not use acc.
	;move in 16 pixies!
	move.l	#16,d0
	move.b	d0,bull_speedx(a2)
	
.notlazerl
		
	sub.w	d0,bull_xpos(a2)
	
	cmp.w	#0,bull_xpos(a2)
	bgt	.okl
	
	bsr	is_edger
	tst.l	d2
	bne	.okl

	add.w	#320+16,bull_xpos(a2)
.okl
	;if its a lazer then store the value in lazercoll(a2)
	;store it in bull_lazx
	move.w	bull_xpos(a2),bull_lazx(a2)

.not_left


.not_leftright
	;if Agrav is set then the bullet wants to fall all the time!
	btst	#ATTRB_AGRAV,bull_attr(a2)
	bne	.jumpy
	
	;if grav is set and bull_life = 0 FALL
	btst	#ATTRB_GRAV,bull_attr(a2)
	beq	.notgrav
	btst	#BOBB_DOWN,bull_go(a2)
	cmp.w	#0,bull_life(a2)
	bne	.notgrav
	;okay he wants to fall!!!!!!
	bset	#BOBB_DOWN,bull_wantgo(a2)
	bra	.jumpy
	

.notgrav	btst	#BOBB_DOWN,bull_go(a2)
	beq	.not_down
	;bullets going down!

.jumpy
	cmp.b	#1,PlayerGun
	bne	.noonon
;	bsr	JIM
.noonon
	bsr	how_fasty	
	;if d2=2 then bra notupdown
	;if d2=0 then all is groovy
	;if d2=1 then bra .not_down
	;d0 will have speed increment (if d2=0)
	cmp.l	#2,d2
	beq	.not_updown
	cmp.l	#1,d2
	beq	.not_down

	;if bull_ypos+d0 goes over a 16 boundary AND
	;bull_attr = BFORM 
	;then check to see if its hit a platform
	;if it has then make it bounce!!!
	;just flip bull_go UP/DOWN.
	;hopefully the program will sort this out!
	
	move.w	bull_ypos(a2),d1
	and.l	#%11110000,d1

	add.w	d0,bull_ypos(a2)
	
	move.w	bull_ypos(a2),d3
	and.l	#%11110000,d3
	cmp.w	d1,d3
	beq	.noPcheck	;no platform check
	;okay, weve omoved over a bonudary.
	;lets check to see if hes hit a platorm!
	;if hes attr = bform anyway!
	btst	#ATTRB_BFORM,bull_attr(a2)
	beq	.noPcheck
	
	;if there is a character here (or possibly under here) then he
	;should bounce up again!
	;checking platform!
	move.l	#$994,d3
.wait
;	move.w	#$0f0,$dff180
	dbra	d3,.wait
	
	;now work out map pos
	clr.l	d0
	move.w	bull_xpos(a2),d0
	and.l	#$0000fff0,d0	;kill all orrible bits
	ror.w	#4,d0		;shift down
	move.b	d0,bull_mapx(a2)		;save baddy mapx

	clr.l	d0
	move.w	bull_ypos(a2),d0
	and.l	#$0000fff0,d0	;kill all orrible bits
	ror.w	#4,d0		;shift down
	move.b	d0,bull_mapy(a2)		;save baddy mapy

	clr.l	d0
	clr.l	d1
	move.b	bull_mapx(a2),d0
	move.b	bull_mapy(a2),d1

	add.b	#1,d1	;check under foot

	move.l	a2,spare		;*
	bsr	find_char		;findchar uses a2 (bad news)

	lea	walk_on,a2		;what chars can you walk on
.underneath
	cmp.b	#0,(a2)
	beq	.still_falling
	cmp.b	(a2)+,d0
	beq	.found_platform
	bra	.underneath
.found_platform
	move.l	spare,a2		;*
	
	;set bullgo to UP!
	bclr	#BOBB_DOWN,bull_go(a2)
	bset	#BOBB_UP,bull_go(a2)

	bclr	#BOBB_UP,bull_wantgo(a2)
	bset	#BOBB_DOWN,bull_wantgo(a2)
	
;	move.b	bull_go(a2),d0
;	move.b	bull_wantgo(a2),d0


.still_falling
	move.l	spare,a2		;*
	
	
	
	
	
	
	
	
	
	
.noPcheck
	
	cmp.w	#256+16,bull_ypos(a2)
	blt	.okd
	
	btst	#KBULB_BOTTOM,bull_death(a2)
	beq	.safebottom
	bsr	kill_bullet
	bra	.okd
.safebottom
	sub.w	#256+16,bull_ypos(a2)
.okd

.not_down


	btst	#BOBB_UP,bull_go(a2)
	beq	.not_up
	;bullets going to the up!

	bsr	how_fasty
	;if d2=2 then bra notupdown
	;if d2=0 then all is groovy
	;if d2=1 then bra .not_up
	;d0 will have speed increment (if d2=0)
	cmp.l	#2,d2
	beq	.not_updown
	cmp.l	#1,d2
	beq	.not_up
		
	sub.w	d0,bull_ypos(a2)
	
	cmp.w	#0,bull_ypos(a2)
	bgt	.oku
	add.w	#256+16,bull_ypos(a2)
.oku

.not_up


.not_updown

.out	rts
JIM
	move.b	bull_go(a2),d0
	move.b	bull_wantgo(a2),d0
	rts

is_edger
	clr.l	d2
	;if its the lazer at the edge then start it from the cannnon again
	;(this clears up any baddy residue) (NO)
	;it makes it harder for the lazer collision rtn!
	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.nolazer
	;bull_paddr will have the structure of the firer
;	bclr	#BOBB_LEFT|BOBB_RIGHT,bull_go(a2)
;	bclr	#BOBB_LEFT|BOBB_RIGHT,bull_wantgo(a2)
	move.l	#1,d2	;dont do anything
	
	;if lazer going right then sub 16
	;if lazer gonig left then add 16
	
	btst	#BOBB_LEFT,bull_go(a2)
	beq	.notleft
	add.w	#16,bull_xpos(a2)
.notleft
	btst	#BOBB_RIGHT,bull_go(a2)
	beq	.notright
	sub.w	#16,bull_xpos(a2)
.notright
	
	rts
	
.nolazer
	clr.l	d2
	
	;if ive hit the edge and ATTR=EDGE then bounce it off
	btst	#ATTRB_EDGE,bull_attr(a2)
	beq	.not_edger
	;hit edge of screen...
	;so instant change direction
	;And Half the speed
	bchg	#BOBB_LEFT,bull_go(a2)	;change direction
	bchg	#BOBB_RIGHT,bull_go(a2)
	clr.l	d0		;half the speed
	move.b	bull_speedx(a2),d0
	sub.b	#4,d0
	bgt	.kik
	move.b	#0,d0
.kik	move.b	d0,bull_speedx(a2)
	move.l	#1,d2	;dont do anything
.not_edger
	;if ive hit the edge of the screen and kbul = edge then die!!!
	btst	#KBULB_EDGE,bull_death(a2)
	bne	.nodedger
	bsr	kill_bullet
.nodedger
	rts

go_moveguns
;move guns is for the player, and move bullets is for the baddies bullets
	move.b	#1,PlayerGun

	lea	gun_list,a2
	move.l	#gun_max-1,d7
	bra	mainmovegun
	
go_movebullets

;for the players, just change the next 2 lines to acc.

	lea	bullet_list,a2
	move.l	#bullet_max-1,d7
	
	
mainmovegun	
.loop
	cmp.b	#DEAD,bull_status(a2)
	beq	.notnew

;	move.w	$dff006,$dff180
	bsr	moving_bulls
	
.notnew
	add.l	#bullet_nd-bullet,a2	;next player
	dbra	d7,.loop

	move.b	#0,PlayerGun
	rts

go_shoot	;Can we fire, if so shall we??
	clr.l	d7
	move.b	random,d7
	cmp.b	bad_randg(a1),d7	;random seeky fire
	bne	.out
	;okay random wants to fire!
	;can the baddy do it?
	btst	#BOBB_GUN2,bad_ability(a1)
	beq	.out		;hey, i cant shoot
	;am i already shooting?
	btst	#BOBB_GUN2,bad_doing(a1)
	bne	.out		;already shooting so do setup again
	;okay, baddy can fire if he wants to
	;lets see if weve got any spare bullet bobs!
	lea	bullet_list,a2
	move.l	#bullet_max-1,d7
.loop
	;find a dead bullet (status = DEAD)
	cmp.b	#DEAD,bull_status(a2)
	bne	.not_dead
	;okay, weve found a bullet. Now lets get it up and running

	;clear structure for new baddy
	move.l	a2,a3
	move.l	#bullet_nd-bullet-1,d6	
.blank	move.b	#0,(a3)+
	dbra	d6,.blank

	bset	#BOBB_GUN2,bad_doing(a1)
	move.b	bad_gun(a1),bull_gun(a2)	;copy weapon type
	move.b	bad_power(a1),bull_power(a2)	;bullet power

	bsr	Prep_bullet

	move.w	bad_gungfk(a1),bull_gfk(a2)

	bsr	bullet_setup

		
;	add.b	#1,random
	
	bra	.out
.not_dead
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop

.out	rts

bullet_setup
	cmp.b	#WeapSmart,bull_gun(a2)
	bne	.not_smart1
;	move.w	#24,bull_gfk(a2)
	bset	#ATTRB_SEEKX,bull_attr(A2)
	bset	#ATTRB_SEEKY,bull_attr(A2)
	bset	#KBULB_BOTTOM,bull_death(a2)	;** TEST ** die when on bottom of screen
	bset	#ATTRB_EDGE,bull_attr(A2)	;** TEST ** bounce off edges
.not_smart1

	cmp.b	#WeapNorm,bull_gun(a2)
	bne	.not_norm1
;	move.w	#28,bull_gfk(a2)
;	bset	#ATTRB_EDGE,bull_attr(A2)	;bounce off edges
	bset	#ATTRB_GRAV,bull_attr(A2)	;fall when out of puff
	bset	#KBULB_BOTTOM,bull_death(a2)	;die when on bottom of screen
	;the normal baddy may not be moving l/r 
	;so look at cango to decide which way to shoot!
.not_norm1
	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.not_Lazer1
	move.w	#160,bull_gfk(a2)
	bset	#ATTRB_GRAV,bull_attr(A2)	;fall when out of puff
	bset	#KBULB_BOTTOM,bull_death(a2)	;die when on bottom of screen
	move.b	bad_LBnk(a1),bull_LBnk(a2)	;copy restore bank no. across
	;copy restore starting position!
	move.b	bad_mapx(a1),bull_Lcnt(a2)	;copy start
	move.l	bad_actual(a1),bull_Lrest(a2)	;copy scr pos
	move.w	#$120,bull_life(a2)
	move.w	bad_x(a1),bull_lazx(a2)
	move.w	bad_x(a1),bull_lazx2(a2)
	add.w	#16,bull_lazx2(a2)
	move.w	bad_y(a1),bull_lazy(a2)
	move.w	bad_y(a1),bull_lazy2(a2)
	add.w	#16,bull_lazy2(a2)
.not_Lazer1

	;if its a weap bounce then youve got to set some bounce bits
	;and setup some flags	
	
	cmp.b	#WeapBounce,bull_gun(a2)
	bne	.notbouncey
;	move.w	#$f00,$dff180
	;	EDGE,BFORM,AGRAV
	move.w	#96,bull_gfk(a2)
	bset	#ATTRB_GRAV,bull_attr(a2)	;fall when out of puff
	bset	#ATTRB_AGRAV,bull_attr(a2)	;fall always
	bset	#ATTRB_EDGE,bull_attr(A2)	;bounce on edge of scr
	bset	#ATTRB_BFORM,bull_attr(A2)	;bounce on pform
	bset	#BOBB_DOWN,bull_go(a2)
	bset	#BOBB_DOWN,bull_wantgo(a2)
	bclr	#BOBB_UP,bull_go(a2)
	bclr	#BOBB_UP,bull_wantgo(a2)
	
	
.notbouncey
	
	;put all other bullet setups here
	rts
	
Prep_bullet
	move.l	a1,bull_paddr(a2)

	;setup for smart bullet!

	move.w	bad_y(a1),bull_ypos(a2)
	
	clr.l	d0
	move.w	bad_x(a1),d0
	;if baddy facing left and xpos over 16 then

	;the weapnorm/weaplazer baddy may not be moving l/r 
	;so look at cango to decide which way to shoot!
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.in
	cmp.b	#WeapNorm,bull_gun(a2)
	bne	.okl
.in	btst	#BOBB_LEFT,bad_cango(a1)	;check baddy
	beq	.not_left
	bra	.normjumpl

.okl

	btst	#BOBB_LEFT,bad_go(a1)	;check baddy
	beq	.not_left

.normjumpl	;okay, hes facing left. Is his xpos over 16?
	cmp.w	#16,bad_x(a1)
	bgt	.okayl
	;on very edge of screen, so kill me off
	move.b	#DEAD,bull_status(a2)	;kill bullet off again
	
	;if bullet is from the player then dec the players bullet counter..
	cmp.b	#1,PlayerGun
	bne	.okayl
	;its the players bullet...
	move.l	a1,RegSave
	move.l	bull_paddr(a2),a1
	sub.b	#1,play_maxbullscnt(a1)
	move.l	RegSave,a1

.okayl
	;okay its safe to do so
	sub.w	#16,d0
	move.w	d0,bull_xpos(a2)
	bset	#BOBB_LEFT,bull_go(a2)
	bset	#BOBB_LEFT,bull_wantgo(a2)
.not_left


	;the weapnorm/weaplazer baddy may not be moving l/r 
	;so look at cango to decide which way to shoot!
	cmp.b	#WeapLazer,bull_gun(a2)
	beq	.in2
	cmp.b	#WeapNorm,bull_gun(a2)
	bne	.okr
.in2	btst	#BOBB_RIGHT,bad_cango(a1)	;check baddy
	beq	.not_right
	bra	.normjumpr

.okr

	;if baddy facing right and xpos under 320+16-16 then
	btst	#BOBB_RIGHT,bad_go(a1)	;check baddy
	beq	.not_right
.normjumpr	;okay, hes facing right. Is his xpos over 320+16-16?
	cmp.w	#320+16-16,bad_x(a1)	;edge of screen?
	blt	.okayr
	;on very edge of screen, so kill me off
	move.b	#DEAD,bull_status(a2)	;kill bullet off again
	
	;if bullet is from the player then dec the players bullet counter..
	cmp.b	#1,PlayerGun
	bne	.okayr
	;its the players bullet...
	move.l	a1,RegSave
	move.l	bull_paddr(a2),a1
	sub.b	#1,play_maxbullscnt(a1)
	move.l	RegSave,a1

.okayr
	;okay its safe to do so
	add.w	#16,d0
	move.w	d0,bull_xpos(a2)
	bset	#BOBB_RIGHT,bull_go(a2)
	bset	#BOBB_RIGHT,bull_wantgo(a2)
.not_right


prepbull2
	move.b	#NEW,bull_status(a2)	;come to life please
	;****SORT OUT the mapx/y positions****
	
	move.b	#0,bull_speedx(a2)	;current bullet speed pos
	move.b	#0,bull_speedy(a2)
	move.b	#60,bull_maxx(a2)	;max in speed table
	move.b	#60,bull_maxy(a2)
	move.b	#4,bull_stepx(a2)	;step through table
	move.b	#6,bull_stepy(a2)	;step through table
		;i.e. to increase speed. bull_speedx+bull_stepx
	move.w	#$40,bull_life(a2)	;life = ffff (unlimited)
	move.w	#100,bull_seekx(a2)	;seek here pleasex
	move.w	#130,bull_seeky(a2)	;seek here pleasey
	move.b	#0,bull_waitx(a2)
	move.b	#0,bull_waity(a2)
	move.b	#0,bull_attr(a2)
	move.b	#0,bull_death(a2)
	
	
	cmp.b	#1,PlayerGun
	beq	.okay
	
	;this bit has to be re-written to grab a rnd player to chase
	lea	player1,a3
	clr.l	d0
	move.b	randplay,d0
.loop	
	cmp.b	#0,d0
	beq	.gotim
	add.l	#player1_nd-player1,a3	;next player
	sub.b	#1,d0
	bra	.loop
.gotim
	cmp.b	#DEAD,play_status(a3)	;is player dead
	bne	.okay
	move.b	#DEAD,bull_status(a2)	;kill bullet off again
.okay
	
	
.not_firing
	rts

anim_baddy
	lea	bad_an_rcnt(a1),a2
	clr.l	d0
	move.b	bad_an_off(a1),d0
	add.l	d0,a2
	move.b	(a2),d0
	
	add.b	#1,bad_anim(a1)
	cmp.b	bad_anim(a1),d0
	bgt	.fine2
	;at end of animation frames
	move.b	#0,bad_anim(a1)	;reset it
.fine2
	rts

find_char	
	and.l	#$000000ff,d0
	and.l	#$000000ff,d1
	sub.l	#1,d0	;go left a char!
	sub.l	#1,d1	;go up a char!
	move.l	LevBase,a2
	mulu	#level_wid*4,d1
	add.l	d1,a2
	add.l	d0,a2
	add.l	d0,a2
	add.l	d0,a2
	add.l	d0,a2
	
	move.l	(a2),d0	;get char under baddy
	and.l	#$0000ffff,d0	;kill attr
	rts

go_restoreplayer1
	clr.l	d7
	move.b	num_players,d7
	sub.l	#1,d7	;for dbra
	lea	player1,a1		;players structure
	move.l	player_temp1Base,a2	;grabbed space
	btst	#1,switch
	bne	.loop
	move.l	player_temp2Base,a2
	
.loop
	;is player dead. if so skip it
	cmp.b	#DEAD,play_status(a1)	
	beq	.dead
	
	;is player dying then restore and then make him DEAD
	cmp.b	#DYING,play_status(a1)	
	bne	.nodie
	add.b	#1,play_dedcnt(a1)
	cmp.b	#2,play_dedcnt(a1)
	bne	.nodie
	move.b	#DEAD,play_status(a1)
.nodie
	
	move.l	scrbase,a3
	add.l	play_was(a1),a3	;add coarse
	;blit a2 to a3 please
	
	CALLGRAF	WaitBlit
	move.w	#4-4,$dff064	;mod A
	move.w	#scrwid-4,$dff066	;mod D
	move.l	a2,$dff050	;src A
	move.l	a3,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(24*5*64)+2,$dff058	;bltsize 

.dead	
	add.l	#24*5*4,a2		;next 1 please
	add.l	#player1_nd-player1,a1	;next player
	dbra	d7,.loop
	
	rts
	
go_grabplayer1
	clr.l	d7
	move.b	num_players,d7
	sub.l	#1,d7	;for dbra

	lea	player1,a1		;point to 1st player structure
	move.l	player_temp1Base,a4	;temp storage for grab
	btst	#1,switch
	bne	.loop
	move.l	player_temp2Base,a4	;grab/rest place
.loop
	;is player dead. if so skip it
	cmp.b	#DEAD,play_status(a1)	
	beq	.dead
	;or dying
;	cmp.b	#DYING,play_status(a1)	
;	beq	.dead





	;do a little loop here to check if the baddy is in a lazerzone!
	;dont use :=A1,A4,D0,D1,D2,D7
	
	move.l	#bullet_max+1,d6
	
	lea	bullet_list,a2
.lazloop
	cmp.b	#WeapLazer,bull_gun(a2)
	bne	.deadlazer
	cmp.w	#0,bull_lazx(a2)
	bne	.ok1	;its a lazer
	cmp.w	#0,bull_lazy(a2)
	beq	.deadlazer
.ok1
	;ok, its a lazer beam..... do summink!
	
	;if play_xpos > bull_lazx AND play_x2 < bull_lazx then possible kill
	;if play_ypos > bull_lazy AND play_y2 < bull_layx then possible kill
	;if both of these are TRUE then KILL murder death hurtalot
	;	destruction of the poor little player!
	
	clr.l	d3
	move.w	play_xpos(a1),d3
	
	cmp.w	bull_lazx(a2),d3
	blt	.safe
	cmp.w	bull_lazx2(a2),d3
	bgt	.safe
	
	
	clr.l	d3
	move.w	play_ypos(a1),d3
	
	cmp.w	bull_lazy(a2),d3
	blt	.safe
	cmp.w	bull_lazy2(a2),d3
	bgt	.safe
	;HAHHHAHAHAHHHHAAX KILL KILL BANG BANG YOUR DEAD KILL KILL
	move.b	#DYING,play_status(a1)	
;	move.b	#DEAD,play_status(a1)	
	move.w	#$fff,flash


.safe	
.deadlazer	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d6,.lazloop
	









	move.l	play_actual(a1),play_was(a1)
	clr.l	d0
	clr.l	d1
	move.w	play_xpos(a1),d0
	move.w	play_ypos(a1),d1
	sub.w	#8,d1		;player is 24 high
	mulu	#scrwid*5,d1

	move.w	d0,d2	;save x
	and.w	#$000f,d0
	rol.w	#8,d0
	rol.w	#4,d0	;got minterm
	and.w	#$fff0,d2	;do corse scrol
	ror.w	#3,d2
	add.w	d2,d1	;got coarse
	move.l	d1,play_actual(a1)	;save coarse scroll
	move.w	d0,play_smooth(a1)	;save smooth	
	
	;if playwas = 0 then copy actual into it
	cmp.l	#0,play_was(a1)
	bne	.okay
	move.l	play_actual(a1),play_was(a1)
.okay

	CALLGRAF	WaitBlit
	add.l	scrbase,d1	
	move.w	#scrwid-4,$dff064	;mod A
	move.w	#4-4,$dff066	;mod D
	move.l	d1,$dff050	;src A
	move.l	a4,$dff054	;dst D
	move.w	#$09f0,$dff040	;bltcon0!!!!!
	move.w	#(24*5*64)+2,$dff058	;bltsize 

.dead	
	add.l	#24*4*5,a4	;next grab place please
	add.l	#player1_nd-player1,a1	;next player
	dbra	d7,.loop


	rts
go_printplayer1
	clr.l	d7
	move.b	num_players,d7
	sub.l	#1,d7	;for dbra

	lea	player1,a1
.loop
	;is player dead. if so skip it
	cmp.b	#DEAD,play_status(a1)	
	beq	.dead
	;or dying
	cmp.b	#DYING,play_status(a1)	
	beq	.dead

	;A = mask
	;B = source
	;C = dest
	;D = dest. (obvious really!!)
	
	CALLGRAF	WaitBlit
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#40-4,$dff062	;mod b
	move.w	#scrwid-4,$dff060	;mod C
	move.w	#scrwid-4,$dff066	;mod D

	move.w	play_smooth(a1),d0	;get smooth
	move.w	d0,$dff042	
	or.w	#$0fce,d0
	move.w	d0,$dff040	
	
	move.l	scrbase,a4		;get coarse
	add.l	play_actual(a1),a4
	
	move.l	Player1Base,a5

	;point to the mask
	move.l	a5,a3
	add.l	#40*48*5,a3		;gott it

	;if player has been hurt make him white.. cheat and use mask!
	cmp.b	#HURT,play_status(a1)
	bne	.nohurt
	move.l	a3,a5
	sub.b	#1,play_hptime(a1)
	cmp.b	#0,play_hptime(a1)
	bne	.nohurt
	move.b	#OKAY,play_status(a1)
	
.nohurt

	clr.l	d0
	clr.l	d1
	move.b	play_anim_style(a1),d0	;get style
;	move.b	#0,d0	;frigging
	mulu	#40*24*5,d0		;get to anim set
	
	move.b	play_anim_frame(a1),d1	;get frame
;	move.b	#7,d1	;frigging
	lsl.l	#2,d1
	add.l	d1,d0
	add.l	d0,a5	;add to player gfx
	add.l	d0,a3	;add to player mask
	
	move.l	a3,$dff050	;get mask A
	move.l	a5,$dff04c	;src B	bob
	move.l	a4,$dff048	;src C	screen
	move.l	a4,$dff054	;dst D	screen
	move.w	#(24*5*64)+2,$dff058

.dead
	add.l	#player1_nd-player1,a1	;next player
	dbra	d7,.loop

	rts

go_findplayers		
	move.b	#0,num_players
	;8 = players
	move.l	LevBase,a0	;point to start of level
	lea	player1,a1
	move.b	#players_max,temp
		
	move.l	#16,d1	;clear y
	move.w	#level_hi-1,d6
.loop3
	move.l	#16,d0	;clear x
	move.w	#level_wid-1,d7
	move.l	a0,a2	;pointer to level
.loop2
	move.l	(a2)+,d2
	and.l	#$ffff0000,d2	;kill gfk
	swap	d2		;get the char
	cmp.l	#8,d2
	bne	.not_player
	
	bsr	create_player
	
	add.l	#player1_nd-player1,a1	;next player please
	add.b	#1,num_players	;add to player count
	sub.b	#1,temp
	cmp.b	#0,temp
	beq	.out
.not_player
	add.l	#16,d0		;next xpos
	dbra	d7,.loop2
	add.l	#level_wid*4,a0
	add.l	#16,d1
	dbra	d6,.loop3
	
	

.out	rts

create_player
	move.w	d0,play_xpos(a1)	;save x
	move.w	d1,play_ypos(a1)	;save y
;	sub.w	#8,play_ypos(a1)	;player is 24 high

	;now work out map pos
	move.w	d0,d2		;
	and.l	#$0000fff0,d2	;kill all orrible bits
	ror.w	#4,d2		;shift down
	move.b	d2,play_mapx(a1)	;save player mapx

	move.w	d1,d2		;
	and.l	#$0000fff0,d2	;kill all orrible bits
	ror.w	#4,d2		;shift down
	move.b	d2,play_mapy(a1)	;save player mapy

	clr.l	d2	;x
	clr.l	d3	;y
	move.w	play_xpos(a1),d2	;get player xpos
	move.w	play_ypos(a1),d3	;get player ypos
	sub.w	#8,d3	;player is 24 high
	
	mulu	#scrwid*5,d3	;got y
	and.w	#$fff0,d2	;do corse scrol
	ror.w	#3,d2
	add.w	d2,d3	;got coarse
	
	move.l	d3,play_was(a1)	;save actual (just add scrbase)
	
	move.b	#16,play_platx(a1)
	move.b	#1,play_speed(a1)	;start speed
	move.b	#60,play_spdmax(a1)	;max speed
	move.b	#4,play_step(a1)	;step through table
	move.b	#8,play_slip(a1)	;how slippy surface
	move.b	#gravity,play_falmax(a1)	;max fall speed!
	move.b	#OKAY,play_status(a1)	;hey im alive!

	move.b	#HitPoints,play_hp(a1)	;player hit points
	
	move.b	#WeapBounce,play_gun(a1)	;players gun
;	move.b	#WeapNorm,play_gun(a1)	;players gun
	move.b	#255,play_ammo(a1)		;ammo (infinite)
	move.b	#10,play_reloadmax(a1)		;take 100 vbl to reload
	;good num... 30 or 10 for ace
	move.b	#gun_max/players_max,play_maxbulls(a1)		;max bullets on screen!!!!
	move.b	#0,play_maxbullscnt(a1)		;zero bullet count
	move.b	#1,play_gunpower(a1)
	
	;figure out what port hes reading from....
	lea	OPTP1JOY,a3		;point to joystick options.
	;num players has player num
	clr.l	d2
	move.b	num_players,d2
	move.b	(a3,d2),play_port(a1)	;copy port
	rts

joyport1
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
	
.loop	rts

joyport2
	clr.l	d1
	move.w	$dff00a,d0		;dff00c port1
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
	btst	#6,$bfe001		;PRA (7 for the other port)
	bne	.loop
;	move.w	#$0f00,$dff180
	bset	#BOBB_SHOOT,d0	;hey i hit the button
	
.loop	rts

go_moveplayer1
	lea	player1,a1
	clr.l	d7
	move.b	num_players,d7
	sub.l	#1,d7	;for dbra

.loop
	cmp.b	#DEAD,play_status(a1)
	beq	.hesdead
	;choose which port to read from (not written)
	cmp.b	#JOYPORT1,play_port(a1)
	bne	.notport1
	bsr	joyport1
.notport1	cmp.b	#JOYPORT2,play_port(a1)
	bne	.notport2
	bsr	joyport2
.notport2
	move.b	d0,play_do(a1)
	
	move.l	d7,RegSave
	bsr	play_move
	move.l	RegSave,d7

.hesdead	add.l	#player1_nd-player1,a1	;next player please
	dbra	d7,.loop
	rts
	
play_move
	bsr	player_right
	bsr	player_left
	bsr	player_up
	bsr	player_down
	bsr	player_fire


;---------------
;proper LR inertia for player (slippy slidey like mario)	
;if the joystick hasnt been pushed LR or the flags
;lowered by the lr routines then do inertia on player
;---------------
	
	;if no LR (play_do) then slow down the player
	
	clr.l	d0
	move.b	play_do(a1),d0	;get joystick dir
	and.b	#BOBF_RIGHT|BOBF_LEFT,d0
	bne	.no_lr
	;player is going left or right!!!!!!
	
	;if players speed at 0 then just exit
	cmp.b	#0,play_speed(a1)
	beq	.no_lr
	
	clr.l	d0
	
	move.b	play_slip(a1),d0
	;if player is falling then play_slip = 1
	btst	#BOBB_FALL,play_doing(a1)
	beq	.onland
	move.b	#1,d0
.onland
	
	sub.b	d0,play_speed(a1)
	bgt	.ok
	move.b	#0,play_speed(a1)
.ok
	bsr	player_right_BYPASS
	bsr	player_left_BYPASS
	bra	.out
.no_lr
	;okay, guy is stationary (I think)
	;Now we can do other things.
	;if play_platx(a1) under 8 or over 24
	;and guy is on edge do balance thing (Sonic)
.out
	rts
player_right
	btst	#BOBB_RIGHT,play_do(a1)	
	beq	.not_right

	;if play_going = left then just slow speed down to 0
	;and then clear left and set right
	btst	#BOBB_LEFT,play_going(a1)
	beq	.okr
	cmp.b	#0,play_speed(a1)
	bgt	.slowmedown
	bclr	#BOBB_LEFT,play_going(a1)
	bset	#BOBB_RIGHT,play_going(a1)
	bra	.not_right
.slowmedown
	sub.b	#1,play_speed(a1)
	bclr	#BOBB_RIGHT,play_do(a1)	
	bra	.not_right
.okr

	clr.l	d0
	move.b	play_speed(a1),d0
	cmp.b	play_spdmax(a1),d0
	bge	.atmax
	
	move.b	play_step(a1),d1
	add.b	d1,play_speed(a1)
.atmax
	bset	#BOBB_RIGHT,play_going(a1)
	bsr	player_right_BYPASS

	move.b	#Anim_RIGHT,play_anim_style(a1)
	cmp.b	#7,play_anim_frame(a1)
	blt	.noreset
	move.b	#0,play_anim_frame(a1)
	move.b	#0,play_anim_count(a1)
.noreset
	add.b	#1,play_anim_count(a1)
	cmp.b	#pamax,play_anim_count(a1)
	bne	.not_right
	move.b	#0,play_anim_count(a1)
	add.b	#1,play_anim_frame(a1)

.not_right
	rts
	
player_right_BYPASS
	clr.l	d0
	move.b	play_speed(a1),d0
	lea	play_walk,a0
	move.b	(a0,d0),d0

	btst	#BOBB_RIGHT,play_going(a1)
	beq	.not_right
	
	add.w	d0,play_xpos(a1)
	cmp.w	#21*16,play_xpos(a1)
	blt	.onscreen
	;going off the right hand side. sub loads to get him across
	sub.w	#21*16,play_xpos(a1)
	sub.b	#21,play_mapx(a1)		
.onscreen
	add.b	d0,play_platx(a1)
	cmp.b	#32,play_platx(a1)
	blt	.not_overr
	;completely in new square, so do summink!
	sub.b	#16,play_platx(a1)
	add.b	#1,play_mapx(a1)
	
	clr.l	d0
	clr.l	d1
	move.b	play_mapx(a1),d0
	move.b	play_mapy(a1),d1
	add.b	#1,d1	;check under foot
	bsr	find_char

	lea	walk_on,a2		;what chars can you walk on
.walkingon
	cmp.b	#0,(a2)
	beq	.not_pform		;not on pform
	cmp.b	(a2)+,d0
	beq	.not_overr		;all groovy (on PFORM)
	bra	.walkingon
.not_pform
	;set fall bit
	btst	#BOBB_FALL,play_doing(a1)	;am i already falling
	bne	.not_right	;yep
	move.b	#0,play_fal(a1)		;reset fall count
	bset	#BOBB_FALL,play_doing(a1)	;hey fall
	bset	#BOBB_DOWN,play_do(a1)		;hey down
	bra	.not_right

.not_overr
.not_right
	rts
player_left	
	btst	#BOBB_LEFT,play_do(a1)	
	beq	.not_left
	
	;if play_going = right then just slow speed down to 0
	;and then clear right and set left
	btst	#BOBB_RIGHT,play_going(a1)
	beq	.okl
	cmp.b	#0,play_speed(a1)
	bgt	.slowmedown
	bclr	#BOBB_RIGHT,play_going(a1)
	bset	#BOBB_LEFT,play_going(a1)
	bra	.not_left
.slowmedown
	sub.b	#1,play_speed(a1)
	bclr	#BOBB_LEFT,play_do(a1)	
	bra	.not_left
.okl

	clr.l	d0
	move.b	play_speed(a1),d0
	cmp.b	play_spdmax(a1),d0
	bge	.atmax
	
	move.b	play_step(a1),d1
	add.b	d1,play_speed(a1)
	
.atmax
	bset	#BOBB_LEFT,play_going(a1)
	bsr	player_left_BYPASS

	move.b	#Anim_LEFT,play_anim_style(a1)
	cmp.b	#7,play_anim_frame(a1)
	blt	.noreset1
	move.b	#0,play_anim_frame(a1)
	move.b	#0,play_anim_count(a1)
.noreset1
	add.b	#1,play_anim_count(a1)
	cmp.b	#pamax,play_anim_count(a1)
	bne	.not_left
	move.b	#0,play_anim_count(a1)

	add.b	#1,play_anim_frame(a1)

.not_left
	rts	
	
player_left_BYPASS
	clr.l	d0
	move.b	play_speed(a1),d0
	lea	play_walk,a0
	move.b	(a0,d0),d0

	btst	#BOBB_LEFT,play_going(a1)
	beq	.not_left
	
	sub.w	d0,play_xpos(a1)
	cmp.w	#0,play_xpos(a1)
	bgt	.onscreen
	;going off the left hand side. add loads to get him across
	add.w	#21*16,play_xpos(a1)
	add.b	#21,play_mapx(a1)		
.onscreen
	sub.b	d0,play_platx(a1)
	cmp.b	#0,play_platx(a1)
	bgt	.not_underl
	;completely in new square, so do summink!
	add.b	#16,play_platx(a1)
	sub.b	#1,play_mapx(a1)

	clr.l	d0
	clr.l	d1
	move.b	play_mapx(a1),d0
	move.b	play_mapy(a1),d1
	add.b	#1,d1	;check under foot
	bsr	find_char

	lea	walk_on,a2		;what chars can you walk on
.walkingon
	cmp.b	#0,(a2)
	beq	.not_pform		;not on pform
	cmp.b	(a2)+,d0
	beq	.not_underl		;all groovy (on PFORM)
	bra	.walkingon
.not_pform

	;set fall bit
	btst	#BOBB_FALL,play_doing(a1)	;am i already falling
	bne	.not_left	;yep
	move.b	#0,play_fal(a1)		;reset fall count
	bset	#BOBB_FALL,play_doing(a1)	;hey fall
	bset	#BOBB_DOWN,play_do(a1)		;hey down
	bra	.not_left

.not_underl
.not_left
	rts

player_down
	;note if player is just pulling down then make him duck! * not written *

	btst	#BOBB_JUMP,play_doing(a1)	
	bne	.not_down

	btst	#BOBB_DOWN,play_do(a1)	
	bne	.down_override

	btst	#BOBB_FALL,play_doing(a1)	
	beq	.not_down
.down_override
	cmp.w	#(scrhi*16)-(24+8),play_ypos(a1)	;********16
	blt	.not_bottom
	
;	bra	.not_down
	;reached bottom of the screen.. FUCK
	move.w	#8+16,play_ypos(a1)
	move.b	#1,play_mapy(a1)
.not_bottom

	lea	bad_walk,a2
	clr.l	d0
	
	add.b	#1,play_fal(a1)	;next table pos
	move.b	play_fal(a1),d0
	cmp.b	play_falmax(a1),d0	;at max speed?
	blt	.freefal
	;reached max
	sub.b	#1,play_fal(a1)
	sub.b	#1,d0
.freefal
	move.b	(a2,d0),d0		;get speed

	move.w	play_ypos(a1),d1	;save for check
	and.l	#$fff0,d1		;kill of tiny ones	
	
	add.w	d0,play_ypos(a1)	;move down please
	
	clr.l	d0
	move.w	play_ypos(a1),d0	;get for mapy check
	and.l	#$fff0,d0		;kill of tiny ones	
	
	cmp.w	d0,d1
	beq	.okay		;still on same block
	
	add.b	#1,play_mapy(a1)	;down a block please

	cmp.b	#1,play_cres(a1)	;hey im in the cresent part of the jump
	bne	.okay
	move.b	#0,play_cres(a1)	;clear it for later
	bra	.still_falling

.okay	
	;now check to see if we hit anything

	cmp.b	#1,play_cres(a1)	;hey im in the cresent part of the jump
	beq	.still_falling



	clr.l	d0
	clr.l	d1
	move.b	play_mapx(a1),d0
	move.b	play_mapy(a1),d1

	add.b	#1,d1	;check under foot

	bsr	find_char

	lea	walk_on,a2		;what chars can you walk on
.underneath
	cmp.b	#0,(a2)
	beq	.still_falling
	cmp.b	(a2)+,d0
	beq	.found_platform
	bra	.underneath
.found_platform
	move.w	play_ypos(a1),d0
	and.w	#$fff0,d0
	move.w	d0,play_ypos(a1)	;make on top of pform
;	add.w	#8,play_ypos(a1)	;hes 24 high (allowed for)
	;hey stop falling dude
	bclr	#BOBB_DOWN,play_do(a1)	
	bclr	#BOBB_FALL,play_doing(a1)	
.still_falling
.not_down
	rts
player_up
	;am i jumping?
	btst	#BOBB_JUMP,play_doing(a1)
	bne	.jump

	
	btst	#BOBB_UP,play_do(a1)	
	beq	.not_up

	;if player is falling then he CANNOT perform a jump!
	btst	#BOBB_FALL,play_doing(a1)	;am i already falling
	bne	.not_up			
	
	;okay player is not falling so we can set the jump bit and set it all up
	btst	#BOBB_JUMP,play_doing(a1)	;am i already jumping
	bne	.not_up			
	
	bset	#BOBB_JUMP,play_doing(a1)
	bset	#BOBB_UP,play_do(a1)	
	move.b	#24,play_jmp_pos(a1)		;reset jump cnt
	
	bra	.not_up	

.jump	
	move.w	play_ypos(a1),d1
	and.l	#$0000fff0,d1	;kill off old xpos fine

	clr.l	d0
	;if in jump mode then get speed!
	btst	#BOBB_JUMP,play_doing(a1)
	beq	.skipd0		;not jumping
	cmp.b	#0,play_jmp_pos(a1)
	bne	.no_climax
	;reached top of jump. now switch off jump and gravity do the rest!
	bclr	#BOBB_JUMP,play_doing(a1)	;stop jumpping ya bastard
	bset	#BOBB_FALL,play_doing(a1)	;fall ya bastard
	bset	#BOBB_DOWN,play_do(a1)	;set going down bit please 
	move.b	#0,play_fal(a1)
	move.b	#1,play_cres(a1)	;hey im in the cresent part of the jump
	bra	.not_up
.no_climax
	sub.b	#1,play_jmp_pos(a1)
	move.b	play_jmp_pos(a1),d0	;get the counter
	lea	bad_jump,a2		;use the same jump table as bad
	move.b	(a2,d0),d0		;got the speed!
	bra	.skipd0
	
	move.b	play_speed(a1),d0
.skipd0
	sub.w	d0,play_ypos(a1)	;move up please

	move.w	play_ypos(a1),d0	;
	and.l	#$0000fff0,d0	;kill off new xpos fine
	cmp.b	d0,d1
	beq	.same4		;hasnt crossed boundary!
	sub.b	#1,play_mapy(a1)
;	;check above player just for walk_thru chars

.same4
	cmp.w	#0,play_ypos(a1)	;edge of screen?
	bgt	.okay4
	;at edge, please turn around
	move.w	#0,play_ypos(a1)
	move.b	#0,play_mapy(a1)
	bclr	#BOBB_UP,play_do(a1)	;clear up
	bset	#BOBB_DOWN,play_do(a1)	;set down
.okay4
	bra	.not_up
.not_up
	rts
	
player_fire
	btst	#BOBB_SHOOT,play_do(a1)
	beq	.out		;finger off button
	
	;ah, hes hit the fire button.... FUCK!
	;is he waiting for a reload?
	cmp.b	#0,play_reloadcnt(a1)
	beq	.reloaded
	;still reloading!
	sub.b	#1,play_reloadcnt(a1)
	bra	.nofire
	
.reloaded
	;ok, has he got any ammo? (255 = infinite)
	cmp.b	#0,play_ammo(a1)
	beq	.nofire		;no ammon
	cmp.b	#255,play_ammo(a1)
	beq	.infinite
	sub.b	#1,play_ammo(a1)	
.infinite
	;are all his bullets on the screen?
	clr.l	d0
	move.b	play_maxbulls(a1),d0
	cmp.b	play_maxbullscnt(a1),d0
	beq	.nofire
	
	;ok, we can shoot!
	add.b	#1,play_maxbullscnt(a1)
	move.b	play_reloadmax(a1),d0
	move.b	d0,play_reloadcnt(a1)

;	move.w	#$ff0,$dff180

	bsr	find_sparebull	;find im and set him up!!!!

	cmp.b	#DEAD,bull_status(a2)
	beq	.dead	
.nofire
	rts
.out
	move.b	#0,play_reloadcnt(a1)
	rts
.dead
	sub.b	#1,play_maxbullscnt(a1)
	rts
	
find_sparebull
	clr.l	d7
	;lets see if weve got any spare bullet bobs!
	lea	gun_list,a2
	move.l	#gun_max-1,d7
.loop
	;find a dead bullet (status = DEAD)
	cmp.b	#DEAD,bull_status(a2)
	bne	.not_dead
	;okay, weve found a bullet. Now lets get it up and running

	;clear structure for new bullet
	move.l	a2,a3
	move.l	#bullet_nd-bullet-1,d6	
.blank	move.b	#0,(a3)+
	dbra	d6,.blank

	bset	#BOBB_GUN2,play_doing(a1)
	move.b	play_gun(a1),bull_gun(a2)	;copy weapon type

	move.l	a1,bull_paddr(a2)
	
	move.w	play_xpos(a1),d0
	move.w	d0,bull_xpos(a2)
	move.w	play_ypos(a1),d0
	move.w	d0,bull_ypos(a2)
	bset	#BOBB_LEFT,bull_go(a2)
	bset	#BOBB_LEFT,bull_wantgo(a2)
	move.b	play_gunpower(a1),bull_power(a2)

	bsr	initplaybull

	bsr	bullet_setup



	bra	.out
.not_dead
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop
.out	rts

initplaybull

	move.w	play_gungfk(a1),bull_gfk(a2)

	move.w	#88+24,bull_gfk(a2)	;**************** REMOVE ME ************

	bsr	prepbull2	;this set all up but wantgo & go	

	move.w	play_ypos(a1),bull_ypos(a2)
	
	move.b	#0,bull_go(a2)
	move.b	#0,bull_wantgo(a2)
	
	clr.l	d0
	move.w	play_xpos(a1),d0
	;if facing left and xpos over 16 then

	;the weapnorm baddy may not be moving l/r 
	;so look at cango to decide which way to shoot!

	btst	#BOBB_LEFT,play_going(a1)	;check player
	beq	.not_left

.normjumpl	;okay, hes facing left. Is his xpos over 16?
	cmp.w	#16,play_xpos(a1)
	bgt	.okayl
	;on very edge of screen, so kill me off
	move.b	#DEAD,bull_status(a2)	;kill bullet off again
.okayl
	;okay its safe to do so
	sub.w	#16,d0
	move.w	d0,bull_xpos(a2)
	move.b	#0,bull_go(a2)
	move.b	#0,bull_wantgo(a2)
	bset	#BOBB_LEFT,bull_go(a2)
	bset	#BOBB_LEFT,bull_wantgo(a2)
.not_left



	;if baddy facing right and xpos under 320+16-16 then
	btst	#BOBB_RIGHT,play_going(a1)	;check player
	beq	.not_right
.normjumpr	;okay, hes facing right. Is his xpos over 320+16-16?
	cmp.w	#320+16-16,play_xpos(a1)	;edge of screen?
	blt	.okayr
	;on very edge of screen, so kill me off
	move.b	#DEAD,bull_status(a2)	;kill bullet off again
.okayr
	;okay its safe to do so
	add.w	#16,d0
	move.w	d0,bull_xpos(a2)
	move.b	#0,bull_go(a2)
	move.b	#0,bull_wantgo(a2)
	bset	#BOBB_RIGHT,bull_go(a2)
	bset	#BOBB_RIGHT,bull_wantgo(a2)
.not_right
	
.out	rts

go_collision

	bsr	player_to_baddyNbullet

	bsr	bullet_to_baddy
	
	rts

bullet_to_baddy
	lea	bad_no,a4		;pointer to baddy list
.main
	bsr	findbadptr
	cmp.l	#0,d0
	beq	.out		;done all baddies


;	PUSHALL
;	bsr	blitcollbaddy
;	PULLALL

	lea	gun_list,a1		;pointer to players gun list
	clr.l	d5		;gun counter!
.checking

	;check to see if bullet is alive
	cmp.b	#OKAY,bull_status(a1)
	bne	.nobulls

.okay
	bsr	guntobadxy
	cmp.l	#0,d0
	beq	.nobulls		;nowhere near. no blit coll
	
;	move.w	#$f00,$dff180	
	;hey, were near a baddy!
	;do blit check......

;	bsr	bulltobadblit	;blit bullet on to collision
;	cmp.l	#0,d0
;	beq	.nobulls 		;no collision!
;	;hey weve hit!!!!
;	move.w	#$0f0,$dff180

	;first do something funny to the bullet!
	clr.l	d0
	move.b	bull_go(a1),d0
	or.b	#BOBF_DOWN,d0
	move.b	d0,bull_go(a1)

	clr.l	d0
	move.b	bull_power(a1),d0
	bsr	hurtbaddy
	move.b	#0,bull_power(a1)

.nobulls
	add.l	#bullet_nd-bullet,a1	;next bullet
	add.b	#1,d5
	cmp.b	#gun_max-1,d5
	ble	.checking

;	PUSHALL
;	bsr	clearcollbaddy
;	PULLALL
	bra	.main		;loop forever
	
.out	rts

player_to_baddyNbullet
	clr.l	d7		;player counter!
	clr.l	d6		;baddy/bullet counter!
	clr.l	d5		;bullet count
	lea	bad_no,a4		;point to baddy list
	lea	bullet_list,a1	;point to bullet list
.main
	
	;---> ALL ROUTINES LEAVE A1/A4 D5/D6/D7 ALONE <---
	
	bsr	findplayptr		;find me an alive player
	cmp.l	#0,d0
	beq	.out		;all players dead!

	PUSHALL	
	bsr	blitcollplayer	;blit player onto collision	
	PULLALL

.main2
	bsr	findbadptr		;find me an alive baddy	
	cmp.l	#0,d0
	beq	.nobads
	
	bsr	badtoplayxy		;are we near each other?
	cmp.l	#0,d0
	beq	.nobads		;nowhere near. no blit coll
	
	bsr	badtoplayblit	;blit baddy on to collision
	cmp.l	#0,d0
	beq	.nobads 		;no collision!
	
	;* player has been hit *
;	bsr	clearcollplayer	;clear player from collision	

	clr.l	d0
	move.b	bad_power(a5),d0

	bsr	hurtplayer	
.nobads


	;NOTE US A1 only for bullets!!!!!
	
	bsr	findbullptr		;find me an alive bullet
	cmp.l	#0,d0
	beq	.nobulls
	
	bsr	bulltoplayxy	;are we near each other?
	cmp.l	#0,d0
	beq	.nobulls		;nowhere near. no blit coll
		
	bsr	bulltoplayblit	;blit bullet on to collision
	cmp.l	#0,d0
	beq	.nobulls 		;no collision!
	
	;* player has been hit *
	PUSHALL
	bsr	clearcollplayer	;clear player from collision	
	PULLALL

	;first do something funny to the bullet!
	clr.l	d0
	move.b	bull_go(a1),d0
	eor.b	#BOBF_UP|BOBF_DOWN|BOBF_LEFT|BOBF_RIGHT,d0
	move.b	d0,bull_go(a1)

	clr.l	d0
	move.b	bull_power(a1),d0

	bsr	hurtplayer	
.nobulls

	;next baddy pointer !!!!!! AUTOMATIC (in get baddy
	;next bullet pointer !!!!!!
		
	add.l	#bullet_nd-bullet,a1	;next bullet
	add.l	#1,d5		;next bullet!
	add.b	#1,d6		;next baddy/bullet
	cmp.b	#bnb_max,d6		;at max of bullets and baddies
	ble	.main2
	
	PUSHALL
	bsr	clearcollplayer	;clear player from collision	
	PULLALL
		
	clr.l	d6
	;reset baddy pointer
	lea	bad_no,a4		;point to baddy list
	;reset bullet pointer
	clr.l	d5		;bullet count
	lea	bullet_list,a1	;point to bullet list
	
	;next player pointer !!!!!!
	
	add.b	#1,d7		;next player
	cmp.b	#players_max,d7
	ble	.main
	
.out	rts

hurtplayer	;how much to hurt player in d0

	;okay, player has been hit zap some of his hit points
	
	;make him white for a bit
	move.b	#HURT,play_status(a6)
	move.b	#hittime,play_hptime(a6)	;stay white for this long!
	
	sub.b	d0,play_hp(a6)
	bgt	.nohit

	;also remove player from the liveplayers table
	move.b	#DYING,play_status(a6)	

	sub.l	#1,d7
	lea	liveplayers,a0
	move.b	#$fe,(a0,d7)	;make player dead!!!!

	add.l	#1,d7		;put all back to normal
.nohit
	rts

hurtbaddy	;how much to hurt baddy in d0

	;okay, player has been hit zap some of his hit points
	
;	;make him white for a bit
;	move.b	#HURT,play_status(a5)
;	move.b	#hittime,play_hptime(a5)	;stay white for this long!
	
	sub.b	d0,bad_hp(a5)
	bgt	.nohit

	;also remove player from the liveplayers table
	move.b	#DYING,bad_status(a5)	
.nohit
	rts

findplayptr	
	;gimme player number D7 and ill find from there an alive player
	;fail if i return 0 in d0
	;else addr of player structure in A6
	;also checks status to see of hes OKAY
	
	;find me an alive player

.main
	;if d7 over players max then bra .out
	cmp.b	#players_max,d7
	bge	.out
	
	lea	player1,a6
	clr.l	d0
	move.b	d7,d0
.loop
	cmp.b	#0,d0
	beq	.gotim
	sub.b	#1,d0
	add.l	#player1_nd-player1,a6	;next player
	bra	.loop
.gotim
	cmp.b	#OKAY,play_status(a6)
	beq	.got1
	add.b	#1,d7	;next player
	cmp.b	#players_max,d7
	beq	.out
	bra	.loop
.nodead	
 	;ALL Routines LEAVE -=> D7 <=- ALONE


.got1	move.l	#1,d0
	rts

.out	;all players dead!!!!
	move.l	#0,d0
	rts

findbadptr		;find me an alive baddy	
	;uses baddy struture pointer A4
	;returns baddy struture in A5

.badloop	move.l	(a4)+,a5	;get baddy
	cmp.l	#0,a5
	beq	.no_bads

	;check to see if baddy is alive
	cmp.b	#OKAY,bad_status(a5)
	bne	.badloop	;cant hit him if baddy DEAD!
	

	move.l	#1,d0
	rts
.no_bads
	sub.l	#4,a4	#go down 1 please
	move.l	#0,d0
	rts

badtoplayxy		;are we near each other?
	;check PLAYER Vs BADDY	
	clr.l	d0
	clr.l	d1
	move.w	bad_x(a5),d0
	add.w	#16,d0
	cmp.w	play_xpos(a6),d0
	bgt	.pastme
	bra	.checkout
.pastme
	move.w	bad_x(a5),d0
	sub.w	#16,d0
	cmp.w	play_xpos(a6),d0
	bge	.checkout
	
.COLLISIONX
	clr.l	d0
	clr.l	d1
	move.w	bad_y(a5),d0
	add.w	#24,d0
	cmp.w	play_ypos(a6),d0
	bgt	.belowme
	bra	.checkout
.belowme
	move.w	bad_y(a5),d0
	sub.w	#16,d0
	cmp.w	play_ypos(a6),d0
	blt	.COLLISIONY
	bra	.checkout

.COLLISIONY
	move.l	#1,d0	;hey ive hit somebody!
	rts
.checkout
	move.l	#0,d0	;missed
	rts
	
	

blitcollplayer	;blit player onto collision	
	;player struct in a6
	
	move.l	a6,spare
	CALLGRAF	WaitBlit
	move.l	spare,a6
	
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-4,$dff066	;mod D
	move.w	#0,$dff042	

	move.w	play_smooth(a6),d0	;get smooth
	and.w	#$f000,d0
	or.w	#$09f0,d0
	move.w	d0,$dff040	
	
	move.l	collbase,a2		;get coarse
	clr.l	d0
	clr.l	d1
	move.w	play_xpos(a6),d0
	move.w	play_ypos(a6),d1
	sub.w	#8,d1		;player is 24 high
	mulu	#scrwid,d1

	and.w	#$fff0,d0	;do corse scrol
	lsr.w	#3,d0
	add.w	d0,d1	;got coarse
	
	add.l	d1,a2	;worked out coarse

	move.l	a2,spare+4	;save it for clear rtn
		
	move.l	Player1COLLBase,a3
;	lea	playersCOLL,a3
	
	clr.l	d0
	clr.l	d1
	move.b	play_anim_style(a6),d0	;get style
	mulu	#40*24,d0		;get to anim set
	
	move.b	play_anim_frame(a6),d1	;get frame
	lsl.l	#2,d1
	add.l	d1,d0
	add.l	d0,a3	;add to player gfx
	
	move.l	a3,$dff050	;get mask A
	move.l	a2,$dff054	;dst D	screen
	move.w	#(24*1*64)+2,$dff058

	rts

clearcollplayer	;clear player from collision	
	move.l	a6,spare
	CALLGRAF	WaitBlit
	move.l	spare,a6
	
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#40-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-4,$dff066	;mod D
	move.w	#0,$dff042	

	move.w	#$0100,$dff040	
	
	move.l	spare+4,a2
	
	move.l	a2,$dff054	;dst D	screen
	move.w	#(24*1*64)+2,$dff058

	rts

blitcollbaddy	;blit baddy onto collision	
	;baddy struct in a5
	
	move.l	a5,spare
	CALLGRAF	WaitBlit
	move.l	spare,a5
	
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#80-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-4,$dff066	;mod D
	move.w	#0,$dff042	

	move.w	bad_smooth(a5),d0	;get smooth
	and.w	#$f000,d0
	or.w	#$09f0,d0
	move.w	d0,$dff040	
	
	move.l	collbase,a2		;get coarse
	clr.l	d0
	clr.l	d1
	move.w	bad_x(a5),d0
	move.w	bad_y(a5),d1
	mulu	#scrwid,d1

	and.w	#$fff0,d0	;do corse scrol
	lsr.w	#3,d0
	add.w	d0,d1	;got coarse
	
	add.l	d1,a2	;worked out coarse

	move.l	a2,spare+4	;save it for clear rtn
		
	move.l	Baddy1COLLBase,a3

	clr.l	d0
	move.b	bad_gfxnum(a5),d0
.findgfx
	cmp.l	#0,d0
	beq	.nogfx
	add.l	#80*1*16,a3
	dbra	d0,.findgfx
.nogfx

	clr.l	d0
	move.b	bad_anim(a5),d0	;get anim no.
	
	;figure out what gfk to display
	;get direction to suss which gfks to use
	clr.l	d1
	lea	bad_an_rcnt(a5),a2	;get actuall addr
	move.b	bad_an_off(a5),d1
	add.l	#1,a2		;skip counter
	add.l	d1,a2		;found bank!
	add.l	d0,a2		;found char
	
	clr.l	d0
	move.b	(a2),d0		;get char
	
	rol.l	#2,d0		;make long!
	add.l	d0,a3		;got baddy

	move.l	a3,$dff050	;get mask A
	move.l	spare+4,$dff054	;dst D	screen
	move.w	#(16*1*64)+2,$dff058

	rts

clearcollbaddy	;clear baddy from collision	
	move.l	a5,spare
	CALLGRAF	WaitBlit
	move.l	spare,a5
	
	move.w	#$ffff,$dff044	;fwm
	move.w	#$ffff,$dff046	;lwm
	move.w	#80-4,$dff064	;mod A .gfx map = 6 bytes. ball = 4
	move.w	#scrwid-4,$dff066	;mod D
	move.w	#0,$dff042	

	move.w	#$0100,$dff040	
	
	move.l	spare+4,a2
	
	move.l	a2,$dff054	;dst D	screen
	move.w	#(16*1*64)+2,$dff058

	rts
guntobadxy		;are we near each other?
	;check bullet(a1) Vs baddy(a5)
	clr.l	d0
	clr.l	d1
	move.w	bad_x(a5),d0
	add.w	#16,d0
	cmp.w	bull_xpos(a1),d0
	bgt	.pastme
	bra	.checkout
.pastme
	move.w	bad_x(a5),d0
	sub.w	#16,d0
	cmp.w	bull_xpos(a1),d0
	bge	.checkout
	
.COLLISIONX
	clr.l	d0
	clr.l	d1
	move.w	bad_y(a5),d0
	add.w	#12,d0
	cmp.w	bull_ypos(a1),d0
	bgt	.belowme
	bra	.checkout
.belowme
	move.w	bad_y(a5),d0
	sub.w	#12,d0
	cmp.w	bull_ypos(a1),d0
	blt	.COLLISIONY
	bra	.checkout

.COLLISIONY
	move.l	#1,d0	;hey ive hit somebody!
	rts
.checkout
	move.l	#0,d0	;missed
	rts

badtoplayblit	;blit baddy on to collision
	;collision minterm A and B = 0CC0 (Does not use D)
	;if no collision clear temp
	;%0000 1100 0000 0000 SRC AB
	;%0000 1100 1100 0000 A and B

	move.w	#$ffff,_CUSTOM+bltafwm	;fwm
	move.w	#$ffff,_CUSTOM+bltalwm	;lwm
	move.w	#80-4,_CUSTOM+bltamod	;mod A baddy collisiob
	move.w	#scrwid-4,_CUSTOM+bltbmod	;mod B player collision

	clr.l	d0
	move.w	bad_smooth(a5),d0	;get smooth
	and.w	#$f000,d0
	or.w	#$0cc0,d0
	
	move.w	d0,_CUSTOM+bltcon0	;collision please
	move.w	#0,_CUSTOM+bltcon1

	move.l	collbase,a2		;get coarse
	clr.l	d0
	clr.l	d1
	move.w	bad_x(a5),d0
	move.w	bad_y(a5),d1
	mulu	#scrwid,d1

	and.w	#$fff0,d0	;do corse scrol
	lsr.w	#3,d0
	add.w	d0,d1	;got coarse
	
	add.l	d1,a2	;worked out coarse
	move.l	a2,_CUSTOM+bltbpt	;baddy addr


	clr.l	d0
	;find what gfk to use!!
	move.l	Baddy1COLLBase,a3
	move.b	bad_gfxnum(a1),d0
.findgfx
	cmp.l	#0,d0
	beq	.nogfx
	add.l	#80*1*16,a3
	dbra	d0,.findgfx
.nogfx
	


	clr.l	d0
	move.b	bad_anim(a5),d0	;get anim no.
	
	;figure out what gfk to display
	;get direction to suss which gfks to use
	clr.l	d1
	lea	bad_an_rcnt(a5),a2	;get actuall addr
	move.b	bad_an_off(a5),d1
	add.l	#1,a2		;skip counter
	add.l	d1,a2		;found bank!
	add.l	d0,a2		;found char
	
	clr.l	d0
	move.b	(a2),d0		;get char
	
	rol.l	#2,d0		;make long!
	add.l	d0,a3		;got baddy
	
	move.l	a3,_CUSTOM+bltapt	;baddy gfk

	move.w	#(16*1*64)+2,_CUSTOM+bltsize	;go for it

	move.l	a6,spare
	CALLGRAF	WaitBlit
	move.l	spare,a6

	btst	#13,_CUSTOM+dmaconr
	beq	.nocollision
	move.l	#0,d0		;Got im
	rts
.nocollision
	move.l	#1,d0		;missed!
	rts	


findbullptr		;find me an alive bullet
	;if its a lazer then dont do any collision
	cmp.b	#WeapLazer,bull_gun(a1)
	beq	.lazer
	
	;check to see if bullet is alive
	cmp.b	#OKAY,bull_status(a1)
	beq	.okay

.lazer	add.l	#bullet_nd-bullet,a1	;next bullet
	add.b	#1,d5
	cmp.b	#bullet_max-1,d5
	ble	findbullptr
	;no bullets!
	sub.l	#bullet_nd-bullet,a1	;pre bullet
	move.l	#0,d0
	rts
	

.okay	move.l	#$1,d0		;got 1
	rts

bulltoplayxy	;are we near each other?
	clr.l	d0
	clr.l	d1
	move.w	bull_xpos(a1),d0
	add.w	#16,d0
	cmp.w	play_xpos(a6),d0
	bgt	.pastme
	bra	.checkout
.pastme
	move.w	bull_xpos(a1),d0
	sub.w	#16,d0
	cmp.w	play_xpos(a6),d0
	bge	.checkout
	
.COLLISIONX
	clr.l	d0
	clr.l	d1
	move.w	bull_ypos(a1),d0
	add.w	#16,d0
	cmp.w	play_ypos(a6),d0
	bgt	.belowme
	bra	.checkout
.belowme
	move.w	bull_ypos(a1),d0
	sub.w	#16,d0
	cmp.w	play_ypos(a6),d0
	blt	.COLLISIONY
	bra	.checkout

.COLLISIONY
	move.b	#1,d0	;hey ive hit somebody!
	rts
	
.checkout
	move.b	#0,d0	;missed
	rts

bulltoplayblit	;blit bullet on to collision
	;collision minterm A and B = 0CC0 (Does not use D)
	;if no collision clear temp
	;%0000 1100 0000 0000 SRC AB
	;%0000 1100 1100 0000 A and B

	move.w	#$ffff,_CUSTOM+bltafwm	;fwm
	move.w	#$ffff,_CUSTOM+bltalwm	;lwm
	move.w	#40-4,_CUSTOM+bltamod	;mod A bullet collisiob
	move.w	#scrwid-4,_CUSTOM+bltbmod	;mod B player collision

	clr.l	d0
	move.w	bull_smooth(a1),d0	;get smooth
	and.w	#$f000,d0
	or.w	#$0cc0,d0
	
	move.w	d0,_CUSTOM+bltcon0	;collision please
	move.w	#0,_CUSTOM+bltcon1

	move.l	collbase,a2		;get coarse
	clr.l	d0
	clr.l	d1
	move.w	bull_xpos(a1),d0
	move.w	bull_ypos(a1),d1
	mulu	#scrwid,d1

	and.w	#$fff0,d0	;do corse scrol
	lsr.w	#3,d0
	add.w	d0,d1	;got coarse
	
	add.l	d1,a2	;worked out coarse
	move.l	a2,_CUSTOM+bltbpt	;baddy addr


	;find what gfk to use!!
	clr.l	d0
	move.b	bull_wantgo(a1),d0	;find what gfk to use
	btst	#BOBB_LEFT,d0
	beq	.goingr
	move.l	#4,d0
	bra	.skip
.goingr
	clr.l	d0
.skip		
	move.l	Bullet1COLLBase,a3
	clr.l	d1
	move.w	bull_gfk(a1),d1	;weird (a2)

	;if d1 > 40 then add 40*16*5,a3
.loopin
	cmp.b	#40,d1
	blt	.ok
	add.l	#80*16*5,a3
	sub.l	#40,d1
	bra	.loopin
.ok
	add.l	d1,a3

	add.l	d0,a3
	
	move.l	a3,_CUSTOM+bltapt	;baddy gfk

	move.w	#(16*1*64)+2,_CUSTOM+bltsize	;go for it

	move.l	a6,spare
	CALLGRAF	WaitBlit
	move.l	spare,a6

	btst	#13,_CUSTOM+dmaconr
	beq	.nocollision
	move.l	#0,d0		;got im
	rts
.nocollision
	move.l	#1,d0		;missed!
	rts

bulltobadblit	;blit bullet on to collision
	;collision minterm A and B = 0CC0 (Does not use D)
	;if no collision clear temp
	;%0000 1100 0000 0000 SRC AB
	;%0000 1100 1100 0000 A and B

	move.w	#$ffff,_CUSTOM+bltafwm	;fwm
	move.w	#$ffff,_CUSTOM+bltalwm	;lwm
	move.w	#40-4,_CUSTOM+bltamod	;mod A bullet collisiob
	move.w	#scrwid-4,_CUSTOM+bltbmod	;mod B baddy collision

	clr.l	d0
	move.w	bull_smooth(a1),d0	;get smooth
	and.w	#$f000,d0
	or.w	#$0cc0,d0
	
	move.w	d0,_CUSTOM+bltcon0	;collision please
	move.w	#0,_CUSTOM+bltcon1

	move.l	collbase,a2		;get coarse
	clr.l	d0
	clr.l	d1
	move.w	bull_xpos(a1),d0
	move.w	bull_ypos(a1),d1
	mulu	#scrwid,d1

	and.w	#$fff0,d0	;do corse scrol
	lsr.w	#3,d0
	add.w	d0,d1	;got coarse
	
	add.l	d1,a2	;worked out coarse
	move.l	a2,_CUSTOM+bltbpt	;baddy addr


	;find what gfk to use!!
	clr.l	d0
	move.b	bull_wantgo(a1),d0	;find what gfk to use
	btst	#BOBB_LEFT,d0
	beq	.goingr
	move.l	#4,d0
	bra	.skip
.goingr
	clr.l	d0
.skip		
	move.l	Bullet1COLLBase,a3
	clr.l	d1
	move.w	bull_gfk(a1),d1

	;if d1 > 40 then add 40*16*5,a3
.loopin
	cmp.b	#40,d1
	blt	.ok
	add.l	#80*16*5,a3
	sub.l	#40,d1
	bra	.loopin
.ok
	add.l	d1,a3

	add.l	d0,a3
	
	move.l	a3,_CUSTOM+bltapt	;baddy gfk

	move.w	#(16*1*64)+2,_CUSTOM+bltsize	;go for it

	move.l	a6,spare
	CALLGRAF	WaitBlit
	move.l	spare,a6

	btst	#13,_CUSTOM+dmaconr
	beq	.nocollision
	move.l	#0,d0		;got im
	rts
.nocollision
	move.l	#1,d0		;missed!
	rts

AllocTemps		;alloc all the tempory storage for gfx

	;allocate bad_temp1
	clr.l	d0		;allocate some memory for it!
	move.l	#4*16*5*bad_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,bad_temp1Base

	;allocate bad_temp2
	clr.l	d0		;allocate some memory for it!
	move.l	#4*16*5*bad_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,bad_temp2Base

	;allocate player_temp1
	clr.l	d0		;allocate some memory for it!
	move.l	#4*24*5*players_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,player_temp1Base

	;allocate player_temp2
	clr.l	d0		;allocate some memory for it!
	move.l	#4*24*5*players_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,player_temp2Base

	;allocate bullet_temp1
	clr.l	d0		;allocate some memory for it!
	move.l	#4*16*5*bullet_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,bullet_temp1Base

	;allocate bullet_temp2
	clr.l	d0		;allocate some memory for it!
	move.l	#4*16*5*bullet_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,bullet_temp2Base

	;allocate gun_temp1
	clr.l	d0		;allocate some memory for it!
	move.l	#4*16*5*gun_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,gun_temp1Base

	;allocate gun_temp2
	clr.l	d0		;allocate some memory for it!
	move.l	#4*16*5*gun_max,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,gun_temp2Base

	;allocate lazertemp
	clr.l	d0		;allocate some memory for it!
	move.l	#scrwid*(16*4)*5,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,lazertempBase

	rts
FreeTemps
	;free up badtemp1
	move.l	#4*16*5*bad_max,d0
	move.l	bad_temp1Base,a1
	CALLEXEC	FreeMem

	;free up badtemp2
	move.l	#4*16*5*bad_max,d0
	move.l	bad_temp2Base,a1
	CALLEXEC	FreeMem

	;free up playertemp1
	move.l	#4*24*5*players_max,d0
	move.l	player_temp1Base,a1
	CALLEXEC	FreeMem

	;free up playertemp2
	move.l	#4*24*5*players_max,d0
	move.l	player_temp2Base,a1
	CALLEXEC	FreeMem

	;free up bullettemp1
	move.l	#4*16*5*bullet_max,d0
	move.l	bullet_temp1Base,a1
	CALLEXEC	FreeMem

	;free up bullettemp2
	move.l	#4*16*5*bullet_max,d0
	move.l	bullet_temp2Base,a1
	CALLEXEC	FreeMem

	;free up guntemp1
	move.l	#4*16*5*gun_max,d0
	move.l	gun_temp1Base,a1
	CALLEXEC	FreeMem

	;free up guntemp2
	move.l	#4*16*5*gun_max,d0
	move.l	gun_temp2Base,a1
	CALLEXEC	FreeMem

	;free up lazertemp
	move.l	#scrwid*(16*4)*5,d0
	move.l	lazertempBase,a1
	CALLEXEC	FreeMem

	rts

FreeGfxMem
	move.l	CharSize,d0
	move.l	CharBase,a1
	CALLEXEC	FreeMem
	
	move.l	MaskSize,d0
	move.l	MaskBase,a1
	CALLEXEC	FreeMem

	move.l	CmapSize,d0
	move.l	CmapBase,a1
	CALLEXEC	FreeMem

	move.l	LDSize,d0
	move.l	LDBase,a1
	CALLEXEC	FreeMem

	move.l	BackSize,d0
	move.l	BackBase,a1
	CALLEXEC	FreeMem

	move.l	TitleSize,d0
	move.l	TitleBase,a1
	CALLEXEC	FreeMem

	move.l	FontSize,d0
	move.l	FontBase,a1
	CALLEXEC	FreeMem

	move.l	Baddy1Size,d0
	move.l	Baddy1Base,a1
	CALLEXEC	FreeMem

	move.l	Baddy1COLLSize,d0
	move.l	Baddy1COLLBase,a1
	CALLEXEC	FreeMem

	move.l	Player1Size,d0
	move.l	Player1Base,a1
	CALLEXEC	FreeMem

	move.l	Player1COLLSize,d0
	move.l	Player1COLLBase,a1
	CALLEXEC	FreeMem

	move.l	Bullet1Size,d0
	move.l	Bullet1Base,a1
	CALLEXEC	FreeMem

	move.l	Bullet1COLLSize,d0
	move.l	Bullet1COLLBase,a1
	CALLEXEC	FreeMem
	
	rts
LoadNProcess
	;first load in the IntSet File From T dir
	bsr	LoadIntSet

	bsr	LoadChar	;search IntSet for Char filename. load & process
	bsr	LoadMask	;search IntSet for Mask filename. load & process
	bsr	LoadCmap	;search IntSet for Cmap filename. load & process

	bsr	LoadLev	;search IntSet for level filename. load & process
	bsr	LoadBack	;search IntSet for backdrop filename. load & process
	bsr	LoadTitle	;search intset for title screen (320*104)
	bsr	LoadFont	;search intset for font (832*48)
	bsr	LoadBaddy1	;search IntSet for baddy filename. load & process
	
	bsr	LoadPlayer1	;search IntSet for player1 filename. load & process
	bsr	LoadBullet1	;search IntSet for bullet1 filename. load & process
	;search through it until you find CHAR=
	rts
LoadChar
	lea	charascii,a0
	bsr	FindAscii		;search through IntSet until you Find CHAR=
	
				;find ascii returns the filename its found in A0
				;* NOTE * the file name is not ZERO terminated
				;with a bit of luck its $0a terminated

	bsr	getfname

	move.l	#40960,CharSize
	
	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	CharSize,d0
	move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,CharBase

	;load as an iff file!
	bsr	convertchar
	bsr	ilbm_to_twi4
	;FileBase	is the start of the ilbm pic
;	lea	FileName,a0	
;	bsr	LoadChipData
;	move.l	FileSize,CharSize
;	move.l	FileBase,CharBase	
	rts

ilbm_to_twi4
	move.l	FileBase,a3	;get source
	move.l	CharBase,a1	;get dest
;	add.l	#16*5*2,a1	;get past blank first char!
	
	;source is 40*5 for bit1
	;dest is 2*5 for bit1
	clr.l	d7
	move.w	#13,d5		;do 13*20 = 260!
.loop3
	clr.l	d6
	move.l	a3,a2
.loop
	move.l	a2,a0
	move.w	#16-1,d4
.loop2
	move.w	(a0),(a1)		;copy 1 plane
	move.w	40(a0),2(a1)	;copy 1 plane
	move.w	80(a0),4(a1)	;copy 1 plane
	move.w	120(a0),6(a1)	;copy 1 plane
	move.w	160(a0),8(a1)	;copy 1 plane
	
	add.l	#40*5,a0	;next line please
	add.l	#2*5,a1	;next line please
	dbra	d4,.loop2
	
	add.w	#1,d7	;char counter
	cmp.w	#255,d7
	beq	.out	;finish when 256
		
	add.l	#2,a2
	add.w	#1,d6
	cmp.w	#20,d6
	bne	.loop	;do a line of chars
	add.l	#16*40*5,a3
	dbra	d5,.loop3
	
.out
	;now free up the iff mem...
	;free up the memory!
	move.l	#42*5*256,d0
	move.l	FileBase,a1
	CALLEXEC	FreeMem


	rts


convertchar

	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#256,d2		;height
	CALLGRAF	InitBitMap

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	#42*5*256,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,FileBase
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	FileBase,a0
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

LoadMask
	;create the mask for the chars (dont be so lame)
	move.l	#8192,MaskSize
	move.l	MaskSize,d0
	move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,MaskBase
	
	move.l	CharBase,a0
	move.l	MaskBase,a1
	move.l	#256-1,d7
.loop2	
	move.l	#16-1,d6
.loop
	clr.l	d0
	move.w	(a0)+,d0	;1bp
	or.w	(a0)+,d0	;2bp
	or.w	(a0)+,d0	;3bp
	or.w	(a0)+,d0	;4bp
	or.w	(a0)+,d0	;5bp
	move.w	d0,(a1)+
	dbra	d6,.loop
	dbra	d7,.loop2
	
	
	rts
LoadCmap
	;this loads an iff file with the cmap in it!!!!
	lea	cmapascii,a0
	bsr	FindAscii	
	bsr	getfname
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle

	move.l	iffhandle,a1		;iff handle ??
	lea	colours,a0
	CALLIFF	GetColorTab

	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	

	rts
LoadLev
	;this loads in 10 levels complete with baddy movement data.
	;and stores it in LDSize,LDBase
		
	;okay this is difficult. grab levelnum var.
	;and create an ascii number for it.
	;then put it on top of the = and put the = after
	;i.e.
	;LEVEL=
	;LEVEL01=
	
	;copy level to scratch so we can add the number to it
	lea	levascii,a0
	lea	scratch,a1
.copy	move.b	(a0)+,(a1)+
	bne	.copy

	;go backwards until you find the =
.back	cmp.b	#"=",-(a1)
	bne	.back
		
	clr.l	d0
	move.b	LevelNum,d0
	move.l	a1,a0
	bsr	numtoasc
	move.b	#"=",(a0)+		;put the = back on
	move.b	#0,(a0)+		;terminate please

	lea	scratch,a0
	bsr	FindAscii	
	bsr	getfname
	lea	FileName,a0	
	bsr	LoadNormData
	move.l	FileSize,LDSize
	move.l	FileBase,LDBase	
	lea	lev1ascii,a2	(10 bytes)

FindLev
	;thats loaded the data in for 10 levels!
	;set up pointer to first level please
	
	move.l	LDBase,a1
	move.l	a1,d0
	add.l	LDSize,d0		;go max size
.loop	
	move.l	#9-1,d7		;how many chars
	move.l	a2,a0	(10 bytes)
	cmp.l	d0,a1
	bge	.lost
	cmp.b	(a0)+,(a1)+		;are they the same?
	bne	.loop		;no
	;groovy, ive found a match
.match	cmp.b	(a0)+,(a1)+
	bne	.loop
	dbra	d7,.match
	move.l	a1,LevBase

	;now find a pointer to the first baddy	

	move.l	LevBase,a1
	move.l	LDBase,d0
	add.l	LDSize,d0		;go max size
.loop2
	move.l	#7-1,d7		;how many chars
	lea	bad1ascii,a0	(8 bytes)
	cmp.l	d0,a1
	bge	.lost
	cmp.b	(a0)+,(a1)+		;are they the same?
	bne	.loop2		;no
	;groovy, ive found a match
.match2	cmp.b	(a0)+,(a1)+
	bne	.loop2
	dbra	d7,.match2
	move.l	a1,BadBase
	
	rts
.lost	;cant find the level!!!!
	;**** PANIC *******
	rts
LoadBack
	;use levelnum to get the backdrop number!
	;copy level to scratch so we can add the number to it
	lea	backascii,a0
	lea	scratch,a1
.copy	move.b	(a0)+,(a1)+
	bne	.copy

	;go backwards until you find the =
.back	cmp.b	#"=",-(a1)
	bne	.back
		
	clr.l	d0
	move.b	LevelNum,d0
	move.l	a1,a0
	bsr	numtoasc
	move.b	#"=",(a0)+		;put the = back on
	move.b	#0,(a0)+		;terminate please

	lea	scratch,a0
	bsr	FindAscii	
	bsr	getfname
	
	bsr	ConvertBackDrop

	rts
ConvertBackDrop

	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#256,d2		;height
	CALLGRAF	InitBitMap

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	BackSize,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,BackBase
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	BackBase,a0
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

LoadTitle
	lea	titascii,a0
	bsr	FindAscii	
	bsr	getfname
	
	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#104,d2		;height
	CALLGRAF	InitBitMap

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	TitleSize,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,TitleBase
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	TitleBase,a0
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

LoadFont
	lea	fontascii,a0
	bsr	FindAscii	
	bsr	getfname
	
	;This is an IFF piccy.
	;We want a bitmap one please so lets use the iff library to load
	
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#832*5,d1	;width
	move.l	#48,d2		;height
	CALLGRAF	InitBitMap

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	FontSize,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,FontBase
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	FontBase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#104,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	
	rts

LoadBaddy1
	lea	baddyascii,a0
	lea	scratch,a1
.copy	move.b	(a0)+,(a1)+
	bne	.copy

	;go backwards until you find the =
.back	cmp.b	#"=",-(a1)
	bne	.back
		
	clr.l	d0
	move.b	#1,d0	;** baddy NUMBER **
	move.l	a1,a0
	bsr	numtoasc
	move.b	#"=",(a0)+		;put the = back on
	move.b	#0,(a0)+		;terminate please

	lea	scratch,a0
	bsr	FindAscii	
	bsr	getfname

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	Baddy1Size,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,Baddy1Base

	move.l	Baddy1Size,BaddySize
	move.l	Baddy1Base,BaddyBase

	bsr	ConvertBaddy
	
	;Convert the collision plane, so jump to it

	;allocate some memory for the collision plane
	clr.l	d0		;allocate some memory for it!
	move.l	Baddy1COLLSize,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,Baddy1COLLBase

	move.l	Baddy1COLLSize,BaddyCOLLSize
	move.l	Baddy1COLLBase,BaddyCOLLBase
	
	bsr	ConvertBaddyColl
		
	rts

ConvertBaddyColl
	move.l	BaddyBase,a0	;source
	move.l	BaddyCOLLBase,a1	;dest
	
	;640 or next 640 or next 640 or next 640 or next 640 = COLL

	move.l	#baddygfx-1,d5		;no. of baddies
.loop3	

	move.l	#16-1,d6		;copy 16 rows or 1 char
.loop2	
	move.l	a0,a2		;save for later
	move.l	#40-1,d7	;copy 1 row
.loop
	move.w	(a1),d0
	or.w	(a2),d0		;or 1st bitplane
	or.w	80(a2),d0		;or 2nd bitplane
	or.w	160(a2),d0		;or 3rd bitplane
	or.w	240(a2),d0		;or 4th bitplane
	or.w	320(a2),d0		;or 5th bitplane
	move.w	d0,(a1)
	add.l	#2,a2
	add.l	#2,a1	
	dbra	d7,.loop
	add.l	#80*5,a0		;next row please
	dbra	d6,.loop2
	add.l	#16*80*5,a0		;skip the mask gfk please
	dbra	d5,.loop3

	rts

ConvertBaddy	;Load N Convert IFF piccy of baddies
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#640*5,d1		;width
	move.l	#baddygfx*32,d2		;height
	CALLGRAF	InitBitMap
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	BaddyBase,a0
	lea	bitmap,a1
.back	move.l	a0,bm_Planes(a1)
	add.l	#80,a0
	add.l	#4,a1	;next long please
	dbra	d7,.back

	move.l	iffhandle,a1
	lea	bitmap,a0
	CALLIFF	DecodePic
	
	move.l	iffhandle,a1
	CALLIFF	CloseIFF	
	
	
	rts

ConvertPlayerColl
	move.l	PlayerBase,a0	;source
	move.l	PlayerCOLLBase,a1	;dest
	
	;320 or next 320 or next 320 or next 320 or next 320 = COLL


	move.l	#48-1,d6		;copy 48 rows or 2 char 
.loop2	
	move.l	a0,a2		;save for later
	move.l	#20-1,d7	;copy 1 row
.loop
	move.w	(a1),d0
	or.w	(a2),d0		;or 1st bitplane
	or.w	40(a2),d0		;or 2nd bitplane
	or.w	80(a2),d0		;or 3rd bitplane
	or.w	120(a2),d0		;or 4th bitplane
	or.w	160(a2),d0		;or 5th bitplane
	move.w	d0,(a1)
	add.l	#2,a2
	add.l	#2,a1	
	dbra	d7,.loop
	add.l	#40*5,a0		;next row please
	dbra	d6,.loop2

	rts

ConvertPlayer	;Load N Convert IFF piccy of baddies
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#48+48,d2		;height & mask
	CALLGRAF	InitBitMap
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	PlayerBase,a0
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

ConvertBulletColl
	move.l	BulletBase,a0	;source
	move.l	BulletCOLLBase,a1	;dest
	
	;320 or next 320 or next 320 or next 320 or next 320 = COLL


	move.l	#16-1,d6		;copy 16 rows or 1 char
.loop2	
	move.l	a0,a2		;save for later
	move.l	#20-1,d7	;copy 1 row
.loop
	move.w	(a1),d0
	or.w	(a2),d0		;or 1st bitplane
	or.w	40(a2),d0		;or 2nd bitplane
	or.w	80(a2),d0		;or 3rd bitplane
	or.w	120(a2),d0		;or 4th bitplane
	or.w	160(a2),d0		;or 5th bitplane
	move.w	d0,(a1)
	add.l	#2,a2
	add.l	#2,a1	
	dbra	d7,.loop
	add.l	#40*5,a0		;next row please
	dbra	d6,.loop2

	rts

ConvertBullet	;Load N Convert IFF piccy of baddies
	lea	FileName,a0	
	move.l	#IFFL_MODE_READ,d0
	CALLIFF	OpenIFF
	move.l	d0,iffhandle
	
	lea	bitmap,a0
	move.l	#$05,d0		;depth
	move.l	#320*5,d1		;width
	move.l	#32*(bullgfxline),d2		;height & mask
	CALLGRAF	InitBitMap
	
	;now copy the pointer into the bitmap structure
	move.l	#5-1,d7
	move.l	BulletBase,a0
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

LoadPlayer1
	lea	player1ascii,a0
	bsr	FindAscii	
	bsr	getfname

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	Player1Size,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,Player1Base

	move.l	Player1Size,PlayerSize
	move.l	Player1Base,PlayerBase

	bsr	ConvertPlayer
	
	;Convert the collision plane, so jump to it

	;allocate some memory for the collision plane
	clr.l	d0		;allocate some memory for it!
	move.l	Player1COLLSize,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,Player1COLLBase

	move.l	Player1COLLSize,PlayerCOLLSize
	move.l	Player1COLLBase,PlayerCOLLBase
	
	bsr	ConvertPlayerColl
		
	rts

LoadBullet1
	lea	bullet1ascii,a0
	bsr	FindAscii	
	bsr	getfname

	;allocate some memory for the picture
	clr.l	d0		;allocate some memory for it!
	move.l	Bullet1Size,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,Bullet1Base

	move.l	Bullet1Size,BulletSize
	move.l	Bullet1Base,BulletBase

	bsr	ConvertBullet
	
	;Convert the collision plane, so jump to it

	;allocate some memory for the collision plane
	clr.l	d0		;allocate some memory for it!
	move.l	Bullet1COLLSize,d0
	move.l	#MEMF_CLEAR|MEMF_CHIP,d1
	CALLEXEC	AllocMem
	move.l	d0,Bullet1COLLBase

	move.l	Bullet1COLLSize,BulletCOLLSize
	move.l	Bullet1COLLBase,BulletCOLLBase
	
	bsr	ConvertBulletColl
		
	rts


numtoasc	;gimme number (d0) and dest ascii (a0)	
	clr.l	d1
.howmany100
	add.l	#1,d1
	sub.l	#100,d0
	bge	.howmany100
	add.l	#100,d0
	add.b	#"0"-1,d1
	move.b	d1,(a0)+

	clr.l	d1
.howmany10
	add.l	#1,d1
	sub.l	#10,d0
	bge	.howmany10
	add.l	#10,d0
	add.b	#"0"-1,d1
	move.b	d1,(a0)+
	
	add.b	#"0",d0
	move.b	d0,(a0)+
	
	rts

asciinum	dc.b	"000",0
	even
	cnop	0,4

getfname	
	lea	FileName,a1
.copyname	cmp.b	#$0a,(a0)
	beq	.eoname
	move.b	(a0)+,(a1)+
	bra	.copyname
.eoname	move.b	#$00,(a1)+	;zero termiante
	rts

LoadChipData
	move.l	#FileName,d1	;filename
	move.l	#MODE_OLDFILE,d2	;mode read
	CALLDOS	Open
	move.l	d0,Handle
	
	move.l	#FileName,d1	;filename
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
LoadNormData
	move.l	#FileName,d1	;filename
	move.l	#MODE_OLDFILE,d2	;mode read
	CALLDOS	Open
	move.l	d0,Handle
	
	move.l	#FileName,d1	;filename
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


FindAscii	;a0 has pointer to line we are looking for
	move.l	IntBase,a1
	move.l	a1,a3	;In HERE
	move.l	a0,a2	;Find ME
	
.loop
	cmp.b	#'=',(a2)
	beq	.Gottim
	cmp.b	(a2)+,(a3)+	;are they the same?
	beq	.loop
	;no they are not the same. skip line please
.skip	cmp.b	#$0a,(a3)+
	bne	.skip
	move.l	a0,a2	;Find ME
	bra	.loop
	
.Gottim
	add.l	#1,a3	;skip the =
	move.l	a3,a0	;a0 has pointer to name!
	rts
	
LoadIntSet
	move.l	#IntFName,d1	;filename
	move.l	#MODE_OLDFILE,d2	;mode read
	CALLDOS	Open
	move.l	d0,Handle
	
	move.l	#IntFName,d1	;filename
	move.l	#ACCESS_READ,d2
	CALLDOS	Lock
	move.l	d0,LockFile
	
	move.l	LockFile,d1
	move.l	#FileInfo,d2
	CALLDOS	Examine
	
	lea	FileInfo,a0
	move.l	fib_Size(a0),IntSize	;get size please

	clr.l	d0		;allocate some memory for it!
	move.l	IntSize,d0
	move.l	#MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,IntBase

	move.l	Handle,d1		;filename
	move.l	IntBase,d2		;pos in mem
	move.l	IntSize,d3		;size
	CALLDOS	Read

	move.l	LockFile,d1
	CALLDOS	UnLock
	
	move.l	Handle,d1	;filename
	CALLDOS	Close
	rts

	rts
	even
	cnop	0,4
Handle	dc.l	0
LockFile	dc.l	0
FileBase	dc.l	0
FileSize	dc.l	0
IntBase	dc.l	0
IntSize	dc.l	0
FileInfo	dcb.b	240,0
scratch	dcb.b	20,0	;for creating things like level002 etc..
IntFName	dc.b	"YOB:IntSet",0
charascii	dc.b	"CHAR=",0
cmapascii	dc.b	"COLMAP=",0
levascii	dc.b	"LEVEL=",0	;cat num (scratch)
backascii	dc.b	"BACK=",0	;cat num
baddyascii	dc.b	"BADDY=",0	;cat num
titascii	dc.b	"TITLE=",0
fontascii	dc.b	"FONT=",0
player1ascii	dc.b	"PLAYER1=",0
bullet1ascii	dc.b	"BULLET1=",0
lev1ascii	dc.b	"LEVEL 001",0	;1st level
bad1ascii	dc.b	"BADDY01",0		;1st baddy
badascii	dc.b	"BADDY",0,0,0	;1st baddy play with
FileName	dcb.b	256,0
	even
	cnop	0,4
init_yobtitle
	lea	sinepos,a2
	lea	maxline,a3
	lea	scrline,a4
	lea	gfkline,a5

	move.l	#yobtitnum,d2	;sine pos value
	move.l	#100,d3		;max screen line
	move.l	#0,d4		;screen line
	move.l	#0,d5	;gfk num
	
	move.l	#yobtitnum-1,d7
.loop
	move.b	d2,(a2)+		;sine
	sub.b	#1,d2
	
	move.b	d3,(a3)+		;max line
	sub.b	#4,d3
	
	move.b	d4,(a4)+		;scr line
	sub.b	#4,d4
	
	move.b	d5,(a5)+
	add.b	#1,d5		;gfk line!
	
	dbra	d7,.loop
	
	rts
go_yobtitle

	clr.l	d6		;cline data
	lea	yobclistnd-48,a1	;end of clist!
	lea	sinepos,a2
	lea	maxline,a3
	lea	scrline,a4
	lea	gfkline,a5
	
	move.l	#$2309fffe,clinedummy
	
	clr.l	d7
.main
	cmp.b	#0,(a4,d7)
	bge	.overff
	
	;its a bar not on the screen, so fill it with crap!
	move.l	clinedummy,(a1)		;copper line!
	sub.l	#$01000000,clinedummy
	move.w	#$0200,6(a1)
	add.l	#48,a1
	
	add.b	#1,(a4,d7)		;next screen line nearly!
	bra	.next
.overff

	;its a valid screen line!
	move.l	#$2409fffe,d6		;starting copper line
	clr.l	d0
	move.b	(a2,d7),d0		;get sine pos
	lea	play_walk,a6
	move.b	(a6,d0),d0		;got sine val
	add.b	(a4,d7),d0		;got screen pos
	
	cmp.b	(a3,d7),d0		;is it more than max?
	blt	.lessmax
	;morethan max
	move.b	(a3,d7),d0		;make it max then!
.lessmax
	move.b	d0,(a4,d7)		;store new screen pos!
	
	bsr	doline
	
	;inc sinepos
	
	add.b	#1,(a2,d7)
	cmp.b	#128,(a2,d7)
	bne	.notmax
	move.b	#127,(a2,d7)
.notmax
	

.next	
	sub.l	#2*48,a1		;go up a copper line!
	add.b	#1,d7
	cmp.b	#yobtitnum,d7
	bne	.main
	
FRIG	;put a blamk line in..
	;get the very bottom copper line..
	;add 4 if under $92 then set it to blank!
	
	lea	yobclr,a0		;yob clr
	lea	yobclistnd-48,a1	;end of clist!
	move.l	(a1),d0
	add.l	#$04000000,d0
	cmp.l	#$9209fffe,d0
	bge	.ok
	move.l	#$9209fffe,d0	;make it bottom
.ok
	move.l	d0,(a0)		;store it
	
	rts
	
doline
	cmp.b	#0,d0
	beq	.gotline
	add.l	#$01000000,d6	;next line
	sub.b	#1,d0
	bra	doline
.gotline
	;got the copper line
	move.l	#screen1,d0		;gfk start
	add.l	#104*(5*scrwid),d0
	add.l	#40,d0 
	add.l	#36,d0 

	clr.l	d1
	move.b	(a5,d7),d1
.dogfk
	cmp.b	#0,d1
	beq	.gotgfk
	sub.l	#4*(5*scrwid),d0
	sub.b	#1,d1
	bra	.dogfk
.gotgfk

	;now bung it in the copper!
	
	move.l	d6,(a1)+		;this line!

	add.l	#2,a1		;next line!	
	move.w	#$5200,(a1)+
	
	move.l	d0,d2
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	
	add.l	#scrwid,d0
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+

	add.l	#scrwid,d0
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+

	add.l	#scrwid,d0
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+

	add.l	#scrwid,d0
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	add.l	#2,a1
	swap	d0
	move.w	d0,(a1)+
	

	rts

title_code
	cmp.b	#0,TitleONFT
	bne	.notfirst
	move.w	#$0200,bitplanes	;planes OFF
	move.w	#$0200,bitplanes2	;planes OFF (title)

	ifeq debugging
	bsr	vblank
	bsr	vblank
	move.l	#new2,$dff080
	endc
	
	move.l	screen1,scrbase
	bsr	init_bitplanes2
	bsr	init_yobtitle
	bsr	nabscreens
	bsr	copyin_title
	bsr	titletextprg
	
	move.w	#$300,coloursTIT
	lea	coloursTIT,a0
	lea	colour2+2,a1
	bsr	go_colour2		;part of go_colour

	move.w	#$5200,bitplanes	;planes ON
	move.w	#$5200,bitplanes2	;planes ON (title)
	move.b	#1,TitleONFT
	
.notfirst
.main	
	;loop round until fire pressed
	;bne	.main
	
	;on exit, reset titleonft
	;and clear TitleON
	
	bsr	go_yobtitle
	bsr	go_pfts
	
	;now check for fire button
	btst	#7,$bfe001		;PRA (6 for the other port)
	beq	.wait
	
	rts

	;now wait for him to release the button..
.wait
;	move.w	$dff006,d0
;	and.l	#$fff,d0
;	move.w	d0,$dff180
	btst	#7,$bfe001
	beq	.wait

	move.b	#0,TitleON
	move.b	#0,TitleONFT
	
	bsr	resscreens

	bsr	SetupALL	
	bsr	go_colour		;restore colour pallete

	ifeq debugging
	bsr	vblank
	bsr	vblank
	move.l	#new,$dff080
	endc
	
	rts
	
nabscreens
	;alloc some (fast?) memory to copy the backdrop into
	move.l	#MEMF_CLEAR,d1	;Mem Requirements
	move.l	Bullet1Size,d0	;Mem size
	CALLEXEC	AllocMem
	move.l	d0,Bullet1BaseCP
	
	;now copy screen1 data into screen1copy data
	move.l	Bullet1Base,a0
	move.l	Bullet1BaseCP,a1
	move.l	Bullet1Size,d7
.copyscr1	move.b	(a0),(a1)+
	move.b	#0,(a0)+
	sub.l	#1,d7
	cmp.l	#0,d7
	bne	.copyscr1

	move.l	scrbase,scrbaseCOPY	

	;clear out screen1 and screen2
	move.l	screen1,a0
	move.l	screen2,a1
	move.l	#(screensize)-1,d7
.cls
	move.b	#0,(a0)+
	move.b	#0,(a1)+
	sub.l	#1,d7
	cmp.l	#0,d7
	bne	.cls
	
	rts

resscreens


	;now copy screen1copy data into screen1 data
	move.l	Bullet1BaseCP,a0
	move.l	Bullet1Base,a1
	move.l	Bullet1Size,d7
.copyscr1	move.b	(a0)+,(a1)+
	sub.l	#1,d7
	cmp.l	#0,d7
	bne	.copyscr1

	move.l	scrbaseCOPY,scrbase

	move.l	Bullet1Size,d0
	move.l	Bullet1BaseCP,a1
	CALLEXEC	FreeMem
	
	rts
copyin_title
	move.l	TitleBase,a0
	move.l	screen1,a1
	move.l	screen2,a2
;	add.l	#(16*scrwid*5),a1	;REMOVE IF DOING SILLY COPPER
;	add.l	#(16*scrwid*5),a2
	add.l	#2,a1
	add.l	#2,a2
	move.l	#104-1,d6	;no. lines
.loop2
	move.l	#5-1,d5	;no. bitplanes
.loop3
	move.l	#40-1,d7	;no. bytes across
.loop
	move.b	(a0),(a1)+
	move.b	(a0)+,(a2)+
	dbra	d7,.loop
	add.l	#scrwid-40,a1	;get to next plpace on screen
	add.l	#scrwid-40,a2	;get to next plpace on screen
	dbra	d5,.loop3
	
	dbra	d6,.loop2
	rts

copycolour
	lea	colours,a0
	lea	coloursTIT,a1
	move.l	#32-1,d7
.loop
	move.w	(a0)+,(a1)+
	dbra	d7,.loop
	rts
	
titletextprg

	lea	titletext,a6	;the text
	
	move.l	screen1,a1		;copy into here
	move.l	screen2,a2		;copy into here
	
	add.l	#(104*5*scrwid)+2,a1
	add.l	#(104*5*scrwid)+2,a2
	
	move.l	a1,spare
	move.l	a2,spare+4
	
.loop
	cmp.b	#0,(a6)
	beq	.out
	clr.l	d0
	move.b	(a6)+,d0
	
	cmp.b	#" ",d0
	bne	.nospc
	add.l	#2,a1
	add.l	#2,a2
	bra	.loop
.nospc
	
	cmp.b	#$0a,d0	;return
	bne	.noret
	add.l	#48*5*scrwid,spare
	add.l	#48*5*scrwid,spare+4
	move.l	spare,a1
	move.l	spare+4,a2
	bra	.loop
	
.noret
	
	
	move.l	FontBase,a0
	sub.b	#"a"+0,d0
	rol.l	#2,d0
	add.l	d0,a0

	PUSHALL
	bsr	printtext
	PULLALL

.nextspc	
	add.l	#4,a1		;next place
	add.l	#4,a2		;next place
	
	bra	.loop

.out	rts
	
printtext
	;a0 has gfk. a1 has dest.....
	;a0 832/8 wide
	;a1 scrwid wide
	;a2 scrwid wide
	
	
	clr.l	d6
	move.w	#48-1,d6		;no. lines
.lines	
	move.l	a0,a3
	move.l	a1,a4
	move.l	a2,a5

	clr.l	d7
	move.w	#5-1,d7		;no. bitplanes
.bitplanes
	move.w	(a3),(a4)		;1 word
	move.w	2(a3),2(a4)		;2 word
	move.w	(a3),(a5)		;1 word
	move.w	2(a3),2(a5)		;2 word

	add.l	#scrwid,a4		;next bplane
	add.l	#scrwid,a5		;next bplane
	add.l	#104,a3		;next bplane
	dbra	d7,.bitplanes

	add.l	#104*5,a0
	add.l	#scrwid*5,a1
	add.l	#scrwid*5,a2

	dbra	d6,.lines
	
	rts
	
NewLevel
;	move.w	$dff006,d0
;	and.l	#$fff,d0
;	move.w	d0,$dff180
	
	add.b	#1,LevelNum
	cmp.b	#10,LevelNum
	beq	.fuck		;load new set
	bsr	init_bulls
	bsr	dolevnum
	lea	scratch,a2		;look for this level!
	bsr	FindLev
	bsr	SetupALL
	
.fuck
	rts
	
init_bulls
	;baddy bullets
	lea	bullet_list,a2
	move.l	#bullet_max-1,d7
	
.loop	move.b	#DEAD,bull_status(a2)
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop

	lea	gun_list,a2
	move.l	#gun_max-1,d7
.loop2
	move.b	#DEAD,bull_status(a2)
	add.l	#bullet_nd-bullet,a2	;next bullet
	dbra	d7,.loop2


	rts
	
dolevnum
	;copy level to scratch so we can add the number to it
	lea	lev1ascii,a0
	lea	scratch,a1
.copy	move.b	(a0)+,(a1)+
	bne	.copy

	;now go back a further 3 to get to the start of the no.
	;LEVEL 001
	;      ^
	sub.l	#4,a1
		
	clr.l	d0
	move.b	LevelNum,d0
	move.l	a1,a0
	bsr	numtoasc

	rts
	
go_flash
	cmp.w	#0,flash
	beq	.out
	sub.w	#$111,flash
	
.out	rts
	
	even
	cnop	0,4

new:
	dc.w	$009c,$8010
	dc.w	bpl1mod
modeven	dc.w	(scrwid*5)-40
	dc.w	bpl2mod
mododd	dc.w	(scrwid*5)-40
	dc.w	dmacon,$0020
scnposs	dc.w	diwstrt,$2c81
scnpose	dc.w	diwstop,$2cc1 
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0
bitplanes	dc.w	$5200
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
	dc.w	$0180
flash	dc.w	$0000

	dc.l	$8009fffe	
	dc.l	$ffdffffe
	dc.w	$2c09,$fffe,bplcon0,$0200
	
	dc.w	$ffff,$fffe		;end of coper list

	dc.l	0
new2:
	dc.w	$009c,$8010
	
;	dc.l	$2989fffe
;	dc.w	bplcon0,$0200	
;	dc.l	$2c09fffe
;	dc.w	bplcon0,$5200	

yobclist	dcb.b	yobtitnum*(4+4+(8*5)),0	;the big title in chunks of 4
yobclistnd
yobclr	dc.l	$9209fffe		;put a blank line after the bottom YOBtit line
	dc.w	bplcon0,$0200	
	
	dc.l	$9309fffe
	dc.l	$0180000f
	dc.l	$9409fffe
	dc.l	$01800000
	dc.w	bplcon0,$0200	
colour2	include	slyma/colclist

	dc.l	$fe09fffe
	dc.l	$0180000f
	dc.l	$ff09fffe
	dc.l	$01800400
	dc.w	bplcon0,$5200	
	dc.l	$ffdffffe
	;okay, we want 40 lines of 5bitplane data for the press fire to start
	
pfts	dcb.b	40*(4+(8*5)),0		;40 lines cline+(bpl1h,0,bpl1l,0)*5

	dc.w	bpl1mod
modeven2	dc.w	(scrwid*5)-40
	dc.w	bpl2mod
mododd2	dc.w	(scrwid*5)-40
	dc.w	dmacon,$0020
scnposs2	dc.w	diwstrt,$2c81
scnpose2	dc.w	diwstop,$2cc1 
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	bplcon0
bitplanes2	dc.w	$5200
	dc.w	bplcon1,$0
	dc.w	bplcon2,0
	dc.w	bplcon3,$0c00	;bplcon3

	dc.w	$ffff,$fffe		;end of coper list

	dc.l	0

old	dc.l	0

gfxname	dc.b	"graphics.library",0
dosname	dc.b	"dos.library",0
iffname	dc.b	"iff.library",0
intname	dc.b	"intuition.library",0
wbname          dc.b  "Workbench",0
	even
colours	dcb.w	32
coloursTIT	dcb.w	32
	even
_GfxBase	dc.l	0
_IFFBase	dc.l	0
_DOSBase	dc.l	0
_IntuitionBase	dc.l	0

wbview          dc.l  0
oldres          dc.l  0
wbscreen        dc.l  0

taglist         dc.l  VTAG_SPRITERESN_GET
resolution      dc.l  SPRITERESN_ECS
                dc.l  TAG_DONE,0



collbase	dc.l	0	;pointer to collision base!
scrbase	dc.l	0	;pointer to screen area!
scrbaseCOPY	dc.l	0	;pointer to screen area! copy
screen1	dc.l	0	;pointer to screen
screen2	dc.l	0	;pointer to screen
iffhandle	dc.l	0	;iff handle
bitmap
	dcb.b	40
	even
	cnop	0,4

;********  Memory Allocation Tables *********
CharBase	dc.l	0
CharSize	dc.l	0
MaskBase	dc.l	0
MaskSize	dc.l	0
CmapBase	dc.l	0
CmapSize	dc.l	0
LevBase	dc.l	0	;pointer to current level (in ldbase)
BadBase	dc.l	0	;pointer to 1st baddy data (in ldbase)
LDBase	dc.l	0	;block of 10 levels and baddy data
LDSize	dc.l	0
BackBase	dc.l	0
BackSize	dc.l	50*5*256	;(FAST)
BaddySize	dc.l	0	;Internal baddy size (for convert)
BaddyBase	dc.l	0	;Internal baddy base (for convert)
PlayerSize	dc.l	0	;Internal player size
PlayerBase	dc.l	0	;Internal player base
PlayerCOLLSize	dc.l	0	;Internal player size
PlayerCOLLBase	dc.l	0	;Internal player base
BulletSize	dc.l	0	;Internal bullet size
BulletBase	dc.l	0	;Internal bullet base
BulletCOLLSize	dc.l	0	;Internal bullet size
BulletCOLLBase	dc.l	0	;Internal bullet base
BaddyCOLLSize	dc.l	0	;Internal baddy COLL size (for convert)
BaddyCOLLBase	dc.l	0	;Internal baddy COLL base (for convert)
Baddy1Size	dc.l	82*5*(baddygfx*32)
Baddy1Base	dc.l	0
Baddy1COLLSize	dc.l	82*1*(baddygfx*16)
Baddy1COLLBase	dc.l	0
Player1Size	dc.l	42*5*96	;48+48 = 96 (player + mask)
Player1Base	dc.l	0
Player1COLLSize	dc.l	42*1*48
Player1COLLBase	dc.l	0
Bullet1Size	dc.l	42*5*32*bullgfxline	;16+16 = 32 (bullet + mask)
Bullet1Base	dc.l	0
Bullet1BaseCP	dc.l	0
Bullet1COLLSize	dc.l	42*1*32*bullgfxline
Bullet1COLLBase	dc.l	0
TitleSize	dc.l	40*5*110	;title screen (FAST)
TitleBase	dc.l	0
FontSize	dc.l	(832/8)*5*55	;title screen (FAST) (should be 48 but iff library fucked)
FontBase	dc.l	0
			;these are allocated in alloctemp
bad_temp1Base	dc.l	0
bad_temp2Base	dc.l	0
player_temp1Base	dc.l	0
player_temp2Base	dc.l	0
bullet_temp1Base	dc.l	0
bullet_temp2Base	dc.l	0
gun_temp1Base	dc.l	0
gun_temp2Base	dc.l	0
lazertempBase	dc.l	0

lazercollxy		dcb.l	bullet_max+1,0
		;this stores the lethal X,Y of the lazer beams.
		;anything in this area will be destoryed.
		;Word X Word Y
		;if X & Y = 0 then dead lazer!


RegSave		dc.l	0
oldpri		dc.l	0	


bad_no	dcb.l	bad_max+1,0
;* = fixed
bad_type1	;dumb l/r
	dc.l	"DUMB"	;dats my name! *
	dc.w	0	;xpos (pix) *
	dc.w	0	;ypos (pix) *
	dc.l	0	;actual pos *
	dc.w	0	;smooth scroll *
	dc.b	0	;anim char * (what pos in list)
	dc.b	0	;speed *
	dc.b	0	;i can go udlr *
	dc.b	0	;i am going r*
	dc.b	0	;what is my weapon *
	dc.b	0	;whats i hit for *
	dc.b	0	;whats my hp *
	dc.b	0
	dc.b	0
	dc.b	0	;map x *
	dc.b	0	;map y *
	dc.b	7,10,11,12,13,14,15,16,17	;anim right *
	dc.b	7,0,1,2,3,4,5,6,7	;anim left *
	dc.b	3,0,0,0,0,0,0,0,0	;anim right jump *
	dc.b	3,0,0,0,0,0,0,0,0	;anim left junp *
	dc.b	0		;anim offet
	dc.b	0		;mario pos
	dc.b	0
	dc.b	0		;doing
	dc.b	0		;falling pos
	dc.b	gravity
	dc.b	0
	dc.l	0		;actual old pos!
	dc.b	0		;jumping pos
	dc.b	0
	dc.b	0		;status!
	dc.b	1		;bad_gfxnum	(0-256)
	dc.w	24		;gun gfk
	dc.b	0		;rand2
	dc.b	0		;bad_LBnk	lazer restore bank 
	dc.b	0		;bad_dedcnt
	dc.b	0,0,0,0,0,0,0,0,0	;spacer
	cnop	0,4
	
bad_type1_nd	;if you add any more * bad structure

;bad_cango & go infos
;0000     can shoot UDLR
;    0000 can i move UDLR

;ability these are things he can do
;       0 fire (intelligent fire (when i can see summink)
;      0  jump
;     0   dieing
;    0    fall off platforms
;   0     fire at will (rnd) 
;  0      seek player (either is or isnt)
; 0       hide from player  (either is or isnt)
;0        platform dude (either is or isnt)
;look
;0000     look for player UDLR
;    0    use power ups
;     0   mario stylee walking

;doing these are things hes doing
;       0 firing (int)
;      0  jumping
;     0   dieing
;    0    falling
;   0     firing (rnd)
;  0      
; 0
;0

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
	
	BITDEF	BOB,GUN1,0	;intelligent fire
	BITDEF	BOB,JUMP,1
	BITDEF	BOB,DEAD,2
	BITDEF	BOB,FALL,3
	BITDEF	BOB,GUN2,4	;rand fire
	BITDEF	BOB,PLAT,7
	
	BITDEF	LOOK,MARIO,2
	
	BITDEF	ATTR,SEEKX,0	;seek in x
	BITDEF	ATTR,SEEKY,1	;seek in y
	BITDEF	ATTR,EDGE,2		;bounces on edge of scr
	BITDEF	ATTR,BFORM,3	;bounces off pform
	BITDEF	ATTR,HFORM,4	;hugs pform
	BITDEF	ATTR,AGRAV,5	;fall to gravity ALWAYS
	BITDEF	ATTR,GRAV,6		;fall to gravity when out of energy

	;kill bullet when	
	BITDEF	KBUL,BOTTOM,0	;bottom of screen
	BITDEF	KBUL,EDGE,1		;edges of screen
	BITDEF	KBUL,PFORM,2	;platform of screen
	
	
	

WeapSmart	equ	1	
WeapNorm	equ	2	;players
WeapLazer	equ	3
WeapBounce	equ	4	;players
	

;SPARE BITS in look & doing
 
;animation
;first byte is how many frames for direction
;then follows the frame no.s (upto 8 different frames)

bad_name	equ	0	;whats you name
bad_x	equ	4	;xpos
bad_y	equ	6	;ypos
bad_actual	equ	8	;coarse
bad_smooth	equ	12	;smooth
bad_anim	equ	14	;what char am I?
bad_speed	equ	15	;speed
bad_cango	equ	16	;what dirs am i alowed
bad_go	equ	17	;what dir(s) am i going
bad_gun	equ	18	;what is my weapon
bad_power	equ	19	;what I hit for
bad_hp	equ	20	;what my hit pts
bad_ability	equ	21	;what can i do
bad_look	equ	22	;what i see
bad_mapx	equ	23	;players mapx pos
bad_mapy	equ	24	;players mapy pos
bad_an_rcnt	equ	25	;how many frames for right
bad_an_rfrm	equ	26	;anim frames for right
bad_an_lcnt	equ	34	;how many frames for left
bad_an_lfrm	equ	35	;anim frames for left
bad_an_ucnt	equ	43	;how many frames for up
bad_an_ufrm	equ	44	;anim frames for up
bad_an_dcnt	equ	52	;how many frames for down
bad_an_dfrm	equ	53	;anim frames for down
bad_an_off	equ	61	;anim offset to suss dir anims
bad_mar	equ	62	;what pos in mario movement pos thing
bad_mar_max	equ	63	;what the max pos in mario movement
bad_doing	equ	64	;what am i doing
bad_fal	equ	65	;falling counter
bad_fal_max	equ	66	;falling maximum
bad_randg	equ	67	;do summink on this no. GUN
bad_act_was	equ	68	;bad actual pos
bad_jmp_pos	equ	72	;jumping pos
bad_platx	equ	73	;platform pos
bad_status	equ	74	;status: alive dead or what!
bad_gfxnum	equ	75	;what bank of gfx are we using (0-256)
bad_gungfk	equ	76	;baddy gun gfk (R) > < > <
bad_rand2	equ	77	;do summink on this no. OTHER
bad_LBnk	equ	78	;Lazer restore bank 
bad_dedcnt	equ	79	;counter for dead baddy!
;bad_an_off how to use it
;add the contents to bad_an_rcnt(a1) to get the bank of gfks to use
;i.e. bad_an_off = 0 then use right anim
;if   bad_an_off = 9 then use left anim
;
	cnop	0,4
bads_list
	dcb.b	bad_max*(bad_type1_nd-bad_type1),0

;for each new baddy you make, put his name and jmp into the bit below
bad_nums	dc.l	51,52,53,54,55,56,57,0		;what lev no. is bad
;     Move	Fire
;51 =   LR		;on Pform
;52 =  DLR 	UDLR 	;Fall off pform <SEEK bullet>
;53 = UD   	   R	;jumps up n down shoot right
;54 = UD	  L	;jumps up n down shoot left
;55 =      	   R	;Lazer Beam RIGHT
;56 =	  L	;Lazer Beam Left
;57 = UDLR	  LR	;Seeks Player

badcheck	dc.l	0	;check to see how many baddys alive
badcnt	dc.b	0	;check baddy alive counter!
badgone	dc.b	0	;results of bad counter

LevelNum	dc.b	0	;starting level
switch	dc.b	0	;which screen
random	dc.b	0	;random number thingy!
randplay	dc.b 	0	;random player to chase thingy! *NOT WRITTEN*
num_players	dc.b	0	;how many players
waitflag	dc.b	0	;has another direction added to wait
temp	dc.b	0	;tempory store for anything
TitleON	dc.b	0	;is the title screen on?
TitleONFT	dc.b	0	;is the title screen on for the first time?
	cnop	0,4

walk_thru
	dc.b	0	;what chars he cant walk l/r thru or jump u/d thru
	dc.b	0

walk_on	;be a good idea to make this a between 2-12 routine instead of 123456789101112
	dc.b	2,3,4,5,6,7,8,9,10,11,12,0	;what chars we can walk on	
;for baddies with mario style walking, this is the table
bad_jump	dc.b	0,0,0,0
bad_walk	
	dc.b	0,1,1,1,1,1,1,1
	dc.b	2,2,2,2,2,2,2,3
	dc.b	3,3,3,3,3,4,4,4
	dc.b	4,4,5,5,5,5,6,6
	dc.b	6,7,7,8,9,10,11,12
	dc.b	13,14,15,15,15,15,15,15

	dc.b	0,0,0,0,0,0,0,0
play_walk
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	3,3,3,3,3,3,3,3,3,3,3,3,3,3
	dc.b	4,4,4,4,4,4,4,4,4,4,4,4,4
	dc.b	5,5,5,5,5,5,5,5,5,5,5,5
	dc.b	6,6,6,6,6,6,6,6,6,6,6
	dc.b	7,7,7,7,7,7,7,7,7,7
	dc.b	8,8,8,8,8,8,8,8,8
	dc.b	9,9,9,9,9,9,9,9
	dc.b	10,10,10,10,10,10,10
	dc.b	11,11,11,11,11,11
	dc.b	12,12,12,12,12
	dc.b	13,13,13,13
	dc.b	14,14,14
	dc.b	15,15
	dc.b	16

bull_table
	dc.b	0
	dcb.b	1,-6
	dcb.b	1,-5
	dcb.b	1,-4
	dcb.b	1,-3
	dcb.b	1,-2
	dcb.b	1,-1
	dcb.b	16,1
	dcb.b	15,2
	dcb.b	14,3
	dcb.b	13,4
	dcb.b	12,5
	dcb.b	11,6
	dcb.b	10,7
	dcb.b	9,8
	dcb.b	8,9
	dcb.b	7,10
	dcb.b	6,11
	dcb.b	5,12
	dcb.b	4,13
	dcb.b	3,14
	dcb.b	2,15
	dcb.b	1,16


	;	00,01,02,03,04,05,06,07,08,09,10
gfktab	dc.l	00,00,00,00,00,00,00,00,00,00,00
liveplayers	dcb.b	players_max+1,0	;need extra one for ff termiated

	cnop	0,4	

player1	;please define in creatplayer (just defaults here)
	dc.w	100	;players x
	dc.w	100	;players y
	dc.l	0	;players actual (add scrbase for pos)
	dc.w	0	;players smooth (add 09f0 to it)
	dc.b	0	;input device (i.e. 0-joy0 1-joy1 etc)
	dc.b	0	;directions from joystick
	dc.l	0	;players old position
	dc.b	0	;mapx
	dc.b	0	;mapy
	dc.b	16	;platx
	dc.b	0	;speed
	dc.b	20	;speed max	
	dc.b	1	;step (step through speed data)
	dc.b	0	;going
	dc.b	8	;slippery (0 - ultra slippy)
	dc.b	0	;skill normal mode
	dc.b	0	;doing
	dc.b	0	;fall counter
	dc.b	0	;fall max
	dc.b	0	;status
	dc.b	0	;anim style
	dc.b	0	;anim frame
	dc.b	0	;anim count
	dc.b	0	;jump pos
	dc.b	0	;cresend of jump
	dc.b	0	;player hitpoints
	dc.b	0	;player hittime
	dc.b	0	;player dedcnt (see bullet) 0/1
	dc.b	0	;players gun
	dc.b	0	;ammo for gun
	dc.b	0	;reload max
	dc.b	0	;current reload counter!
	dc.b	0	;max no. bullets
	dc.b	0	;cuttent no. bullets
	dc.b	0	;current gun gfk!
	dc.b	0	;gun power
	cnop	0,4
	
player1_nd
players_list	;keep right under player1
	dcb.b	players_max*(player1_nd-player1),0

play_xpos	equ	0
play_ypos	equ	2
play_actual	equ	4
play_smooth	equ	8
play_port	equ	10	;what joy port do i read from ?
play_do	equ	11	;please go this way
play_was	equ	12	;players old pos.
play_mapx	equ	16	;map posx
play_mapy	equ	17	;map posy
play_platx	equ	18	;platform X
play_speed	equ	19	;what place in speed table
play_spdmax	equ	20	;max pos in speed table
play_step	equ	21	;how fast he goes through table (def 1)
play_going	equ	22	;what direction am i actually going
play_slip	equ	23	;how slippery is the surface player is on
play_skill	equ	24	;what mode am I
play_doing	equ	25	;same as baddy!
play_fal	equ	26	;falling counter
play_falmax	equ	27	;falling maximum
play_status	equ	28	;status: alive dead or what!
play_anim_style	equ	29	;animation style (see below)
play_anim_frame	equ	30	;animation frame
play_anim_count	equ	31	;animation counter
play_jmp_pos	equ	32	;jumping pos
play_cres		equ	33	;hey im in the cresent part of the jump
play_hp		equ	34
play_hptime		equ	35	;how long have i been hit for!
play_dedcnt		equ	36	;counter to remove from screen! (same as bullet)
play_gun		equ	37	;what gun have i got!
play_ammo		equ	38	;how much ammo!
play_reloadmax	equ	39	;how long between reloads!
play_reloadcnt	equ	40	;current time between reloads!
play_maxbulls	equ	41	;maximum no. bullets!
play_maxbullscnt	equ	42	;current no. bullets!
play_gungfk		equ	43	;player gun gfk
play_gunpower	equ	44	;players gun power
;play_skill
;what is the dude doing????
;0 = normal walk/jump/fall
;1 = jetpack
;2 = swim

;Ports (joystick ports etc)
JOYPORT1	equ	0	;port 1
JOYPORT2	equ	1	;port 2

;play_anim_style
;0 = walk left
;1 = walk right
;
Anim_RIGHT	equ	0
Anim_LEFT	equ	1

	cnop	0,4
	even
bullet
	dc.w	0	;x	
	dc.w	0	;y
	dc.l	0	;actual
	dc.l	0	;was
	dc.w	0	;smooth
	dc.b	0	;status
	dc.b	0	;gun
	dc.b	0	;speedx
	dc.b	0	;speedy
	dc.b	0	;speed maxx
	dc.b	0	;speed maxy
	dc.b	0	;step through table x
	dc.b	0	;step through table y
	dc.b	0	;wait before moving
	dc.b	0	;going at the mo
	dc.w	0	;how long the bullet lives
	dc.b	0	;can go if want to
	dc.b	0	;dead counter
	dc.w	0	;seekx
	dc.w	0	;seeky
	dc.b	0	;bullet wants to go
	dc.b	0	;wait before moving Y
	dc.b	0	;what player your after
	dc.b	0	;what attributes
	dc.b	0	;what kills bullet
	dc.b	1	;bullet power (how much i hit for)
	dc.w	24	;gfk start offset
	dc.w	0	;how long the bullet lives
	dc.b	0	;Lazer restore count
	dc.b	0	;spare
	dc.l	0	;Players address
	dc.w	0	;lazerx COLLISION
	dc.w	0	;lazerx2 COLLISION
	dc.w	0	;lazery COLLISION
	dc.w	0	;lazery2 COLLISION
		;this stores the lethal X,Y of the lazer beams.
		;anything in this area will be destoryed.
		;Word X Word Y
		;if X & Y = 0 then dead lazer!

	dc.l	0	;Lazer restore offset
	dc.b	0	;Lazer restore Bank
	dc.b	0	;position on mapx (most bullets DONT use it)
	dc.b	0	;position on mapy (most bullets DONT use it)
	
	cnop	0,4
bullet_nd

	
bull_xpos	equ	0
bull_ypos	equ	2
bull_actual	equ	4
bull_was	equ	8
bull_smooth	equ	12
bull_status	equ	14	;dead/dying/okay/new
bull_gun	equ	15
bull_speedx	equ	16
bull_speedy	equ	17
bull_maxx	equ	18
bull_maxy	equ	19
bull_stepx	equ	20
bull_stepy	equ	21
bull_waitx	equ	22	;waiting for conuter before moving
bull_go	equ	23	;where am i going
bull_life	equ	24	;how much life
bull_cango	equ	26	;can go if want to
bull_dedcnt	equ	27	;0/1 clear from both scr switches
bull_seekx	equ	28	;try to get here x
bull_seeky	equ	30	;try to get here y
bull_wantgo	equ	32	;where does he want to go
bull_waity	equ	33	;waiting counter for y
bull_player	equ	34	;what player are you after!
bull_attr	equ	35	;attributes
bull_death	equ	36	;what can kill the bullet (player/bullet/sides etc)
bull_power	equ	37	;what bullet hits for
bull_gfk	equ	38	;what gfk offset bullet is
bull_life2	equ	40	;how much life when seeking
bull_Lcnt	equ	42	;Lazer restore count
bull_spare	equ	43	;spare
bull_paddr	equ	44	;players structure address
bull_lazx	equ	48	;lazer lethal zonex start
bull_lazx2 	equ	50	;lazer lethal zonex end
bull_lazy	equ	52	;lazer lethal zoney start
bull_lazy2	equ	54	;lazer lethal zoney end
bull_Lrest	equ	56	;off set of screen for Lazer restore
bull_LBnk	equ	60	;what restore bank do i use!
bull_mapx	equ	61	;position on mapx *NOT USED* except for some... always setup for stability!
bull_mapy	equ	62	;position on mapy *NOT USED*

;bull_lazx
;this stores the lethal X,Y of the lazer beams.
;anything in this area will be destoryed.
;Word X Word Y
;if X & Y = 0 then dead lazer!

	even
	cnop	0,4
bull
bullet_list	dcb.b	bullet_max*(bullet_nd-bullet),0
FRED	dcb.b	100,$ff
gun_list	dcb.b	gun_max*(bullet_nd-bullet),0
HARRY	dcb.b	100,$ff

PlayerGun	dc.b	0	;set this flag when you do any player bullet rtns (i.e. grab/print/restore/move/collision etc)

DEAD	equ	0	;No Blitting
DYING	equ	1	;dying anim dont grab/blit just restore
OKAY	equ	2	;okay
NEW	equ	3	;New DONT Restore
HURT	equ	4	;player hit by summink (go white)

titletext
	dc.b	"press fire",$0a
	dc.b	"  to start",0
	
inbaset	dc.b	162		;start line of new cline TOp
inpost	dc.b	20		;where do you want it? (20=middle) TOP
inbaseb	dc.b	162+20		;start line of new cline BOT
inposb	dc.b	20		;where do you want it? (20=middle) BOT
pftswait	dc.b	0		;wait this long before restartin	

	even
	cnop	0,4
clinedummy	dc.l	0
scrline	dcb.b	yobtitnum,0
maxline	dcb.b	yobtitnum,0
sinepos	dcb.b	yobtitnum,0
gfkline	dcb.b	yobtitnum,0

OPTP1JOY	dc.b	JOYPORT1	;port 1 please 
OPTP2JOY	dc.b	JOYPORT1	;port 2 please ;changed to stop duff gfx
OPTP3JOY	dc.b	JOYPORT1	;port 1 please
OPTP4JOY	dc.b	JOYPORT2	;port 2 please
OPTP5JOY	dc.b	JOYPORT1	;port 1 please
OPTP6JOY	dc.b	JOYPORT2	;port 2 please

	even
john
	lea	bads_list,a0
	move.b	bad_mapx(a0),d0
	move.b	bad_mapy(a0),d1
	lea	player1,a0
	move.b	play_mapx(a0),d0
	move.b	play_mapy(a0),d1
	rts

	cnop	0,4
spare	dc.l	0,0,0,0

;	include	yoblev1.inc