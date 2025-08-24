;	AUTO	J\WB\DMSHead\DMSEnd\

	move.w	#TextEnd-TxtData,HLength
	move.w	#TextEnd-TxtData,ULength
	move.w	#TextEnd-TxtData,PLength	;Length Of Text

	moveq	#0,d0
	moveq	#0,d1
	lea	TxtData(pc),a0
	move.w	ULength(pc),d2
	subq.w	#1,d2
ChkSmLp	move.b	(a0)+,d0
	add.w	d0,d1
	dbf	d2,ChkSmLp
	move.w	d1,UPckSum			;Sum of Unpacked Text

	move.w	PLength(pc),d0
	lea	TxtData(pc),a0
	bsr	CRCChck
	move.w	d0,DataCRC			;CRC for Packed Data

	moveq	#18,d0
	lea	TrkHead(pc),a0
	bsr	CRCChck
	move.w	d0,HeadCRC			;CRC for Track Header

	moveq	#50,d0
	lea	DMSHead+4(pc),a0
	bsr	CRCChck
	move.w	d0,InfoCRC			;CRC for DMS Header

	rts

CRCChck	movem.l	d6-d7,-(a7)
	moveq	#0,d1
	moveq	#0,d6
	moveq	#0,d7
	subq.w	#1,d0
	lea	CRCLst2(pc),a1
CRCLoop	move.b	(a0)+,d6
	eor.b	d1,d6
	move.b	(a1,d6.w),d1
	eor.b	d7,d1
	move.b	CRCLst1(pc,d6.w),d7
	dbf	d0,CRCLoop
	move.w	d7,d0
	lsl.w	#8,d0
	move.b	d1,d0
	movem.l	(a7)+,d6-d7
	rts

CRCLst1	dc.b	$00,$c0,$c1,$01,$c3,$03,$02,$c2,$c6,$06,$07,$c7,$05,$c5,$c4,$04
	dc.b	$cc,$0c,$0d,$cd,$0f,$cf,$ce,$0e,$0a,$ca,$cb,$0b,$c9,$09,$08,$c8
	dc.b	$d8,$18,$19,$d9,$1b,$db,$da,$1a,$1e,$de,$df,$1f,$dd,$1d,$1c,$dc
	dc.b	$14,$d4,$d5,$15,$d7,$17,$16,$d6,$d2,$12,$13,$d3,$11,$d1,$d0,$10
	dc.b	$f0,$30,$31,$f1,$33,$f3,$f2,$32,$36,$f6,$f7,$37,$f5,$35,$34,$f4
	dc.b	$3c,$fc,$fd,$3d,$ff,$3f,$3e,$fe,$fa,$3a,$3b,$fb,$39,$f9,$f8,$38
	dc.b	$28,$e8,$e9,$29,$eb,$2b,$2a,$ea,$ee,$2e,$2f,$ef,$2d,$ed,$ec,$2c
	dc.b	$e4,$24,$25,$e5,$27,$e7,$e6,$26,$22,$e2,$e3,$23,$e1,$21,$20,$e0
	dc.b	$a0,$60,$61,$a1,$63,$a3,$a2,$62,$66,$a6,$a7,$67,$a5,$65,$64,$a4
	dc.b	$6c,$ac,$ad,$6d,$af,$6f,$6e,$ae,$aa,$6a,$6b,$ab,$69,$a9,$a8,$68
	dc.b	$78,$b8,$b9,$79,$bb,$7b,$7a,$ba,$be,$7e,$7f,$bf,$7d,$bd,$bc,$7c
	dc.b	$b4,$74,$75,$b5,$77,$b7,$b6,$76,$72,$b2,$b3,$73,$b1,$71,$70,$b0
	dc.b	$50,$90,$91,$51,$93,$53,$52,$92,$96,$56,$57,$97,$55,$95,$94,$54
	dc.b	$9c,$5c,$5d,$9d,$5f,$9f,$9e,$5e,$5a,$9a,$9b,$5b,$99,$59,$58,$98
	dc.b	$88,$48,$49,$89,$4b,$8b,$8a,$4a,$4e,$8e,$8f,$4f,$8d,$4d,$4c,$8c
	dc.b	$44,$84,$85,$45,$87,$47,$46,$86,$82,$42,$43,$83,$41,$81,$80,$40
	dc.b	$00

CRCLst2	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$01,$c0,$80,$41,$00,$c1,$81,$40,$00,$c1,$81,$40,$01,$c0,$80,$41
	dc.b	$00,$c1,$81,$40,$01,$c0,$80,$41,$01,$c0,$80,$41,$00,$c1,$81,$40
	dc.b	$00,$28,$00

DMSHead	dc.l	"DMS!"		;Identifier
	dc.w	0,0,0		;Unknown, leave 0
	dc.w	8		;General Info
				;1-NOZERO
				;2-ENCRYPTED
				;4-OPTIMIZED
				;8-BANNER
	dc.l	$2cfe3045	;Creation date
	dc.w	-1		;Low Track
	dc.w	-1		;High Track
	dc.l	100		;Bytes Packed
	dc.l	1000		;Bytes Unpacked
	dc.l	0		;Serial number of creator
	dc.w	1		;Processor
				;01-68000
				;02-68010
				;03-68020
				;04-68030
				;05-68040
				;06-68050
				;07-8086
				;08-8088
				;09-80188
				;10-80186
				;11-80286
				;12-80386SX
				;13-80386
				;14-80486
				;15-80586
	dc.w	0		;CoProcessor
				;00-None
				;01-68881
				;02-68882
				;03-8087
				;04-80287
				;05-80387SX
				;06-80387
	dc.w	1		;Machine Type
				;1-AMIGA
				;2-PC/CLONE
				;3-ATARI ST
				;4-MACINTOSH
	dc.l	0		;CPU Speed
	dc.l	49		;Time Taken
	dc.w	112		;DMS Version
	dc.w	111		;DMS Version Needed
	dc.w	1		;Disktype of Archive
				;01-AMIGA 1.0 OFS
				;02-AMIGA 1.0 FFS
				;03-MS-DOS
				;04-AMAX
				;05-MAC
	dc.w	6		;Compression Type
				;0-NOCOMP
				;1-SIMPLE
				;2-QUICK
				;3-MEDIUM
				;4-DEEP
				;5-HEAVY1
				;6-HEAVY2
				;7-HEAVY3
				;8-HEAVY4
				;9-HEAVY5
InfoCRC	dc.w	0		;Info Header CRC

TrkHead	dc.w	"TR",-1
	dc.w	0
HLength	dc.w	0		;Bytes To Next Header
PLength	dc.w	0		;Plength
ULength	dc.w	0		;Ulength
	dc.b	5		;Cflag
	dc.b	0		;Compression method
UPckSum	dc.w	0		;USUM
DataCRC	dc.w	0		;DCRC
HeadCRC	dc.w	0		;HCRC

TxtData	incbin	"DH1:Banner.txt"
TextEnd
DMSEnd
