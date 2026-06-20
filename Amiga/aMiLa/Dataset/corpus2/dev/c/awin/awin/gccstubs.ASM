; FILE: GG:src/own/awin/gccstubs.ASM      REV: 1 --- stubs for 10+ param functions
; LINK: >LEAVEOBJ>
; History
;  0      17th Nov 1998.
;  1      27th Nov 1998. _LVOWriteLUTPixelArray = -$c6 *not* -$c0
;

; note: not all of these are nececcarily used

	XDEF	_bltbitmap
	XDEF	_scalepixelarray
	XDEF	_readpixelarray
	XDEF	_writepixelarray
	XDEF	_writelutpixelarray


;ULONG bltbitmap(struct bltbitmapargs *args __asm("a0"));

	CNOP	0,8
_bltbitmap:
	movem.l	d2-d7/a2/a6,-(sp)
	movem.w	(a0)+,d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	(a0),a0/a1/a2/a6
	jsr	-$1e(a6)
	movem.l	(sp)+,d2-d7/a2/a6
	rts


;LONG scalepixelarray(struct scalepixelarrayargs *args __asm("a0"));

	CNOP	0,8
_scalepixelarray:
	movem.l	d2-d7/a6,-(sp)
	movem.w	(a0)+,d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	(a0),a0/a1/a6
	jsr	-$5a(a6)
	movem.l	(sp)+,d2-d7/a6
	rts


;LONG readpixelarray(struct readpixelarrayargs *args __asm("a0"));

	CNOP	0,8
_readpixelarray:
	movem.l	d2-d7/a6,-(sp)
	movem.w	(a0)+,d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	(a0),a0/a1/a6
	jsr	-$78(a6)
	movem.l	(sp)+,d2-d7/a6
	rts


;LONG writepixelarray(struct writepixelarrayargs *args __asm("a0"));

	CNOP	0,8
_writepixelarray:
	movem.l	d2-d7/a6,-(sp)
	movem.w	(a0)+,d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	(a0),a0/a1/a6
	jsr	-$7e(a6)
	movem.l	(sp)+,d2-d7/a6
	rts


;LONG writelutpixelarray(struct writelutpixelarrayargs *args __asm("a0"));

	CNOP	0,8
_writelutpixelarray:
	movem.l	d2-d7/a2/a6,-(sp)
	movem.w	(a0)+,d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	(a0),a0/a1/a2/a6
	jsr	-$c6(a6)  ; *NOT* c0 as in cybergraphics_pragmas.h 41.19 (14.07.1998)
	movem.l	(sp)+,d2-d7/a2/a6
	rts

