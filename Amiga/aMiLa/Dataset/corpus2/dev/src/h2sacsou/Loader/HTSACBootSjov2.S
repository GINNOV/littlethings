ùúùúÿðXÇÿðXÇÿðXÇÿðXÇÿðXÇÿðXÇÿðXÇÿðXÇÿðXÇ;-------T---------T
	AUTO	ws\Boot\0\2\cc\

Boot:	DC.B	'DOS',0
	DC.L	0
	DC.B	'Melon Dezign! '

Begin:	movem.l	d0/d1/a0/a1/a6,-(sp)
	lea	gfx(pc),a1
	jsr	-408(a6)		;OldOpenLibrary("graphics.library")
	move.l	d0,a6
	sub.l	a1,a1
	jsr	-222(a6)		;LoadView(NULL)
	bra.b	.ahah
	bra.b	Begin
.ahah	movem.l	(sp)+,d0/d1/a0/a1/a6
	lea	Begin(pc),a2
	lea	$50000,a3
	moveq	#(EOB-Begin)/4,d2
.cloop	move.l	(a2)+,(a3)+
	dbra	d2,.cloop
	jmp	$50000+.jump-Begin
.jump	lea	$DFF000,a5
	move.w	$004(a5),d0
	andi.w	#$2000,d0
	beq.b	.nopal
	move.w	#$20,$1DC(a5)
.nopal	bset	#1,$BFE001		;FILTER OFF
	move.w	#2,$1c(a1)		;Command
	move.l	#$70000,$28(a1)	;Mem-location
	move.l	#512*31,$24(a1)	;Length
	move.l	#512*2,$2c(a1)	;Offset
	jsr	-456(a6)		;DoIO
	move.w	#$7FFF,$09A(a5)	;INTENA
	move.w	#$7FFF,$096(a5)	;DMACON
	lea	$70000,a0
	lea	$100.w,a1
	move.w	#512*31/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	jmp	$100.w

gfx:	dc.b	'graphics.library',0
	EVEN

EOB:
	IF	(EOB-Boot)>64*3
	FAIL	Boot too big!!!!
	ELSE
	PRINTT	"Plads til overs:"
	PRINTV	64*3-(EOB-Boot)
	ENDC

	blk.b	64*3-(EOB-Boot),' '

	;0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
 dc.b	'                                                                '
 dc.b	'>--------------------------------------------------------------<'
 dc.b	'>                                                              <'
 dc.b	'>  Melon Dezign presents:                                      <'
 dc.b	'>                                                              <'
 dc.b	'>    HOW TO SKIN A CAT!         Code  - Slammer                <'
 dc.b	'>                               Gfx   - Solnova, Mack          <'
 dc.b	'>                               Music - Nuke/Lemon.            <'
 dc.b	'>                                                              <'
 dc.b	'>                     Spread like hell!!!!                     <'
 dc.b	'>                                                              <'
 dc.b	'>--------------------------------------------------------------<'
 dc.b	'                                                                '

