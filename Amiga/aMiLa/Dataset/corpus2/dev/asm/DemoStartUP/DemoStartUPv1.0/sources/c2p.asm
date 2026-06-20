; - [ c2p / Mikael Kalms 1998-1999 / ] -

	xdef	_C2P
	xdef	_InitC2P

	xref	_CPU
	
;
; 1999-01-08
;
; c2p1x1_8_c5_030
;
; 1.22vbl [all dma off] on Bliz1230-IV@50
;

	IFND	BPLX
BPLX	EQU	320
	ENDC
	IFND	BPLY
BPLY	EQU	256
	ENDC
	IFND	BPLSIZE
BPLSIZE	EQU	BPLX*BPLY/8
	ENDC
	IFND	CHUNKYXMAX
CHUNKYXMAX EQU	BPLX
	ENDC
	IFND	CHUNKYYMAX
CHUNKYYMAX EQU	BPLY
	ENDC

	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

_InitC2P
	move.w	#CHUNKYXMAX,d0
	move.w	#CHUNKYYMAX,d1
	moveq	#0,d2			; Not used by this c2p
	moveq	#0,d3			;         -"-
	move.l	#BPLX/8,d4		;         -"-
	move.l	#BPLSIZE,d5		; Only partially used by this c2p
	move.l	#CHUNKYXMAX,d6		; Not used by this c2p

	cmp.l	#68040,_CPU
	blt.s	.030

	jsr	c2p1x1_8_c5_040_init
	rts
.030
	jsr	c2p1x1_8_c5_030_init
	rts

c2p1x1_8_c5_030_init
	movem.l	d2-d3,-(sp)
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_8_c5_030_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_8_c5_030_pixels
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

_C2P
	cmp.l	#68040,_CPU
	blt.s	c2p1x1_8_c5_030
	bra.s	c2p1x1_8_c5_040
	
c2p1x1_8_c5_030
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	#$00ff00ff,a6

	add.w	#BPLSIZE,a1
	add.l	c2p1x1_8_c5_030_scroffs,a1

	lea	c2p1x1_8_c5_030_fastbuf,a3

	move.l	c2p1x1_8_c5_030_pixels,a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	addq.l	#4,a2
	move.l	a1,-(sp)

	move.l	#$f0f0f0f0,d6

	move.l	(a0)+,d2
	move.l	d2,d7
	lsl.l	#4,d7
	move.l	(a0)+,d0
	move.l	(a0)+,d3
	move.l	(a0)+,d1
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsr.l	#4,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsl.l	#4,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	move.l	d2,(a3)+
	lsr.l	#4,d7
	eor.l	d7,d3
	move.l	d3,(a3)+

	move.l	(a0)+,d4
	move.l	d4,d7
	lsl.l	#4,d7
	move.l	(a0)+,d2
	move.l	(a0)+,d5
	move.l	(a0)+,d3
	eor.l	d2,d7
	and.l	d6,d7
	eor.l	d7,d2
	lsr.l	#4,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsl.l	#4,d7
	eor.l	d3,d7
	and.l	d6,d7
	eor.l	d7,d3
	move.l	d4,(a3)+
	lsr.l	#4,d7
	eor.l	d7,d5
	move.l	d5,(a3)+

	move.w	d2,d7			; Swap 16x2
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2

	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	bra.s	.start1
.x1
	move.l	(a0)+,d0
	move.l	(a0)+,d3
	move.l	(a0)+,d1
	move.l	d7,BPLSIZE(a1)
	move.l	d2,d7
	lsl.l	#4,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsr.l	#4,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsl.l	#4,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	move.l	d2,(a3)+
	lsr.l	#4,d7
	eor.l	d7,d3
	move.l	d3,(a3)+

	move.l	(a0)+,d4
	move.l	d4,d7
	lsl.l	#4,d7
	move.l	(a0)+,d2
	move.l	(a0)+,d5
	move.l	(a0)+,d3
	move.l	a4,(a1)+
	eor.l	d2,d7
	and.l	d6,d7
	eor.l	d7,d2
	lsr.l	#4,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsl.l	#4,d7
	eor.l	d3,d7
	and.l	d6,d7
	eor.l	d7,d3
	lsr.l	#4,d7
	eor.l	d7,d5

	move.w	d2,d7			; Swap 16x2
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.l	d4,(a3)+
	move.w	d7,d2

	move.w	d3,d7
	move.w	d1,d3
	move.l	d5,(a3)+
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	move.l	a5,-BPLSIZE-4(a1)
.start1
	move.l	#$33333333,d5

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	a6,d4
	move.l	#$55555555,d5

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	move.l	d0,BPLSIZE*2(a1)
	add.l	d7,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1
	lsr.l	#1,d1
	eor.l	d2,d1
	and.l	d5,d1
	eor.l	d1,d2
	move.l	d2,a4
	move.l	(a0)+,d2
	add.l	d1,d1
	eor.l	d1,d3
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	.x1
.x1end
	move.l	d7,BPLSIZE(a1)	;
	move.l	a4,(a1)+
	move.l	a5,-BPLSIZE-4(a1)	;
        addq.l  #4,a1   ;;;;;;;;;;

	move.l	(sp)+,a1
	add.l	#BPLSIZE*4,a1

	move.l	c2p1x1_8_c5_030_pixels,d0
	lsr.l	#1,d0
	lea	c2p1x1_8_c5_030_fastbuf,a0
	lea	4(a0,d0.l),a2

	move.l	(a0)+,d0
	move.l	#$55555555,d4
	move.l	#$33333333,d5
	move.l	#$00ff00ff,d6
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.w	d2,d7			; Swap 16x2
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2

	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	d1,d7
	lsr.l	#8,d7
	bra.s	.start2
.x2
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d7,BPLSIZE(a1)
	move.w	d2,d7			; Swap 16x2
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2

	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	move.l	a4,(a1)+
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	d1,d7
	lsr.l	#8,d7
	move.l	a5,-BPLSIZE-4(a1)
.start2

	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d1,d7

	move.l	d3,d1
        move.l  d0,BPLSIZE*2(a1)
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1
	lsr.l	#1,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	add.l	d1,d1
	eor.l	d1,d3

	move.l	(a0)+,d0
	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	.x2

	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
	move.l	a5,-BPLSIZE-4(a1)

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts


; - [ c2p for 040/060 ] -


;
; Date: 20-Jan-1998			Mikael Kalms (Scout/C-Lous & more)
;					Email: mikael@kalms.org
;
; About:
;   1x1 8bpl cpu5 C2P for contigous bitplanes and no horizontal modulo
;
;   This routine is intended for use on all 68040 and 68060 based systems.
;   It is not designed to perform well on 68020-030.
;
;   This routine is released into the public domain. It may be freely used
;   for non-commercial as well as commercial purposes. A short notice via
;   email is always appreciated, though.
;
; Timings:
;   ~130% on (a1200 Blizzard) 040-25
;   Estimated to run at copyspeed on 040-40 and 060
;
; Features:
;   Performs CPU-only C2P conversion using rather state-of-the-art (as of
;   the creation date, anyway) techniques
;   Handles bitplanes of virtually any size (4GB)
;
; Restrictions:
;   Chunky-buffer must be an even multiple of 32 pixels wide
;   If incorrect/invalid parameters are specified, the routine will
;   most probably crash.
;
; c2p1x1_8_c5_040_smcinit		changes the bitplane-size &
;					chunkybuffer size/pos
; c2p1x1_8_c5_040_init			sets only the chunkybuffer size/pos
; c2p1x1_8_c5_040			performs the actual c2p conversion
;


; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl


c2p1x1_8_c5_040_smcinit
	movem.l	d3/a6,-(sp)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_8_c5_040_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_8_c5_040_pixels
	move.l	d5,d0
	lsl.l	#3,d0
	sub.l	d5,d0
	move.l	d0,c2p1x1_8_c5_040_smc1-4
	addq.l	#4,d0
	move.l	d0,c2p1x1_8_c5_040_smc5-4
	move.l	d5,d0
	lsl.l	#2,d0
	move.l	d0,c2p1x1_8_c5_040_smc2-4
	move.l	d0,c2p1x1_8_c5_040_smc4-4
	move.l	d0,c2p1x1_8_c5_040_smc6-4
	move.l	d0,c2p1x1_8_c5_040_smc8-4
	move.l	d0,c2p1x1_8_c5_040_smc10-4
	move.l	d0,c2p1x1_8_c5_040_smc12-4
	sub.l	d5,d0
	move.l	d0,c2p1x1_8_c5_040_smc3-4
	move.l	d0,c2p1x1_8_c5_040_smc7-4
	move.l	d0,c2p1x1_8_c5_040_smc9-4
	move.l	d0,c2p1x1_8_c5_040_smc11-4
	move.l	$4.w,a6
;	jsr	_LVOCacheClearU(a6)
	movem.l	(sp)+,d3/a6
	rts

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

_c2p1x1_8_c5_040_init
c2p1x1_8_c5_040_init
	move.l	d3,-(sp)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_8_c5_040_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_8_c5_040_pixels
	move.l	(sp)+,d3
	rts



; a0	c2pscreen
; a1	bitplanes


c2p1x1_8_c5_040
	movem.l	d2-d7/a2-a6,-(sp)

	add.l	#BPLSIZE*7,a1
c2p1x1_8_c5_040_smc1 EQU *
	add.l	c2p1x1_8_c5_040_scroffs,a1

	move.l	c2p1x1_8_c5_040_pixels,a2
	tst.l	a2
	beq	.none
	add.l	a0,a2

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,a5
	move.l	(a0)+,a6

	swap	d4			; Swap 16x4, part 1
	swap	d5
	eor.w	d0,d4
	eor.w	d1,d5
	eor.w	d4,d0
	eor.w	d5,d1
	eor.w	d0,d4
	eor.w	d1,d5
	swap	d4
	swap	d5

	move.l	d4,d6			; Swap 2x4, part 1
	move.l	d5,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d4
	eor.l	d7,d5

	exg	d4,a5
	exg	d5,a6

	swap	d4			; Swap 16x4, part 2
	swap	d5
	eor.w	d2,d4
	eor.w	d3,d5
	eor.w	d4,d2
	eor.w	d5,d3
	eor.w	d2,d4
	eor.w	d3,d5
	swap	d4
	swap	d5

	move.l	d4,d6			; Swap 2x4, part 1
	move.l	d5,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d2,d6
	eor.l	d3,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d2
	eor.l	d7,d3
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d4
	eor.l	d7,d5

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	bra	.start

	cnop	0,16
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,a5
	move.l	(a0)+,a6

	move.l	d6,(a1)
	sub.l	#BPLSIZE*4,a1
c2p1x1_8_c5_040_smc2 EQU *

	swap	d4			; Swap 16x4, part 1
	swap	d5
	eor.w	d0,d4
	eor.w	d1,d5
	eor.w	d4,d0
	eor.w	d5,d1
	eor.w	d0,d4
	eor.w	d1,d5
	swap	d4
	swap	d5

	move.l	d7,(a1)
	add.l	#BPLSIZE*3,a1
c2p1x1_8_c5_040_smc3 EQU *

	move.l	d4,d6			; Swap 2x4, part 1
	move.l	d5,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d4
	eor.l	d7,d5

	exg	d4,a5
	exg	d5,a6

	swap	d4			; Swap 16x4, part 2
	swap	d5
	eor.w	d2,d4
	eor.w	d3,d5
	eor.w	d4,d2
	eor.w	d5,d3
	eor.w	d2,d4
	eor.w	d3,d5
	swap	d4
	swap	d5

	move.l	a3,(a1)
	sub.l	#BPLSIZE*4,a1
c2p1x1_8_c5_040_smc4 EQU *

	move.l	d4,d6			; Swap 2x4, part 1
	move.l	d5,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d2,d6
	eor.l	d3,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d2
	eor.l	d7,d3
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d4
	eor.l	d7,d5

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	a4,(a1)
	add.l	#BPLSIZE*7+4,a1
c2p1x1_8_c5_040_smc5 EQU *

.start
	move.l	d2,d6			; Swap 8x2, part 1
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	d2,d6			; Swap 1x2, part 1
	move.l	d3,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$55555555,d6
	and.l	#$55555555,d7
	eor.l	d6,d0
	eor.l	d7,d1
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d6,d2
	eor.l	d7,d3

        move.l  d0,(a1)
	sub.l	#BPLSIZE*4,a1
c2p1x1_8_c5_040_smc6 EQU *

	move.l	a5,d6
	move.l	a6,d7
	move.l	d2,a3
	move.l	d3,a4

	move.l	d5,d2			; Swap 4x1, part 2
	move.l	d7,d3
	lsr.l	#4,d2
	lsr.l	#4,d3
	eor.l	d4,d2
	eor.l	d6,d3
	and.l	#$0f0f0f0f,d2
	and.l	#$0f0f0f0f,d3
	eor.l	d2,d4
	eor.l	d3,d6

	move.l	d1,(a1)
	add.l	#BPLSIZE*3,a1
c2p1x1_8_c5_040_smc7 EQU *

	lsl.l	#4,d2
	lsl.l	#4,d3
	eor.l	d2,d5
	eor.l	d3,d7

	move.l	d4,d2			; Swap 8x2, part 2
	move.l	d5,d3
	lsr.l	#8,d2
	lsr.l	#8,d3
	eor.l	d6,d2
	eor.l	d7,d3
	and.l	#$00ff00ff,d2
	and.l	#$00ff00ff,d3
	eor.l	d2,d6
	eor.l	d3,d7

	move.l	a3,(a1)
	sub.l	#BPLSIZE*4,a1
c2p1x1_8_c5_040_smc8 EQU *

	lsl.l	#8,d2
	lsl.l	#8,d3
	eor.l	d2,d4
	eor.l	d3,d5

	move.l	d4,d2			; Swap 1x2, part 2
	move.l	d5,d3
	lsr.l	#1,d2
	lsr.l	#1,d3
	eor.l	d6,d2
	eor.l	d7,d3
	and.l	#$55555555,d2
	and.l	#$55555555,d3

	move.l	a4,(a1)
	add.l	#BPLSIZE*3,a1
c2p1x1_8_c5_040_smc9 EQU *

	eor.l	d2,d6
	eor.l	d3,d7
	add.l	d2,d2
	add.l	d3,d3
	eor.l	d2,d4
	eor.l	d3,d5

	move.l	d4,a3
	move.l	d5,a4

	cmp.l	a0,a2
	bne	.x

        move.l  d6,(a1)
	sub.l	#BPLSIZE*4,a1
c2p1x1_8_c5_040_smc10 EQU *
	move.l	d7,(a1)
	add.l	#BPLSIZE*3,a1
c2p1x1_8_c5_040_smc11 EQU *
	move.l	a3,(a1)
	sub.l	#BPLSIZE*4,a1
c2p1x1_8_c5_040_smc12 EQU *
	move.l	a4,(a1)

.none	movem.l	(sp)+,d2-d7/a2-a6
	rts


	section	bss,bss

c2p1x1_8_c5_030_scroffs	ds.l	1
c2p1x1_8_c5_030_pixels	ds.l	1

c2p1x1_8_c5_030_fastbuf	ds.b	CHUNKYXMAX*CHUNKYYMAX/2

c2p1x1_8_c5_040_scroffs	ds.l	1
c2p1x1_8_c5_040_pixels	ds.l	1
