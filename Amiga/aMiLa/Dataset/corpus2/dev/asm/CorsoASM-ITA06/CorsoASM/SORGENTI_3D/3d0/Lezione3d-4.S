
	SECTION	3d1,CODE

s; sintab STANDARD OLD1 con aggiunto sintab prima di costab come VECTOR2
; e filledvector

*****************************************************************************
	include	"Assembler2:sorgenti4/startup1.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper, bitplane e blitter
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
	lea	$dff000,a6
	MOVE.W	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper

	lea 	bpls1(pc),a0
	lea 	bplanes,a1
	move.w	#4,d0
	move.w 	#$e0,d2
	bsr.w 	setbpl

	bsr.w 	initvectors
	bsr.w	setup
					; e sprites.

	move.l	#COPPERLIST,$80(a6)	; Puntiamo la nostra COP
	move.w	d0,$88(a6)		; Facciamo partire la COP
	move.w	#0,$1fc(a6)		; Disattiva l'AGA
	move.w	#$c00,$106(a6)		; Disattiva l'AGA
	move.w	#$11,$10c(a6)		; Disattiva l'AGA

mouse:
	CMP.b	#$ff,6(a6)	; linea 255?
	bne.s	mouse

	cmp.w	#6000,pers
	beq.s	nosub
	sub.w	#200,pers
nosub:
	bsr.s	move		; vector movement
	bsr.w 	swapscr		; scambia schermi doublebuffer
	bsr.w	angles
	bsr.w 	initrot
	bsr.w	rotate
	bsr.w	draw
right:
	btst	#2,$16(a6)	; tasto destro?
	bne.s	left
	move.w	#$ffff,d0
	bra.s	endit
left:
	btst 	#6,$bfe001	; tasto sinistro?
	bne.s 	mouse
	moveq	#0,d0
endit:
	rts

* Vectormovement control routine

move:
	tst.w	counter
	beq.s	allok
	subq.w	#1,counter
	bra.s	endmove
allok:	tst.w	xyzok
	beq.s	xyzadd
	add.l	#14,entry
	cmp.l	#tabend-movetab,entry
	bne.s	notyet
	clr.l	entry
notyet:	lea	movetab(pc),a0
	add.l	entry(pc),a0
	move.w	(a0),counter
	move.w	2(a0),xspeed
	move.w	4(a0),yspeed
	move.w	6(a0),zspeed
	clr.w	xyzok
	clr.l	xok
	clr.w	zok
endmove:rts

* Angle adjustments

xyzadd:	lea	movetab(pc),a0
	add.l	entry(pc),a0
	move.w	8(a0),d0
	move.w	10(a0),d1
	move.w	12(a0),d2

testx:	cmp.w	xangle(pc),d0
	blt.s	minx
	bhi.s	morex
	clr.w	xspeed
	move.w	#$ffff,xok
	bra.s	testy
morex:	move.w	#2,xspeed
	clr.w	xok
	bra.s	testy
minx:	move.w	#718,xspeed
	clr.w	xok

testy:	cmp.w	yangle(pc),d1
	blt.s	miny
	bhi.s	morey
	clr.w	yspeed
	move.w	#$ffff,yok
	bra.s	testz
morey:	move.w	#2,yspeed
	clr.w	yok
	bra.s	testz
miny:	move.w	#718,yspeed
	clr.w	yok

testz:	cmp.w	zangle(pc),d2
	blt.s	minz
	bhi.s	morez
	clr.w	zspeed
	move.w	#$ffff,zok
	bra.s	testall
morez:	move.w	#2,zspeed
	clr.w	zok
	bra.s	testall
minz:	move.w	#718,zspeed
	clr.w	zok
testall:tst.w	xok
	beq.s	notok
	tst.w	yok
	beq.s	notok
	tst.w	zok
	beq.s	notok
	move.w	#$ffff,xyzok
	bra.w	endmove
notok:	clr.w	xyzok
	bra.w	endmove


;;;;

* Scroll colors setup & text printout

setup:	movem.l	d0-d7/a0-a6,-(a7)	;scrollcolors
	clr.l	d0
	move.w	movetab(pc),d0
	move.w	d0,counter
	movem.l	(a7)+,d0-d7/a0-a6
	rts


* LineDraw routine

draw:	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	clsrg,d0-d7
	lea	lines(pc),a0
	lea	xtable(pc),a1
	lea	ytable(pc),a2
readlin:move.w	(a0)+,d4
	cmp.w	#$ff,d4
	beq.s	enddraw
	move.w	(a1,d4.w),d0
	move.w	(a2,d4.w),d1
	move.w	(a0)+,d4
	move.w	(a1,d4.w),d2 
	move.w	(a2,d4.w),d3 
	bra.s	drawlin
enddraw:movem.l	(a7)+,d0-d7/a0-a6
	rts

drawlin:movem.l	d0-d7/a0-a6,-(a7)
	move.l	pl1(pc),a0
	add.l	#[120*42],a0
	move.w	#42,a1

	cmp.w	d0,d2
	bne.s	nolik
	cmp.w	d1,d3
	bne.s	nolik
	addq.w	#1,d2
	addq.w	#1,d3
	
nolik:	move.l	a1,d4
	mulu	d1,d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a0,d4

	clr.l	d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.s	y2gy1
	neg.w	d3
y2gy1:	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.s	x2gx1
	neg.w	d2
x2gx1:	move.w	d3,d1
	sub.w	d2,d1
	bge.s	dygdx
	exg	d2,d3
dygdx:	roxl.b	#1,d5
	move.b	okttab(pc,d5.w),d5
	add.w	d2,d2
wblit:	btst	#14,$02(a6)
	bne.s	wblit
	move.w	d2,$62(a6)
	sub.w	d3,d2
	bge.s	signnl
	or.b	#$40,d5
signnl:	move.w	d2,$52(a6)
	sub.w	d3,d2
	move.w	d2,$64(a6)
	move.l	#$ffff8000,$72(a6)
	move.w	#$ffff,$44(a6)
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,$40(a6)
	move.w	d5,$42(a6)
	move.l	d4,$48(a6)
	move.l	d4,$54(a6)
	move.w	a1,$60(a6)
	move.w	a1,$66(a6)
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$58(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	bra.w	readlin

okttab:	dc.b	0*4+1,4*4+1,2*4+1,5*4+1	;okt 6,7,5,4
	dc.b	1*4+1,6*4+1,3*4+1,7*4+1	;okt 1,0,2,3
	even

* Vector initial routine

initvectors:
	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	clsrg,d0-d7/a0-a6
	lea	Object1(pc),a0
init1:
	move.w	(a0),d0
	cmp.w	#$ff,d0
	beq.s	init2
	muls	#84,d0  	; (5461/85) = 65
	move.w	d0,(a0)+	; MAXVERDI I TABELL = 64 FOR X,Y,Z
	bra.s	init1
init2:
	addq.w	#2,a0
	move.w	(a0),d0
	cmp.w	#$ff,d0
	beq.s	initend
	muls	#2,d0
	move.w	d0,(a0)
	bra.s	init2
initend:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Vector [x,y,z] rotations

rotate:	movem.l	d0-d7/a0-a6,-(a7)
	lea 	Object1(pc),a0
	lea	xtable(pc),a1
	lea	ytable(pc),a2
	lea	ztable(pc),a3

ReadVec:move.w 	(a0)+,d0	; Les inn (X,Y,Z) - (d0.W,d1.W,d2.W)
	cmp.w 	#$ff,d0
	beq.w 	endrot
	move.w 	(a0)+,d1
	move.w 	(a0)+,d2
	move.w	d0,d3		; Start rotering av X,Y og Z
	move.w	d1,d4
	move.w	d2,d5
	muls	xx(pc),d0
	muls	xy(pc),d4
	muls	xz(pc),d5
	sub.l	d4,d0
	sub.l	d5,d0
	lsl.l	#2,d0
	swap	d0		; Rotert X i 3D-format
	move.w	d3,d4
	move.w	d1,d5
	move.w	d2,d6
	muls	yx(pc),d3
	muls	yy(pc),d1
	muls	yz(pc),d6
	add.l	d3,d1
	sub.l	d6,d1
	lsl.l	#2,d1
	swap	d1		; Rotert Y i 3D-format
	muls	zx(pc),d4
	muls	zy(pc),d5
	muls	zz(pc),d2
	add.l	d4,d2
	add.l	d5,d2
	lsl.l	#2,d2
	swap	d2		; Rotert Z i 3D-format
	move.w	d2,(a3)+	; Lagre Z i tabell for sortering
	add.w	xadd(pc),d0
	add.w	yadd(pc),d1
	muls	xpers(pc),d0	; Her begynner beregning av  
	muls	xpers(pc),d1	; perspektivet (3D - 2D convert)
	 
	add.w	pers(pc),d2
	tst.w	d2
	beq.s	zero
	divs	d2,d0
	divs	d2,d1
zero:	add.w	xsentrum(pc),d0
	add.w	ysentrum(pc),d1
	move.w	d0,(a1)+	; Lagre X i tabell (2D-format/skjerm)
	move.w	d1,(a2)+	; Lagre Y i tabell (2D-format/skjerm)
	bra.w	readvec
endrot:	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Vector Sine/Cosine angle calculations

initrot:movem.l	d0-d7/a0-a6,-(a7)
	lea	sinus(pc),a0
	lea	cosinus(pc),a1
	lea	xangle(pc),a2

	move.w	(a2)+,d0
	move.w	(a0,d0.w),sinx	
	move.w	(a1,d0.w),cosx
	move.w	(a2)+,d0
	move.w	(a0,d0.w),siny
	move.w	(a1,d0.w),cosy
	move.w	(a2)+,d0
	move.w	(a0,d0.w),sinz
	move.w	(a1,d0.w),cosz	
	move.w	sinz(pc),d0	; Her begynner beregning av
	muls	sinx(pc),d0	; generell X-rotering
	lsl.l	#2,d0
	swap	d0
	move.w	d0,d2
	muls	siny(pc),d0
	move.w	cosz(pc),d1
	muls	cosy(pc),d1
	sub.l	d0,d1
	lsl.l	#2,d1
	swap	d1
	move.w	d1,xx		; XX=CosZ*CosY-SinY*[SinZ*SinX]
	move.w	cosz(pc),d0
	muls	sinx(pc),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,d3
	muls	siny(pc),d0
	move.w	sinz(pc),d1
	muls	cosy(pc),d1
	add.l	d1,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,xy		; XY=SinY*[CosZ*SinX]+SinZ*CosY
	move.w	siny(pc),d0
	muls	cosx(pc),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,xz		; XZ=SinY*CosY
	move.w	sinz(pc),d0	; Her begynner beregning av
	muls	cosx(pc),d0	; generell Y-rotering
	lsl.l	#2,d0
	swap	d0
	move.w	d0,yx		; YX=SinZ*CosX
	move.w	cosz(pc),d0
	muls	cosx(pc),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,yy		; YY=CosZ*CosX
	move.w	sinx(pc),YZ	; YZ=SinX
	move.w	cosz(pc),d0	; Her begynner beregning av
	muls	siny(pc),d0	; generell Z-rotering
	muls	cosy(pc),d2
	add.l	d2,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,zx		; ZX=CosZ*SinY+CosY*[SinZ*SinX]
	muls	cosy(pc),d3
	move.w	sinz(pc),d0
	muls	siny(pc),d0
	sub.l	d0,d3
	lsl.l	#2,d3
	swap	d3
	move.w	d3,zy		; ZY=CosY*[CosZ*SinX]-SinZ*SinY
	move.w	cosy(pc),d0
	muls	cosx(pc),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,zz		; ZZ=CosY*CosX
	move.w	zsentrum(pc),d1	; Her beregnes generellt perspektiv
;	add.w	zadd(pc),d1
	move.l	perssub(pc),d0
	divs	d1,d0
	move.w	d0,xpers
	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Angle add/sub

angles:
	movem.l	d0-d7/a0-a6,-(a7)
	move.w	zspeed(pc),d0
	move.w	yspeed(pc),d1
	move.w	xspeed(pc),d2
	add.w	d0,zangle
	cmp.w	#719,zangle
	bmi.s	step1
	sub.w	#720,zangle
step1:
	add.w	d1,yangle
	cmp.w	#719,yangle
	bmi.s	step2
	sub.w	#720,yangle
step2:
	add.w	d2,xangle
	cmp.w	#719,xangle
	bmi.s	step3
	sub.w	#720,xangle
step3:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Swap & clear screen

swapscr:
	movem.l	d0-d7/a0-a6,-(a7)
	bchg 	#1,swp
	beq.s 	screen2
screen1:
	lea 	bpls1(pc),a0
	lea 	bplanes,a1
	move.w 	#2,d0
	move.w 	#$00e0,d2
	bsr.w 	setbpl
	move.l 	#bpl1b,pl1
	bra.s	endswp

screen2:
	lea 	bpls2(pc),a0
	lea 	bplanes,a1
	move.w 	#3,d0
	move.w 	#$00e0,d2
	bsr.w 	setbpl
	move.l 	#bpl1a,pl1
endswp:	
	btst 	#14,$02(a6)
	bne.s 	endswp
	move.l 	pl1,$54(a6)
	move.l 	#$01000000,$40(a6)
	move.w 	#$0002,$66(a6)
	move.w 	#[[120+214]*64]+[320/16],$58(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rts


* Bitplane/Sprite 'allround' rout

setbpl:
	move.w	d2,(a1)+
	move.l	(a0)+,d1
	swap	d1
	move.w	d1,(a1)+
	addq.w	#2,d2
	move.w	d2,(a1)+
	swap	d1
	move.w	d1,(a1)+
	addq.w	#2,d2
	subq.w	#1,d0
	bne.s 	setbpl
	rts

* Variables

intenar:dc.w 	0
dmaconr:dc.w 	0
oldlev3:dc.l 	0
counter:dc.w	0
begun:	dc.w	0
;space:	dc.w	0
;howfar:	dc.w	0
entry:	dc.l	0
;wait:	dc.w	0
xok:	dc.w	0
yok:	dc.w	0
zok:	dc.w	0
xyzok:	dc.w	0
swp:	dc.w 	0
pers:	dc.w 	30000
perssub:dc.l 	50000
xsentrum:dc.w 	160
ysentrum:dc.w 	124
zsentrum:dc.w 	280
xadd:	dc.w 	0
yadd:	dc.w 	0
zadd:	dc.w 	0
xangle:	dc.w 	180*2
yangle:	dc.w 	0*2
zangle:	dc.w 	0*2
sinx:	dc.w 	0
cosx:	dc.w 	0
siny:	dc.w 	0
cosy:	dc.w 	0
sinz:	dc.w 	0
cosz:	dc.w 	0
xx:	dc.w 	0
xy:	dc.w 	0
xz:	dc.w 	0
yx:	dc.w 	0
yy:	dc.w 	0
yz:	dc.w 	0
zx:	dc.w 	0
zy:	dc.w 	0
zz:	dc.w 	0
xpers:	dc.w 	0
ypers:	dc.w 	0
xspeed:	dc.w	0
yspeed:	dc.w	0
zspeed:	dc.w	0
pl1:	dc.l 	bpl1a

numpunti	= 31

xtable:	dcb.w	numpunti,$ff
ytable:	dcb.w 	numpunti,$ff
ztable:	dcb.w 	numpunti,$ff
clsrg:	dcb.l	16,0


Object1:	; 31 triple coordinate x,y,z
	dc.w	-20,+20,-20	; P0 (X,Y,Z)
	dc.w	+20,+20,-20	; P1 (X,Y,Z)
	dc.w	+20,-20,-20	; P2 (X,Y,Z)
	dc.w	-20,-20,-20	; P3 (X,Y,Z)
	dc.w	-20,+20,+20	; P4 (X,Y,Z)
	dc.w	+20,+20,+20	; P5 (X,Y,Z)
	dc.w	+20,-20,+20	; P6 (X,Y,Z)
	dc.w	-20,-20,+20	; P7 (X,Y,Z)
	dc.w	$ff	; flag di fine

;	      (P4) -50,+50,+50______________+50,+50,+50 (P5)
;			     /|		   /|
;			    / |		  / |
;			   /  |		 /  |
;			  /   |		/   |
;	 (P0) -50,+50,-50/____|________/+50,+50,-50 (P1)
;			|     |       |     |
;			|     |_______|_____|+50,-50,+50 (P6)
;			|    /-50,-50,+50 (P7)
;			|   /	      |   /
;			|  /	      |  /
;			| /	      | /
;			|/____________|/+50,-50,-50 (P2)
;	 (P3) -50,-50,-50

; connessioni tra i punti: l'ordine e' a piacere, ma vedete di non tracciare
; la stessa linea 2 volte! Un cubo ha 12 spigoli, infatti ecco 12 connessioni

lines:
	dc.w	0,1	; faccia davanti
	dc.w	1,2
	dc.w	2,3
	dc.w	3,0

	dc.w	4,5	; faccia dietro
	dc.w	5,6
	dc.w	6,7
	dc.w	7,4

	dc.w	0,4	; spigoli laterali
	dc.w	1,5
	dc.w	2,6
	dc.w	3,7

	dc.w	$ff	; flag di fine
	
sinus:	; 90 valori
	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516,4790
	dc.w 5063,5334,5604,5872,6138,6402,6664,6924,7182
	dc.w 7438,7692,7943,8192,8438,8682,8923,9162,9397
	dc.w 9630,9860,10087,10311,10531,10749,10963,11174,11381
	dc.w 11585,11786,11982,12176,12365,12551,12733,12911,13085
	dc.w 13255,13421,13583,13741,13894,14044,14189,14330,14466
	dc.w 14598,14726,14849,14968,15082,15191,15296,15396,15491
	dc.w 15582,15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374,16382

cosinus: ;- altri 360 valori
	dc.w 16384,16382,16374,16362,16344,16322,16294,16262,16225
	dc.w 16182,16135,16083,16026,15964,15897,15826,15749,15668
	dc.w 15582,15491,15396,15296,15191,15082,14968,14849,14726
	dc.w 14598,14466,14330,14189,14044,13894,13741,13583,13421
	dc.w 13255,13085,12911,12733,12551,12365,12176,11982,11786
	dc.w 11585,11381,11174,10963,10749,10531,10311,10087,9860
	dc.w 9630,9397,9162,8923,8682,8438,8192,7943,7692
	dc.w 7438,7182,6924,6664,6402,6138,5872,5604,5334
	dc.w 5063,4790,4516,4240,3964,3686,3406,3126,2845
	dc.w 2563,2280,1997,1713,1428,1143,857,572,286
	dc.w 0,-286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516,-4790
	dc.w -5063,-5334,-5604,-5872,-6138,-6402,-6664,-6924,-7182
	dc.w -7438,-7692,-7943,-8192,-8438,-8682,-8923,-9162,-9397
	dc.w -9630,-9860,-10087,-10311,-10531,-10749,-10963,-11174,-11381
	dc.w -11585,-11786,-11982,-12176,-12365,-12551,-12733,-12911,-13085
	dc.w -13255,-13421,-13583,-13741,-13894,-14044,-14189,-14330,-14466
	dc.w -14598,-14726,-14849,-14968,-15082,-15191,-15296,-15396,-15491
	dc.w -15582,-15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374,-16382
	dc.w -16384,-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
	dc.w -16182,-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
	dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14968,-14849,-14726
	dc.w -14598,-14466,-14330,-14189,-14044,-13894,-13741,-13583,-13421
	dc.w -13255,-13085,-12911,-12733,-12551,-12365,-12176,-11982,-11786
	dc.w -11585,-11381,-11174,-10963,-10749,-10531,-10311,-10087,-9860
	dc.w -9630,-9397,-9162,-8923,-8682,-8438,-8192,-7943,-7692
	dc.w -7438,-7182,-6924,-6664,-6402,-6138,-5872,-5604,-5334
	dc.w -5063,-4790,-4516,-4240,-3964,-3686,-3406,-3126,-2845
	dc.w -2563,-2280,-1997,-1713,-1428,-1143,-857,-572,-286
	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516,4790
	dc.w 5063,5334,5604,5872,6138,6402,6664,6924,7182
	dc.w 7438,7692,7943,8192,8438,8682,8923,9162,9397
	dc.w 9630,9860,10087,10311,10531,10749,10963,11174,11381
	dc.w 11585,11786,11982,12176,12365,12551,12733,12911,13085
	dc.w 13255,13421,13583,13741,13894,14044,14189,14330,14466
	dc.w 14598,14726,14849,14968,15082,15191,15296,15396,15491
	dc.w 15582,15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374,16382


* VectorMovements table:
* entry: [duration in secs *50],xspeed,yspeed,zspeed
* then:  which angel to stop at/adjust to - x,y,z angle...

movetab:
	dc.w	[7*50],0,0,0,	180*2,0*2,0*2
	dc.w	[7*50],0,2,0,	180*2,0*2,0*2
	dc.w	[7*50],4,2,0,	180*2,0*2,0*2
	dc.w	[5*50],2,4,2,	180*2,0*2,0*2
	dc.w	[7*50],0,4,4,	180*2,0*2,0*2
	dc.w	[3*50],4,0,2,	180*2,0*2,0*2
tabend:

bpls1:	dc.l 	bpl1a,bpl2a,bpl3,bpl4
bpls2:	dc.l 	bpl1b,bpl2b,bpl3,bpl4


* Copper data

	Section	Coppy3d,data_C

copperlist:
	dc.w 	$008e,$2c71,$0090,$2cd1,$0092,$0038,$0094,$00d0
	dc.w	$0100,$4600,$0102,$0000,$0104,$0040,$0108,$0002
	dc.w 	$010a,$0002,$0120,$0000,$0122,$0000
bplanes:
	dcb.l	$0c,$00f60000
colors:
	dc.w	$0180,$0000,$0182,$0fff,$0184,$00ff,$0186,$0fff
	dc.w	$0188,$0fff,$018a,$0fff,$018c,$0fff,$018e,$0fff
	dc.w	$0190,$0000,$0192,$0f48	;<- color of Vectors here!
	dc.w	$0194,$0000,$0196,$0fff

	dc.w	$3001,$fffe,$0182,$0ddd
	dc.w	$8001,$fffe,$0182,$0777
	dc.w	$9401,$fffe,$0182,$0444
	dc.w	$b001,$fffe,$0108,-82
	dc.w	$c001,$fffe,$0182,$0444,$0194,$0112
	dc.w	$d401,$fffe,$0182,$0777
	dc.w	$e801,$fffe,$0182,$0ddd
	dc.w 	$ffff,$fffe


	section	bitplanes,bss_C

	ds.b	1024
bpl1a:	ds.b 	[336/8*120]
bpl2a:	ds.b	[336/8*258]
bpl1b:	ds.b 	[336/8*120]
bpl2b:	ds.b	[336/8*258]
bpl3:	ds.b	[336/8*256]
bpl4:	ds.b	[336/8*256]
prgend:

