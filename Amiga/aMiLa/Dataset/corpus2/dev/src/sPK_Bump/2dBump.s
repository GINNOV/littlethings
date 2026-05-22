*************************************************************************
*		2dbumpmapping by SCENile^sPANK! in 1996			*
*			Released 14/08/97				*
*		C2P by ? (can't remember..)				*
*									*
*		If u use diz one in a demo, greet sPANK!		*
*									*
*		Not very systemfriendly or anything...			*
*									*
*		Anyway, the lightsource is 256*256 bytes, 		*
*			the bumpmap 320x200 bytes!			*
*									*
*		If u don't have the includes, get them! :)		*
*************************************************************************
*		Mail me for comments, sourceswapping, etc at:		*
*			scenile@hotmail.com !				*
**************************************************************************
		section main,code
**************************************************************************
		incdir	'include:'
		include	'exec/exec_lib.i'
		include 'hardware/CustomRegisters.i'
		include	'graphics/graphics_lib.i'
**************************************************************************
_AbsExecBase	EQU	4
MEMF_CHIP	EQU 	1<<1
MEMF_FAST	EQU 	1<<0
MEMF_CLEAR	EQU 	1<<16
LOFlist		EQU 	$32
planesize	EQU	40*256
planes		EQU	8
XSIZE		EQU	320
YSIZE		EQU	200
chunkyplanesize	EQU	XSIZE*YSIZE
bmapsize	EQU	XSIZE*YSIZE
**************************************************************************
		bsr	getmem
**************************************************************************
		move.w	#$0020,dmacon+_custom	;Sprite DMA off

		move.l	_AbsExecBase,a6		;
		jsr	_LVOForbid(a6)		;Stäng av multitaskingen..

		lea.l	graphics_name,a1	;Get GFX libbet
		moveq	#0,d0			;
		jsr	_LVOOpenLibrary(a6)	;
		move.l	d0,_GfxBase		;
**************************************************************************
		bsr	initcopscreen
		bsr	fixlsource		;Adjust brightness

		bsr	calcnormals		;Duh !
**************************************************************************
mainloop:	bsr	dobump

		move.l	chunky,a0
		move.l	screen,a1
		bsr	c2p

		btst	#6,$bfe001
		bne.w	mainloop
**************************************************************************
endnormally:	bsr	uninitcopscreen

		move.l	_AbsExecBase,a6		;
		move.l	_GfxBase,a1		;
		jsr	_LVOCloseLibrary(a6)	;
		jsr	_LVOPermit(a6)		;Sätt på multitaskingen..

		bsr	freemem
exit:		moveq	#0,d0
		rts
**************************************************************************
fixlsource:	lea.l	lightsrc,a0
		move.w	#256*256-1,d0
.fixloop:	move.b	(a0),d1
		lsl.b	#1,d1
		move.b	d1,(a0)+
		dbf	d0,.fixloop
		rts
*************************************************************************
* Bump on man!								*
*************************************************************************
dobump:		move.l	chunky,a0		;Screen to plot on
		move.l	normals,a1		;Bump offsets
		lea.l	lightsrc,a2
*************************************************************************
		moveq	#0,d1		;För att använda longwords i lightsrc
		move.w	joy0dat+_custom,d2	;Läs mus..
*************************************************************************
		move.w	#((XSIZE*YSIZE)/5)-1,d0

.bumploop:	move.w	(a1)+,d1		;NormalX
		add.w	d2,d1
		move.b	(a2,d1.l),(a0)+		;Plotta
		move.w	(a1)+,d1		;NormalX
		add.w	d2,d1
		move.b	(a2,d1.l),(a0)+		;Plotta
		move.w	(a1)+,d1		;NormalX
		add.w	d2,d1
		move.b	(a2,d1.l),(a0)+		;Plotta
		move.w	(a1)+,d1		;NormalX
		add.w	d2,d1
		move.b	(a2,d1.l),(a0)+		;Plotta
		move.w	(a1)+,d1		;NormalX
		add.w	d2,d1
		move.b	(a2,d1.l),(a0)+		;Plotta

		dbf	d0,.bumploop	;Xloop
*************************************************************************
		rts
*************************************************************************
* Räkna ut normalerna för bmappen					*
*************************************************************************
calcnormals:	lea.l	bmap,a0
		move.l	normals,a1

		move.w	#YSIZE-1,d1
.calcyloop:	move.w	#XSIZE-1,d0
.calcxloop:	move.b	XSIZE-1(a0),d2		;Optimerat som fan ...
		sub.b	(a0)+,d2		;
		move.b	XSIZE(a0),d3		;
		sub.b	-1(a0),d3		;

		add.w	d1,d2			;addar x värdet
		lsl.w	#8,d2			;Korrekt plotoffset i bumploop

		add.w	d0,d2			;addar y värdet
		add.w	d3,d2
		move.w	d2,(a1)+		;Både y o x normaler i tabben

		dbf	d0,.calcxloop		;xloop
		dbf	d1,.calcyloop		;yloop
		rts
**************************************************************************
initcopscreen:	lea.l	b_planes,a0
		move.l  screen,d0
		moveq	#planes-1,d1

init_cop:	move.w	d0,6(a0)		;install bit plane pointers
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		add.l	#chunkyplanesize/8,d0
		add.w	#8,a0
		dbf	d1,init_cop

		move.l	_GfxBase,a6
		move.w	#$80,dmacon+_custom	;copper DMA off
		move.l	LOFlist(a6),old_cop	;save existing copper list
		move.l	#copperlist,LOFlist(a6)	;install new list
		move.w	#$8080,dmacon+_custom	;copper dma on

		rts
*************************************************************************
uninitcopscreen:move.l	_GfxBase,a6
		move.w	#$80,dmacon+_custom	;copper dma off
		move.w  #$81a0,dmacon+_custom	;Sätt på sprite dma M.M.
		move.l	old_cop,LOFlist(a6)	;Install old list
		move.w	#$8080,dmacon+_custom	;copper dma on
		move.w	#32,beamcon0+_custom	;Switcha till PAL!
		rts
*************************************************************************
getmem:		move.l	_AbsExecBase,a6		;FreeMem()
		move.l	#planesize*planes,d0	;AllocMem()
		move.l	#MEMF_CHIP+MEMF_CLEAR,d1;
		jsr	_LVOAllocMem(a6)	;
		move.l	d0,screen		;

		move.l	#chunkyplanesize,d0	;AllocMem()
		move.l	#MEMF_FAST+MEMF_CLEAR,d1;
		jsr	_LVOAllocMem(a6)	;
		move.l	d0,chunky		;

		move.l	#bmapsize*2,d0		;Holds both X and Y normals
		move.l	#MEMF_FAST+MEMF_CLEAR,d1;
		jsr	_LVOAllocMem(a6)	;
		move.l	d0,normals		;

		rts
***************************************************************************
freemem:	move.l	_AbsExecBase,a6		;FreeMem()
		move.l	screen,a1		;
		move.l	#planesize*planes,d0	;
		jsr	_LVOFreeMem(a6)		;

		move.l	chunky,a1		;
		move.l	#chunkyplanesize,d0	;
		jsr	_LVOFreeMem(a6)		;

		move.l	normals,a1		;
		move.l	#bmapsize*2,d0		;Holds both X and Y normals
		jsr	_LVOFreeMem(a6)		;

		rts
***************************************************************************
WIDTH		EQU	320		; MUST be multiple of 32
HEIGHT		EQU	200
plsiz		EQU	(WIDTH/8)*HEIGHT

		cnop	0,4
c2p:		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,a2
		add.l	#plsiz*8,a2	;a2 = end of chunky buffer
	
		;; Sweep thru the whole chunky data once,
		;; Performing 3 merge operations on it.
	
		move.l	#$00ff00ff,a3	; load byte merge mask
		move.l	#$0f0f0f0f,a4	; load nibble merge mask

firstsweep:	movem.l (a0),d0-d7      ;8+4n   40      cycles
		move.l  d4,a6           a6 = CD
		move.w  d0,d4           d4 = CB
		swap    d4              d4 = BC
		move.w  d4,d0           d0 = AC
		move.w  a6,d4           d4 = BD
		move.l  d5,a6           a6 = CD
		move.w  d1,d5           d5 = CB
		swap    d5              d5 = BC
		move.w  d5,d1           d1 = AC
		move.w  a6,d5           d5 = BD
		move.l  d6,a6           a6 = CD
		move.w  d2,d6           d6 = CB
		swap    d6              d6 = BC
		move.w  d6,d2           d2 = AC
		move.w  a6,d6           d6 = BD
		move.l  d7,a6           a6 = CD
		move.w  d3,d7           d7 = CB
		swap    d7              d7 = BC
		move.w  d7,d3           d3 = AC
		move.w  a6,d7           d7 = BD
		move.l  d7,a6
		move.l  d6,a5
		move.l  a3,d6   ; d6 = 0x0x
		move.l  a3,d7   ; d7 = 0x0x
		and.l   d0,d6   ; d6 = 0b0r
		and.l   d2,d7   ; d7 = 0j0z
		eor.l   d6,d0   ; d0 = a0q0
		eor.l   d7,d2   ; d2 = i0y0
		lsl.l   #8,d6   ; d6 = b0r0
		lsr.l   #8,d2   ; d2 = 0i0y
		or.l    d2,d0           ; d0 = aiqy
		or.l    d7,d6           ; d2 = bjrz
		move.l  a3,d7   ; d7 = 0x0x
		move.l  a3,d2   ; d2 = 0x0x
		and.l   d1,d7   ; d7 = 0b0r
		and.l   d3,d2   ; d2 = 0j0z
		eor.l   d7,d1   ; d1 = a0q0
		eor.l   d2,d3   ; d3 = i0y0
		lsl.l   #8,d7   ; d7 = b0r0
		lsr.l   #8,d3   ; d3 = 0i0y
		or.l    d3,d1           ; d1 = aiqy
		or.l    d2,d7           ; d3 = bjrz

		move.l  a4,d2   ; d2 = 0x0x
		move.l  a4,d3   ; d3 = 0x0x
		and.l   d0,d2   ; d2 = 0b0r
		and.l   d1,d3   ; d3 = 0j0z
		eor.l   d2,d0   ; d0 = a0q0
		eor.l   d3,d1   ; d1 = i0y0
		lsr.l   #4,d1   ; d1 = 0i0y
		or.l    d1,d0           ; d0 = aiqy
		move.l  d0,(a0)+
		lsl.l	#4,d2
		or.l    d3,d2           ; d1 = bjrz
		move.l	d2,(a0)+

		move.l  a4,d3   ; d3 = 0x0x
		move.l  a4,d1   ; d1 = 0x0x
		and.l   d6,d3   ; d3 = 0b0r
		and.l   d7,d1   ; d1 = 0j0z
		eor.l   d3,d6   ; d6 = a0q0
		eor.l   d1,d7   ; d7 = i0y0
		lsr.l   #4,d7   ; d7 = 0i0y
		or.l    d7,d6           ; d6 = aiqy
		move.l	d6,(a0)+
		lsl.l	#4,d3
		or.l    d1,d3           ; d7 = bjrz
		move.l	d3,(a0)+

		move.l  a6,d7
		move.l  a5,d6
		move.l  a3,d0   ; d0 = 0x0x
		move.l  a3,d1   ; d1 = 0x0x
		and.l   d4,d0   ; d0 = 0b0r
		and.l   d6,d1   ; d1 = 0j0z
		eor.l   d0,d4   ; d4 = a0q0
		eor.l   d1,d6   ; d6 = i0y0
		lsl.l   #8,d0   ; d0 = b0r0
		lsr.l   #8,d6   ; d6 = 0i0y
		or.l    d6,d4           ; d4 = aiqy
		or.l    d1,d0           ; d6 = bjrz
		move.l  a3,d1   ; d1 = 0x0x
		move.l  a3,d6   ; d6 = 0x0x
		and.l   d5,d1   ; d1 = 0b0r
		and.l   d7,d6   ; d6 = 0j0z
		eor.l   d1,d5   ; d5 = a0q0
		eor.l   d6,d7   ; d7 = i0y0
		lsl.l   #8,d1   ; d1 = b0r0
		lsr.l   #8,d7   ; d7 = 0i0y
		or.l    d7,d5           ; d5 = aiqy
		or.l    d6,d1           ; d7 = bjrz
		move.l  a4,d6   ; d6 = 0x0x
		move.l  a4,d7   ; d7 = 0x0x
		and.l   d4,d6   ; d6 = 0b0r
		and.l   d5,d7   ; d7 = 0j0z
		eor.l   d6,d4   ; d4 = a0q0
		eor.l   d7,d5   ; d5 = i0y0
		lsr.l   #4,d5   ; d5 = 0i0y
		or.l    d5,d4           ; d4 = aiqy
		move.l  d4,(a0)+
		lsl.l   #4,d6   ; d6 = b0r0
		or.l    d7,d6           ; d5 = bjrz
		move.l  d6,(a0)+

		move.l  a4,d7   ; d7 = 0x0x
		move.l  a4,d5   ; d5 = 0x0x
		and.l   d0,d7   ; d7 = 0b0r
		and.l   d1,d5   ; d5 = 0j0z
		eor.l   d7,d0   ; d0 = a0q0
		eor.l   d5,d1   ; d1 = i0y0
		lsr.l   #4,d1   ; d1 = 0i0y
		or.l    d1,d0           ; d0 = aiqy
		move.l  d0,(a0)+
		lsl.l   #4,d7   ; d7 = b0r0
		or.l    d5,d7           ; d1 = bjrz
		move.l  d7,(a0)+
		cmp.l   a0,a2           ;; 4c
		bne.w   firstsweep      ;; 6c

		sub.l   #plsiz*8,a0
		move.l  #$33333333,a5
		move.l  #$55555555,a6
		lea     plsiz*4(a1),a1  ;a2 = plane4

secondsweep:	move.l  (a0),d0
		move.l  8(a0),d1
		move.l  16(a0),d2
		move.l  24(a0),d3

		move.l  a5,d6   ; d6 = 0x0x
		move.l  a5,d7   ; d7 = 0x0x
		and.l   d0,d6   ; d6 = 0b0r
		and.l   d2,d7   ; d7 = 0j0z
		eor.l   d6,d0   ; d0 = a0q0
		eor.l   d7,d2   ; d2 = i0y0
		lsl.l   #2,d6   ; d6 = b0r0
		lsr.l   #2,d2   ; d2 = 0i0y
		or.l    d2,d0           ; d0 = aiqy
		or.l    d7,d6           ; d2 = bjrz
		move.l  a5,d7   ; d7 = 0x0x
		move.l  a5,d2   ; d2 = 0x0x
		and.l   d1,d7   ; d7 = 0b0r
		and.l   d3,d2   ; d2 = 0j0z
		eor.l   d7,d1   ; d1 = a0q0
		eor.l   d2,d3   ; d3 = i0y0
		lsl.l   #2,d7   ; d7 = b0r0
		lsr.l   #2,d3   ; d3 = 0i0y
		or.l    d3,d1           ; d1 = aiqy
		or.l    d2,d7           ; d3 = bjrz
		move.l  a6,d2   ; d2 = 0x0x
		move.l  a6,d3   ; d3 = 0x0x
		and.l   d0,d2   ; d2 = 0b0r
		and.l   d1,d3   ; d3 = 0j0z
		eor.l   d2,d0   ; d0 = a0q0
		eor.l   d3,d1   ; d1 = i0y0
		lsr.l   #1,d1   ; d1 = 0i0y
		or.l    d1,d0           ; d0 = aiqy
		move.l  d0,plsiz*3(a1)
		add.l   d2,d2
		or.l    d3,d2           ; d1 = bjrz
		move.l  d2,plsiz*2(a1)

		move.l  a6,d3   ; d3 = 0x0x
		move.l  a6,d1   ; d1 = 0x0x
		and.l   d6,d3   ; d3 = 0b0r
		and.l   d7,d1   ; d1 = 0j0z
		eor.l   d3,d6   ; d6 = a0q0
		eor.l   d1,d7   ; d7 = i0y0
		lsr.l   #1,d7   ; d7 = 0i0y
		or.l    d7,d6           ; d6 = aiqy
		move.l  d6,plsiz*1(a1)
		add.l   d3,d3
		or.l    d1,d3           ; d7 = bjrz
		move.l  d3,(a1)+

		move.l  4(a0),d0
		move.l  12(a0),d1
		move.l  20(a0),d2
		move.l  28(a0),d3

		move.l  a5,d6   ; d6 = 0x0x
		move.l  a5,d7   ; d7 = 0x0x
		and.l   d0,d6   ; d6 = 0b0r
		and.l   d2,d7   ; d7 = 0j0z
		eor.l   d6,d0   ; d0 = a0q0
		eor.l   d7,d2   ; d2 = i0y0
		lsl.l   #2,d6   ; d6 = b0r0
		lsr.l   #2,d2   ; d2 = 0i0y
		or.l    d2,d0           ; d0 = aiqy
		or.l    d7,d6           ; d2 = bjrz
		move.l  a5,d7   ; d7 = 0x0x
		move.l  a5,d2   ; d2 = 0x0x
		and.l   d1,d7   ; d7 = 0b0r
		and.l   d3,d2   ; d2 = 0j0z
		eor.l   d7,d1   ; d1 = a0q0
		eor.l   d2,d3   ; d3 = i0y0
		lsl.l   #2,d7   ; d7 = b0r0
		lsr.l   #2,d3   ; d3 = 0i0y
		or.l    d3,d1           ; d1 = aiqy
		or.l    d2,d7           ; d3 = bjrz
		move.l  a6,d2   ; d2 = 0x0x
		move.l  a6,d3   ; d3 = 0x0x
		and.l   d0,d2   ; d2 = 0b0r
		and.l   d1,d3   ; d3 = 0j0z
		eor.l   d2,d0   ; d0 = a0q0
		eor.l   d3,d1   ; d1 = i0y0
		lsr.l   #1,d1   ; d1 = 0i0y
		or.l    d1,d0           ; d0 = aiqy
		move.l  d0,-4-plsiz*1(a1)
		add.l   d2,d2
		or.l    d3,d2           ; d1 = bjrz
		move.l  d2,-4-plsiz*2(a1)

		move.l  a6,d3   ; d3 = 0x0x
		move.l  a6,d1   ; d1 = 0x0x
		and.l   d6,d3   ; d3 = 0b0r
		and.l   d7,d1   ; d1 = 0j0z
		eor.l   d3,d6   ; d6 = a0q0
		eor.l   d1,d7   ; d7 = i0y0
		lsr.l   #1,d7   ; d7 = 0i0y
		or.l    d7,d6           ; d6 = aiqy
		move.l  d6,-4-plsiz*3(a1)
		add.l   d3,d3
		or.l    d1,d3           ; d7 = bjrz
		move.l  d3,-4-plsiz*4(a1)
		add.w   #32,a0  ;;4c
		cmp.l   a0,a2   ;;4c
		bne.w   secondsweep     ;;6c

		;300

.exit:		movem.l	(sp)+,d2-d7/a2-a6
		rts
**************************************************************************
		section	copdata,data_c		;Must be in chip

copperlist:	dc.w	bplcon0,%0000000000010000	;8 bitplanes
		dc.w	diwstrt,11393
		dc.w	diwstop,11519
		dc.w	ddfstrt,56
		dc.w	ddfstop,208
		dc.w	bpl1mod,0
		dc.w	bpl2mod,0

		dc.w	$1dc,$0			;Ställer om till ntsc
		dc.w	$f201,$ff00		;För fullskärm..
		dc.w	bplcon0,%0000000000000001

pal1:		incbin	'coding:asm/koder/bump/bin/pal3.cop'

b_planes:	dc.w	bpl1pth			;bitplane 1
p1h:		dc.w	0
		dc.w	bpl1ptl
p1l:		dc.w	0
		dc.w	bpl2pth			;bitplane 2
p2h:		dc.w	0
		dc.w	bpl2ptl
p2l:		dc.w	0
		dc.w	bpl3pth			;bitplane 3
p3h:		dc.w	0
		dc.w	bpl3ptl
p3l:		dc.w	0
		dc.w	bpl4pth			;bitplane 4
p4h:		dc.w	0
		dc.w	bpl4ptl
p4l:		dc.w	0
		dc.w	bpl5pth			;bitplane 5
p5h:		dc.w	0
		dc.w	bpl5ptl
p5l:		dc.w	0
		dc.w	bpl6pth			;bitplane 6
p6h:		dc.w	0
		dc.w	bpl6ptl
p6l:		dc.w	0
		dc.w	bpl7pth			;bitplane 7
p7h:		dc.w	0
		dc.w	bpl7ptl
p7l:		dc.w	0
		dc.w	bpl8pth			;bitplane 8
p8h:		dc.w	0
		dc.w	bpl8ptl
p8l:		dc.w	0

		dc.w 	$ffff,$fffe		;End of CList
**************************************************************************
		section	arrays,bss_c
_GfxBase: 	ds.l	1
old_cop:	ds.l	1
screen:		ds.l	1
**************************************************************************
		section	other_arrays,bss
chunky		ds.l	1
normals:	ds.l	1
**************************************************************************
		section	datavars,data

graphics_name:	dc.b	'graphics.library',0

bmap:		incbin	'bumpmap.raw'
lightsrc:	incbin	'lightsource.raw'
**************************************************************************
