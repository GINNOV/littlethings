****************************************************************************
; Basato sul Vector Object Editor by BTG of PSI 1993
;
; Addictional coding by Randy of NA^CMX (ora RAM JAM)
****************************************************************************

; Precalcolare anche plasma o copeffect SOTTO, (plane in comun, $8a)ed e'fatta!
; (scritta autoscrivente 8x8 all'inizio per precalculing)...
; in fondo giusto scritta 8*8 e sfumaturina copper...

; merd velocita': se fast ram, allora altra figura vah!
; o, infine, fare come quella intro che precalcola tra un oggetto e l'altro,
; facendo il fade vah tra uno e l'altro... (fade precalcolade del colore..!

; sistema: punti a se e linee a se.
; tabella standard variata |512 anziche' 360 valori per 360 gradi...
; tanto dividere l'angolo giro in 360 e' una convenzione stupida...

	SECTION	BAUBAU,CODE

*****************************************************************************
	include	"assembler2:sorgenti4/startup1.s" ; Salva Copperlist Etc.
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

Start:
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
	LEA	PLANEPOINTCOP2,A0
	TST.W	switch
	BEQ.S	Scambia2x
	LEA	POINTER1(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
	bra.s	cambiatox
Scambia2x:
	LEA	POINTER2(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
cambiatox:

	LEA	$DFF000,A5	; (DO NOT USE A CMPI.B #$F8,$DFF07C!)
	MOVE.W	$7C(A5),D0	; DeniseID or LisaID in AGA
	MOVEQ	#60,D2		; Check 60 times ( prevents old denise random)
	ANDI.W	#%000000011111111,d0	; low byte only
DENLOOP:
	BCLR	#7,d3		; Just to steal time
	MOVE.W	$7C(A5),D1	; Denise ID (LisaID on AGA)
	ANDI.W	#%000000011111111,d1	; low byte only
	CMP.B	d0,d1		; same value?
	BNE.S	NOTAGA		; Not the same value, then OCS Denise!
	DBRA	D2,DENLOOP
	ORI.B	#%11110000,D0	; MASK AGA REVISION (will work on new aga)
	CMPI.B	#%11111000,D0	; BIT 2 LOW=AGA (this bit will be=0 in AAA!)
	BNE.S	NOTAGA		; IS THE AGA CHIPSET PRESENT?
	MOVE.W	#3,FETCH+2	; sistema la copperlist per l'AGA...
	subQ.W	#8,MOD0+2
	subQ.W	#8,MOD1+2
NOTAGA:				; NOT AGA, BUT IS POSSIBLE AN AAA MACHINE!!

	lea	loopo(PC),a0
	move.l	a0,d0
	and.l	#$FF000000,d0
	tst.l	d0
	beq.s	erano24bit	; vero, funzionante
	move.l	#3000,D3_Zoom	; molto vicino! 32bit fastram!
	bra.s	sono32bit
erano24bit:
	move.l	#4000,D3_Zoom	; lontano! no fastram!
sono32bit:

	bsr.w	precalcop

	LEA	$DFF002,A6		; save dma

pointcop2:
	BTST	#0,5-2(a6)	; aspetta linea 256
	BEQ.S	pointcop2
	MOVE.L	#copper2,$80-2(a6)	; point cop
	move.W	d0,$88-2(a6)
	move.w	#0,$1fc-2(a6)
		; 5432109876543210
	MOVE.W	#%1000001111000000,$96-2(a6)

FaiPrecalc:
	BSR.W	Viewer_Sphere	; 2 moltiplicazioni, 1 linea vah..
	BSR.W	D3_VIEW
	bsr.w	VECtabcontrol

	addq.w	#1,contasolido
	cmp.w	#$400,contasolido
	tst.b	cazfinito
	beq.s	FaiPrecalc

finprecalc:
	move.l	cazpoint(PC),cazpointrep

ANIMATE:
	move.L	#$1FF00,D1
	move.L	#$12c00,D2	; wait linea 301
waitbot:
	MOVE.L	4-2(a6),D0
	ANDI.L	D1,D0
	CMP.L	D2,D0
	BNE.S	waitbot

	BSR.W	CLEARSCREEN	; pulisci lo schermo che non si vede
				; 10240 bytes in 38 linee raster e swappa
				; gli schermi doublebuffer
				; NONCHE' SWAPPA LA COPPERLIST!

	move.w	#$f00,$180-2(a6)
	cmp.l	#3000,D3_Zoom
	bne.s	SchifoCHIP
	bsr.w	DrawBlitta	; fastram -> blitter+CPU!
	bra.s	fattomix
schifoCHIP:
	bsr.w	DRAWCHIPPY	; solo chipram -> solo blitter
fattomix:
	move.w	#$000,$180-2(a6)

	btst	#6,$bfe001
	BNE.S	ANIMATE

EXITPROG:
	BTST	#6,(a6)	; Wait blit
	BNE.S	EXITPROG
	RTS

contasolido:
	dc.w	0


XCOORD:
	dc.w	0
YCOORD:
	dc.w	0
YCOORD2:
	dc.w	0
EXITFLAG:
	dc.w	0

attualdraw:
	dc.l	Double1

; NOTA: non so bene perche', ma non si puo' cambiare contemporaneamente
; l'angolo Z e quello X, o succede casino

VECTabcontrol:
	movem.l	d0/a0-a1,-(SP)
	bsr.s	VfaiY	; Y YAngle - rotazione attorno asse verticale |
;	bsr.w	VfaiZ	; Z ZAngle
	bsr.w	VfaiX	; X Xangle - rotazione attono asse orizzontale --
;	bsr.w	VfaiZoom ; Allontanamento e avvicinamento del solido
	movem.l	(SP)+,d0/a0-a1
	rts

VFaiY:		; - a sinistra, + a destra...
	ADDQ.L	#2,VECTABYPOINT	 ; Fai puntare alla word successiva
	MOVE.L	VECTABYPOINT(PC),A0 ; indirizzo contenuto in long VECTABYPOINT
				 ; copiato in a0
	CMP.L	#FINEVECTABY-2,A0  ; Siamo all'ultima word della VECTAB?
	BNE.S	VNOBSTARTYs	; non ancora? allora continua
	MOVE.L	#VECTABY-2,VECTABYPOINT ; Riparti a puntare dalla prima word-2
	st	cazfinito
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

****************************************************************************
	dc.w	2,4,6,8,10,12,14,$10,$12,$14,$16,$18,$1A,$1C,$1E
	dc.w	$20,$22,$24,$26,$28,$2A,$2C,$2E,$30,$32,$34,$36
	dc.w	$38,$3A,$3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E
	dc.w	$50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62,$64,$66
	dc.w	$68,$6A,$6C,$6E,$70,$72,$74,$76,$78,$7A,$7C,$7E
	dc.w	$80,$82,$84,$86,$88,$8A,$8C,$8E,$90,$92,$94,$96
	dc.w	$98,$9A,$9C,$9E,$A0,$A2,$A4,$A6,$A8,$AA,$AC,$AE
	dc.w	$B0,$B2,$B4,$B6,$B8,$BA,$BC,$BE,$C0,$C2,$C4,$C6
	dc.w	$C8,$CA,$CC,$CE,$D0,$D2,$D4,$D6,$D8,$DA,$DC,$DE
	dc.w	$E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE,$F0,$F2,$F4,$F6
	dc.w	$F8,$FA,$FC,$FE,$100,$102,$104,$106,$108,$10A
	dc.w	$10C,$10E,$110,$112,$114,$116,$118,$11A,$11C,$11E
	dc.w	$120,$122,$124,$126,$128,$12A,$12C,$12E,$130,$132
	dc.w	$134,$136,$138,$13A,$13C,$13E,$140,$142,$144,$146
	dc.w	$148,$14A,$14C,$14E,$150,$152,$154,$156,$158,$15A
	dc.w	$15C,$15E,$160,$162,$164,$166,$168,$16A,$16C,$16E
	dc.w	$170,$172,$174,$176,$178,$17A,$17C,$17E,$180,$182
	dc.w	$184,$186,$188,$18A,$18C,$18E,$190,$192,$194,$196
	dc.w	$198,$19A,$19C,$19E,$1A0,$1A2,$1A4,$1A6,$1A8,$1AA
	dc.w	$1AC,$1AE,$1B0,$1B2,$1B4,$1B6,$1B8,$1BA,$1BC,$1BE
	dc.w	$1C0,$1C2,$1C4,$1C6,$1C8,$1CA,$1CC,$1CE,$1D0,$1D2
	dc.w	$1D4,$1D6,$1D8,$1DA,$1DC,$1DE,$1E0,$1E2,$1E4,$1E6
	dc.w	$1E8,$1EA,$1EC,$1EE,$1F0,$1F2,$1F4,$1F6,$1F8,$1FA
	dc.w	$1FC,$1FE,$200

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

	dc.w	2,4,6,8,10,12,14,$10,$12,$14,$16,$18,$1A,$1C,$1E
	dc.w	$20,$22,$24,$26,$28,$2A,$2C,$2E,$30,$32,$34,$36
	dc.w	$38,$3A,$3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E
	dc.w	$50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62,$64,$66
	dc.w	$68,$6A,$6C,$6E,$70,$72,$74,$76,$78,$7A,$7C,$7E
	dc.w	$80,$82,$84,$86,$88,$8A,$8C,$8E,$90,$92,$94,$96
	dc.w	$98,$9A,$9C,$9E,$A0,$A2,$A4,$A6,$A8,$AA,$AC,$AE
	dc.w	$B0,$B2,$B4,$B6,$B8,$BA,$BC,$BE,$C0,$C2,$C4,$C6
	dc.w	$C8,$CA,$CC,$CE,$D0,$D2,$D4,$D6,$D8,$DA,$DC,$DE
	dc.w	$E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE,$F0,$F2,$F4,$F6
	dc.w	$F8,$FA,$FC,$FE,$100,$102,$104,$106,$108,$10A
	dc.w	$10C,$10E,$110,$112,$114,$116,$118,$11A,$11C,$11E
	dc.w	$120,$122,$124,$126,$128,$12A,$12C,$12E,$130,$132
	dc.w	$134,$136,$138,$13A,$13C,$13E,$140,$142,$144,$146
	dc.w	$148,$14A,$14C,$14E,$150,$152,$154,$156,$158,$15A
	dc.w	$15C,$15E,$160,$162,$164,$166,$168,$16A,$16C,$16E
	dc.w	$170,$172,$174,$176,$178,$17A,$17C,$17E,$180,$182
	dc.w	$184,$186,$188,$18A,$18C,$18E,$190,$192,$194,$196
	dc.w	$198,$19A,$19C,$19E,$1A0,$1A2,$1A4,$1A6,$1A8,$1AA
	dc.w	$1AC,$1AE,$1B0,$1B2,$1B4,$1B6,$1B8,$1BA,$1BC,$1BE
	dc.w	$1C0,$1C2,$1C4,$1C6,$1C8,$1CA,$1CC,$1CE,$1D0,$1D2
	dc.w	$1D4,$1D6,$1D8,$1DA,$1DC,$1DE,$1E0,$1E2,$1E4,$1E6
	dc.w	$1E8,$1EA,$1EC,$1EE,$1F0,$1F2,$1F4,$1F6,$1F8,$1FA
	dc.w	$1FC,$1FE,$200
;	incbin	"ram:b"
FINEVECTABX:

;	incbin	"XCOORDINAT.VECTAB"	; .w
;FINEVECTABX:



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
;	incbin	"ZCOORDINAT.VECTAB"	; .w
FINEVECTABZ:



;*************************
;* LR by BTG on 17.03.91 *
;*************************
; bsr Viewer_Sphere to get in orbit around object
; bsr D3_View to plot calculated object in 3D-Wire
; See Obj_Data how an object is structered

;*** Viewer on orbit by YAngle,Xangle,ZAngle

Viewer_Sphere:
	move.w	YAngle(pc),d0
	move.w	Xangle(pc),d1
	lea	cos(pc),a0	; costab -> a0
	lea	256(a0),a1	; sintab -> a1
	lea	xvie(pc),a2
	move.w	0(a1,d0.w*2),d3	; Sin YAngle	; 68020+
	move.w	0(a1,d1.w*2),d5	; Sin Xangle	; 68020+
	move.w	0(a0,d0.w*2),d2	; Cos YAngle	; 68020+
	move.w	0(a0,d1.w*2),d4	; Cos Xangle	; 68020+

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
	dc.l	3000	;$7D0*2

D3_VIEW:
	bsr.w	TD_Transform	; init Matrix (3 linee raster, ma 16 moltiplic.
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
	BSR.W	td_make3dpoint	; 2 linee rast
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
	BSR.w	td_make3dpoint	; 2 linee ogni PUNTO! merda...

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
;	move.w	#%1111111111111111,a2	; pattern per la linea - normale
	move.w	(a5)+,d4
	cmp.w	#$ffff,d4	; flag di fine??
	beq.s	D3_END
	move.w	(a4,d4.w*4),d0
	move.w	2(a4,d4.w*4),d1
	add.w	(a3),d0		; x0
	add.w	2(a3),d1	; y0
	move.w	(a5)+,d4
	move.w	(a4,d4.w*4),d2
	move.w	2(a4,d4.w*4),d3
	add.w	(a3),d2		; x1
	add.w	2(a3),d3	; y1

	bsr.w	DrawlinePREC	; input: a2.w = pattern della linea
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
casinato:
	DC.L	casinato_POINTS
	DC.L	casinato_LINES
	DC.L	0
casinato_POINTS:
	DC.W	-0980, 0440, 0000,-0780, 0190, 0000
	DC.W	-0760, 0550, 0000,-1140, 0450, 0000
	DC.W	-0860, 0270, 0000,-0760, 0460, 0000
	DC.W	-1180, 0650, 0000, 0820,-0900, 0000
	DC.W	 1140,-0590, 0000, 0700,-0750, 0000
	DC.W	 0780,-0850, 0000,-0750,-0750, 0000
	DC.W	-1360,-0830, 0000, 0330, 0530, 0000
	DC.W	 0940, 0410, 0000, 0710, 0830, 0000
	DC.W	-0180, 0260, 0000, 0150, 1070, 0000
	DC.W	-0100,-0290, 0000,-0330,-0310, 0000
	DC.W	-0220,-0790, 0000,-0210,-0300, 0000
	DC.W	-0200,-0190, 0000,-0980, 0350,-0260
	DC.W	-0780, 0150,-0120,-0760, 0440,-0330
	DC.W	-1140, 0360,-0270,-0860, 0210,-0160
	DC.W	-0760, 0370,-0270,-1180, 0520,-0390
	DC.W	 0820,-0730, 0520, 1140,-0480, 0340
	DC.W	 0700,-0610, 0430, 0780,-0690, 0490
	DC.W	-0750,-0610, 0430,-1360,-0680, 0480
	DC.W	 0330, 0420,-0320, 0940, 0330,-0250
	DC.W	 0710, 0670,-0490,-0180, 0210,-0160
	DC.W	 0150, 0860,-0630,-0100,-0240, 0160
	DC.W	-0330,-0260, 0180,-0220,-0650, 0460
	DC.W	-0210,-0250, 0170,-0200,-0160, 0110
	DC.W	-0980, 0130,-0420,-0780, 0050,-0190
	DC.W	-0760, 0170,-0530,-1140, 0140,-0430
	DC.W	-0860, 0080,-0260,-0760, 0140,-0440
	DC.W	-1180, 0200,-0620, 0820,-0290, 0850
	DC.W	 1140,-0190, 0560, 0700,-0240, 0710
	DC.W	 0780,-0270, 0800,-0750,-0240, 0710
	DC.W	-1360,-0270, 0780, 0330, 0160,-0510
	DC.W	 0940, 0120,-0390, 0710, 0260,-0790
	DC.W	-0180, 0080,-0250, 0150, 0330,-1020
	DC.W	-0100,-0100, 0270,-0330,-0100, 0290
	DC.W	-0220,-0250, 0750,-0210,-0100, 0280
	DC.W	-0200,-0060, 0180,-0980,-0140,-0420
	DC.W	-0780,-0060,-0190,-0760,-0170,-0530
	DC.W	-1140,-0140,-0430,-0860,-0090,-0260
	DC.W	-0760,-0140,-0440,-1180,-0200,-0620
	DC.W	 0820, 0270, 0850, 1140, 0170, 0560
	DC.W	 0700, 0220, 0710, 0780, 0250, 0810
	DC.W	-0750, 0220, 0710,-1360, 0250, 0790
	DC.W	 0330,-0170,-0510, 0940,-0130,-0400
	DC.W	 0710,-0260,-0800,-0180,-0080,-0250
	DC.W	 0150,-0330,-1030,-0100, 0080, 0270
	DC.W	-0330, 0090, 0290,-0220, 0230, 0750
	DC.W	-0210, 0090, 0280,-0200, 0050, 0180
	DC.W	-0980,-0360,-0270,-0780,-0160,-0120
	DC.W	-0760,-0450,-0330,-1140,-0370,-0270
	DC.W	-0860,-0220,-0170,-0760,-0370,-0280
	DC.W	-1180,-0530,-0390, 0820, 0720, 0530
	DC.W	 1140, 0470, 0350, 0700, 0600, 0440
	DC.W	 0780, 0680, 0500,-0750, 0600, 0440
	DC.W	-1360, 0660, 0490, 0330,-0430,-0320
	DC.W	 0940,-0330,-0250, 0710,-0670,-0500
	DC.W	-0180,-0210,-0160, 0150,-0860,-0640
	DC.W	-0100, 0230, 0170,-0330, 0240, 0180
	DC.W	-0220, 0630, 0470,-0210, 0240, 0170
	DC.W	-0200, 0150, 0110,-0980,-0440,-0010
	DC.W	-0780,-0190,-0010,-0760,-0550,-0010
	DC.W	-1140,-0450,-0010,-0860,-0270,-0010
	DC.W	-0760,-0460,-0010,-1180,-0650,-0010
	DC.W	 0820, 0890, 0010, 1140, 0580, 0000
	DC.W	 0700, 0740, 0000, 0780, 0840, 0010
	DC.W	-0750, 0740, 0000,-1360, 0820, 0010
	DC.W	 0330,-0530,-0010, 0940,-0410,-0010
	DC.W	 0710,-0830,-0020,-0180,-0260,-0010
	DC.W	 0150,-1070,-0020,-0100, 0280, 0000
	DC.W	-0330, 0300, 0000,-0220, 0780, 0000
	DC.W	-0210, 0290, 0000,-0200, 0180, 0000
	DC.W	-0980,-0360, 0250,-0780,-0160, 0100
	DC.W	-0760,-0450, 0310,-1140,-0370, 0250
	DC.W	-0860,-0230, 0150,-0760,-0380, 0260
	DC.W	-1180,-0540, 0370, 0820, 0730,-0520
	DC.W	 1140, 0480,-0340, 0700, 0610,-0440
	DC.W	 0780, 0690,-0490,-0750, 0610,-0440
	DC.W	-1360, 0670,-0480, 0330,-0440, 0300
	DC.W	 0940,-0340, 0230, 0710,-0680, 0470
	DC.W	-0180,-0220, 0140, 0150,-0880, 0610
	DC.W	-0100, 0230,-0170,-0330, 0250,-0180
	DC.W	-0220, 0640,-0460,-0210, 0240,-0180
	DC.W	-0200, 0150,-0110,-0980,-0150, 0410
	DC.W	-0780,-0070, 0170,-0760,-0180, 0520
	DC.W	-1140,-0150, 0420,-0860,-0090, 0250
	DC.W	-0760,-0150, 0430,-1180,-0220, 0610
	DC.W	 0820, 0290,-0860, 1140, 0190,-0560
	DC.W	 0700, 0240,-0710, 0780, 0270,-0810
	DC.W	-0750, 0240,-0710,-1360, 0270,-0790
	DC.W	 0330,-0180, 0500, 0940,-0140, 0380
	DC.W	 0710,-0280, 0780,-0180,-0090, 0240
	DC.W	 0150,-0350, 1010,-0100, 0090,-0280
	DC.W	-0330, 0100,-0300,-0220, 0250,-0750
	DC.W	-0210, 0090,-0290,-0200, 0060,-0180
	DC.W	-0980, 0120, 0420,-0780, 0050, 0180
	DC.W	-0760, 0150, 0520,-1140, 0130, 0430
	DC.W	-0860, 0070, 0250,-0760, 0130, 0440
	DC.W	-1180, 0180, 0620, 0820,-0270,-0870
	DC.W	 1140,-0180,-0570, 0700,-0220,-0720
	DC.W	 0780,-0250,-0820,-0750,-0220,-0720
	DC.W	-1360,-0250,-0800, 0330, 0150, 0500
	DC.W	 0940, 0110, 0390, 0710, 0240, 0790
	DC.W	-0180, 0070, 0240, 0150, 0310, 1020
	DC.W	-0100,-0090,-0280,-0330,-0090,-0300
	DC.W	-0220,-0230,-0760,-0210,-0090,-0290
	DC.W	-0200,-0060,-0190,-0980, 0350, 0260
	DC.W	-0780, 0150, 0110,-0760, 0430, 0330
	DC.W	-1140, 0350, 0270,-0860, 0210, 0160
	DC.W	-0760, 0360, 0270,-1180, 0510, 0390
	DC.W	 0820,-0720,-0550, 1140,-0470,-0360
	DC.W	 0700,-0600,-0460, 0780,-0680,-0520
	DC.W	-0750,-0600,-0460,-1360,-0670,-0510
	DC.W	 0330, 0420, 0320, 0940, 0320, 0240
	DC.W	 0710, 0660, 0500,-0180, 0200, 0150
	DC.W	 0150, 0850, 0640,-0100,-0240,-0180
	DC.W	-0330,-0250,-0190,-0220,-0630,-0480
	DC.W	-0210,-0240,-0190,-0200,-0160,-0120
	DC.W	-0650,-1050, 0000,-0550,-0920, 0000
	DC.W	-0470,-1160, 0000, 1310, 0910, 1110
	DC.W	 1340, 0910, 0810, 1410, 0910, 0950
	DC.W	 1170, 0910,-0970, 1290, 0910,-1130
	DC.W	 1290, 0910,-0990, 1170, 0910,-0960
	DC.W	-0150,-1170,-0330,-0150,-1050,-0590
	DC.W	-0150,-1020,-0390,-0150,-1170,-0350
	DC.W	-0630, 0570, 0180,-0560, 0840, 0180
	DC.W	-0480, 0610, 0180,-0640, 0560, 0180
	DC.W	 0680,-1050, 0180, 0710,-0970, 0180
	DC.W	 0890,-1000, 0180, 0680,-1070, 0180
	DC.W	 0190,-1040, 0230, 0360,-1040,-0010
	DC.W	 0390,-1040, 0120, 0210,-1040, 0220
	DC.W	-1350,-1040,-0990,-1200,-1040,-1160
	DC.W	-1110,-1040,-1040,-1330,-1040,-1010
	DC.W	-1340,-1420, 0830,-1340,-1310, 0590
	DC.W	-1340,-1270, 0740,-1340,-1390, 0800
	DC.W	-0350, 0990, 0800,-0140, 0790, 0800
	DC.W	-0160, 0900, 0800,-0360, 0980, 0800
	DC.W	-0310, 0980, 0960,-0140, 0980, 0790
	DC.W	 1300, 0980,-0480, 1340, 0980,-0520
	DC.W	 1520, 0980,-0530, 1310, 0980,-0440
	DC.W	 1320, 0980,-0430,-0590, 0980,-0190
	DC.W	-0510, 0980,-0360,-0480, 0980,-0210
	DC.W	-0590, 0980,-0210,-0580, 0930,-0700
	DC.W	-0580, 1080,-0880,-0580, 1180,-0650
	DC.W	-0580, 0880,-0720,-0580,-1060, 0950
	DC.W	-0580,-0920, 0760,-0580,-0920, 0940
	DC.W	-0580,-1060, 0930,-0650,-0080, 0570
	DC.W	-0520,-0290, 0570,-0500,-0030, 0570
	DC.W	-0630,-0080, 0570, 0320,-0080,-0900
	DC.W	 0540,-0080,-1020, 0430,-0080,-0840
	DC.W	-0230,-0780,-0940,-0230,-0660,-1150
	DC.W	-0230,-0630,-1020,-0230,-0760,-0980
	DC.W	 0290,-0840,-0100, 0380,-0780,-0100
	DC.W	 0430,-0900,-0100, 0280,-0830,-0100
	DC.W	 0280, 0980, 0950, 0410, 0980, 0740
	DC.W	 0420, 0980, 0930, 0290, 0980, 0940
	DC.W	-1
casinato_LINES:		; 820
	DC.W	 0000, 0001, 0001, 0002, 0002, 0003, 0003, 0004
	DC.W	 0004, 0005, 0005, 0006, 0007, 0008, 0008, 0009
	DC.W	 0009, 0010, 0011, 0012, 0013, 0014, 0015, 0016
	DC.W	 0016, 0017, 0018, 0019, 0019, 0020, 0020, 0021
	DC.W	 0021, 0022, 0023, 0024, 0024, 0025, 0025, 0026
	DC.W	 0026, 0027, 0027, 0028, 0028, 0029, 0030, 0031
	DC.W	 0031, 0032, 0032, 0033, 0034, 0035, 0036, 0037
	DC.W	 0038, 0039, 0039, 0040, 0041, 0042, 0042, 0043
	DC.W	 0043, 0044, 0044, 0045, 0046, 0047, 0047, 0048
	DC.W	 0048, 0049, 0049, 0050, 0050, 0051, 0051, 0052
	DC.W	 0053, 0054, 0054, 0055, 0055, 0056, 0057, 0058
	DC.W	 0059, 0060, 0061, 0062, 0062, 0063, 0064, 0065
	DC.W	 0065, 0066, 0066, 0067, 0067, 0068, 0069, 0070
	DC.W	 0070, 0071, 0071, 0072, 0072, 0073, 0073, 0074
	DC.W	 0074, 0075, 0076, 0077, 0077, 0078, 0078, 0079
	DC.W	 0080, 0081, 0082, 0083, 0084, 0085, 0085, 0086
	DC.W	 0087, 0088, 0088, 0089, 0089, 0090, 0090, 0091
	DC.W	 0092, 0093, 0093, 0094, 0094, 0095, 0095, 0096
	DC.W	 0096, 0097, 0097, 0098, 0099, 0100, 0100, 0101
	DC.W	 0101, 0102, 0103, 0104, 0105, 0106, 0107, 0108
	DC.W	 0108, 0109, 0110, 0111, 0111, 0112, 0112, 0113
	DC.W	 0113, 0114, 0115, 0116, 0116, 0117, 0117, 0118
	DC.W	 0118, 0119, 0119, 0120, 0120, 0121, 0122, 0123
	DC.W	 0123, 0124, 0124, 0125, 0126, 0127, 0128, 0129
	DC.W	 0130, 0131, 0131, 0132, 0133, 0134, 0134, 0135
	DC.W	 0135, 0136, 0136, 0137, 0138, 0139, 0139, 0140
	DC.W	 0140, 0141, 0141, 0142, 0142, 0143, 0143, 0144
	DC.W	 0145, 0146, 0146, 0147, 0147, 0148, 0149, 0150
	DC.W	 0151, 0152, 0153, 0154, 0154, 0155, 0156, 0157
	DC.W	 0157, 0158, 0158, 0159, 0159, 0160, 0161, 0162
	DC.W	 0162, 0163, 0163, 0164, 0164, 0165, 0165, 0166
	DC.W	 0166, 0167, 0168, 0169, 0169, 0170, 0170, 0171
	DC.W	 0172, 0173, 0174, 0175, 0176, 0177, 0177, 0178
	DC.W	 0179, 0180, 0180, 0181, 0181, 0182, 0182, 0183
	DC.W	 0184, 0185, 0185, 0186, 0186, 0187, 0187, 0188
	DC.W	 0188, 0189, 0189, 0190, 0191, 0192, 0192, 0193
	DC.W	 0193, 0194, 0195, 0196, 0197, 0198, 0199, 0200
	DC.W	 0200, 0201, 0202, 0203, 0203, 0204, 0204, 0205
	DC.W	 0205, 0206, 0207, 0208, 0208, 0209, 0209, 0210
	DC.W	 0210, 0211, 0211, 0212, 0212, 0213, 0214, 0215
	DC.W	 0215, 0216, 0216, 0217, 0218, 0219, 0220, 0221
	DC.W	 0222, 0223, 0223, 0224, 0225, 0226, 0226, 0227
	DC.W	 0227, 0228, 0228, 0229, 0000, 0023, 0023, 0046
	DC.W	 0046, 0069, 0069, 0092, 0092, 0115, 0115, 0138
	DC.W	 0138, 0161, 0161, 0184, 0184, 0207, 0207, 0000
	DC.W	 0001, 0024, 0024, 0047, 0047, 0070, 0070, 0093
	DC.W	 0093, 0116, 0116, 0139, 0139, 0162, 0162, 0185
	DC.W	 0185, 0208, 0208, 0001, 0002, 0025, 0025, 0048
	DC.W	 0048, 0071, 0071, 0094, 0094, 0117, 0117, 0140
	DC.W	 0140, 0163, 0163, 0186, 0186, 0209, 0209, 0002
	DC.W	 0003, 0026, 0026, 0049, 0049, 0072, 0072, 0095
	DC.W	 0095, 0118, 0118, 0141, 0141, 0164, 0164, 0187
	DC.W	 0187, 0210, 0210, 0003, 0004, 0027, 0027, 0050
	DC.W	 0050, 0073, 0073, 0096, 0096, 0119, 0119, 0142
	DC.W	 0142, 0165, 0165, 0188, 0188, 0211, 0211, 0004
	DC.W	 0005, 0028, 0028, 0051, 0051, 0074, 0074, 0097
	DC.W	 0097, 0120, 0120, 0143, 0143, 0166, 0166, 0189
	DC.W	 0189, 0212, 0212, 0005, 0006, 0029, 0029, 0052
	DC.W	 0052, 0075, 0075, 0098, 0098, 0121, 0121, 0144
	DC.W	 0144, 0167, 0167, 0190, 0190, 0213, 0213, 0006
	DC.W	 0007, 0030, 0030, 0053, 0053, 0076, 0076, 0099
	DC.W	 0099, 0122, 0122, 0145, 0145, 0168, 0168, 0191
	DC.W	 0191, 0214, 0214, 0007, 0008, 0031, 0031, 0054
	DC.W	 0054, 0077, 0077, 0100, 0100, 0123, 0123, 0146
	DC.W	 0146, 0169, 0169, 0192, 0192, 0215, 0215, 0008
	DC.W	 0009, 0032, 0032, 0055, 0055, 0078, 0078, 0101
	DC.W	 0101, 0124, 0124, 0147, 0147, 0170, 0170, 0193
	DC.W	 0193, 0216, 0216, 0009, 0010, 0033, 0033, 0056
	DC.W	 0056, 0079, 0079, 0102, 0102, 0125, 0125, 0148
	DC.W	 0148, 0171, 0171, 0194, 0194, 0217, 0217, 0010
	DC.W	 0011, 0034, 0034, 0057, 0057, 0080, 0080, 0103
	DC.W	 0103, 0126, 0126, 0149, 0149, 0172, 0172, 0195
	DC.W	 0195, 0218, 0218, 0011, 0012, 0035, 0035, 0058
	DC.W	 0058, 0081, 0081, 0104, 0104, 0127, 0127, 0150
	DC.W	 0150, 0173, 0173, 0196, 0196, 0219, 0219, 0012
	DC.W	 0013, 0036, 0036, 0059, 0059, 0082, 0082, 0105
	DC.W	 0105, 0128, 0128, 0151, 0151, 0174, 0174, 0197
	DC.W	 0197, 0220, 0220, 0013, 0014, 0037, 0037, 0060
	DC.W	 0060, 0083, 0083, 0106, 0106, 0129, 0129, 0152
	DC.W	 0152, 0175, 0175, 0198, 0198, 0221, 0221, 0014
	DC.W	 0015, 0038, 0038, 0061, 0061, 0084, 0084, 0107
	DC.W	 0107, 0130, 0130, 0153, 0153, 0176, 0176, 0199
	DC.W	 0199, 0222, 0222, 0015, 0016, 0039, 0039, 0062
	DC.W	 0062, 0085, 0085, 0108, 0108, 0131, 0131, 0154
	DC.W	 0154, 0177, 0177, 0200, 0200, 0223, 0223, 0016
	DC.W	 0017, 0040, 0040, 0063, 0063, 0086, 0086, 0109
	DC.W	 0109, 0132, 0132, 0155, 0155, 0178, 0178, 0201
	DC.W	 0201, 0224, 0224, 0017, 0230, 0231, 0231, 0232
	DC.W	 0232, 0230, 0233, 0234, 0234, 0235, 0235, 0233
	DC.W	 0236, 0237, 0237, 0238, 0238, 0239, 0240, 0241
	DC.W	 0241, 0242, 0242, 0243, 0244, 0245, 0245, 0246
	DC.W	 0246, 0247, 0248, 0249, 0249, 0250, 0250, 0251
	DC.W	 0252, 0253, 0253, 0254, 0254, 0255, 0256, 0257
	DC.W	 0257, 0258, 0258, 0259, 0260, 0261, 0261, 0262
	DC.W	 0262, 0263, 0264, 0265, 0265, 0266, 0266, 0267
	DC.W	 0267, 0268, 0268, 0269, 0270, 0271, 0271, 0272
	DC.W	 0272, 0273, 0273, 0274, 0275, 0276, 0276, 0277
	DC.W	 0277, 0278, 0279, 0280, 0280, 0281, 0281, 0282
	DC.W	 0283, 0284, 0284, 0285, 0285, 0286, 0287, 0288
	DC.W	 0288, 0289, 0289, 0290, 0291, 0292, 0292, 0293
	DC.W	 0293, 0291, 0294, 0295, 0295, 0296, 0296, 0297
	DC.W	 0298, 0299, 0299, 0300, 0300, 0301, 0302, 0303
	DC.W	 0303, 0304, 0304, 0305
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
	lea	cos(pc),a1 	; indririzzo COS
	lea	256(a1),a0	; sin=cos+90 - indirizzo SIN
	move.w	0(a0,d0.w*2),a2	; trova sin angolo X
	move.w	0(a0,d1.w*2),a3	; trova sin angolo Y
	move.w	0(a0,d2.w*2),a4	; trova sin angolo Z
	lea	SinX(pc),a5
	move.w	a2,(a5)		; salva SinX
	move.w	a3,2(a5)	; salva SinY
	move.w	a4,4(a5)	; salva SinZ
	movea.w	0(a1,d0.w*2),a2	; a2 = CosX
	movea.w	0(a1,d1.w*2),a3	; a3 = CosY
	movea.w	0(a1,d2.w*2),a4	; a4 = CosZ
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
;	 d0.w = x0
;	 d1.w = y0
;	 d2.w = x1
;	 d3.w = y1
;	 d4.w = bytes per linea di schermo
;	 a6.l = $dff000!!!
;
; la linea e' (x0,y0)-(x1,y1) = (d0,d1)-(d2,d3)

DrawLinePREC:
	MOVEM.L	D4-D7/A0-A6,-(SP)
	BSR.W	SchifoClippa	  ; aggiusta le coord se sono fuori schermo
	MOVEM.L	(SP)+,D4-D7/A0-A6
	CMP.W	D0,D2		; x0 = x1? bah...
	BNE.s	DrawBlittaPREC
	CMP.W	D1,D3		; anche y0 = y1? se si esci senza disegnare!!
	BNE.s	DrawBlittaPREC

	moveq	#-1,d0	; flag del caz
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3

	move.l	cazpoint(PC),a0
	movem.w	d0-d3,-(a0)	; 16 bytes * 820 linee * n.fotogrammi 640
	move.l	a0,cazpoint
	RTS


DrawBlittaPREC:
	move.l	cazpoint(PC),a0
	movem.w	d0-d3,-(a0)	; 16 bytes * 820 linee * n.fotogrammi 640
	move.l	a0,cazpoint
	rts

******************************************************************************
; Routine di DRAW delle linee per sola CHIPRAM -> blitter solo!

DRAWCHIPPY:
	move.l	cazpoint(PC),a3
	cmp.l	#cazzdatiend,a3
	bne.s	NoRipartizC
	move.l	cazpointrep(PC),cazpoint
NoRipartizC:

	btst	#2,$16-2(a6)
	beq.s	dueC
		; 5432109876543210	; magari secondo equalizzatore!
	move.w	#%1111111111111111,a2	; pattern per la linea - normale
	bra.s	treC
dueC:
	move.w	#%1010101010101010,a2	; pattern per la linea - a pua'
treC:

	move.w	#250-1,d7	; 410/2 linee - per slow ram
	add.l	#(410-250)*8,cazpoint	; prendi nuove 4 coordinate

	MOVE.W	#$8000,$74-2(a6)	; BLTADAT
	MOVE.W	A2,$72-2(a6)	; BLTBDAT - Pattern della linea
	MOVE.W	#$FFFF,$44-2(a6)
	moveq	#40,d0	; bytes per linea
	MOVE.W	d0,$60-2(a6)	; BLTCMOD - bytes per linea (larghezza/8)
	MOVE.W	d0,$66-2(a6)	; BLTDMOD - bytes per linea

; ******************+ LOOP MEGAVELOCE DI DRAW DELLE LINEE *****************

;	d0,d1,d2,d3 = coordinate
;	d7 = conteggio loop!
;	d4 = usato variabile
;	d5 = usato variabile
;	d6 = MINTERMS

;	a0 ind dove tracciare
;	a1 = $dff062
;	a2 = $dff052 bltapt
;	a3 = cazpoint!!!
;	a4 = tabba..
;	a5 = $dff058
;	a6 = $dff002

	move.l	cazpoint(PC),a3		; posizione attuale di cazpoint
	move.l	attualdraw(PC),a0	; ind. dove tracciare
	lea	tabba(PC),a4
	lea	$52-2(a6),a2	; BLTAPT - 2y-x
	lea	$62-2(a6),a1
	lea	$58-2(a6),a5	; bltsize in a5
	move.w	#$BCA,d6	; USEA,C,D acesi e minterms $CA per linea

loopoC:
	; sta anche nella cache!
	movem.w	(a3)+,d0-d3		; prendi nuove 4 coordinate

	cmp.w	#-1,d0	; coordinata a vuoto?
	beq.s	saltC	; se si salta!

	moveq	#0,d4
	move.w	0(a4,d1.w*2),d4	; 68020+

	MOVEQ	#-16,D5	; $FFFFFFF0
	AND.W	D0,D5	; escludi i 4 bit bassi di x0
	LSR.W	#3,D5	; dividi per 8, trovando l'offset orizzontale
	ADD.W	D5,D4	; d4 = start address come offset dall'inizio schermo
	ADD.L	A0,D4	; aggiungi indirizzo schermo: d4 = start address FINALE

	MOVEQ	#0,D5
	SUB.W	D1,D3	; y0-y1
	ROXL.B	#1,D5
	TST.W	D3	; y1
	BGE.S	OctSelez1C
	NEG.W	D3	; y1
OctSelez1C:
	SUB.W	D0,D2	; x0-x1
	ROXL.B	#1,D5
	TST.W	D2	; x1
	BGE.S	OctSelez2C
	NEG.W	D2	; x1
OctSelez2C:
	MOVE.W	D3,D1	; y1 in d1
	SUB.W	D2,D1	; 
	BGE.S	OctSelez3C
	EXG	D2,D3
OctSelez3C:
	ROXL.B	#1,D5
	MOVE.B	TabOttantiC(PC,D5.L),D5
	ADD.W	D2,D2	; d2*2
	moveq	#6,d1
WaitBlittC:
	BTST.b	d1,(a6)	; aspetta la fine del lavoro del blitter
	BNE.S	WaitBlittC

	MOVE.W	D2,(a1)		; BLTBMOD - 4y dff062
	SUB.W	D3,D2
	BGE.S	BlizuC
	ORI.B	#$40,D5		; setta il bit 6 di BPLCON1 - SIGN = -
BlizuC:
	MOVE.W	D2,(a2)	; BLTAPT - 2y-x
	SUB.W	D3,D2
	MOVE.W	D2,$64-2(a6)	; BLTAMOD
	ANDI.W	#%1111,D0	; seleziona i 4 bit bassi di x0
	ROR.W	#4,D0		; shiftali a destra per BLTCON0
	OR.W	d6,D0		; Aggiungi MINTERMS e USE A,C,D
	MOVE.W	D0,$40-2(a6)	; BLTCON0 -
	MOVE.W	D5,$42-2(a6)	; BLTCON1 -
	MOVE.L	D4,$48-2(a6)	; BLTCPT -
	MOVE.L	D4,$54-2(a6)	; BLTDPT - indirizzo di partenza della linea
	LSL.W	d1,D3
	ADDQ.W	#2,D3
	MOVE.W	D3,(a5)		; BLTSIZE
saltC:
	dbra	d7,loopoC
fineloopoC:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

;	Tabella con i valori per gli ottanti

TabOttantiC:
	dc.b	1
	dc.b	$11
	dc.b	9
	dc.b	$15
	dc.b	5
	dc.b	$19
	dc.b	13
	dc.b	$1D

*****************************************************************************

; come "tabellarsi" la prima moltiplicazione, se d4 e' sempre 40 e d1 puo'
; andare da 0 a $ff (dato che e' la posizione y).
;
;	lea	tabba(PC),a0
;	moveq	#0,d1
;	moveq	#40,d4
;FaiTab:
;	MULU.W	D1,D4	; d4 = bytes per linea*y0-trova l'offset verticale
;	move.w	d4,(a0)+
;	addq.w	#1,d1
;	moveq	#40,d4	
;	cmp.w	#$101,d1
;	bne.s	FaiTab
;	rts
;
;tabba:
;	ds.w	256
;finetabba:


;Minterms:		; USEA,C,D acesi e minterms $CA per linea
;	dc.w	$BCA

tabba:
	dc.w	0,$28,$50,$78,$A0,$C8,$F0,$118,$140,$168,$190
	dc.w	$1B8,$1E0,$208,$230,$258,$280,$2A8,$2D0,$2F8,$320
	dc.w	$348,$370,$398,$3C0,$3E8,$410,$438,$460,$488,$4B0
	dc.w	$4D8,$500,$528,$550,$578,$5A0,$5C8,$5F0,$618,$640
	dc.w	$668,$690,$6B8,$6E0,$708,$730,$758,$780,$7A8,$7D0
	dc.w	$7F8,$820,$848,$870,$898,$8C0,$8E8,$910,$938,$960
	dc.w	$988,$9B0,$9D8,$A00,$A28,$A50,$A78,$AA0,$AC8,$AF0
	dc.w	$B18,$B40,$B68,$B90,$BB8,$BE0,$C08,$C30,$C58,$C80
	dc.w	$CA8,$CD0,$CF8,$D20,$D48,$D70,$D98,$DC0,$DE8,$E10
	dc.w	$E38,$E60,$E88,$EB0,$ED8,$F00,$F28,$F50,$F78,$FA0
	dc.w	$FC8,$FF0,$1018,$1040,$1068,$1090,$10B8,$10E0
	dc.w	$1108,$1130,$1158,$1180,$11A8,$11D0,$11F8,$1220
	dc.w	$1248,$1270,$1298,$12C0,$12E8,$1310,$1338,$1360
	dc.w	$1388,$13B0,$13D8,$1400,$1428,$1450,$1478,$14A0
	dc.w	$14C8,$14F0,$1518,$1540,$1568,$1590,$15B8,$15E0
	dc.w	$1608,$1630,$1658,$1680,$16A8,$16D0,$16F8,$1720
	dc.w	$1748,$1770,$1798,$17C0,$17E8,$1810,$1838,$1860
	dc.w	$1888,$18B0,$18D8,$1900,$1928,$1950,$1978,$19A0
	dc.w	$19C8,$19F0,$1A18,$1A40,$1A68,$1A90,$1AB8,$1AE0
	dc.w	$1B08,$1B30,$1B58,$1B80,$1BA8,$1BD0,$1BF8,$1C20
	dc.w	$1C48,$1C70,$1C98,$1CC0,$1CE8,$1D10,$1D38,$1D60
	dc.w	$1D88,$1DB0,$1DD8,$1E00,$1E28,$1E50,$1E78,$1EA0
	dc.w	$1EC8,$1EF0,$1F18,$1F40,$1F68,$1F90,$1FB8,$1FE0
	dc.w	$2008,$2030,$2058,$2080,$20A8,$20D0,$20F8,$2120
	dc.w	$2148,$2170,$2198,$21C0,$21E8,$2210,$2238,$2260
	dc.w	$2288,$22B0,$22D8,$2300,$2328,$2350,$2378,$23A0
	dc.w	$23C8,$23F0,$2418,$2440,$2468,$2490,$24B8,$24E0
	dc.w	$2508,$2530,$2558,$2580,$25A8,$25D0,$25F8,$2620
	dc.w	$2648,$2670,$2698,$26C0,$26E8,$2710,$2738,$2760
	dc.w	$2788,$27B0,$27D8,$2800

cazfinito:
	dc.w	0


;	459200 bytes per 410 linee*140 fotogrammi, infatti: 410*8*140=459200
cazpoint:
	dc.l	cazzdatiend

cazpointrep:
	dc.l	0


DrawBlitta:
	move.l	cazpoint(PC),a3
	cmp.l	#cazzdatiend,a3
	bne.s	NoRipartiz
	move.l	cazpointrep(PC),cazpoint
NoRipartiz:
	move.w	#(410/2)-1,d7	; 410 (820) linee - per fast ram

	btst	#2,$16-2(a6)	; right mousebutton
	beq.s	due
		; 5432109876543210	; magari secondo equalizzatore!
	move.w	#%1111111111111111,a2	; pattern per la linea - normale
	bra.s	tre
due:
	move.w	#%1010101010101010,a2	; pattern per la linea - a pua'
tre:

	MOVE.W	#$8000,$74-2(a6)	; BLTADAT
	MOVE.W	A2,$72-2(a6)	; BLTBDAT - Pattern della linea
	MOVE.W	#$FFFF,$44-2(a6)
	moveq	#40,d0	; bytes per linea
	MOVE.W	d0,$60-2(a6)	; BLTCMOD - bytes per linea (larghezza/8)
	MOVE.W	d0,$66-2(a6)	; BLTDMOD - bytes per linea

; ******************+ LOOP MEGAVELOCE DI DRAW DELLE LINEE *****************

;	d0,d1,d2,d3 = coordinate
;	d7 = conteggio loop! *
;	d4 = 
;	d5 = 
;	d6 = 

;	a0 ind dove tracciare -
;	a1 = 
;	a2 = 
;	a3 = cazpoint!!! *
;	a4 = tabba.. -
;	a5 = 
;	a6 = $dff002 -

	move.l	cazpoint(PC),a3		; posizione attuale di cazpoint

	;d6 - coord seconde!
	;a2
	; a1
	; a5

loopo:
	move.l	attualdraw(PC),a0	; ind. dove tracciare
	lea	tabba(PC),a4
	lea	$dff002,a6

	movem.w	(a3)+,d0-d3/d6/a1/a2/a5		; prendi nuove 4 coordinate*2

	cmp.w	#-1,d0	; coordinata a vuoto?
	beq.s	salt	; se si salta!

	moveq	#0,d4
	move.w	0(a4,d1.w*2),d4	; 68020+

	MOVEQ	#-16,D5	; $FFFFFFF0
	AND.W	D0,D5	; escludi i 4 bit bassi di x0
	LSR.W	#3,D5	; dividi per 8, trovando l'offset orizzontale
	ADD.W	D5,D4	; d4 = start address come offset dall'inizio schermo
	ADD.L	A0,D4	; aggiungi indirizzo schermo: d4 = start address FINALE

	MOVEQ	#0,D5
	SUB.W	D1,D3	; y0-y1
	ROXL.B	#1,D5
	TST.W	D3	; y1
	BGE.S	OctSelez1
	NEG.W	D3	; y1
OctSelez1:
	SUB.W	D0,D2	; x0-x1
	ROXL.B	#1,D5
	TST.W	D2	; x1
	BGE.S	OctSelez2
	NEG.W	D2	; x1
OctSelez2:
	MOVE.W	D3,D1	; y1 in d1
	SUB.W	D2,D1	; 
	BGE.S	OctSelez3
	EXG	D2,D3
OctSelez3:
	ROXL.B	#1,D5
	MOVE.B	TabOttanti(PC,D5.L),D5
	ADD.W	D2,D2	; d2*2
	moveq	#6,d1
WaitBlitt:
	BTST.b	d1,(a6)	; aspetta la fine del lavoro del blitter
	BNE.S	WaitBlitt

	MOVE.W	D2,$62-2(a6)		; BLTBMOD - 4y dff062
	SUB.W	D3,D2
	BGE.S	Blizu
	ORI.B	#$40,D5		; setta il bit 6 di BPLCON1 - SIGN = -
Blizu:
	MOVE.W	D2,$52-2(a6)	; BLTAPT - 2y-x
	SUB.W	D3,D2
	MOVE.W	D2,$64-2(a6)	; BLTAMOD
	ANDI.W	#%1111,D0	; seleziona i 4 bit bassi di x0
	ROR.W	#4,D0		; shiftali a destra per BLTCON0
	OR.W	#$BCA,D0	; Aggiungi MINTERMS e USE A,C,D
	MOVE.W	D0,$40-2(a6)	; BLTCON0 -
	MOVE.W	D5,$42-2(a6)	; BLTCON1 -
	MOVE.L	D4,$48-2(a6)	; BLTCPT -
	MOVE.L	D4,$54-2(a6)	; BLTDPT - indirizzo di partenza della linea
	LSL.W	d1,D3
	ADDQ.W	#2,D3
	MOVE.W	D3,$58-2(a6)		; BLTSIZE
salt:

;	movem.w	(a3)+,d0-d3/d6/a1/a2/a5		; prendi nuove 4 coordinate*2

	move.w	d6,d0
	move.w	a1,d1
	move.w	a2,d2
	move.w	a5,d3

	cmp.w	#-1,d0	; coordinata a vuoto?
	beq.w	salt2	; se si salta!

CpuDrawLine1pl:				; d0,d1 =x0,y0 ; d2,d3 = x1,y1

	move.w	D2,D4	; x1 in d4

	move.l	d7,a4

	sub.w	D0,D4	; x0-x1
	beq.w	Xugualone	;
	move.w	D3,D5	; y1 in d5
	sub.w	D1,D5	; y0-y1
	beq.w	Yugualone	;
	blt.s	Verso1Y
	tst.w	D4	; negat?
	blt.s	Verso1x
	moveq	#1,D6
	cmp.w	D4,D5	; diff uguali?
	blt.s	Verso3XY
	bra.w	VersoFatto

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

Verso1x:
	neg.w	D4
	moveq	#-1,D6
	cmp.w	D4,D5
	blt.s	Verso3XY
	bra.w	VersoFatto

Verso1Y:
	neg.w	D5
	move.w	D2,D0
	move.w	D3,D1
	tst.w	D4
	bgt.s	nonPreo
	neg.w	D4
	moveq	#1,D6
	cmp.w	D4,D5
	blt.s	Verso3XY
	bra.w	VersoFatto

nonPreo:
	moveq	#-1,D6
	cmp.w	D4,D5
	blt.s	Verso3XY
	bra.s	VersoFatto

Verso3XY:
;Sclippad0d1ind3
	move.w	D1,D7
	lsl.w	#5,D1
	lsl.w	#3,D7
	add.w	D7,D1
	move.w	D0,D2
	lsr.w	#4,D2
	add.w	D2,D2
	add.w	D2,D1
	andi.w	#15,D0
	neg.w	D0
	addi.w	#15,D0
	moveq	#0,D3
	bset	D0,D3
;
	move.w	D4,D2
	lsr.w	#1,D2
	neg.w	D2
	move.w	D4,D7
	move.l	attualdraw(PC),a1	; ind. dove tracciare
LoopSclippato:
	or.w	D3,0(A1,D1.W)	; scrivi!! d3=offset in byte, d1=offset "big"
	add.w	D5,D2
	ble.s	noad
	sub.w	D4,D2
	addi.w	#40,D1
noad:
	tst.w	D6
	blt.s	scherzavo
	lsr.w	#1,D3
	bcc.s	NosKi
	move.l	#$00008000,D3
	addq.w	#2,D1
	dbra	D7,LoopSclippato
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts


scherzavo:
	lsl.w	#1,D3
	bcc.s	NosKi
	moveq	#1,D3
	subq.w	#2,D1
NosKi:
	dbra	D7,LoopSclippato
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

VersoFatto:
;Sclippad0d1ind3
	move.w	D1,D7
	lsl.w	#5,D1
	lsl.w	#3,D7
	add.w	D7,D1
	move.w	D0,D2
	lsr.w	#4,D2
	add.w	D2,D2
	add.w	D2,D1
	andi.w	#15,D0
	neg.w	D0
	addi.w	#15,D0
	moveq	#0,D3
	bset	D0,D3
;
	move.w	D5,D2
	lsr.w	#1,D2
	neg.w	D2
	move.w	D5,D7
	move.l	attualdraw(PC),a1	; ind. dove tracciare
lopooora:
	or.w	D3,0(A1,D1.W)	; scrivi!! d3=offset in byte, d1=offset "big"
	add.w	D4,D2
	ble.s	NextaLinea
	sub.w	D5,D2
	tst.w	D6
	blt.s	scherzavo2
	lsr.w	#1,D3
	bcc.s	NextaLinea
	move.w	#$8000,D3
	addi.w	#42,D1
	dbra	D7,lopooora
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts


scherzavo2:
	lsl.w	#1,D3
	bcc.s	NextaLinea
	moveq	#1,D3
	addi.w	#38,D1
	dbra	D7,lopooora
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

NextaLinea:
	addi.w	#40,D1
	dbra	D7,lopooora
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

Xugualone:
	move.w	D3,D5
	sub.w	D1,D5
	beq.s	Uscitona
	bgt.s	faona
	neg.w	D5
	exg	D1,D3
faona:
;Sclippad0d1ind3
	move.w	D1,D7
	lsl.w	#5,D1
	lsl.w	#3,D7
	add.w	D7,D1
	move.w	D0,D2
	lsr.w	#4,D2
	add.w	D2,D2
	add.w	D2,D1
	andi.w	#15,D0
	neg.w	D0
	addi.w	#15,D0
	moveq	#0,D3
	bset	D0,D3
;
	move.w	D5,D7
	move.l	attualdraw(PC),a1	; ind. dove tracciare
loopozz:
	or.w	D3,0(A1,D1.W)	; scrivi!! d3=offset in byte, d1=offset "big"
	addi.w	#40,D1
	dbra	D7,loopozz
Uscitona:
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

Yugualone:
	cmp.w	D0,D2
	beq.s	Uscitona
	move.w	D1,D6
	lsl.w	#5,D6
	move.w	D1,D7
	lsl.w	#3,D7
	add.w	D7,D6
	move.w	D2,D1
	lea	FilTab1(PC),A2
	lea	FilTab2(PC),A5
;CPUDrawlin
	cmp.w	D0,D1
	beq.w	MauGuali
	bgt.s	SemprePiu
	exg	D0,D1	; meno!
SemprePiu:
	move.l	attualdraw(PC),a1	; ind. dove tracciare
	move.w	D1,D2
	sub.w	D0,D2
	cmp.w	#$1F,D2
	bgt.s	MaAllora
	addq.w	#1,D2
	ext.l	D0
	BFSET	0(A1,D6.W){D0:D2}	; 68020+
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	RTS

MaAllora:
	move.w	D0,D2
	lsr.w	#5,D2
	move.w	D1,D3
	lsr.w	#5,D3
	sub.w	D2,D3
	lsl.w	#2,D2
	add.w	D2,D6
	andi.w	#$1F,D0
	MOVE.L	0(A2,D0.W*4),D0	; 68020+
	ANDI.W	#$001F,D1
	MOVE.L	0(A5,D1.W*4),D1	; 68020+
	subq.w	#1,D3
	blt.w	Stereo
	beq.w	Mono
	subq.w	#1,D3
	lea	0(A1,D6.W),A6
	or.l	D0,(A6)+
	move.w	D3,D2
FaiPezzone:
	ori.l	#$FFFFFFFF,(A6)+
	dbra	D2,FaiPezzone
	or.l	D1,(A6)
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

Mono:
	lea	0(A1,D6.W),A6
	or.l	D0,(A6)+
	or.l	D1,(A6)
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

Stereo:				; non sicuro
	and.l	D1,D0
	or.l	D0,0(A1,D6.W)
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts

MauGuali:			; forse non occorrerebbe, mai callato
	move.l	cazlin1(PC),D2
	move.l	cazlin2(PC),cazlin1
	move.l	D2,cazlin2
	move.w	D0,D1
	lsr.w	#3,D1
	add.w	D1,D6
	andi.w	#7,D0
	neg.w	D0
	addq.w	#7,D0
	moveq	#0,D2
	bset	D0,D2
	move.b	D2,D3
	not.b	D3
	move.l	attualdraw(PC),a6
	or.b	D2,0(A6,D6.W)
	move.l	a4,d7
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts


salt2:
	dbra	d7,loopo
;fineloopo:
	move.l	a3,cazpoint	; salva la posizione di cazpoint
	rts



;	a0 = 
;	a1 = indirizzo dove tracciare
;	a2 = 
;	a3 = 
;	a4 = 
;	a5 = 
;	a6 = usat

FilTab1:
	dc.l	$FFFFFFFF
	dc.l	$7FFFFFFF
	dc.l	$3FFFFFFF
	dc.l	$1FFFFFFF
	dc.l	$FFFFFFF
	dc.l	$7FFFFFF
	dc.l	$3FFFFFF
	dc.l	$1FFFFFF
	dc.l	$FFFFFF
	dc.l	$7FFFFF
	dc.l	$3FFFFF
	dc.l	$1FFFFF
	dc.l	$FFFFF
	dc.l	$7FFFF
	dc.l	$3FFFF
	dc.l	$1FFFF
	dc.l	$FFFF
	dc.l	$7FFF
	dc.l	$3FFF
	dc.l	$1FFF
	dc.l	$FFF
	dc.l	$7FF
	dc.l	$3FF
	dc.l	$1FF
	dc.l	$FF
	dc.l	$7F
	dc.l	$3F
	dc.l	$1F
	dc.l	15
	dc.l	7
	dc.l	3
	dc.l	1
FilTab2:
	dc.l	$80000000
	dc.l	$C0000000
	dc.l	$E0000000
	dc.l	$F0000000
	dc.l	$F8000000
	dc.l	$FC000000
	dc.l	$FE000000
	dc.l	$FF000000
	dc.l	$FF800000
	dc.l	$FFC00000
	dc.l	$FFE00000
	dc.l	$FFF00000
	dc.l	$FFF80000
	dc.l	$FFFC0000
	dc.l	$FFFE0000
	dc.l	$FFFF0000
	dc.l	$FFFF8000
	dc.l	$FFFFC000
	dc.l	$FFFFE000
	dc.l	$FFFFF000
	dc.l	$FFFFF800
	dc.l	$FFFFFC00
	dc.l	$FFFFFE00
	dc.l	$FFFFFF00
	dc.l	$FFFFFF80
	dc.l	$FFFFFFC0
	dc.l	$FFFFFFE0
	dc.l	$FFFFFFF0
	dc.l	$FFFFFFF8
	dc.l	$FFFFFFFC
	dc.l	$FFFFFFFE
	dc.l	$FFFFFFFF

cazlin1:
	dc.w	$AAAA
	dc.w	$AAAA
cazlin2:
	dc.w	$5555
	dc.w	$5555

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


CLEARSCREEN:
SwappaCoppero:
	MOVE.L	copbufpunt(PC),D0
	lea	coppajumpa,a0
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)
	ADD.L	#((linee*8)+AGGIUNTE),COPBUFPUNT	; PROSSIMA COP
	MOVE.L	copbufpunt(PC),D0
	cmp.l	#finebuffoni,d0
	bne.w	NonRibuffona
	move.l	#copbuf1,copbufpunt
NonRibuffona:
nonora:
	BTST	#6,(a6)	; prima di swappare,il dis. deve essere finito!
	BNE.S	nonora
	move.w	#$7fff,$96-2(a6)		; disable all DMA!
	EORI.W	#$FFFF,switch
	LEA	PLANEPOINTCOP2,A0
	TST.W	switch
	BEQ.S	Scambia2
	LEA	POINTER1(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
	bra.s	CLEARSCREEN1
Scambia2:
	LEA	POINTER2(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
CLEARSCREEN1:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.W	switch
	BNE.S	Azzera2
	LEA	Double1,a0	; plane1
	BRA.S	Azzera1
Azzera2:
	LEA	Double2,a0	; plane2
Azzera1:
	move.l	a0,attualdraw
	MOVE.L	SP,OLDSP
	LEA	scr_size(a0),SP		; ADDRESS OF END SCREEN
	MOVEM.L	CLREG(PC),D0-D7/A0-A6	; CLEAR REGISTERS

;	MOVEM.L	D0-D7/A0-A6,-(SP)	; questa e' $48e7FFFE

	dcb.l	scr_size/60,$48E7FFFE ; NOW CLEAR WITH CPU(60 bytes ogni movem)

	MOVEM.L	D0-D7/a0-a1,-(SP)	; azzera gli ultimi 40 bytes...

	MOVE.L	OLDSP(PC),SP	; 60 bytes every instruction!
	MOVEM.L	(SP)+,D0-D7/A0-A6

		; 5432109876543210
	MOVE.W	#%1000001111000000,$96-2(a6)	; riabilita DMA
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

******************************************************************************
; routine di precalc dell'effetto copper
******************************************************************************

LINEE	Equ	211
AGGIUNTE	=	20	; LUNGHRZZA PARTI AGGIUNTE IN FONDO...
NUMBUFCOPPERI	=	50


PrecalCop:
	lea	copbuf1,a0
	move.w	#NUMBUFCOPPERI-1,d7
FaiBuf:
	bsr.w	FaiCopp1
	add.w	#((linee*8)+AGGIUNTE),a0
	dbra	d7,FaiBuf

; ora "riempiamo"

	move.w	#NUMBUFCOPPERI-1,d7
	lea	copbuf1,a0
ribuf:
 	BSR.s	changecop	; chiama la routine che cambia il copper
	add.w	#((linee*8)+AGGIUNTE),a0
	dbra	d7,riBuf

	MOVE.L	copbufpunt(PC),D0
	lea	coppajumpa,a0
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)

	MOVE.L	#ourcopper,D0
	lea	coppajumpa2,a0
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)

	rts

; routine che crea la copperlist

FaiCopp1:
	move.l	a0,-(SP)
	MOVE.L	#$2c07fffe,d1	; istruzione copper wait, che inizia
				; attendendo alla linea $2c
	MOVE.L	#$1800000,d2	; $dff180 = colore 0 per il copper
	MOVE.w	#LINEE-1,d0	; numero di linee per il loop
	MOVEQ	#$000,d3	; colore da mettere = nero
coploop:
	MOVE.L	d1,(a0)+	; Metti il WAIT
	MOVE.L	d2,(a0)+	; Metti il $180 (color0) azzerato al NERO
	ADD.L	#$01000000,d1	; Fai aspettare il WAIT 1 linea dopo
	DBRA	d0,coploop	; ripeti fino alla fine delle linee
	move.l	finPunt(PC),d0
	MOVE.w	#$82,(A0)+	; PARTEFINALE puntare!
	move.w	d0,(a0)+
	swap	d0
	MOVE.w	#$80,(A0)+	; PARTEFINALE
	move.w	d0,(a0)+
	move.l	#$880000,(a0)+

	move.l	(SP)+,a0
	rts

CopBufPunt:
	dc.l	copbuf1
FinPunt:
	dc.l	pezzofinale
; routine che cambia i colori nella copperlist

changecop:
	move.l	a0,-(SP)
	MOVE.w	#LINEE-1,d0	; numero linee per il loop
	MOVE.L	PuntatoreTABCol(PC),a1	; inizio della tabella colori in a1
	move.l	a1,PuntatTemporaneo	; salvato nel PuntatoreTemporaneo
	moveq	#0,d1			; azzero d1
LineeLoop:
	move.w	(a1)+,6(a0)	; copia il colore dalla tabella alla copperlist
	addq.w	#8,a0		; prossimo color0 in copperlist
 	addq.b	#1,d1		; annoto in d1 la lunghezza della sotto-barra
 	cmp.b	#9,d1		; fine della sotto-barra?
	bne.s	AspettaSottoBarra

	MOVE.L	PuntatTemporaneo(PC),a1
	addq.w	#2,a1			; punto al colore dopo
	cmp.l	#FINETABColBarra,PuntatTemporaneo	; siamo a fine tab?
	bne.s	NonRipartire		; se non ancora, vai a NonRipartire
	lea	TABColoriBarra(pc),a1	; altrimenti riparti dal primo col!
NonRipartire:
	move.l	a1,PuntatTemporaneo	; e salva il valore nel Pun. temporaneo
	moveq	#0,d1			; azzero d1
AspettaSottoBarra:
	dbra d0,LineeLoop	; fai tutte le linee

	addq.l	#2,PuntatoreTABCol		 ; prossimo colore
	cmp.l	#FINETABColBarra+2,PuntatoreTABCol ; siamo alla fine della
						 ; tabella colori?
	bne.s FineRoutine			 ; se no, esci, altrimenti...
	move.l #TABColoriBarra,PuntatoreTABCol	 ; riparti dal primo valore di
						 ; TABColoriBarra
FineRoutine:
	move.l	(SP)+,a0
	rts

;	altezza barre

barlen:
	dc.b	1

	even


;	Tabella con i valori RGB dei colori. in questo caso sono toni di BLU

TABColoriBarra:
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$008,$009,$00A,$00B,$00C,$00D,$00D,$00E
	dc.w	$00E,$00F,$00F,$00F,$00E,$00E,$00D,$00D
	dc.w	$00C,$00B,$00A,$009,$008,$007,$006,$005
	dc.w	$004,$003,$002,$001,$000,$000,$000,$000
	dcb.w	10,$000
FINETABColBarra:
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007	; questi valori servono
	dc.w	$008,$009,$00A,$00B,$00C,$00D,$00D,$00E ; per le sotto-barre
	dc.w	$00E,$00F,$00F,$00F,$00E,$00E,$00D,$00D
	dc.w	$00C,$00B,$00A,$009,$008,$007,$006,$005
	dc.w	$004,$003,$002,$001,$000,$000,$000,$000


PuntatTemporaneo:
 	dc.l	TABColoriBarra

PuntatoreTABCol:
 	DC.L	TABColoriBarra

***************************************************************************

	SECTION	dati,BSS

d3_TransData:			; buffer un po a caso eh!
	ds.b	820*2

	Section	caz,bss

	ds.b	64*8
cazzdati:
;	459200 bytes per 410 linee*140 fotogrammi, infatti: 410*8*140=459200
	ds.b	410*8*256	;140
cazzdatiend:
	ds.b	64*8

	cnop	0,8

	SECTION	GRAPH,DATA_C

ourcopper:
Copper2:
;	dc.w	$8e,DIWS	; DiwStrt
;	dc.w	$90,DIWSt	; DiwStop
	dc.w	$8e,$2c82	; DiwStrt	; chiusurina...
	dc.w	$90,$2cc1	; DiwStop

	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop
	dc.w	$102,0		; BplCon1

FETCH:
	dc.w	$1fc,0
	dc.w	$104,0		; BplCon2
MOD0:
	dc.w	$108,0		;BPL1MOD
MOD1:
	dc.w	$10A,0		;BPL2MOD

	dc.w	$100,BPLC0	; BplCon0
	dc.w	$E0
PLANEPOINTCOP2:
	dc.w	0
	dc.w	$E2,0
	dc.w	$180,$000	; color0
	dc.w	$182,$0Fa	; color1

coppajumpa:
	dc.w	$84
	DC.W	0		; cop2LC
	dc.w	$86
	DC.W	0
	DC.W	$8a,0		; COPJMP2

* * * * * * 

pezzofinale:
	dc.w	$ffdf,$fffe
	dc.w	$0107,$fffe
	dc.w	$180,$010
	dc.w	$0207,$fffe
	dc.w	$180,$020
	dc.w	$0307,$fffe
	dc.w	$180,$030
	dc.w	$0507,$fffe
	dc.w	$180,$040
	dc.w	$0707,$fffe
	dc.w	$180,$050
	dc.w	$0907,$fffe
	dc.w	$180,$060
	dc.w	$0c07,$fffe
	dc.w	$180,$070
	dc.w	$0f07,$fffe
	dc.w	$180,$080
	dc.w	$1207,$fffe
	dc.w	$180,$090
	dc.w	$1607,$fffe
	dc.w	$180,$0a0
	dc.w	$1a07,$fffe
	dc.w	$180,$0b0
	dc.w	$1f07,$fffe
	dc.w	$180,$0c0
	dc.w	$2607,$fffe
	dc.w	$180,$0d0
	dc.w	$2c07,$fffe
	dc.w	$180,$0e0

coppajumpa2:
	dc.w	$80	; per far ripartire la copperlist dall'ourcopper
	DC.W	0		; cop2LC
	dc.w	$82
	DC.W	0
	dc.w	$FFFF,$FFFE	; Fine della copperlist
finepezzofinale:


	section	bufcopperi,bss_C

copcols:
copbuf1:
	ds.b	((linee*8)+AGGIUNTE)*NUMBUFCOPPERI
b:
finebuffoni:


	SECTION	Objectaaa,BSS_C

	cnop	0,8
	ds.b	64
Double1:
	ds.b	scr_size	; larghezza 416
	ds.b	64

	cnop	0,8
Double2:
	ds.b	scr_size
	ds.b	64

	end

(altezza 287 linee overscannate.. mah...)
