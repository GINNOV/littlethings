
	OPT	O+

RELOCATOR_ADDR:	equ	$0100
PROGRAM_ADDR:	equ	$0400

RELOC:
	move.w	#$7fff,d0
	move.w	d0,$dff096
	move.w	d0,$dff09a
	move.w	d0,$dff09e
	clr.w	$dff180

	lea	RELOC_START(pc),a0
	lea	FILE(pc),a1
	lea	RELOCATOR_ADDR,a2
	move.l	a2,$80.w
.loop	move.w	(a0)+,(a2)+
	cmp.l	a0,a1
	bne.s	.loop

	trap	#0

RELOC_START:
	move.w	#$2700,sr

	lea	PROGRAM_ADDR,a7

	add.l	#FILE_END-FILE,a1
	lea	$80000,a2

	cmp.l	a1,a2
	bcs.s	.no_reloc

.loop:	move.w	-(a1),-(a2)	* Adresse Source
	cmp.l	a0,a1
	bne.s	.loop
	move.l	a2,a0
.no_reloc:	move.l	a0,a1

	lea	PROGRAM_ADDR,a0	* Adresse Destination
	move.l	#File_end-file,d0
                  move.l	a0,-(sp)
dec
	incbin  work:agony/demo/decrunch.bin
RELOC_END:

FILE:	incbin	dh0:ag_demo_bin/sea.crn
FILE_END:	EVEN

