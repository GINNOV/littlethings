; FILE: GG:src/own/awin/ddazure2.ASM    REV: 6 --- ultrafast scaling routines by Azure
; LINK: >LEAVEOBJ>
; History
;  0      1st Dec 1998. Got source & permission to use it from Azure.
;         did you already know I love Azure :)
;  1      adapted to use stack for temp, figured out some stuff:)
;  2      wrote bad _awddscalech68k with nice 1:1, 2:1 and 1:2 routines
;  3      wrote nice 1:1, 2:1 and 1:2 routines to _awddremapscalech68k
;  4      hmmph.
;  5      _awddremapscalech68k8 .samex trashed 12(a5) and 4(a5).
;  6      fixed one line overflow from all functions :)
;

; Oh btw don't blame Azure if these routines seem bad :)

	XDEF	_awddscalech68k8
	XDEF	_awddremapscalech68k8

	XDEF	_awddscalech68k16
	XDEF	_awddremapscalech68k16
	XDEF	_awddscalech68k16_565
	XDEF	_awddscalech68k16_argb


asc_addstartb	EQU	0
asc_ycnt	EQU	4 ; obviously using both asc_ycnt and asc_yadd
asc_yadd	EQU	4 ; at the same time is a BAD idea.. ;)
asc_xlongs	EQU	8
asc_chunkywidth	EQU	12
asc_modulo	EQU	16
asctemp_SIZEOF	EQU	20

;in:
;d0.l/d1.l source width/height
;d2.l/d3.l destination width/height
;d4.l destination width aligned (aligned with 16,32,64 etc)
;d5.l destination pixperrow
;a0 destination
;a2 source

	CNOP	0,8
_awddscalech68k8:
	movem.l	d2-d7/a2-a6,-(sp)

	cmp.w	d0,d2
	beq	.samex

	lea	(-asctemp_SIZEOF,sp),sp
	sub.l	d4,d5
	move.l	sp,a5
	move.l	d5,asc_modulo(a5)
	move.l	d0,asc_chunkywidth(a5)

	lsl.l	#8,d0
	lsl.l	#8,d1
	divu.w	d2,d0
	divu.w	d3,d1	;8.8 accuracy
	ext.l	d0
	ext.l	d1

	cmp.w	#(1<<8)>>1,d0
	beq	.doublex
	cmp.w	#(1<<8)<<1,d0
	beq	.halvex

	move.l	d0,d7

	moveq	#0,d5
	move.b	d0,d5	;fraction
	ror.l	#8,d5
	move.l	d5,a3	;addstart a
	ror.l	#7,d0
	move.l	d0,d7	;adder
	move.l	d0,d5
	ror.l	#1,d0
	move.w	d0,d5	;addstart b
	move.l	d5,(a5)

	move.l	d1,a4
	lsr.l	#2,d4
	move.l	d4,asc_xlongs(a5)

	clr.l	asc_ycnt(a5)
.ylop
	move.l	(a5),d6

	move.l	asc_ycnt(a5),d4
	move.l	d4,d2
	lsr.l	#8,d4
	mulu.w	asc_chunkywidth+2(a5),d4
	lea	(a2,d4.l),a1
	add.l	a4,d2
	move.l	d2,asc_ycnt(a5)

	move.l	a3,d0

	move.w	asc_xlongs+2(a5),d4
	subq.w	#1,d4		;clear x-flag
.xlop
	move.w	(a1,d0.w),d5	;this definetely sucks
	addx.l	d7,d0
	move.b	(a1,d6.w),d5
	addx.l	d7,d6
	swap	d5
	move.w	(a1,d0.w),d5
	addx.l	d7,d0
	move.b	(a1,d6.w),d5
	move.l	d5,(a0)+
	addx.l	d7,d6

	dbf	d4,.xlop	; can NOT subq!!
	add.l	asc_modulo(a5),a0 ;add modulo
	subq.w	#1,d3
	bne.b	.ylop
	bra	.exit


	CNOP	0,4
.samex	move.l	d5,a4
	lsl.l	#8,d1
	sub.l	d4,a4	;a4=modulo=pixperrow-width_aligned
	divu.w	d3,d1	;8.8 accuracy
	ext.l	d1

	lsr.l	#4,d4	;/16 (four longs at a time)
	move.l	d4,a3

	moveq	#0,d2
.sylop	move.l	d2,d5
	move.l	a3,d4
	lsr.l	#8,d5
	mulu.w	d0,d5
	add.l	d1,d2
	lea	(a2,d5.l),a1

.sxlop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	subq.l	#1,d4
	bne.b	.sxlop
	add.l	a4,a0		;add modulo
	subq.w	#1,d3
	bne.b	.sylop
	bra	.sexit	; it's .samex exit you perv


	CNOP	0,4
.doublex	move.l	asc_chunkywidth(a5),d6

	lsr.l	#3,d4	;/8 (two longs at a time)
	moveq	#16,d7
	move.l	d4,a3

	moveq	#0,d2

.dylop	move.l	d2,d5
	move.l	a3,d4
	lsr.l	#8,d5
	mulu.w	d6,d5
	add.l	d1,d2
	lea	(a2,d5.l),a1

.dxlop	move.w	(a1),d0		;--ab
	move.w	(2,a1),d5	;--cd
	move.b	(a1),d0		;--aa
	move.b	(2,a1),d5	;--cc
	lsl.l	d7,d0		;aa--
	lsl.l	d7,d5		;cc--
	move.w	(1,a1),d0	;aabc
	move.w	(3,a1),d5	;ccde
	move.b	(1,a1),d0	;aabb
	move.b	(3,a1),d5	;ccdd
	move.l	d0,(a0)+
	addq.l	#4,a1
	move.l	d5,(a0)+

	subq.w	#1,d4
	bne.b	.dxlop
	add.l	asc_modulo(a5),a0 ;add modulo
	subq.w	#1,d3
	bne.b	.dylop
	bra	.exit


	CNOP	0,4
.halvex	move.l	asc_chunkywidth(a5),d6

	lsr.l	#3,d4	;/8 (two longs at a time)
	moveq	#16,d7
	move.l	d4,a3

	moveq	#0,d2

.hylop	move.l	d2,d5
	move.l	a3,d4
	lsr.l	#8,d5
	mulu.w	d6,d5
	add.l	d1,d2
	lea	(a2,d5.l),a1

.hxlop	move.w	(a1),d0		;--ab
	move.w	(8,a1),d5	;--ij
	move.b	(2,a1),d0	;--ac
	move.b	(10,a1),d5	;--ik
	lsl.l	d7,d0		;ac--
	lsl.l	d7,d5		;ik--
	move.w	(4,a1),d0	;acef
	move.w	(12,a1),d5	;ikmn
	move.b	(6,a1),d0	;aceg
	move.b	(14,a1),d5	;ikmo
	move.l	d0,(a0)+
	add.l	d7,a1
	move.l	d5,(a0)+

	subq.w	#1,d4
	bne.b	.hxlop
	add.l	asc_modulo(a5),a0 ;add modulo
	subq.w	#1,d3
	bne.b	.hylop


.exit	lea	(asctemp_SIZEOF,sp),sp
.sexit	movem.l	(sp)+,d2-d7/a2-a6
	rts


;in:
;d0.l/d1.l source width/height
;d2.l/d3.l destination width/height
;d4.l destination width aligned (aligned with 16,32,64 etc)
;a0 destination
;a2 source
;a6 remap (palette LUT)

	CNOP	0,8
_awddremapscalech68k8:
	movem.l	d2-d7/a2-a6,-(sp)

	lea	(-asctemp_SIZEOF,sp),sp
	move.l	sp,a5

	move.l	d0,asc_chunkywidth(a5)

	cmp.w	d0,d2
	beq	.samex

	move.l	d0,d7
	lsl.l	#8,d7
	divu.w	d2,d7

	addq.l	#1,d2	;handle leftmost pix
	lsl.l	#8,d0
	lsl.l	#8,d1
	divu.w	d2,d0
	divu.w	d3,d1	;8.8 accuracy
	ext.l	d0
	ext.l	d1

	cmp.w	#(1<<8)>>1,d7
	beq	.doublex
	cmp.w	#(1<<8)<<1,d7
	beq	.halvex

	move.l	d0,d7

	moveq	#0,d5
	move.b	d0,d5	;fraction
	ror.l	#8,d5
	move.l	d5,a3	;addstart a
	ror.l	#7,d0
	move.l	d0,d7	;adder
	move.l	d0,d5
	ror.l	#1,d0
	move.w	d0,d5	;addstart b
	move.l	d5,(a5)

	move.l	d1,a4
	lsr.l	#2,d4
	move.l	d4,asc_xlongs(a5)

	clr.l	asc_ycnt(a5)
	moveq	#0,d1
.ylop
	move.l	(a5),d6

	move.l	asc_ycnt(a5),d4
	move.l	d4,d2
	lsr.l	#8,d4
	mulu.w	asc_chunkywidth+2(a5),d4
	lea	(a2,d4.l),a1
	add.l	a4,d2
	move.l	d2,asc_ycnt(a5)

	move.l	a3,d0

	moveq	#0,d2
	move.w	asc_xlongs+2(a5),d4
	move.b	(a1,d6.w),d2	;handle leftmost pix
	subq.w	#1,d4		;clear x-flag
	addx.l	d7,d0		;handle leftmost pix
	addx.l	d7,d6		;handle leftmost pix
.xlop
	move.b	(a1,d0.w),d1	*x
	move.w	(a6,d2.w),d5	*
	addx.l	d7,d0		*	3++ cycles per pixel
	move.b	(a1,d6.w),d2
	move.b	(a6,d1.w),d5
	addx.l	d7,d6
	swap	d5
	move.b	(a1,d0.w),d1
	move.w	(a6,d2.w),d5
	addx.l	d7,d0
	move.b	(a1,d6.w),d2
	move.b	(a6,d1.w),d5
	move.l	d5,(a0)+
	addx.l	d7,d6

	dbf	d4,.xlop	; can NOT subq!!
	subq.w	#1,d3
	bne.b	.ylop
	bra	.exit


	CNOP	0,4
.samex	lsl.l	#8,d1
	divu.w	d3,d1	;8.8 accuracy
	ext.l	d1
	move.l	d1,asc_yadd(a5)

	lsr.l	#3,d4	;/8 (two longs at a time)
	move.l	d4,a3

	moveq	#0,d6
	moveq	#16,d7

	moveq	#0,d2
.sylop	move.l	d2,d5
	move.w	a3,d4
	lsr.l	#8,d5
	mulu.w	asc_chunkywidth+2(a5),d5
	add.l	asc_yadd(a5),d2
	lea	(a2,d5.l),a1

	IFGT	1
	moveq	#0,d5		;could be faster
.sxlop	move.b	(a1),d6
	move.b	(4,a1),d5
	move.w	(a6,d6.l),d0
	move.b	(1,a1),d6
	move.w	(a6,d5.l),d1
	move.b	(5,a1),d5
	move.b	(a6,d6.l),d0
	move.b	(a6,d5.l),d1
	lsl.l	d7,d0
	lsl.l	d7,d1
	move.b	(2,a1),d6
	move.b	(6,a1),d5
	move.w	(a6,d6.l),d0
	move.b	(3,a1),d6
	move.w	(a6,d5.l),d1
	move.b	(7,a1),d5
	move.b	(a6,d6.l),d0
	move.b	(a6,d5.l),d1
	move.l	d0,(a0)+
	addq.l	#8,a1
	move.l	d1,(a0)+
	ELSE
.sxlop	move.b	(a1),d6
	move.b	(1,a1),d7
	move.b	(a6,d6.w),d1
	lsl.l	#8,d1
	move.b	(2,a1),d6
	move.b	(a6,d7.w),d1
	lsl.l	#8,d1
	move.b	(3,a1),d7
	move.b	(a6,d6.w),d1
	lsl.l	#8,d1
	move.b	(4,a1),d6
	move.b	(a6,d7.w),d1
	move.b	(5,a1),d7
	move.b	(a6,d6.w),d5
	lsl.l	#8,d5
	move.b	(6,a1),d6
	move.b	(a6,d7.w),d5
	lsl.l	#8,d5
	move.b	(7,a1),d7
	move.b	(a6,d6.w),d5
	lsl.l	#8,d5
	addq.l	#8,a1
	move.b	(a6,d7.w),d5
	move.l	d1,(a0)+
	move.l	d5,(a0)+
	ENDC

	subq.w	#1,d4
	bne.b	.sxlop
	subq.w	#1,d3
	bne.b	.sylop
	bra	.exit


	CNOP	0,4
.doublex	move.l	d1,asc_yadd(a5)

	lsr.l	#3,d4	;/8 (two longs at a time)
	moveq	#16,d7
	move.l	d4,a3

	moveq	#0,d0
	moveq	#0,d6

	moveq	#0,d2

.dylop	move.l	d2,d5
	move.l	a3,d4
	lsr.l	#8,d5
	mulu.w	asc_chunkywidth+2(a5),d5
	add.l	asc_yadd(a5),d2
	lea	(a2,d5.l),a1

.dxlop	move.b	(a1),d6		;a pix
	move.b	(2,a1),d0	;c pix
	move.w	(a6,d6.l),d5	;--a-
	move.w	(a6,d0.l),d1	;--c-
	move.b	(a6,d6.l),d5	;--aa
	move.b	(a6,d0.l),d1	;--cc
	lsl.l	d7,d5		;aa--
	lsl.l	d7,d1		;cc--
	move.b	(1,a1),d6	;b pix
	move.b	(3,a1),d0	;d pix
	move.w	(a6,d6.l),d5	;aab-
	move.w	(a6,d0.l),d1	;ccd-
	move.b	(a6,d6.l),d5	;aabb
	move.b	(a6,d0.l),d1	;ccdd
	move.l	d5,(a0)+
	addq.l	#4,a1
	move.l	d1,(a0)+

	subq.l	#1,d4
	bne.b	.dxlop
	subq.w	#1,d3
	bne.b	.dylop
	bra	.exit


	CNOP	0,4
.halvex	move.l	d1,asc_yadd(a5)

	lsr.l	#3,d4	;/8 (two longs at a time)
	moveq	#16,d7
	move.l	d4,a3

	moveq	#0,d0
	moveq	#0,d6

	moveq	#0,d2

.hylop	move.l	d2,d5
	move.l	a3,d4
	lsr.l	#8,d5
	mulu.w	asc_chunkywidth+2(a5),d5
	add.l	asc_yadd(a5),d2
	lea	(a2,d5.l),a1

.hxlop	move.b	(a1),d6		;a pix
	move.b	(8,a1),d0	;i pix
	move.w	(a6,d6.l),d5	;--a-
	move.b	(2,a1),d6	;c pix
	move.w	(a6,d0.l),d1	;--i-
	move.b	(10,a1),d0	;k pix
	move.b	(a6,d6.l),d5	;--ac
	move.b	(a6,d0.l),d1	;--ik
	lsl.l	d7,d5		;ac--
	lsl.l	d7,d1		;ik--
	move.b	(4,a1),d6	;e pix
	move.b	(12,a1),d0	;m pix
	move.w	(a6,d6.l),d5	;ace-
	move.b	(7,a1),d6	;g pix
	move.w	(a6,d0.l),d1	;ikm-
	move.b	(14,a1),d0	;o pix
	move.b	(a6,d6.l),d5	;aceg
	move.b	(a6,d0.l),d1	;ikmo
	move.l	d5,(a0)+
	add.l	d7,a1
	move.l	d1,(a0)+

	subq.w	#1,d4
	bne.b	.hxlop
	subq.w	#1,d3
	bne.b	.hylop

.exit	lea	(asctemp_SIZEOF,sp),sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts


;in:
;d0.l/d1.l source width/height
;d2.l/d3.l destination width/height
;d4.l destination width aligned (aligned with 16,32,64 etc)
;d5.l destination pixperrow
;a0 destination
;a2 source

	CNOP	0,8
_awddscalech68k16:
	movem.l	d2-d7/a2-a6,-(sp)
	movem.l	(sp)+,d2-d7/a2-a6
	rts

;in:
;d0.l/d1.l source width/height
;d2.l/d3.l destination width/height
;d4.l destination width aligned (aligned with 16,32,64 etc)
;a0 destination
;a2 source
;a6 remap (palette LUT)

	CNOP	0,8
_awddremapscalech68k16:
	movem.l	d2-d7/a2-a6,-(sp)
	movem.l	(sp)+,d2-d7/a2-a6
	rts


;in:
;d0.l/d1.l source width/height
;d2.w/d3.w destination width/height
;d4.l destination width aligned (aligned with 16,32,64 etc)
;d5.l destination pixperrow
;a0 destination
;a2 source

	CNOP	0,8
_awddscalech68k16_565:
	movem.l	d2-d7/a2-a6,-(sp)
	movem.l	(sp)+,d2-d7/a2-a6
	rts


;in:
;d0.l/d1.l source width/height
;d2.w/d3.w destination width/height
;d4.l destination width aligned (aligned with 16,32,64 etc)
;d5.l destination pixperrow
;a0 destination
;a2 source

	CNOP	0,8
_awddscalech68k16_argb:
	movem.l	d2-d7/a2-a6,-(sp)
	movem.l	(sp)+,d2-d7/a2-a6
	rts
