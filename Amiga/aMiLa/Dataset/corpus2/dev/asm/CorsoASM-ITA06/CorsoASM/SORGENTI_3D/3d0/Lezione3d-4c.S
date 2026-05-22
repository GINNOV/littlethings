
	section	lamevec,code

;; sintab STANDARD OLD1 con aggiunto sintab prima di costab come CRYPTOINTRO
; e VECTOR2

*****************************************************************************
	include	"Assembler2:sorgenti4/startup1.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper, bitplane e blitter
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
	lea	SpritePointers1,a0
	lea	SpritePointers1,a1
	move.w	#7,d0
	move.l	#Dummy,d1
ClearS:
	move.w	d1,6(a0)
	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a0)
	move.w	d1,2(a1)
	swap	d1
	add.l	#8,a0
	add.l	#8,a1
	dbf	d0,ClearS

	move.l	#Screen1,d0
	move.w	d0,Bpl1+6
	swap	d0
	move.w	d0,Bpl1+2

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	CMP.b	#$ff,$dff006	; linea 255?
	bne.s	mouse

	moveq	#0,d0
	moveq	#0,d1

	bsr.s	ClearScreen
	bsr.w	VectorCalc

	clr.w	d0
	move.b	$dff00a,d0
	lsl.w	#1,d0
	move.w	d0,AngleData+4

	btst 	#6,$bfe001	; tasto sinistro?
	bne.s 	mouse	
;Exit:
	rts




	;---------------------------------------
graph:	dc.b 'graphics.library',0
	EVEN
SYSSTACK:	dc.l 0
STACKPOINTER:	dc.l 0
Dummy:		dc.l 0
	;---------------------------------------

ClearScreen:			;This routine also fix Diff draw pages
	btst    #14,$dff002
	bne     ClearScreen
	lea	VectorScreens(pc),a0
	move.w	VectorPlane,d0
	move.l	(a0,d0.w),d1
	move.w	d1,Bpl1+6
	swap	d1
	move.w	d1,Bpl1+2
	bchg	#2,d0
	move.l	(a0,d0.w),d1
	bchg	#2,VectorPlane+1

ClearThisPlane:
	move.l	d1,LineMem		;fix drawl
	move.w	#$100,$dff040		;USE D,A SATT MINTERM D=A
	move.w	#0,$dff042		;O=BLTCON1
	move.l	#$ffffffff,$dff044
	move.l	d1,$dff054		;DEST
	move.w	#0,$dff066		;SATT MODULO D
	move.w	#240*64+20,$dff058	;SATT STORLEK,STARTA BLT
	rts     

	;-----------------------------------------------------------
VectorCalc:
	lea	CosinusData(pc),a0	;load Cosinus-data
	lea	SinusData(pc),a1	;load Sinus-data
	move.w	AngleData,d0		;load a in d0
	move.w	(a0,d0.w),Cosa
	move.w	(a1,d0.w),Sina
	move.w	AngleData+2,d0		;load b in d0
	move.w	(a0,d0.w),Cosb		;Cos b
	move.w	(a1,d0.w),Sinb		;Sin b
	move.w	AngleData+4,d0		;load c in d0
	move.w	(a0,d0.w),Cosc		;Cos c
	move.w	(a1,d0.w),Sinc		;Sin c

	lea	Oggetto(pc),a0
	lea	Pointx(pc),a3		;Where to store calc coords
	lea	Pointy(pc),a4
	move.w	Coordnum,d5		;Ant coords
	subq.w	#1,d5			;as counter
	
CalcMoreCoords:
	move.w	(a0)+,d0		;d0=x
	move.w	(a0)+,d1		;d1=y
	move.w	(a0)+,d2		;d2=z

	;Calculation for rot. a
	
	move.l	d1,d3
	move.l	d2,d4
	muls	Cosa,d1
	muls	Sina,d4
	add.l	d4,d1
	lsl.l	#2,d1
	swap	d1			;d1=yy
	muls	Cosa,d2
	muls	Sina,d3
	sub.l	d3,d2
	lsl.l	#2,d2
	swap	d2			;d2=zz
	
	;Calculation for rot. b
	
	move.l	d0,d3
	move.l	d2,d4
	muls	Cosb,d0
	muls	Sinb,d4
	sub.l	d4,d0
	lsl.l	#2,d0
	swap	d0			;d0=xx
	muls	Cosb,d2
	muls	Sinb,d3
	add.l	d3,d2
	lsl.l	#2,d2
	swap	d2			;d2=z
	
	;Calculation for rot. c
	
	move.l	d0,d3
	move.l	d1,d4
	muls	Cosc,d0
	muls	Sinc,d4
	add.l	d4,d0
	lsl.l	#2,d0
	swap	d0			;d0=x
	muls	Cosc,d1
	muls	Sinc,d3
	sub.l	d3,d1
	lsl.l	#2,d1
	swap	d1			;d1=y
	
	add.w	#256,d2
	muls	Dist,d0			;Distance
	muls	Dist,d1			;Distance
	divs	d2,d0
	divs	d2,d1
	add.w	Centrex,d0		;add to center
	add.w	Centrey,d1		;add to center
	move.w	d0,(a3)+		;Save calc coords
	move.w	d1,(a4)+
	
	dbra	d5,CalcMoreCoords

	;-------------------------------
	addq.w	#2,AngleData		;rot speed x
	cmp.w	#720,AngleData
	blt.s	NoXReset
	sub.w	#720,AngleData
NoXReset:
	add.w	#2,AngleData+2		;rot speed y
	cmp.w	#720,AngleData+2
	blt.s	NoYReset
	sub.w	#720,AngleData+2
NoYReset:
	add.w	#2,AngleData+4		;rot speed z
	cmp.w	#720,AngleData+4
	blt.s	NoZReset
	sub.w	#720,AngleData+4
NoZReset:
	;-------------------------------
	lea	LinkCoords(pc),a1
	lea	Pointx(pc),a2		;Addr of calc coords
	lea	Pointy(pc),a3
	lea	LineNum(pc),a4
	move.w	ObjNum,d7		;Num of Objects
	subq.w	#1,d7			;as counter

DrawMoreObj:
	move.w	(a4)+,d6
	subq.w	#$01,d6
	move.w	d7,SaveD7

DrawMoreLines:
	move.w	(a1)+,d4
	lsl.w	#1,d4			;*2 (x.w;y.w)
	move.w	(a2,d4.w),d0		;x1
	move.w	(a3,d4.w),d1		;y1
	move.w	(a1)+,d4
	lsl.w	#1,d4			;*2 (x.w;y.w)
	move.w	(a2,d4.w),d2		;x2
	move.w	(a3,d4.w),d3		;y2
	bsr	LineDraw		;draw line

	dbf	d6,DrawMoreLines
	move.w	SaveD7,d7
	dbf	d7,DrawMoreObj
	rts

;-------------------------------
	
Cosa:	dc.l	0
Sina:	dc.l	0
Cosb:	dc.l	0
Sinb:	dc.l	0
Cosc:	dc.l	0
Sinc:	dc.l	0
	;--------$ffff=end of data--------
Coordnum:	dc.w	8

Oggetto:
	dc.w	-50,+50,-50	; P0 (X,Y,Z)
	dc.w	+50,+50,-50	; P1 (X,Y,Z)
	dc.w	+50,-50,-50	; P2 (X,Y,Z)
	dc.w	-50,-50,-50	; P3 (X,Y,Z)
	dc.w	-50,+50,+50	; P4 (X,Y,Z)
	dc.w	+50,+50,+50	; P5 (X,Y,Z)
	dc.w	+50,-50,+50	; P6 (X,Y,Z)
	dc.w	-50,-50,+50	; P7 (X,Y,Z)

	;-------------------------------
Objnum:	dc.w	1
LineNum:
	dc.w	12,12

LinkCoords:	;From,To,From,To.........
	dc.w	0,1	; faccia davanti
	dc.w	1,2
	dc.w	2,3
	dc.w	3,0

	dc.w	4,5	; faccia dietro
	dc.w	5,6
	dc.w	6,7
	dc.w	7,4

	dc.w	0,4	; spigoli laterali
	dc.w	1,5
	dc.w	2,6
	dc.w	3,7


	;-------------------------------
Pointx:	blk.w	50*2,0		;Saved calc coords
Pointy:	blk.w	50*2,0

Dist:	dc.w	256		;Distance norm 256

Centrex:	dc.w	160
Centrey:	dc.w	128

VectorScreens:
	dc.l	Screen1,Screen2

VectorPlane:	dc.w	0

AngleData:	dc.w	360,0,0

SaveD7:	dc.w	0

SinusData:
	DC.W	$0000,$011E,$023C,$0359,$0477,$0594,$06B1,$07CD
	DC.W	$08E8,$0A03,$0B1D,$0C36,$0D4E,$0E66,$0F7C,$1090
	DC.W	$11A4,$12B6,$13C7,$14D6,$15E4,$16F0,$17FA,$1902
	DC.W	$1A08,$1B0C,$1C0E,$1D0E,$1E0C,$1F07,$2000,$20F6
	DC.W	$21EA,$22DB,$23CA,$24B5,$259E,$2684,$2767,$2847
	DC.W	$2923,$29FD,$2AD3,$2BA6,$2C75,$2D41,$2E0A,$2ECE
	DC.W	$2F90,$304D,$3107,$31BD,$326F,$331D,$33C7,$346D
	DC.W	$350F,$35AD,$3646,$36DC,$376D,$37FA,$3882,$3906
	DC.W	$3986,$3A01,$3A78,$3AEA,$3B57,$3BC0,$3C24,$3C83
	DC.W	$3CDE,$3D34,$3D85,$3DD2,$3E19,$3E5C,$3E9A,$3ED3
	DC.W	$3F07,$3F36,$3F61,$3F86,$3FA6,$3FC2,$3FD8,$3FEA
	DC.W	$3FF6,$3FFE
CosinusData:
	DC.W	$4000,$3FFE,$3FF6,$3FEA,$3FD8,$3FC2
	DC.W	$3FA6,$3F86,$3F61,$3F36,$3F07,$3ED3,$3E9A,$3E5C
	DC.W	$3E19,$3DD2,$3D85,$3D34,$3CDE,$3C83,$3C24,$3BC0
	DC.W	$3B57,$3AEA,$3A78,$3A01,$3986,$3906,$3882,$37FA
	DC.W	$376D,$36DC,$3646,$35AD,$350F,$346D,$33C7,$331D
	DC.W	$326F,$31BD,$3107,$304D,$2F90,$2ECE,$2E0A,$2D41
	DC.W	$2C75,$2BA6,$2AD3,$29FD,$2923,$2847,$2767,$2684
	DC.W	$259E,$24B5,$23CA,$22DB,$21EA,$20F6,$2000,$1F07
	DC.W	$1E0C,$1D0E,$1C0E,$1B0C,$1A08,$1902,$17FA,$16F0
	DC.W	$15E4,$14D6,$13C7,$12B6,$11A4,$1090,$0F7C,$0E66
	DC.W	$0D4E,$0C36,$0B1D,$0A03,$08E8,$07CD,$06B1,$0594
	DC.W	$0477,$0359,$023C,$011E,$0000,$FEE2,$FDC4,$FCA7
	DC.W	$FB89,$FA6C,$F94F,$F833,$F718,$F5FD,$F4E3,$F3CA
	DC.W	$F2B2,$F19A,$F084,$EF70,$EE5C,$ED4A,$EC39,$EB2A
	DC.W	$EA1C,$E910,$E806,$E6FE,$E5F8,$E4F4,$E3F2,$E2F2
	DC.W	$E1F4,$E0F9,$E000,$DF0A,$DE16,$DD25,$DC36,$DB4B
	DC.W	$DA62,$D97C,$D899,$D7B9,$D6DD,$D603,$D52D,$D45A
	DC.W	$D38B,$D2BF,$D1F6,$D132,$D070,$CFB3,$CEF9,$CE43
	DC.W	$CD91,$CCE3,$CC39,$CB93,$CAF1,$CA53,$C9BA,$C924
	DC.W	$C893,$C806,$C77E,$C6FA,$C67A,$C5FF,$C588,$C516
	DC.W	$C4A9,$C440,$C3DC,$C37D,$C322,$C2CC,$C27B,$C22E
	DC.W	$C1E7,$C1A4,$C166,$C12D,$C0F9,$C0CA,$C09F,$C07A
	DC.W	$C05A,$C03E,$C028,$C016,$C00A,$C002,$C000,$C002
	DC.W	$C00A,$C016,$C028,$C03E,$C05A,$C07A,$C09F,$C0CA
	DC.W	$C0F9,$C12D,$C166,$C1A4,$C1E7,$C22E,$C27B,$C2CC
	DC.W	$C322,$C37D,$C3DC,$C440,$C4A9,$C516,$C588,$C5FF
	DC.W	$C67A,$C6FA,$C77E,$C806,$C893,$C924,$C9BA,$CA53
	DC.W	$CAF1,$CB93,$CC39,$CCE3,$CD91,$CE43,$CEF9,$CFB3
	DC.W	$D070,$D132,$D1F6,$D2BF,$D38B,$D45A,$D52D,$D603
	DC.W	$D6DD,$D7B9,$D899,$D97C,$DA62,$DB4B,$DC36,$DD25
	DC.W	$DE16,$DF0A,$E000,$E0F9,$E1F4,$E2F2,$E3F2,$E4F4
	DC.W	$E5F8,$E6FE,$E806,$E910,$EA1C,$EB2A,$EC39,$ED4A
	DC.W	$EE5C,$EF70,$F084,$F19A,$F2B2,$F3CA,$F4E3,$F5FD
	DC.W	$F718,$F833,$F94F,$FA6C,$FB89,$FCA7,$FDC4,$FEE2
	DC.W	$0000,$011E,$023C,$0359,$0477,$0594,$06B1,$07CD
	DC.W	$08E8,$0A03,$0B1D,$0C36,$0D4E,$0E66,$0F7C,$1090
	DC.W	$11A4,$12B6,$13C7,$14D6,$15E4,$16F0,$17FA,$1902
	DC.W	$1A08,$1B0C,$1C0E,$1D0E,$1E0C,$1F07,$2000,$20F6
	DC.W	$21EA,$22DB,$23CA,$24B5,$259E,$2684,$2767,$2847
	DC.W	$2923,$29FD,$2AD3,$2BA6,$2C75,$2D41,$2E0A,$2ECE
	DC.W	$2F90,$304D,$3107,$31BD,$326F,$331D,$33C7,$346D
	DC.W	$350F,$35AD,$3646,$36DC,$376D,$37FA,$3882,$3906
	DC.W	$3986,$3A01,$3A78,$3AEA,$3B57,$3BC0,$3C24,$3C83
	DC.W	$3CDE,$3D34,$3D85,$3DD2,$3E19,$3E5C,$3E9A,$3ED3
	DC.W	$3F07,$3F36,$3F61,$3F86,$3FA6,$3FC2,$3FD8,$3FEA
	DC.W	$3FF6,$3FFE

LineMem:
	dc.l	Screen1
	
LineDraw:
	moveq   #$0f,d4
	and.w   d2,d4
	sub.w   d3,d1
	mulu    #$0028,d3
	sub.w   d2,d0
	blt     a_054d34
	tst.w   d1
	blt     a_054d24
	cmp.w   d0,d1
	bge     a_054d1e
	moveq   #$11,d7
	bra     a_054d56
a_054d1e:
	moveq   #$01,d7
	exg     d1,d0
	bra     a_054d56
a_054d24:
	neg.w   d1
	cmp.w   d0,d1
	bge     a_054d2e
	moveq   #$19,d7
	bra     a_054d56
a_054d2e:
	moveq   #$05,d7
	exg     d1,d0
	bra     a_054d56
a_054d34:
	neg.w   d0
	tst.w   d1
	blt     a_054d48
	cmp.w   d0,d1
	bge     a_054d42
	moveq   #$15,d7
	bra     a_054d56
a_054d42:
	moveq   #$09,d7
	exg     d1,d0
	bra     a_054d56
a_054d48:
	neg.w   d1
	cmp.w   d0,d1
	bge     a_054d52
	moveq   #$1d,d7
	bra    	a_054d56
a_054d52:
	moveq   #$0d,d7
	exg     d1,d0
a_054d56:
	add.w   d1,d1
	asr.w   #3,d2
	ext.l   d2
	add.l   d2,d3
	move.w  d1,d2
	sub.w   d0,d2
	bge     a_054d68
	or.w    #$0040,d7
a_054d68:
	or.w    #$0000,d7
	lea     $dff000.l,a6
	move.w  d2,a0

WaitBlt:
	btst    #$0006,$0002(a6)
	bne     WaitBlt
	move.w  d1,$0062(a6)
	move.w  d2,d1
	sub.w   d0,d1
	move.w  d1,$0064(a6)
	moveq   #-1,d1			;#$ff
	move.l  d1,$0044(a6)
	move.w  #$8000,$0074(a6)
	move.w  #$0028,$0060(a6)
	move.w  d7,d5
	addq.w  #1,d0
	asl.w   #6,d0
	addq.w  #2,d0
	swap    d4
	asr.l   #4,d4
	or.w    #$0b5a,d4		;#$0bca or
	swap    d5			;#$0b6a xor
	move.w  d4,d5
	swap    d5
	add.l   LineMem,d3
;	or.l	#2,d5			;Only 1 Pix/Line ; NO!
	move.l  d5,$0040(a6)
	move.w  a0,$0052(a6)
	move.l  d3,$0048(a6)
	move.l  d3,$0054(a6)
	move.w  #$ffff,$0072(a6)
	move.w  d0,$0058(a6)
	rts     

		Section	Coppero,data_C

CopperList:
	dc.l $01001000,$01020000,$00920038,$009400d0,$008e2c81,$00902cc1
BPL1:
	dc.l $00e00000,$00e20000
	dc.l $01080000,$010a0000
SpritePointers1:
	dc.l $01200000,$01220000,$01240000,$01260000,$01280000,$012a0000
	dc.l $012c0000,$012e0000,$01300000,$01320000,$01340000,$01360000
	dc.l $01380000,$013a0000,$013c0000,$013e0000

	
	dc.l $01800003
	dc.l $018200f3
	
	dc.l $fffffffe

	Section	buffero,bss_C

Screen1:
	ds.b	256*40
Screen2:
	ds.b	256*40

	end

