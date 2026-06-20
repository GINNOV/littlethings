
*GENERAL FX CODE!!!
*DispFX_init : initialise code
*RunDispFX : launch! : vsync to showpl!
*DelDispFX : delete!

DispFX_Init
	Lea	DispFXlist,a0
	MOVE.L	a0,DispFXPtr
;Initialise!
	lea	SpinBlocks_Bobs,a0
	bsr initbob
	rts
Fxtype dc.b 0
	even

DelDispFX
	ST Fxtype						; set -1
	BRA.s	DDispFX

RunDispFX							; Do a display effect!!!
	SF Fxtype						; zero it...

DDispFX
	push	d0-d7/a0-a4
	MOVE.L	DispFXptr,a0
DDFX_rlp
	cmp.b	#dispfxfin,(a0)			; list finished ?
	bne.s	DDFX_Nfin
	lea	DispFXList,a0
	bra.s	DDFX_rlp
DDFX_nFin
	Lea fxbuffer,a1

	moveq	#(8*2)-1,d0				; Put in skips...
DDFX_skiplp1
	move.b	#dispfxskip,(a1)+
	dbra	d0,DDFX_skiplp1
DDFX_iblp
	move.b	(a0)+,d0				; copy data from fx list
	cmp.b	#dispfxend,d0
	beq.s	DDFX_ibdone
	move.b	d0,(a1)+
	bra.s	DDFX_iblp
DDFX_ibdone
	moveq	#(8*2)-1,d0				; Put in skips...
DDFX_skiplp2
	move.b	#dispfxskip,(a1)+
	dbra	d0,DDFX_skiplp2
	move.b	#dispfxend,(a1)+
	move.b	#dispfxend,(a1)+
;Now fx buffer 100%!!!
	
	tst.b fxtype
	beq.s DDFX_NNew
	move.l	a0,dispfxptr 	; save fx ptr : only update on *wipe*
DDFX_NNew	

	lea	fxbuffer,a4
	moveq	#0,D7					; Reset counter value
	moveq	#4,d6					; Counter delta
	tst.b fxtype
	beq.s DDFX_NDel
	moveq #8*4,d7
	moveq #-4,d6

DDFX_NDel
	lea	SpinBlocks_bobs,a0
	move.l	p.showpl(a5),a1
	sub.l	a2,a2					; no savepos!

DDFX_mlp	move.l	d7,d2			; d2 = cur spr pos
	moveq	#7,d4					; number done...

	bsr	waitvbl
DDFX_flp
	moveq	#0,d0
	move.b (a4),d0
	cmp.b	#dispfxskip,d0
	beq.s	DDFX_skip
	cmp.b	#dispfxend,d0	
	beq.s	DDFX_mlpend
;do block at (a4)
	lsl.w	#5,d0					; x pos *32
	moveq	#0,d1
	move.b	1(a4),d1
	lsl.w	#5,d1					; y pos *32
	bsr dobob						; this is the life... all these lib rt.s!

ddfx_skip
	addq.l	#2,a4					; next entry
	add.l	d6,d2					; next sprite entry
	dbra	d4,DDFX_flp
	lea	-(8-1)*2(a4),a4
	bra.s	ddfx_mlp
DDFX_mlpend

	pop d0-d7/a0-a4
	rts

dispfxskip = -1
Dispfxend = -2 ;also in fxeditor!!!
dispfxfin = -3

Dispfxptr	dc.l	0				; Ptr to pos in dispfxtable
DispFXlist	;list of x/y block no.s
;spiral in: tl>bl>br>tr etc
	DC.B	0,0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,1,7,2,7
	DC.B	3,7,4,7,5,7,6,7,7,7,8,7,9,7,9,6,9,5,9,4
	DC.B	9,3,9,2,9,1,9,0,8,0,7,0,6,0,5,0,4,0,3,0
	DC.B	2,0,1,0,1,1,1,2,1,3,1,4,1,5,1,6,2,6,3,6
	DC.B	4,6,5,6,6,6,7,6,8,6,8,5,8,4,8,3,8,2,8,1
	DC.B	7,1,6,1,5,1,4,1,3,1,2,1,2,2,2,3,2,4,2,5
	DC.B	3,5,4,5,5,5,6,5,7,5,7,4,7,3,7,2,6,2,5,2
	DC.B	4,2,3,2,3,3,3,4,4,4,5,4,6,4,6,3,5,3,4,3
	dc.b	dispfxend
;Rippler tl>br
	DC.B	0,0,1,0,0,1,2,0,1,1,0,2,3,0,2,1,1,2,0,3
	DC.B	4,0,3,1,2,2,1,3,0,4,5,0,4,1,3,2,2,3,1,4
	DC.B	0,5,6,0,5,1,4,2,3,3,2,4,1,5,0,6,7,0,6,1
	DC.B	5,2,4,3,3,4,2,5,1,6,0,7,8,0,7,1,6,2,5,3
	DC.B	4,4,3,5,2,6,1,7,9,0,8,1,7,2,6,3,5,4,4,5
	DC.B	3,6,2,7,9,1,8,2,7,3,6,4,5,5,4,6,3,7,9,2
	DC.B	8,3,7,4,6,5,5,6,4,7,9,3,8,4,7,5,6,6,5,7
	DC.B	9,4,8,5,7,6,6,7,9,5,8,6,7,7,9,6,8,7,9,7
	DC.B	dispfxend
;horizontals: tl>tr....
	DC.B	0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,0
	DC.B	9,1,8,1,7,1,6,1,5,1,4,1,3,1,2,1,1,1,0,1
	DC.B	0,2,1,2,2,2,3,2,4,2,5,2,6,2,7,2,8,2,9,2
	DC.B	9,3,8,3,7,3,6,3,5,3,4,3,3,3,2,3,1,3,0,3
	DC.B	0,4,1,4,2,4,3,4,4,4,5,4,6,4,7,4,8,4,9,4
	DC.B	9,5,8,5,7,5,6,5,5,5,4,5,3,5,2,5,1,5,0,5
	DC.B	0,6,1,6,2,6,3,6,4,6,5,6,6,6,7,6,8,6,9,6
	DC.B	9,7,8,7,7,7,6,7,5,7,4,7,3,7,2,7,1,7,0,7
	DC.B	dispfxend

;verticals: tl>bl...
	DC.B	0,0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,1,7,1,6
	DC.B	1,5,1,4,1,3,1,2,1,1,1,0,2,0,2,1,2,2,2,3
	DC.B	2,4,2,5,2,6,2,7,3,7,3,6,3,5,3,4,3,3,3,2
	DC.B	3,1,3,0,4,0,4,1,4,2,4,3,4,4,4,5,4,6,4,7
	DC.B	5,7,5,6,5,5,5,4,5,3,5,2,5,1,5,0,6,0,6,1
	DC.B	6,2,6,3,6,4,6,5,6,6,6,7,7,7,7,6,7,5,7,4
	DC.B	7,3,7,2,7,1,7,0,8,0,8,1,8,2,8,3,8,4,8,5
	DC.B	8,6,8,7,9,7,9,6,9,5,9,4,9,3,9,2,9,1,9,0
	DC.B	dispfxend

	dc.b	dispfxfin
	even

FXBuffer
	ds.w	(8+1)*2					; start/end headers
	ds.w	16*20					; main x/ys
	even

;Data must be in chip memory!
;SpinBlocks_Bobs	;32 pixels height:full>blank over 9 frames total!
;	dc.w	0
;	dc.w	2+1,32,(9-1)*4
;	dc.l	SpinBlocksBMap,SpinBlocksMask
;	ds.w	5
;	dc.l	0
;SpinBlocksBMAP	incbin	gfx/Spinblocks.iraw
;SpinBlocksmask
;	rept	32
;	dcb.l 9*3,-1
;	dcb.l 9*2,0
;	endr
	