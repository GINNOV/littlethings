;------------------------------------------------------------------------------
;
; 100% systemfriendly PlanarToChunky converter for use with intuition
; screens in applications/games/whatever.
;
; Coded in 1994 by Morten Eriksen.
; Reach me through email: mortene@stud.unit.no.
;
; Use and modify as you like - give credit where appropriate.
;
; Timings on my A1200 with 68EC020 and 32-bit fastram:
;
;  Testcase    Dimensions       This routine             C='s ReadPixelArray8
;
;	1	320x256x5 -	10 frames (0.20 seconds)	41 frames
;	2	320x256x8 -	16 frames (0.32 seconds)	51 frames
;	3	640x512x4 -	34 frames (0.68 seconds)	158 frames
;	4     1024x1024x1 -	35 frames (0.70 seconds)	312 frames
;	5	752x578x8 -	89 frames (1.78 seconds)	312 frames
;
; Please suggest speed-ups in the code if you see any (by changing the
; algorithm, using other instructions with less executiontime, better
; pipelining, etc etc). The 'convert32pixels' is of course the bottleneck,
; as this subroutine accounts for almost all processing done in the
; converter.
;
;------------------------------------------------------------------------------
	xdef	_PlanarToChunkyAsm
;------------------------------------------------------------------------------
; This routine takes a buffer of chunkybytes and fills it with converted
; planar datas from the source BitMap.
;
; As a replacement for C='s ReadPixelArray8 routine, this one is more than
; three times as fast (in worst case) and works directly on bitmaps (instead
; of RastPorts). All cases handled (any width and height > 0, no alignment
; restrictions). Works on OCS/ECS/AGA, all Kickstarts and any MC680x0 CPU.
; The downside is that it does not do clipping and does not work with
; interleaved bitmaps (support for interleaved bitmaps should be piece of
; cake to implement, though).
;------------------------------------------------------------------------------
;
; C interface:
;
; extern void __asm PlanarToChunkyAsm(register __a0 struct p2cStruct *);
;
; struct p2cStruct
; {
;  struct BitMap *bmap;
;  UWORD startX, startY, width, height;
;  UBYTE *chunkybuffer;
; } p2c;
;
; p2c.bmap = mybitmap;
; p2c.startX = x0;
; p2c.startY = y0;
; p2c.width = x1 - x0 + 1;
; p2c.height = y1 - y0 + 1;
; p2c.chunkybuffer = chunkybytes;
;
; SyncSBitMap(mywindow->RPort->Layer);
; PlanarToChunkyAsm(&p2c);
;------------------------------------------------------------------------------
;
; Assembler interface:
;
; In: 	a0 - p2c struct.
; Out:	Nothing.
;------------------------------------------------------------------------------

; ** BitMap struct **
BytesPerRow	EQU	0	; UWORD
Rows		EQU	2	; UWORD
Flags		EQU	4	; UBYTE
Depth		EQU	5	; UBYTE
Pad		EQU	6	; UWORD
Planes		EQU	8	; PLANEPTRs [8]

; ** p2c struct **

bmap		EQU	0	; struct BitMap *
startX		EQU	4	; UWORD
startY		EQU	6	; UWORD
width		EQU	8	; UWORD
height		EQU	10	; UWORD
chunkybuffer	EQU	12	; UBYTE *

AttnFlags	EQU	296
;------------------------------------------------------------------------------
	Section	code,CODE
	
_PlanarToChunkyAsm:
	movem.l	d2-d7/a2-a6,-(sp)

	tst.b	madetable	* need only make bitspreadtable on first call
	bne.s	table_made
	bsr.w	make_table

	move.l	4.w,a1		* and ditto for 68020 check
	clr.b	chk68000
	move.w	AttnFlags(a1),d0
	andi.b	#%1110,d0
	tst.b	d0
	bne.s	atleast68020
	move.b	#1,chk68000
atleast68020
table_made

	move.l	bmap(a0),a1
	move.l	chunkybuffer(a0),a3
	lea	p2c,a4

	moveq	#0,d1
	move.w	startX(a0),d0
	andi.w	#%111,d0
	tst.w	d0
	beq.s	noleftpix
	moveq	#8,d1
	sub.w	d0,d1
noleftpix
	move.w	d1,leftpix

	move.w	width(a0),d0
	move.w	d0,Width
hit	cmp.w	d1,d0
	bhs.s	notinsidebyte
	move.b	#1,insidebyte
	moveq	#0,d1
	bra.s	isinside

notinsidebyte
	clr.b	insidebyte
	move.w	Width,d0
	sub.w	leftpix,d0
	move.w	d0,d1
	lsr.w	#5,d0
	lsl.w	#5,d0
	sub.w	d0,d1
isinside
	move.w	d1,rightpix

	* find initial offset in bytes into bitmap given by (startX, startY)
	moveq	#0,d0
	move.w	startX(a0),d0
	lsr.w	#3,d0
	move.w	startY(a0),d1
	tst.w	d1
	beq.s	line0
	moveq	#0,d2
	move.w	BytesPerRow(a1),d2
	subq	#1,d1
makeoffset
	add.l	d2,d0
	dbra	d1,makeoffset
line0	move.l	d0,a2

	tst.w	leftpix
	beq.s	nol1
	subq	#3,a2

nol1	move.w	Width,d0
	sub.w	rightpix,d0
	move.w	BytesPerRow(a1),d1
	lsr.w	#3,d0
	sub.w	d0,d1
	move.w	d1,Modulo

	tst.b	insidebyte
	bne.s	nol2
	tst.w	leftpix
	beq.s	nol2
	subq	#4,Modulo
nol2

	move.w	height(a0),Height

	; a0 - c2p struct, a1 - bmap,
	; a2 - offset from Planes pointer, a3 - chunkybuffer
	; a4 - bitspread table

	move.l	a1,a6
	add.w	#Planes,a6
	moveq	#0,d0
	move.b	Depth(a1),d0
	move.w	d0,depth
	lsl.w	#2,d0
	add.l	d0,a6
	move.l	a6,lastplaneptr

convertline
	tst.b	insidebyte
	beq.s	notinsidesinglebyte
	bsr.w	convert32pixels
	lea	buffer+32,a5
	movem.l	d0-d7,-(a5)
	moveq	#32,d0
	sub.w	leftpix,d0
	add.l	d0,a5
	move.w	Width,d0
	subq	#1,d0
singleinsert
	move.b	(a5)+,(a3)+
	dbra	d0,singleinsert
	bra.w	linedone

notinsidesinglebyte
	tst.w	leftpix
	beq.s	noleftpixels

	tst.w	Width
	beq.w	linedone

	bsr.w	convert32pixels
	lea	buffer+32,a5
	movem.l	d0-d7,-(a5)
	moveq	#32,d0
	sub.w	leftpix,d0
	add.l	d0,a5
	move.w	leftpix,d0
	move.w	d0,d1
	subq	#1,d0
leftinsert
	move.b	(a5)+,(a3)+
	dbra	d0,leftinsert
	sub.w	d1,Width
	addq	#4,a2
	
noleftpixels
	cmp.w	#32,Width
	blo.s	trailbits

	bsr.w	convert32pixels

	tst.b	chk68000
	beq.b	flushall
	move.w	a3,dummy
	andi.w	#%1,dummy
	tst.w	dummy
	beq.b	flushall

	lea	buffer+32,a5
	movem.l	d0-d7,-(a5)
	moveq	#(32/8)-1,d0
mloop	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	dbra	d0,mloop
	bra.s	nolongflush

flushall
	add.w	#32,a3
	movem.l	d0-d7,-(a3)
	add.w	#32,a3

nolongflush
	sub.w	#32,Width
	addq	#4,a2
	bra.b	noleftpixels

trailbits
	tst.w	Width
	beq.s	linedone

	bsr.b	convert32pixels
	lea	buffer+32,a5
	movem.l	d0-d7,-(a5)
	move.w	rightpix,d0
	subq	#1,d0
rightinsert
	move.b	(a5)+,(a3)+
	dbra	d0,rightinsert

linedone
	move.w	width(a0),Width
	add.w	Modulo,a2
	subq	#1,Height
	tst.w	Height
	bne.w	convertline

	movem.l	(sp)+,d2-d7/a2-a6
	rts
;------------------------------------------------------------------------------
convert32pixels:
	move.l	a3,-(sp)
	move.w	depth,a3
	move.l	lastplaneptr,a6
	
	move.l	-(a6),a5
	add.l	a2,a5
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	movem.l	0(a4,d7.w),d0/d1
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	movem.l	0(a4,d7.w),d2/d3
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	movem.l	0(a4,d7.w),d4/d5
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	movem.l	0(a4,d7.w),d6/d7

convert32pixelsloop
	subq	#1,a3
	cmp.w	#0,a3
	beq.s	done

	move.l	-(a6),a5
	add.l	a2,a5
	move.w	d7,-(sp)
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	add.l	d0,d0
	or.l	0(a4,d7.w),d0
	add.l	d1,d1
	or.l	4(a4,d7.w),d1
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	add.l	d2,d2
	or.l	0(a4,d7.w),d2
	add.l	d3,d3
	or.l	4(a4,d7.w),d3
	clr.w	d7
	move.b	(a5)+,d7
	lsl.w	#3,d7
	add.l	d4,d4
	or.l	0(a4,d7.w),d4
	add.l	d5,d5
	or.l	4(a4,d7.w),d5
	move.w	(sp)+,d7
	move.w	d5,-(sp)
	clr.w	d5
	move.b	(a5)+,d5
	lsl.w	#3,d5
	add.l	d6,d6
	or.l	0(a4,d5.w),d6
	add.l	d7,d7
	or.l	4(a4,d5.w),d7
	move.w	(sp)+,d5
	bra.s	convert32pixelsloop

done	move.l	(sp)+,a3
	rts
;------------------------------------------------------------------------------
* makes the bitspread table *
* Do not destroy a0! *
make_table:
	lea	p2c,a1
	moveq	#0,d0
more_table
	move.b	d0,d1

	moveq	#8-1,d2
byteloop
	btst	#7,d1
	beq.s	zero
	move.b	#1,(a1)+
	bra.s	one
zero	clr.b	(a1)+
one	lsl.b	#1,d1
	dbra	d2,byteloop

	addq	#1,d0
	cmp.w	#256,d0
	beq.s	table_done
	bra.s	more_table
table_done
	move.b	#1,madetable	
	rts
;------------------------------------------------------------------------------
	Section	variables,DATA

lastplaneptr	dc.l	0
Width		dc.w	0
Height		dc.w	0
depth		dc.w	0
Modulo		dc.w	0
dummy		dc.w	0
leftpix		dc.w	0
rightpix	dc.w	0
insidebyte	dc.b	0
madetable	dc.b	0
chk68000	dc.b	0
;------------------------------------------------------------------------------
	Section	tables,BSS	

	cnop	0,8
* bitspread table *
p2c	ds.b	256*8
buffer	ds.b	32
;------------------------------------------------------------------------------
	END
