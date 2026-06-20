; FILE: GG:src/own/awin/awremapinner.ASM          REV: 1 --- awremap ObtainBestPen loop in 0x0 asm
; LINK: >LEAVEOBJ>
; History
;  0      13th Dec 1998: started because 256 ObtainBestPens take quite a
;         long time due PPC<->0x0 contextswitches.
;  1      14th Dec 1998: fixed to do freepens too in same routine.
;

; a0 = ULONG *rgb (r0, g0, b0, r1, g2, b3, ... r<n>, g<n>, b<n>)
; a1 = UBYTE *remap (pen0, pen1, ... pen<n>)
; a2 = UBYTE *penal (free0, free1, ... free<n>)
; a3 = struct ColorMap *colormap
; a6 = struct Library *GfxBase
; d0 = ULONG max
; d1 = ULONG precision

_awremapinner68k:
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	d0,d7

	move.l	a0,a4
	move.l	a1,a5

	clr.l	-(sp)		; build taglist into stack
	clr.l	-(sp)
	pea	$84000001	; OBP_FailIdBad
	move.l	d1,-(sp)
	pea	$84000000	; OBP_Precision

	jsr	-$e4(a6)	; _LVOWaitBlit

	moveq	#0,d6
.flop	tst.b	(a2)		; releasepen this pen?
	beq.b	.fskip		; nope, skip
	moveq	#0,d0
	move.l	a3,a0		; colormap
	move.b	(a5),d0		; pen number
	jsr	-$3b4(a6)	; _LVOReleasePen
.fskip	clr.b	(a2)+		; clear releaseflag
	addq.l	#1,a5		; next pen number
	subq.b	#1,d6		; loop 256 times
	bne.b	.flop

	lea	-256(a2),a2	; fix pointers
	lea	-256(a5),a5
	moveq	#-1,d4

.lop	move.l	a3,a0		; colormap
	movem.l	(a4)+,d1/d2/d3	; r/g/b
	move.l	sp,a1		; taglist
	jsr	-$348(a6)	; _LVOObtainBestPenA
	move.l	d0,d1
	addq.l	#1,d1
	bne.b	.got

	; a3=colormap
	move.l	-2*4(a4),d1	; d1=r
	; d2=g
	; d3=b
	; d4=-1
	jsr	-$3f0(a6)	; _LVOFindColor
	bra.b	.skip
.got
	move.b	#1,(a2)+	; set releaseflag
.skip	move.b	d0,(a5)+	; set remap pen number

	subq.l	#1,d7
	bne.b	.lop

	lea	(5*4,sp),sp	; pop taglist from stack
	movem.l	(sp)+,d2-d7/a2-a6
	rts

