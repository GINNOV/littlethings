; FILE: GG:src/own/awin/awfreepensinner.ASM     REV: 0 --- awfreepens ReleasePen loop in 0x0 asm
; LINK: >LEAVEOBJ>
; History
;  0      13th Dec 1998: started because 256 ReleasePens take quite a
;         long time due PPC<->0x0 contextswitches.
;

; a0 = UBYTE *remap (pen0, pen1, ... pen<n>)
; a1 = UBYTE *penal (free0, free1, ... free<n>)
; a2 = struct ColorMap *colormap
; a6 = struct Library *GfxBase

_awfreepensinner68k:
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	a0,a3
	move.l	a1,a4
	move.l	#256,d7

.lop	tst.b	(a4)		; releasepen this pen?
	beq.b	.skip		; nope, skip
	moveq	#0,d0
	move.l	a2,a0		; colormap
	move.b	(a3),d0		; pen number
	jsr	-$3b4(a6)	; _LVOReleasePen
.skip	clr.b	(a4)+		; clear penal flag
	clr.b	(a3)+		; clean pen num

	subq.l	#1,d7
	bne.b	.lop

	movem.l	(sp)+,d2-d7/a2-a6
	rts

