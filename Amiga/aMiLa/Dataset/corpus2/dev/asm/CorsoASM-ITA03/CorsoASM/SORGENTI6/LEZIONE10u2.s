
; Lezione10u2.s Effetto con linee
;		tasto destro per vedere altri effetti, sinistro per uscire

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	bsr.w	InitLine	; inizializza line-mode

	move.w	#$ffff,d0	; linea continua
	bsr.w	SetPattern	; definisce pattern

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1

	bsr.w	ScambiaBuffer	; questa routine scambia i 2 buffer

	bsr.w	CancellaSchermo	; pulisce lo schermo

	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	NonCambia	; se no salta..
	bsr.s	CambiaParametri	; ..altrimenti cambia i parametri delle linee
NonCambia:

	bsr.w	MuoviPunti	; modifica le coordinate dei punti della prima
				; linea


	move.w	IndiceX1(pc),d4	; legge gli indici della prima linea
	move.w	IndiceX2(pc),d5
	move.w	IndiceY1(pc),d6
	move.w	IndiceY2(pc),d7

	move.w	NumLines(pc),d0

LineLoop:

; disegna la linea

	movem.l	d0-d7,-(a7)	; salva i registri
	move.w	CoordX1(pc),d0	; legge le coordinate dei punti
	move.w	CoordY1(pc),d1
	move.w	CoordX2(pc),d2
	move.w	CoordY2(pc),d3
	move.l	draw_buffer(pc),a0
	bsr.w	Drawline
	movem.l	(a7)+,d0-d7	; rileggi i registri

	bsr.w	NextLine

	dbra	d0,LineLoop	; ripeti per ogni linea

	btst	#6,$bfe001	; mouse premuto?
	bne.w	mouse

	rts


;***************************************************************************
; Questa routine cambia i valori dei parametri.
; I valori cambiati sono: "NumLines", i 4 "Indice", i 4 "Add", i 4 "NextAdd"
; I nuovi valori sono contenuti in un'apposita tabella.
; Siccome tutti i valori da cambiare sono consecutivi in memoria, si puo`
; utilizzare un unico loop di copia
;***************************************************************************

;	          _ _
;	   .   __/ V \__  ..
;	   .  /___ : ___\  ::
;	 .: _/____\_/____\_ ::
;	:::/ฏ ฌ(@:)_(@:)ฌ ฏ\:::
;	_::\_ __/ฏ/_\ฏ\__ _/:::
;	  ::ท\:| . : . |:/ ::::
;	   .:.ฏ:_|_|_|_:ฏ.::::ท
;	    ท::( V_V_V ):::ท
;	        \|   |/

CambiaParametri:
	move.l	PointerParam(pc),a0	; puntatore ai nuovi valori
	lea	NumLines(pc),a1		; puntatore alle variabili

	moveq	#13-1,d0		; numero di valori da cambiare
CambiaLoop:
	move.w	(a0)+,(a1)+		; loop di copia
	dbra	d0,CambiaLoop

	cmp.l	#FineParam,a0		; siamo alla fine della tabella?
	blo.s	NoRestart		; se no salta..
	lea	TabParam(pc),a0		; ..altrimenti ricomincia da capo

NoRestart:
	move.l	a0,PointerParam		; memorizza il puntatore

; aspetta che venga rilasciato il pulsante del mouse

Waitmouse:
	btst	#2,$dff016		; tasto destro del mouse premuto?
	beq.s	Waitmouse		; se si aspetta

	rts

; puntatore alla tabella dei parametri

PointerParam:	dc.l	TabParam

; Tabella dei parametri
; potete provare a specificare voi dei parametri. I parametri (tranne il primo)
; DEVONO essere numeri PARI

TabParam:
	dc.w	$3a,0,$40,0,$40,2,2,2,2,8,8,$10,$10
	dc.w	$32,0,$80,0,$80,2,2,4,4,$7e,$80,$7e,$80

	dc.w	$3A,0,0,0,0,-2,2,4,4,$7e,$7e,$7e,$7e

	dc.w	$38,0,$68,0,$68,2,2,4,4,8,8,10,10
	dc.w	$28,$64,0,0,0,6,4,4,2,6,6,4,8
	dc.w	$3A,$40,$40,$40,$40,2,2,2,8,2,2,4,4
	dc.w	$39,2,0,$68,0,-2,2,4,4,8,8,10,10

	dc.w	$27,$64,0,0,0,8,4,4,2,4,2,2,4
	dc.w	$3A,0,$40,0,$40,2,2,4,4,4,4,$104,$104
FineParam:

;***************************************************************************
; Questa routine legge da tabelle le coordinate dei vertici delle linee
; successiva alla prima e le memorizza nelle apposite variabili.
; La lettura dalle tabelle viene effettuata mediante l'indirizzamento indiretto
; con indice. Per spostarci all'interno delle tabelle modifichiamo gli indici
; (che sono words) invece che i puntatori (longwords). Cio` ci permette di
; evitare di fuoriuscire dalla tabella con una semplice AND che mantiene
; l'indice compreso nell'intervallo 0 - 512 (infatti le tabelle sono composte
; da 256 valori words (512 bytes).
; Gli indici delle coordinate precedenti sono memorizzati
; nei registri D4,D5,D6,D7
; I valori da sommare all'indice per passare da una linea all'altra sono
; memorizzari in apposite variabili.
;***************************************************************************

NextLine:
	lea	TabX(pc),a0

; coordinata X1

	add.w	NextAddX1(pc),d4	; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d4		; tiene l'indice all'interno della
					; tabella
	move.w	0(a0,d4.w),CoordX1	; copia la coordinata dalla tabella
					; nella variabile

; coordinata X2

	add.w	NextAddX2(pc),d5	; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d5		; tiene l'indice all'interno della
					; tabella
	move.w	0(a0,d5.w),CoordX2	; copia la coordinata dalla tabella
					; nella variabile


	lea	TabY(pc),a0

; coordinata Y1

	add.w	NextAddY1(pc),d6	; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d6		; tiene l'indice all'interno della
					; tabella
	move.w	0(a0,d6.w),CoordY1	; copia la coordinata dalla tabella
					; nella variabile
; coordinata Y2

	add.w	NextAddY2(pc),d7	; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d7		; tiene l'indice all'interno della
					; tabella
	move.w	0(a0,d7.w),CoordY2	; copia la coordinata dalla tabella
					; nella variabile
	rts

;***************************************************************************
; Questa routine legge da tabelle le coordinate dei vari punti e le
; memorizza nelle apposite variabili.
; La lettura dalle tabelle viene effettuata mediante l'indirizzamento indiretto
; con indice. Per spostarci all'interno delle tabelle modifichiamo gli indici
; (che sono words) invece che i puntatori (longwords). Cio` ci permette di
; evitare di fuoriuscire dalla tabella con una semplice AND che mantiene
; l'indice compreso nell'intervallo 0 - 512 (infatti le tabelle sono composte
; da 256 valori words (512 bytes).
;***************************************************************************

MuoviPunti:
	lea	TabX(pc),a0

; coordinata X1

	move.w	indiceX1(pc),d0		; indice della coordinata precedente
	add.w	addX1(pc),d0		; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d0		; tiene l'indice all'interno della
					; tabella
	move.w	d0,indiceX1		; memorizza l'indice
	move.w	0(a0,d0.w),d1		; legge la coordinata dalla tabella
	move.w	d1,CoordX1		; copia la coordinata nella variabile

; coordinata X2

	move.w	indiceX2(pc),d0		; indice della coordinata precedente
	add.w	addX2(pc),d0		; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d0		; tiene l'indice all'interno della
					; tabella
	move.w	d0,indiceX2		; memorizza l'indice
	move.w	0(a0,d0.w),d1		; legge la coordinata dalla tabella
	move.w	d1,CoordX2		; copia la coordinata nella variabile

	lea	TabY(pc),a0

; coordinata Y1

	move.w	indiceY1(pc),d0		; indice della coordinata precedente
	add.w	addY1(pc),d0		; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d0		; tiene l'indice all'interno della
					; tabella
	move.w	d0,indiceY1		; memorizza l'indice
	move.w	0(a0,d0.w),d1		; legge la coordinata dalla tabella
	move.w	d1,CoordY1		; copia la coordinata nella variabile

; coordinata Y2

	move.w	indiceY2(pc),d0		; indice della coordinata precedente
	add.w	addY2(pc),d0		; modifica l'indice per puntare
					; la nuova coordinata
	and.w	#$1FF,d0		; tiene l'indice all'interno della
					; tabella
	move.w	d0,indiceY2		; memorizza l'indice
	move.w	0(a0,d0.w),d1		; legge la coordinata dalla tabella
	move.w	d1,CoordY2		; copia la coordinata nella variabile
	rts

; questa tabella contiene le coordinate X

TabX:
	DC.W	$00A2,$00A6,$00A9,$00AD,$00B1,$00B4,$00B8,$00BB,$00BF,$00C3
	DC.W	$00C6,$00CA,$00CD,$00D1,$00D4,$00D8,$00DB,$00DE,$00E2,$00E5
	DC.W	$00E8,$00EC,$00EF,$00F2,$00F5,$00F8,$00FB,$00FE,$0101,$0103
	DC.W	$0106,$0109,$010B,$010E,$0110,$0113,$0115,$0117,$011A,$011C
	DC.W	$011E,$0120,$0122,$0123,$0125,$0127,$0128,$012A,$012B,$012D
	DC.W	$012E,$012F,$0130,$0131,$0132,$0133,$0133,$0134,$0135,$0135
	DC.W	$0135,$0136,$0136,$0136,$0136,$0136,$0136,$0135,$0135,$0135
	DC.W	$0134,$0133,$0133,$0132,$0131,$0130,$012F,$012E,$012D,$012B
	DC.W	$012A,$0128,$0127,$0125,$0123,$0122,$0120,$011E,$011C,$011A
	DC.W	$0117,$0115,$0113,$0110,$010E,$010B,$0109,$0106,$0103,$0101
	DC.W	$00FE,$00FB,$00F8,$00F5,$00F2,$00EF,$00EC,$00E8,$00E5,$00E2
	DC.W	$00DE,$00DB,$00D8,$00D4,$00D1,$00CD,$00CA,$00C6,$00C3,$00BF
	DC.W	$00BB,$00B8,$00B4,$00B1,$00AD,$00A9,$00A6,$00A2,$009E,$009A
	DC.W	$0097,$0093,$008F,$008C,$0088,$0085,$0081,$007D,$007A,$0076
	DC.W	$0073,$006F,$006C,$0068,$0065,$0062,$005E,$005B,$0058,$0054
	DC.W	$0051,$004E,$004B,$0048,$0045,$0042,$003F,$003D,$003A,$0037
	DC.W	$0035,$0032,$0030,$002D,$002B,$0029,$0026,$0024,$0022,$0020
	DC.W	$001E,$001D,$001B,$0019,$0018,$0016,$0015,$0013,$0012,$0011
	DC.W	$0010,$000F,$000E,$000D,$000D,$000C,$000B,$000B,$000B,$000A
	DC.W	$000A,$000A,$000A,$000A,$000A,$000B,$000B,$000B,$000C,$000D
	DC.W	$000D,$000E,$000F,$0010,$0011,$0012,$0013,$0015,$0016,$0018
	DC.W	$0019,$001B,$001D,$001E,$0020,$0022,$0024,$0026,$0029,$002B
	DC.W	$002D,$0030,$0032,$0035,$0037,$003A,$003D,$003F,$0042,$0045
	DC.W	$0048,$004B,$004E,$0051,$0054,$0058,$005B,$005E,$0062,$0065
	DC.W	$0068,$006C,$006F,$0073,$0076,$007A,$007D,$0081,$0085,$0088
	DC.W	$008C,$008F,$0093,$0097,$009A,$009E

; questa tabella contiene le coordinate Y

TabY:
	DC.W	$0080,$0083,$0086,$0088,$008B,$008E,$0090,$0093,$0096,$0098
	DC.W	$009B,$009E,$00A0,$00A3,$00A5,$00A8,$00AA,$00AD,$00AF,$00B2
	DC.W	$00B4,$00B6,$00B9,$00BB,$00BD,$00BF,$00C2,$00C4,$00C6,$00C8
	DC.W	$00CA,$00CC,$00CE,$00D0,$00D1,$00D3,$00D5,$00D7,$00D8,$00DA
	DC.W	$00DB,$00DD,$00DE,$00DF,$00E1,$00E2,$00E3,$00E4,$00E5,$00E6
	DC.W	$00E7,$00E8,$00E9,$00E9,$00EA,$00EB,$00EB,$00EC,$00EC,$00EC
	DC.W	$00ED,$00ED,$00ED,$00ED,$00ED,$00ED,$00ED,$00ED,$00EC,$00EC
	DC.W	$00EC,$00EB,$00EB,$00EA,$00E9,$00E9,$00E8,$00E7,$00E6,$00E5
	DC.W	$00E4,$00E3,$00E2,$00E1,$00DF,$00DE,$00DD,$00DB,$00DA,$00D8
	DC.W	$00D7,$00D5,$00D3,$00D1,$00D0,$00CE,$00CC,$00CA,$00C8,$00C6
	DC.W	$00C4,$00C2,$00BF,$00BD,$00BB,$00B9,$00B6,$00B4,$00B2,$00AF
	DC.W	$00AD,$00AA,$00A8,$00A5,$00A3,$00A0,$009E,$009B,$0098,$0096
	DC.W	$0093,$0090,$008E,$008B,$0088,$0086,$0083,$0080,$007E,$007B
	DC.W	$0078,$0076,$0073,$0070,$006E,$006B,$0068,$0066,$0063,$0060
	DC.W	$005E,$005B,$0059,$0056,$0054,$0051,$004F,$004C,$004A,$0048
	DC.W	$0045,$0043,$0041,$003F,$003C,$003A,$0038,$0036,$0034,$0032
	DC.W	$0030,$002E,$002D,$002B,$0029,$0027,$0026,$0024,$0023,$0021
	DC.W	$0020,$001F,$001D,$001C,$001B,$001A,$0019,$0018,$0017,$0016
	DC.W	$0015,$0015,$0014,$0013,$0013,$0012,$0012,$0012,$0011,$0011
	DC.W	$0011,$0011,$0011,$0011,$0011,$0011,$0012,$0012,$0012,$0013
	DC.W	$0013,$0014,$0015,$0015,$0016,$0017,$0018,$0019,$001A,$001B
	DC.W	$001C,$001D,$001F,$0020,$0021,$0023,$0024,$0026,$0027,$0029
	DC.W	$002B,$002D,$002E,$0030,$0032,$0034,$0036,$0038,$003A,$003C
	DC.W	$003F,$0041,$0043,$0045,$0048,$004A,$004C,$004F,$0051,$0054
	DC.W	$0056,$0059,$005B,$005E,$0060,$0063,$0066,$0068,$006B,$006E
	DC.W	$0070,$0073,$0076,$0078,$007B,$007E


; Qui sono memorizzate i volta in volta le coordinate dei vertici della linea

CoordX1:	dc.w	0
CoordY1:	dc.w	0
CoordX2:	dc.w	0
CoordY2:	dc.w	0

; Qui e` memorizzato il numero di linee disegnate

NumLines:	dc.w	10

; Qui sono memorizzati per ogni coordinata gli indici all'interno della tabella

IndiceX1:	dc.w	20
IndiceY1:	dc.w	50
IndiceX2:	dc.w	30
IndiceY2:	dc.w	40

; Qui sono memorizzati per ogni coordinata i valori da aggiungere ad ogni frame
; agli indici della tabella per i vertici della prima linea

addX1:	dc.w	4
addY1:	dc.w	-6
addX2:	dc.w	-2
addY2:	dc.w	2

; Qui sono memorizzati per ogni coordinata i valori da aggiungere agli indici
; della tabella per i vertici delle linee successive

NextaddX1:	dc.w	10
NextaddY1:	dc.w	14
NextaddX2:	dc.w	6
NextaddY2:	dc.w	-4

;******************************************************************************
; Questa routine effettua il disegno della linea. prende come parametri gli
; estremi della linea P1 e P2, e l'indirizzo del bitplane su cui disegnarla.
; D0 - X1 (coord. X di P1)
; D1 - Y1 (coord. Y di P1)
; D2 - X2 (coord. X di P2)
; D3 - Y2 (coord. Y di P2)
; A0 - indirizzo bitplane
;******************************************************************************

; costanti

DL_Fill		=	0		; 0=NOFILL / 1=FILL

	IFEQ	DL_Fill
DL_MInterns	=	$CA
	ELSE
DL_MInterns	=	$4A
	ENDC


DrawLine:
	sub.w	d1,d3	; D3=Y2-Y1

	IFNE	DL_Fill
	beq.s	.end	; per il fill non servono linee orizzontali 
	ENDC

	bgt.s	.y2gy1	; salta se positivo..
	exg	d0,d2	; ..altrimenti scambia i punti
	add.w	d3,d1	; mette in D1 la Y piu` piccola
	neg.w	d3	; D3=DY
.y2gy1:
	mulu.w	#40,d1		; offset Y
	add.l	d1,a0
	moveq	#0,d1		; D1 indice nella tabella ottanti
	sub.w	d0,d2		; D2=X2-X1
	bge.s	.xdpos		; salta se positivo..
	addq.w	#2,d1		; ..altrimenti sposta l'indice
	neg.w	d2		; e rendi positiva la differenza
.xdpos:
	moveq	#$f,d4		; maschera per i 4 bit bassi
	and.w	d0,d4		; selezionali in D4
		
	IFNE	DL_Fill		; queste istruzioni vengono assemblate
				; solo se DL_Fill=1
	move.b	d4,d5		; calcola numero del bit da invertire
	not.b	d5		; (la BCHG numera i bit in modo inverso	
	ENDC

	lsr.w	#3,d0		; offset X:
				; Allinea a byte (serve per BCHG)
	add.w	d0,a0		; aggiunge all'indirizzo
				; nota che anche se l'indirizzo
				; e` dispari non fa nulla perche`
				; il blitter non tiene conto del
				; bit meno significativo di BLTxPT

	ror.w	#4,d4		; D4 = valore di shift A
	or.w	#$B00+DL_MInterns,d4	; aggiunge l'opportuno
					; Minterm (OR o EOR)
	swap	d4		; valore di BLTCON0 nella word alta
		
	cmp.w	d2,d3		; confronta DiffX e DiffY
	bge.s	.dygdx		; salta se >=0..
	addq.w	#1,d1		; altrimenti setta il bit 0 del'indice
	exg	d2,d3		; e scambia le Diff
.dygdx:
	add.w	d2,d2		; D2 = 2*DiffX
	move.w	d2,d0		; copia in D0
	sub.w	d3,d0		; D0 = 2*DiffX-DiffY
	addx.w	d1,d1		; moltiplica per 2 l'indice e
				; contemporaneamente aggiunge il flag
				; X che vale 1 se 2*DiffX-DiffY<0
				; (settato dalla sub.w)
	move.b	Oktants(PC,d1.w),d4	; legge l'ottante
	swap	d2			; valore BLTBMOD in word alta
	move.w	d0,d2			; word bassa D2=2*DiffX-DiffY
	sub.w	d3,d2			; word bassa D2=2*DiffX-2*DiffY
	moveq	#6,d1			; valore di shift e di test per
					; la wait blitter 

	lsl.w	d1,d3		; calcola il valore di BLTSIZE
	add.w	#$42,d3

	lea	$52(a5),a1	; A1 = indirizzo BLTAPTL
				; scrive alcuni registri
				; consecutivamente con delle 
				; MOVE #XX,(Ax)+

	btst	d1,2(a5)	; aspetta il blitter
.wb:
	btst	d1,2(a5)
	bne.s	.wb

	IFNE	DL_Fill		; questa istruzione viene assemblata
				; solo se DL_Fill=1
	bchg	d5,(a0)		; Inverte il primo bit della linea
	ENDC

	move.l	d4,$40(a5)	; BLTCON0/1
	move.l	d2,$62(a5)	; BLTBMOD e BLTAMOD
	move.l	a0,$48(a5)	; BLTCPT
	move.w	d0,(a1)+	; BLTAPTL
	move.l	a0,(a1)+	; BLTDPT
	move.w	d3,(a1)		; BLTSIZE
.end:
	rts

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
; se vogliamo eseguire linee per il fill, il codice ottante setta ad 1 il bit
; SING attraverso la costante SML

	IFNE	DL_Fill
SML		= 	2
	ELSE
SML		=	0
	ENDC

; tabella ottanti

Oktants:
	dc.b	SML+1,SML+1+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+9,SML+9+$40
	dc.b	SML+21,SML+21+$40

;******************************************************************************
; Questa routine setta i registri del blitter che non devono essere
; cambiati tra una line e l'altra
;******************************************************************************

InitLine
	btst	#6,2(a5) ; dmaconr
WBlit_Init:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Init

	moveq	#-1,d5
	move.l	d5,$44(a5)		; BLTAFWM/BLTALWM = $FFFF
	move.w	#$8000,$74(a5)		; BLTADAT = $8000
	move.w	#40,$60(a5)		; BLTCMOD = 40
	move.w	#40,$66(a5)		; BLTDMOD = 40
	rts

;******************************************************************************
; Questa routine definisce il pattern che deve essere usato per disegnare
; le linee. In pratica si limita a settare il registro BLTBDAT.
; D0 - contiene il pattern della linea 
;******************************************************************************
SetPattern
	btst	#6,2(a5) ; dmaconr
WBlit_Set:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Set

	move.w	d0,$72(a5)	; BLTBDAT = pattern della linea
	rts


;****************************************************************************
; Questa routine cancella lo schermo mediante il blitter.
;****************************************************************************

CancellaSchermo:
	move.l	draw_buffer(pc),a0	; indirizzo area da cancellare

	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move.w	#$0000,$66(a5)		; BLTDMOD=0
	move.l	a0,$54(a5)		; BLTDPT
	move.w	#(64*256)+20,$58(a5)	; BLTSIZE (via al blitter !)
					; cancella tutto lo schermo
	rts

;****************************************************************************
; Questa routine scambia i 2 buffer scambiando gli indirizzi nelle
; variabili VIEW_BUFFER e  DRAW_BUFFER.
; Inoltre aggiorna nella copperlist le istruzioni che caricano i registri
; BPLxPT, in modo che puntino al nuovo buffer da visualizzare.
;****************************************************************************

ScambiaBuffer
	move.l	draw_buffer(pc),d0		; scambia il contenuto
	move.l	view_buffer(pc),draw_buffer	; delle variabili
	move.l	d0,view_buffer			; in d0 c'e` l'indirizzo
						; del nuovo buffer
						; da visualizzare

; aggiorna la copperlist puntando i bitplanes del nuovo buffer da visualizzare

	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	rts


; puntatori ai 2 buffer

view_buffer:	dc.l	BITPLANE	; buffer visualizzato
draw_buffer:	dc.l	BITPLANEb	; buffer di disegno

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$1200	; Bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w	$e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

	Section	IlMioPlane,bss_C

; buffer 1

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

; buffer 2

BITPLANEb:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio aggiungiamo altre linee al programma lezione10h1.s
realizzando effetti piu` complessi. Le linee successive alla prima vengono
disegnate prendendo come coordinate dei valori letti sempre dalla tabella.
Per calcolare le nuove coordinate vengono aggiunti agli indici dei valori
ad ogni linea. Tali valori sono contenuti nelle variabili "NextAdd".
Inoltre premendo il bottone destro si possono variare tutti i valori
delle variabili. In questo modo si possono ottenere nuovi effetti semplicemente
variando i parametri.

