; FILE: GG:src/own/awin/cpu5azure2.ASM          REV: 10 --- fast 040/060 c2p by Azure
; LINK: >LEAVEOBJ>
; History
;  0      This is supposed to be cleaner :)
;  7      Made it dynamic.
;  10     Made it mostly(!) dynamic about plane count,
;         you still *MUST* pass all 8 planes!!
;

;---------------------------------------------------------------------------
;5 Pass CPU Chunky to Planar Converter for 68040/60
;
; This c2p is enhanced for slow 060-boards like the Blizzard 1260 and
; Apollo 1260.
;
; Tested: Copyspeed on Apollo 1240/40, Apollo 4040/40 , Apollo 1260/50
;	its probably copyspeed on all 4060 boards, all 1240/40 boards and
;	all 4040/40 boards. On slower 040 boards it should perform well,
;	too. I hope it is copyspeed on Blizzard 1260/50,too.
;
;(W) and (C) 6-7.5.1997 by Tim Boescke
;			Azure/Artwork
;
;
;This converter is using enhanced and paired mergeops (rot-merges) taking
;3 cycles per merge on 060, 8 cycles per merge on 040. Plus a little overhead
;for final rot-correction. The disadvantage is, that the 16bit merge is slighty
;slower now on 040.
;
;Effective cycles taken for 8lw c2p:
;
;			040		060
;
;rot paired	merge		169		61.5
;normal paired	merge		168		68
;non paired	merge		168		~132-152
;


	XDEF	_awinitchunky2planar
	XDEF	_awchunky2planar

;void awinitchunky2planar(UBYTE *chunky __asm("a0"),
;                        ULONG width __asm("d0"),
;                        ULONG height __asm("d1"),
;                        ULONG depth __asm("d2"));

;void awchunky2planar(UBYTE *planar __asm("a1"));




USEA7	equ	0	;1 = use a7 ,0 = dont use a7 
			;NoA7 uses selfmodifying code with cacheflush
			;its applied every time you change the chunkybuffers
			;location. (a0=source) So changing it a lot of times
			;could slow the c2p down a bit.


;---------------------------------------------------------------------------
;
;IN:
;
;	a0   =source
;	d0   =width
;	d1   =height
;               d2   =depth
;
;----------------------------------------------------------------------------


	CNOP	0,8
_awinitchunky2planar:
	movem.l	d0-d7/a0-a6,-(a7)

	movem.l	d0-d2/a0-a1,-(a7)
	move.l	.alignbase(pc),d0
	bne.b	.norealign

	; Align the c2p to a 16 byte-border

	move.l	#_alignhere,d0
	and.w	#$fff0,d0
	move.l	d0,a0
	move.l	a0,.alignbase

	lea	_alignhere(pc),a1
	move.w	#_loopend-_alignhere,d0
	lsr.w	#1,d0		;phxass is drain bamaged
.reloop	move.w	(a1)+,(a0)+
	subq.w	#1,d0
	bne.b	.reloop

	; Get original chip writes

	lea	.cwtab(pc),a0
	move.l	.alignbase(pc),a1
	move.w	(_smc_p0-_alignhere,a1),(a0)+
	move.w	(_smc_p1-_alignhere,a1),(a0)+
	move.w	(_smc_p2-_alignhere,a1),(a0)+
	move.w	(_smc_p3-_alignhere,a1),(a0)+
	move.w	(_smc_p4-_alignhere,a1),(a0)+
	move.w	(_smc_p5-_alignhere,a1),(a0)+
	move.w	(_smc_p6-_alignhere,a1),(a0)+
	move.w	(_smc_p7-_alignhere,a1),(a0)+

.norealign	movem.l	(a7)+,d0-d2/a0-a1

	mulu.w	d1,d0		;d0=screensize
	move.l	d0,d1
	lsr.l	#3,d1		;d1=plane (screensize/8)

	move.l	a0,_smcsrca0+2

	lea	(a0,d0.l),a0

	IFNE	USEA7
	move.l	a0,_smcherea7+2
	ENDC

	; must use .alignbase for aligned area!!
	; (ie. for things between _loop and _loopend)
	move.l	.alignbase(pc),a5

	IFEQ	USEA7
	move.l	a0,(_endsmc+2-_alignhere,a5)
	ENDC

	;d1=plane (screensize/8)
	move.l	d1,(_smc_plane01+2-_alignhere,a5)
	move.l	d1,(_smc_plane02+2-_alignhere,a5)
	move.l	d1,(_smc_plane03+2-_alignhere,a5)
	move.l	d1,_smc_plane04+2
	move.l	d1,_smc_plane05+2
	move.l	d1,_smc_plane06+2

	move.l	d1,d3
	add.l	d1,d3		;d3=2*plane

	move.l	d3,(_smc_2plane01+2-_alignhere,a5)
	move.l	d3,_smc_2plane02+2

	move.l	d3,d4
	addq.l	#4,d4		;d4=2*plane+4
	move.l	d4,(_smc_2plane401+2-_alignhere,a5)

	move.l	d3,d4
	add.l	d4,d4		;d4=4*plane
	move.l	d4,(_smc_4plane01+2-_alignhere,a5)
	add.l	d1,d4
	subq.l	#4,d4		;d4=5*plane-4
	move.l	d4,_smc_5plane401+2

	move.l	d1,d3
	add.l	d1,d3
	add.l	d1,d3		;d3=3*plane
	move.l	d3,(_smc_3plane01+2-_alignhere,a5)

	move.l	d3,d4
	add.l	d4,d4		;d4=6*plane
	move.l	d4,(_smc_6plane01+2-_alignhere,a5)

	lea	.cwtab(pc),a0
	move.w	(a0)+,(_smc_p0-_alignhere,a5)
	move.w	(a0)+,(_smc_p1-_alignhere,a5)
	move.w	(a0)+,(_smc_p2-_alignhere,a5)
	move.w	(a0)+,(_smc_p3-_alignhere,a5)
	move.w	(a0)+,(_smc_p4-_alignhere,a5)
	move.w	(a0)+,(_smc_p5-_alignhere,a5)
	move.w	(a0)+,(_smc_p6-_alignhere,a5)
	move.w	(a0)+,(_smc_p7-_alignhere,a5)

	cmp.l	#8,d2
	bls.b	.dok
	moveq	#8,d2
.dok	move.w	#$2048,d0	;move.l a0,a0
	jmp	.djpos(pc,d2.l*4)
.djpos	move.w	d0,(_smc_p0-_alignhere,a5)
	move.w	d0,(_smc_p1-_alignhere,a5)
	move.w	d0,(_smc_p2-_alignhere,a5)
	move.w	d0,(_smc_p3-_alignhere,a5)
	move.w	d0,(_smc_p4-_alignhere,a5)
	move.w	d0,(_smc_p5-_alignhere,a5)
	move.w	d0,(_smc_p6-_alignhere,a5)
	move.w	d0,(_smc_p7-_alignhere,a5)

	move.l	4.w,a6
	jsr	-636(a6)	;cacheflush

	movem.l	(a7)+,d0-d7/a0-a6
	rts
.alignbase	dc.l	0
.cwtab	dc.w	0,0,0,0
	dc.w	0,0,0,0

;
;IN:
;
;	(a0   =source)
;	a1   =target
;
;NOTE!!!! : Dont use any optimizations when assembling this! Especially
;	not with PHXass. The generated code might not work otherwise.
;---------------------------------------------------------------------------

	CNOP	0,8
_awchunky2planar:
	movem.l	d0-d7/a2-a6,-(a7)

_smcsrca0	move.l	#$1337C0DE,a0

	IFNE	USEA7
	move.l	a7,_a7save
_smcherea7	move.l	#$BADC0DE,a7		;a7=endpointer
	ENDC

_smc_5plane401	add.l	#$C0DE7,a1		;5*.plane-4,a1

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,a3
	move.l	(a0)+,d6
	move.l	(a0)+,a2
	swap	d4
	swap	d6
	eor.w	d0,d4
	eor.w	d2,d6
	eor.w	d4,d0
	eor.w	d6,d2
	eor.w	d0,d4
	eor.w	d2,d6
	ror.l	#8,d2
	rol.l	#8,d4
	move.l	d6,d7
	move.l	d2,d5
	eor.l	d4,d7
	eor.l	d0,d5
	and.l	#$00FF00FF,d5
	and.l	#$FF00FF00,d7
	eor.l	d5,d0
	eor.l	d7,d4
	eor.l	d5,d2
	eor.l	d7,d6
	rol.l	#6,d4
	rol.l	#6,d6
	move.l	d4,d5
	move.l	d6,d7
	eor.l	d0,d5
	eor.l	d2,d7
	and.l	#$33333333,d5
	and.l	#$33333333,d7
	eor.l	d5,d0
	eor.l	d7,d2
	eor.l	d5,d4
	eor.l	d7,d6
	rol.l	#4,d2
	rol.l	#4,d6
	move.l	a2,d7
	move.l	a3,d5
	move.l	d6,a2
	move.l	d4,a3
	swap	d5
	swap	d7
	eor.w	d1,d5
	eor.w	d3,d7
	eor.w	d5,d1
	eor.w	d7,d3
	eor.w	d1,d5
	eor.w	d3,d7
	ror.l	#8,d3
	rol.l	#8,d5
	move.l	d7,d6
	move.l	d3,d4
	eor.l	d5,d6
	eor.l	d1,d4
	and.l	#$00FF00FF,d4
	and.l	#$FF00FF00,d6
	eor.l	d4,d1
	eor.l	d6,d5
	eor.l	d4,d3
	eor.l	d6,d7
	rol.l	#6,d5
	rol.l	#6,d7
	move.l	d5,d4
	move.l	d7,d6
	eor.l	d1,d4
	eor.l	d3,d6
	and.l	#$33333333,d4
	and.l	#$33333333,d6
	eor.l	d4,d1
	eor.l	d6,d3
	eor.l	d4,d5
	eor.l	d6,d7
	ror.l	#4,d1
	ror.l	#4,d5

	move.l	a2,d6
	move.l	d5,a2

	REPT	4	;space for realigning
	move.l	a1,a1	;pipelined/superscalar nop
	move.l	a2,a2	;(Note: the real NOP is more than a
			; No-Operation. It does Pipeline-Sync and
			; is dead slow that way)
			;asm-one isnt assembling trapf
	ENDR
_alignhere
	bra.w	_enter_here

	REPT	3
	move.l	a1,a1
	move.l	a2,a2
	ENDR
_loop
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,a3
	move.l	(a0)+,d6
	move.l	(a0)+,a2
_smc_p0	move.l	d7,(a1)			;plane0
	swap	d4
	swap	d6
	eor.w	d0,d4
	eor.w	d2,d6
	eor.w	d4,d0
	eor.w	d6,d2
	eor.w	d0,d4
	eor.w	d2,d6
_smc_plane01	add.l	#$C0DE1,a1
	ror.l	#8,d2
	rol.l	#8,d4
_smc_p1	move.l	d5,(a1)			;plane1
	move.l	d6,d7
	move.l	d2,d5
	eor.l	d4,d7
	eor.l	d0,d5
	and.l	#$00FF00FF,d5
	and.l	#$FF00FF00,d7
	eor.l	d5,d0
	eor.l	d7,d4
	eor.l	d5,d2
	eor.l	d7,d6
	rol.l	#6,d4
	rol.l	#6,d6
_smc_plane02	add.l	#$C0DE1,a1
	move.l	d4,d5
	move.l	d6,d7
	eor.l	d0,d5
	eor.l	d2,d7
	and.l	#$33333333,d5
	and.l	#$33333333,d7
	eor.l	d5,d0
	eor.l	d7,d2
	eor.l	d5,d4
_smc_p2	move.l	a4,(a1)			;plane2
	eor.l	d7,d6
	rol.l	#4,d2
	rol.l	#4,d6
	move.l	a2,d7
	move.l	a3,d5
	move.l	d6,a2
	move.l	d4,a3
	swap	d5
	swap	d7
	eor.w	d1,d5
	eor.w	d3,d7
	eor.w	d5,d1
	eor.w	d7,d3
	eor.w	d1,d5
	eor.w	d3,d7
_smc_2plane01	add.l	#$C0DE2,a1
	ror.l	#8,d3
	rol.l	#8,d5
	move.l	d7,d6
	move.l	d3,d4
	eor.l	d5,d6
_smc_p4	move.l	a5,(a1)			;plane4
	eor.l	d1,d4
	and.l	#$00FF00FF,d4
	and.l	#$FF00FF00,d6
	eor.l	d4,d1
	eor.l	d6,d5
	eor.l	d4,d3
	eor.l	d6,d7
	rol.l	#6,d5
	rol.l	#6,d7
	move.l	d5,d4
	move.l	d7,d6
	eor.l	d1,d4
	eor.l	d3,d6
_smc_plane03	add.l	#$C0DE1,a1
	and.l	#$33333333,d4
	and.l	#$33333333,d6
	eor.l	d4,d1
	eor.l	d6,d3
	eor.l	d4,d5
	eor.l	d6,d7

	ror.l	#4,d1
	ror.l	#4,d5

	move.l	a2,d6
	move.l	d5,a2
_smc_p5	move.l	a6,(a1)			;plane5
_enter_here
	move.l	d1,d4
	move.l	d3,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	#$0F0F0F0F,d4
	and.l	#$F0F0F0F0,d5
	eor.l	d4,d0
	eor.l	d5,d2
	eor.l	d4,d1
	eor.l	d5,d3
	rol.l	#3,d2
	rol.l	#3,d3
	move.l	d2,d4
	move.l	d3,d5
	eor.l	d0,d4
	eor.l	d1,d5
	and.l	#$55555555,d4
	and.l	#$55555555,d5
_smc_2plane401	add.l	#$C0DE3,a1		;(2*.plane)+4,a1
	eor.l	d4,d0
	eor.l	d5,d1
_smc_p7	move.l	d0,(a1)			;plane7
	eor.l	d4,d2
	eor.l	d5,d3
	rol.l	#4,d1
	rol.l	#1,d2
	rol.l	#5,d3
	move.l	a3,d4
	move.l	a2,d5
	move.l	d3,a4
	move.l	d5,d0
	move.l	d7,d3
	eor.l	d4,d0
	eor.l	d6,d3
_smc_4plane01	sub.l	#$C0DE5,a1
	and.l	#$C3C3C3C3,d0
	and.l	#$3C3C3C3C,d3
_smc_p3	move.l	d1,(a1)			;plane3
	eor.l	d0,d4
	eor.l	d3,d6
	eor.l	d0,d5
	eor.l	d3,d7
	rol.l	#3,d6
	rol.l	#3,d7
	move.l	d6,d0
	move.l	d7,d3
_smc_3plane01	add.l	#$C0DE4,a1
	eor.l	d4,d0
	eor.l	d5,d3
	and.l	#$55555555,d0
	and.l	#$55555555,d3
	eor.l	d0,d4
	eor.l	d3,d5
	eor.l	d0,d6
	eor.l	d3,d7
_smc_p6	move.l	d2,(a1)			;plane6
	rol.l	#2,d4
	rol.l	#6,d5
	rol.l	#3,d6
	rol.l	#7,d7
;;_smc_p6	move.l	d2,(a1)			;plane6
	move.l	d6,a5
	move.l	d4,a6
_smc_6plane01	sub.l	#$C0DE6,a1

	IFNE	USEA7
	cmp.l	a7,a0
	ELSE
_endsmc	cmp.l	#$DEADC0DE,a0
	ENDC
	blt.w	_loop
	jmp	_loopend
_loopend

	move.l	d7,(a1)
_smc_plane04	add.l	#$C0DE1,a1
	move.l	d5,(a1)
_smc_plane05	add.l	#$C0DE1,a1
	move.l	a4,(a1)
_smc_2plane02	add.l	#$C0DE2,a1
	move.l	a5,(a1)
_smc_plane06	add.l	#$C0DE1,a1
	move.l	a6,(a1)

	IFNE	USEA7
	move.l	_a7save(pc),a7
	ENDC
	movem.l	(a7)+,d0-d7/a2-a6
	rts

	IFNE	USEA7
_a7save	dc.l	0
	ENDC

;---------------------------------------------------------------------------

