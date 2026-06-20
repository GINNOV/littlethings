* Bootblock spécial: Play Sample v0.1
* par Frédo (Jan/95)

* Jouer un sample lors du boot

* Play a sound sample (loaded from disk)
* The sound data must be written onto the disk, then you can install
* this bootblock with the correct parameters (LEN and OFS)
*
* This bootblock is NOT system-friendly (doesn't allocate his memory)
* so don't take it as an example of bootblock coding.
* I just coded this in order to amuse some friends.


ADR=$70000	;where to load sound data (dirty)
LEN=37		;number of disk blocks to load
OFS=2		;disk offset where sound data starts

PER=500		;default sound period
VOL=64		;default sound volume

;begin of bootblock
start:
	dc.b	"DOS",0
	dc.l	0
	dc.l	$370

;begin of boot code
main:
	movem.l	d0-a6,-(sp)

;load sound data (from disk blocks)
	move	#2,28(a1)
	move.l	#ADR,40(a1)	;io_data: destination address
	move.l	#LEN*512,36(a1)	;io_length
	move.l	#OFS*512,44(a1)	;io_offset
	jsr	-456(a6)	;DoIO()
	move	#9,28(a1)
	clr.l	36(a1)
	jsr	-456(a6)

; examine sound data (IFF-8SVX or RAW)
	lea	$dff000,a5
	lea	ADR,a0
	move.l	a0,a1
.s	cmp.l	#"FORM",(a0)+
	bne.b	PlayRaw
	addq.l	#4,a0
	cmp.l	#"8SVX",(a0)+
	bne.b	fin
	cmp.l	#"VHDR",(a0)+
	bne.b	fin
	clr.l	d1
	addq.l	#4,a0
	move	12(a0),d1	;SamplesPerSec
	bsr.b	GetPeriod
.s2	cmp.l	#"BODY",(a0)+
	bne.b	.s2
	move.l	(a0),d1
	asr.l	#1,d1
	addq.l	#4,a0

; play sound
Play
	move.l	a0,$a0(a5)	;address of sample data
	move	d1,$a4(a5)	;length in words
	move	d0,$a6(a5)	;period = fréquence
	move	#VOL,$a8(a5)	;volume
	move	#$8001,$96(a5)	;init dma: canal audio 0 ON

;click leftmouse button to stop
.w	btst	#6,$bfe001
	bne.b	.w

.f
	move	#1,$96(a5)	;dma
fin
	bra.b	Init

; play RAW sound data
PlayRaw:
	move	#PER,d0
	move	#(LEN*512)/2,d1	;longueur (en mots)
	move.l	a1,a0
	bra.b	Play

* Get the correct Period from the Sampling rate of an 8SVX IFF sample
* Calling parameters:
* d1: contains Sampling-rate (SamplesPerSec)
* Exit parameters:
* d0: contains Period (Fréquence)
GetPeriod:
	movem.l	d2-d4,-(a7)
	move.l	#100000000,d0
	mulu	#28,d1
	clr.l	d2
	moveq	#$1f,d4
.bcl	roxl.l	#1,d0
	roxl.l	#1,d2
	cmp.l	d1,d2
	bcs.b	.no
	sub.l	d1,d2
	move	#$10,ccr
.no	roxl.l	#1,d3
	dbf	d4,.bcl
	move.l	d3,d0
	move.l	d2,d1
	movem.l	(a7)+,d2-d4
	rts	

Init:
	movem.l	(sp)+,d0-a6
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-96(a6)
	tst.l	d0
	beq.b	.err
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
.err	moveq	#-1,d0
	rts

dosname:dc.b "dos.library",0

 dc.b " INFO:"
 DC.B " THIS BOOTBLOCK LOADS A SAMPLE FROM THE DISK AND PLAYS IT"
 dc.b " UNTIL THE LEFTMOUSEBUTTON IS PRESSED !"
 DC.B " --- THIS WAS MADE BY FREDO !",0

End:
	dcb.b	512*2,0
