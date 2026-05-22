
	section	bau,code
;----------------------------------------------
;	Hidden Lines V1.0
;	Coding by Morgan
;	© 1990 by NoLimits
;----------------------------------------------
	move.l 	4,a6
	jsr	-132(a6)
;w:	move.l	$dff004,d0
;	and.l	#$0001ff00,d0
;	cmp.l	#$00000800,d0
;	bne	w
	move.w	#$0020,$dff096	;sprite
	move.w	#$4000,$dff09a	;interupt
	move.w	#$8400,$dff096	;blitter nasty
	move.l	#copperliste,$dff080
	move.w	d0,$dff088
	move.w	#0,$dff1fc
	move.l	#0,$dff108

wait:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00001e00,d0
	bne	wait

	btst	#2,$dff016
	bne	wait2
	move.w	#$f00,$dff180
wait2:
	bsr	INTERUPT
	move.w	#$0,$dff180

	btst	#6,$bfe001
	bne	wait

	move.w	#$8020,$dff096
	move.w	#$c000,$dff09a
	move.l	4,a6
;	move.l	156(a6),a0	; urgh!
	lea	gfxname(pc),a1
	jsr	-$198(A6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	jsr	-138(a6)
	moveq	#0,d0
	rts

gfxname:
	dc.b	"graphics.library",0,0

;----------------------------------------------
;--------- INTERUPT ---------------------------
;----------------------------------------------

INTERUPT:
	move.l	screen1,d0
	move.l	screen2,d1
	move.l	d1,screen1
	move.l	d0,screen2
	lea	vectormap,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	move.l	cleartab1,d0
	move.l	cleartab2,d1
	move.l	d1,cleartab1
	move.l	d0,cleartab2
	
	bsr	vector
	rts

;----------------------------------------------
;--------- VECTOR -----------------------------
;----------------------------------------------
vector:
	bsr	clearline

;	move.w	#$f0,$dff180
	bsr	calcpunkt
;	move.w	#$f,$dff180

	bsr	drawline
	rts

;----------------------------------------------
;--------- CALCPUNKT --------------------------
;----------------------------------------------
calcpunkt:
	move.w	adder,d0
	move.w	adder+2,d1
	move.w	adder+4,d2
	lea	cvinkel,a1
	lea	svinkel,a2
	add.w	d0,(a1)
	and.w	#$1fe,(a1)+
	add.w	d0,(a2)
	and.w	#$1fe,(a2)+
	add.w	d1,(a1)
	and.w	#$1fe,(a1)+
	add.w	d1,(a2)
	and.w	#$1fe,(a2)+
	add.w	d2,(a1)
	and.w	#$1fe,(a1)+
	add.w	d2,(a2)
	and.w	#$1fe,(a2)+

	move.l	cordpointer,a0
	lea	sinetable,a1
	lea	punkt,a2
	move.w	(a0)+,d0

calcloop:
	move.w	(a0)+,d1		;x cord
	move.w	(a0)+,d2		;y cord
	move.w	(a0)+,d3		;z cord

;----------------------------------------------
;------- Z rotation ---------------------------
;----------------------------------------------

	move.w	cvinkel+4,d4		;z COS vinkel
	move.w	svinkel+4,d5		;z SIN vinkel

	move.w	d1,d6			;save x
	move.w	d2,d7			;save y
	muls	(a1,d4.w),d6		;x*COSzv
	muls	(a1,d5.w),d7		;y*SINzv
	sub.l	d7,d6			;xCOSzv-ySINzv

	muls	(a1,d5.w),d1		;x*SINzv
	muls	(a1,d4.w),d2		;y*COSzv
	add.l	d1,d2			;xSINzv+yCOSzv

	lsr.l	#8,d6
	lsr.l	#8,d2

;----------------------------------------------
;------- X rotation ---------------------------
;----------------------------------------------

	move.w	cvinkel,d4		;x COS vinkel
	move.w	svinkel,d5		;x SIN vinkel

	move.w	d2,d1			;save y
	move.w	d3,d7			;save z
	muls	(a1,d4.w),d1		;y*COSzv
	muls	(a1,d5.w),d7		;z*SINxv
	sub.l	d7,d1			;yCOSxv-zSINxv

	muls	(a1,d5.w),d2		;y*SINxv
	muls	(a1,d4.w),d3		;z*COSxv
	add.l	d2,d3			;ySINxv+zCOSxv

	lsr.l	#8,d1
	lsr.l	#8,d3

;----------------------------------------------
;------- Y rotation ---------------------------
;----------------------------------------------

	move.w	cvinkel+2,d4		;y COS vinkel
	move.w	svinkel+2,d5		;y SIN vinkel

	move.w	d3,d2			;save z
	move.w	d6,d7			;save x
	muls	(a1,d4.w),d2		;z*COSyv
	muls	(a1,d5.w),d7		;x*SINyv
	sub.l	d7,d2			;zCOSyv-xSINyv

	muls	(a1,d5.w),d3		;z*SINyv
	muls	(a1,d4.w),d6		;x*COSyv
	add.l	d3,d6			;zSINyv+xCOSyv

	lsr.l	#8,d2
	lsr.l	#8,d6

;----------------------------------------------
;------- PERSPECTIVE --------------------------
;----------------------------------------------

	add.w	avs(PC),d2
	muls	zoom(PC),d6
	muls	zoom(PC),d1
	divs	d2,d6
	divs	d2,d1

	addI.w	#160,d6
	addI.w	#128,d1
	move.w	d6,(a2)+
	move.w	d1,(a2)+

	dbf	d0,calcloop
	rts

;----------------------------------------------
;------- VECTOR DATA --------------------------
;----------------------------------------------
avs:		dc.w	2700
zoom:		dc.w	330

svinkel:	dc.w	0,0,0
cvinkel:	dc.w	128,128,128

adder:		dc.w	2,4,-2
		dc.w	0,2,0


cordpointer:	dc.l	cobj01
linespointer:	dc.l	lobj01
punkt:		blk.w	200,0

;----------------------------------------------
;------- OBJECTS ------------------------------
;----------------------------------------------
cobj01:
	dc.w	7		;box (8 punti)
	dc.w	 500, 500, 500
	dc.w	-500, 500, 500
	dc.w	-500,-500, 500
	dc.w	 500,-500, 500
	dc.w	 500, 500,-500
	dc.w	-500, 500,-500
	dc.w	-500,-500,-500
	dc.w	 500,-500,-500


;remember, when making surfases always list the cords clockwise
;on all surfaces!!!

lobj01:
	dc.w	5			;box (6 facce)
	dc.w	3, 1,5, 5,6, 6,2, 2,1	; faccia1 (4 punti)
	dc.w	3, 0,4, 4,5, 5,1, 1,0	; faccia2
	dc.w	3, 3,7, 7,4, 4,0, 0,3	; faccia3
	dc.w	3, 2,6, 6,7, 7,3, 3,2	; faccia4
	dc.w	3, 4,7, 7,6, 6,5, 5,4	; faccia5
	dc.w	3, 0,1, 1,2, 2,3, 3,0	; faccia6

;----------------------------------------------
;------- DRAW ROUTINE -------------------------
;----------------------------------------------
;
;	drawline
;
;d0 = x1
;d1 = y1
;d2 = x2
;d3 = y2
;a0 = planestart
;a1 = planewidth in bytes
;d4 - d6 = work registers

;----------------------------------------------
;------- CLEAR LINE ---------------------------
;----------------------------------------------
clearline:
	move.l	screen2,a0
	move.l	cleartab1,a5
	move.l	#$dff000,a6

clsloopz:
	btst	#14,2(a6)
	bne.s	clsloopz

	move.w	#$ffff,$44(a6)
	move.l	#$00008000,$72(a6)
	move.w	#40,$60(a6)
	move.w	#40,$66(a6)

	move.w	(a5)+,d7
	bmi	clsend
clsloop:
	btst	#14,2(a6)
	bne.s	clsloop
	move.w	(a5)+,$62(a6)
	move.w	(a5)+,$52(a6)
	move.w	(a5)+,$64(a6)
	move.w	(a5)+,$40(a6)
	move.w	(a5)+,$42(a6)
	move.l	(a5),$48(a6)
	move.l	(a5)+,$54(a6)
	move.w	(a5)+,$58(a6)
	dbf	d7,clsloop
clsend:	rts	


;----------------------------------------------
;------- DRAW LINE ----------------------------
;----------------------------------------------
drawline:
	move.l	screen2,a0
	lea	octant,a1
	move.l	cleartab1,a2
	move.l	linespointer,a3
	lea	punkt,a4
	move.l	cleartab1,a5
	addQ.l	#2,a5

	move.l	#$dff000,a6

clsloopy:
	btst	#14,2(a6)
	bne.s	clsloopy

	move.w	#$ffff,$44(a6)
	move.l	#$ffff8000,$72(a6)
	move.w	#40,$60(a6)
	move.w	#40,$66(a6)

	move.w	#-1,(a2)
	move.w	(a3)+,d7

loop:	moveq	#0,d6
	move.w	(a3)+,d6

	move.w	(a3),d1
	move.w	2(a3),d3
	move.w	6(a3),d5

	lsl.w	#2,d1
	lsl.w	#2,d3
	lsl.w	#2,d5
	move.w	(a4,d1.w),d0
	move.w	2(a4,d1.w),d1
	move.w	(a4,d3.w),d2
	move.w	2(a4,d3.w),d3
	move.w	(a4,d5.w),d4
	move.w	2(a4,d5.w),d5

	sub.w	d2,d0	;Xa
	sub.w	d3,d1	;Ya
	sub.w	d2,d4	;Xb
	sub.w	d3,d5	;Yb
	muls	d5,d0	;Xa * Yb
	muls	d4,d1	;Ya * Xb
	sub	d1,d0
	bgt	loop2
	
	addq.l	#1,d6
	lsl.l	#2,d6
	add.l	d6,a3
	bra	over2

loop2:	move.w	(a3)+,d1
	move.w	(a3)+,d3
	lsl.w	#2,d1
	lsl.w	#2,d3
	move.w	(a4,d1.w),d0
	move.w	2(a4,d1.w),d1
	move.w	(a4,d3.w),d2
	move.w	2(a4,d3.w),d3

	cmp.w	d0,d2  
	bne.S	c1 
	cmp	d1,d3
	bne.S	c1
	bra.w	over
c1:
	move.l	d1,d4
;	lsl.l	#5,d4		;32 skjerm
	mulu	#40,d4		;40 skjerm

	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a0,d4

	moveq 	#0,d5
	sub	d1,d3
	roxl.b	#1,d5
	tst	d3
	bge.s	y2gy1
	neg	d3
y2gy1:	
	sub	d0,d2
	roxl.b	#1,d5
	tst	d2
	bge.s	x2gx1
	neg	d2
x2gx1:	
	move.w	d3,d1
	sub.w	d2,d1
	bge.s	dygdx
	exg	d2,d3
dygdx:
	roxl.b	#1,d5
	move.b	(a1,d5.w),d5
	add.w	d2,d2
wblit:
	btst	#14,2(a6)
	bne.s	wblit
	move.w	d2,$62(a6)
	move.w	d2,(a5)+
	sub.w	d3,d2
	bge.s	signnl
	or.b	#$40,d5
signnl:	
	move.w	d2,$52(a6)
	move.w	d2,(a5)+
	sub.w	d3,d2
	move.w	d2,$64(a6)
	move.w	d2,(a5)+
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,$40(a6)
	move.w	d0,(a5)+
	move.w	d5,$42(a6)
	move.w	d5,(a5)+
	move.l	d4,$48(a6)
	move.l	d4,$54(a6)
	move.l	d4,(a5)+
	lsl.w	#6,d3
	addq.W	#2,d3
	move.w	d3,$58(a6)
	move.w	d3,(a5)+
	addQ.w	#1,(a2)

over:	dbf	d6,loop2
over2:	dbf	d7,loop
	rts

octant:	
  dc.b 1,17,9,21,5,25,13,29

;----------------------------------------------
;------- LINE DATA ----------------------------
;----------------------------------------------
screen1:	dc.l	BUFFER1
screen2:	dc.l	BUFFER2
cleartab1:	dc.l	cleartable1
cleartab2:	dc.l	cleartable2

cleartable1:	blk.b	20*80,-1
cleartable2:	blk.b	20*80,-1



;----------------------------------------------
;------- SINETABLE ----------------------------
;----------------------------------------------
sinetable:
	DC.W	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	DC.W	$0031,$0037,$003E,$0044,$004A,$0050,$0056,$005B
	DC.W	$0061,$0067,$006D,$0072,$0078,$007D,$0083,$0088
	DC.W	$008D,$0093,$0098,$009D,$00A2,$00A6,$00AB,$00B0
	DC.W	$00B4,$00B9,$00BD,$00C1,$00C5,$00C9,$00CD,$00D0
	DC.W	$00D4,$00D7,$00DB,$00DE,$00E1,$00E4,$00E6,$00E9
	DC.W	$00EC,$00EE,$00F0,$00F2,$00F4,$00F6,$00F7,$00F9
	DC.W	$00FA,$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF
	DC.W	$00FF,$00FF,$00FF,$00FE,$00FE,$00FD,$00FC,$00FB
	DC.W	$00FA,$00F9,$00F7,$00F6,$00F4,$00F2,$00F0,$00EE
	DC.W	$00EC,$00E9,$00E6,$00E4,$00E1,$00DE,$00DB,$00D7
	DC.W	$00D4,$00D0,$00CD,$00C9,$00C5,$00C1,$00BD,$00B9
	DC.W	$00B4,$00B0,$00AB,$00A6,$00A2,$009D,$0098,$0093
	DC.W	$008D,$0088,$0083,$007D,$0078,$0072,$006D,$0067
	DC.W	$0061,$005B,$0056,$0050,$004A,$0044,$003E,$0037
	DC.W	$0031,$002B,$0025,$001F,$0019,$0012,$000C,$0006
	DC.W	$FFFF,$FFF9,$FFF3,$FFED,$FFE6,$FFE0,$FFDA,$FFD4
	DC.W	$FFCE,$FFC8,$FFC1,$FFBB,$FFB5,$FFAF,$FFA9,$FFA4
	DC.W	$FF9E,$FF98,$FF92,$FF8D,$FF87,$FF82,$FF7C,$FF77
	DC.W	$FF72,$FF6C,$FF67,$FF62,$FF5D,$FF59,$FF54,$FF4F
	DC.W	$FF4B,$FF46,$FF42,$FF3E,$FF3A,$FF36,$FF32,$FF2F
	DC.W	$FF2B,$FF28,$FF24,$FF21,$FF1E,$FF1B,$FF19,$FF16
	DC.W	$FF13,$FF11,$FF0F,$FF0D,$FF0B,$FF09,$FF08,$FF06
	DC.W	$FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF01,$FF01
	DC.W	$FF01,$FF01,$FF01,$FF01,$FF01,$FF02,$FF03,$FF04
	DC.W	$FF05,$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11
	DC.W	$FF13,$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28
	DC.W	$FF2B,$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF46
	DC.W	$FF4B,$FF4F,$FF54,$FF59,$FF5D,$FF62,$FF67,$FF6C
	DC.W	$FF72,$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF92,$FF98
	DC.W	$FF9E,$FFA4,$FFA9,$FFAF,$FFB5,$FFBB,$FFC1,$FFC8
	DC.W	$FFCE,$FFD4,$FFDA,$FFE0,$FFE6,$FFED,$FFF3,$FFF9


;----------------------------------------------
;--------- COPPERLISTE ------------------------
;----------------------------------------------
	section	coppy,data_C

copperliste:
	dc.l	$0107fffe
	dc.l	$008e2081,$009035c1,$00920038,$009400d0

	dc.l	$01800000
	dc.l	$01820fff
vectormap:
	dc.l	$00e00006,$00e20000
	dc.l	$2007fffe,$01001200
	dc.l	$ffe1fffe
;	dc.l	$200ffffe,$10000000
	dc.l	$fffffffe

	section	buffy,bss_C

BUFFER1:
	Ds.B	$10000
BUFFER2:
	Ds.B	$10000
