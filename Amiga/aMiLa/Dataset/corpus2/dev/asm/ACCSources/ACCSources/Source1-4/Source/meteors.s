;Meteors (C)1988 by Brian Postma

loadrgb4	=	-192
clipblit	=	-552
writepixel	=	-324
movesprite	=	-426
freesprite	=	-414
text	=	-60
move	=	-240

openlibrary	=	-408
closelibrary	=	-414
forbid	=	-132
permit	=	-138

openscreen	=	-198
closescreen	=	-66

execbase	=	4

start:
	bsr	openlibs
	bsr	newscreen
loop3:
	bra	display
back:
	bsr	init
	bsr	irqinit
	move.w	$dff00e,d0
	move.w	#%0001000001000001,$dff098	
	bsr	gameon
	move.l	oldirq,$6c
	move.l	#0,d0
	move.l	gfxbase,a6
	jsr	freesprite(a6)
	bra	loop3	

openlibs:
	move.l	execbase,a6
	jsr	forbid(a6)
	lea	intname,a1
	jsr	openlibrary(a6)
	move.l	d0,intbase
	lea	gfxname,a1
	jsr	openlibrary(a6)
	move.l	d0,gfxbase
	rts

newscreen:
	move.l	intbase,a6
	lea	osargs,a0
	jsr	openscreen(a6)
	move.l	d0,screenbase
	add.l	#44,d0
	move.l	d0,viewport
	add.l	#40,d0
	move.l	d0,rastport
	move.l	gfxbase,a6
	move.l	viewport,a0
	lea	colors,a1
	move.l	#32,d0
	jsr	loadrgb4(a6)
	rts

cls:
	move.l	screenbase,a0
	add.l	#192,a0
	move.l	(a0),a1
	move.l	#10240,d0
lus:
	move.b	#0,(a1)+
	dbra	d0,lus
	rts
init:
	bsr	cls
	move.l	#160,x
	move.l	#20,y
	move.w	#0,score
	rts

display:
	bsr	cls
	move.l	gfxbase,a6
	move.l	rastport,a1
	move.l	#68,d0
	move.l	#100,d1
	jsr	move(a6)
	lea	string,a0
	move.l	#23,d0
	jsr	text(a6)
	move.l	rastport,a1
	move.l	#84,d0
	move.l	#140,d1
	jsr	move(a6)
	bsr	calscore
wait:
	btst	#6,$bfe001
	beq	closestuff
	btst	#7,$bfe001
	bne	wait
	bra	back

calscore:
	move.l	#4,d3
	lea	scoretext,a0
	move.w	#10000,d2
loop2:
	clr.l	d0	
	move.w	score,d0
	divu	d2,d0
	add.b	#$30,d0
	move.b	d0,(a0)+
	swap	d0
	move.w	d0,score
	divu	#10,d2
	dbra	d3,loop2	
	move.l	gfxbase,a6
	move.l	rastport,a1
	lea	scoret,a0
	move.l	#19,d0
	jsr	text(a6)
	rts

closestuff:
	move.l	screenbase,a0
	move.l	intbase,a6
	jsr	closescreen(a6)
	move.l	execbase,a6
	move.l	gfxbase,a1
	jsr	closelibrary(a6)
	move.l	intbase,a1
	jsr	closelibrary(a6)
	rts

irqinit:
	move.l	$6c,oldirq
	move.l	#newirq,$6c
	rts

newirq:
	move.w	$dff01e,d0
	and.w	#$10,d0
	beq	nocopirq
	move.w	#$0010,$dff09c
	rte
nocopirq:
	move.l	gfxbase,a6
	move.w	random,d0
loop:
	sub.w	#320,d0
	cmp.w	#320,d0
	bcc	loop
	move.l	#254,d1
	move.l	rastport,a1
	jsr	writepixel(a6)
	move.l	rastport,a0
	move.l	a0,a1
	move.l	#0,d0
	move.l	#1,d1
	move.l	#0,d2
	move.l	#0,d3
	move.l	#320,d4
	move.l	#255,d5
	move.l	#192,d6
	jsr	clipblit(a6)
	lea	simplesprite,a1
	move.l	viewport,a0
	move.l	x,d0
	move.l	y,d1
	addq.w	#1,score
	jsr	movesprite(a6)
	dc.w	$4ef9
oldirq:	dc.l	0

gameon:
	move.l	#100000,d0
delay:
	dbra	d0,delay
	bsr	joystick	
	move.w	random,d0
	add.w	$dff006,d0
	move.w	d0,random
	btst	#1,$dff00f
	beq	gameon
	rts

joystick:
	clr.w	$dff036	
	move.b	$dff00d,d1
	move.b	d1,d2
	lsr.b	#1,d2
	eor.b	d1,d2
	btst	#0,d2
	beq	notdown
	cmp.l	#200,y
	beq	notdown
	addq.l	#1,y
notdown:	
	btst	#1,$dff00d
	beq	notright
	cmp.l	#310,x
	beq	notright
	addq.l	#1,x	
notright:	
	move.b	$dff00c,d1
	move.b	d1,d2
	lsr.b	#1,d2
	eor.b	d1,d2
	btst	#0,d2
	beq	notup
	cmp.l	#1,y
	beq	notup
	subq.l	#1,y
notup:
	btst	#1,$dff00c
	beq	notleft
	cmp.l	#8,x
	beq	notleft
	subq.l	#1,x
notleft:
	rts
	
random:	dc.w	0
gfxbase:	dc.l	0
intbase:	dc.l	0
screenbase:	dc.l	0
viewport:	dc.l	0
rastport:	dc.l	0
score:	dc.w	0
intname:	dc.b	"intuition.library",0
gfxname:	dc.b	"graphics.library",0
	even
osargs:
	dc.w	0,0,320,256,1
	dc.b	0,1
	dc.w	0,0
	dc.l	0,0,0,0

	section	data,data_c

colors:
	dc.w	$0000,$0fff,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$0f00,$00f0,$000f,0,0,0,0,0,0,0,0,0,0,0,0

x:	dc.l	160
y:	dc.l	10
simplesprite:
	dc.l	sprite
	dc.w	7,0,0,0
sprite:
	dc.w	%0111000000001110,%0111000000001110
	dc.w	%0111001111001110,%0111000000001110
	dc.w	%0111001001001110,%0111000110001110
	dc.w	%0011101001011100,%0011100110011100
	dc.w	%0001111001111000,%0001110110111000
	dc.w	%0000001111000000,%0000000000000000
	dc.w	%0000000110000000,%0000000000000000
	dc.w	%0000000110000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000

string:
	dc.b	"METEORS by Brian Postma",0
scoret:
	dc.b	"Last Score : "
scoretext:
	dc.b	"000000",0


