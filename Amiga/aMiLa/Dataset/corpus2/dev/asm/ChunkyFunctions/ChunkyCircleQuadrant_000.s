;APS0000531300005313000053130000017C000053130000531300005313000053130000531300005313
******************************************************************************
* Originally written by Holger 'Lynxx' Hippenstiel somewhere around 1994-95, *
* tuned a bit for speed & high-resolution compability in May 2023.           *
******************************************************************************

;Functions:
;ChunkyCircleQuadrant
;a0=ChunkyScreen, d0=X, d1=Y, d2=Quadrants, d3=Size, d4=Color, d5=pixelwidth
;Quadrant: 1=top right, 2=bottom right, 4=bottom left, 8=top left
;          ofcourse you can combine them 1+2 = right half of a circle
ChunkyCircleQuadrant:
	movem.l	d0-d7/a0-a6,-(a7)
	moveq	#$f,d6
	add	d0,a0		;X
	and.l	d6,d2
	move	d1,a2		;Y
	move.l	d2,-(a7)	;Quadrants
	ext.l	d5
	move	d4,d2		;Color
	move.l	d5,d4		;pixelwidth
	lea	CircleMultab+MAXHEIGHT*4(pc),a1
	add.l	a2,a2
	move	d3,d5		;Size
	lea	(a1,a2.w),a1
	move	d5,d7
	lsl	#2,d7
	move.l	a0,a3
	add.l	(a1,d7.w),a3
	move	d5,d3
	move.l	a0,a4
	neg	d3
	moveq	#0,d0
	move	d3,d7
	add.l	(a1),a4
	move.l	a0,a6
	lsl	#2,d7
	add.l	(a1,d7.w),a6
	moveq	#2,d1
	add.l	(a1),a0
	move.l	(a7)+,a1
	lea	.CircleTab(pc),a5
	add.l	a1,a1
	move.l	d3,d6
	add	(a5,a1),a5
	moveq	#0,d7
	sub	d5,d1
	jmp	(a5)

.CircleTab:
	dc.w	.CircleEnd-.CircleTab
	dc.w	.Circle0001-.CircleTab
	dc.w	.Circle0010-.CircleTab
	dc.w	.Circle0011-.CircleTab
	dc.w	.Circle0100-.CircleTab
	dc.w	.Circle0101-.CircleTab
	dc.w	.Circle0110-.CircleTab
	dc.w	.Circle0111-.CircleTab
	dc.w	.Circle1000-.CircleTab
	dc.w	.Circle1001-.CircleTab
	dc.w	.Circle1010-.CircleTab
	dc.w	.Circle1011-.CircleTab
	dc.w	.Circle1100-.CircleTab
	dc.w	.Circle1101-.CircleTab
	dc.w	.Circle1110-.CircleTab
	dc.w	.Circle1111-.CircleTab

	cnop	0,16

.Circle0001:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	addq	#1,d6
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0001

.CircleLoop0001:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd2

	subq	#1,d5
	add.l	d4,a6
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0001

	bra.b	.Circle0001

	cnop	0,16

.Circle0010:
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	add	d0,d1			;X inc
	addq	#1,d6
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	add.l	d4,a4
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0010

.CircleLoop0010:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd2

	subq	#1,d5
	sub.l	d4,a3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	add.l	d4,a4
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0010

	bra.b	.Circle0010

.CircEnd2:
	bra.w	.CircleEnd
	
	cnop	0,16

.Circle0100:
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add	d0,d1			;X inc
	addq	#1,d6
	add.l	d4,a4
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0100

.CircleLoop0100:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd2

	addq	#1,d3
	sub.l	d4,a3
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	subq	#1,d5
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0100

	bra.b	.Circle0100

	cnop	0,16

.Circle1000:
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add	d0,d1			;X inc
	addq	#1,d6
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle1000

.CircleLoop1000:
	addq	#2,d6
	cmp	d0,d5
	ble.b	.CircEnd2

	addq	#1,d3
	subq	#1,d5
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop1000

	bra.b	.Circle1000

	cnop	0,16

.Circle0011:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	addq	#1,d6
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0011

.CircleLoop0011:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd6

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	sub.l	d4,a3
	add.l	d4,a6
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0011

	bra.b	.Circle0011

	cnop	0,16

.Circle0110:
	add	d0,d1			;X inc
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0110

.CircleLoop0110:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd6

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	sub.l	d4,a3
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0110

	bra.b	.Circle0110

.CircEnd6:
	bra.w	.CircleEnd

	cnop	0,16

.Circle1001:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	addq	#1,d6
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle1001

.CircleLoop1001:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd6

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add.l	d4,a6
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	addq	#1,d0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	add	d6,d1
	bpl.b	.CircleLoop1001

	bra.b	.Circle1001

	cnop	0,16

.Circle0101:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0101

.CircleLoop0101:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd6

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	sub.l	d4,a3
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0101

	bra.b	.Circle0101

	cnop	0,16

.Circle1010:
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	add	d0,d1			;X inc
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	addq	#1,d6
	add.l	d4,a4
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle1010

.CircleLoop1010:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd10

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	sub.l	d4,a3
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	add.l	d4,a4
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop1010

	bra.b	.Circle1010

	cnop	0,16

.Circle1100:
	add	d0,d1			;X inc
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle1100

.CircleLoop1100:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd10

	subq	#1,d5
	addq	#1,d3
	sub.l	d4,a3
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop1100

	bra.b	.Circle1100
	
.CircEnd10:
	bra.w	.CircleEnd

	cnop	0,16

.Circle0111:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle0111

.CircleLoop0111:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd10

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	sub.l	d4,a3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop0111

	bra.b	.Circle0111

	cnop	0,16

.Circle1110:
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	addq	#1,d6
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	sub.l	d4,a0
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	add	d0,d1			;X inc
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle1110

.CircleLoop1110:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd12

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	sub.l	d4,a3
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop1110

	bra.b	.Circle1110

.CircEnd12:
	bra.w	.CircleEnd

	cnop	0,16

.Circle1101:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	addq	#1,d0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d1
	bmi.b	.Circle1101

.CircleLoop1101:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd12

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	sub.l	d4,a3
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	addq	#1,d0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	add	d6,d1
	bpl.b	.CircleLoop1101

	bra.b	.Circle1101

	cnop	0,16

.Circle1011:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	addq	#1,d6
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.Circle1011

.CircleLoop1011:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircEnd14

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	sub.l	d4,a3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	add.l	d4,a6
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop1011

	bra.b	.Circle1011

.CircEnd14:
	bra.b	.CircleEnd
	cnop	0,16

.Circle1111:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	addq	#1,d0
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	addq	#1,d1
	bmi.b	.Circle1111

.CircleLoop1111:
	addq	#2,d6
	cmp	d0,d5	
	ble.b	.CircleEnd

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	sub.l	d4,a3
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop1111

	bra.b	.Circle1111

.CircleEnd:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	INCLUDE	"ChunkyMultab.s"
