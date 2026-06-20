****************************************************************************
; Basato sul Vector Object Editor by BTG of PSI 1993
;
; Addictional coding by Randy of NA^CMX (ora RAM JAM)
****************************************************************************

; sistema: punti a se e linee a se.
; tabella standard variata |512 anziche' 360 valori per 360 gradi...
; tanto dividere l'angolo giro in 360 e' una convenzione stupida...

; VERSIONE NORMALE 320*256

scr_bytes	= 40	; Numero di bytes per ogni linea orizzontale
			; (da questa si calcola la larghezza dello schermo,
			; moltiplicando i bytes per 8: schermo norm. 320/8=40
			; Es. per uno schermo largo 336 pixel, 336/8=42
			; larghezze esempio:
			; 264 pixel = 33 / 272 pixel = 34 / 280 pixel = 35
			; 360 pixel = 45 / 368 pixel = 46 / 376 pixel = 47
			; ... 640 pixel = 80 / 648 pixel = 81 ...

scr_h		= 256	; Altezza dello schermo in linee
scr_x		= $81	; Inizio schermo, posizione XX (normale $xx81) (129)
scr_y		= $2c	; Inizio schermo, posizione YY (normale $2cxx) (44)
scr_res		= 1	; 2 = HighRes (640*xxx) / 1 = LowRes (320*xxx)
scr_lace	= 0	; 0 = non interlace (xxx*256) / 1 = interlace (xxx*512)
scr_bpl		= 1	; Numero Bitplanes


; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)	; BPLCON0
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


	SECTION	ObjectED,CODE

ProgStart:
	MOVEA.L	4.W,A6
	JSR	-$84(A6)
	JSR	-$78(a6)

	LEA	POINTER1(PC),A0		; point planes
	MOVE.L	#Double1,D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	MOVE.W	D0,(A0)
	LEA	POINTER2(PC),A0
	MOVE.L	#Double2,D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	MOVE.W	D0,(A0)

	MOVEA.L	4.w,A6			; open gfxlib
	LEA	graphicslibra(PC),A1
	JSR	-$198(A6)
	MOVE.L	D0,GFXBASE

	LEA	$DFF000,A6		; save dma
	MOVE.W	#$8000,olddma
	MOVE.W	#$8000,oldintena
	MOVE.W	2(A6),D0
	OR.W	D0,olddma
	MOVE.W	#$7FFF,$96(A6)
	MOVE.W	$1C(A6),D0
	OR.W	D0,oldintena

	MOVE.W	#$87D0,$96(A6)
	MOVE.L	VECTABZoomPOINT(PC),D3_Zoom

pointcop2:
	BTST	#0,5(A6)	; aspetta linea 256
	BEQ.S	pointcop2
	MOVE.L	#copper2,$80(A6)	; point cop
	move.W	d0,$88(A6)
	move.w	#0,$1fc(a6)
	MOVE.W	#$87D0,$96(A6)


ANIMATE:
	MOVE.L	4(a6),D0	; $DFF004
	LSR.L	#8,D0
	ANDI.W	#%111111111,D0	; Select only the VPOS bits
	CMPI.W	#$12d,D0	; wait line 301
	BNE.s	ANIMATE

	BSR.W	SWAPSCREENS	; scambia gli schemi doublebuffer
	BSR.W	CLEARSCREEN	; pulisci lo schermo che non si vede
	BSR.W	Viewer_Sphere
	BSR.W	D3_VIEW
	addq.w	#1,contasolido
	cmp.w	#$400,contasolido
	beq.s	WaitBlitx

	cmp.w	#$280+50,contasolido
	bhi.s	nontutto

	cmp.w	#$280,contasolido
	bhi.s	fermatutto

nontutto:
	bsr.w	VECtabcontrol

fermatutto:
	btst	#6,$bfe001
	BNE.S	ANIMATE

Waitblitx:
	BTST	#6,2(A6)	;
	BNE.S	Waitblitx
	LEA	$DFF000,A6
	MOVE.W	#$87D0,$96(A6)

EXITPROG:
	BTST	#6,2(A6)	; Wait blit
	BNE.S	EXITPROG

	MOVEA.L	GFXBASE(PC),A5	; restore old cop
	MOVE.L	$26(A5),$80(A6)
	MOVE.W	d0,$88(A6)

	MOVE.W	olddma(PC),$96(A6)	; restpre dma
	MOVE.W	oldintena(PC),$9A(A6)

	MOVEA.L	4.w,A6			; CLOSEGFX
	MOVEA.L	GFXBASE(PC),A1
	JSR	-$19E(A6)

	MOVEA.L	4.W,A6
	JSR	-$8A(A6)
	JSR	-$7e(A6)
	MOVEQ	#0,D0
	RTS

contasolido:
	dc.w	0

olddma:
	dc.w	$8000
oldintena:
	dc.w	$8000

graphicslibra:
	dc.b	'graphics.library',0,0
GFXBASE:
	dc.l	0

XCOORD:
	dc.w	0
YCOORD:
	dc.w	0
YCOORD2:
	dc.w	0
EXITFLAG:
	dc.w	0


; NOTA: non so bene perche', ma non si puo' cambiare contemporaneamente
; l'angolo Z e quello X, o succede casino

VECTabcontrol:
	movem.l	d0/a0-a1,-(SP)
	bsr.s	VfaiY	; Y YAngle - rotazione attorno asse verticale |
	bsr.w	VfaiZ	; Z ZAngle
;	bsr.w	VfaiX	; X Xangle - rotazione attono asse orizzontale --
	bsr.w	VfaiZoom ; Allontanamento e avvicinamento del solido
	movem.l	(SP)+,d0/a0-a1
	rts

VFaiY:		; - a sinistra, + a destra...
	ADDQ.L	#2,VECTABYPOINT	 ; Fai puntare alla word successiva
	MOVE.L	VECTABYPOINT(PC),A0 ; indirizzo contenuto in long VECTABYPOINT
				 ; copiato in a0
	CMP.L	#FINEVECTABY-2,A0  ; Siamo all'ultima word della VECTAB?
	BNE.S	VNOBSTARTYs	; non ancora? allora continua
	MOVE.L	#VECTABY-2,VECTABYPOINT ; Riparti a puntare dalla prima word-2
VNOBSTARTYs:
	moveq	#0,d0		; azzeriamo d0
	MOVE.W	(A0),YAngle	; copia la word della coordinata in d0
;	move.w	d0,(a1)
	rts			; dei due sprite attacched


VECTABYPOINT:
	dc.l	VECTABY-2	; NOTA: i valori della VECTABella sono word


	; 0 = FRONTALE, 135 di lato, 270 rovesciato, 380 altro lato, 511 rinorm
	; infatti la tabella anziche' 360 valori ne ha 512 per l'angolo giro!
VECTABY:
	DC.W	$0001,$0003,$0006,$0008,$000A,$000C,$000F,$0011,$0013,$0015
	DC.W	$0018,$001A,$001C,$001E,$0021,$0023,$0025,$0027,$0029,$002C
	DC.W	$002E,$0030,$0032,$0035,$0037,$0039,$003B,$003E,$0040,$0042
	DC.W	$0044,$0046,$0049,$004B,$004D,$004F,$0052,$0054,$0056,$0058
	DC.W	$005A,$005D,$005F,$0061,$0063,$0065,$0068,$006A,$006C,$006E
	DC.W	$0070,$0073,$0075,$0077,$0079,$007B,$007D,$0080,$0082,$0084
	DC.W	$0086,$0088,$008A,$008D,$008F,$0091,$0093,$0095,$0097,$0099
	DC.W	$009C,$009E,$00A0,$00A2,$00A4,$00A6,$00A8,$00AA,$00AD,$00AF
	DC.W	$00B1,$00B3,$00B5,$00B7,$00B9,$00BB,$00BD,$00BF,$00C1,$00C3
	DC.W	$00C6,$00C8,$00CA,$00CC,$00CE,$00D0,$00D2,$00D4,$00D6,$00D8
	DC.W	$00DA,$00DC,$00DE,$00E0,$00E2,$00E4,$00E6,$00E8,$00EA,$00EC
	DC.W	$00EE,$00F0,$00F2,$00F4,$00F6,$00F8,$00FA,$00FC,$00FE,$00FF
	DC.W	$0101,$0103,$0105,$0107,$0109,$010B,$010D,$010F,$0111,$0113
	DC.W	$0114,$0116,$0118,$011A,$011C,$011E,$0120,$0121,$0123,$0125
	DC.W	$0127,$0129,$012A,$012C,$012E,$0130,$0132,$0133,$0135,$0137
	DC.W	$0139,$013A,$013C,$013E,$0140,$0141,$0143,$0145,$0146,$0148
	DC.W	$014A,$014B,$014D,$014F,$0151,$0152,$0154,$0155,$0157,$0159
	DC.W	$015A,$015C,$015E,$015F,$0161,$0162,$0164,$0165,$0167,$0169
	DC.W	$016A,$016C,$016D,$016F,$0170,$0172,$0173,$0175,$0176,$0178
	DC.W	$0179,$017B,$017C,$017E,$017F,$0181,$0182,$0183,$0185,$0186
	DC.W	$0188,$0189,$018A,$018C,$018D,$018E,$0190,$0191,$0193,$0194
	DC.W	$0195,$0196,$0198,$0199,$019A,$019C,$019D,$019E,$019F,$01A1
	DC.W	$01A2,$01A3,$01A4,$01A6,$01A7,$01A8,$01A9,$01AA,$01AB,$01AD
	DC.W	$01AE,$01AF,$01B0,$01B1,$01B2,$01B3,$01B5,$01B6,$01B7,$01B8
	DC.W	$01B9,$01BA,$01BB,$01BC,$01BD,$01BE,$01BF,$01C0,$01C1,$01C2
	DC.W	$01C3,$01C4,$01C5,$01C6,$01C7,$01C8,$01C9,$01CA,$01CA,$01CB
	DC.W	$01CC,$01CD,$01CE,$01CF,$01D0,$01D0,$01D1,$01D2,$01D3,$01D4
	DC.W	$01D5,$01D5,$01D6,$01D7,$01D8,$01D8,$01D9,$01DA,$01DA,$01DB
	DC.W	$01DC,$01DD,$01DD,$01DE,$01DF,$01DF,$01E0,$01E0,$01E1,$01E2
	DC.W	$01E2,$01E3,$01E3,$01E4,$01E5,$01E5,$01E6,$01E6,$01E7,$01E7
	DC.W	$01E8,$01E8,$01E9,$01E9,$01EA,$01EA,$01EB,$01EB,$01EB,$01EC
	DC.W	$01EC,$01ED,$01ED,$01ED,$01EE,$01EE,$01EE,$01EF,$01EF,$01EF
	DC.W	$01EF,$01EF,$01EF,$01EE,$01EE,$01EE,$01ED,$01ED,$01ED,$01EC
	DC.W	$01EC,$01EB,$01EB,$01EB,$01EA,$01EA,$01E9,$01E9,$01E8,$01E8
	DC.W	$01E7,$01E7,$01E6,$01E6,$01E5,$01E5,$01E4,$01E3,$01E3,$01E2
	DC.W	$01E2,$01E1,$01E0,$01E0,$01DF,$01DF,$01DE,$01DD,$01DD,$01DC
	DC.W	$01DB,$01DA,$01DA,$01D9,$01D8,$01D8,$01D7,$01D6,$01D5,$01D5
	DC.W	$01D4,$01D3,$01D2,$01D1,$01D0,$01D0,$01CF,$01CE,$01CD,$01CC
	DC.W	$01CB,$01CA,$01CA,$01C9,$01C8,$01C7,$01C6,$01C5,$01C4,$01C3
	DC.W	$01C2,$01C1,$01C0,$01BF,$01BE,$01BD,$01BC,$01BB,$01BA,$01B9
	DC.W	$01B8,$01B7,$01B6,$01B5,$01B3,$01B2,$01B1,$01B0,$01AF,$01AE
	DC.W	$01AD,$01AB,$01AA,$01A9,$01A8,$01A7,$01A6,$01A4,$01A3,$01A2
	DC.W	$01A1,$019F,$019E,$019D,$019C,$019A,$0199,$0198,$0196,$0195
	DC.W	$0194,$0193,$0191,$0190,$018E,$018D,$018C,$018A,$0189,$0188
	DC.W	$0186,$0185,$0183,$0182,$0181,$017F,$017E,$017C,$017B,$0179
	DC.W	$0178,$0176,$0175,$0173,$0172,$0170,$016F,$016D,$016C,$016A
	DC.W	$0169,$0167,$0165,$0164,$0162,$0161,$015F,$015E,$015C,$015A
	DC.W	$0159,$0157,$0155,$0154,$0152,$0151,$014F,$014D,$014B,$014A
	DC.W	$0148,$0146,$0145,$0143,$0141,$0140,$013E,$013C,$013A,$0139
	DC.W	$0137,$0135,$0133,$0132,$0130,$012E,$012C,$012A,$0129,$0127
	DC.W	$0125,$0123,$0121,$0120,$011E,$011C,$011A,$0118,$0116,$0114
	DC.W	$0113,$0111,$010F,$010D,$010B,$0109,$0107,$0105,$0103,$0101
	DC.W	$00FF,$00FE,$00FC,$00FA,$00F8,$00F6,$00F4,$00F2,$00F0,$00EE
	DC.W	$00EC,$00EA,$00E8,$00E6,$00E4,$00E2,$00E0,$00DE,$00DC,$00DA
	DC.W	$00D8,$00D6,$00D4,$00D2,$00D0,$00CE,$00CC,$00CA,$00C8,$00C6
	DC.W	$00C3,$00C1,$00BF,$00BD,$00BB,$00B9,$00B7,$00B5,$00B3,$00B1
	DC.W	$00AF,$00AD,$00AA,$00A8,$00A6,$00A4,$00A2,$00A0,$009E,$009C
	DC.W	$0099,$0097,$0095,$0093,$0091,$008F,$008D,$008A,$0088,$0086
	DC.W	$0084,$0082,$0080,$007D,$007B,$0079,$0077,$0075,$0073,$0070
	DC.W	$006E,$006C,$006A,$0068,$0065,$0063,$0061,$005F,$005D,$005A
	DC.W	$0058,$0056,$0054,$0052,$004F,$004D,$004B,$0049,$0046,$0044
	DC.W	$0042,$0040,$003E,$003B,$0039,$0037,$0035,$0032,$0030,$002E
	DC.W	$002C,$0029,$0027,$0025,$0023,$0021,$001E,$001C,$001A,$0018
	DC.W	$0015,$0013,$0011,$000F,$000C,$000A,$0008,$0006,$0003,$0001
;	incbin	"YCOORDINATOK2.VECTAB"	; val .w
FINEVECTABY:

;

VFaiX:		; - in alto, + in basso
	ADDQ.L	#2,VECTABXPOINT	 ; Fai puntare al  success
	MOVE.L	VECTABXPOINT(PC),A0 ; indirizzo contenuto in long VECTABXPOINT
				 ; copiato in a0
	CMP.L	#FINEVECTABX-2,A0  ; Siamo all'ultima?
	BNE.S	VNOBSTARTXs	; non ancora? allora continua
	MOVE.L	#VECTABX-2,VECTABXPOINT ; Riparti a puntare
VNOBSTARTXs:
;	moveq	#0,d0		; Pulisci d0
	MOVE.w	(A0),Xangle	;d0		; copia la word
;	move.w	d0,(a1)
	rts

VECTABXPOINT:
	dc.l	VECTABX-2	; NOTA: i valori della VECTABella sono bXtes


VECTABX:
	DC.W	$0099,$009F,$00A6,$00AC,$00B2,$00B8,$00BF,$00C5,$00CB,$00D1
	DC.W	$00D7,$00DE,$00E4,$00EA,$00F0,$00F6,$00FC,$0102,$0107,$010D
	DC.W	$0113,$0119,$011E,$0124,$0129,$012F,$0134,$0139,$013F,$0144
	DC.W	$0149,$014E,$0153,$0158,$015C,$0161,$0166,$016A,$016F,$0173
	DC.W	$0177,$017B,$017F,$0183,$0187,$018B,$018E,$0192,$0195,$0198
	DC.W	$019B,$019E,$01A1,$01A4,$01A7,$01A9,$01AC,$01AE,$01B0,$01B2
	DC.W	$01B4,$01B6,$01B8,$01B9,$01BB,$01BC,$01BD,$01BE,$01BF,$01C0
	DC.W	$01C1,$01C1,$01C2,$01C2,$01C2,$01C2,$01C2,$01C2,$01C1,$01C1
	DC.W	$01C0,$01BF,$01BE,$01BD,$01BC,$01BB,$01B9,$01B8,$01B6,$01B4
	DC.W	$01B2,$01B0,$01AE,$01AC,$01A9,$01A7,$01A4,$01A1,$019E,$019B
	DC.W	$0198,$0195,$0192,$018E,$018B,$0187,$0183,$017F,$017B,$0177
	DC.W	$0173,$016F,$016A,$0166,$0161,$015C,$0158,$0153,$014E,$0149
	DC.W	$0144,$013F,$0139,$0134,$012F,$0129,$0124,$011E,$0119,$0113
	DC.W	$010D,$0107,$0102,$00FC,$00F6,$00F0,$00EA,$00E4,$00DE,$00D7
	DC.W	$00D1,$00CB,$00C5,$00BF,$00B8,$00B2,$00AC,$00A6,$009F,$0099
	DC.W	$0093,$008D,$0086,$0080,$007A,$0074,$006D,$0067,$0061,$005B
	DC.W	$0055,$004E,$0048,$0042,$003C,$0036,$0030,$002A,$0025,$001F
	DC.W	$001F,$0025,$002A,$0030,$0036,$003C,$0042,$0048,$004E,$0055
	DC.W	$005B,$0061,$0067,$006D,$0074,$007A,$0080,$0086,$008D,$0093
;	incbin	"XCOORDINAT.VECTAB"	; .w
FINEVECTABX:



VFaiZ:		; - in alto, + in basso
	ADDQ.L	#2,VECTABZPOINT	 ; Fai puntare al  success
	MOVE.L	VECTABZPOINT(PC),A0 ; indirizzo contenuto in long VECTABZPOINT
				 ; copiato in a0
	CMP.L	#FINEVECTABZ-2,A0  ; Siamo all'ultima?
	BNE.S	VNOBSTARTZs	; non ancora? allora continua
	MOVE.L	#VECTABZ-2,VECTABZPOINT ; Riparti a puntare
VNOBSTARTZs:
;	moveq	#0,d0		; Pulisci d0
	MOVE.w	(A0),ZAngle	;d0		; copia la word
;	move.w	d0,(a1)
	rts

VECTABZPOINT:
	dc.l	VECTABZ-2	; NOTA: i valori della VECTABella sono bytes


VECTABZ:
	DC.W	$0080,$0082,$0084,$0086,$0088,$008A,$008C,$008E,$0090,$0092
	DC.W	$0094,$0096,$0098,$009A,$009C,$009E,$00A0,$00A2,$00A4,$00A6
	DC.W	$00A8,$00AA,$00AC,$00AE,$00B0,$00B2,$00B4,$00B6,$00B8,$00BA
	DC.W	$00BC,$00BD,$00BF,$00C1,$00C3,$00C5,$00C7,$00C9,$00CB,$00CD
	DC.W	$00CF,$00D1,$00D3,$00D4,$00D6,$00D8,$00DA,$00DC,$00DE,$00E0
	DC.W	$00E2,$00E3,$00E5,$00E7,$00E9,$00EB,$00EC,$00EE,$00F0,$00F2
	DC.W	$00F4,$00F5,$00F7,$00F9,$00FB,$00FC,$00FE,$0100,$0102,$0103
	DC.W	$0105,$0107,$0108,$010A,$010C,$010E,$010F,$0111,$0112,$0114
	DC.W	$0116,$0117,$0119,$011A,$011C,$011E,$011F,$0121,$0122,$0124
	DC.W	$0125,$0127,$0128,$012A,$012B,$012D,$012E,$0130,$0131,$0133
	DC.W	$0134,$0135,$0137,$0138,$013A,$013B,$013C,$013E,$013F,$0140
	DC.W	$0142,$0143,$0144,$0145,$0147,$0148,$0149,$014A,$014C,$014D
	DC.W	$014E,$014F,$0150,$0151,$0152,$0154,$0155,$0156,$0157,$0158
	DC.W	$0159,$015A,$015B,$015C,$015D,$015E,$015F,$0160,$0161,$0162
	DC.W	$0163,$0164,$0164,$0165,$0166,$0167,$0168,$0169,$0169,$016A
	DC.W	$016B,$016C,$016C,$016D,$016E,$016F,$016F,$0170,$0171,$0171
	DC.W	$0172,$0172,$0173,$0174,$0174,$0175,$0175,$0176,$0176,$0177
	DC.W	$0177,$0178,$0178,$0178,$0179,$0179,$017A,$017A,$017A,$017B
	DC.W	$017B,$017B,$017C,$017C,$017C,$017C,$017D,$017D,$017D,$017D
	DC.W	$017D,$017D,$017E,$017E,$017E,$017E,$017E,$017E,$017E,$017E
	DC.W	$017E,$017E,$017E,$017E,$017E,$017E,$017E,$017E,$017D,$017D
	DC.W	$017D,$017D,$017D,$017D,$017C,$017C,$017C,$017C,$017B,$017B
	DC.W	$017B,$017A,$017A,$017A,$0179,$0179,$0178,$0178,$0178,$0177
	DC.W	$0177,$0176,$0176,$0175,$0175,$0174,$0174,$0173,$0172,$0172
	DC.W	$0171,$0171,$0170,$016F,$016F,$016E,$016D,$016C,$016C,$016B
	DC.W	$016A,$0169,$0169,$0168,$0167,$0166,$0165,$0164,$0164,$0163
	DC.W	$0162,$0161,$0160,$015F,$015E,$015D,$015C,$015B,$015A,$0159
	DC.W	$0158,$0157,$0156,$0155,$0154,$0152,$0151,$0150,$014F,$014E
	DC.W	$014D,$014C,$014A,$0149,$0148,$0147,$0145,$0144,$0143,$0142
	DC.W	$0140,$013F,$013E,$013C,$013B,$013A,$0138,$0137,$0135,$0134
	DC.W	$0133,$0131,$0130,$012E,$012D,$012B,$012A,$0128,$0127,$0125
	DC.W	$0124,$0122,$0121,$011F,$011E,$011C,$011A,$0119,$0117,$0116
	DC.W	$0114,$0112,$0111,$010F,$010E,$010C,$010A,$0108,$0107,$0105
	DC.W	$0103,$0102,$0100,$00FE,$00FC,$00FB,$00F9,$00F7,$00F5,$00F4
	DC.W	$00F2,$00F0,$00EE,$00EC,$00EB,$00E9,$00E7,$00E5,$00E3,$00E2
	DC.W	$00E0,$00DE,$00DC,$00DA,$00D8,$00D6,$00D4,$00D3,$00D1,$00CF
	DC.W	$00CD,$00CB,$00C9,$00C7,$00C5,$00C3,$00C1,$00BF,$00BD,$00BC
	DC.W	$00BA,$00B8,$00B6,$00B4,$00B2,$00B0,$00AE,$00AC,$00AA,$00A8
	DC.W	$00A6,$00A4,$00A2,$00A0,$009E,$009C,$009A,$0098,$0096,$0094
	DC.W	$0092,$0090,$008E,$008C,$008A,$0088,$0086,$0084,$0082,$0080
;	incbin	"ZCOORDINAT.VECTAB"	; .w
FINEVECTABZ:

VFaiZoom:	; - in avanti, + indietro.
	ADDQ.L	#4,VECTABZoomPOINT	 ; Fai puntare al byte successivo
	MOVE.L	VECTABZoomPOINT(PC),A0 ; indirizzo
				 ; copiato in a0
	CMP.L	#FINEVECTABZoom-4,A0  ; Siamo all'ultima?
	BNE.S	VNOBSTARTZoom	; non ancora? allora continua
	MOVE.L	#VECTABZoom-4,VECTABZoomPOINT ; Riparti a puntare
VNOBSTARTZoom:
	MOVE.l	(A0),d3_Zoom	;d0  copia la word dalla VECTABella in d0
	rts

VECTABZoomPOINT:
	dc.l	VECTABZoom-4	; NOTA: i valori della VECTABella sono bytes

; VECTABella con coordinate precalcolate.
		; $c8= massimo vicino, 100000=lontano lontano
VECTABZoom:
	DC.L	$000007DA,$000008C5,$000009B0,$00000A9B,$00000B85,$00000C6F
	DC.L	$00000D58,$00000E42,$00000F2B,$00001013,$000010FC,$000011E4
	DC.L	$000012CC,$000013B3,$0000149A,$00001581,$00001668,$0000174E
	DC.L	$00001834,$00001919,$000019FF,$00001AE4,$00001BC8,$00001CAD
	DC.L	$00001D91,$00001E74,$00001F58,$0000203B,$0000211D,$00002200
	DC.L	$000022E2,$000023C4,$000024A5,$00002586,$00002667,$00002747
	DC.L	$00002827,$00002907,$000029E7,$00002AC6,$00002BA4,$00002C83
	DC.L	$00002D61,$00002E3F,$00002F1C,$00002FF9,$000030D6,$000031B2
	DC.L	$0000328E,$0000336A,$00003445,$00003520,$000035FB,$000036D5
	DC.L	$000037AF,$00003889,$00003962,$00003A3B,$00003B14,$00003BEC
	DC.L	$00003CC4,$00003D9B,$00003E72,$00003F49,$00004020,$000040F6
	DC.L	$000041CB,$000042A1,$00004376,$0000444A,$0000451F,$000045F2
	DC.L	$000046C6,$00004799,$0000486C,$0000493E,$00004A10,$00004AE2
	DC.L	$00004BB3,$00004C84,$00004D55,$00004E25,$00004EF5,$00004FC4
	DC.L	$00005093,$00005162,$00005230,$000052FE,$000053CC,$00005499
	DC.L	$00005A2A,$00005AF4,$00005BBE,$00005C87,$00005D50,$00005E19
	DC.L	$00006389,$0000644E,$00006513,$000065D8,$0000669C,$00006760
	DC.L	$00006CAF,$00006D6F,$00006E2F,$00006EEF,$00006FAE,$0000706D
	DC.L	$00006BED,$00006B2B,$00006A6A,$000069A8,$000068E5,$00006822
	DC.L	$000062C2,$000061FC,$00006136,$0000606F,$00005FA7,$00005EE0
	DC.L	$0000595F,$00005894,$000057C8,$000056FD,$00005631,$00005564
	DC.L	$00004FC3,$00004EF3,$00004E24,$00004D53,$00004C83,$00004BB2
	DC.L	$00004AE1,$00004A0F,$0000493D,$0000486A,$00004798,$000046C4
	DC.L	$000045F1,$0000451D,$00004449,$00004374,$0000429F,$000041CA
	DC.L	$000040F4,$0000401E,$00003F48,$00003E71,$00003D9A,$00003CC2
	DC.L	$00003BEA,$00003B12,$00003A39,$00003960,$00003887,$000037AE
	DC.L	$000036D4,$000035F9,$0000351F,$00003444,$00003368,$0000328C
	DC.L	$000031B0,$000030D4,$00002FF7,$00002F1A,$00002E3D,$00002D5F
	DC.L	$00002C81,$00002BA2,$00002AC4,$000029E5,$00002905,$00002825
	DC.L	$00002745,$00002665,$00002584,$000024A3,$000023C1,$000022E0
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	dc.l	$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe,$21fe
	DC.L	$000021FE,$0000211B,$00002038,$00001F55,$00001E72,$00001D8E
	DC.L	$00001CAA,$00001BC6,$00001AE1,$000019FC,$00001917,$00001831
	dc.l	$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b
	dc.l	$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b
	dc.l	$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b
	dc.l	$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b
	dc.l	$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b
	dc.l	$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b,$174b
	DC.L	$0000174B,$00001665,$0000157F,$00001498,$000013B1,$000012C9
	DC.L	$000011E1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1,$11e1
	dc.l	$000010F9,$00001011,$00000F28,$00000E3F,$00000D56
	DC.L	$00000C6C,$00000B82,$00000A98,$000009AD,$000008C3,$000007D7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
	dc.l	$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7,$7d7
FINEVECTABZoom:


;*************************
;* LR by BTG on 17.03.91 *
;*************************
; bsr Viewer_Sphere to get in orbit around object
; bsr D3_View to plot calculated object in 3D-Wire
; See Obj_Data how an object is structered

;*** Viewer on orbit by YAngle,Xangle,ZAngle

Viewer_Sphere:
	move.w	YAngle(pc),d0
	add.w	d0,d0
	move.w	Xangle(pc),d1
	add.w	d1,d1
	lea	cos(pc),a0	; costab -> a0
	lea	256(a0),a1	; sintab -> a1
	lea	xvie(pc),a2
	move.w	0(a1,d0.w),d3	; Sin YAngle
	move.w	0(a1,d1.w),d5	; Sin Xangle
	move.w	0(a0,d0.w),d2	; Cos YAngle
	move.w	0(a0,d1.w),d4	; Cos Xangle

	move.w	d3,d6
	muls	d4,d6

	swap	D6		;equals asr.l #14,Dx
	rol.l	#2,D6		;
	ext.l	D6		;

	asr.w	#8,d6

	neg.w	d6
	move.w	d6,(a2)

	move.w	d5,d6

	asr.w	#8,d6

	move.w	d6,2(a2)

	move.w	d2,d6
	ext.l	d6
	muls	d4,d6

	swap	D6		;equals asr.l #14,Dx
	rol.l	#2,D6		;
	ext.l	D6		;

	asr.w	#8,d6

	neg.w	d6
	move.w	d6,4(a2)
	rts

D3_Zoom:
	dc.l	$7D0

D3_VIEW:
	bsr.w	TD_Transform	; init Matrix
	movea.l	D3_ObjData(pc),a5
	movea.l	(a5),a5		; Pnt to PointData
	LEA	d3_TransData,A4
	LEA	xpos(PC),A3
	move.l	#[4*scr_bytes],d7
	move.l	#scr_h/2,d6	; lunghezza schermo/2
D3_CalcZero:
	clr.w	(a3)
	clr.w	2(a3)
	clr.w	4(a3)
	BSR.W	td_make3dpoint
	NEG.W	x3d
	NEG.W	y3d
	MOVE.W	x3d(PC),D3_Centre
	MOVE.W	y3d(PC),D3_Centre+2
D3_LOOP:
	CMPI.W	#$FFFF,(A5)
	BEQ.S	D3_GENEND
	MOVE.W	(A5)+,(A3)
	MOVE.W	(A5)+,2(A3)
	MOVE.W	(A5)+,4(A3)
	BSR.W	td_make3dpoint

	MOVE.W	x3d(PC),D0
	ADD.W	D7,D0
	MOVE.W	D0,(A4)+
	MOVE.W	y3d(PC),D0
	ADD.W	D6,D0
	MOVE.W	D0,(A4)+

	BRA.S	D3_LOOP

D3_GENEND:
	movea.l	D3_ObjData(pc),a5	; lea if data direct
	movea.l	4(a5),a5
	lea	D3_TransData,a4
	lea	D3_Centre(pc),a3

D3_PLOTLOOP:
	move.w	#scr_bytes,a1		; bytes per linea orizzontale
	tst.w	Switch
	bne.s	D3_Scr2nd
	lea	Double1,a0	; indirizzo dove tracciare: double1
	bra.s	D3_Scr1st
D3_Scr2nd:
	lea	Double2,a0	; indirizzo dove tracciare: double2
D3_Scr1st:
		; 5432109876543210
;	move.w	#%1010101010101010,a2	; pattern per la linea - a pua'
	move.w	#%1111111111111111,a2	; pattern per la linea - normale
	move.w	(a5)+,d4
	cmp.w	#$ffff,d4	; flag di fine??
	beq.s	D3_END
	add.w	d4,d4		; d4*4
	add.w	d4,d4
	move.w	(a4,d4.w),d0
	move.w	2(a4,d4.w),d1
	add.w	(a3),d0		; x0
	add.w	2(a3),d1	; y0
	move.w	(a5)+,d4
	add.w	d4,d4		; d4*4
	add.w	d4,d4
	move.w	(a4,d4.w),d2
	move.w	2(a4,d4.w),d3
	add.w	(a3),d2		; x1
	add.w	2(a3),d3	; y1

	bsr.w	Drawline	; input: a2.w = pattern della linea
				;	 a1.l = bytes per linea di schermo
				;	 a0.l = indirizzo dello schermo
				;	 d0.w = x0
				;	 d1.w = y0
				;	 d2.w = x1
				;	 d3.w = y1
				;	 d6.l = $dff000!!!
				;
				; la linea e' (x0,y0)-(x1,y1) = (d0,d1)-(d2,d3)
				;
				; 
				; .-------------.	00=====>X
				; |0,0		|	||
				; |		|	||
				; |      max,max|	\/
				; ·-------------'	Y

	bra.s	D3_PLOTLOOP
D3_END:
	rts

D3_Centre:
	dc.w	0,0
D3_Objdata:
	dc.l	OBJ_DATA

;*** Object Data

OBJ_DATA:
	DC.L	naob1_POINTS
	DC.L	naob1_LINES
	DC.L	0

naob1_POINTS:
	DC.W	-1260,0520,-0280,-0840,0520,-0280
	DC.W	-0840,-0280,-0280,-0430,0490,-0280
	DC.W	-0120,0500,-0280,-0110,-0820,-0280
	DC.W	-0390,-0990,-0280,-0360,-0080,-0280
	DC.W	-0950,-0880,-0280,-1440,-0910,-0280
	DC.W	-1180,-0660,-0280,-1270,0520,-0280
	DC.W	 0040,0500,-0280,0560,-0870,-0280
	DC.W	 0970,-0950,-0280,1180,0520,-0280
	DC.W	 0780,0370,-0280,0800,-0030,-0280
	DC.W	 0490,-0020,-0280,0340,0370,-0280
	DC.W	 0020,0490,-0280,0560,-0230,-0280
	DC.W	 0850,-0250,-0280,0780,-0660,-0280
	DC.W	 0560,-0240,-0280,1150,1050,-0280
	DC.W	 1380,0730,-0280,1410,1130,-0280
	DC.W	 1160,1040,-0280,-1090,0560,0650
	DC.W	-0810,0560,0270,-0710,0560,0850
	DC.W	-1080,0560,0640,0690,-0920,0740
	DC.W	 0690,-1080,0300,0690,-0670,0340
	DC.W	-1490,0810,0720,-1360,1060,0720
	DC.W	-1220,0790,0720,-1020,0820,-0920
	DC.W	-0960,0820,-0700,-0640,0820,-0940
	DC.W	 0690,-0940,-0650,0690,-0780,-0880	
	DC.W	 0690,-1080,-0900,0690,-0930,-0660	
	DC.W	-0040,-0530,0880,0280,-0280,0880	
	DC.W	-0080,-0220,0880,-0030,-0540,0880	
	DC.W	-1300,-0730,-0530,-1020,-1030,-0530	
	DC.W	-1050,-0650,-0530,-1280,-0740,-0530	
	DC.W	-1
naob1_LINES:	
	DC.W	 0000,0001,0001,0002,0002,0003,0003,0004	
	DC.W	 0004,0005,0005,0006,0006,0007,0007,0008	
	DC.W	 0008,0009,0009,0010,0010,0011,0012,0013	
	DC.W	 0013,0014,0014,0015,0015,0016,0016,0017	
	DC.W	 0017,0018,0018,0019,0019,0020,0021,0022	
	DC.W	 0022,0023,0023,0024,0025,0026,0026,0027	
	DC.W	 0027,0028,0029,0030,0030,0031,0031,0032	
	DC.W	 0033,0034,0034,0035,0035,0033,0036,0037	
	DC.W	 0037,0038,0038,0036,0039,0040,0040,0041	
	DC.W	 0041,0039,0042,0043,0043,0044,0044,0045
	DC.W	 0046,0047,0047,0048,0048,0049,0050,0051
	DC.W	 0051,0052,0052,0053
	DC.W	-1


; 1. td_transform     |  result in x3d,y3d,z3d
; 2. td_make3dpoint   |  viewer in xvie,yvie,zvie
;    td_turnpoint     |  viedeg in Xangle,YAngle,ZAngle 
;    td_perspective   |  point  in xpos,ypos,zpos
;    td_movepoint


TD_Transform:
	move.w	Xangle(pc),d0
	move.w	YAngle(pc),d1
	move.w	ZAngle(pc),d2
	add.w	d0,d0		; moltiplica per 2 gli angoli, dato che
	add.w	d1,d1		; la tabella dei sincos e' fatta di words
	add.w	d2,d2
	lea	cos(pc),a1 	; indririzzo COS
	lea	256(a1),a0	; sin=cos+90 - indirizzo SIN
	move.w	0(a0,d0.w),a2	; trova sin angolo X
	move.w	0(a0,d1.w),a3	; trova sin angolo Y
	move.w	0(a0,d2.w),a4	; trova sin angolo Z
	lea	SinX(pc),a5
	move.w	a2,(a5)		; salva SinX
	move.w	a3,2(a5)	; salva SinY
	move.w	a4,4(a5)	; salva SinZ
	movea.w	0(a1,d0.w),a2	; a2 = CosX
	movea.w	0(a1,d1.w),a3	; a3 = CosY
	movea.w	0(a1,d2.w),a4	; a4 = CosZ
	move.w	a2,6(a5)	; salva CosX
	move.w	a3,8(a5)	; salva CosY
	move.w	a4,10(a5)	; salva CosZ
	lea	TM+00(pc),a5	; base for transformation
	moveq	#0,d0
	moveq	#0,d1
	move.w	SinX(pc),d0	; TM (0,0)
	muls.w	SinY(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	muls.w	SinZ(pc),d0	; SinZ*(SinX*SinY)
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	CosZ(pc),d1
	muls	CosY(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,d0
	move.w	d0,(a5)		; Salva
	moveq	#0,d0
	moveq	#0,d1
	move.w	SinX(pc),d0	; TM (0,1)
	muls	CosZ(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	SinY(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	SinZ(pc),d1
	muls	CosY(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	sub.w	d1,d0
	move.w	d0,2(a5)	; Salva
	moveq	#0,d0
	move.w	SinY(pc),d0	;TM (0,2)
	muls	CosX(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,4(a5)	; Salva
	moveq	#0,d0
	move.w	SinZ(pc),d0	;TM (1,0)
	muls	CosX(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,6(a5)	; Salva
	moveq	#0,d0
	move.w	CosZ(pc),d0	;TM (1,1)
	muls	CosX(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,8(a5)	; Salva
	moveq	#0,d0
	move.w	SinX(pc),d0	;TM (1,2)
	neg.w	d0
	move.w	d0,10(a5)	; Salva
	moveq	#0,d0
	moveq	#0,d1
	move.w	SinX(pc),d0	;TM (2,0)
	muls	SinZ(pc),d0
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	CosY(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	SinY(pc),d1
	muls	CosZ(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	sub.w	d1,d0
	move.w	d0,12(a5)	; salva
	moveq	#0,d0
	moveq	#0,d1
	move.w	SinX(pc),d0	;TM (2,1)
	muls	CosZ(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	CosY(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	SinZ(pc),d1
	muls	SinY(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,d0
	move.w	d0,14(a5)	; Salva
	moveq	#0,d0
	move.w	CosX(pc),d0	;TM (2,2)
	muls	CosY(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,16(a5)	; Salva
	rts

td_make3dpoint:				; move point
	lea	x3d(pc),a0
	lea	y3d(pc),a1
	lea	z3d(pc),a2
	lea	xpos(pc),a3
	move.w	xvie(pc),d0
	sub.w	d0,(a3)			; xpos
	move.w	yvie(pc),d0
	sub.w	d0,2(a3)		; ypos
	move.w	zvie(pc),d0
	sub.w	d0,4(a3)		; zpos
td_turnpoint:				; turn point
	move.w	xpos(pc),d0
	move.w	TM+00(pc),d1
	muls	d0,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	move.w	d1,(a0)
	move.w	ypos(pc),d2
	move.w	TM+06(pc),d1
	muls	d2,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a0)
	move.w	zpos(pc),d3
	move.w	TM+12(pc),d1
	muls	d3,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a0)
	move.w	TM+02(pc),d1
	muls	d0,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	move.w	d1,(a1)
	move.w	TM+08(pc),d1
	muls	d2,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a1)
	move.w	TM+14(pc),d1
	muls	d3,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a1)
	move.w	TM+04(pc),d1
	muls	d0,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	move.w	d1,(a2)
	move.w	TM+10(pc),d1
	muls	d2,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a2)
	move.w	TM+16(pc),d1
	muls	d3,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a2)
td_perspective:				; put in perspective
	move.w	z3d(pc),d1
	ext.l	d1
	add.l	D3_Zoom(pc),d1
	bne.s	td_nozero
	moveq	#1,d1
td_nozero:
	move.w	x3d(pc),d0
	ext.l	d0
	asl.l	#8,d0
	divs	d1,d0
	move.w	d0,(a0)
	move.w	y3d(pc),d0
	ext.l	d0
	asl.l	#8,d0
	divs	d1,d0
	move.w	d0,2(a0)	
	move.w	d1,4(a0)
	rts

x3d:
	dc.w	0
y3d:
	dc.w	0
z3d:
	dc.w	0

xvie:
	dc.w	0
yvie:
	dc.w	0
zvie:
	dc.w	0

xpos:
	dc.w	0
ypos:
	dc.w	0
zpos:
	dc.w	0

; Angoli di rotazione. L'angolo giro e' di 512 gradi anziche' 360!

Xangle:
	dc.w	0
YAngle:
	dc.w	0
ZAngle:
	dc.w	0

; Seni e Coseni degli angoli Xangle,Yangle,Zangle ricavati dalla tabella
; per eseguire la rotazione

SinX:
	dc.w	0
SinY:
	dc.w	0
SinZ:
	dc.w	0
CosX:
	dc.w	0
CosY:
	dc.w	0
CosZ:
	dc.w	0

TM:			; 9 valori salvati dalla routine di trasformazione
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0

; Routine di disegno delle linee

; input: a2.w = pattern della linea
;	 a0.l = indirizzo dello schermo
;	 a1.l = bytes per linea di schermo
;	 d0.w = x0
;	 d1.w = y0
;	 d2.w = x1
;	 d3.w = y1
;	 d6.l = $dff000!!!
;
; la linea e' (x0,y0)-(x1,y1) = (d0,d1)-(d2,d3)

DrawLine:
	MOVEM.L	D4-D7/A0-A6,-(SP)
	BSR.W	SchifoClippa	  ; aggiusta le coord se sono fuori schermo
	MOVEM.L	(SP)+,D4-D7/A0-A6
	CMP.W	D0,D2		; x0 = x1? bah...
	BNE.S	DrawBlitta
	CMP.W	D1,D3		; anche y0 = y1? se si esci senza disegnare!!
	BNE.S	DrawBlitta
	RTS

DrawBlitta:
	MOVE.L	A1,D4
	MULU.W	D1,D4	; d4 = bytes per linea*y0-trova l'offset verticale
	MOVEQ	#-16,D5	; $FFFFFFF0
	AND.W	D0,D5	; escludi i 4 bit bassi di x0
	LSR.W	#3,D5	; dividi per 8, trovando l'offset orizzontale
	ADD.W	D5,D4	; d4 = start address come offset dall'inizio schermo
	ADD.L	A0,D4	; aggiungi indirizzo schermo: d4 = start address FINALE

	MOVEQ	#0,D5
	SUB.W	D1,D3
	ROXL.B	#1,D5
	TST.W	D3
	BGE.S	OctSelez1
	NEG.W	D3
OctSelez1:
	SUB.W	D0,D2
	ROXL.B	#1,D5
	TST.W	D2
	BGE.S	OctSelez2
	NEG.W	D2
OctSelez2:
	MOVE.W	D3,D1
	SUB.W	D2,D1
	BGE.S	OctSelez3
	EXG	D2,D3
OctSelez3:
	ROXL.B	#1,D5
	MOVE.B	TabOttanti(PC,D5.L),D5
	ADD.W	D2,D2	; d2*2

WaitBlitt:
	BTST	#6,2(A6)	; aspetta la fine del lavoro del blitter
	BNE.S	WaitBlitt

	MOVE.W	D2,$62(A6)	; BLTBMOD - 4y
	SUB.W	D3,D2
	BGE.S	Blizu
	ORI.B	#$40,D5		; setta il bit 6 di BPLCON1 - SIGN = -
Blizu:
	MOVE.W	D2,$52(A6)	; BLTAPT - 2y-x
	SUB.W	D3,D2
	MOVE.W	D2,$64(A6)	; BLTAMOD
	MOVE.W	#$8000,$74(A6)	; BLTADAT
	MOVE.W	A2,$72(A6)	; BLTBDAT - Pattern della linea
	MOVE.W	#$FFFF,$44(A6)
	ANDI.W	#%1111,D0	; seleziona i 4 bit bassi di x0
	ROR.W	#4,D0		; shiftali a destra per BLTCON0
	OR.W	Minterms(PC),D0	; Aggiungi MINTERMS e USE A,C,D
	MOVE.W	D0,$40(A6)	; BLTCON0 -
	MOVE.W	D5,$42(A6)	; BLTCON1 -
	MOVE.L	D4,$48(A6)	; BLTCPT -
	MOVE.L	D4,$54(A6)	; BLTDPT - indirizzo di partenza della linea
	move.l	a1,$100.w
	MOVE.W	A1,$60(A6)	; BLTCMOD - bytes per linea (larghezza/8)
	MOVE.W	A1,$66(A6)	; BLTDMOD - bytes per linea
	LSL.W	#6,D3
	ADDQ.W	#2,D3
	MOVE.W	D3,$58(A6)	; BLTSIZE
	RTS

;	Tabella con i valori per gli ottanti

TabOttanti:
	dc.b	1
	dc.b	$11
	dc.b	9
	dc.b	$15
	dc.b	5
	dc.b	$19
	dc.b	13
	dc.b	$1D

Minterms:		; USEA,C,D acesi e minterms $CA per linea
	dc.w	$BCA


;	Routine pietosa, di clippaggio.

SchifoClippa:
	MOVEQ	#0,D7
	MOVEQ	#0,D4
	TST.W	D0		; Coordinata X0 minore di ZERO?
	BLT.S	NonVaBene0
	CMPI.W	#scr_w,D0		; Coord. X0 maggiore della largh. schermo?
	BGT.S	NonVaBene0
	TST.W	D1		; Coord. Y0 minore di zero?
	BLT.S	NonVaBene0
	CMPI.W	#scr_h,D1		; Coord.Y0 maggiore dell'altezza dello schermo?
	BGT.S	NonVaBene0
	BRA.S	CoordNelloSchermo1

NonVaBene0:
	ADDQ.W	#1,D7	; segnala che non va
	MOVEQ	#1,D4	; d4 - che sono x0-y0
CoordNelloSchermo1:
	MOVEQ	#0,D5
	TST.W	D2		; Coord X1 minore di zero?
	BLT.S	NonVaBene1
	CMPI.W	#scr_w,D2		; Coord X1 maggiore della largh. schermo?
	BGT.S	NonVaBene1
	TST.W	D3		; Coord Y1 minore di zero?
	BLT.S	NonVaBene1
	CMPI.W	#scr_h,D3		; Coord Y2 maggiore dell'altezza dello shermo?
	BGT.S	NonVaBene1
	BRA.S	ControllatoOK

NonVaBene1:
	ADDQ.W	#1,D7	; d7=2 se ci sono errori a entrambi gli xx
	MOVEQ	#1,D5	; d5 segnala errore a x1-y1
ControllatoOK:
	TST.W	D7		; tutto e' andato OK?
	BEQ.S	FinitoCoord		; se si finisci

; clippatura

	MOVE.L	#-1,Controllo1		; altrimenti prova a clippare
	MOVE.L	#513,Controllo2

	CMPI.W	#1,D7		; 1 sola coppia da clippare?
	BEQ.S	MammaClippa

	MOVEQ	#0,D4		; abbiamo fatto almeno x0-y0
	BSR.S	MammaClippa
	CMPI.W	#1,COntaFatto	; abbiamo sistemato tutto?
	BGT.S	Sistema
	MOVEQ	#0,D0		; altrimenti azzera la linea! (buuuh!)
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	rts

Sistema:
	MOVE.W	NuovaX0(PC),D0
	MOVE.W	NuovaY0(PC),D1
	MOVE.W	NuovaX1(PC),D2
	MOVE.W	NuovaX2(PC),D3
FinitoCoord:
	RTS

MammaClippa:
	CLR.W	COntaFatto
	TST.W	D4		; coppia x1,y1?
	BEQ.S	NonScambiare
	EXG	D0,D2		; x0 <> x1
	EXG	D1,D3		; y0 <> y1
NonScambiare:
	MOVE.W	D2,D6
	SUB.W	D0,D6
	MOVE.W	D6,DistX
	MOVE.W	D3,D7
	SUB.W	D1,D7
	MOVE.W	D7,DistY
	TST.W	D7
	BEQ.W	QuestoFatto
	MOVEQ	#0,D4		; coordinata zero
	SUB.L	D1,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D7,D4	; leeeento..
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D6,D5	; leeeento...
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D0,D5
	EXT.L	D5
	TST.L	D4	; y* meno di zero?
	BLT.S	Fatto1
	CMPI.L	#511,D4	; y* piu' di 511?
	BGT.S	Fatto1
	TST.L	D5	; meno della coordinata 0?
	BLT.S	Fatto1
	CMPI.L	#scr_w,D5	; piu' della larghezza dello schermo?
	BGT.S	Fatto1
	MOVE.W	D5,D2
	MOVEQ	#0,D3		; coordinata Y = zero, tutto in ALTO!
	CMP.L	Controllo1(PC),D4
	BLE.S	Cont1
	MOVE.W	D2,CacolatX
	MOVE.W	D3,CacolatY
	MOVE.L	D4,Controllo1
Cont1:
	CMP.L	Controllo2(PC),D4
	BGE.S	Cont2
	MOVE.W	D2,CacolatXok2
	MOVE.W	D3,CacolatYok2
	MOVE.L	D4,Controllo2
Cont2:
	ADDQ.W	#1,COntaFatto
Fatto1:
	MOVE.L	#scr_h,D4		; altezza schermo
	SUB.L	D1,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D7,D4	; leeento
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D6,D5	; leeento
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D0,D5
	EXT.L	D5
	TST.L	D4		; coordinata y* meno di 0?
	BLT.S	QuestoFatto
	CMPI.L	#511,D4		; coordinata y* piu' di 511?
	BGT.S	QuestoFatto
	TST.L	D5		; coordinata x meno di 0?
	BLT.S	QuestoFatto
	CMPI.L	#scr_w,D5		; coordinata x maggiore della largh. schermo?
	BGT.S	QuestoFatto
	MOVE.W	D5,D2
	MOVE.W	#scr_h,D3		; altezza schermo in coord Y - tutto in BASSO
	CMP.L	Controllo1(PC),D4
	BLE.S	Cont3
	MOVE.W	D2,CacolatX
	MOVE.W	D3,CacolatY
	MOVE.L	D4,Controllo1
Cont3:
	CMP.L	Controllo2(PC),D4
	BGE.S	Cont4
	MOVE.W	D2,CacolatXok2
	MOVE.W	D3,CacolatYok2
	MOVE.L	D4,Controllo2
Cont4:
	ADDQ.W	#1,COntaFatto
QuestoFatto:
	TST.W	D6
	BEQ.W	Vaiii
	MOVEQ	#0,D4		; coordinata ZERO
	SUB.L	D0,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D6,D4
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D7,D5
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D1,D5
	EXT.L	D5
	TST.L	D4		; coord Y* meno di zero?
	BLT.S	PassoFatto
	CMPI.L	#511,D4		; coord Y* piu' di 511?
	BGT.S	PassoFatto
	TST.L	D5		; Coordinata Y meno di zero?
	BLT.S	PassoFatto
	CMPI.L	#scr_h,D5		; coord. Y maggiore dell'altezza schermo?
	BGT.S	PassoFatto
	MOVEQ	#0,D2
	MOVE.W	D5,D3
	CMP.L	Controllo1(PC),D4
	BLE.S	cont5
	MOVE.W	D2,CacolatX
	MOVE.W	D3,CacolatY
	MOVE.L	D4,Controllo1
Cont5:
	CMP.L	Controllo2(PC),D4
	BGE.S	Cont6
	MOVE.W	D2,CacolatXok2
	MOVE.W	D3,CacolatYok2
	MOVE.L	D4,Controllo2
Cont6:
	ADDQ.W	#1,COntaFatto
PassoFatto:
	MOVE.L	#scr_w,D4		; larghezza schermo
	SUB.L	D0,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D6,D4
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D7,D5
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D1,D5
	EXT.L	D5
	TST.L	D4		; y* minore di zero?
	BLT.S	Vaiii
	CMPI.L	#511,D4		; x* maggiore di 512?
	BGT.S	Vaiii
	TST.L	D5		; y minore di zero?
	BLT.S	Vaiii
	CMPI.L	#scr_h,D5		; Y maggiore dell'altezza schermo?
	BGT.S	Vaiii
	MOVE.W	#scr_w,D2		; x = larghezza schermo?
	MOVE.W	D5,D3
	CMP.L	Controllo1(PC),D4
	BLE.S	Cont7
	MOVE.W	D2,CacolatX
	MOVE.W	D3,CacolatY
	MOVE.L	D4,Controllo1
Cont7:
	CMP.L	Controllo2(PC),D4
	BGE.S	Cont8
	MOVE.W	D2,CacolatXok2
	MOVE.W	D3,CacolatYok2
	MOVE.L	D4,Controllo2
Cont8:
	ADDQ.W	#1,COntaFatto
Vaiii:
	LEA	CacolatXok2(PC),A0
	LEA	NuovaX1(PC),A1

	MOVE.W	(A0)+,D2	; copia le coordinate...
	MOVE.W	D2,(A1)+
	MOVE.W	(A0)+,D3
	MOVE.W	D3,(A1)+

	MOVE.W	(A0)+,D2
	MOVE.W	D2,(A1)+
	MOVE.W	(A0)+,D3
	MOVE.W	D3,(A1)+

	RTS


COntaFatto:
	dc.w	0

DistX:
	dc.w	0
DistY:
	dc.w	0

NuovaX1:
	dc.w	0
NuovaX2:
	dc.w	0
NuovaX0:
	dc.w	0
NuovaY0:
	dc.w	0

Controllo1:
	dc.l	-1
Controllo2:
	dc.l	511

CacolatXok2:
	dc.w	0
CacolatYok2:
	dc.w	0
CacolatX:
	dc.w	0
CacolatY:
	dc.w	0


SWAPSCREENS:
	BTST	#6,2(A6)	; prima di swappare,il dis. deve essere finito!
	BNE.S	SWAPSCREENS

	EORI.W	#$FFFF,switch
	LEA	PLANEPOINTCOP2,A0
	TST.W	switch
	BEQ.S	Scambia2
	LEA	POINTER1(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
	rts

Scambia2:
	LEA	POINTER2(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
	RTS

CLEARSCREEN:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.W	switch
	BNE.S	Azzera2
	LEA	Double1,a0	; plane1
	BRA.S	Azzera1
Azzera2:
	LEA	Double2,a0	; plane2
Azzera1:
	MOVE.L	SP,OLDSP
	LEA	scr_size(a0),SP		; ADDRESS OF END SCREEN
	MOVEM.L	CLREG(PC),D0-D7/A0-A6	; CLEAR REGISTERS

;	MOVEM.L	D0-D7/A0-A6,-(SP)	; questa e' $48e7FFFE

	dcb.l	scr_size/60,$48E7FFFE ; NOW CLEAR WITH CPU(60 bytes ogni movem)

	MOVEM.L	D0-D7/a0-a1,-(SP)	; azzera gli ultimi 40 bytes...

	MOVE.L	OLDSP(PC),SP	; 60 bytes every instruction!
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS


CLREG:
	DS.L	15

OLDSP:
	dc.l	0
switch:
	dc.w	0



POINTER1:
	dc.l	0
POINTER2:
	dc.l	0

******************************************************************************
* Tabella SENI/COSENI. Questa tabella ha sempre la caratteristica di avere
* i valori moltiplicati per 16384, cioe' shiftati di 14 bit a sinistra, ma
* anziche' esserci 360 valori per i 360 gradi, ci sono 512 valori.
* Dunque 90°, che sono 360/4, qua corrisponde a 512/4=128. Allo stesso modo
* 180° corrisponde al 256esimo valore. L'unica differenza di cui tenere conto
* e' che per fare una rotazione completa occorrono 512 "gradi" anziche' 360.
* L'angolo giro fu diviso in 360 parti, dette gradi, in un periodo in cui
* si credeva che ci fossero 360 soli giorni all'anno, quando l'astronomia
* aveva una grande importanza. In realta' pero' non ha utilita' pratiche
* dividere l'angolo giro in 360 parti. Per esempio vengono usati i radianti,
* che mettono in rapporto la misura dell'arco corrispondente con l'angolo.
* Noi in questo caso siamo nell'assembler, e sapete che 512 e' un numero
* "da computer" come 360 era ad un tempo un numero astronomico.
******************************************************************************


cos:	;128 valori anziche' 90,
	dc.w	$4000,$3FFE,$3FFB,$3FF4,$3FEC,$3FE1,$3FD3,$3FC3
	dc.w	$3FB1,$3F9C,$3F84,$3F6A,$3F4E,$3F2F,$3F0E,$3EEB
	dc.w	$3EC5,$3E9C,$3E71,$3E44,$3E15,$3DE2,$3DAE,$3D77
	dc.w	$3D3E,$3D02,$3CC5,$3C84,$3C42,$3BFD,$3BB6,$3B6C
	dc.w	$3B20,$3AD2,$3A82,$3A2F,$39DB,$3983,$392A,$38CF
	dc.w	$3871,$3811,$37AF,$374B,$36E5,$367C,$3612,$35A5
	dc.w	$3536,$34C6,$3453,$33DE,$3367,$32EF,$3274,$31F7
	dc.w	$3179,$30F8,$3076,$2FF2,$2F6B,$2EE3,$2E5A,$2DCE
	dc.w	$2D41,$2CB2,$2C21,$2B8F,$2AFB,$2A65,$29CD,$2934
	dc.w	$289A,$27FD,$2760,$26C0,$2620,$257D,$24DA,$2435
	dc.w	$238E,$22E6,$223D,$2193,$20E7,$203A,$1F8B,$1EDC
	dc.w	$1E2B,$1D79,$1CC6,$1C12,$1B5D,$1AA7,$19EF,$1937
	dc.w	$187E,$17C4,$1708,$164C,$158F,$14D2,$1413,$1354
	dc.w	$1294,$11D3,$1112,$1050,$F8D,$ECA,$E06,$D41
	dc.w	$C7C,$BB7,$AF1,$A2B,$964,$89D,$7D6,$70E
	dc.w	$646,$57E,$4B5,$3ED,$324,$25B,$192,$C9
; sintab (512 valori anziche' 360)
	dc.w	0,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4B,$FA82
	dc.w	$F9BA,$F8F2,$F82A,$F763,$F69C,$F5D5,$F50F,$F449
	dc.w	$F384,$F2BF,$F1FA,$F136,$F073,$EFB0,$EEEE,$EE2D
	dc.w	$ED6C,$ECAC,$EBED,$EB2E,$EA70,$E9B4,$E8F8,$E83C
	dc.w	$E782,$E6C9,$E611,$E559,$E4A3,$E3EE,$E33A,$E287
	dc.w	$E1D5,$E124,$E074,$DFC6,$DF19,$DE6D,$DDC3,$DD19
	dc.w	$DC72,$DBCB,$DB26,$DA82,$D9E0,$D93F,$D8A0,$D802
	dc.w	$D766,$D6CC,$D632,$D59B,$D505,$D471,$D3DF,$D34E
	dc.w	$D2BF,$D232,$D1A6,$D11C,$D094,$D00E,$CF8A,$CF08
	dc.w	$CE87,$CE08,$CD8C,$CD11,$CC98,$CC21,$CBAD,$CB3A
	dc.w	$CAC9,$CA5A,$C9EE,$C983,$C91B,$C8B5,$C850,$C7EE
	dc.w	$C78F,$C731,$C6D5,$C67C,$C625,$C5D0,$C57D,$C52D
	dc.w	$C4DF,$C493,$C44A,$C402,$C3BE,$C37B,$C33B,$C2FD
	dc.w	$C2C1,$C288,$C251,$C21D,$C1EB,$C1BB,$C18E,$C163
	dc.w	$C13B,$C114,$C0F1,$C0D0,$C0B1,$C095,$C07B,$C063
	dc.w	$C04E,$C03C,$C02C,$C01E,$C013,$C00B,$C004,$C001
	dc.w	$C000,$C001,$C004,$C00B,$C013,$C01E,$C02C,$C03C
	dc.w	$C04E,$C063,$C07B,$C094,$C0B1,$C0CF,$C0F1,$C114
	dc.w	$C13A,$C163,$C18D,$C1BB,$C1EA,$C21C,$C251,$C287
	dc.w	$C2C1,$C2FC,$C33A,$C37A,$C3BD,$C402,$C449,$C492
	dc.w	$C4DE,$C52C,$C57D,$C5CF,$C624,$C67B,$C6D4,$C730
	dc.w	$C78E,$C7ED,$C84F,$C8B4,$C91A,$C982,$C9ED,$CA59
	dc.w	$CAC8,$CB39,$CBAB,$CC20,$CC97,$CD10,$CD8A,$CE07
	dc.w	$CE86,$CF06,$CF89,$D00D,$D093,$D11B,$D1A5,$D230
	dc.w	$D2BD,$D34C,$D3DD,$D470,$D504,$D599,$D631,$D6CA
	dc.w	$D765,$D801,$D89E,$D93E,$D9DE,$DA81,$DB24,$DBC9
	dc.w	$DC70,$DD18,$DDC1,$DE6B,$DF17,$DFC4,$E073,$E122
	dc.w	$E1D3,$E285,$E338,$E3EC,$E4A1,$E557,$E60F,$E6C7
	dc.w	$E780,$E83B,$E8F6,$E9B2,$EA6F,$EB2C,$EBEB,$ECAA
	dc.w	$ED6A,$EE2B,$EEEC,$EFAE,$F071,$F134,$F1F8,$F2BD
	dc.w	$F382,$F447,$F50D,$F5D3,$F69A,$F761,$F828,$F8F0
	dc.w	$F9B8,$FA80,$FB49,$FC11,$FCDA,$FDA3,$FE6C,$FF35
	dc.w	$FFFE,$C7,$190,$259,$322,$3EB,$4B3,$57C
	dc.w	$644,$70C,$7D3,$89B,$962,$A29,$AEF,$BB5
	dc.w	$C7A,$D3F,$E04,$EC8,$F8B,$104E,$1110,$11D1
	dc.w	$1292,$1352,$1411,$14D0,$158E,$164A,$1706,$17C2
	dc.w	$187C,$1935,$19ED,$1AA5,$1B5B,$1C10,$1CC4,$1D77
	dc.w	$1E29,$1EDA,$1F8A,$2038,$20E5,$2191,$223B,$22E5
	dc.w	$238D,$2433,$24D8,$257C,$261E,$26BF,$275E,$27FC
	dc.w	$2898,$2933,$29CC,$2A63,$2AF9,$2B8D,$2C20,$2CB0
	dc.w	$2D3F,$2DCD,$2E58,$2EE2,$2F6A,$2FF0,$3074,$30F7
	dc.w	$3177,$31F6,$3273,$32ED,$3366,$33DD,$3452,$34C5
	dc.w	$3535,$35A4,$3611,$367B,$36E4,$374A,$37AE,$3810
	dc.w	$3870,$38CE,$3929,$3983,$39DA,$3A2F,$3A81,$3AD1
	dc.w	$3B20,$3B6B,$3BB5,$3BFC,$3C41,$3C84,$3CC4,$3D02
	dc.w	$3D3D,$3D77,$3DAD,$3DE2,$3E14,$3E44,$3E71,$3E9C
	dc.w	$3EC4,$3EEA,$3F0E,$3F2F,$3F4E,$3F6A,$3F84,$3F9B
	dc.w	$3FB0,$3FC3,$3FD3,$3FE1,$3FEC,$3FF4,$3FFB,$3FFE
	dc.w	$4000,$3FFE,$3FFB,$3FF4,$3FEC,$3FE1,$3FD3,$3FC3
	dc.w	$3FB1,$3F9C,$3F85,$3F6B,$3F4E,$3F30,$3F0F,$3EEB
	dc.w	$3EC5,$3E9D,$3E72,$3E45,$3E15,$3DE3,$3DAF,$3D78
	dc.w	$3D3F,$3D03,$3CC5,$3C85,$3C42,$3BFE,$3BB6,$3B6D
	dc.w	$3B21,$3AD3,$3A83,$3A30,$39DB,$3984,$392B,$38D0
	dc.w	$3872,$3812,$37B0,$374C,$36E6,$367D,$3613,$35A6
	dc.w	$3538,$34C7,$3454,$33DF,$3369,$32F0,$3275,$31F9
	dc.w	$317A,$30F9,$3077,$2FF3,$2F6D,$2EE5,$2E5B,$2DD0
	dc.w	$2D42,$2CB3,$2C23,$2B90,$2AFC,$2A66,$29CF,$2936
	dc.w	$289B,$27FF,$2761,$26C2,$2621,$257F,$24DC,$2436
	dc.w	$2390,$22E8,$223F,$2194,$20E9,$203C,$1F8D,$1EDE
	dc.w	$1E2D,$1D7B,$1CC8,$1C14,$1B5F,$1AA9,$19F1,$1939
	dc.w	$1880,$17C5,$170A,$164E,$1591,$14D4,$1415,$1356
	dc.w	$1296,$11D5,$1114,$1052,$F8F,$ECC,$E08,$D43
	dc.w	$C7E,$BB9,$AF3,$A2D,$966,$89F,$7D8,$710
	dc.w	$648,$580,$4B7,$3EF,$326,$25D,$194,$CB


	SECTION	dati,BSS

d3_TransData:			; buffer un po a caso eh!
	ds.b	24000


	SECTION	GRAPH,DATA_C

copper2:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; bpl1mod
	dc.w	$10A,0		; bpl2mod

	dc.w	$100,BPLC0	; BplCon0

	dc.w	$E0
PLANEPOINTCOP2:
	dc.w	0
	dc.w	$E2,0
	dc.w	$180,$002	; color0
	dc.w	$182,$0Fa	; color1
	dc.w	$FFFF,$FFFE


	SECTION	Objectaaa,BSS_C

	ds.b	60
Double1:
	ds.b	scr_size	; larghezza 416
	ds.b	60
Double2:
	ds.b	scr_size
	ds.b	60
	end

(altezza 287 linee overscannate.. mah...)
