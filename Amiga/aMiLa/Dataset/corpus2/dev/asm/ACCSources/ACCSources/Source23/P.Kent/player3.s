
    OPT C-,O+,D+,OW2-
*LOADS of offsets removed [0(Ax) etc] : no warnings for this s.v.p.

*TANXS!!!! TABS=4
*Will be a four player tank game, as in the old ATARI VCS classic!
*Only two players at the mo, but very modular code/design so additional
*players easy to implement! (If I can suss how to read a 4 player adaptor!)
*All major code BAR bullet firing/collision detection system in place!
*(INC.A handy set of portable bob routines! - NB MakeBobMask not useable yet!)
*Collision detection system is pixel accurate: but only if necessary!

*P.Kent,9 Pendean,Burgess Hill,West Sussex,RH15 ODW.
*GFX: from PREDATORS MEGADEMO
*BITS of code: ACC members esp D.Edwards! Thanks for the ideas from blitter3.s

*ESC to quit!

*1.4.92: Initialisation shell code for players (UNTESTED)
*        Lots needs defining!
*6.4.92: Can drive around+pixel accurate scenery collisions+box player collns.
*        Needs pixel accurate  player hits / no bullet or damage code et.
*9.4.92: ELECTION :-()    <<<confused smiley!!!!
*		 Accurate player vs player hits (PAPMAPs)
*        Damage in explosions- ENERGY/POWER line etc
*        Print/Delete bullet code.
*11.4.92 Bullet run shell code + few "death situation" bugs NUKED!
*        Fire shell bugged! conditional test wrong or similar.

    SECTION TANXS,CODE
	OUTPUT	TANXS:PLAYER

	INCDIR	Source:INCLUDE/
	INCLUDE	HARDWARE.I
	INCLUDE	MYMACROS.I
	INCLUDE	HWSTART.S

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


MAXENERGY	=	99*8				; Max player energy
MAXPOWER	=	99*8				; Max player bullet power
POWERGROW	=	4					; Grow 1/2% per frame
CRASHDAMAGE	=	2					; Damage due to collisions between players
EXPLODAMAGE	=	4					; If at centre of explosion: take wodges
									; of damage!

MAXSPEED	=	1					; Max player speed
BULLSPEED	=	2
BULLETDELAY	=	20					; .4 secs between bullets
BULLETDAMAGE	=	9*8				; 12 hits to death! 11=1% left!!!
BULLETCOST	=	9*8					; 9% per bullet
BULLETDIST	=	100					; No of frames bullet can run for
ALIVE	=	0
DYING	=	1
DEAD	=	2
MaxBullets	=		8				; 8 in air at once
Explospeed	=		3				; Change explo every 3 frames
BExplospeed	=		3				; every 3 frames
BullExploframes	=	6
TankExploframes	=	8				; No anims in tank explosion
Deathmax	=		TankExploFrames*ExploSpeed
Bullmax		=		BullExploFrames*Bexplospeed

;BULLET STRUCTURE
			rsreset
bl_sig		rs.b	1				; Flying,Burning,dead
bl_explo	rs.b	1				; count for explosion/bullet
bl_timer	rs.w	1				; Path length left
bl_xpos		rs.w	1				; x,y position
bl_ypos		rs.w	1

bl_dx		rs.w	1				;+/- #BULLSPEED FOR BULLETS
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
p_Bullets	rs.b	MaxBullets*Bullet_len	; Bullet tracking data
p_len		rs.w	1


;BOB structure!

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

_BOOT
	LEA	CUSTOM,A6
	LEA	MYVARS,A5
	BSR	InitStartUp


	Bsr	InitGame					; Sets start level etc.

;Next level:
	Bsr	StartLevel					; Fades in level + prints players
									; Resets energies
mainlp
	lea	player0(a5),a4				; Process player actions:						
	bsr	Doplayer					; Movement/bullets/exploding etc.
	lea	player1(a5),a4
	bsr	Doplayer

	bsr	printplayers				; Print all players on background screen
	bsr	printbullets				; Print bullets/explosions

	bsr	printstats

	catchpos	a6,312
	bsr	swapcop

	bsr	deletebullets				; Tidy old foreground screen...
	bsr	deleteplayers	

;	Interrupt monitoring
;	move.l	l.vblcounter(a5),d0
;	moveq	#0,d1
;	move.l	d1,d2
;	bsr	showd0
;	add.l	#10,d1
;	move.l	l.copcounter(a5),d0
;	bsr	showd0
;	add.l	#10,d1
;	move.l	l.blitcounter(a5),d0
;	bsr	showd0
;	add.l	#10,d1
;	move.l	l.ciacounter(a5),d0
;	bsr	showd0

	lea	player0(a5),a4				; Quit if only 1 left alive!
;	cmp.b	#DEAD,p_state(a4)
;	beq.s	mainlp_fin
	cmp.b	#$50,b.ordkey(a5)		; Use F1 to blow up on remote!
	bne.s	Nuke1
	move.w	#0,p_energy(a4)
Nuke1

	lea	player1(a5),a4
;	cmp.b	#DEAD,p_state(a4)
;	beq.s	mainlp_fin
	cmp.b	#$51,b.ordkey(a5)		; F2 nukes player 2!
	bne.s	Nuke2
	move.w	#0,p_energy(a4)
Nuke2

	cmp.b	#$45,b.ordkey(a5)		; Escape aborts
	bne	mainlp
mainlp_fin
	BSR	CloseDown
	RTS	
 

*****
*Initialisation routine for startup only
*****
InitStartUp

	lea	Int3_Handler(pc),a0				; Set up interrupt handlers
	move.l	a0,$6C.W
	lea	Int2_Handler(pc),a0
	move.l	a0,$68.W
	lea	Trace_Handler(pc),a0			; Debug code..
	move.l	a0,$24.W

	MOVE.L	#SCREEN1,p.DrawPl(A5)		; initial screen ptr
	BSR	SwapCop

;	BSR	MT_INIT

	CATCHVB	A6	        				; Wait for VBL
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN,dmacon(A6)
	MOVE.L	#MY_Copper,cop1lch(A6)		; Just set dma/ints and wait!
	MOVE.W	D0,COPJMP1(A6)
	MOVE.b	#%01111111,CIAAICR			; Nuke ports!
	MOVE.L	#(SETIT!INTEN!BLIT!VERTB!COPER!PORTS)*65536+$7FFF,intena(A6)
										; My ints + zap intreq!
	move.b	#$88,CIAAICR				; Enable Int2 kbrd handler
	move.b	#$20,CIAACRA

	MOVE.L	#lw.BlackCols,plw.Cols(A5)	; Put in initial colours...
	BSR	InitLevels						; Initialise level offsets
	BSR	InitSprites
	BSR	InitPlayers						; Put in ptrs in player structs
	RTS

*****
*Termination code
*****
CloseDown
	MOVE.L	#lw.BlackCols,plw.COls(A5)	; Always fade to black!
	MOVEQ	#1,D0
	BSR	FadeCols
;	BSR	MT_END
	MOVE.B	#%10011011,CIAAICR			; Keyb etc. back on
	RTS 

***
* Trace_Handler()
* Handle a trace exception
* Debugging routine -D.Edwards strikes again!
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
* Int2_Handler()
* Handle Level 2 interrupt (CIA-A)
* Get key value etc
*****
Int2_Handler
	movem.l	d0-d5/a5,-(sp)
;	move.w	#$2200,SR			; prevent interrupt nesting
	lea	myvars,a5
	lea	custom,a6
	move.w	INTREQR(a6),d0
	bclr	#15,d0				; ensure IRQ acknowledge
	bclr	#3,d0 				; of CIA interrupt
	move.w	d0,INTREQ(a6)		; and tell 4703 about it

	move.b	CIAAICR,d1			; check CIA source
	bclr	#7,d1

	addq.l	#1,l.CIACounter(a5)	; one of many counters...

	move.b	CIAASP,d2			; get key press
	or.b	#$40,CIAACRA		; pull KCLK low (SPMODE output)

	not.b d2
	ror.b #1,d2 				; get correct key code

	move.b	d2,d3 				; copy key code
	bclr	#7,d3 				; clear keyup bit of copy
	cmp.b #$60,d3				; is it a shift-type key?
	bcc.s Int2_3				; yes

	tst.b d2 					; key up?
	bmi.s Int2_4				; yes
	move.b	d3,b.OrdKey(a5)		; else save ordinary key
	bra.s Int2_2				; and exit Int2

Int2_4	st b.OrdKey(a5)			; keyup so 'clear' it
;	clr.b b.ShiftKey(a5)		; and the shifts??
	bra.s Int2_2				; and exit Int2

Int2_3
	moveq #0,d4 				; shift key state to record
	move.b	b.ShiftKey(a5),d5 	; shifts already gotten
	sub.b #$60,d3				; get shift bit no
	bset	d3,d4 				; & set the shift bit

	tst.b d2 					; is it keyup?
	bmi.s Int2_5				; yes
	or.b	d4,d5 				; else add a new one
	move.b	d5,b.ShiftKey(a5)	; and set it
	bra.s Int2_2				; and exit Int2

Int2_5
	not.b d4 					; subtract a shift state
	and.b d4,d5
	move.b	d5,b.ShiftKey(a5)	; signal new shift state

Int2_2
	nop
	moveq #4,d2 				; wait for 75 microsecs
Int2_6
	subq.w	#1,d2
	bne.s Int2_6
	and.b #$BF,CIAACRA			; SPMODE=input again
Int2_1
	movem.l	(sp)+,d0-d5/a5
	rte

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
	bclr	#15,d0					; signal IRQ acknowledge
	move.w	d0,INTREQ(a6)			; and tell 4703 about it

	btst	#6,d0 					; Blitter?
	beq.s Int3_1					; no
	addq.l	#1,l.BlitCounter(a5)	; add to blitter counter

Int3_1
	btst	#5,d0 					; VBL?
	beq.s Int3_2					; no
	addq.l	#1,l.VBLCounter(a5)		; add to VBL counter

;		BSR	MT_MUSIC

Int3_2
	btst	#4,d0 					; Copper?
	beq.s Int3_3					; no
	addq.l	#1,l.CopCounter(a5)		; add to Copper counter

Int3_3
	movem.l	(sp)+,d0-d7/a0-a6
	rte

*****
* InitGame()
* Zeros score, sets 0th level etc.
*****
InitGame
	move.w	#0,w.curlevel(a5)		; Hmm...
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
;CHECK ENERGY: IF 0 SET DYING,LOCK CONTROLS >EXPLOSION CODE
	tst.w	P_energy(a4)
	bhi.s	DOP_HaveEnergy
	move.b	#DYING,p_state(a4)		; No escpae!
	move.b	#0,p_diecnt(a4)			; Set anim counter to zero
	bra	DOP_Dying
DOP_HaveEnergy
;ADD TO BULLET POWER! (<MAXIMUM!)
	cmp.w	#MAXPOWER,p_bulletpow(a4)
	beq.s	DOP_BullPMax
	addq.w	#POWERGROW,p_Bulletpow(a4)
	cmp.w	#MAXPOWER,p_bulletpow(a4)
	bmi.s	DOP_BullPMax
	move.w	#MAXPOWER,p_bulletpow(a4)
DOP_BullpMax
;SUB BULLET TIMER
	cmp.b	#0,p_bullettim(a4)
	beq.s	DOP_BulletTimeok
	subq.b	#1,p_bullettim(a4)
DOP_Bullettimeok
;SCAN CONTROLS
	move.l	p_joyptr(a4),a0
	jsr	(a0)
	move.w	d0,p_joyval(a4)

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
	lea	lw.facelist,a0
	add.w	d0,d0
	move.w	(a0,d0),p_facedir(a4)
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


*****
*Hitcode (a4) subr for players:
*Check for hits with scenery+other players given delta position
*Change delta posns until OK!
*****
Player0_HitCode
	bsr.s	CheckHitScene
	lea	player1(a5),a3
	bsr	CheckHitPlayer
	bsr	PlayerCoords
	rts
Player1_HitCode
	bsr.s	CheckHitScene
	lea	player0(a5),a3
	bsr	CheckHitPlayer
	bsr	PlayerCoords
	rts

*****
*CheckHitScene(a0,d0,d1,d2)(bobs,new x,new y,offset)
*Check specified player bob for hits against scenery
*****
CS_KillDeltaY	clr.w	p_dy(a4)
	rts
CS_KillDeltaX	clr.w	p_dx(a4)
	rts

CheckHitScene
	move.l	p_sprptr(a4),a0			; My sprite ptr
	move.w	p_xpos(a4),d0			; New x,y pos...
	move.w	p_ypos(a4),d1
	move.w	p_facedir(a4),d2
	bsr.s	CS_HitSub
	bne.s		CS_OK				;TRUE=nonzero
	tst.w	p_dx(a4)
	beq.s	CS_KillDeltaY
	tst.w	p_dy(a4)
	beq.s	CS_KillDeltaX
	move.w	p_dx(a4),d7
	clr.w	p_dx(a4)
	bsr.s	CS_HitSub
	bne.s	CS_OK
	clr.w	p_dy(a4)
	move.w	d7,p_dx(a4)
	bsr.s	CS_HitSub
	bne.s	CS_OK
	clr.w	p_dx(a4)
CS_OK	rts

CS_HitSub
	movem.l	d0-d2,-(a7)
	add.w	p_dx(a4),d0				; Add deltas
	add.w	p_dy(a4),d1
	lea	hitplane,a1
	move.w	d0,d3
	lsr.w	#3,d3					; No. bytes
	lea	(a1,d3.w),a1
	mulu	#plwidb,d1				; Y offset in plane
	lea	(a1,d1.l),a1				; TLC for checks
	and.w	#%1111,d0
	ror.w	#4,d0					; Bltcon value...(rot for srcs)
	or.w	#USEA!USEC!LF7!LF5,d0	; 'AC'
	move.l	B_Mask(a0),a2	
	lea	(a2,d2.w),a2				; get mask+offset it...
									; Use A&C for 'free' channel time!
									; A2=A channel
									; A1=C channel

	move.w	B_hgt(a0),d1
	lsl.w	#6,d1
	add.w	B_WWid(a0),d1			; New Bltsize

	move.w	B_WWid(a0),d2			; Extra width+wordswidth+1
	subq.w	#1,d2
	add.w	d2,d2					; Bytes wid of bli part
	add.w	B_SMod(a0),d2			; Calc bobs *total* byte width
	mulu	#npl-1,d2
	add.w	B_CRMod(a0),d2

	blitwait	a6
	move.w	B_CMod(a0),bltcmod(a6)
	move.w	d2,bltamod(a6)
	move.l	a2,bltapth(a6)
	move.l	a1,bltcpth(a6)
	move.w	d0,bltcon0(a6)			; modes, A rot
	move.w	#0,bltcon1(a6)			; Zilch in con1
	move.l	#$ffff0000,bltafwm(a6)	; No last word!
	move.w	d1,bltsize(a6)
	movem.l	(a7)+,d0-d2
	blitwait	a6
	btst	#5,dmaconr(a6)			;Blitzero ?
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
	subq.w	#CRASHDAMAGE,p_energy(a3)
;If in box of exploding player, also take damage
	cmp.b	#DYING,p_state(a3)
	bne.s	CHP_NED1
	tst.b	d5
	beq.s	CHP_NED1
	subq.w	#EXPLODAMAGE,p_energy(a4)
CHP_NED1

	tst.w	p_dx(a4)
	beq.s	CHP_KillDeltaY
	tst.w	p_dy(a4)
	beq.s	CHP_KillDeltaX
	move.w	p_dx(a4),d7
	clr.w	p_dx(a4)
	bsr.s	CHP_HitSub
	bne.s	CHP_OK
	clr.w	p_dy(a4)
	move.w	d7,p_dx(a4)
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
CP_PossX	cmp.w	#17,d1
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
	move.l	b_mask(a0),a2
	move.w	p_facedir(a3),d4
	lea	(a2,d4.w),a2				; Offset mask - A chan

	move.w	B_hgt(a0),d1
	lsl.w	#6,d1
	add.w	B_WWid(a0),d1			; New Bltsize

	move.w	B_WWid(a0),d0			; Extra width+wordswidth+1
	subq.w	#1,d0
	add.w	d0,d0					; Bytes wid of bli part
	add.w	B_SMod(a0),d0			; Calc bobs *total* byte width
	mulu	#npl-1,d0
	add.w	B_CRMod(a0),d0

	blitwait	a6
	move.w	#6-4,bltcmod(a6)		; Bytes width -2*words per bob
	move.w	d0,bltamod(a6)
	move.l	a2,bltapth(a6)
	move.l	a1,bltcpth(a6)
	move.w	d2,bltcon0(a6)			; modes, A rot
	move.w	#0,bltcon1(a6)			; Zilch in con1
	move.l	#$ffff0000,bltafwm(a6)	; No last word!
	move.w	d1,bltsize(a6)
	blitwait	a6
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
;IF ALIVE!
;MAKE PAPMAP for self
;CHECK ALL BULLETS AGAINST SELF - DAMAGE, BULLET TERM.S AS REQD
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P0B_NAlive
	Bsr	MakePapmap
	lea	player1(a5),a3				; Check player1s active! bullets 
	bsr	ProcBullets
P0B_NAlive
;FOR VERY PLAYER ACTIVE BULLET:
;DYING: STEP ANIM CNT ON EXPLODING BULLETS
;ALIVE: MOVE/REFLECT BULLETS/SUB BULLET TIMERS - TERMINATE AS REQD
	bsr	RunBullets
;ADD NEW BULLET IF FIRE + TIMER OK + POWER OK + SLOT FREE +ALIVE!
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P0B_Nalive2
	bsr	FireBullet
P0B_Nalive2
	rts

Player1_BullCode
;IF ALIVE!
;MAKE PAPMAP for self
;CHECK ALL BULLETS AGAINST SELF - DAMAGE, BULLET TERM.S AS REQD
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P1B_NAlive
	Bsr	MakePapmap
	lea	player0(a5),a3				; Check player0s active! bullets 
	bsr	ProcBullets
P1B_NAlive
;FOR VERY PLAYER ACTIVE BULLET:
;DYING: STEP ANIM CNT ON EXPLODING BULLETS
;ALIVE: MOVE/REFLECT BULLETS/SUB BULLET TIMERS - TERMINATE AS REQD
	bsr	RunBullets
;ADD NEW BULLET IF FIRE + TIMER OK + POWER OK + SLOT FREE +ALIVE!
	cmp.b	#ALIVE,p_state(a4)
	bne.s	P1B_Nalive2
	bsr	FireBullet
P1B_Nalive2
	rts

*****
*ProcBullets(a3,a4) (test player,active player)
*Check all active player bullets against test player - if any!
*Using papmap!
*Sub players energy+term bullet if hit: set bl_explo to 0
*****
ProcBullets
	rts
*****
*RunBullets(a4) (player)
*Run all active player bullets - move/reflect/sub timers/terminate etc
*****
RunBullets
	cmp.b	#0,p_bulletcnt(a4)
	beq.s	RB_Quit
;....:-)
RB_Quit
	rts
*****
*FireBullet(a4)(player)
*Fire bullet if fire pressed + bullet timer =0 + free bullet slot!
*****
FireBullet
	Btst	#Fire,p_joyval(a4)		; Firing ?
	beq	FB_Quit
	cmp.b	#0,p_bullettim(a4)		; Can't fire if counter NZERO 
	bne	FB_QUit
	cmp.b	#MAXBULLETS,p_bulletcnt(a4)	; Must have free slot!
	beq	FB_Quit
	cmp.w	#BULLETCOST,p_bulletpow(a4)	; Must have power!
	bmi	FB_Quit

	sub.w	#BULLETCOST,p_bulletpow(a4)	; Subtract power!
	move.b	#BULLETDELAY,p_bullettim(a4)	; Pause value!
	lea	p_bullets(a4),a3
FB_GetB
	cmp.b	#DEAD,bl_sig(a3)
	beq.s	FB_GotB
	lea	Bullet_len(a3),a3
	bra.s	FB_GetB
FB_GotB
	move.b	#ALIVE,bl_sig(a3)		; Alive!
	move.w	#BULLETDIST,bl_timer(a3)	; Distance to run!
;Set x/y pos, set dx/y according to p_x/ypos, p_facedir
FB_Quit
	rts

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
	move.l	b_mask(a2),a2
	move.w	p_facedir(a4),d0
	lea	(a2,d0.w),a2
	blitwait	a6
	move.l	a1,bltdpth(a6)
	move.l	a2,bltapth(a6)
	move.w	#6-2,bltdmod(a6)
	move.w	#78,bltamod(a6)			; Bytes width total - byte each
	move.l	#$09f00000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#(18*64)+1,bltsize(a6)	; put mask player sprite
	rts


*****
*InitPlayers
*Initialises player structs
*****
InitPlayers
;Player 0 first:
	lea	player0(a5),a4
	move.l	#RJoy0,p_joyptr(a4)		; Reader code
	move.l	#Player0_hitcode,p_hitptr(a4)
	move.l	#Player0_bobs,p_sprptr(a4)
	move.l	#player0_Save1,p_save1(a4)
	move.l	#Player0_Save2,p_save2(a4)
	move.l	#Player0_Bullcode,p_bulletptr(a4)
	lea	p_bullets(a4),a3
	lea	p0_Bulletsave,a2			; Array for bullet sprite saving
	move.w	#maxbullets-1,d0
ip0_bulletlp
	move.l	#player0_bullets,bl_sprptr(a3)
	move.l	a2,bl_save1(a3)
	lea		BulletSavelen(a2),a2	; Next save posn
	move.l	a2,bl_save2(a3)
	lea	BulletSavelen(a2),a2
	lea	Bullet_len(a3),a3			; Next bullet	
	dbra	d0,ip0_bulletlp
;REPEAT! for player 1:
	lea	player1(a5),a4
	move.l	#RJoy1,p_joyptr(a4)		; Reader code
	move.l	#Player1_hitcode,p_hitptr(a4)
	move.l	#Player1_bobs,p_sprptr(a4)
	move.l	#player1_Save1,p_save1(a4)
	move.l	#Player1_Save2,p_save2(a4)
	move.l	#Player1_Bullcode,p_bulletptr(a4)
	lea	p_bullets(a4),a3
	lea	p1_Bulletsave,a2			; Array for bullet sprite saving
	move.w	#maxbullets-1,d0
ip1_bulletlp
	move.l	#player1_bullets,bl_sprptr(a3)
	move.l	a2,bl_save1(a3)
	lea		BulletSavelen(a2),a2	; Next save posn
	move.l	a2,bl_save2(a3)
	lea	BulletSavelen(a2),a2
	lea	Bullet_len(a3),a3			; Next bullet	
	dbra	d0,ip1_bulletlp

	bsr.s	ResetPlayers			; Reload non-static data
	rts

*****
*ResetPlayers
*Loads starting enrgies for both players
*Sets start pos from curlevel
*Resets bullets
*****
ResetPlayers
	push	d0-d7/a0-a4
	Lea	player0(a5),a4
	move.b	#0,p_bulletcnt(a4)
	move.b	#0,p_bullettim(a4)
	move.w	#0,p_facedir(a4)
	move.b	#ALIVE,p_state(a4)
	move.b	#0,p_diecnt(a4)
	lea	P_Bullets(a4),a3			; Now initialise bullet structs
	move.w	#maxbullets-1,d0
rp0_bulletlp
	move.b	#DEAD,bl_sig(a3)
	move.l	bl_save1(a3),a2
	clr.l	(a2)
	move.l	bl_save2(a3),a2
	clr.l	(a2)
	lea	bullet_len(a3),a3
	dbra	d0,rp0_bulletlp
	move.b	#0,p_joyval(a4)					; No value
	move.b	#MAXSPEED,p_maxspeed(a4)		; Top speed
	move.w	#MAXENERGY,p_energy(a4)
	move.w	#MAXPOWER,p_bulletpow(a4)

	move.l	p_save1(a4),a3					; Nuke backups
	clr.l	(a3)
	move.l	p_save2(a4),a3
	clr.l	(a3)

	move.l	a4,a0

	Lea	player1(a5),a4
	move.b	#0,p_bulletcnt(a4)
	move.b	#0,p_bullettim(a4)
	move.w	#0,p_facedir(a4)
	move.b	#ALIVE,p_state(a4)
	move.b	#0,p_diecnt(a4)
	lea	p_bullets(a4),a3			; Now initialise bullet structs
	move.w	#maxbullets-1,d0
rp1_bulletlp
	move.b	#DEAD,bl_sig(a3)
	move.l	bl_save1(a3),a2
	clr.l	(a2)
	move.l	bl_save2(a3),a2
	clr.l	(a2)
	lea	bullet_len(a3),a3
	dbra	d0,rp1_bulletlp
	move.b	#0,p_joyval(a4)			; No value
	move.b	#MAXSPEED,p_maxspeed(a4)	; Stationary
	move.w	#MAXENERGY,p_energy(a4)
	move.w	#MAXPOWER,p_bulletpow(a4)

	move.l	p_save1(a4),a3			; Nuke backups
	clr.l	(a3)
	move.l	p_save2(a4),a3
	clr.l	(a3)

	move.l	a4,a1

;now do positioning of players in a0,a1
	move.w	w.CurLevel(a5),d0
	lsl.w	#4,d0					; 16 modulo on table
	lea	lp.maplist,a2
;	addq.w	#8,d0					; Skip level/col ptrs
	lea	8(a2,d0.w),a2
	
	move.w	(a2)+,p_xpos(a0)
	move.w	(a2)+,p_ypos(a0)
	move.w	(a2)+,p_xpos(a1)
	move.w	(a2)+,p_ypos(a1)

	pop	d0-d7/a0-a4
	rts

*****
* Initlevels()
* Processes all offsets in lp.maplist, sets w.Numlevels
*****
InitLevels
	lea	lp.maplist,a1
	moveq	#-1,d0					; Level count
InitLevels_lp
	move.l	(a1),d1
	tst.l	d1
	beq.s	InitLevelsFin
	move.l	d1,a2
	move.w	#NUMBLOCKS-1,d1			; Level size
InitLevels_ilp
	MOVE.W	(A2),D2
	LSL.W	#5,D2					; *32 = length of 1 plane of block
	MOVE.W	D2,(A2)+
	DBRA	D1,InitLevels_ilp
	addq.l	#1,d0					; +1 levels
	addq.l	#8,a1					; Skip levptr & colptr
	bra.s	InitLevels_lp
InitLevelsFin
	move.w	d1,w.Numlevels(a5)		; Save max levels
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
	lsl.w	#4,d0					; *16 'modulo' on table
	LEA	(A1,D0.W),A1
	move.l	a1,-(a7)

	Move.l	(a1),a0
	Bsr.s	PrintLevel				; Print level
;positions,enrgies,bullet track etc.
	Bsr	ResetPlayers				
	Bsr	PrintStatsInit
	Bsr	PrintPlayers				; Print but also cycle ptrs
	bsr	swapcop
	bsr	DeletePlayers

	move.l	(a7)+,a1	
	Move.l	4(a1),plw.Cols(a5)
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

	blitwait	a6
	move.w	#SETIT!BLTPRI,dmacon(a6)

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
	Blitwait	a6
	move.l	a4,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	#BLOCKBSIZE,bltsize(a6)
	Blitwait	a6					; Tile screen2
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
	Blitwait	a6
	move.l	a4,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	#HITBLOCKBSIZE,bltsize(a6)
	addq.l	#BLOCKWWID*2,a1					; Next pos along
	dbra	d1,PrintHM_Hlp
	lea	PHM.Offset(a1),a1
	dbra	d0,PrintHM_Vlp

	Move.w	#BLTPRI,dmacon(a6)		; Blitter 'friendly'
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
	lea	Player0_Bullets,a0
	Bsr	Initbob
	lea	Player1_Bullets,a0
	Bsr	Initbob
	lea	Pexplode_bobs,a0
	Bsr	InitBob
	lea	Bexplode_bobs,a0
	Bsr	InitBob
	rts

*****
* PrintStats()
* Prints players energies+gun power
*****
PrintStats
	lea	player0(a5),a4
	lea	dectab,a1
	lea	font,a2
	move.l	p.drawpl(a5),a0
	add.l	#ps_text2-ps_text,a0
	moveq	#0,d0
	move.w	p_energy(a4),d0
	bpl.s	PS_1
	moveq	#0,d0
PS_1	bsr.s	PSPerc

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

	rts

PrintStatsInit

	move.l	#screen1,a0
	lea	PS_text,a1
	lea	font,a2
PS_Textlp1
	moveq	#0,d3
	move.b	(a1)+,d3
	beq.s	PS_textfin1
	sub.b	#32,d3
	lsl.w	#3,d3
	lea	(a2,d3.w),a3
	bsr.s	PS_DOChr
	addq.l	#1,a0
	bra.s	PS_Textlp1
PS_textfin1

	move.l	#screen2,a0
	lea	PS_text,a1
PS_Textlp2
	moveq	#0,d3
	move.b	(a1)+,d3
	beq.s	PS_textfin2
	sub.b	#32,d3
	lsl.w	#3,d3
	lea	(a2,d3.w),a3
	bsr.s	PS_DOChr
	addq.l	#1,a0
	bra.s	PS_Textlp2
PS_textfin2

	rts

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

dectab	dc.b	'0123456789'
PS_Text
	dc.b	'ENERGY %'
PS_Text2	dc.b	'PA GUN %'
PS_Text3	dc.b	'UL    ENERGY %'
PS_Text4	dc.b	'KE GUN %'
PS_text5	dc.b	'NT',0
	even
*****
* PrintPlayers()
* Prints both players (explosions implemented!)
*****
PrintPlayers
	lea	player0(a5),a4
	cmp.b	#DEAD,p_state(a4)
	beq.s	PP_NoP0
	Bsr.s	PPlayer
PP_NoP0
	lea	player1(a5),a4
	cmp.b	#DEAD,p_state(a4)
	beq.s	PP_NOP1
	bsr.s	PPlayer
PP_NoP1
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
	bra	DoBob
PPlayer_exploding
	move.l	p.drawpl(a5),a1
	move.l	p_save1(a4),a2
	move.w	p_xpos(a4),d0
	move.w	p_ypos(a4),d1
	subq.w	#8,d0
	subq.w	#8,d1
	lea	Pexplode_bobs,a0
	moveq	#0,d2
	move.b	p_diecnt(a4),d2
	divu	#explospeed,d2
	and.l	#$ffff,d2
	add.w	d2,d2
	add.w	d2,d2
	bra	Dobob	

*****
* PrintBullets()
* Prints bullets for all players - if any bullets active!
*****
PrintBullets
	lea	player0(a5),a4
	tst.b	p_bulletcnt(a4)
	beq.s	PB_Nobull0
	lea	p_bullets(a4),a3
	moveq	#maxbullets-1,d7
PB_lp0
	cmp.b	#DEAD,bl_sig(a3)
	beq.s	PB_Dead0
	bsr.s	PBullets
PB_Dead0
	lea	Bullet_len(a3),a3
	dbra	d7,PB_lp0
PB_Nobull0

	lea	player1(a5),a4
	tst.b	p_bulletcnt(a4)
	beq.s	PB_Nobull1
	lea	p_bullets(a4),a3
	moveq	#maxbullets-1,d7
PB_lp1
	cmp.b	#DEAD,bl_sig(a3)
	beq.s	PB_Dead1
	bsr.s	PBullets
PB_Dead1
	lea	Bullet_len(a3),a3
	dbra	d7,PB_lp1
PB_NoBUll1
	rts

PBullets							; Print bullet at a3
	cmp.b	#DYING,bl_sig(a3)
	beq.s	PBullets_Burn
	move.l	p.drawpl(a5),a1
	move.l	bl_save1(a3),a2
	move.w	bl_xpos(a3),d0
	move.w	bl_ypos(a3),d1
	move.l	bl_sprptr(a3),a0
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
	divu	#Bexplospeed,d2			; Get no
	and.l	#$ffff,d2
	add.w	d2,d2
	bra	Dobob
	
		
*****
* DeletePlayers()
* Removes p_save2,exchanges p_save1/2
*****
DeletePlayers
	lea	player1(a5),a4
	move.l	p_save2(a4),a2			; Exchange screen ptrs
	move.l	p_save1(a4),p_save2(a4)
	move.l	a2,p_save1(a4)
	bsr	RecoBob	

	lea	player0(a5),a4
	move.l	p_save2(a4),a2			; Exchange screen ptrs
	move.l	p_save1(a4),p_save2(a4)
	move.l	a2,p_save1(a4)
	bra	RecoBob

*****
* DeleteBullets()
* Removes bl_save2 ,exchages save addr - ***ignores*** bulletcnt for framing
*****
DeleteBullets
	lea	player0(a5),a4
	lea	p_bullets(a4),a3
	moveq	#maxbullets-1,d7
DB_lp0								; Exchange ptrs, call bob rt!
	move.l	bl_save2(a3),a2
	move.l	bl_save1(a3),bl_save2(a3)
	move.l	a2,bl_save1(a3)
	bsr	Recobob
	lea	Bullet_len(a3),a3
	dbra	d7,DB_lp0

	lea	player1(a5),a4
	lea	p_bullets(a4),a3
	moveq	#maxbullets-1,d7
DB_lp1
	move.l	bl_save2(a3),a2
	move.l	bl_save1(a3),bl_save2(a3)
	move.l	a2,bl_save1(a3)
	bsr	Recobob
	lea	Bullet_len(a3),a3
	dbra	d7,DB_lp1

	rts

*****
* WaitVBL()
* Wait for VBL to pass by
* d0 corrupt - INT CODE MUST BE RUNNING!
*****
WaitVBL
	move.l	l.VBLCounter(a5),d0
WaitVBL_1
	cmp.w l.VBLCounter+2(a5),d0
	beq.s WaitVBL_1
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
*Save screen portion to save if nz
*Blit bob at prt to screen *no clipping*
*****
DoBob
	PUSH	D0-D3/A1-A3
	move.w	d0,d3
	lsr.w	#3,d3					; No. bytes
	lea	(a1,d3.w),a1
	mulu	#plwidb*npl,d1			; Y offset Offset in plane
	lea	(a1,d1.l),a1				; Dest for bob!
	and.w	#%1111,d0
	ror.w	#4,d0					; Bltcon value...

	cmp.l	#0,a2					; Saving ?
	beq.s	DoBob_NoSave
	move.l	a0,(a2)+				; Save bob struct address
	Move.l	a1,(a2)+				; Save address
	blitwait	a6					; Now do save
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
	blitwait	a6
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
	POP	D0-D3/A1-A3
	rts

*****
*RecoBob(Save)(a2)
*Recover screen portion at save *no clipping*
*Safe: if (a2)=0 then abort!
*****
RecoBob
	tst.l	(a2)
	beq.s	RecoBob_Abort
	PUSH	A0-A2
	blitwait	a6
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
	POP	A0-A2
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
	move.w		JOY0DAT(a6),d0		read stick
	btst		#1,d0			right ?
	beq.s		Rj0.test_left		if not jump!
	or.w		#1,d2			set right bit
Rj0.test_left
	btst		#9,d0			left ?
	beq.s		Rj0.test_updown		if not jump
	or.w		#2,d2			set left bit
Rj0.test_updown	move.l		d0,d1			copy JOY1DAT
	lsr.w		#1,d1			shift u/d bits
	eor.w		d1,d0			exclusive or 'em
	btst		#0,d0			down ?
	beq.s		Rj0.test_down		if not jump
	or.w		#4,d2			set down bit
Rj0.test_down	btst		#8,d0			up ?
	beq.s		Rj0.no_joy			if not jump
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
*Swap copper ptrs in copper list
*****

SwapCop
	MOVE.L	p.DrawPl(a5),a0
	CMP.L	#SCREEN1,A0
	BEQ.S	SwapCop2
	MOVE.L	#SCREEN1,p.DrawPl(a5)
	BRA.S	SwapCop3
SwapCop2	MOVE.L	#SCREEN2,p.DrawPl(a5)
SwapCop3
	Lea	CopPls,a1
	moveq	#npl-1,d1
	move.w	#plwidb,d2
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
	CATCHVB	A6
	dbra	d3,FC_Pauselp
	BRA.S	FC_olp
FC_DoneAll
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

;MT_ STUFF!
;	INCLUDE	PT11B-PLAY.S

	SECTION	TANXS_CHIPSTUFF,DATA_C
;All chip datas here!
*****
*Copper list for main program
*****
MY_Copper
	dc.w	diwstrt,$2C81,diwstop,$2CC1
	dc.w	ddfstrt,$38,ddfstop,$D0
	dc.w	bplcon0,BPU2!BPU0!COLOR
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
	
	dc.w	$FFFF,$FFFE

; Interleaved map tiles.
Raw.MapBlks
	INCBIN	source:P.Kent/Gfx/MapTiles.IBlock
; Hit map tiles...
Raw.MapHits
	INCBIN	source:P.Kent/Gfx/MapTiles.HitMap
;Colour maps for levels.
lw.Map1Cols	INCBIN	source:P.Kent/Gfx/MapTiles.ColMap

;BOB STRUCTS +GFX HERE!
Player0_Bobs
Player1_Bobs
	dc.w	0
	dc.w	1+1,18,14
	dc.l	PlayerBMap,PlayerMask	
	ds.w	3
PlayerMask	INCBIN	source:P.Kent/Gfx/TESTTANK.IMASK
PlayerBMap	INCBIN	source:P.Kent/Gfx/TESTTANK.IRAW
PlayerBMap_len	=	*-PlayerBMap

PExplode_Bobs
	dc.w	0
	dc.w	2+1,32,28
	dc.l	PlayerEMap,PExploMask	
	ds.w	3
PExploMask	INCBIN	source:P.Kent/Gfx/TANKEXPLO.IMASK
PlayerEMap	INCBIN	source:P.Kent/Gfx/TANKEXPLO.IRAW
PlayerEMap_len	=	*-PlayerEMap


Player0_Bullets						; Init bob routine catches 2nd inits!
Player1_bullets
	dc.w	0
	dc.w	1+1,7,0
	dc.l	BulletBMap,BulletMask
	ds.w	3
BulletBMap	INCBIN	source:P.Kent/Gfx/Bullets.Iraw
BulletBMap_len	=	*-BulletBMAP
BulletMask	INCBIN	source:P.Kent/Gfx/Bullets.Imask

BulletSavelen	=	8+BulletBMap_len		; LWptr+hgt*plane*2*width

Bexplode_bobs
	dc.w	0
	dc.w	1+1,7,12-2
	dc.l	EBulletBMap,EBulletMask
	ds.w	3
EBulletBMap	INCBIN	source:P.Kent/Gfx/Bullexplo.Iraw
EBulletBMap_len	=	*-BulletBMAP
EBulletMask	INCBIN	source:P.Kent/Gfx/Bullexplo.Imask

;
;MT_DATA	INCBIN	"TANXS:SOUND/MOD.A KING IS BORN"

	SECTION	TANX_VIEWS,BSS_C
PLAYER0_SAVE1	ds.b	8+PlayerEMap_len	; 2LW ptr,wid+1*hgt*npl
PLAYER0_SAVE2	ds.b	8+PlayerEMap_len	; 2LW ptr,wid+1*hgt*npl
PLAYER1_SAVE1	ds.b	8+PlayerEMap_len	; 2LW ptr,wid+1*hgt*npl
PLAYER1_SAVE2	ds.b	8+PlayerEMap_len	; 2LW ptr,wid+1*hgt*npl

;Save1/2 for every bullet for every player!!!
P0_BULLETSAVE	ds.b	2*maxbullets*bulletsavelen
P1_BULLETSAVE	ds.b	2*maxbullets*bulletsavelen
				even
SCREEN1			ds.b	pllen*npl			; Screens...
SCREEN2			ds.b	pllen*npl
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

;List of ptrs to maps & colmaps+pl1,2 start pos
lp.MapList		dc.l	a.level1,lw.Map1Cols
				dc.w	60,60
				dc.w	220,156
				dc.l	0			; List terminated
a.level1
	dc.w	05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05
	dc.w	66,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,67
	dc.w	50,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,51
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,60,60,00,20,21,00,61,62,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,80,80,00,40,41,00,61,62,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	30,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,31
	dc.w	86,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,87
	dc.w	05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05
font	incbin	source:P.Kent/Gfx/metallion.fnt03

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
*Variable definitions
*****
			rsreset
p.DrawPl	rs.l	1			; Ptr to current draw plane
plw.Cols    rs.l	1      		; Ptr to list of current colours, or target
b.OrdKey	rs.b	1			; Key value from INT2
b.Shiftkey	rs.b	1			; Shift state

l.VBLCounter	rs.l	1
l.CopCounter	rs.l	1
l.BlitCounter	rs.l	1
l.CIACounter	rs.l	1
w.Tron		rs.w	1			; Trace control - on/off

w.NumLevels	rs.w	1			; No levels in map lists (start=0)
w.Curlevel	rs.w	1			; Level in use/to be drawn (start=0)

Player0		rs.b	p_len		; Player structs :-)
Player1		rs.b	p_len	
myvars_len	rs.b	1	

			SECTION	MYVARS,BSS
MYVARS		DS.B	MYVARS_LEN
			EVEN
