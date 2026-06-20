    OPT C-,D+
******************************************************************************
* WOKING TITLE: TANKS
*       AUTHOR: PAUL KENT
*     COMPILER: DEVPAC3
*       MEMORY: 300K Odd!
*  DIARY/NOTES:
*1.4.92: Initialisation shell code for players (UNTESTED)
*        Lots needs defining!
*6.4.92: Can drive around+pixel accurate scenery collisions+box player collns.
*        Needs pixel accurate  player hits / no bullet or damage code etc.
*9.4.92: ELECTION :-()    <<<confused smiley!!!!
*		 Accurate player vs player hits (PAPMAPs)
*        Damage in explosions- ENERGY/POWER line etc
*        Print/Delete bullet code.
*11.4.92 Bullet run shell code + few "death situation" bugs NUKED!
*16.4.92 Bug in bullet run code - bullets on terming SOMETIMES leave a
*        graphical 'smudge'. Set Bullmax to 1 temporarily...
*20.4.92 Bullets move(no reflections!) Smudging bug removed (bullets DEL in
*        wrong order. More generic surrounding collision code.
*        Command line (genam3) options. BULLSPEED*bl_dx/dy for total delta
*24.4.92 Bullet deflections fully operational!!! No bugs left! (HOPE!)
*26.4.92 Using box collisions for bullet<>player hits !only!. Looks ok.
*        Papmaps built by 68000. Maybe use blitter interrupt for clearing?
*28.4.92 4 players (shell only!). Keyboard reader re-done!
*01.5.92 4 players 100%. Waiting for GFX files + playtest comments!
*        TO DO ?: LOADER/OPTIONS SCREENS
*                 SOUND EFFECTS
*                 START/END GAME FX
*                 BONUSES: (ALL FROM SPINNING `?` ICON)
*                          TEMPORARY SHIELD
*                          MORE ENERGY
*                          HIGHER BULLET POWER
*                          LONG DISTANCE BULLETS
*                          NON-REFLECTIVE BULLETS(PENALTY)
*                          BULLETS HIT SELF(PENALTY)
*                          MOVE FASTER
*03.5.92 Menu system(simple!). Bug in 'swapcop' removed: move.w instead of .l 
*04.5.92 Hitmaps ptr in bob struct, ptr used in collision codes
*07.5.92 Stuarts map gfx, map editor!
*08.5.92 Bonus: Appears after 5 s of no damage: 4 possible locns per level
*        stored in lp.maplist.Counter >255 then bonus.
*        Zero counter every hit/damage.
*        Do Jsr PrintRunBonus+ Jsr DelBOnus always
*		 Extended player structure : P_BonusSig.w & P_BonusTime.w
*        Constants defined for P_Bonussig.w
*18.5.92 SOUND FX + BONUS' + KEYCODE 100% Yo! Updated Mapgfx....
*22.5.92 Splitter bullets
*28.5.92 Various improvements: new font, tried tiled effect behind  menu..
*10.6.92 Lots of tidying. Logo on all info screens. Bullet hit code bug
*        fixed - was 1 pixel out! Levels tidied.
*        ...one step closer...
*
* SPECIFY ON COMMAND LINE:
* RAMDRIVE FOR RRD: RESIDENT BINARIES
* RUNTIME FOR FULL INTERRUPT DRIVERS ETC
* SMPI FOR SMPI CODE
* EDITOR FOR EDITOR CODE!
* GENLOCK FOR ERSY!
******************************************************************************

    SECTION TANXS,CODE
	OUTPUT	TANKS:MAIN

RUNTIME	set 1			;Added these to make life easier :-) MM
SMPI	set 1
EDITOR	set 1

	IFND	RAMDRIVE
	INCDIR	Source:P.Kent/
	ENDC
	IFD	RAMDRIVE
	INCDIR	RRD:
	LIST
* USING RRD: RESIDENT FILES *
	NOLIST
	ENDC

	INCLUDE	INCLUDES/HARDWARE.I
	INCLUDE	INCLUDES/MYMACROS.I
	INCLUDE INCLUDES/COMBISTART.S
	INCLUDE	INCLUDES/HWSTART.S

	INCLUDE	SOURCE/MENU.S
;	INCLUDE	SOURCE/DISPFX.S

	IFD	SMPI
	INCLUDE	INCLUDES/SMPI.S
	ENDC

	opt	o-

NBLITWAIT	MACRO
	BLITWAIT	\1
	ENDM

SBLITWAIT	MACRO
	TST.W	DMACONR(\1)				; Clear pipline reg
	MOVEQ	#1,\2
.wait\@
	DIVU	\2,\2
	BTST	#6,DMACONR(\1)			; Busy
	BNE.S	.wait\@
	ENDM
****************************
*     SCREEN SIZES         *
****************************
;SCREEN IS 320+16 ($28+2 WIDB), 256 HGT
NPL = 5
PLWIDW = 21
PLWIDB = PLWIDW*2
PLHGT  = 256
PLLEN = PLWIDB*PLHGT
NUMCOLS	= 32
****************************
NUMVBLOCKS	=	16
NUMHBLOCKS	=	20
NUMBLOCKS	=	NUMHBLOCKS*NUMVBLOCKS
BLOCKWWID	=	1
BLOCKPHGT	=	16
BLOCKBSIZE	=	BLOCKPHGT*64*NPL+BLOCKWWID
HITBLOCKBSIZE	=	BLOCKPHGT*64+BLOCKWWID

BULLETSCORE = 10
KILLEDSCORE = 100
LEVELSCORE  = 125
;NB PENALTY!!
CRASHSCORE  = 2					; Hahahaha -2*50=-100 per sec approx.

MAXENERGY	=	99*8				; Max player energy
MAXPOWER	=	99*8				; Max player bullet power
POWERGROW	=	1					; Grow per frame
CRASHDAMAGE	=	2*2					; Damage due to collisions between players
EXPLODAMAGE	=	4*2					; If at centre of explosion: take wodges
									; of damage!

MAXSPEED	=	1					; Max player speed

;NB HARD CODED IN BULLET CODE!!
BULLSPEED	=	4
;

BULLETDELAY		=	10				; .2 secs between bullets
BULLETDAMAGE	=	4*8*2			;
BULLETCOST	=	2*5*8				; 10% per bullet
BULLETDIST	=	70					; No of frames bullet can run for

ALIVE	=	0
DYING	=	1
DEAD	=	2

MaxPBulletTotal	=	8				; 8 in air at once
Explospeed	=		3				; Change explo every 3 frames

;WARNING!!! HARD CODED IN SOMEPLACES!!!
BExplospeed	=		2				; every 2 frames

BullExploframes	=	6
TankExploframes	=	9				; No anims in tank explosion
Deathmax	=		TankExploFrames*ExploSpeed
Bullmax		=		BullExploFrames*Bexplospeed

BONUSDURATION	=	400				; 8 secs duration of bonus on player!
BONUSSHIELDDURATION	=	200			; 4 secs duration
BONUSBSPLITDURATION =	600
BONUSENERGY		=	30*8			; 30% bonus
BONUSSPEED		=	2
BONUSBDIST		=	BULLETDIST*3	; Dist bullets go w. bonus
;Codes for player bonus sigs...
;also +energy (instant)
			rsreset
PB_NONE		rs.b	1				; Nothing active  			IMP
PB_ENERGY	rs.b	1				; Additional energy			IMP
PB_BPOWER	rs.b	1				; 2*Bullet power (*2 damage)IMP
PB_BDIST	rs.b	1				; Bullets travel further..  IMP
PB_FAST		rs.b	1				; Player moves faster...	IMP
PB_SHIELD	rs.b	1
PB_NRBULLET rs.b	1
PB_INVIS	rs.b	1				; Invisible...
PB_BSPLIT	rs.b	1				; Bullets split on term > 4 others!
			rsreset
BLT_NORM	rs.b	1
BLT_LONG	rs.b	1
BLT_DAMAGE	rs.b	1
BLT_NRBULLET	rs.b	1
BLT_BSPLIT	rs.b	1
;BULLET STRUCTURE
			rsreset
bl_sig		rs.b	1				; Flying,Burning,dead
bl_explo	rs.b	1				; count for explosion/bullet
bl_type		rs.b	1				; bullet type: NORM/LONG/DAMAGE etc
			rs.b	1
bl_timer	rs.w	1				; Path length left
bl_xpos		rs.w	1				; x,y position
bl_ypos		rs.w	1

bl_dx		rs.w	1				;+/- 1 FOR BULLETS (*BULLSPEED FOR DELTA)
bl_dy		rs.w	1

bl_sprptr	rs.l	1				; Ptr to sprite array
bl_save1	rs.l	1				; Bullet save addrs
bl_save2	rs.l	1
Bullet_len	rs.w	1				; Num words/bullet
		


;PLAYER STRUCTURE
			rsreset
p_state		rs.b	1				; Alive,dying,dead
p_diecnt	rs.b	1				; Death position counter!
p_joyptr	rs.l	1				; Ptr to scan control subroutine
p_joyval	rs.b	1				; Current control value
p_maxspeed	rs.b	1				; Players max speed
p_energy	rs.w	1				; Players current energy
p_score		rs.l	1				; Score...
p_bulletpow	rs.w	1				; Players gun power
p_hitptr	rs.l	1				; Ptr to scenery/player hit subr.
p_sprptr	rs.l	1				; Ptr to players sprite list
p_save1		rs.l	1				; Save posns
p_save2		rs.l	1				; -/-
p_bulletptr	rs.l	1				; Ptr to bullet run code
p_bulletcnt	rs.b	1				; No. active bullets
p_Bullettim	rs.b	1				; Timer between shots
p_facedir	rs.w	1				; Direction player is facing
									; 12:00 clockwisw, multiples of 2
                                    ; 0 up,4 right,8 down,12 left..
p_xpos		rs.w	1				; X,y positions
p_ypos		rs.w	1
p_dx		rs.w	1				; Deltas +/- maxspeed (1 typ)
p_dy		rs.w	1
P_BonusSig	rs.w	1				; Current bonus code!
P_BonusTime rs.w	1				; Time left with current bonus!
p_Bullets	rs.b	MaxPBulletTotal*Bullet_len	; Bullet tracking data
p_len		rs.w	1


;BOB structure
			rsreset
B_InitSig	rs.b	1				; NZERO after init
B_Options	rs.b	1				; 0 - use mask as present
									; 1 - calculate & use mask at ptr
									; 2 - no mask - direct copy
B_WWid		rs.w	1				; Width in words+1
B_Hgt		rs.w	1				; Height pixels
B_SMod		rs.w	1				; Source + modulo if any

B_BMap		rs.l	1				; Interleaved bitmap ptr
B_Mask		rs.l	1				; Interleaved mask ptr

B_CBSize	rs.w	1				; BlitSize
B_CMod		rs.w	1				; Generic modulo
B_CRMod		rs.w	1				; Reset modulo CMod-2
;!!! Hit code specific!
B_CSHBSize	rs.w	1				; Blitsize for surrounding hit code
B_CSHMod	rs.w	1				; Source modulo for s. hit code
B_HitMap	rs.l	1				; Ptr to hitmap, same format as il.mask
B_len		rs.w	1

_BOOT
	LEA	CUSTOM,A6
	LEA	MYVARS,A5
	BSR	InitStartUp

Menulp
	JSR	Menu
	TST.L	D0
	Bne.s	Launch
	IFD	EDITOR
	JSR	DeInitlevels
	ENDC

	MOVE.B	#%10011011,CIAAICR		; Keyb etc. back on

	RTS								; Back to DOS!

Launch
	IFD EDITOR
	CMP.L #"EDIT",D0
	BNE.S	LNedit
	PEA	Menulp(PC)
	JMP	Edit
LNedit
	ENDC

	BSR.S StartGame
	BRA.S Menulp

StartGame
	Bsr	InitGame					; Sets start level etc.
NextLevel
	Bsr	StartLevel					; Fades in level + prints players
									; Resets energies + w.deathwatch
mainlp
	bsr	printrunbonus				; Handle bonus
	bsr	printplayers				; Print all players on background screen
	bsr	printbullets				; Print bullets/explosions
	bsr	printstats

	IFND	RUNTIME
	bsr	waitvbl
	bsr	swapcop
	ENDC

	IFD	RUNTIME
vblp1	tst.b	b.vbsig(a5)
	bne.s	vblp1
	st	b.vbsig(a5)
	ENDC

;Read 4 player adaptor if 3 or 4 players, & 1+ on stick
	cmp.w	#1,w.Numplayers(a5)		; If 3 or 4 players
	bls.s NRP_main
	bsr	ReadPort
NRP_main

	MOVE.W	w.NumPlayers(a5),d0
	lea	player0(a5),a4				; Process player actions:						
doplayerolp	bsr	Doplayer			; Movement/bullets/exploding etc.
	lea	p_len(a4),a4
	dbra	d0,doplayerolp

	tst.b	keymap
	beq.s	NKALL
	tst.b	keymap+$5d
	beq.s	NKALL
	lea	player0(a5),a4
	move.w	#-1,p_energy(a4)
	lea	player1(a5),a4
	move.w	#-1,p_energy(a4)
	lea	player2(a5),a4
	move.w	#-1,p_energy(a4)
	lea	player3(a5),a4
	move.w	#-1,p_energy(a4)

NKALL

	IFD	RUNTIME
vblp2	tst.b	b.vbsig(a5)
	bne.s	vblp2
	ENDC

	bsr	deletebullets				; Tidy old foreground screen...
	bsr	deleteplayers	
	bsr	deletebonus					; Zap bonus


	tst.w	w.Deathwatch(a5)		; Check if running
	bmi.s	P_DRunning				; -ve: RUNNING
	subq.w	#1,w.Deathwatch(a5)		; Sub watch
	beq.s	mainlp_fin2				; Die!
	bra.s	P_SkipD					; DEATHWATCH => no need to check

P_DRunning							; Scan whos alive...
	moveq	#0,d0					; No. dead
	move.w	w.NumPlayers(a5),d1		; For every dead active player, count.
	lea	player0(a5),a4
P_Dlp	cmp.b	#DEAD,p_state(a4)
	bne.s	P_ND
	addq.w	#1,d0
P_ND	lea	p_len(a4),a4
	dbra	d1,p_dlp

	cmp.w	w.NumPlayers(a5),d0		; All dead or all -1 ?
	bmi.s	P_SkipD					; Dont die?
	move.w	#50,w.Deathwatch(a5)	; Set 1s till death
P_SkipD
	tst.b	$45+keymap				; Escape aborts
	beq	mainlp
;QUIT: HAVE ABORTED!
mainlp_fin	BSR	CloseDown
mainlp_fin3
	BSR	Doresults
	BSR	AllOff
	RTS	

;QUIT: NEXT LEVEL ETC
mainlp_fin2
	BSR	CloseDown					; fade out!
;Add to scores...

	lea	player0(a5),a4
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P0_nA
	add.l	#LEVELSCORE,p_score(A4)
P0_nA
	lea	player1(a5),a4
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P1_nA
	add.l	#LEVELSCORE,p_score(A4)
P1_nA
	cmp.w	#1,w.numplayers(a5)
	beq.s	p3_na
	lea	player2(a5),a4
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P2_nA
	add.l	#LEVELSCORE,p_score(A4)
P2_nA
	cmp.w	#2,w.numplayers(a5)
	beq.s	p3_na
	lea	player3(a5),a4
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P3_nA
	add.l	#LEVELSCORE,p_score(A4)
P3_nA

	MOVE.W	w.CurLevel(a5),D0		; Quit if all levels done
	CMP.W	w.NumLevels(a5),d0
	BEQ.S mainlp_fin3
	ADDQ.W	#1,w.Curlevel(a5)		; next level...
	BRA NextLevel

*****
*Initialisation routine for startup only
*****
InitStartUp
	IFD	RUNTIME
	lea	Int3_Handler(pc),a0				; Set up interrupt handlers
	move.l	a0,$6C.W
	lea	Trace_Handler(pc),a0			; >>MY<< debug code..
	move.l	a0,$24.W
	ENDC

	MOVE.L	#SCREEN1,p.DrawPl(A5)		; initial screen ptr
	MOVE.L	#SCREEN2,p.ShowPL(a5)
	BSR	SwapCop

	IFD	SMPI
	BSR	InitSmpi
	ENDC
	IFD	RUNTIME
	CATCHVB	A6	        				; Wait for VBL
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN,dmacon(A6)
	MOVE.L	#MY_Copper,cop1lch(A6)		; Just set dma/ints and wait!
	MOVE.W	D0,COPJMP1(A6)
	MOVE.L	#(SETIT!INTEN!BLIT!VERTB!COPER)*65536+$7FFF,intena(A6)
										; My ints + zap intreq!
	BSR	InitKeys						; Init keyb handler, $68.w
	ENDC
	BSR	InitMulTab
	MOVE.L	#lw.BlackCols,plw.Cols(A5)	; Put in initial colours...
	BSR	InitLevels						; Initialise level offsets
	BSR	InitSprites
	BSR	InitPlayers						; Put in ptrs in player structs
	BSR	InitBonus
	RTS

*****
*Termination code
*****
;End of game/level
CloseDown
	MOVE.L	#lw.BlackCols,plw.COls(A5)	; Always fade to black!
	MOVEQ	#3,D0						; Slow fade out!
	BRA	FadeCols
;Quit game
AllOff
	IFD	SMPI
	BSR	KillSmpi
	ENDC
	RTS	


DoResults							; Print results!
	BSR	CLS
	Lea player0(a5),a4
	MOVE.l	p_score(A4),D0
	Lea	Res.p0.txt,a0
	BSR	GetDecimal

	Lea player1(a5),a4
	MOVE.l	p_score(A4),D0
	Lea	Res.p1.txt,a0
	BSR	GetDecimal

	Lea player2(a5),a4
	MOVE.l	p_score(A4),D0
	Lea	Res.p2.txt,a0
	BSR	GetDecimal

	Lea player3(a5),a4
	MOVE.l	p_score(A4),D0
	Lea	Res.p3.txt,a0
	BSR	GetDecimal

	LEA	Result.txt,a0
	move.l	p.drawpl(a5),a2
;	lea	plwidb*(npl-1)(a2),a2

	BSR	DoTxtStruct
	BSR GimmeLogoDraw
	BSR	WAITVBL
	BSR	SwapCop
	MOVE.L	#lw.LogoCols,plw.COls(A5)	; Always fade menu in!!!
	MOVEQ	#2,D0						; Fastish fade in
	BSR	FadeCols
	move.w	#400,d7					; Wait 8 secs max
	clr.b	b.ordkey
Reslp
	bsr	waitvbl
	tst.b	b.ordkey
	bne.s	resFin
	dbra	d7,Reslp
ResFin
	BSR	CloseDown
	rts

Result.txt
	_TEXT	rt2,0,110+39,'C',systemfont,<'LATEST SCORES'>
rt2	dc.l	rt3
	dc.w	0,126+39,'C'
	dc.l	systemfont
	dc.l	rt2.txt
rt2.txt
	dc.b	'PLAYER 1 : '
res.p0.txt	dc.b	'0000000000',0
	even

rt3	dc.l	rt4
	dc.w	0,142+39,'C'
	dc.l	systemfont
	dc.l	rt3.txt
rt3.txt
	dc.b	'PLAYER 2 : '
res.p1.txt	dc.b	'0000000000',0
	even

rt4	dc.l	rt5
	dc.w	0,158+39,'C'
	dc.l	systemfont
	dc.l	rt4.txt
rt4.txt
	dc.b	'PLAYER 3 : '
res.p2.txt	dc.b	'0000000000',0
	even

rt5	dc.l	rt6
	dc.w	0,174+39,'C'
	dc.l	systemfont
	dc.l	rt5.txt
rt5.txt
	dc.b	'PLAYER 4 : '
res.p3.txt	dc.b	'0000000000',0
	even
rt6	_TEXT	0,0,190+39,'C',systemfont,<'ANY KEY TO CONTINUE'>

***
* Trace_Handler()
* Handle a trace exception
***
Trace_Handler
	movem.l	d0-d7/a0-a7,ll.TraceRegs
	move.w	SR,w.TraceStat
	Lea	MYVARS,A5
	move.w	#$2700,SR			; prevent ints

	move.l	2(sp),l.TracePC

	bsr.s	ShowRegs

Trace_W1
	btst	#6,CIAAPRA	; wait for mouse press
	bne.s Trace_W1
Trace_W2
	btst	#6,CIAAPRA
	beq.s Trace_W1

	tst.w w.Tron(a5)			; continuing trace?
	bne.s Trace_B1 				; yes

	move.w	(sp),d0				; get actual SR saved
	bclr	#15,d0				; clr trace bit
	move.w	d0,(sp)				; save back

Trace_B1
 	movem.l	ll.TraceRegs,d0-d7/a0-a7
	rte

*****
* ShowRegs()
* d0-d2/a6 corrupt
*****
ShowRegs
 	lea	ll.TraceRegs,a6			; where saved regs are

	moveq #8,d7 				; show 1st 8 (d0-d7)
	moveq #2,d1
	move.w	#170,d2

Trace_L1
 	move.l	(a6)+,d0 		; get reg
	bsr	showd0					; display it
	add.w #10,d2				; next display pos
	subq.w	#1,d7
	bne.s Trace_L1

	moveq #12,d1
	move.w	#170,d2
	moveq #8,d7 				; show 2nd 8 (a0-a7)

Trace_L2
 	move.l	(a6)+,d0 		; get reg
	bsr	showd0					; show it
	add.w #10,d2				; next display pos
	subq.w	#1,d7
	bne.s Trace_L2

	move.l	l.TracePC,d0 		; get PC
	moveq #22,d1
	move.w	#170,d2
	bsr	showd0					; show it
	add.w #10,d2				; next display pos

	moveq	#0,d0
	move.w	w.TraceStat,d0 		; get SR
	add.w #10,d2
	bsr	showd0					; display it

		rts

*****
*SetTrace()
*****
SetTrace
 	move.w	#-1,w.Tron(a5)
	or.w	#$8000,SR
	rts

*****
*ClearTrace()
*****
ClearTrace
	clr.w w.Tron(a5)
	rts

*****
* InitKeys
* Initialise keyboard routine!
*****
InitKeys
	MOVE.W	#PORTS,CUSTOM+intena
	MOVE.L	#KeybInterrupt,$68.W
	MOVE.B	#$77,CIAAICR
	MOVE.B	#$88,CIAAICR
;	MOVE.B	#$7F,CIABICR
	TST.B	CIAAICR
;	TST.B	CIABICR
	MOVE.W	#PORTS,CUSTOM+intreq
	MOVE.W	#SETIT!PORTS,CUSTOM+intena
	RTS	

KeybInterrupt
	MOVEM.L	D0/A0,-(SP)
	MOVE.B	CIAAICR,D0
	BTST	#3,D0
	BEQ.S	Keyb_rt
	MOVE.B	CIAASP,D0
	BSET	#6,CIAACRA
	MOVE.B	#$FF,CIAASP

	MOVE.B	#8,CIAACRA
	MOVE.B	#$19,CIAATALO
	MOVE.B	#2,CIAATAHI

	MOVE.B	#$81,CIAAICR
	MOVE.B	#8,CIAAICR

	NOT.B	D0
	LEA	KeyMap(PC),A0
	LSR.B	#1,D0
	BCS.S	ReleaseKey
	AND.W	#$7F,D0
	MOVE.B	#-1,(A0,D0.W)
	MOVE.B	D0,b.ordkey

KeyDone	TST.B	CIAAICR
	MOVE.W	#PORTS,CUSTOM+intreq
	MOVEM.L	(SP)+,D0/A0
	RTE	
 
ReleaseKey	AND.W	#$7F,D0
	CLR.B	(A0,D0.W)
	BRA.S	KeyDone

Keyb_rt	BTST	#0,D0
	BEQ.S	Keyb_rtdone
	BCLR	#6,CIAACRA				; Complete handshake...
	MOVE.B	#1,CIAAICR
	MOVE.B	#$88,CIAAICR
	TST.B	CIAAICR
Keyb_rtdone	MOVE.W	#PORTS,CUSTOM+intreq
	MOVEM.L	(SP)+,D0/A0
	RTE	
KeyMap	ds.b	$7f				; Offset as keycode = -1 when pressed
b.ordkey	ds.b	1

*****
* Int3_Handler()
* Handle Level 3 Interrupt
*****
Int3_Handler
	movem.l	d0-d7/a0-a6,-(sp) 		;save these
;	move.w	#$2300,SR				; prevent interrupt nesting
	lea	custom,a6
	lea	myvars,a5
	move.w	INTREQR(a6),d0 			; check which int occurred

	moveq	#0,d7					; return code

;	move.w	d0,INTREQ(a6)			; and tell 4703 about it

	btst	#6,d0 					; Blitter?
	beq.s Int3_1					; no
	addq.l	#1,l.BlitCounter(a5)	; add to blitter counter
	or.w	#BLIT,D7
Int3_1
	btst	#5,d0 					; VBL?
	beq.s Int3_2					; no
	addq.l	#1,l.VBLCounter(a5)		; add to VBL counter
	or.w	#VERTB,d7
Int3_2
	btst	#4,d0 					; Copper?
	beq.s Int3_3					; no
	addq.l	#1,l.CopCounter(a5)		; add to Copper counter
	IFD	RUNTIME
	tst.b	b.vbsig(a5)
	beq.s	novb
	bsr	swapcop
	clr.b	b.vbsig(a5)
novb
	ENDC

	IFD	SMPI
	BSR	SMPIVBI
	ENDC
	or.w	#COPER,d7
Int3_3
	move.w	d7,INTREQ(A6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte

*****
* InitGame()
* Zeros score, sets 0th level etc.
* TEMP: GET num players
*****
InitGame
	move.w	#0,w.curlevel(a5)		; Hmm...
	move.w	w.NumPlayers(a5),d0

	move.w	#8-1,w.MaxBullets(a5)	; Set for 2 players
	cmp.w	#1,d0
	beq.s	IF_MBFin
	move.w	#5-1,w.MaxBullets(a5)	; Set for 3 players
	cmp.w	#2,d0
	beq.s	IF_MBFin
	move.w	#4-1,w.maxbullets(a5)	; Set for 4 players
IF_MBFin

	clr.L	p_score+player0(a5)
	clr.L	p_score+player1(a5)
	clr.L	p_score+player2(a5)
	clr.L	p_score+player3(a5)

	rts

*****
*DoPlayer(play struct) (a4)
*Process player stuff : move/bullets/collisions etc.
*****
DoPlayer
	PUSH	D0-D7/A0-A3
;IF NOT ACTIVE QUIT
	cmp.b	#DEAD,p_state(a4)
	beq	DOP_Dead
;IF DYING >EXLOSION
	cmp.b	#DYING,p_state(a4)
	beq		DOP_Dying
;CHECK ENERGY: IF <0 SET DYING,LOCK CONTROLS >EXPLOSION CODE
	tst.w	P_energy(a4)
	bpl.s	DOP_HaveEnergy
	move.b	#DYING,p_state(a4)		; No escape!
	move.b	#0,p_diecnt(a4)			; Set anim counter to zero
	IFD	SMPI
	lea	SMPI_BOOM1,A0
	BSR	playsmpi
	ENDC

	bra	DOP_Dying
DOP_HaveEnergy
;Process bonus code!
	bsr	ProcPBonus
	cmp.w	#MAXENERGY,p_energy(a4)
	bmi.s	DOP_ENMAX
	move.w	#MAXENERGY,p_energy(a4)
DOP_ENMAX

;ADD TO BULLET POWER! (<MAXIMUM!)
	cmp.w	#MAXPOWER,p_bulletpow(a4)
	beq.s	DOP_BullPMax
	addq.w	#POWERGROW,p_Bulletpow(a4)

	cmp.w	#MAXPOWER,p_bulletpow(a4)	; Check maximum
	bmi.s	DOP_BullPMax
	move.w	#MAXPOWER,p_bulletpow(a4)
DOP_BullpMax

	tst.w	p_bulletpow(a4)			; Check minimum
	bpl.s	DOP_BullpMin
	move.w	#0,p_bulletpow(a4)
DOP_BullpMin

;SUB BULLET FIRE TIMER
	cmp.b	#0,p_bullettim(a4)
	beq.s	DOP_BulletTimeok
	subq.b	#1,p_bullettim(a4)
DOP_Bullettimeok

;SCAN CONTROLS
	move.l	p_joyptr(a4),a0
	jsr	(a0)
	move.b	d0,p_joyval(a4)

;DO DELTA POSN
	btst	#right,d0
	beq.s	DOP_NotRight
	move.w	#1,p_dx(a4)
	bra.s	DOP_DoneLR
DOP_NotRight
	btst	#left,d0
	beq.s	DOP_NotLR
	move.w	#-1,p_dx(a4)
	bra.s	DOP_DoneLR
DOP_NotLR	move.w	#0,p_dx(a4)
DOP_DoneLR

	btst	#down,d0
	beq.s	DOP_NotDown
	move.w	#1,p_dy(a4)
	bra.s	DOP_DoneUD
DOP_NotDown
	btst	#up,d0
	beq.s	DOP_NotUD
	move.w	#-1,p_dy(a4)
	bra.s	DOP_DoneUD
DOP_NotUD	move.w	#0,p_dy(a4)
DOP_DoneUD

;NOW SET FACING DIRN,IF NO JOY DIR, LEAVE CONST
	and.w	#%1111,d0				; Mask off fire
	beq.s	DOP_facedirCONST
;	lea	lw.facelist,a0
	add.w	d0,d0
	move.w	lw.facelist(pc,d0),p_facedir(a4)
DOP_facedirCONST

;CHECK AGAINST SCENERY + PLAYERS (as p_hitptr)
	move.l	p_hitptr(a4),a0			; Check deltas against scenery
	jsr	(a0)
;UPDATE POSN+CLIP INTO SCREEN

DOP_Bullc

;RUN BULLETS(as ptr) - collisions (SELF+SCENERY BOUNCING)
	move.l	p_bulletptr(a4),a0
	jsr	(a0)
	POP	D0-D7/A0-A3
	rts

DOP_Dying							; Player is exploding!
	addq.b	#1,p_diecnt(a4)			; Add to death count
	cmp.b	#DEATHMAX,p_diecnt(a4)
	bne.s	DOP_Dead
	move.b	#DEAD,p_state(a4)
DOP_Dead	move.w	#0,p_energy(a4)
	bra.s	DOP_Bullc

lw.facelist
	dc.w	0	;0
	dc.w	4	;1right
	dc.w	12	;2left
	dc.w	0	;3
	dc.w	8	;4down
	dc.w	6	;5down+right
	dc.w	10	;6down+left
	dc.w	0	;7
	dc.w	0	;8up
	dc.w	2	;9up+right
	dc.w	14	;10up+left
	dc.w	0	;11
	dc.w	0	;12
	dc.w	0	;13
	dc.w	0	;14
	dc.w	0	;15


*****
*Hitcode (a4) subr for players:
*Check for hits with scenery+other players given delta position
*Change delta posns until OK!
*****
Player0_HitCode
	move.b	p_maxspeed(a4),d7
P0_Hclp
	bsr	CheckHitScene
	lea	player1(a5),a3
	bsr	CheckHitPlayer
	cmp.w	#1,w.NumPlayers(a5)	; Done all players ?
	beq.s	P0_HCQ
	lea	player2(a5),a3
	bsr	CheckHitPlayer
	cmp.w	#2,w.NumPlayers(a5)
	beq.s	P0_HCQ
	lea	player3(a5),a3
	bsr	CheckHitPlayer
P0_HCQ
	bsr	PlayerCoords
	subq.b	#1,d7
	bne.s	P0_Hclp
	rts

Player1_HitCode
	move.b	p_maxspeed(a4),d7
P1_Hclp
	bsr	CheckHitScene
	lea	player0(a5),a3
	bsr	CheckHitPlayer
	cmp.w	#1,w.NumPlayers(a5)	; Done all players ?
	beq.s	P1_HCQ
	lea	player2(a5),a3
	bsr	CheckHitPlayer
	cmp.w	#2,w.NumPlayers(a5)	; Done all players ?
	beq.s	P1_HCQ
	lea	player3(a5),a3
	bsr	CheckHitPlayer
P1_HCQ	bsr	PlayerCoords
	subq.b	#1,d7
	bne.s	P1_Hclp
	rts

Player2_HitCode
	move.b	p_maxspeed(a4),d7
P2_Hclp

	bsr.s	CheckHitScene
	lea	player0(a5),a3
	bsr	CheckHitPlayer
	lea	player1(a5),a3
	bsr	CheckHitPlayer
	cmp.w	#2,w.NumPlayers(a5)	; Done all players ?
	beq.s	P2_HCQ
	lea	player3(a5),a3
	bsr	CheckHitPlayer
P2_HCQ	bsr	PlayerCoords
	subq.b	#1,d7
	bne.s	P2_Hclp
	rts

Player3_HitCode					; All other players must be active
	move.b	p_maxspeed(a4),d7
P3_Hclp
	bsr.s	CheckHitScene
	lea	player0(a5),a3
	bsr	CheckHitPlayer
	lea	player1(a5),a3
	bsr	CheckHitPlayer
	lea	player2(a5),a3
	bsr	CheckHitPlayer
	bsr	PlayerCoords
	subq.b	#1,d7
	bne.s	P3_Hclp
	rts

*****
*CheckHitScene(a0,d0,d1,d2)(bobs,new x,new y,offset)
*Check specified player bob for hits against scenery
*>>>>PIXEL ACCURATE<<<<<
*****
CS_KillDeltaY	clr.w	p_dy(a4)
	rts
CS_KillDeltaX	clr.w	p_dx(a4)
	rts

CheckHitScene
	move.l	p_sprptr(a4),a0			; My sprite ptr
	move.w	p_xpos(a4),d0			; New x,y pos...
	move.w	p_ypos(a4),d1
	add.w	p_dx(a4),d0				; Add deltas
	add.w	p_dy(a4),d1
	move.w	p_facedir(a4),d2
	bsr.s	SpriteSCheck
	bne.s		CS_OK				;TRUE=nonzero
	tst.w	p_dx(a4)
	beq.s	CS_KillDeltaY
	tst.w	p_dy(a4)
	beq.s	CS_KillDeltaX

	move.w	p_dx(a4),d3				;Try no X movement
	clr.w	p_dx(a4)
	sub.w	d3,d0
	bsr.s	SpriteSCheck
	bne.s	CS_OK

	sub.w	p_dy(a4),d1				;try no Y movement
	clr.w	p_dy(a4)
	move.w	d3,p_dx(a4)
	add.w	d3,d0
	bsr.s	SpriteSCheck
	bne.s	CS_OK
	clr.w	p_dx(a4)
CS_OK	rts

*****
* SpriteSCheck(Bob xpos ypos offset) (a0 d0 d1 d2)
* Sprite Collision detection code! Handles sprite<>surround hits!
* Returns NONZERO (NE) if no collision occured!
*****
SpriteSCheck
	movem.l	d0-d1/d3/a1-a2,-(a7)
	lea	hitplane,a1
	move.w	d0,d3
	lsr.w	#3,d3					; No. bytes
	lea	(a1,d3.w),a1

	mulu	#plwidb,d1				; Y offset in plane
	lea	(a1,d1.l),a1				; TLC for checks

	and.w	#%1111,d0
	ror.w	#4,d0					; Bltcon value...(rot for srcs)
	or.w	#USEA!USEC!LF7!LF5,d0	; 'AC'
	move.l	B_Hitmap(a0),a2	
	lea	(a2,d2.w),a2				; get hitmap+offset it...
									; Use A&C for 'free' channel time!
									; A2=A channel
									; A1=C channel


	SBLITWAIT	a6,D3
	move.w	B_CMod(a0),bltcmod(a6)
	move.w	B_CSHMod(a0),bltamod(a6)	; Source modulo (one planar)
	move.l	a2,bltapth(a6)
	move.l	a1,bltcpth(a6)
	move.w	d0,bltcon0(a6)			; modes, A rot
	move.w	#0,bltcon1(a6)			; Zilch in con1
	move.l	#$ffff0000,bltafwm(a6)	; No last word!
	move.w	B_CSHBSize(a0),bltsize(a6)	; Get bsize (one planar)
	SBLITWAIT	a6,D3
	movem.l	(a7)+,d0-d1/d3/a1-a2
	btst	#5,dmaconr(a6)			;Blitzero ?
	rts

SpriteSCheck68k
	movem.l	a1-a4/d0-d6,-(a7)
;get tlc plane
	lea	hitplane,a1
	move.w	d0,d3
	lsr.w	#4,d3
	add.w	d3,d3
	lea	(a1,d3.w),a1
	mulu	#plwidb,d1
	lea	(a1,d1.w),a1
;get shift value
	and.w	#%1111,d0				;d0=RIGHT shift
;For every pixel height
	move.w	b_hgt(a0),d1
	subq.w	#1,d1					;-1 for dbra

	move.l	b_Hitmap(a0),a2
	lea	(a2,d2.w),a2				;offset for multi sprites
	move.w	b_wwid(a0),d2
	subq.w	#2,d2

;	move.w	B_wwid(a0),d5
;	subq.w	#1,d5
;	add.w	d5,d5
;	add.w	b_smod(a0),d5
;	mulu	#npl,d5

	move.w	b_cshmod(a0),d5
	addq.w	#4,d5

	moveq	#0,d6

SSC68_hlp
;-save plane pos...
	move.l	a1,a3
	move.l	a2,a4
;-For every word wide:
	move.w	d2,d3					;d3=width counter...
SSC68_wlp
;--and.w hitplane,bobplane
	move.l	(a1)+,d4				;01 23
	swap	d4						;23 01
	subq.l	#2,a1
	rol.l	d0,d4					;3 01 2
	
	move.w	(a2)+,d6
	and.l	d6,d4
;--bne hit
	bne.s	SSC68_hit
	dbra	d3,SSC68_wlp
;-recover plane pos,add line height
	lea	plwidb(a3),a1	;next line
	lea	(a4,d5.w),a2
;-loop,till done
	dbra	d1,SSC68_hlp
;rts NO HIT
	movem.l	(a7)+,a1-a4/d0-d6
	SETNONZEROFLAG
	RTS
;HIT: rts HIT
SSC68_hit
	movem.l	(a7)+,a1-a4/d0-d6
	SETZEROFLAG
	rts

*****
*CheckHitPlayer(a3,a4) (test player, active player)
*Check proposed active player coords against test player:
*modify deltas as reqd to allow movement
*****
CHP_KillDeltaY	clr.w	p_dy(a4)
	rts
CHP_KillDeltaX	clr.w	p_dx(a4)
	rts

CheckHitPlayer
	cmp.b	#DEAD,p_state(a3)		; Cant hit dead players!
	beq.s	CHP_OK

	bsr.s	CHP_HitSub
	bne.s	CHP_OK

;We've hit the other player! - sub crash damage from player a3s energy
;IF THEY ARE ALIVE
	CMP.B	#ALIVE,p_state(a3)
	bne.s	CHP_DYING

	cmp.w	#PB_Shield,p_bonussig(a3)	; ARE they immune ?
	beq.s	CHP_NCrash
	subq.w	#CRASHDAMAGE,p_energy(a3)
	bge.s	CHP_NDead
	add.l	#KILLEDSCORE,p_score(a4)
CHP_NDead
CHP_NCrash
    subq.l   #CRASHSCORE,p_score(a4)
	bge.s CHP_Cont
    clr.l   p_score(a4)                 ;
	BRA.S	CHP_CONT

;If in box of exploding player, also take damage : EXPLOSION
CHP_DYING
	cmp.w	#PB_Shield,p_bonussig(a4)	; Are they immune ?
	beq.s	CHP_Immune
	tst.b	d5						; In bang box ?
	beq.s	CHP_Immune
	subq.w	#EXPLODAMAGE,p_energy(a4)
CHP_Immune

CHP_CONT
	tst.w	p_dx(a4)
	beq.s	CHP_KillDeltaY
	tst.w	p_dy(a4)
	beq.s	CHP_KillDeltaX
	move.w	p_dx(a4),d6
	clr.w	p_dx(a4)
	bsr.s	CHP_HitSub
	bne.s	CHP_OK
	clr.w	p_dy(a4)
	move.w	d6,p_dx(a4)
	bsr.s	CHP_HitSub
	bne.s	CHP_OK
	clr.w	p_dx(a4)
CHP_OK	rts

CHP_HitSub							;Box based collision routine at mo!
	moveq	#0,d5					;Set box hit to zero
	move.w	p_xpos(a3),d0
	move.w	p_ypos(a3),d1
	move.w	p_xpos(a4),d2
	move.w	p_ypos(a4),d3
	add.w	p_dx(a4),d2
	add.w	p_dy(a4),d3
	sub.w	d2,d0
	sub.w	d3,d1
	move.w	d0,d2
	move.w	d1,d3
	tst.w	d0
	bpl.s	CP_1
	neg.w	d0
CP_1
	tst.w	d1
	bpl.s	CP_2
	neg.w	d1
Cp_2
	cmp.w	#15,d0
	bls.s	CP_PossX
CP_NPossY	moveq	#1,d0
	rts
CP_PossX	cmp.w	#18,d1
	bhi.s	CP_NPossY
;need to do pixel accurate hits!
	moveq	#1,d5					; Have hit box! - for in explosion damage

	add.w	#16,d2					; Centre deltas
	add.w	#18,d3	
	bsr	MakePapmap
	
;Now do hitcheck w. d2,d3 coords
	lea	PAPMAP,a1
	move.w	d2,d4
	lsr.w	#3,d4
	lea	(a1,d4.w),a1
	mulu	#6,d3					; Yoffset :6 bytes width
	lea	(a1,d3.w),a1				; C channel setup
	and.w	#%1111,d2
	ror.w	#4,d2
	or.w	#USEA!USEC!LF7!LF5,d2	; AC
	move.l	p_sprptr(a3),a0
	move.l	b_hitmap(a0),a2
	move.w	p_facedir(a3),d4
	lea	(a2,d4.w),a2				; Offset mask - A chan

	SBLITWAIT	a6,D4
	move.w	#6-4,bltcmod(a6)		; Bytes width -2*words per bob
	move.w	B_CSHMod(a0),bltamod(a6)
	move.l	a2,bltapth(a6)
	move.l	a1,bltcpth(a6)
	move.w	d2,bltcon0(a6)			; modes, A rot
	move.w	#0,bltcon1(a6)			; Zilch in con1
	move.l	#$ffff0000,bltafwm(a6)	; No last word!
	move.w	B_CSHBSize(a0),bltsize(a6)
	SBLITWAIT	a6,D4
	btst	#5,dmaconr(a6)
	rts								; NE=ZERO!

*****
*PlayerCoords(a4)
*Do deltas + coord clipping for player(s)
*D0 scrunged,x/y pos (a4) changed!
*****
PlayerCoords
	move.w	p_dx(a4),d0
	add.w	d0,p_xpos(a4)
	move.w	p_dy(a4),d0
	add.w	d0,p_ypos(a4)

	tst.w	p_xpos(a4)
	bpl.s	DOP_Xposok1
	move.w	#0,p_xpos(a4)
DOP_Xposok1
	cmp.w	#(PLWIDB-2)*8,p_xpos(a4)
	bmi.s	DOP_Xposok2
	move.w	#(PLWIDB-2)*8,p_xpos(a4)
DOP_Xposok2
	tst.w	p_ypos(a4)
	bpl.s	DOP_Yposok3
	move.w	#0,p_ypos(a4)
DOP_Yposok3
	cmp.w	#PLHGT,p_ypos(a4)
	bmi.s	DOP_Yposok4
	move.w	#PLHGT,p_ypos(a4)
DOP_Yposok4
	rts

*****
*Bullet control code for each player
*MOVE/REFLECT/HITS/DAMAGE/EXPLOSION/NEW BULLETS/BULLET TIMERS
*****
Player0_BullCode
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P0B_NAlive
;
	cmp.w	#PB_Shield,p_bonussig(a4)
	beq.s	P0B_Nalive
;
	lea	player1(a5),a3				; Check player1s active! bullets 
	bsr	ProcBullets
	lea	player2(a5),a3				; Check players active! bullets 
	bsr	ProcBullets
	lea	player3(a5),a3				; Check players active! bullets 
	bsr	ProcBullets
P0B_NAlive
	bsr	RunBullets
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P0B_NFire
	Btst	#Fire,p_joyval(a4)		; Firing ?
	beq.s	P0B_NFire
	bsr	FireBullet
P0B_NFire
	rts

Player1_BullCode
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P1B_NAlive
;
	cmp.w	#PB_Shield,p_bonussig(a4)
	beq.s	P1B_Nalive
;
	lea	player0(a5),a3				; Check player0s active! bullets
	bsr	ProcBullets
	lea	player2(a5),a3				; Check players active! bullets 
	bsr	ProcBullets
	lea	player3(a5),a3				; Check players active! bullets 
	bsr	ProcBullets
P1B_NAlive
	bsr	RunBullets
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P1B_NFire
	Btst	#Fire,p_joyval(a4)		; Firing ?
	beq.s	P1B_NFire
	bsr	FireBullet
P1B_NFire
	rts

Player2_BullCode
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P2B_NAlive
;
	cmp.w	#PB_Shield,p_bonussig(a4)
	beq.s	P2B_Nalive
;

	lea	player0(a5),a3				; Check player0s active! bullets 
	bsr.s	ProcBullets
	lea	player1(a5),a3				; Check players active! bullets 
	bsr.s	ProcBullets
	lea	player3(a5),a3				; Check players active! bullets 
	bsr.s	ProcBullets
P2B_NAlive
	bsr	RunBullets
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P2B_NFire
	Btst	#Fire,p_joyval(a4)		; Firing ?
	beq.s	P2B_NFire
	bsr	FireBullet
P2B_NFire
	rts

Player3_BullCode
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P3B_NAlive
;
	cmp.w	#PB_Shield,p_bonussig(a4)
	beq.s	P3B_Nalive
;

	lea	player0(a5),a3				; Check player0s active! bullets 
	bsr.s	ProcBullets
	lea	player1(a5),a3				; Check players active! bullets
	bsr.s	ProcBullets
	lea	player2(a5),a3				; Check players active! bullets 
	bsr.s	ProcBullets
P3B_NAlive
	bsr	RunBullets
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P3B_NFire
	Btst	#Fire,p_joyval(a4)		; Firing ?
	beq.s	P3B_NFire
	bsr	FireBullet
P3B_NFire
	rts


*****
*ProcBullets(a3,a4) (test player,active player)
*Check all test player bullets against active player - if any!
*Sub players energy+term bullet if hit etc
*****
ProcBullets
	cmp.b	#0,p_bulletcnt(a3)
	beq.s	PB_NoneActive

	move.w	p_xpos(a4),d2			; Needed by check routine
	move.w	p_ypos(a4),d3
	moveq	#0,d6					; Hits so far
	lea	p_bullets(a3),a2			; Bullet list
	move.w	w.MaxBullets(a5),d7
PB_Checklp
	cmp.b	#ALIVE,bl_sig(a2)
	bne.s	PB_Nalive
	bsr.s	PB_Check				; Check bullet vs papmap/hit box
PB_Nalive	lea	bullet_len(a2),a2
	dbra	d7,PB_Checklp
	sub.w	d6,p_energy(a4)
	bge.s PB_StillOK
	add.l	#KILLEDSCORE,p_score(a3)	; If energy -ve + score!
PB_StillOK
PB_noneActive	
	rts

PB_Check
;d6- damage so far (+BULLETDAMAGE PER HIT) d7-bullet countdown
;d2/d3 coords of test player
;a2 bullet struct - set bullet exploding (DYING) + D6AMAGE on hit!
;a3,a4 player for bullet, player to be hit!
;Use box method only: bullets+players occupy enough of a box to be OK.

	Move.w	bl_xpos(a2),d0
	Move.w	bl_ypos(a2),d1
	Sub.w	d2,d0
	Sub.w	d3,d1
	cmp.w	#15,d0					; Bullet right of player ?
	bgt.s	PBC_NoHit
	cmp.w	#-7+1,d0				; Left?
	blt.s	PBC_NoHit
	cmp.w	#15,d1					; Below ?
	bgt.s	PBC_NoHit
	cmp.w	#-7+1,d1				; Above ?
	blt.s	PBC_NoHit

;Say we've hit player (TEMP)
	add.w	#BULLETDAMAGE,d6		; Add to damage
;
	add.l	#BULLETSCORE,p_score(a3)	; At to guilty party's score...

	cmp.b	#BLT_DAMAGE,bl_type(a2)	; More damage if DAMAGE bonus...
	beq.s	PBC_MoreDamage
	cmp.b	#BLT_BSPLIT,bl_type(a2)	; More if a splitter hits...
	bne.s	PBC_NoMoreDamage
PBC_MoreDamage
	add.w	#BULLETDAMAGE,d6
PBC_NoMoreDamage

	move.b	#DYING,bl_sig(a2)		; BANG!
;BUG FIX: GFX ERROR ON COLLSION SO BL_EXPLO=>0
	addq.b	#1,bl_explo(a2)

	IFD	SMPI
	LEA SMPI_SMALLEXPLOD,A0
	BSR PLAYSMPI
	ENDC
PBC_NoHit	rts

*****
*RunBullets(a4) (player)
*Run all active player bullets - move/reflect/sub timers/terminate etc
*****
RunBullets
	cmp.b	#0,p_bulletcnt(a4)		; No bullets in play? Abort!
	beq.s	RB_Quit
	lea	p_bullets(a4),a3
	move.w	w.maxBullets(a5),d7		; Counter
RB_lp
	cmp.b	#DEAD,bl_sig(a3)		; Ignore dead bullets
	beq.s	RB_Dead
	cmp.b	#DYING,bl_sig(a3)		; Dying bullets...
	beq.s	RB_Dying
	subq.w	#1,bl_timer(a3)
	beq.s	RB_Die					; Time out ? Dying!

;move/reflect bullet:-)
	bsr.s RB_Surrounds
	bsr.s	BulletCoords
RB_Dead
	lea	bullet_len(a3),a3
	dbra	d7,RB_lp
RB_Quit
	rts

RB_Die
	move.b	#DYING,bl_sig(a3)		; Kill it!

;If a splitter bullet, try to launch 3 more...
	cmp.b	#BLT_BSPLIT,bl_type(a3)
	bne.s	RB_Dying
	bsr	Launch3Norm
RB_Dying							; Keep on killing!
	addq.b	#1,bl_explo(a3)
	cmp.b	#Bullmax,bl_explo(a3)

;BULLETS DIE INSTANTLY! IF NEXT BRANCH COMMENTED OUT!
	bne.s	RB_Dead

	move.b	#DEAD,bl_sig(a3)		; Finito....
	subq.b	#1,p_bulletcnt(a4)		; One less bullet to worry about
	bra.s	RB_Dead

*****
*BulletCoords ( bullet x y )(a3 d0 d1)
*Coord clipping for bullet
*x/y pos (a3) changed!
*****
BulletCoords
	tst.w	d0
	bpl.s	BC_Xposok1
	move.w	#0,d0
BC_Xposok1
	cmp.w	#(PLWIDB-2)*8,d0
	bmi.s	BC_Xposok2
	move.w	#(PLWIDB-2)*8,d0
BC_Xposok2
	tst.w	d1
	bpl.s	BC_Yposok3
	move.w	#0,d1
BC_Yposok3
	cmp.w	#PLHGT,d1
	bmi.s	BC_Yposok4
	move.w	#PLHGT,d1
BC_Yposok4
	move.w	d0,bl_xpos(a3)
	move.w	d1,bl_ypos(a3)
	rts

*****
* RB_surrounds(bullet)(a3)
* Move/reflect bullet against surroundings!
* Adjust dx/dy as reqd
* PROBABLY THE MOST IMPORTANT LUMP OF CODE!
* RETURN : d0,d1 legit coords
*****
Rb_Surrounds
;Try entire movement...
	move.l	bl_sprptr(a3),a0

;	moveq.l	#BULLSPEED,d2		;<<<<
	move.w	bl_dx(a3),d0
	add.w	d0,d0
	add.w	d0,d0

	add.w	bl_xpos(a3),d0
	move.w	bl_dy(a3),d1

;	muls	d2,d1				;<<<<
	add.w	d1,d1
	add.w	d1,d1
;
	add.w	bl_ypos(a3),d1
	moveq	#0,d2					; Bullets have no bitmap offset
	bsr	SpriteSCheck
	beq.s	RB_NOk
	rts
RB_NOK
;If 'bonus' of non reflective bullets *or* splitter set, kill bullet etc.
	cmp.b	#BLT_NRBULLET,bl_type(a3)
	beq	RB_Stepwall
	cmp.b	#BLT_BSPLIT,bl_type(a3)
	beq	RB_Stepwall

;Step through this frames worth of bullet movement > reflect as reqd
;set num to move (BULLSPEED)
	moveq	#BULLSPEED-1,d5			; Num to count, -1 for dbra
	move.w	bl_xpos(a3),d3			; x,y pos in d4
	move.w	bl_ypos(a3),d4
;* calc dirn
RB_mlp
	move.w	bl_dx(a3),d0			; 4*(dy+1)+(dx+1) * LW
	addq.w	#1,d0
	move.w	bl_dy(a3),d1
	addq.w	#1,d1
	lsl.w	#2,d1
	add.w	d1,d0

	lsl.w	#5,d0					; struct is 16 words/entry = 32 bytes

	lea	BullDirnTab(PC),a2
	lea	(a2,d0.w),a2
;jmp to dirn code x,y in d3/d4 d2=0
	bsr.s ProcRBEntry
;add dx/dy to proposed x,y pos
	add.w	bl_dx(a3),d3
	add.w	bl_dy(a3),d4
;loop * until moved all
	dbra	d5,RB_mlp
	move.w	d3,d0					; Proposed coords d0-d1
	move.w	d4,d1
	RTS

ProcRBEntry
;d3,d4 coords, d2=0 d5,d6,d7 used! a3 & up used!
;a0 = sprstruct
;any 2s are ERRORS!!!!
;Test dxy0 OK then no new dxy
	move.w	d3,d0
	move.w	d4,d1
	add.w	RBE_dx0(a2),d0
	add.w	RBE_dy0(a2),d1
	bsr	SpriteSCheck
	beq.s	PRBE_Nok				; No collision then quit,ok.
	rts
;ELSE
PRBE_nok

;CHeck other two test locations, then decide on bullet reflection.
;Test dxy1,2
	sub.l	a1,a1					; Need more data registers! Use a1=counter
	move.w	d3,d0
	move.w	d4,d1
	add.w	RBE_dx1(a2),d0
	add.w	RBE_dy1(a2),d1
	bsr	SpriteSCheck
	bne.s		PRBE_Nf1
	addq.l	#4,a1					; 2 words to skip
PRBE_Nf1
	move.w	d3,d0
	move.w	d4,d1
	add.w	RBE_dx2(a2),d0
	add.w	RBE_dy2(a2),d1
	bsr	SpriteSCheck
	bne.s		PRBE_Nf2
	addq.l	#8,a1					; 2*2 words to skip
PRBE_Nf2
;Then new dxy as rxy0-3 !!! (fine in theory!)
	move.l	a1,d0
	move.w	RBE_rx0(a2,d0),bl_dx(a3)
	move.w	RBE_ry0(a2,d0),bl_dy(a3)
	rts

RB_StepWall							; Pilot bullet up to wall & explode!
;	moveq	#BULLSPEED-1,d5			; Num to count, -1 for dbra +1 FOR START!
Stepperlp							; Loop up to wall...
	sub.w	bl_dx(a3),d0
	sub.w	bl_dy(a3),d1
	bsr	SpriteSCheck
	beq.s	Stepperlp
;	dbeq	d5,Stepperlp
	move.w	#1,bl_timer(a3)			; Return d0-1 legit coords...
	rts

BullDirnTab
;BULLET DIRECTION REFLECTION/TESTCODE TABLE!!!
;AS STRUCT BELOW...
;*FOR FIRST REFL CODE!
	rsreset
RBE_dx0	rs.w	1					; Try first - if OK do dx/dy as is
RBE_dy0	rs.w	1
RBE_dx1	rs.w	1					; Other 2 test locns
RBE_dy1	rs.w	1
RBE_dx2	rs.w	1
RBE_dy2	rs.w	1

RBE_rx0	rs.w	1					; neither 2 tests fail
RBE_ry0	rs.w	1
RBE_rx1	rs.w	1					; 1st test fail
RBE_ry1	rs.w	1
RBE_rx2	rs.w	1					; 2nd test
RBE_ry2	rs.w	1
RBE_rx3	rs.w	1					; both 2 tests fail
RBE_ry3	rs.w	1
		rs.w	2					; dummy entries!
;16words per direction entry => *32 or lsl #5 offset code

BD_E	MACRO
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		ENDM
;BD_ul
	dc.w	-1,-1,-1,0,0,-1,1,1,1,-1,-1,1,1,1,0,0
;BD_u
	dc.w	0,-1,-1,-1,1,-1,0,1,1,0,-1,0,0,1,0,0
;BD_ur
	dc.w	1,-1,0,-1,1,0,-1,1,1,1,-1,-1,-1,1,0,0
	BD_e
;BD_l
	dc.w	-1,0,-1,1,-1,-1,1,0,0,-1,0,1,1,0,0,0
	BD_e
;BD_r
	dc.w	1,0,1,1,1,-1,-1,0,0,-1,0,1,-1,0,0,0
	BD_E
;BD_dl
	dc.w	-1,1,-1,0,0,1,1,-1,1,1,-1,-1,1,-1,0,0
;BD_d       d   dl   dr  u    r   l    u
	dc.w	0,1,-1,1,1,1,0,-1,1,0,-1,0,0,-1,0,0
;BD_dr
	dc.w	1,1,0,1,1,0,-1,-1,1,-1,-1,1,-1,-1,0,0
	BD_E

*****
*FireBullet(a4)(player)
*Fire bullet if bullet timer =0 + free bullet slot + enough power!
*****
FireBullet
	cmp.b	#0,p_bullettim(a4)		; Can't fire if counter NZERO 
	bne	FB_QUit
	move.w	w.Maxbullets(a5),d0
	addq.w	#1,d0
	cmp.b	p_bulletcnt(a4),d0		; Must have free slot!
	beq	FB_Quit

	cmp.w	#BULLETCOST,p_bulletpow(a4)	; Must have power!
	bmi	FB_Quit
	addq.b	#1,p_bulletcnt(a4)			; Add to active count
	sub.w	#BULLETCOST,p_bulletpow(a4)	; Subtract power!
	move.b	#BULLETDELAY,p_bullettim(a4)	; Pause value!
	lea	p_bullets(a4),a3
FB_GetB
	cmp.b	#DEAD,bl_sig(a3)
	beq.s	FB_GotB
	lea	Bullet_len(a3),a3
	bra.s	FB_GetB
FB_GotB

	IFD	SMPI
	cmp.w	#PB_NRBULLET,p_bonussig(a4)	; Reflective ?
	bne.s	FB_Snd2
	lea	SMPI_SHOT3,A0				; Shot 3 : naff bullets!
	BSR	playsmpi
	BRA.S	FB_SndC
FB_Snd2
	lea	SMPI_SHOT1,a0
	BSR	playsmpi
FB_SndC
	ENDC

	move.b	#ALIVE,bl_sig(a3)		; Alive!
	move.w	#BULLETDIST,bl_timer(a3)	; Distance to run!
	move.b	#BLT_NORM,bl_type(a3)
;
	cmp.w	#PB_BDIST,p_bonussig(a4)
	bne.s	FB_NDist
	move.w	#BONUSBDIST,bl_timer(a3)
	move.b	#BLT_LONG,bl_type(a3)
FB_NDist
	cmp.w	#PB_BPOWER,p_bonussig(a4)
	bne.s	FB_NPow
	move.b	#BLT_DAMAGE,bl_type(a3)
FB_NPow
	cmp.w	#PB_NRBULLET,p_bonussig(a4)
	bne.s	FB_NRB
	move.b	#BLT_NRBULLET,bl_type(a3)
FB_NRB
	cmp.w	#PB_BSPLIT,p_bonussig(a4)		; Will bullet split ???
	bne.s	FB_NSPLIT
	move.b	#BLT_BSPLIT,bl_type(a3)
	move.b	#BULLETDELAY*2,p_bullettim(a4)	; Pause value!
FB_NSPLIT

	move.b	#-1,bl_explo(a3)		; 1st explo frame when +1

;Set x/y pos, set dx/y according to p_x/ypos, p_facedir
	move.w	p_xpos(a4),d1			; Offset from TLC
	move.w	p_ypos(a4),d2
	lea	BDeltaTab,a0
	move.w	p_facedir(a4),d0		; Get dirn U>r>d>l
	add.w	d0,d0					; *2
	add.w	d0,d0					; *4 - now mod 8!
	add.w	(a0,d0.w),d1
	add.w	2(a0,d0.w),d2

	move.w	d1,bl_xpos(a3)
	move.w	d2,bl_ypos(a3)
	move.w	4(a0,d0.w),bl_dx(a3)
	move.w	6(a0,d0.w),bl_dy(a3)

FB_Quit	rts

*****
*Launch3Norm(a3,a4)(bullet,player)
*Launch 3 bullets Perpendicular to bullet path!
*****
Launch3Norm
	push	d0-d7/a0-a3
	move.l	a3,a2					; save bullet struct...
	moveq	#3-1,d3					; Bullet no.
L3n_lp
	bsr.s	LaunchNorm
	dbra	d3,L3n_lp
	pop	d0-d7/a0-a3
	rts
LaunchNorm
	move.w	w.Maxbullets(a5),d0
	addq.w	#1,d0
	cmp.b	p_bulletcnt(a4),d0		; Must have free slot!
	beq.s	LN_Quit
	addq.b	#1,p_bulletcnt(a4)			; Add to active count
	lea	p_bullets(a4),a3
LN_GetB
	cmp.b	#DEAD,bl_sig(a3)
	beq.s	LN_GotB
	lea	Bullet_len(a3),a3
	bra.s	LN_GetB
LN_GotB
	IFD	SMPI
	lea	SMPI_SHOT1,a0
	BSR	playsmpi
	ENDC

	move.b	#ALIVE,bl_sig(a3)		; Alive!
	move.w	#BULLETDIST,bl_timer(a3)	; Distance to run!
	move.b	#BLT_NORM,bl_type(a3)
	move.b	#-1,bl_explo(a3)		; 1st explo frame when +1

;Set x/y pos, set dx/y according to bl_x/ypos, bl_dx/dy,d3=offset

	move.w	bl_xpos(a2),bl_xpos(a3)			; Pos
	move.w	bl_ypos(a2),bl_ypos(a3)
	lea	SplitTab,a0

	move.w	bl_dx(a2),d0			; Calc table pos 16 b per entry...

	addq.w	#1,d0
	move.w	bl_dy(a2),d1

	addq.w	#1,d1
	lsl.w	#2,d1
	add.w	d1,d0
	lsl.w	#2,d0
	add.w	d3,d0
	lsl.w	#2,d0
									;16(dx+1)+4F+64(dy+1)=(4(dx+1+4(dy+1))+F)*4

	move.w	(a0,d0.w),bl_dx(a3)
	move.w	2(a0,d0.w),bl_dy(a3)
LN_Quit	rts
SplitTab	;dxy1,dxy2,dxy3,null :16 bytes/entry

;UL U UR N
;L N R N
;DL D DR N
	dc.w	1,0,0,1,1,1,6,6
	dc.w	0,1,-1,1,1,1,6,6
	dc.w	-1,0,0,1,-1,1,6,6
	dc.w	6,6,6,6,6,6,6,6

	dc.w	1,0,1,-1,1,1,6,6
	dc.w	6,6,6,6,6,6,6,6
	dc.w	-1,0,-1,-1,-1,1,6,6
	dc.w	6,6,6,6,6,6,6,6

	dc.w	0,-1,1,0,1,-1,6,6
	dc.w	-1,-1,1,-1,0,-1,6,6
	dc.w	0,-1,1,0,-1,-1,6,6
	dc.w	6,6,6,6,6,6,6,6

*****
*MakePapmap(a4)(player struct)
*Builds Pixel Accurate Player MAP for given passed struct
*       +     +        +      +++
*
*Assumes PAPMAP blanked
*d0/a1/a2 scrunged
*****
MakePapmap
	lea	PAPMap+110,a1				; Dummy 9*2*18 array
	move.l	p_sprptr(a4),a2
	move.l	b_hitmap(a2),a2
	move.w	p_facedir(a4),d0
	lea	(a2,d0.w),a2
;Players are 16 hgt
	move.w	(a2),(a1)
	move.w	80*1(a2),6*1(a1)
	move.w	80*2(a2),6*2(a1)
	move.w	80*3(a2),6*3(a1)
	move.w	80*4(a2),6*4(a1)
	move.w	80*5(a2),6*5(a1)
	move.w	80*6(a2),6*6(a1)
	move.w	80*7(a2),6*7(a1)
	move.w	80*8(a2),6*8(a1)
	move.w	80*9(a2),6*9(a1)
	move.w	80*10(a2),6*10(a1)
	move.w	80*11(a2),6*11(a1)
	move.w	80*12(a2),6*12(a1)
	move.w	80*13(a2),6*13(a1)
	move.w	80*14(a2),6*14(a1)
	move.w	80*15(a2),6*15(a1)
	rts

BOFF = 0
BRUN = 1
BOPEN = 2
BCLOSE = 3

BBONUSFRAMES = 5						; 5 frame of anims
BBONUSSPEED = 2						; New frame every 2. HARD CODED!!!
BBONUSTIME = 250

InitBonus
	MOVE.L	#BonusSave1,Bonus_Save1(a5)
	MOVE.L	#BonusSave2,Bonus_Save2(a5)
	MOVE.L	#RANDLIST,l.randptr(a5)
	MOVE.L	#BRANDLIST,l.brandptr(a5)
	RTS

ResetBonus
	clr.b	Bonus_count(a5)			; Zero timer
	move.b	#BOFF,Bonus_state(a5)	; Kill any left...
	MOVE.L	Bonus_Save1(a5),a0
	CLR.L	(A0)+
	MOVE.L	Bonus_Save2(a5),a0
	CLR.L	(A0)+
	RTS

*****
*PrintRunBonus
*Process bonus!
*****
PrintRunBonus
	CMP.B	#BOPEN,Bonus_State(a5)	; Opening : just do sprite
	Beq.s	PRB_Opening
	CMP.B	#BRUN,Bonus_State(a5)	; RUN : check to see if collected
	Beq.s	PRB_Running
	CMP.B	#BCLOSE,Bonus_State(a5)	; Closing : just sprite
	Beq.s	PRB_Closing
	Addq.b	#1,Bonus_Count(a5)		; Add to counter
	cmp.b	#BBONUSTIME,Bonus_Count(a5)	; LAUNCH BONUS if max!
	beq.s	PRB_Launch
	rts
PRB_Launch

	Move.b	#BOPEN,Bonus_State(a5)
	move.w	#BBONUSFRAMES*BBONUSSPEED,Bonus_Timer(a5)
	lea	lp.maplist,a0
	move.w	w.Curlevel(a5),d0
	mulu	#MP_LEN,d0
	Lea	Mp_bonus(a0,d0.w),a0			;Get offsets
;Grab 0-3rd entry.... (random)
	bsr	random03
	MOVE.W	(A0,D0.W),BONUS_X(A5)
	MOVE.W	2(A0,D0.W),BONUS_Y(A5)	
PRB_Opening
;-TIMER to Min
	Subq.w	#1,bonus_timer(a5)
	bne.s	PRB_o1
	move.b	#BRUN,bonus_state(a5)
PRB_o1
;Print bonus at pos, bitmap as per timer
	BRA	PrintBonus

PRB_Closing
;+TIMER to Max, then terminate
	Addq.w	#1,bonus_timer(a5)
	cmp.w	#BBONUSSPEED*BBONUSFRAMES-1,bonus_timer(a5)
	bne	PrintBonus
	move.b	#BOFF,bonus_state(a5)	; Zero count till next bonus...
	clr.b	bonus_count(a5)
;	rts
	Bra	PrintBonus

PRB_Running
;Check to see if collected.
	move.w	w.numplayers(a5),d7	; No to check
	Move.w	bonus_x(a5),d4
	MOve.w	bonus_y(a5),d5
	lea	player0(a5),a4
prb_chklp
	cmp.b	#ALIVE,p_state(a4)
	bne.s	prb_chklpfin
	move.w	p_xpos(a4),d2
	move.w	p_ypos(a4),d3
	move.w	d4,d0
	move.w	d5,d1
	sub.w	d2,d0
	sub.w	d3,d1
	cmp.w	#15-1,d0					; Bullet right of player ?
	bpl.s	Prb_chklpfin
	cmp.w	#-15+1,d0					; Left?
	bmi.s	prb_chklpfin
	cmp.w	#15-1,d1					; Below ?
	bpl.s	prb_chklpfin
	cmp.w	#-15+1,d1					; Above ?
	bmi.s	prb_chklpfin
	bra.s	prb_chkhit
prb_chklpfin
	lea	p_len(a4),a4
	dbra	d7,prb_chklp
	BRA	PrintBonus
prb_chkhit

;if pb_fast,reset speed!
;	cmp.w	#PB_FAST,p_bonussig(a4)
;	bne.s	Prb_NF1
	move.b	#MAXSPEED,p_maxspeed(a4)
;Prb_nf1

;a4 is bonus player!
	bsr	Brandom
;Effect processed in next frame....
	move.w	d0,p_bonussig(a4)
	cmp.b	#PB_SHIELD,d0			; Set shorter time if a shield
	beq.s	Prb_SetShieldD
	cmp.b   #pb_bsplit,d0
	beq.s   Prb_setbsplittimer
	move.w	#BONUSDURATION,p_bonustime(a4)
Prb_SSDCont

	IFD	SMPI
	add.w	d0,d0
	add.w	d0,d0
	Move.l	BFXTAB(PC,d0.w),A0
	BSR	PlaySmpi
	ENDC
;-> Set Closing
	MOVE.b	#BCLOSE,bonus_state(a5)
	BRA	PrintBonus
Prb_SetShieldD
	move.W	#BONUSSHIELDDURATION,p_bonustime(a4)
	bra.s	Prb_SSDCont
Prb_setbsplittimer
	MOVE.W  #BONUSBSPLITDURATION,p_bonustime(a4)
	bra.s	Prb_SSDCont

	ifd	smpi
BFXTAB
	dc.l	smpi_scale.short	;none
	dc.l	smpi_scale.short
	dc.l	smpi_reload2
	dc.l	smpi_reload1
	dc.l	smpi_scale.short
	dc.l	smpi_scale.short
	dc.l	smpi_scale.short
	dc.l	smpi_scale.short
	dc.l	smpi_reload2
	endc

Random03	;get 0-3 *4 - pick posn for bonus icon
	move.l	a0,-(sp)
	move.l	l.randptr(a5),a0
	moveq	#0,d0
RRandom_entry
	move.b	(a0)+,d0
	bmi.s	ResetRandom03
	move.l	a0,l.randptr(a5)
	move.l	(sp)+,a0
	rts
ResetRandom03
	lea	randlist,a0
	bra.s	RRandom_entry
Randlist
	dc.b	1*4,3*4,2*4,0*4
	dc.b	2*4,0*4,1*4,3*4
	dc.b	1*4,0*4,3*4,2*4
	dc.b	3*4,1*4,0*4,2*4
	dc.b	-1
	even

BRandom
	move.l	a0,-(sp)
	move.l	l.brandptr(a5),a0
BRRandom_entry
	move.w	(a0)+,d0
	bmi.s	BResetRandom
	move.l	a0,l.brandptr(a5)
	move.l	(sp)+,a0
	rts
BResetRandom
	lea	brandlist,a0
	bra.s	BRRandom_entry

BRANDLIST

	dc.w	PB_BDIST	
	dc.w	PB_SHIELD	
	dc.w	PB_BSPLIT
	dc.w	PB_NRBULLET 
	dc.w	PB_INVIS
	dc.w	PB_ENERGY	
	dc.w	PB_BPOWER	
	dc.w	PB_FAST		

	dc.w	PB_NRBULLET 
	dc.w	PB_BPOWER	
	dc.w	PB_INVIS
	dc.w	PB_BSPLIT
	dc.w	PB_BDIST	
	dc.w	PB_ENERGY	
	dc.w	PB_FAST		
	dc.w	PB_SHIELD	

	dc.w	PB_BDIST	
	dc.w	PB_NRBULLET 
	dc.w	PB_INVIS
	dc.w	PB_ENERGY		
	dc.w	PB_BSPLIT
	dc.w	PB_SHIELD	
	dc.w	PB_BPOWER	
	dc.w	PB_FAST		

	dc.w	-1						; Terminator

PrintBonus							; Print bonus, interpret timer!
	Lea	Bonus_Bobs,a0
	move.l	p.drawpl(a5),a1
	Move.l	bonus_save1(a5),a2
	move.w	bonus_x(a5),d0
	move.w	bonus_y(a5),d1
	moveq	#0,d2
	move.w	bonus_timer(a5),d2
	lsr.w	#1,d2					; /2 speed
	BRA	DoBob

DeleteBonus
	move.l	bonus_save2(a5),a2
	move.l	bonus_save1(a5),bonus_save2(a5)
	move.l	a2,bonus_save1(a5)
	bra	recobob

*****
* ProcPBonus(a4) (player)
* Process bonus!
*****
ProcPBonus
	cmp.w	#PB_NONE,p_bonussig(a4)	; None active? QUIT
	bne.s	PPB_ok
	rts
PPB_ok
	move.w	p_bonussig(a4),d0

	cmp.w	#PB_ENERGY,d0			; Bonus energy? Add then null
	bne.s	PPB_NE
	add.w	#BONUSENERGY,p_energy(a4)
	move.w	#PB_NONE,p_bonussig(a4)
	rts
PPB_NE
	cmp.w	#PB_FAST,d0
	bne.s	PPB_NFAST
	move.b	#BONUSSPEED,p_maxspeed(a4)
	subq.w	#1,p_bonustime(a4)
	beq.s	PPB_NF2
	rts
PPB_NF2
	move.b	#MAXSPEED,p_maxspeed(a4)
	move.w	#pb_none,p_bonussig(a4)
	rts

PPB_NFAST
;These cmp handle IN other code blocks...
;	cmp.w	#PB_BPOWER,d0
;	cmp.w	#PB_BDIST,d0
;	cmp.w	#PB_SHIELD,d0
;	cmp.w	#PB_NRBULLET,d0
;	cmp.w	#PB_INVIS,d0
;	cmp.w	#PB_BSPLIT,d0
;	BRA.S	PPB_SubQuit

PPB_SubQuit
	subq.w	#1,p_bonustime(a4)
	beq.s	PPB_SQ2
	rts
PPB_SQ2
	move.w	#PB_NONE,p_bonussig(a4)
	rts

*****
* InitPlayers
* Initialises player structs
*****
InitPlayers
;Player 0 first:
	lea	player0(a5),a4
	move.l	#Player0_hitcode,p_hitptr(a4)
	move.l	#Player0_bobs,p_sprptr(a4)
	move.l	#player0_Save1,p_save1(a4)
	move.l	#Player0_Save2,p_save2(a4)
	move.l	#Player0_Bullcode,p_bulletptr(a4)
	lea	p_bullets(a4),a3
	lea	p0_Bulletsave,a2			; Array for bullet sprite saving
	move.w	#MaxPBulletTotal-1,d0
ip0_bulletlp
	move.l	#player0_bullets,bl_sprptr(a3)
	move.l	a2,bl_save1(a3)
	lea		Bulletsave_len(a2),a2	; Next save posn
	move.l	a2,bl_save2(a3)
	lea	Bulletsave_len(a2),a2
	lea	Bullet_len(a3),a3			; Next bullet	
	dbra	d0,ip0_bulletlp

;REPEAT! for player 1:
	lea	player1(a5),a4
	move.l	#Player1_hitcode,p_hitptr(a4)
	move.l	#Player1_bobs,p_sprptr(a4)
	move.l	#player1_Save1,p_save1(a4)
	move.l	#Player1_Save2,p_save2(a4)
	move.l	#Player1_Bullcode,p_bulletptr(a4)
	lea	p_bullets(a4),a3
	lea	p1_Bulletsave,a2			; Array for bullet sprite saving
	move.w	#MaxPBulletTotal-1,d0
ip1_bulletlp
	move.l	#player1_bullets,bl_sprptr(a3)
	move.l	a2,bl_save1(a3)
	lea		Bulletsave_len(a2),a2	; Next save posn
	move.l	a2,bl_save2(a3)
	lea	Bulletsave_len(a2),a2
	lea	Bullet_len(a3),a3			; Next bullet	
	dbra	d0,ip1_bulletlp

;REPEAT! for player 2:
	lea	player2(a5),a4

	move.l	#Player2_hitcode,p_hitptr(a4)
	move.l	#Player2_bobs,p_sprptr(a4)
	move.l	#player2_Save1,p_save1(a4)
	move.l	#Player2_Save2,p_save2(a4)
	move.l	#Player2_Bullcode,p_bulletptr(a4)
	lea	p_bullets(a4),a3
	lea	p2_Bulletsave,a2			; Array for bullet sprite saving
	move.w	#MaxPBulletTotal-1,d0
ip2_bulletlp
	move.l	#player2_bullets,bl_sprptr(a3)
	move.l	a2,bl_save1(a3)
	lea		Bulletsave_len(a2),a2	; Next save posn
	move.l	a2,bl_save2(a3)
	lea	Bulletsave_len(a2),a2
	lea	Bullet_len(a3),a3			; Next bullet	
	dbra	d0,ip2_bulletlp

;REPEAT! for player 3:
	lea	player3(a5),a4

	move.l	#Player3_hitcode,p_hitptr(a4)
	move.l	#Player3_bobs,p_sprptr(a4)
	move.l	#player3_Save1,p_save1(a4)
	move.l	#Player3_Save2,p_save2(a4)
	move.l	#Player3_Bullcode,p_bulletptr(a4)
	lea	p_bullets(a4),a3
	lea	p3_Bulletsave,a2			; Array for bullet sprite saving
	move.w	#MaxPBulletTotal-1,d0
ip3_bulletlp
	move.l	#player3_bullets,bl_sprptr(a3)
	move.l	a2,bl_save1(a3)
	lea		Bulletsave_len(a2),a2	; Next save posn
	move.l	a2,bl_save2(a3)
	lea	Bulletsave_len(a2),a2
	lea	Bullet_len(a3),a3			; Next bullet	
	dbra	d0,ip3_bulletlp

	rts

*****
*ResetNonStatic - Non-static data...
*Loads starting enrgies for both players
*Sets start pos from curlevel
*Resets bullets
*****
ResetNonStatic
	push	d0-d7/a0-a4
	Lea	player0(a5),a4
	BSR	Rp_rt
	Lea	player1(a5),a4
	BSR	Rp_rt
	Lea	player2(a5),a4
	BSR	Rp_rt
	Lea player3(a5),a4
	BSR	Rp_rt

	lea	player0(a5),a4
	tst.b	b.Player0Control(a5)
	beq.s	RS0_Stick
	bmi.s	RS0_Keys1
	move.l	#RKBDP0,p_joyptr(a4)
	BRA.S	RS0_ContrC
RS0_Keys1	move.l	#RKBDP1,p_joyptr(a4)
	BRA.S	RS0_COntrC
RS0_Stick	move.l	#RJoy0,p_joyptr(a4)		; Reader code
RS0_ContrC

	lea	player1(a5),a4
	tst.b	b.Player1Control(a5)
	beq.s	RS1_Stick
	bmi.s	RS1_Keys1
	move.l	#RKBDP0,p_joyptr(a4)
	BRA.S	RS1_ContrC
RS1_Keys1	move.l	#RKBDP1,p_joyptr(a4)
	BRA.S	RS1_COntrC
RS1_Stick	move.l	#RJoy1,p_joyptr(a4)		; Reader code
RS1_ContrC

	lea	player2(a5),a4
	tst.b	b.Player2Control(a5)
	beq.s	RS2_Stick
	bmi.s	RS2_Keys1
	move.l	#RKBDP0,p_joyptr(a4)
	BRA.S	RS2_ContrC
RS2_Keys1	move.l	#RKBDP1,p_joyptr(a4)
	BRA.S	RS2_COntrC
RS2_Stick	move.l	#RJoy2,p_joyptr(a4)		; Reader code
RS2_ContrC

	lea	player3(a5),a4
	tst.b	b.Player3Control(a5)
	beq.s	RS3_Stick
	bmi.s	RS3_Keys1
	move.l	#RKBDP0,p_joyptr(a4)
	BRA.S	RS3_ContrC
RS3_Keys1	move.l	#RKBDP1,p_joyptr(a4)
	BRA.S	RS3_COntrC
RS3_Stick	move.l	#RJoy3,p_joyptr(a4)		; Reader code
RS3_ContrC

	move.w	w.CurLevel(a5),d0
	mulu	#MP_len,d0			; 24 modulo on table
	lea	lp.maplist,a2
	lea	MP_Starts(a2,d0.w),a2				; Skip level/col ptrs

	lea	player0(a5),a0
	lea	player1(a5),a1	
	move.w	(a2)+,p_xpos(a0)
	move.w	(a2)+,p_ypos(a0)
	move.w	(a2)+,p_xpos(a1)
	move.w	(a2)+,p_ypos(a1)
	lea	player2(a5),a0
	lea	player3(a5),a1	
	move.w	(a2)+,p_xpos(a0)
	move.w	(a2)+,p_ypos(a0)
	move.w	(a2)+,p_xpos(a1)
	move.w	(a2)+,p_ypos(a1)

	move.w	#-1,w.DeathWatch(a5)	; Clear deathwatch
	bsr	ResetBonus
	pop	d0-d7/a0-a4
	rts

Rp_rt
	move.b	#0,p_bulletcnt(a4)
	move.b	#0,p_bullettim(a4)
	move.w	#0,p_facedir(a4)
	move.b	#ALIVE,p_state(a4)
	move.b	#0,p_diecnt(a4)
	lea	p_bullets(a4),a3			; Now initialise bullet structs
	move.w	#MaxPBulletTotal-1,d0
rp_bulletlp
	move.b	#DEAD,bl_sig(a3)
	move.l	bl_save1(a3),a2
	clr.l	(a2)
	move.l	bl_save2(a3),a2
	clr.l	(a2)
	lea	bullet_len(a3),a3
	dbra	d0,rp_bulletlp
	move.b	#0,p_joyval(a4)				; No value : 
	move.b	#MAXSPEED,p_maxspeed(a4)	; Stationary
	move.w	#MAXENERGY,p_energy(a4)
	move.w	#MAXPOWER,p_bulletpow(a4)
	move.w	#PB_NONE,p_bonussig(a4)	; Set no active bonus
	move.l	p_save1(a4),a3			; Nuke backups
	clr.l	(a3)
	move.l	p_save2(a4),a3
	clr.l	(a3)
	rts

*****
* InitMulTab()
*****
InitMulTab
	MOVEQ	#0,D1
	MOVE.W  #PLWIDB*NPL,D3
	MOVE.W  #PLHGT-1,D4
	LEa lw.plmultab(a5),a1
IMT_lp
	move.l d1,(a1)+
	add.w d3,d1
	dbra d4,imt_lp
	rts

*****
* Initlevels()
* Processes all offsets in lp.maplist, sets w.Numlevels
*****
InitLevels
	lea	lp.maplist,a1
	moveq	#-1,d0					; Level count
InitLevels_lp
	tst.l	(a1)
	beq.s	InitLevelsFin
	lea	Mp_Level(a1),a2
	move.w	#NUMBLOCKS-1,d1			; Level size
InitLevels_ilp
	MOVE.W	(A2),D2
	LSL.W	#5,D2					; *32 = length of 1 plane of block
	MOVE.W	D2,(A2)+
	DBRA	D1,InitLevels_ilp
	addq.l	#1,d0					; +1 levels
	lea	MP_LEN(a1),a1					; Skip levptr & colptr
	bra.s	InitLevels_lp
InitLevelsFin
	move.w	d0,w.Numlevels(a5)		; Save max levels
	rts

*****
* Startlevel()
* Initialises all level infos,fades in level
*****
Startlevel
	Move.l	#lw.BlackCols,plw.Cols(a5)
	MOVEQ	#1,D0
	Bsr	FadeCols					; Fade out screen

	lea	lp.maplist,a1
	move.w	w.CurLevel(a5),d0
	mulu	#MP_len,d0					; *24 'modulo' on table
	LEA	(A1,D0.W),A1
	move.l	a1,-(a7)
	lea	mp_level(a1),a0
	Bsr.s	PrintLevel				; Print level
;positions,enrgies,bullet track etc.
	Bsr	ResetNonStatic				
	Bsr	PrintStatsInit
	Bsr	PrintPlayers				; Print but also cycle ptrs
	Bsr	PrintBullets
	Bsr	PrintCurLevel
	bsr	swapcop
	bsr	DeleteBullets
	bsr	DeletePlayers
	bsr	DeleteBonus
	move.l	(a7)+,a1	
	Move.l	mp_cols(a1),plw.Cols(a5)
	moveq	#2,d0
	Bsr	FadeCols

	rts

*****
* Printlevel(a0=level ptr)
* Print level to both display buffers + hitmap
* ALL REGS PRESERVED
*****

Plev.offset	=	PLWIDB*BLOCKPHGT*NPL-PLWIDB+2
PHM.offset	=	PLWIDB*BLOCKPHGT-PLWIDB+2
PrintLevel
	push	d0-d7/a0-a4

	SBLITWAIT	a6,D7
	move.w	#0,bltamod(a6)
	move.w	#Plwidb-(Blockwwid*2),bltdmod(a6)
	move.l	#$09f00000,bltcon0(a6)	; straight A>D blit
	move.l	#-1,bltafwm(a6)

	move.l	a0,-(a7)				; Save for hitmap...
	Move.l	#SCREEN1,A1
	Move.l	#SCREEN2,A2
	Lea	Raw.MapBlks,a3				; Blittable block data
; Print level
	MOVE.W	#NUMVBLOCKS-1,D0
Printlevel_Vlp
	MOVE.W	#NUMHBLOCKS-1,D1
Printlevel_Hlp
	MOVE.W	(A0)+,D2				; Get block offset
	MULU	#NPL,D2
	Lea	(a3,d2.l),a4				; Block ptr
									; a1,a2 are dests - now blit!
	SBLITWAIT	a6,D7
	move.l	a4,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	#BLOCKBSIZE,bltsize(a6)
	SBLITWAIT	a6,D7					; Tile screen2
	move.l	a4,bltapth(a6)
	move.l	a2,bltdpth(a6)
	move.w	#BLOCKBSIZE,bltsize(a6)
	addq.l	#BLOCKWWID*2,a1					; Next pos along
	addq.l	#BLOCKWWID*2,a2
	dbra	d1,Printlevel_Hlp
	lea	Plev.Offset(a1),a1
	lea	Plev.Offset(a2),a2
	dbra	d0,Printlevel_Vlp
	move.l	(a7)+,a0

	Move.l	#HITPLANE,A1
	Lea	Raw.MapHits,a3				; Blittable block data
; Print levels hit map
	MOVE.W	#NUMVBLOCKS-1,D0
PrintHM_Vlp
	MOVE.W	#NUMHBLOCKS-1,D1
PrintHM_Hlp
	MOVE.W	(A0)+,D2				; Get block offset
	Lea	(a3,d2.l),a4				; Block ptr
									; a1,a2 are dests - now blit!
	SBLITWAIT	a6,D7
	move.l	a4,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	#HITBLOCKBSIZE,bltsize(a6)
	addq.l	#BLOCKWWID*2,a1					; Next pos along
	dbra	d1,PrintHM_Hlp
	lea	PHM.Offset(a1),a1
	dbra	d0,PrintHM_Vlp
	pop		d0-d7/a0-a4
	rts
	
*****
*InitSprites()
*Initialises all sprites used in game
*****
InitSprites
	lea	Player0_Bobs,a0
	Bsr	Initbob
	lea	Player1_Bobs,a0
	Bsr	Initbob
	lea	Player2_Bobs,a0
	Bsr	Initbob
	lea	Player3_Bobs,a0
	Bsr	Initbob

	lea	Player0_Bullets,a0
	Bsr	Initbob
	lea	Player1_Bullets,a0
	Bsr	Initbob
	lea	Player2_Bullets,a0
	Bsr	Initbob
	lea	Player3_Bullets,a0
	Bsr	Initbob

;Initialise all 9 BIG explosion frames!!!
	lea	Pexplode_bobs+b_len*0,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*1,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*2,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*3,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*4,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*5,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*6,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*7,a0
	Bsr	InitBob
	lea	Pexplode_bobs+b_len*8,a0
	Bsr	InitBob

	lea	Bexplode_bobs,a0
	Bsr	InitBob
	Lea	Bonus_bobs,a0
	Bsr	InitBob
	Lea	Shield_bobs,a0
	Bsr	Initbob
	rts


*****
* PrintStats()
* Prints players energies+gun power
*****
PrintStats
	lea	dectab,a1
	lea	font,a2

	lea	player0(a5),a4
	move.l	p.drawpl(a5),a0
	add.l	#ps_text2-ps_text,a0
	moveq	#0,d0
	move.w	p_energy(a4),d0
	bpl.s	PS_1
	moveq	#0,d0
PS_1	bsr	PSPerc
	add.l	#ps_text3-ps_text2-1,a0
	moveq	#0,d0
	move.w	p_bulletpow(a4),d0
	bsr.s	PSperc
	lea	player1(a5),a4
	lea	ps_text4-ps_text3-1(a0),a0
	moveq	#0,d0
	move.w	p_energy(a4),d0
	bpl.s	PS_2
	moveq	#0,d0
PS_2	bsr.s	PSperc
	addq.l	#ps_text5-ps_text4-1,a0
	moveq	#0,d0
	move.w	p_bulletpow(a4),d0
	bsr.s	PSperc
	cmp.w	#1,w.NumPlayers(a5)
	beq.S	Ps_Quit

	lea	player2(a5),a4
	move.l	p.drawpl(a5),a0
	lea	npl*plwidb*10(a0),a0
	add.l	#ps_text2-ps_text,a0
	moveq	#0,d0
	move.w	p_energy(a4),d0
	bpl.s	PS_3
	moveq	#0,d0
PS_3	bsr.s	PSPerc
	add.l	#ps_text3-ps_text2-1,a0
	moveq	#0,d0
	move.w	p_bulletpow(a4),d0
	bsr.s	PSperc

	cmp.w	#2,w.Numplayers(a5)
	beq.s	Ps_Quit
	lea	player3(a5),a4
	lea	ps_text4-ps_text3-1(a0),a0
	moveq	#0,d0
	move.w	p_energy(a4),d0
	bpl.s	PS_4
	moveq	#0,d0
PS_4	bsr.s	PSperc
	addq.l	#ps_text5-ps_text4-1,a0
	moveq	#0,d0
	move.w	p_bulletpow(a4),d0
	bsr.s	PSperc
PS_Quit	rts

PSPerc
	lsr.w	#3,d0					;Divide by 8 init
	divu	#10,d0					;By 10 from %ages
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a1,d0.w),d1
	swap	d0
	move.b	(a1,d0.w),d2
	sub.b	#32,d1
	sub.b	#32,d2
	lsl.w	#3,d1
	lsl.w	#3,d2

	lea	(a2,d1.w),a3
	bsr.s	PS_Dochr
	lea	(a2,d2.w),a3
	addq.l	#1,a0
PS_Dochr
	move.b	(a3)+,d3
	move.b	d3,(a0)
	move.b	d3,plwidb(a0)
	move.b	d3,2*plwidb(a0)
	move.b	d3,3*plwidb(a0)
	move.b	d3,4*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,5*plwidb(a0)
	move.b	d3,6*plwidb(a0)
	move.b	d3,7*plwidb(a0)
	move.b	d3,8*plwidb(a0)
	move.b	d3,9*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,10*plwidb(a0)
	move.b	d3,11*plwidb(a0)
	move.b	d3,12*plwidb(a0)
	move.b	d3,13*plwidb(a0)
	move.b	d3,14*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,15*plwidb(a0)
	move.b	d3,16*plwidb(a0)
	move.b	d3,17*plwidb(a0)
	move.b	d3,18*plwidb(a0)
	move.b	d3,19*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,20*plwidb(a0)
	move.b	d3,21*plwidb(a0)
	move.b	d3,22*plwidb(a0)
	move.b	d3,23*plwidb(a0)
	move.b	d3,24*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,25*plwidb(a0)
	move.b	d3,26*plwidb(a0)
	move.b	d3,27*plwidb(a0)
	move.b	d3,28*plwidb(a0)
	move.b	d3,29*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,30*plwidb(a0)
	move.b	d3,31*plwidb(a0)
	move.b	d3,32*plwidb(a0)
	move.b	d3,33*plwidb(a0)
	move.b	d3,34*plwidb(a0)
	move.b	(a3)+,d3
	move.b	d3,35*plwidb(a0)
	move.b	d3,36*plwidb(a0)
	move.b	d3,37*plwidb(a0)
	move.b	d3,38*plwidb(a0)
	move.b	d3,39*plwidb(a0)
	rts

PrintStatsInit
	move.l	#screen1,a0
	lea	PS_text,a1
	bsr.s	PS_Textrt
	move.l	#screen1+plwidb*npl*10,a0
	lea	PS_text,a1
	bsr.s	PS_Textrt

	move.l	#screen2,a0
	lea	PS_text,a1
	bsr.s	PS_Textrt
	move.l	#screen2+plwidb*npl*10,a0
	lea	PS_text,a1
	bsr.s	PS_Textrt
	rts
PrintCurLevel
	lea	dectab,a1
	lea	font,a2
	MOVE.L	#screen1+19+(5*plwidb*npl),a0
	moveq	#0,d0
	move.w	w.curlevel(a5),d0
	addq.w	#1,d0
	lsl.w	#3,d0
	bsr	psperc

	MOVE.L	#screen2+19+(5*plwidb*npl),a0
	moveq	#0,d0
	move.w	w.curlevel(a5),d0
	addq.w	#1,d0
	lsl.w	#3,d0
	bsr	psperc
	
	rts

PS_Textrt
	lea	font,a2
PS_Textlp
	moveq	#0,d3
	move.b	(a1)+,d3
	beq.s	PS_textfin1
	sub.b	#32,d3
	lsl.w	#3,d3
	lea	(a2,d3.w),a3
	bsr	PS_DOChr
	addq.l	#1,a0
	bra.s	PS_Textlp
PS_textfin1
	rts


dectab	dc.b	'0123456789'
PS_Text
	dc.b	'ENERGY %'
PS_Text2	dc.b	'00 GUN %'
PS_Text3	dc.b	'00    ENERGY %'
PS_Text4	dc.b	'00 GUN %'
PS_text5	dc.b	'00',0
	even

*****
* PrintPlayers()
* Prints both players (explosions implemented!)
*****
PrintPlayers
	lea	player0(a5),a4
	move.w	w.NumPlayers(a5),d7
PP_lp
	cmp.b	#DEAD,p_state(a4)
	beq.s	PP_NoP
	cmp.b	#DYING,p_state(a4)
	beq.s	PP_NICHK
	cmp.w	#PB_INVIS,p_bonussig(a4)
	beq.s	PP_Nop
PP_NIChk
	Bsr.s	PPlayer
PP_NoP	lea	p_len(a4),a4
	dbra	d7,pp_lp
	rts

PPlayer								; Printplayer at a4
	cmp.b	#DYING,p_state(a4)		; Player exploding?
	beq.s	PPlayer_Exploding
	move.l	p.drawpl(a5),a1
	move.l	p_save1(a4),a2
	move.w	p_xpos(a4),d0
	move.w	p_ypos(a4),d1
	move.l	p_sprptr(a4),a0
	move.w	p_facedir(a4),d2	
	bsr	DoBob
	cmp.w	#PB_SHIELD,p_bonussig(a4)
	beq.s	PP_Shielded
	rts
PP_Shielded
	moveq	#0,d2					; No offset!
	move.l	d2,a2					; No save!
	lea	Shield_bobs,a0
	bra	DoBob

PPlayer_exploding
	move.l	p.drawpl(a5),a1
	move.l	p_save1(a4),a2
	move.w	p_xpos(a4),d0
	move.w	p_ypos(a4),d1
	subq.w	#8,d0					; always 32 width...
	addq.w	#8,d1					; y centre of tank

	lea	Pexplode_bobs,a0
	moveq	#0,d2
	move.b	p_diecnt(a4),d2
	divu	#explospeed,d2
	mulu	#b_len,d2
	add.l	d2,a0					; Get bob frame
	move.w	B_hgt(a0),d2
	asr.w	#1,d2					; .5 hgt offset
	sub.w	d2,d1

	moveq	#0,d2					; No bitmap offset
	bra	Dobob

*****
* PrintBullets()
* Prints bullets for all players
*****
PrintBullets
	lea	player0(a5),a4
	move.w	w.NumPlayers(a5),d6
PB_lp	bsr.s	PB_player
	lea	p_len(a4),a4
	dbra	d6,PB_lp
	rts

PB_player
	lea	p_bullets(a4),a3
	move.w	w.MaxBullets(a5),d7
PB_lp0
	cmp.b	#DEAD,bl_sig(a3)
	beq.s	PB_Dead0
	bsr.s	PBullets
PB_Dead0
	lea	Bullet_len(a3),a3
	dbra	d7,PB_lp0
	rts

PBullets							; Print bullet at a3
	cmp.b	#DYING,bl_sig(a3)
	beq.s	PBullets_Burn
	move.l	bl_sprptr(a3),a0
	move.l	p.drawpl(a5),a1
	move.l	bl_save1(a3),a2
	move.w	bl_xpos(a3),d0
	move.w	bl_ypos(a3),d1
	moveq	#0,d2
	bra	DoBob

PBullets_Burn
	move.l	p.drawpl(a5),a1
	move.l	bl_save1(a3),a2
	move.w	bl_xpos(a3),d0
	move.w	bl_ypos(a3),d1
	lea	Bexplode_bobs,a0
	moveq	#0,d2
	move.b	bl_explo(a3),d2			; Explosion counter
;	divu	#Bexplospeed,d2			; Get no
;	and.l	#$ffff,d2
;	add.w	d2,d2
;
	and.b	#%11111110,d2			;divu 2 , mulu 2
;
	bra	Dobob
	
*****
* DeletePlayers()
* Removes p_save2,exchanges p_save1/2
*****
DeletePlayers
	move.w	w.NumPlayers(a5),d7
	move.w	d7,d6
	add.w	d6,d6
	move.w	DPOff(PC,D6.W),D6
	LEA	PLAYER0(A5),A4
	LEA	(A4,D6.W),A4				; Get player!	
DP_lp
	move.l	p_save2(a4),a2			; Exchange screen ptrs
	move.l	p_save1(a4),p_save2(a4)
	move.l	a2,p_save1(a4)
	bsr	RecoBob	
	lea	-p_len(a4),a4
	dbra	d7,DP_lp
	rts
;table with offsets for each player: for reverse order deletions!
DPoff	dc.w	0,P_len,p_len*2,p_len*3

*****
* DeleteBullets()
* Removes bl_save2 ,exchages save addr - ***ignores*** bulletcnt for framing
*****
DeleteBullets
	move.w	w.NumPlayers(a5),d6
	move.w	d6,d5
	add.w	d5,d5
	move.w	DPOff(PC,D5.W),D5
	LEA	PLAYER0(A5),A4
	LEA	(a4,D5.W),a4			; Get player!	
DB_lp
	bsr.s	DB_Player
	lea	-P_len(a4),a4
	dbra	d6,db_lp
	rts

DB_Player
	move.w	w.MaxBullets(a5),d7
	move.w	d7,d5
	add.w	d5,d5
	move.w	DBOffList(PC,d5.w),d5
	lea	p_bullets(a4,d5.w),a3
DB_lp1								; Exchange ptrs, call bob rt!
	move.l	bl_save2(a3),a2
	move.l	bl_save1(a3),bl_save2(a3)
	move.l	a2,bl_save1(a3)
	bsr	Recobob
	lea	-Bullet_len(a3),a3
	dbra	d7,DB_lp1
	rts
DBOffList	dc.w	0,bullet_len,bullet_len*2,bullet_len*3,bullet_len*4
			dc.w	bullet_len*5,bullet_len*6,bullet_len*7

*****
* WaitVBL()
* Wait for VBL to pass by
* INT CODE MUST BE RUNNING!
*****
WaitVBL
	IFD	RUNTIME
	move.w	d0,-(a7)
	move.w	l.VBLCounter+2(a5),d0
WaitVBL_1
	cmp.w l.VBLCounter+2(a5),d0
	beq.s WaitVBL_1
	move.w (a7)+,d0
	ENDC
	IFND RUNTIME
	CATCHPOS	A6,200
	ENDC
	rts

*****
* showd0(d0,d1,d2)
* d0 = value to show
* d1 = x pos
* d2 = y pos
* d3 = colour
* a5 = my vars
* all regs preserved
*****
showd0
	movem.l	d0-d4/d7/a0,-(sp)
	move.l	p.drawpl(a5),a0
	moveq	#31,d3				; colour
	mulu	#PLWIDB*NPL,d2
	add.l d2,a0
	add.w d1,a0 				; where to start plotting chars
	moveq #8,d7 				; 8 chars per longword
	bra.s showd0_a
showd0_l
	rol.l #4,d0 				; get digits in sequence
	move.w	d0,d4
	and.w #%1111,d4				; ensure range 0-F hex
	move.b	HexTab(pc,d4.w),d4
	Bsr.s	PrChar
	addq.l	#1,a0 				; next char position along
showd0_a
 	dbra	d7,showd0_l
	movem.l	(sp)+,d0-d4/d7/a0
	rts

Hextab
	dc.b	"0123456789ABCDEF"
	even

*****
*Put a char(a0=destbpl d3=col d4=ascii)
*DOES-NOT PRESERVE BACKGROUND!
*all regs preserved
*****
PRChar
	movem.l	d2/d4-d6/a0-a1,-(a7)
	sub.b	#32,d4
	lsl.w #3,d4 					; as index into char table
	lea	font,a1
	add.w d4,a1 					; get char bit pattern ptr
	move.w	d3,d2
	moveq	#8-1,d5					; 8 Height
PrCharolp
	move.b	(a1)+,d6
	moveq	#npl-1,d4
PrCharilp
	btst	#0,d3
	beq.s	PRChar2
	move.b	d6,(a0)					; plane is set
	bra.s	PrChar3
PRChar2
	clr.b	(a0)					; nuke plane location
PrChar3
	lea	plwidb(a0),a0
	ror.w	#1,d3
	dbra	d4,PrCharilp
	move.w	d2,d3
	dbra	d5,Prcharolp
	movem.l	(a7)+,d2/d4-d6/a0/a1
	rts

*****
*InitBob(Ptr)(a0)
*Initialise a bob
*****
InitBob
	PUSH	A0/D0
	tst.b	B_InitSig(a0)			; Init already ?
	bne.s	InitBob_Done
	cmp.b	#1,B_Options(a0)		; Need to calc mask ?
	bne.s	InitBob_maskok
	bsr.s	MakeBobMask
	move.b	#0,B_Options(a0)		; Now have a mask
InitBob_maskok
	move.w	#Plwidb,d0
	sub.w	B_WWid(a0),d0
	sub.w	B_WWid(a0),d0
	move.w	d0,B_CMod(a0)			; Save standard modulo...
	move.w	B_SMod(a0),B_CRMod(a0)	; Reset modulo for COOKIES!
	subq.w	#2,B_CRMod(a0)
	move.w	B_Hgt(a0),d0			; Calc bsize...
	mulu	#64*npl,d0				; BHGT
	add.w	B_Wwid(a0),d0
	move.w	d0,B_CBSize(a0)


	move.w	B_hgt(a0),d0
	lsl.w	#6,d0
	add.w	B_WWid(a0),d0			; New Bltsize
	move.w	d0,B_CSHBSize(a0)

	move.w	B_WWid(a0),d0			; Extra width+wordswidth+1
	subq.w	#1,d0
	add.w	d0,d0					; Bytes wid of bli part
	add.w	B_SMod(a0),d0			; Calc bobs *total* byte width
	mulu	#npl-1,d0
	add.w	B_CRMod(a0),d0
	move.w	d0,B_CSHMod(a0)
	
	Tst.l	b_hitmap(a0)
	bne.s	IB_Hitset
	MOVE.L	B_Mask(a0),B_Hitmap(a0)
IB_Hitset
	st	b_initsig(a0)
InitBob_done
	POP	A0/D0
	rts

*****
*MakeBobmask(ptr) (a0)
*Calc mask for bob
*****
MakeBobMask
;	movem.l	a1/a2/d0-d5,-(a7)
;	move.w	B_Smod(a0),d0
;	add.w	B_Bwid(a0),d0			; d0= width,bytes
;	move.w	d0,d1
;	mulu	#npl-1,d1				; d1=modulo for each plane of mask
;	move.l	B_BMap(a0),a1			; Source
;	move.l	B_Mask(a0),a2			; Dest

;	move.w	B_Hgt(a0),d5
;	subq.w	#1,d5
;MBM_hgtlp
;	move.w	d0,d2					; Do a line of mask...
;	subq.w	#1,d2
;MBM_widlp
;	moveq	#0,d3
;	moveq	#0,d4					; Offset count
;	rept	npl
;	or.b	(a1,d4.w),d3			; add to set bits
;	add.w	d0,d4					; next plane
;	endr

;	moveq	#0,d4					; Offset count
;	rept	npl
;	move.b	d3,(a2,d4.w)
;	add.w	d0,d4
;	endr
;	addq.l	#1,a1
;	addq.l	#1,a2
;	dbra	d2,MBM_widlp
;	lea	(a1,d1.w),a1
;	lea	(a2,d1.w),a2
;	dbra	d5,MBM_hgtlp
;	movem.l	(a7)+,a1/a2/d0-d5
	rts

*****
*DoBob(Ptr,Screen,Save,x,y,offset)(a0 a1 a2 d0 d1 d2)
*Save screen portion to save if a2 nz
*Blit bob at ptr to screen *no clipping*
*****
DoBob
	MOVEM.L	D0-D3/A1-A3,-(A7)
	move.w	d0,d3
	lsr.w	#3,d3					; No. bytes
	lea	(a1,d3.w),a1

;	mulu	#plwidb*npl,d1			; Y offset Offset in plane
;lea etc.
	add.w d1,d1						; *4 table...
	add.w d1,d1
	add.l lw.plmultab(A5,d1.w),a1	; Dest for bob!

	and.w	#%1111,d0
	ror.w	#4,d0					; Bltcon value...

	move.l  a2,d1
;	cmp.l	#0,a2					; Saving ?
	beq.s	DoBob_NoSave

;	tst.l	(a2)
;	beq.s	testok
;	move.l	d4,-(a7)
;	move.w	#-1,d4
;tlp	move.w	d4,color00(a6)
;	dbra	d4,tlp
;	move.l	(a7)+,d4
;testok

	move.l	a0,(a2)+				; Save bob struct address
	Move.l	a1,(a2)+				; Save address
	SBLITWAIT	a6,D3					; Now do save
	Move.l	a1,bltapth(a6)
	move.l	a2,bltdpth(a6)
	move.w	B_CMod(a0),bltamod(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$09f00000,bltcon0(a6)	; A>D blit
	move.l	#-1,bltafwm(a6)
	move.w	B_CBSize(a0),BltSize(a6)
DoBob_Nosave
	move.w	d0,d1
	or.w	#$0fca,d0
	move.l	B_Mask(a0),a2			; A ptr Mask data
	move.l	B_BMap(a0),a3		    ; B ptr GFX data
	lea	(a2,d2.w),a2
	lea	(a3,d2.w),a3
									; D ptr is a1
	SBLITWAIT	a6,D3
	move.l	a2,bltapth(a6)			; Mask
	move.l	a3,bltbpth(a6)			; SRC
	move.l	a1,bltcpth(a6)			; Dest
	move.l	a1,bltdpth(a6)
	move.w	B_CRMod(a0),bltamod(a6)
	move.w	B_CRMod(a0),bltbmod(a6)
	move.w	B_CMod(a0),bltcmod(a6)
	move.w	B_CMod(a0),bltdmod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d1,bltcon1(a6)
	move.l	#$ffff0000,bltafwm(a6)	; No last word!
	move.w	B_CBSize(a0),bltsize(a6)
	MOVEM.L	(SP)+,D0-D3/A1-A3
	rts

*****
*RecoBob(Save)(a2)
*Recover screen portion at save *no clipping*
*Safe: if (a2)=0 then abort!
*A0-A2,D0 SCRUNGED
*****
RecoBob
	tst.l	(a2)
	beq.s	RecoBob_Abort
	SBLITWAIT	a6,D0
	move.l	(a2),a0					; Recover save struct+addr
	clr.l	(a2)+					; Nuke for safety
	move.l	(a2)+,a1
	move.l	a1,bltdpth(a6)
	move.l	a2,bltapth(a6)
	move.l	#$09f00000,bltcon0(a6)	; A>D blit
	move.l	#-1,bltafwm(a6)
	move.w	B_CMod(a0),bltdmod(a6)
	move.w	#0,bltamod(a6)
	move.w	B_CBsize(a0),bltsize(a6)
RecoBob_Abort	
	rts

;HARD CODED IN JOY ROUTINE!!! DO NOT MODIFY!!!!
		rsreset
RIGHT	rs.b	1
LEFT	rs.b	1
DOWN	rs.b	1
UP		rs.b	1
FIRE	rs.b	1
;!!!!!
*****
* ReadPort()
* read 4 player adaptor, save results...
*****
ReadPort
	MOVE.B	#0,CIAADDRB
	BCLR	#0,CIABDDRA
	BCLR	#2,CIABDDRA
	MOVE.B	CIAAPRB,D0
	LSL.B	#1,D0
	SCC	P4R1(A5)
	LSL.B	#1,D0
	SCC	P4L1(A5)
	LSL.B	#1,D0
	SCC	P4D1(A5)
	LSL.B	#1,D0
	SCC	P4U1(A5)
	LSL.B	#1,D0
	SCC	P4R2(A5)
	LSL.B	#1,D0
	SCC	P4L2(A5)
	LSL.B	#1,D0
	SCC	P4D2(A5)
	LSL.B	#1,D0
	SCC	P4U2(A5)
	MOVE.B	CIABPRA,D0
	BTST	#0,D0
	SEQ	P4F1(A5)
	BTST	#2,D0
	SEQ	P4F2(A5)
	rts

*****
* Rjoy3()
* Return d0=joycode
* Process result of ReadPort : 4PLAYER ADAPTOR II
* Code by P.Kent!
*****
;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement
;   bit 4 set = fire!
RJoy3
	moveq	#0,d0
	tst.b	p4r2(a5)
	beq.s	rj3_nr
	or.w	#1,d0
rj3_nr
	tst.b	p4l2(a5)
	beq.s	rj3_nl
	or.w	#2,d0
rj3_nl
	tst.b	p4d2(a5)
	beq.s	rj3_nd
	or.w	#4,d0
rj3_nd
	tst.b	p4u2(a5)
	beq.s	rj3_nu
	or.w	#8,d0
rj3_nu
	tst.b	p4f2(a5)
	beq.s	rj3_nf
	or.w	#16,d0
rj3_nf
	rts

*****
* Rjoy2()
* Return d0=joycode
* Process result of ReadPort : 4PLAYER ADAPTOR I
* Code by P.Kent!
*****
;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement
;   bit 4 set = fire!
RJoy2
	moveq	#0,d0
	tst.b	p4r1(a5)
	beq.s	rj2_nr
	or.w	#1,d0
rj2_nr
	tst.b	p4l1(a5)
	beq.s	rj2_nl
	or.w	#2,d0
rj2_nl
	tst.b	p4d1(a5)
	beq.s	rj2_nd
	or.w	#4,d0
rj2_nd
	tst.b	p4u1(a5)
	beq.s	rj2_nu
	or.w	#8,d0
rj2_nu
	tst.b	p4f1(a5)
	beq.s	rj2_nf
	or.w	#16,d0
rj2_nf
	rts	
*****
* Rjoy1()
* Return d0=joycode
* READ JOYSTICK IN PORT 1 ("JOYSTICK PORT")
* Code by M.Meany
*****
;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement
;   bit 4 set = fire!

RJoy1
	movem.l	d1/d2,-(a7)
	moveq.l		#0,d0			clear
	move.l		d0,d2
	move.w		JOY1DAT(a6),d0		read stick
	btst		#1,d0			right ?
	beq.s		Rj1.test_left		if not jump!
	or.w		#1,d2			set right bit
Rj1.test_left
	btst		#9,d0			left ?
	beq.s		Rj1.test_updown		if not jump
	or.w		#2,d2			set left bit
Rj1.test_updown	move.l		d0,d1			copy JOY1DAT
	lsr.w		#1,d1			shift u/d bits
	eor.w		d1,d0			exclusive or 'em
	btst		#0,d0			down ?
	beq.s		Rj1.test_down		if not jump
	or.w		#4,d2			set down bit
Rj1.test_down	btst		#8,d0			up ?
	beq.s		Rj1.no_joy			if not jump
	or.w		#8,d2			set up bit
Rj1.no_joy
	btst	#7,ciaapra
	bne.s	Rj1.no_fire
	or.w		#16,d2
Rj1.no_fire
	move.w	d2,d0
	movem.l	(a7)+,d1/d2
	rts

*****
* Rjoy0()
* Return d0=joycode
* READ JOYSTICK IN PORT 0 ("MOUSE PORT")
*****
;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement
;   bit 4 set = fire!

RJoy0
	movem.l	d1/d2,-(a7)
	moveq.l		#0,d0			clear
	move.l		d0,d2
	move.w		JOY0DAT(a6),d0	read stick
	btst		#1,d0			right ?
	beq.s		Rj0.test_left	if not jump!
	or.w		#1,d2			set right bit
Rj0.test_left
	btst		#9,d0			left ?
	beq.s		Rj0.test_updown	if not jump
	or.w		#2,d2			set left bit
Rj0.test_updown
	move.l		d0,d1			copy JOY1DAT
	lsr.w		#1,d1			shift u/d bits
	eor.w		d1,d0			exclusive or 'em
	btst		#0,d0			down ?
	beq.s		Rj0.test_down	if not jump
	or.w		#4,d2			set down bit
Rj0.test_down
	btst		#8,d0			up ?
	beq.s		Rj0.no_joy		if not jump
	or.w		#8,d2			set up bit
Rj0.no_joy
	btst		#6,ciaapra
	bne.s		Rj0.no_fire
	or.w		#16,d2
Rj0.no_fire
	move.w	d2,d0
	movem.l	(a7)+,d1/d2
	rts

*****
* RKBDPX
* Read keyboard for players
*****
RKBDP0
	Lea lb.Kbdp0,a0
	bra.S PRKBD
lb.Kbdp0
	dc.b $31,$32,$10,$20,$63
	even
RKBDP1
	Lea lb.Kbdp1,a0
	bra.S PRKBD
lb.Kbdp1
	dc.b	$2d,$2f,$3e,$1e,$43
	even
*****
* PRKBD(list a0)
* Read keyboard for keys specified (LRUDF)
* Return d0=bits as rjoy routines
* scrunges a1,d1,a0 already scrunged
*****
PRKBD
	Lea KeyMap,a1
	MOVEQ	#0,D0
	MOVEQ	#0,D1

	move.b (a0)+,d1
	tst.b (a1,d1.w)
	beq.s PRKBD_NO1
	or.w	#2,D0					;L
PRKBD_NO1
	move.b (a0)+,d1
	tst.b (a1,d1.w)
	beq.s PRKBD_NO2
	or.w	#1,D0					;R
	and.b	#%11111101,d0
PRKBD_NO2	move.b (a0)+,d1
	tst.b (a1,d1.w)
	beq.s PRKBD_NO3
	or.w	#8,D0					;U
PRKBD_NO3	move.b (a0)+,d1
	tst.b (a1,d1.w)
	beq.s PRKBD_NO4
	or.w	#4,D0					;D
	and.b	#%11110111,d0	
PRKBD_NO4	move.b (a0)+,d1
	tst.b (a1,d1.w)
	beq.s PRKBD_NO5
	or.w	#16,D0
PRKBD_NO5	RTS	

*****
*Swap copper ptrs in copper list
*****
SwapCop
	MOVE.L	p.ShowPl(a5),a1
	MOVE.L	p.DrawPl(a5),a0
	MOVE.L	A0,p.Showpl(a5)
	MOVE.L	A1,p.Drawpl(a5)
	Lea	CopPls,a1
	moveq	#npl-1,d1
	moveQ	#plwidb,d2
	move.l	a0,d0
SwapCoplp
	move.w	d0,4(a1)				; Low word
	swap	d0
	move.w	d0,(a1) 				; High word
	swap	d0
	add.l 	d2,d0
	addq.l	#8,a1
	dbra	d1,SwapCoplp
	RTS


*****
*Fade Colours into copper,d0=framing rate
*****
FadeCols
	movem.l	d1-d4/a1,-(a7)
	move.l	d0,d2
FC_olp
	Lea	CopCols,a0
	move.l	plw.Cols(a5),a1
	move.w	#Numcols-1,d4			; Counter
	moveq	#0,d3					; number of colours the same
FC_ilp
	move.w	(a0),d0					; Cur col
	move.w	(a1)+,d1
	cmp.w	d0,d1
	bne.s	FC_NSame
	addq.w	#1,d3					; add to no matches
	bra.s	Fc_nxt
FC_NSAME
	BSR.S	Fader
	move.w	d0,(a0)					; Save new colour
Fc_nxt	Addq.l	#4,a0
	Dbra	d4,FC_ilp				; Repeat for all colours
	cmp.w	#numcols,d3				; done ?
	beq.s	FC_DoneAll
	move.w	d2,d3
FC_Pauselp
	BSR	WAITVBL						; NB scrunges d0
	dbra	d3,FC_Pauselp
	BRA.S	FC_olp
FC_DoneAll
	movem.l (a7)+,d1-d4/a1
	RTS

*****
*Intelligent fade routine d0 cur col,d1 dest col returns d0=faded
*****
Fader
	CMP.W	D0,D1
	BEQ.S	FADER_DONE
	MOVEM.W D1-D6,-(SP)
	MOVE.W  D1,D2   			; d1-3 : dest values
	MOVE.W  D1,D3
	MOVE.W  D0,D4   			; d4-6 Init values
	MOVE.W  D0,D5
	MOVE.W  D0,D6
	AND.W   #$00F,D1  			; D1-3 B-G-R
	AND.W   #$0F0,D2
	AND.W   #$F00,D3
	AND.W   #$00F,D4  			; d4-6 B-G-R
	AND.W   #$0F0,D5
	AND.W   #$F00,D6
	CMP.W   D4,D1
	BCC.S   Blue_NOTdown
	SUBQ.W  #1,D4
Blue_NOTdown
	CMP.W   D4,D1
	BLS.S   Blue_Fin
	ADDQ.W  #1,D4
Blue_Fin
	CMP.W   D5,D2
	BCC.S   Green_NOTdown
	SUB.W   #$010,D5
Green_NOTdown
	CMP.W   D5,D2
	BLS.S   Green_Fin
	ADD.W   #$010,D5
Green_Fin
    CMP.W   D6,D3
	BCC.S   Red_NOTdown
	SUB.W   #$100,D6
Red_NOTdown
	CMP.W   D6,D3
	BLS.S   REd_FIn
	ADD.W   #$100,D6
REd_FIn
	MOVE.W  D4,D0   			; -> d0 is finished value...
	OR.W    D5,D0
	OR.W    D6,D0
	MOVEM.W (SP)+,D1-D6
FADER_DONE
	RTS

*************************************************************************************
* Converts a Hexdecimal longword into ASCII decimal text
* ------------------------------------------------------
*
* a0 = ASCII Output buffer ( After conversion will hold decimal number in ASCII )
* d0 = Hex Longword to Convert
*
*************************************************************************************
 
getdecimal
		movem.l	d0-d5/a0-a1,-(a7)
		move.b	#" ",d5			; replace leading zero's with spaces
		lea	hextable(pc),a1

		move.w	#8,d4

ccloop		move.l	(a1)+,d1
		cmp.l	d1,d0
		bcs.s	get3
 
		move.w	#32-1,d3
		moveq.l	#0,d2
get1		asl.l	#1,d0
		roxl.l	#1,d2
		cmp.l	d1,d2
		bcs.s	get2
 
		sub.l	d1,d2
		addq.l	#1,d0
get2		dbra	d3,get1
	 
		add.b	#48,d0
		move.b	d0,(a0)+
		move.l	d2,d0
		move.b	#48,d5
		bra.s	get4
 
get3		move.b	d5,(a0)+
get4		dbra	d4,ccloop
 
		add.b	#48,d0
		move.b	d0,(a0)+
		movem.l	(a7)+,d0-d5/a0-a1
		rts

hextable	dc.l	1000000000
		dc.l	100000000
		dc.l	10000000
		dc.l	1000000
		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10

	SECTION	TANXS_CHIPSTUFF,DATA_C
;All chip datas here!
*****
*Copper list for main program
*****
MY_Copper
	dc.w	diwstrt,$2C81,diwstop,$2CC1
	dc.w	ddfstrt,$38,ddfstop,$D0,bplcon0
	IFND	GENLOCK
	dc.w	BPU2!BPU0!COLOR
	ENDC
	IFD	GENLOCK
	DC.W	BPU2!BPU0!COLOR!ERSY
	ENDC
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,PLWIDB*(NPL-1)+2,bpl2mod,PLWIDB*(NPL-1)+2

	dc.w	COLOR00
CopCols	dc.w	0,COLOR01,0,COLOR02,0,COLOR03,0,COLOR04,0
	DC.W	COLOR05,0,COLOR06,0,COLOR07,0,COLOR08,0	
	DC.W	COLOR09,0,COLOR10,0,COLOR11,0,COLOR12,0
	DC.W	COLOR13,0,COLOR14,0,COLOR15,0,COLOR16,0
	DC.W	COLOR17,0,COLOR18,0,COLOR19,0,COLOR20,0
	DC.W	COLOR21,0,COLOR22,0,COLOR23,0,COLOR24,0
	DC.W	COLOR25,0,COLOR26,0,COLOR27,0,COLOR28,0
	DC.W	COLOR29,0,COLOR30,0,COLOR31,0

	dc.w	bpl1pth
CopPls	dc.w	0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0,bpl4pth,0,bpl4ptl,0
	dc.w	bpl5pth,0,bpl5ptl,0
	dc.w	$ffdf,$fffe
	dc.w	$2c09,$fffe,intreq,setit!coper	
	dc.w	$FFFF,$FFFE

Raw.MapBlks	INCBIN	GFX/StuMapTiles.IBlock	; Interleaved map tiles.
MAXMAPBLOCKS =  (*-Raw.MapBlks)/(2*16*5)
Raw.MapHits	INCBIN	GFX/StuMapTiles.HitMap	; Hit map tiles...
lw.Map1Cols	INCBIN	GFX/MapTiles.ColMap	;Colour maps for levels.

;BOB STRUCTS +GFX HERE!
Player0_Bobs
	dc.w	0
	dc.w	1+1,18,14
	dc.l	PlayerBMap+0*18*16*5,PlayerMask	
	ds.w	5
	dc.l	PlayerHitmap
Player1_Bobs
	dc.w	0
	dc.w	1+1,18,14
	dc.l	PlayerBMap+1*18*16*5,PlayerMask	
	ds.w	5
	dc.l	PlayerHitmap
Player2_Bobs
	dc.w	0
	dc.w	1+1,18,14
	dc.l	PlayerBMap+2*18*16*5,PlayerMask	
	ds.w	5
	dc.l	PlayerHitmap
Player3_Bobs
	dc.w	0
	dc.w	1+1,18,14
	dc.l	PlayerBMap+3*18*16*5,PlayerMask	
	ds.w	5
	dc.l	PlayerHitmap

PlayerMask	INCBIN	GFX/TESTTANK.IMASK
PlayerBMap	INCBIN	GFX/MULTITANKS.IRAW
PlayerHitmap	INCBIN	GFX/TESTTANK.HITMAP

PExplode_Bobs
;Frame 1
	dc.w	0
	dc.w	2+1,255-243,0
	dc.l	PlayerEMap,PExploMask	
	ds.w	5
	dc.l	0
; Frame 2
	dc.w	0
	dc.w	2+1,243-223,0
	dc.l	PlayerEMap+(255-243)*4*5,PExploMask+(255-243)*4*5
	ds.w	5
	dc.l	0
; Frame 3
	dc.w	0
	dc.w	2+1,223-199,0
	dc.l	PlayerEMap+(255-223)*4*5,PExploMask+(253-223)*4*5
	ds.w	5
	dc.l	0
; Frame 4
	dc.w	0
	dc.w	2+1,199-171,0
	dc.l	PlayerEMap+(255-199)*4*5,PExploMask+(255-199)*4*5
	ds.w	5
	dc.l	0
; Frame 5
	dc.w	0
	dc.w	2+1,171-139,0
	dc.l	PlayerEMap+(255-171)*4*5,PExploMask+(255-171)*4*5
	ds.w	5
	dc.l	0
; Frame 6
	dc.w	0
	dc.w	2+1,139-107,0
	dc.l	PlayerEMap+(255-139)*4*5,PExploMask+(255-139)*4*5
	ds.w	5
	dc.l	0
; Frame 7
	dc.w	0
	dc.w	2+1,107-75,0
	dc.l	PlayerEMap+(255-107)*4*5,PExploMask+(255-107)*4*5
	ds.w	5
	dc.l	0
; Frame 8
	dc.w	0
	dc.w	2+1,75-43,0
	dc.l	PlayerEMap+(255-75)*4*5,PExploMask+(255-75)*4*5
	ds.w	5
	dc.l	0
; Frame 9
	dc.w	0
	dc.w	2+1,43-11,0
	dc.l	PlayerEMap+(255-43)*4*5,PExploMask+(255-43)*4*5
	ds.w	5
	dc.l	0

PExploMask	INCBIN	GFX/NEWTEXPLO.IMASK
PlayerEMap	INCBIN	GFX/NEWTEXPLO.IRAW

PlayerSave_len	=	2*3*32*5+8

Player0_Bullets						; Init bob routine catches 2nd inits!
	dc.w	0
	dc.w	1+1,6,0
	dc.l	BulletBMap,BulletMask
	ds.w	5
	dc.l	0
Player1_bullets
	dc.w	0
	dc.w	1+1,6,0
	dc.l	BulletBMap+1*7*5*2,BulletMask
	ds.w	5
	dc.l	0
Player2_bullets
	dc.w	0
	dc.w	1+1,6,0
	dc.l	BulletBMap+2*7*5*2,BulletMask
	ds.w	5
	dc.l	0
Player3_bullets
	dc.w	0
	dc.w	1+1,6,0
	dc.l	BulletBMap+3*7*5*2,BulletMask
	ds.w	5
	dc.l	0

BulletBMap	INCBIN	GFX/MultiBullets.Iraw
BulletMask	INCBIN	GFX/Bullets.Imask

Bexplode_bobs
	dc.w	0
	dc.w	1+1,7,12-2
	dc.l	EBulletBMap,EBulletMask
	ds.w	5
	dc.l	0

EBulletBMap	INCBIN	GFX/Bullexplo.Iraw
EBulletMask	INCBIN	GFX/Bullexplo.Imask

BulletSave_len	=	2*2*7*5+8		;2 bt / wd*wd save wid*hgt*npl +2 lw ptrs

Bonus_Bobs
	dc.w	0
	dc.w	1+1,16,8
	dc.l	BonusBMAP,BonusMask
	ds.w	5
	dc.l	0
BonusBMAP	INCBIN	GFX/Bonus.Iraw
BonusMask	INCBIN	GFX/Bonus.IMask

Shield_Bobs
	dc.w	0
	dc.w	1+1,18,0
	dc.l	ShieldBMap,ShieldBMap
	ds.w	5
	dc.l	0
ShieldBMAP	INCBIN	GFX/Shield.Iraw

;FOR DISPLAY FX!!!
;MenuBlocks_Bobs	;32 pixels height:full>blank over 9 frames total!
;	dc.w	0
;	dc.w	2+1,32,(9-1)*4
;	dc.l	MenuBlocksBMap,MenuBlocksMask
;	ds.w	5
;	dc.l	0
;MenuBlocksBMAP	incbin	gfx/menublocks.iraw
;MenuBlocksmask
;	rept	32
;	dcb.l 9*3,-1
;	dcb.l 9*2,0
;	endr
	
	IFD	SMPI
BLANKSAMPLE	DS.W	2				; 0 sample for PLAYSND
SMPI_BOOM1	INCBIN	SOUND/BOOM1.SMPI
SMPI_SHOT1	INCBIN	SOUND/SHOT1.SMPI
SMPI_SHOT3	INCBIN	SOUND/SHOT3.SMPI
SMPI_RELOAD1	INCBIN	SOUND/RELOAD1.SMPI
SMPI_RELOAD2	INCBIN	SOUND/RELOAD2.SMPI
SMPI_SCALE.SHORT	INCBIN	SOUND/SCALE.SHORT.SMPI
SMPI_SMALLEXPLOD	INCBIN	SOUND/SMALLEXPLOD.SMPI

	ENDC
	SECTION	TANX_VIEWS,BSS_C
PLAYER0_SAVE1	ds.b	PlayerSave_len
PLAYER0_SAVE2	ds.b	PlayerSave_len
PLAYER1_SAVE1	ds.b	PlayerSave_len
PLAYER1_SAVE2	ds.b	PlayerSave_len
PLAYER2_SAVE1	ds.b	PlayerSave_len
PLAYER2_SAVE2	ds.b	PlayerSave_len
PLAYER3_SAVE1	ds.b	PlayerSave_len
PLAYER3_SAVE2	ds.b	PlayerSave_len

;Save1/2 for every bullet for every player!!!
P0_BULLETSAVE	ds.b	2*MaxPBulletTotal*bulletsave_len
				even
P1_BULLETSAVE	ds.b	2*MaxPBulletTotal*bulletsave_len
				even
P2_BULLETSAVE	ds.b	2*MaxPBulletTotal*bulletsave_len
				even
P3_BULLETSAVE	ds.b	2*MaxPBulletTotal*bulletsave_len
				even
BONUSSAVE1		ds.b	2*2*16*5+8
BONUSSAVE2		ds.b	2*2*16*5+8

				ds.b	npl*plwidb*16		; space to avoid clipping!
SCREEN1			ds.b	pllen*npl			; Screens...
				ds.b	npl*plwidb*16
SCREEN2			ds.b	pllen*npl
				ds.b	npl*plwidb*16

HITPLANE		ds.b	pllen				; Plane for collision detection
PAPMAP			ds.b	9*2*18				; Pixel Accurate Player hitmap!

	SECTION	TANXS_DATA,DATA
*****
*Static data
*****

lw.BlackCols	ds.w	numcols		; List of blacks...

ll.TraceRegs	dc.l	0,0,0,0,0,0,0,0
				dc.l	0,0,0,0,0,0,0,0
l.TracePC		dc.l	0
w.TraceStat		dc.w	0

; Level datas!
	INCLUDE	SOURCE/LEVELDATA.S

font	incbin	gfx/metallion10.8

LOGO incbin gfx/titlelogo.irawc
LOGO_LEN = *-LOGO-64
lw.logocols = *-64
	even
BdeltaTab
;x,y diffs from x/ypos ,delta x/y
	dc.w	4,0,0,-1			; u
	dc.w	8,0,1,-1			; ur
	dc.w	8,4,1,0				; r
	dc.w	8,8,1,1				; dr
	dc.w	4,8,0,1				; d
	dc.w	0,8,-1,1			; dl
	dc.w	0,4,-1,0			; l
	dc.w	0,0,-1,-1			; ul
	IFD	EDITOR
	INCLUDE SOURCE/EDITOR.S
	ENDC

*****
*Variable definitions
*****
			rsreset
lw.Plmultab rs.l    plhgt
p.DrawPl	rs.l	1			; Ptr to current draw plane
p.Showpl	rs.l	1			; Ptr to shown plane
plw.Cols    rs.l	1      		; Ptr to list of current colours, or target
	ifd	RUNTIME
b.vbsig		rs.b	1
			rs.b	1
	endc

	ifd	SMPI
	SMPIVARS
	endc
b.player0control	rs.b	1	; 0 if stick, 1 keys 1, -1 keys 2
b.player1control	rs.b	1
b.player2control	rs.b	1
b.player3control	rs.b	1
w.MaxBullets		rs.w	1	; Max bullets -1
l.VBLCounter	rs.l	1
l.CopCounter	rs.l	1
l.BlitCounter	rs.l	1
l.CIACounter	rs.l	1
w.Tron			rs.w	1		; Trace control - on/off
P4L1		rs.b	1			; $player adaptor readings!
P4R1		rs.b	1
P4U1		rs.b	1
P4D1		rs.b	1
P4F1		rs.b	1
P4L2		rs.b	1
P4R2		rs.b	1
P4U2		rs.b	1
P4D2		rs.b	1
P4F2		rs.b	1
w.DeathWatch	rs.w	1		; Counter sig at level-over
w.NumLevels	rs.w	1			; No levels in map lists (start=0)
w.NumPlayers	rs.w	1		; No players!
w.Curlevel	rs.w	1			; Level in use/to be drawn (start=0)
Player0		rs.b	p_len		; Player structs :-)
Player1		rs.b	p_len	
Player2		rs.b	p_len	
Player3		rs.b	p_len	
		
Bonus_State	rs.b	1
Bonus_Count	rs.b	1
Bonus_Timer	rs.w	1
Bonus_X		rs.w	1
Bonus_Y		rs.w	1
Bonus_Save1	rs.l	1
Bonus_Save2	rs.l	1
l.randptr	rs.l	1
l.brandptr	rs.l	1
myvars_len	rs.b	1	

			SECTION	MYVARS,BSS
MYVARS		DS.B	MYVARS_LEN
			EVEN
