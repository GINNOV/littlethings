

; hidden linevector con clip linee. FA UN PO' SCHIFINO...

	section	bau,code

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


LarghSchermo	=	320
LunghSchermo	=	256


START:
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA
	move.l	#0,$108(a5)
	move.l	#$2c812cc1,$8e(a5)
	move.l	#$003800d0,$92(a5)
	move.w	#%0001001000000000,$100(a5)
	move.l	#0,$102(a5)
	move.l	#0,$108(a5)

mainloop:
	move.w	$dff01e,d0
	btst.l	#5,d0
	beq.s	mainloop
	move.l	pln(PC),d0
	swap	d0
	move.w	d0,coplist+10
	move.l	d0,pln
	bsr.w	clrscreen
	bsr.w	joy
	cmp.w	#360*2,rx
	blt.s	xok
	moveq	#0,d0
	move.w	d0,rx
xok:
	cmp.w	#360*2,ry
	blt.s	yok
	moveq	#0,d0
	move.w	d0,ry
yok:
	lea	surfaces(pc),a3
	move.w	numsur(PC),d7
mlp:
	bsr.s	transform
	tst.w	eflg
	bne.s	cazzend
	bsr.w	backs
	bsr.w	project
	dbra	d7,mlp
cazzend:
	move.w	#$20,$dff09c
	btst.b	#6,$bfe001
	bne.s	mainloop
	rts


transform:
	movem.l	d3-d7/a0-a2,-(sp)
	moveq	#0,d0
	move.w	d0,eflg
	lea	pointtab(pc),a4
	lea	transpts(pc),a2
	move.w	(a3)+,d6
	move.w	d6,curnum
	addq.w	#1,d6
tloop:
	move.w	(a3)+,d5
	movem.w	(a4,d5.w),d0-d2
;	add.w	add(PC),d2
	lea	sintab(pc),a0
	lea	costab(pc),a1
	bsr.s	y_ax
	bsr.s	x_ax
;	bsr.w	z_ax
;	add.w	#obz,d2
	add.w	add(PC),d2
	cmp.w	#obz-obz/10,d2
	bge.s	endtrf
	movem.w	d0-d2,(a2)
	addq.w	#6,a2
	dbra	d6,tloop
	movem.l	(sp)+,d3-d7/a0-a2
	rts

endtrf:
	moveq	#1,d0
	move.w	d0,eflg
	movem.l	(sp)+,d3-d7/a0-a2
	rts

x_ax:
	move.w	rx(PC),d3
	move.l	d1,d4
	move.l	d2,d7
	muls.w	(a1,d3.w),d1
	muls.w	(a0,d3.w),d2
	lsl.l	#4,d1
	lsl.l	#4,d2
	swap	d1
	swap	d2
	sub.w	d2,d1
	muls.w	(a0,d3.w),d4
	muls.w	(a1,d3.w),d7
	lsl.l	#4,d4
	lsl.l	#4,d7
	swap	d4
	swap	d7
	add.w	d7,d4
	move.l	d4,d2
	rts

y_ax:
	move ry(PC),d3
	move.l	d0,d4
	move.l	d2,d7
	muls.w	(a1,d3.w),d0
	muls.w	(a0,d3.w),d2
	lsl.l	#4,d0
	lsl.l	#4,d2
	swap	d0
	swap	d2
	add.w	d2,d0
	neg.w	d4
	muls.w	(a0,d3.w),d4
	muls.w	(a1,d3.w),d7
	lsl.l	#4,d4
	lsl.l	#4,d7
	swap	d4
	swap	d7
	add.w	d7,d4
	move.l	d4,d2
	rts

z_ax:
	move.w	rz(PC),d3
	move.l	d0,d4
	move.l	d1,d7
	muls.w	(a1,d3.w),d0
	muls.w	(a0,d3.w),d1
	lsl.l	#4,d0
	lsl.l	#4,d1
	swap	d0
	swap	d1
	sub.w	d1,d0
	muls.w	(a0,d3.w),d4
	muls.w	(a1,d3.w),d7
	lsl.l	#4,d4
	lsl.l	#4,d7
	swap	d4
	swap	d7
	add.w	d7,d4
	move.l	d4,d1
	rts

backs:
	lea	transpts(pc),a2
	movem.w	(a2)+,d0-d2
	movem.w	(a2)+,d3-d5
	sub.w	d0,d3
	sub.w	d1,d4
	sub.w	d2,d5
	lea	vx(pc),a1
	movem.w	d3-d5,(a1)
	movem.w	(a2),d3-d5
	sub.w	d0,d3
	sub.w	d1,d4
	sub.w	d2,d5
	lea	wx(pc),a1
	movem.w	d3-d5,(a1)
	move.w	vy(PC),d0
	muls.w	d0,d5
	move.w	vz(PC),d0
	muls.w	d0,d4
	sub.w	d4,d5
	move.w	d5,px
	move.w	vz(PC),d0
	muls.w	d0,d3
	move.w	vx(PC),d0
	move.w	wz(PC),d1
	muls.w	d0,d1
	sub.w	d1,d3
	move.w	d3,py
	move.w	vx(PC),d0
	move.w	wy(PC),d3
	muls.w	d0,d3
	move.w	vy(PC),d0
	move.w	wx(PC),d1
	muls.w	d0,d1
	sub.w	d1,d3
	move.w	d3,pz
	moveq	#0,d0
	move.w	d0,eflg
	lea	transpts(pc),a2
	movem.w	(a2)+,d0-d2
	sub.w	#obz,d2
	muls.w	px(PC),d0
	muls.w	py(PC),d1
	muls.w	pz(PC),d2
	add.l	d2,d1
	add.l	d1,d0
	bgt.s	visib
	moveq	#1,d0
	move.w	d0,eflg
visib:
	rts

project:
	cmp.w	#1,eflg
	beq.s	endpro
	movem.l	d7/a0-a3,-(sp)
	lea	transpts(pc),a2
	movem.w	(a2)+,d0-d2
	bsr.s	centr
	move.w	d0,xold
	move.w	d1,yold
	move.w	d0,xfst
	move.w	d1,yfst
	move.w	curnum(PC),d6
ploop:
	movem.w	(a2)+,d0-d2
	bsr.s	centr
	move.w	xold(PC),d2
	move.w	yold(PC),d3
	move.w	d0,xold
	move.w	d1,yold
	bsr.s	draw
	dbra	d6,ploop
	move.w	xold(PC),d0
	move.w	yold(PC),d1
	move.w	xfst(PC),d2
	move.w	yfst(PC),d3
	bsr.s	draw
endpro1:
	movem.l (sp)+,d7/a0-a3
	rts

endpro:
	moveq	#0,d0
	move.w	d0,eflg
	rts

centr:
	moveq	#0,d3
	moveq	#0,d4
	move.w	#obz,d5
	sub.w	d5,d2
	tst.w	d2
	beq.s	ce
	sub.w	d4,d1
	sub.w	d3,d0
	muls.w	d5,d1
	muls.w	d5,d0
	divs.w	d2,d1
	divs.w	d2,d0
	sub.w	d1,d4
	sub.w	d0,d3
	move.w	d3,d0
	move.w	d4,d1
	neg.w	d1
	add.w	#160,d0
	add.w	#128,d1
ce:
	rts

draw:
	movem.l	d4-d7,-(sp)
onceag:
	cmp.w	d0,d2
	bne.s	draw1
	cmp.w	d1,d3
	bne.s	draw1
	movem.l (sp)+,d4-d7
	rts

draw1:
	moveq	#0,d6
	tst.w	d1
	bmi.s	cty11
	tst.w	d3
	bmi.s	cty12
	move.w	#255,d6
	cmp.w	d6,d1
	bgt.s	cty21
	cmp.w	d6,d3
	bgt.s	cty22
	moveq	#0,d6
	tst.w	d0
	bmi.s	ctx11
	tst.w	d2
	bmi.s	ctx12
	move.w	#319,d6
	cmp.w	d6,d0
	bgt.s	ctx21
	cmp.w	d6,d2
	bgt.s	ctx22
	bra.w	drawline

cty11:
	tst.w	d3
	bmi.s	clpend
	bsr.s	clipy
	move.w	d4,d0
	moveq	#0,d1
	bra.s	onceag

cty12:
	bsr.s	clipy
	move.w	d4,d2
	moveq	#0,d3
	bra.s	onceag

cty21:
	cmp.w d6,d3
	bgt.s clpend
	bsr.s clipy
	move.w d4,d0
	move.w d6,d1
	bra.s onceag

cty22:
	bsr.s clipy
	move.w d4,d2
	move.w d6,d3
	bra.s onceag

ctx11:
	tst.w d2
	bmi.s clpend
	bsr.s clipx
	move.w d4,d1
	moveq #0,d0
	bra.s onceag

ctx12:
	bsr.s clipx
	move.w d4,d3
	moveq #0,d2
	bra.s onceag

ctx21:
	cmp.w d6,d2
	bgt.s clpend
	bsr.s clipx
	move.w d4,d1
	move.w d6,d0
	bra onceag

ctx22:
	bsr.s clipx
	move.w d4,d3
	move.w d6,d2
	bra onceag

clpend:
	movem.l (sp)+,d4-d7
	rts

clipy:
	move.w d0,d4
	sub.w d2,d4
	move.w d3,d5
	move.w d3,d7
	sub.w d6,d7
	muls d7,d4
	sub.w d1,d5
	divs d5,d4
	add.w d2,d4
	rts

clipx:
	move.w d1,d4
	sub.w d3,d4
	move.w d2,d5
	move.w d2,d7
	sub.w d6,d7
	muls d7,d4
	sub.w d0,d5
	divs d5,d4
	add.w d3,d4
	rts

drawline:
	bsr line
	movem.l (sp)+,d4-d7
	rts

line:
	movem.l a0-a6,-(sp)
	moveq #40,d4
	move.l d4,a1
	mulu d1,d4
	moveq #-$10,d5
	and.w d0,d5
	lsr.w #3,d5
	add.w d5,d4
	add.l plnadr,d4
	add.w pln,d4
	moveq #0,d5
	sub.w d1,d3
	roxl.b #1,d5
	tst.w d3
	bge.s y2gy1
	neg.w d3

y2gy1:
	sub.w d0,d2
	roxl.b #1,d5
	tst.w d2
	bge.s x2gx1
	neg.w d2

x2gx1:
	move.w d3,d1
	sub.w d2,d1
	bge.s dygdx
	exg d2,d3

dygdx:
	roxl.b #1,d5
	move.b octtab(pc,d5),d5
	add.w d2,d2
	bsr wblt
	move.w d2,$dff062
	sub.w d3,d2
	bge.s signnl
	or.b #$40,d5

signnl:
	move.w d2,$dff052
	sub.w d3,d2
	move.w d2,$dff064
	move.w #$8000,$dff074
	move.w #-1,$dff072
	move.w #$ffff,$dff044
	and.w #$000f,d0
	ror.w #4,d0
	or.w miniterm,d0
	move.w d0,$dff040
	move.w d5,$dff042
	move.l d4,$dff048
	move.l d4,$dff054
	move.w a1,$dff060
	move.w a1,$dff066
	lsl.w #6,d3
	add.w #$42,d3
	move.w d3,$dff058
	movem.l (sp)+,a0-a6
	rts

octtab:
	dc.b 0*4+1
	dc.b 4*4+1
	dc.b 2*4+1
	dc.b 5*4+1
	dc.b 1*4+1
	dc.b 6*4+1
	dc.b 3*4+1
	dc.b 7*4+1
	even

wblt:
	btst #14,$dff002
	bne.s wblt
	rts

joy:
	move.w $dff00c,d0
	btst #1,d0
	bne.s right
	btst #9,d0
	bne.s left

testud:
	move.w d0,d1
	lsr.w #1,d1
	eor.w d1,d0
	btst #0,d0
	bne.s bckw
	btst #8,d0
	bne.s forw
	rts

right:
	addq.w #4,ry
	bra.s testud

left:
	subq.w #4,ry
	blt.s yneg
	bra.s testud

bckw:
	btst #7,$bfe001
	beq.s trmi
	subq.w #4,rx
	blt.s xneg
	rts

trmi:
	sub.w #60,add
	rts

forw:
	btst #7,$bfe001
	beq.s trpl
	addq.w #4,rx
	rts

trpl:
	add.w #60,add
	rts

yneg:
	add.w #360*2,ry
	bra.s testud

xneg:
	add.w #360*2,rx
	rts


clrscreen:
	bsr wblt
	move.l plnadr,a0
	moveq #0,d0
	move.w pln,d0
	add.l d0,a0
	move.w #0,$dff074
	move.l a0,$dff054
	move.w #0,$dff066
	move.l #$ffffffff,$dff044
	move.l #$1f00000,$dff040
	move.w #256*64+20,$dff058
	bsr wblt
	rts

plnadr: dc.l $60000 ;weil 512KB-ChipRam ! Ansonsten dc.l $e0000 !!
pln: dc.l $80000000
xold: dc.w 0
yold: dc.w 0
xfst: dc.w 0
yfst: dc.w 0
rx: dc.w 0
ry: dc.w 0
rz: dc.w 0
miniterm: dc.w $bca
add: dc.w -300
eflg: dc.w 0
curnum: dc.w 0
transpts: blk.w 3*4,0
px: dc.w 0
py: dc.w 0
pz: dc.w 0
vx: dc.w 0
vy: dc.w 0
vz: dc.w 0
wx: dc.w 0
wy: dc.w 0
wz: dc.w 0
numsur: dc.w 11-1

surfaces:
	dc.w 3-2,0*6,2*6,1*6
	dc.w 3-2,0*6,1*6,3*6
	dc.w 3-2,0*6,4*6,2*6
	dc.w 3-2,3*6,5*6,4*6
	dc.w 3-2,1*6,2*6,5*6
	dc.w 3-2,1*6,5*6,3*6
	dc.w 3-2,2*6,4*6,5*6
	dc.w 3-2,0*6,7*6,4*6
	dc.w 3-2,0*6,3*6,7*6
	dc.w 3-2,4*6,7*6,3*6
	dc.w 3-2,8*6,10*6,9*6

pointtab:
	dc.w -200,0,0,0,37,50,0,37,-50,150,0,75,150,0,-75,125,50,0
	dc.w 75,100,0,125,-25,0,145,12,37,145,12,-37,131,37,0


sintab:
	dc.w 0,$47,$8e,$d6
	dc.w $11d,$164,$1ac,$1f3
	dc.w $23a,$280,$2c7,$30d
	dc.w $353,$399,$3de,$424
	dc.w $469,$4ad,$4f1,$535,$578,$5bb,$5fe,$640
	dc.w $681,$6c3,$703,$743,$782,$7c1,$7ff,$83d
	dc.w $87a,$8b6,$8f2,$92d,$967,$9a1,$9d9,$a11
	dc.w $a48,$a7f,$ab4,$ae9,$b1d,$b50,$b82,$bb3
	dc.w $be3,$c13,$c41,$c6f,$c9b,$cc7,$cf1,$d1b
	dc.w $d43,$d6b,$d91,$db6,$ddb,$dfe,$e20,$e41
	dc.w $e61,$e80,$e9d,$eba,$ed5,$eef,$f08,$f20
	dc.w $f37,$f4d,$f61,$f74,$f86,$f97,$fa6,$fb4
	dc.w $fc1,$fcd,$fd8,$fe1,$fe9,$ff0,$ff6,$ffa
	dc.w $ffd,$fff
costab:
	dc.w $fff,$fff
	dc.w $ffd,$ffa,$ff6,$ff0,$fe9,$fe1,$fd8,$fcd
	dc.w $fc1,$fb4,$fa6,$f97,$f86,$f74,$f61,$f4d
	dc.w $f37,$f20,$f08,$eef,$ed5,$eba,$e9d,$e80
	dc.w $e61,$e41,$e20,$dfe,$dd8,$db6,$d91,$d6b
	dc.w $d43,$d1b,$cf1,$cc7,$c9b,$c6f,$c41,$c13
	dc.w $be3,$bb3,$b82,$b50,$b1d,$ae9,$ab4,$a7f
	dc.w $a48,$a11,$9d9,$9a1,$967,$92d,$8f2,$8b6
	dc.w $87a,$83d,$800,$7c1,$782,$743,$703,$6c3
	dc.w $682,$640,$5fe,$5bb,$578,$535,$4f1,$4ad
	dc.w $469,$424,$3de,$399,$353,$30d,$2c7,$280
	dc.w $23a,$1f3,$1ac,$165,$11d,$d6,$8e,$47
	dc.w 0,$ffb9,$ff12,$ff2a,$ffe3,$ff9c,$fe54,$fe0d
	dc.w $fdc6,$fd80,$fd39,$fcf3,$fcad,$fc67,$fc22,$fbdc
	dc.w $fb98,$fb53,$fb0f,$facb,$fa88,$fa45,$fa02,$f9c0
	dc.w $f97f,$f93d,$f8fd,$f8bd,$f87e,$f83f,$f801,$f7c3
	dc.w $f786,$f74a,$f70e,$f6d3,$f699,$f65f,$f627,$f5ef
	dc.w $f5b8,$f581,$f54c,$f517,$f4e3,$f4b0,$f47e,$f44d
	dc.w $f41d,$f3ed,$f3bf,$f391,$f365,$f339,$f30f,$f2e5
	dc.w $f2bd,$f295,$f26f,$f24a,$f225,$f202,$f1e0,$f1bf
	dc.w $f19f,$f180,$f163,$f146,$f12b,$f111,$f0f8,$f0e0
	dc.w $f0c9,$f0b3,$f09f,$f08c,$f07a,$f069,$f05a,$f04c
	dc.w $f03f,$f033,$f028,$f01f,$f017,$f010,$f00a,$f006
	dc.w $f003,$f001,$f001,$f001
	dc.w $f003,$f006,$f00a,$f010,$f017,$f01f,$f028,$f033
	dc.w $f03f,$f04c,$f05a,$f069,$f07a,$f08c,$f09f,$f0b3
	dc.w $f0c9,$f0e0,$f0f7,$f111,$f12b,$f146,$f163,$f180
	dc.w $f19f,$f1bf,$f1e0,$f202,$f225,$f24a,$f26f,$f295
	dc.w $f2bd,$f2e5,$f30f,$f339,$f365,$f391,$f3bf,$f3ed
	dc.w $f41d,$f44d,$f47e,$f4b0,$f4e3,$f517,$f54c,$f581
	dc.w $f5b8,$f5ef,$f627,$f65f,$f699,$f6d3,$f70e,$f74a
	dc.w $f786,$f7c3,$f800,$f83f,$f87d,$f8bd,$f8fd,$f93d
	dc.w $f97e,$f9c0,$fa02,$fa45,$fa88,$facb,$fb0f,$fb53
	dc.w $fb97,$fbdc,$fc22,$fc67,$fcad,$fcf3,$fd39,$fd80
	dc.w $fdc6,$fe0d,$fe54,$fe9b,$fee3,$ff2a,$ff71,$ffb9
	dc.w 0,$47,$8e,$d6
	dc.w $11d,$164,$1ac,$1f3
	dc.w $23a,$280,$2c7,$30d,$353,$399,$3de,$424
	dc.w $469,$4ad,$4f1,$535,$578,$5bb,$5fe,$640
	dc.w $681,$6c3,$703,$743,$782,$7c1,$7ff,$83d
	dc.w $87a,$8b6,$8f2,$92d,$967,$9a1,$9d9,$a11
	dc.w $a48,$a7f,$ab4,$ae9,$b1d,$b50,$b82,$bb3
	dc.w $be3,$c13,$c41,$c6f,$c9b,$cc7,$cf1,$d1b
	dc.w $d43,$d6b,$d91,$db6,$ddb,$dfe,$e20,$e41
	dc.w $e61,$e80,$e9d,$eba,$ed5,$eef,$f08,$f20
	dc.w $f37,$f4d,$f61,$f74,$f86,$f97,$fa6,$fb4
	dc.w $fc1,$fcd,$fd8,$fe1,$fe9,$ff0,$ff6,$ffa
	dc.w $ffd,$fff

obz = 1000

	section	bas,data_C

coplist:
	dc.w $2c01,-2,$e0,$6,$e2,0,$180,0,$182,$0af
	dc.w -1,-2

	end

