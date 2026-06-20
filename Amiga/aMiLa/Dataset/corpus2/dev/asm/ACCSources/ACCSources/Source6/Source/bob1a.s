;   "BOB1a.s"    by *** Jack Young *** , written near the end of 1989
;
;Print lots of bobs on the screen (170)
;Bobs ared 1 bit plane, 16×16 pixels, and masked.
;Masking is only in the sense that bobs abliterate only
;   what's not wanted underneath;
;   they don't store what was underneath.
;All the bobs move, at a stunning 50 frames per second!
;
;
;Requests "mathtrans.library" to build up sine table.
;
;To stop, press CTRL key or left mouse button.
;For some reason, right mouse button pauses.



;Define lots of constants

DMACON	= $96
DMACONR	= $2
COLOR00	= $180

COP1LC	= $80
COPJMP1	= $88


BPLCON0	= $100
BPLCON1	= $102
BPLCON2	= $104
BPL1PTH	= $0E0
BPL1PTL	= $0E2
BPL1MOD	= $108
BPL2MOD	= $10A
DIWSTRT	= $08E
DIWSTOP	= $090
DDFSTRT	= $092
DDFSTOP	= $094

BLTCON0	= $40
BLTCON1	= $42
BLTCPTH	= $48
BLTCPTL	= $4a
BLTBPTH	= $4c
BLTBPTL	= $4e
BLTAPTH	= $50
BLTAPTL	= $52
BLTDPTH	= $54
BLTDPTL	= $56
BLTCMOD	= $60
BLTBMOD	= $62
BLTAMOD	= $64
BLTDMOD	= $66
BLTSIZE	= $58
BLTCDAT	= $70
BLTBDAT	= $72
BLTADAT	= $74
BLTAFWM	= $44
BLTALWM	= $46

CIAAPRA	= $bfe001

;Exec library offsets:

ExecBase	= 4

CloseLibrary 	= -414
OldOpenLibrary	= -408
OpenLibrary = -30-522
Forbid	    = -30-102
Permit	    = -30-108
AllocMem    = -30-168
FreeMem     = -30-180

;Graphics Library Base Offsets:

OwnBlitter	= -30-426
DisownBlitter	= -30-432

StartList = 38


Planewidth	= 40
Planeheight	= 272
Planesize	= Planewidth*Planeheight

Chip	= 2		;allocate Chip-RAM
Clear	= Chip+$10000	;Clear Chip-RAM first

;mathffp.library base offsets:
SPFix = -30
SPFlt = -36
SPCmp = -42
SPTst = -48
SPAbs = -54
SPNeg = -60
SPAdd = -66
SPSub = -72
SPMul = -78
SPDiv = -84

;*** Initialization ***

Start:
;Open Libraries
	bsr	openffp
	beq	stop
	bsr	openmt
	beq	end1

;Allocate memory for bit planes
	move.l	ExecBase,a6
	move.l	#Planesize,d0
	move.l	#Clear,d1
	jsr	AllocMem(a6)	;Allocate Memory
	move.l	d0,Planeadr1
	beq	end2		;Error! -> End
	move.l	#Planesize,d0
	move.l	#Clear,d1
	jsr	AllocMem(a6)	;Allocate Memory
	move.l	d0,Planeadr2
	beq	end3		;Error! -> End

;Allocate memory for Copper-List
	move.l	#12,d0		;3 commands, 6 words, 12 bytes
	moveq.l	#Chip,d1	;want chip RAM
	jsr	AllocMem(a6)
	move.l	d0,CLadr
	beq	FreePlane

;Create Copper-List
	move.l	d0,a0
	move.l	Planeadr2,d0
	move.w	#BPL1PTH,(a0)+	;'MOVE' to BPL1PTH...
	swap	d0
	move.w	d0,(a0)+	;...the address of Planeadr2
	move.w	#BPL1PTL,(a0)+	;...and the low byte.
	swap	d0
	move.w	d0,(a0)+
	move.l	#$fffffffe,(a0)+ ;'WAIT'- impossible beam pos; so end coplist

;Allocate memory for bob
	move.l	#bobsize,d0
	move.l	#Chip,d1
	jsr	AllocMem(a6)
	move.l	d0,bobadr
	beq	FreeCop
;Transfer bob to chip-RAM
	lea	bobgraph,a0
	move.l	d0,a1
	move.w	#bobsize/2-1,d0
bobtran	move.w	(a0)+,(a1)+
	dbra	d0,bobtran

;Allocate Blitter
	lea	grname,a1
	clr.l	d0
	jsr	OpenLibrary(a6)
	move.l	d0,grbase
	move.l	d0,a6
	jsr	OwnBlitter(a6)

;*** Main Program ***
;DMA and Task-Switching off
	move.l	ExecBase,a6
	jsr	Forbid(a6)
	lea	$dff000,a5
	move.w	#$03e0,DMACON(a5)	;Most DAM off
;Copper initialization
	move.l	CLadr,COP1LC(a5)
	clr.w	COPJMP1(a5)
;Set colour

	move.w	#$0000,COLOR00(a5)	;Black background
	move.w	#$0ff0,COLOR00+2(a5)	;yellow 'foreground'

;Playfield initialiazion

	move.w	#$2581,DIWSTRT(a5)	;Standard PAL screen
	move.w	#$35c1,DIWSTOP(a5)
	move.w	#$0038,DDFSTRT(a5)
	move.w	#$00d0,DDFSTOP(a5)
	move.w	#%0001001000000000,BPLCON0(a5)	;1bitplane, COLOR=1
	clr.w	BPLCON1(a5)	;no scroll
	clr.w	BPLCON2(a5)	;no playfield priorities
	clr.w	BPL1MOD(a5)
	clr.w	BPL2MOD(a5)
;DMA on
	move.w	#$83C0,DMACON(a5)	;Most DMA on

	bsr	mainbit	;main bit of the program

;*** End program ***

;Wait till blitter is ready (ie finished)

Wait:	btst	#14,DMACONR(a5)
	bne	Wait

;Activate old Copper-List

	move.l	grbase,a6
	move.l	StartList(a6),COP1LC(a5)
	clr.w	COPJMP1(a5)
	move.w	#$8020,DMACON(a5)
	jsr	DisownBlitter(a6)
	move.l	ExecBase,a6
	jsr	Permit(a6)

;Release memory for bob

FreeBob	move.l	bobadr,a1
	move.l	#bobsize,d0
	jsr	FreeMem(a6)

;Release memory for Copper-List

FreeCop	bsr	closeffp
	move.l	CLadr,a1
	move.l	#12,d0
	jsr	FreeMem(a6)

;Release Bitplane memory

FreePlane:

	move.l	Planeadr2,a1
	move.l	#Planesize,d0
	jsr	FreeMem(a6)

end3:
	move.l	Planeadr1,a1
	move.l	#Planesize,d0
	jsr	FreeMem(a6)
end2
	bsr	closemt
end1:
	bsr	closeffp
stop	clr.l	d0
	rts



openffp:
	move.l	ExecBase,a6
	lea	ffpName,a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,ffpbase
	rts
ffpName	dc.b	"mathffp.library",0
	even
ffpbase	dc.l	0

closeffp:
	move.l	ExecBase,a6
	move.l	ffpbase,a1
	jsr	CloseLibrary(a6)
	rts

openmt:
	move.l	ExecBase,a6
	lea	mtName,a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,mtbase
	rts
mtName	dc.b	"mathtrans.library",0
	even
mtbase	dc.l	0

closemt:
	move.l	ExecBase,a6
	move.l	mtbase,a1
	jsr	CloseLibrary(a6)
	rts


mainbit:
;convert lots of integer constants to ffp
	move.l	ffpbase,a6
	move.l	#314159265,d0
	jsr	SPFlt(a6)
	move.l	d0,-(a7)
	move.l	#100000000,d0
	jsr	SPFlt(a6)
	move.l	d0,d1
	move.l	(a7)+,d0
	jsr	SPDiv(a6)
	move.l	d0,pi		;make pi
	move.l	#2,d0
	jsr	SPFlt(a6)
	move.l	d0,n2		;make 2
	move.l	pi,d1
	jsr	SPMul(a6)
	move.l	d0,pi2		;make 2*pi
	move.l	#128,d0
	jsr	SPFlt(a6)
	move.l	d0,n128		;make 128
	move.l	#16384,d0
	jsr	SPFlt(a6)
	move.l	d0,n16384	;make 16384
	move.l	#1,d0		;step of rotation (degrees)
	jsr	SPFlt(a6)
	move.l	n128,d1
	jsr	SPDiv(a6)
	move.l	pi,d1
	jsr	SPMul(a6)
	move.l	d0,rotstep	;get step of rotation (floating, radians)
	jsr	SPNeg(a6)	;negate
	move.l	d0,rot		;place in current amount of rotation

;generate a sine table
	move.l	rotstep,d1
	move.w	#319,d2		;320 loops= 256 + 32
	lea	sindat,a0	;address to store sine table
sinlp
	move.l	ffpbase,a6
	move.l	rot,d0
	jsr	SPAdd(a6)
	move.l	d0,rot
	move.l	mtbase,a6
	movem.l	d1-d2/a0,-(a7)
	jsr	-36(a6)		;SPSin
	move.l	ffpbase,a6
	move.l	n16384,d1	;mutiply by 16384
	jsr	SPMul(a6)
	jsr	SPFix(a6)	;convert to integer
	movem.l	(a7)+,d1-d2/a0
	move.w	d0,(a0)+
	dbra	d2,sinlp
	move.l	#0,rot

	move.w	#0,current

;Main loop
loop
pause1	btst.b	#0,$dff005	;Wait until
	beq	pause1		;end of frame
pause2	btst.b	#0,$dff005
	bne	pause2

;swap screen pointer
	lea	Planeadr1,a0	;point to screen1 pointer
	not.w	current		;"current" is either 0 or -1
	bne	screen1
	adda.l	#4,a0		;point to screen2 pointer
screen1	move.l	(a0),a0		;get screen address

;Clear screen, with blitter
;Use only channel D for speed.
;Make channel D always output zeros, so clearing the screen.
WBlit2	btst	#14,DMACONR(a5)	;wait until blitter has
	bne	WBlit2		;finished last operation
	move.l	a0,BLTDPTH(a5)
	move.w	#0,BLTDMOD(a5)
	move.w	#%0000000100000000,BLTCON0(a5)	;channel D only
	move.w	#%0000000000000000,BLTCON1(a5)
	move.w	#Planeheight*64+Planewidth/2,BLTSIZE(a5)
WBlit4	btst	#14,DMACONR(a5)	;wait until last blitter operation
	bne	WBlit4		;is finished

;set registers for putting bobs on screen.
;All of these registers do not need to be changed once set.
;Channel A is the bob graphic
;Channel B is the mask
;Channel C is the existing screen
;Channel D is output to screen
;Take word from C, reset the bits from the mask(B) and 'OR' the bits from A
;Put result in D.
	move.w	#0,BLTAMOD(a5)
	move.w	#0,BLTBMOD(a5)
	move.w	#Planewidth-4,BLTCMOD(a5)
	move.w	#Planewidth-4,BLTDMOD(a5)
	move.l	#$ffffffff,BLTAFWM(a5)
	move.l	bobadr,a3
	move.l	a3,a4
	add.l	#boblen,a4
	move.w	#Planewidth,d5


;Do bobs
dobobs	move.w	rx,d2
	move.w	ry,d3
	btst	#2,$dff016
	beq	jjjjjj
	add.w	#4,d2
	add.w	#0,d3
jjjjjj	and.w	#$1ff,d2
	and.w	#$1ff,d3
	move.w	d2,rx
	move.w	d3,ry
	lea	sindat,a1
	move.l	#169,d4
boblp	and.w	#$1ff,d2
	and.w	#$1ff,d3
	move.w	(a1,d2.w),d0
	move.w	(a1,d3.w),d1
	asr.w	#8,d0		;divide by 256
	asr.w	#8,d1		;divide by 256
	add.w	#160,d0
	add.w	#128,d1
	cmp.w	#256,d1
	bhi	sg
	cmp.w	#320-32,d0
	bhi	sg
	bsr	bob
sg	add.w	#2,d2
	add.w	#100,d3
	dbra	d4,boblp
;	move.w	#0,$dff180

;Update Copper-List (swap screen)
	move.l	a0,d0
	move.l	CLadr,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

;Check break - loop
	bclr.b	#1,$bfe001
	cmp.b	#$39,$bfec01
	beq	break
	btst	#6,$bfe001
	beq	break
	bra	loop

break	rts


;----------Put bob onto screen----------

bob:
WBlit3	btst	#14,DMACONR(a5)
	bne	WBlit3
	move.l	a0,a2
	clr.l	d6
	clr.l	d7
	move.w	d0,d6
	move.w	d1,d7
	mulu	d5,d7
	lsr.w	#3,d6
	add.w	d6,d7
	add.l	d7,a2
	move.l	a3,BLTAPTH(a5)
	move.l	a4,BLTBPTH(a5)
	move.l	a2,BLTCPTH(a5)
	move.l	a2,BLTDPTH(a5)
	move.w	d0,d6
	and.w	#15,d6
	ror.w	#4,d6
	move.w	d6,d7
	or.w	#%0000111111110010,d6
	move.w	d6,BLTCON0(a5)
	move.w	d7,BLTCON1(a5)
	move.w	#16*64+2,BLTSIZE(a5)
	rts
	

bobgraph:
	dc.l	%0000000000000000*$10000
	dc.l	%0000001111000000*$10000
	dc.l	%0000111111110000*$10000
	dc.l	%0001110000111000*$10000
	dc.l	%0011000000001100*$10000
	dc.l	%0011000000001100*$10000
	dc.l	%0110000000000110*$10000
	dc.l	%0110000000000110*$10000
	dc.l	%0110000000000110*$10000
	dc.l	%0110000000000110*$10000
	dc.l	%0011000000001100*$10000
	dc.l	%0011000000001100*$10000
	dc.l	%0001110000111000*$10000
	dc.l	%0000111111110000*$10000
	dc.l	%0000001111000000*$10000
	dc.l	%0000000000000000*$10000
bobmask:
	dc.l	%0000001111000000*$10000
	dc.l	%0000111111110000*$10000
	dc.l	%0011111111111100*$10000
	dc.l	%0011111111111100*$10000
	dc.l	%0111110000111110*$10000
	dc.l	%0111100000011110*$10000
	dc.l	%1111000000001111*$10000
	dc.l	%1111000000001111*$10000
	dc.l	%1111000000001111*$10000
	dc.l	%1111000000001111*$10000
	dc.l	%0111100000011110*$10000
	dc.l	%0111110000111110*$10000
	dc.l	%0011111111111100*$10000
	dc.l	%0011111111111100*$10000
	dc.l	%0000111111110000*$10000
	dc.l	%0000001111000000*$10000
bobend
bobadr	dc.l	0

bobsize	= bobend-bobgraph
boblen	= bobmask-bobgraph


Planeadr1	dc.l	0
Planeadr2	dc.l	0
CLadr	dc.l	0

current	dc.l	0
rx	dc.w	0
ry	dc.w	64


sindat	ds.w	320

;floating point storage
pi	dc.l	0
pi2	dc.l	0
rot	dc.l	0
rotstep	dc.l	0
n2	dc.l	0
n128	dc.l	0
n16384	dc.l	0


grname	dc.b	"graphics.library",0
	even
grbase	dc.l	0

