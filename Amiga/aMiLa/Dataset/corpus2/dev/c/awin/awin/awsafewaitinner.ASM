; FILE: GG:src/own/awin/awsafewaitinner.ASM     REV: 0 --- wait msg to arrive
; LINK: >LEAVEOBJ>
; History
;  0      15th Dec 1998: reduces PPC<->0x0 contextswitches
;

; d0 = ULONG sigmask
; a0 = struct MesgPort *port
; a6 = sturct Library *execbase

_awsafewaitinner68k:
	movem.l	d2/a2,-(sp)
	move.l	d0,d2
	move.l	a0,a2

.wmsg	move.l	a2,a0
	jsr	-$174(a6)	; _LVOGetMsg
	tst.l	d0
	bne.b	.gotit
	move.l	d2,d0
	jsr	-$13e(a6)	; _LVOWait
	bra.b	.wmsg
.gotit
	movem.l	(sp)+,d2/a2
	rts

