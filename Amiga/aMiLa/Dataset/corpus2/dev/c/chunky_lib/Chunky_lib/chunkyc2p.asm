; 100% systemfriendly ChunkyToPlanar converter for use with intuition
; screens in applications/games/whatever.
;
; Coded in 1994 by Morten Eriksen.
; Reach me through email: mortene@stud.unit.no.
;
; Use and modify as you like - give credit where appropriate.
;
; Timings on my A1200 with 68EC020 and 32-bit fastram:
;
;   Testcase    Dimensions      This routine             C='s WritePixelArray8
;
;	1	320x256x5 -	15 frames (0.30 seconds)	33 frames
;	2	320x256x8 -	16 frames (0.32 seconds)	51 frames
;	3	640x512x4 -	63 frames (1.26 seconds)	100 frames
;	4     1024x1024x1 -    194 frames (3.88 seconds)	101 frames
;	5	752x578x8 -	88 frames (1.76 seconds)	250 frames
;
; Please help me speed up this sucker - the main bottleneck is the
; 'convert32pixels' subroutine (e.g. in the 3rd testcase, 60 out of
; 63 frames are spent in this routine). As you can see, it gets worse
; on less bitplanes (compared to C='s routine) - but on 8-bit bitmaps it's
; about 3 times as fast. If you improve it, be sure to repost the improved
; version to Usenet, or send it to me through email.
;
;------------------------------------------------------------------------------
	xdef	_ChunkyToPlanarAsm
;------------------------------------------------------------------------------
; This routine takes a buffer of chunkybytes and transform it into
; planar datas, which are directly inserted into the destination BitMap.
;
; As a replacement for C='s WritePixelArray8 routine, this one is on average
; about twice as fast and works directly on bitmaps (instead of RastPorts).
; All cases handled (any width and height > 0, no alignment restrictions).
; Works on OCS/ECS/AGA, all Kickstarts and any MC680x0 CPU.
; The downside is that it does not do clipping and does not work with
; interleaved bitmaps (support for interleaved bitmaps should be piece of
; cake to implement, though).
;------------------------------------------------------------------------------
;
; C interface:
;
; extern void __asm ChunkyToPlanarAsm(register __a0 struct c2pStruct *);
;
; struct c2pStruct
; {
;  struct BitMap *bmap;
;  UWORD startX, startY, width, height;
;  UBYTE *chunkybuffer;
; } c2p;
;
; c2p.bmap = mybitmap;
; c2p.startX = x0;
; c2p.startY = y0;
; c2p.width = x1 - x0 + 1;
; c2p.height = y1 - y0 + 1;
; c2p.chunkybuffer = chunkybytes;
;
; ChunkyToPlanarAsm(&c2p);
; CopySBitMap(mywindow->RPort->Layer);
;------------------------------------------------------------------------------
;
; Assembler interface:
;
; In: 	a0 - c2p struct.
; Out:	Nothing.
;------------------------------------------------------------------------------

; ** BitMap struct **
BytesPerRow	EQU	0	; UWORD
Rows		EQU	2	; UWORD
Flags		EQU	4	; UBYTE
Depth		EQU	5	; UBYTE
Pad		EQU	6	; UWORD
Planes		EQU	8	; PLANEPTRs [8]

; ** c2p struct **

bmap		EQU	0	; struct BitMap *
startX		EQU	4	; UWORD
startY		EQU	6	; UWORD
width		EQU	8	; UWORD
height		EQU	10	; UWORD
chunkybuffer	EQU	12	; UBYTE *
;------------------------------------------------------------------------------
	Section	code,CODE
	
_ChunkyToPlanarAsm:
	movem.l	d2-d7/a2-a6,-(sp)

	tst.b	madetable		* need only make bitspreadtable once
	bne.s	table_made
	bsr.w	make_table
table_made

	* find number of not bytealigned pixels at left side of frame and
	* the mask to be used
	moveq	#0,d0
	move.w	startX(a0),d0
	andi.w	#%111,d0
	tst.w	d0
	beq.s	leadno
	move.w	d0,d1
	moveq	#8,d0
	sub.w	d1,d0

	move.b	#$ff,d1
	lsl.b	d0,d1
	move.b	d1,andval_lead

leadno	move.w	d0,leadingbits

	move.w	width(a0),d0
	cmp.w	leadingbits,d0
	bhs.s	notsingle

	* in case the whole chunkypixels buffer to be inserted fits into
	* a single byte
	move.b	#$80,d1
	subq	#1,d0
	asr.b	d0,d1
	addq	#1,d0
	moveq	#8,d2
	sub.w	leadingbits,d2
	lsr.b	d2,d1
	not.b	d1
	move.b	d1,andval_single
	clr.w	trailingbits
	bra.s	single
notsingle
	clr.b	andval_single

	* find number of not bytealigned pixels at right side of frame and
	* the mask to be used
	sub.w	leadingbits,d0
	move.w	d0,d1
	andi.w	#$fff8,d1
	sub.w	d1,d0
	move.w	d0,trailingbits
	move.b	#$ff,d1
	lsr.b	d0,d1
	move.b	d1,andval_trail
single
	* initialize variables to be used (modulo, bytealigned width, etc)
	move.l	bmap(a0),a1
	move.l	chunkybuffer(a0),a3
	moveq	#0,d0
	move.b	Depth(a1),d0
	move.w	d0,depth
	move.w	height(a0),Height
	move.w	width(a0),Width
	move.w	leadingbits,d1
	sub.w	d1,Width
	move.w	trailingbits,d1
	sub.w	d1,Width
	move.w	Width,GWidth
	move.w	BytesPerRow(a1),Modulo
	tst.b	andval_single
	bne.s	singlebyte
	move.w	Width,d0
	lsr.w	#3,d0
	sub.w	d0,Modulo
singlebyte
	tst.w	leadingbits
	beq.s	nolead
	sub.w	#1,Modulo
nolead	tst.w	trailingbits
	beq.s	notrail
	sub.w	#1,Modulo
notrail

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
line0
	move.l	d0,a2

	* find jumpaddress for planar data insertion into bitmap
	* (depending on bitmap depth)
	move.l	a1,a6
	add.l	#Planes,a6
	lea	insertpointerslong,a4
	lea	insertpointers,a5
	moveq	#0,d7
	move.w	depth,d7
	lsl.w	#2,d7
	add.l	d7,a6
	move.l	a6,planepointerspointer
	subq	#4,d7
	add.l	d7,a4
	add.l	d7,a5
	move.l	(a4),insertpointerlong
	move.l	(a5),insertpointer

	lea	c2p,a4

	; a0 - c2p struct, a1 - bmap,
	; a2 - offset from Planes pointer, a3 - chunkybuffer
	; a4 - bitspread table

convertlines
	* check if whole width fits into a single byte and take
	* appropriate action if this is the case
	tst.b	andval_single
	beq.s	testlead
	bsr.w	insertsinglebytebits
	bra.w	trailno

testlead
	* is the frame _not_ left bytealigned ?
	tst.w	leadingbits
	beq.b	convert8pixels
	bsr.w	insertleadingbits

convert8pixels
	* done?
	tst.w	Width
	beq.s	rowdone

	* check if we can do a speedier 32 pixels in one go conversion...
	cmp.w	#32,Width
	blo.s	nolong
	* test odd/even address to be compatible with 68000 aswell *
	move.l	Planes(a1),d0
	add.l	a2,d0
	btst	#0,d0
	bne.s	nolong
	bsr.w	convert32pixels
	sub.w	#32,Width
	addq	#4,a2
	bra.s	convert8pixels

nolong	* ...rather than the slower 8 pixel conversion
	moveq	#0,d0
	moveq	#0,d4
	moveq	#8-1,d1
convert8bytes
	* find correct bitspreadtable offset -> a4 *
	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2

	* insert bitrow *
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	addq	#4,d2
	add.l	d4,d4
	or.l	0(a4,d2.w),d4

	dbra	d1,convert8bytes

	* spread bits to all registers *
	move.b	d0,d3
	lsr.w	#8,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0

	move.b	d4,d7
	lsr.w	#8,d4
	move.b	d4,d6
	swap	d4
	move.b	d4,d5
	lsr.w	#8,d4

	cmp.w	#8,depth
	beq.s	its8
	move.l	a2,d7
its8	move.l	planepointerspointer(pc),a6
	move.l	insertpointer(pc),a5
	jsr	(a5)

	addq	#1,a2
	subq	#8,Width
	bra.w	convert8pixels

rowdone
	* are there any non bytealigned pixels remaining at the right side
	* of the frame?
	tst.w	trailingbits
	beq.b	trailno
	bsr.w	inserttrailingbits

trailno	move.w	GWidth,Width
	add.w	Modulo,a2
	subq	#1,Height
	tst.w	Height
	bne.w	convertlines

	movem.l	(sp)+,d2-d7/a2-a6
	rts
;------------------------------------------------------------------------------
insertdata:	* insert converted 8 pixels c->p data into the bitmap
plane8	move.l	-(a6),a5
	add.l	a2,a5
	move.b	d7,(a5)
	move.l	a2,d7
plane7	move.l	-(a6),a5
	move.b	d6,0(a5,d7.l)
plane6	move.l	-(a6),a5
	move.b	d5,0(a5,d7.l)
plane5	move.l	-(a6),a5
	move.b	d4,0(a5,d7.l)
plane4	move.l	-(a6),a5
	move.b	d3,0(a5,d7.l)
plane3	move.l	-(a6),a5
	move.b	d2,0(a5,d7.l)
plane2	move.l	-(a6),a5
	move.b	d1,0(a5,d7.l)
plane1	move.l	-(a6),a5
	move.b	d0,0(a5,d7.l)
	rts
;------------------------------------------------------------------------------
insertdatalong:	* insert converted 32 pixels c->p data into the bitmap
plane8l	move.l	-(a6),a5
	add.l	a2,a5
	move.l	d7,(a5)
	move.l	a2,d7
plane7l	move.l	-(a6),a5
	move.l	d6,0(a5,d7.l)
plane6l	move.l	-(a6),a5
	move.l	d5,0(a5,d7.l)
plane5l	move.l	-(a6),a5
	move.l	d4,0(a5,d7.l)
plane4l	move.l	-(a6),a5
	move.l	d3,0(a5,d7.l)
plane3l	move.l	-(a6),a5
	move.l	d2,0(a5,d7.l)
plane2l	move.l	-(a6),a5
	move.l	d1,0(a5,d7.l)
plane1l	move.l	-(a6),a5
	move.l	d0,0(a5,d7.l)
	rts
;------------------------------------------------------------------------------
insertpointer		dc.l	0
insertpointerlong	dc.l	0
planepointerspointer	dc.l	0
;------------------------------------------------------------------------------
convert32pixels:
	* convert 4 * 8 = 32 pixels in one go
	lea	buffer+32,a5

	moveq	#4-1,d3
eachlong
	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	movem.l	0(a4,d2.w),d0/d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	add.l	d4,d4
	or.l	4(a4,d2.w),d4

	* push temporary converted data in buffer
	movem.l	d0/d4,-(a5)
	dbra	d3,eachlong

	* buffer now looks like this:
	* d00 d10
	* d20 d30
	* d40 d50
	* d60 d70
	* d01 d11
	* d21 d31
	* d41 d51
	* d61 d71
	* d02 d12
	* d22 d32
	* d42 d52
	* d62 d72
	* d03 d13
	* d23 d33
	* d43 d53
	* d63 d73
	* ...where e.g. d43 means most significant byte (#3) in dataregister 4

	* now pop the converted data from the buffer and into the
	* dataregisters
	add.l	#4*2*4,a5

	move.l	-(a5),d4
	move.b	d4,d7
	lsr.w	#8,d4
	move.b	d4,d6
	swap	d4
	move.b	d4,d5
	lsr.w	#8,d4

	move.l	-(a5),d0
	move.b	d0,d3
	lsr.w	#8,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0

	lsl.w	#8,d7
	move.b	-1(a5),d7
	lsl.w	#8,d6
	move.b	-2(a5),d6
	lsl.w	#8,d5
	move.b	-3(a5),d5
	lsl.w	#8,d4
	move.b	-4(a5),d4
	lsl.w	#8,d3
	move.b	-5(a5),d3
	lsl.w	#8,d2
	move.b	-6(a5),d2
	lsl.w	#8,d1
	move.b	-7(a5),d1
	lsl.w	#8,d0
	move.b	-8(a5),d0

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	swap	d6
	swap	d7

	subq	#8,a5

	move.w	-(a5),d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.w	-(a5),d4
	move.b	d4,d5
	lsr.w	#8,d4
	move.w	-(a5),d2
	move.b	d2,d3
	lsr.w	#8,d2
	move.w	-(a5),d0
	move.b	d0,d1
	lsr.w	#8,d0

	lsl.w	#8,d7
	move.b	-1(a5),d7
	lsl.w	#8,d6
	move.b	-2(a5),d6
	lsl.w	#8,d5
	move.b	-3(a5),d5
	lsl.w	#8,d4
	move.b	-4(a5),d4
	lsl.w	#8,d3
	move.b	-5(a5),d3
	lsl.w	#8,d2
	move.b	-6(a5),d2
	lsl.w	#8,d1
	move.b	-7(a5),d1
	lsl.w	#8,d0
	move.b	-8(a5),d0

	* insert the converted c->p data into the bitmap
	cmp.w	#8,depth
	beq.b	its8x
	move.l	a2,d7
its8x	move.l	planepointerspointer(pc),a6
	move.l	insertpointerlong(pc),a5
	jsr	(a5)
	rts
;------------------------------------------------------------------------------
insertleadingbits:
	moveq	#0,d0
	moveq	#0,d4
	move.w	leadingbits,d1
	subq	#1,d1
convertleadingbits
	* find correct bitspreadtable offset -> a4 *
	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2

	* insert bitrow *
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	addq	#4,d2
	add.l	d4,d4
	or.l	0(a4,d2.w),d4

	dbra	d1,convertleadingbits

	* spread bits to all registers *
	move.b	d0,d3
	lsr.w	#8,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0

	move.b	d4,d7
	lsr.w	#8,d4
	move.b	d4,d6
	swap	d4
	move.b	d4,d5
	lsr.w	#8,d4

	movem.l	a0-a1/a3,-(sp)

	move.w	depth,a0
	addq	#Planes,a1

	* read and mix in the data from the bitmap with the converted data
planel0	move.w	d7,-(sp)
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d7
	and.b	andval_lead,d7
	or.b	d7,d0
	move.w	(sp)+,d7
	move.w	d0,-(sp)

	subq	#1,a0
	cmp.w	#0,a0
	beq.w	doneplanes
planel1	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d1

	subq	#1,a0
	cmp.w	#0,a0
	beq.w	doneplanes
planel2	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d2

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	doneplanes
planel3	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d3

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	doneplanes
planel4	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d4

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	doneplanes
planel5	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d5

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	doneplanes
planel6	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d6

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	doneplanes
planel7	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_lead,d0
	or.b	d0,d7

doneplanes
	move.w	(sp)+,d0
	movem.l	(sp)+,a0-a1/a3
	
	cmp.w	#8,depth
	beq.s	its8l
	move.l	a2,d7
its8l	move.l	planepointerspointer(pc),a6
	move.l	insertpointer(pc),a5
	jsr	(a5)
	addq	#1,a2
	rts
;------------------------------------------------------------------------------
inserttrailingbits:
	moveq	#0,d0
	moveq	#0,d4
	move.w	trailingbits,d1
	subq	#1,d1
converttrailingbits
	* find correct bitspreadtable offset -> a4 *
	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2

	* insert bitrow *
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	addq	#4,d2
	add.l	d4,d4
	or.l	0(a4,d2.w),d4

	dbra	d1,converttrailingbits

	moveq	#8,d1
	sub.w	trailingbits,d1
	lsl.l	d1,d0
	lsl.l	d1,d4
	
	* spread bits to all registers *
	move.b	d0,d3
	lsr.w	#8,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0

	move.b	d4,d7
	lsr.w	#8,d4
	move.b	d4,d6
	swap	d4
	move.b	d4,d5
	lsr.w	#8,d4

	movem.l	a0-a1/a3,-(sp)

	move.w	depth,a0
	addq	#Planes,a1

	* read and mix in the data from the bitmap with the converted data
planet0	move.w	d7,-(sp)
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d7
	and.b	andval_trail,d7
	or.b	d7,d0
	move.w	(sp)+,d7
	move.w	d0,-(sp)

	subq	#1,a0
	cmp.w	#0,a0
	beq.w	done_planes
planet1	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d1

	subq	#1,a0
	cmp.w	#0,a0
	beq.w	done_planes
planet2	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d2

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done_planes
planet3	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d3

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done_planes
planet4	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d4

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done_planes
planet5	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d5

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done_planes
planet6	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d6

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done_planes
planet7	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_trail,d0
	or.b	d0,d7

done_planes
	move.w	(sp)+,d0
	movem.l	(sp)+,a0-a1/a3
	
	cmp.w	#8,depth
	beq.s	its8t
	move.l	a2,d7
its8t	move.l	planepointerspointer(pc),a6
	move.l	insertpointer(pc),a5
	jsr	(a5)
	addq	#1,a2
	rts
;------------------------------------------------------------------------------
insertsinglebytebits:
	moveq	#0,d0
	moveq	#0,d4
	move.w	width(a0),d1
	subq	#1,d1
convertsinglebytebits
	* find correct bitspreadtable offset -> a4 *
	moveq	#0,d2
	move.b	(a3)+,d2
	lsl.w	#3,d2

	* insert bitrow *
	add.l	d0,d0
	or.l	0(a4,d2.w),d0
	addq	#4,d2
	add.l	d4,d4
	or.l	0(a4,d2.w),d4

	dbra	d1,convertsinglebytebits

	moveq	#0,d1
	move.w	leadingbits,d1
	sub.w	width(a0),d1
	lsl.l	d1,d0
	lsl.l	d1,d4
	
	* spread bits to all registers *
	move.b	d0,d3
	lsr.w	#8,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0

	move.b	d4,d7
	lsr.w	#8,d4
	move.b	d4,d6
	swap	d4
	move.b	d4,d5
	lsr.w	#8,d4

	movem.l	a0-a1/a3,-(sp)

	move.w	depth,a0
	addq	#Planes,a1

	* read and mix in the data from the bitmap with the converted data
planes0	move.w	d7,-(sp)
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d7
	and.b	andval_single,d7
	or.b	d7,d0
	move.w	(sp)+,d7
	move.w	d0,-(sp)

	subq	#1,a0
	cmp.w	#0,a0
	beq.w	done__planes
planes1	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d1

	subq	#1,a0
	cmp.w	#0,a0
	beq.w	done__planes
planes2	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d2

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done__planes
planes3	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d3

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done__planes
planes4	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d4

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done__planes
planes5	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d5

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done__planes
planes6	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d6

	subq	#1,a0
	cmp.w	#0,a0
	beq.s	done__planes
planes7	addq	#4,a1
	move.l	(a1),a3
	add.l	a2,a3
	move.b	(a3),d0
	and.b	andval_single,d0
	or.b	d0,d7

done__planes
	move.w	(sp)+,d0
	movem.l	(sp)+,a0-a1/a3
	
	cmp.w	#8,depth
	beq.s	its8s
	move.l	a2,d7
its8s	move.l	planepointerspointer(pc),a6
	move.l	insertpointer(pc),a5
	jsr	(a5)
	addq	#1,a2
	rts
;------------------------------------------------------------------------------
* makes the bitspread table *
* Do not destroy a0! *
make_table:
	lea	c2p,a1
	moveq	#0,d0
more_table
	move.b	d0,d1

	moveq	#8-1,d2
byteloop
	btst	#0,d1
	beq.s	zero
	move.b	#1,(a1)+
	bra.s	one
zero	clr.b	(a1)+
one	lsr.b	#1,d1
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

depth	dc.w	0
Width	dc.w	0
GWidth	dc.w	0
Height	dc.w	0
Modulo	dc.w	0
insertpointers
	dc.l	plane1,plane2,plane3,plane4,plane5,plane6,plane7,plane8
insertpointerslong
	dc.l	plane1l,plane2l,plane3l,plane4l,plane5l,plane6l,plane7l,plane8l
leadingbits
	dc.w	0
trailingbits
	dc.w	0
madetable
	dc.b	0
andval_lead
	dc.b	0
andval_trail
	dc.b	0
andval_single
	dc.b	0
;------------------------------------------------------------------------------
	Section	tables,BSS	

* bitspread table *
c2p	ds.b	256*8
* temporary buffer *
buffer	ds.b	32
;------------------------------------------------------------------------------
	END
