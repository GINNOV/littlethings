******************************************************************************
*	        	INTRO DEFY 7 BY MODEM/X-ZONE			     *
******************************************************************************

	SECTION	tunnelcode,CODE
	incdir	"dh1:programs/asmone/modem/st03/"
	include	"daworkbench.s"
	include	"startup2.s"

WAITDISK	equ	0

DMASET	equ	%1000001110000000	; copper, bitplane abilitati

START:
*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*				INTROPART				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
	movem.l	d0-d7/a0-a6,-(SP)	; setto la musica
	lea	P61_data,a0	; Indirizzo del modulo in a0
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	sub.l	a1,a1		; I samples non sono a parte, mettiamo zero
	sub.l	a2,a2		; no samples -> modulo non compattato
	lea	samples,a2	; modulo compattato! Buffer destinazione per
				; i samples (in chip ram) da indicare!
	bsr.w	P61_Init
	movem.l	(SP)+,d0-d7/a0-a6

	move.l	BaseVbr(PC),A1
	move.l	#MyInt6c,$6C(A1)
	move.w	#DMASET,$96(a5)		; DMACON - abilita bitplane e copper
	move.w	#$e020,$9a(a5)		; INTENA - Abilito Master and lev6

	move.l	#TITOLO,d0
	lea	BPLPOINTERS,A1	
	moveq	#8-1,D7

POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#$2800,d0
	addq.w	#8,a1
	dbra	d7,POINTB

	move.l	#COPLIST,$dff080
	move.w	d0,$dff088

	move.w	#0,$dff1fc
	move.w	#$c00,$dff106

	clr.l	VBcounter

LOGOWBLANY1:
	bsr.w	WBLAN

	bsr.w	MAINFADEINOUT

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#85,VBcounter
	blo.s	LOGOWBLANY1

	clr.l	VBcounter

LOGOWBLANY2:
	bsr.w	WBLAN


	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#698,VBcounter
	blo.s	LOGOWBLANY2

	clr.l	VBcounter

LOGOWBLANY3:
	bsr.w	WBLAN

	bsr.w	MAINFADEINOUT

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#95,VBcounter
	blo.s	LOGOWBLANY3

	clr.l	VBcounter

	MOVE.L	#SALE,d0
	LEA	SALEBPLPOINTERS,A1
	MOVEQ	#4-1,D1

SALEPOINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#40*572,d0
	addq.w	#8,a1
	dbra	d1,SALEPOINTBP

	move.l	#SALECOPLIST,$dff080
	move.w	d0,$dff088
	move.w	#0,$dff1fc
	move.w	#$c00,$dff106

LOGOWBLANYSALE:
	bsr.w	WBLAN

	bsr.w	SALITA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#100,VBcounter
	blo.s	LOGOWBLANYSALE

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*				LOGO DEFY 7				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLPOINTERS2,a1	; Indirizzo Puntatori in a1
	move.l	#DEFY,d0	; Indirizzo Bitplanes in d0
	moveq	#4-1,d1		; Numero Bitplane 4

POINTBP:
 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro
 	add.l	#40*60,d0	; alto 60 pixel
 	addq.w	#8,a1		; Prossimo puntatore ai bitplane
 	dbra	d1,POINTBP	; Ripetiamo il ciclo d1 volte

	move.l	#COPLIST2,$80(a5)	; Puntiamo la nostra 1a COP
	move.w	d0,$88(a5)		; Facciamo partire la 1a COP

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*				FLASH BIANCO				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLVUOTO,a1	; Indirizzo Puntatori in a1
	move.l	#VUOTO,d0	; Indirizzo Bitplanes in d0

 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro

	move.l	#COPVUOTO,$84(a5)	; Puntiamo la nostra 2a COP


	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANY1:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#10,VBcounter
	blo.s	WBLANY1

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*			PRIMA PARTE: SFERA				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*


	lea 	BPLPOINTERS3,a1	; Indirizzo Puntatori in a1
	move.l	#SFERA,d0	; Indirizzo Bitplanes in d0
	moveq	#7,d1		; Numero Bitplane 8

POINTBPa:
 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro
 	add.l	#40*256,d0	; Prossimo bitplane
 	addq.w	#8,a1		; Prossimo puntatore ai bitplane
 	dbra	d1,POINTBPa	; Ripetiamo il ciclo d1 volte

	move.l	#COPLIST3,$84(a5)	; Puntiamo la nostra 2a COP

	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANNY3:
	bsr.w	WBLAN

	bsr.w	MAPPING
	bsr.w	READ24BIT
	bsr.w	ANIMAP
	bsr.w	RIMBALZO

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#1080,VBcounter
	blo.s	WBLANNY3

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*				FLASH BIANCO				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLVUOTO,a1	; Indirizzo Puntatori in a1
	move.l	#VUOTO,d0	; Indirizzo Bitplanes in d0

 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro

	move.l	#COPVUOTO,$84(a5)	; Puntiamo la nostra 2a COP

	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANY2:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#10,VBcounter
	blo.s	WBLANY2

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*			SECONDA PARTE: CREDITS				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLVUOTO,a1	; Indirizzo Puntatori in a1
	move.l	#CREDITS,d0	; Indirizzo Bitplanes in d0

 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro

	move.l	#COPVUOTO,$84(a5)	; Puntiamo la nostra 2a COP

	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANNY4:
	bsr.w	WBLAN

	BSR.W	PRINTCARATTERE
	BSR.W	PRINTCARATTERE

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#810,VBcounter
	blo.s	WBLANNY4

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*				FLASH BIANCO				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLVUOTO,a1	; Indirizzo Puntatori in a1
	move.l	#VUOTO,d0	; Indirizzo Bitplanes in d0

 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro

	move.l	#COPVUOTO,$84(a5)	; Puntiamo la nostra 2a COP

	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANY3:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#10,VBcounter
	blo.s	WBLANY3

	clr.l	VBcounter
	
*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*			TERZA PARTE: TUNNEL				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLPOINTERS5,a1	; Indirizzo Puntatori in a1
	move.l	#TUNNEL,d0	; Indirizzo Bitplanes in d0
	moveq	#7,d1		; Numero Bitplane 8

POINTBPb:
 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro
 	add.l	#40*256,d0	; Prossimo bitplane
 	addq.w	#8,a1		; Prossimo puntatore ai bitplane
 	dbra	d1,POINTBPb	; Ripetiamo il ciclo d1 volte

	move.l	#COPLIST5,$84(a5)	; Puntiamo la nostra 2a COP

	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANNY5:
	bsr.w	WBLAN

	bsr.w	MAPPING
	bsr.w	TUNNELREAD24BIT
	bsr.w	ANIMAP
	bsr.w	ONDULA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#2280,VBcounter
	blo.s	WBLANNY5

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*				FLASH BIANCO				      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	lea 	BPLVUOTO,a1	; Indirizzo Puntatori in a1
	move.l	#VUOTO,d0	; Indirizzo Bitplanes in d0

 	move.w	d0,6(a1)	; Copia la word bassa
 	swap	d0		; Inverte il registro
 	move.w	d0,2(a1)	; Copia la word alta
 	swap	d0		; Inverte il registro

	move.l	#COPVUOTO,$84(a5)	; Puntiamo la nostra 2a COP

	lea	FINECOP,a4
	move.l	#$8affff,(a4)	; facciamo partire anche la COP2

WBLANNY6:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#10,VBcounter
	blo.s	WBLANNY6

	clr.l	VBcounter

*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
*		            USCITA DEL LOGO DEFY 7			      *
*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

	move.l	#SALE,d0
	lea	SALEBPLPOINTERS-40*256*4,A1
	moveq	#4-1,D1

POINTBPLAST:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#40*572,d0
	addq.w	#8,a1
	dbra	d1,POINTBPLAST

	move.l	#SALECOPLIST,$dff080
	move.w	d0,$dff088
	move.w	#0,$dff1fc
	move.w	#$c00,$dff106

LOGOWBLANYLAST:
	bsr.w	WBLAN

	bsr.w	SALITA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#18,VBCOUNTER
	blo.s	LOGOWBLANYLAST

ESCI:
	clr.l	VBCOUNTER

	lea	$dff000,a6	; stoppo la musica
	bsr.w	P61_End
	rts

******************************************************************************
;			ROUTINE CHE ASPETTA IL VBL
******************************************************************************

WBLAN:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00012b00,d0
	bne.s	WBLAN
WBLAN1:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00012b00,d0
	beq.s	WBLAN1
	rts

******************************************************************************
			; Interrupt level 3, VERTB...
******************************************************************************

	cnop	0,4

MyInt6c:
	BTST	#5,$DFF01F
	beq.s	NoIntVertb
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ST	FrameFlagCounter
	addq.l	#1,VBcounter
	MOVEM.L	(SP)+,D0-D7/A0-A6
NoIntVertb:
	BTST	#4,$DFF01F
	beq.s	NoIntCoper
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEM.L	(SP)+,D0-D7/A0-A6
NoIntCoper:
	MOVE.W	#$70,$DFF09C
	RTE

*****************************************************************************

FrameFlagCounter:
	dc.w	0


AspettaFrameFlag:
	SF	FrameFlagCounter
StoFlaNon:
	TST.B	FrameFlagCounter
	BEQ.B	StoFlaNon
	RTS

AspettVBL:
	cmp.b	#$40,$dff006
	bne.s	AspettVBL
AspettVBL2:
	cmp.b	#$40,$dff006
	beq.s	AspettVBL2
	rts

*******************************************************************************
;		ROUTINE CONVERSIONE PALETTE 24BIT SFERA
*******************************************************************************
	
READ24BIT:
	lea	PALETTETUNNEL,a0	; Indirizzo palette immagine in a0
	lea	COLP0+2,a1		; Indirizzo di partenza nibble alti
	lea	COLP0b+2,a2		; Indirizzo di partenza nibble bassi
	moveq	#7,d6			; 8 banchi di 32 colori
	
BANCHI:
	moveq	#31,d7			; 32 colori per banco
	moveq	#0,d0			; Azzeriamo d0,d2,d3
	moveq	#0,d2
	moveq	#0,d3
		
CONVERTI:
	move.b	3(a0),d2		; Bb in d2
	andi.b	#%00001111,d2		; nibble basso 0b
	move.b	2(a0),d3		; Gg in d3
	lsl.b	#4,d3			; 4 bit a sinistra per g0
	ori.b	d2,d3			; nibble 0b in d2 e g0 per gb in d3
	move.b	d3,1(a2)		; Copiamo il byte in copperlist
	move.b	1(a0),(a2)		; Rr in copperlist
	andi.b	#%00001111,(a2)		; nibble basso per 0r
;-------------------------------
	move.b	3(a0),d2		; Bb in d2
	lsr.b	#4,d2			; 4 bit a destra per 0b
	move.b	2(a0),d3		; Gg in d3		
	andi.b	#%11110000,d3		; nibble alto per g0
	ori.b	d2,d3			; 0B in d2 con G0 in d3 per gb in d3
	move.b	d3,1(a1)		; GB in copperlist
	move.b	1(a0),d2		; Rr in d2
	lsr.b	#4,d2			; destra di 4 bit per 0r
	move.b	d2,(a1)			; 0r in copperlist
	addq.w	#4,a0			; Prossimo colore palette sfera
	addq.w	#4,a1			; Prossimo registro colore nibble alti
	addq.w	#4,a2			; Prossimo registro colore nibble bassi
	dbra	d7,CONVERTI		; Ripetiamo il loop

	add.w	#(128+8),a1
	add.w	#(128+8),a2
	dbra	d6,BANCHI
	rts

*******************************************************************************
;		ROUTINE CHUNKY PIXEL MAPPING SFERA-TUNNEL
*******************************************************************************

MAPPING:
	lea	CHUNKYPIC,a0		; Indirizzo figura chunky in a0
	lea	CHUNKYPALETTE,a1	; Indirizzo palette figura Chunky in a1
	lea	PALETTETUNNEL,a2	; Indirizzo palette Tunnel in a2
	add.w	CHUNKYOFFSET,a0		; Aggiungiamo l` Offset
	moveq	#0,d0			; Puliamo d0
	move.b	#255,d0			; Numero loop: 256 pixel
	moveq	#0,d2			; Puliamo d2

MAPLOOP:
	clr.l	d1
	move.b	(a0)+,d1
	lsl.w	#2,d1
	add.l	a1,d1
	move.l	d1,a3
	move.l	(a3),(a2)+
	dbra	d0,MAPLOOP
	move.l	#0,PALETTETUNNEL
	rts

*******************************************************************************
;		ROUTINE CHUNKY PIXEL AGGIORNAMENTO TEXTURE SFERA
*******************************************************************************

ANIMAP:
	cmpi.w	#0,CHUNKYOFFSET		; Abbiamo raggiunto il margine inf?
	bne.s	Nonazzera		; Se no non azzera il flag direzione
	move.w	#2656,chunkyoffset
	rts

NONAZZERA:
	subi.w	#16,CHUNKYOFFSET	; +16 per riga precedente $f per rotaz!
	rts				

*******************************************************************************
;			ROUTINE DI RIMBALZO SFERA
*******************************************************************************

RIMBALZO:
	lea	BPLPOINTERS3,A1
	move.w	2(a1),d0
	swap	d0
	move.w	6(a1),d0
	addq.l	#4,RIMTABPOINT
	move.l	RIMTABPOINT(PC),a0
	cmp.l	#FINERIMBALZTAB-4,a0
	bne.s	NOBSTART2
	move.l	#RIMBALZTAB-4,RIMTABPOINT

NOBSTART2:
	move.l	(a0),d1
	sub.l	d1,d0
	lea	BPLPOINTERS3,a1
	moveq	#7,d1

POINTBP2:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#$2800,d0
	addq.w	#8,a1
	dbra	d1,POINTBP2
	rts

RIMTABPOINT:
	dc.l	RIMBALZTAB-4

RIMBALZTAB:
	dc.l	0,0,0,0,0,0,40,40,40,40,40,40,40,40,40
	dc.l	40,40,2*40,2*40
	dc.l	2*40,2*40,2*40,2*40,2*40
	dc.l	3*40,3*40,3*40,3*40,3*40,4*40,4*40,4*40,5*40,5*40
	dc.l	6*40,8*40
	dc.l	-8*40,-6*40,-5*40
	dc.l	-5*40,-4*40,-4*40,-4*40,-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40
	dc.l	-2*40,-2*40,-40,-40
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40,0,0,0,0,0
FINERIMBALZTAB:

*******************************************************************************
;		ROUTINE CONVERSIONE PALETTE 24BIT TUNNEL
*******************************************************************************
	
TUNNELREAD24BIT:
	lea	PALETTETUNNEL,a0	; Indirizzo palette immagine in a0
	lea	TUNNELCOLP0+2,a1	; Indirizzo di partenza nibble alti
	lea	TUNNELCOLP0b+2,a2	; Indirizzo di partenza nibble bassi
	moveq	#7,d6			; 8 banchi di 32 colori
	
TUNNELBANCHI:
	moveq	#31,d7			; 32 colori per banco
	moveq	#0,d0			; Azzeriamo d0,d2,d3
	moveq	#0,d2
	moveq	#0,d3
		
TUNNELCONVERTI:
	move.b	3(a0),d2		; Bb in d2
	andi.b	#%00001111,d2		; nibble basso 0b
	move.b	2(a0),d3		; Gg in d3
	lsl.b	#4,d3			; 4 bit a sinistra per g0
	ori.b	d2,d3			; nibble 0b in d2 e g0 per gb in d3
	move.b	d3,1(a2)		; Copiamo il byte in copperlist
	move.b	1(a0),(a2)		; Rr in copperlist
	andi.b	#%00001111,(a2)		; nibble basso per 0r
;-------------------------------
	move.b	3(a0),d2		; Bb in d2
	lsr.b	#4,d2			; 4 bit a destra per 0b
	move.b	2(a0),d3		; Gg in d3		
	andi.b	#%11110000,d3		; nibble alto per g0
	ori.b	d2,d3			; 0B in d2 con G0 in d3 per gb in d3
	move.b	d3,1(a1)		; GB in copperlist
	move.b	1(a0),d2		; Rr in d2
	lsr.b	#4,d2			; destra di 4 bit per 0r
	move.b	d2,(a1)			; 0r in copperlist
	addq.w	#4,a0			; Prossimo colore palette sfera
	addq.w	#4,a1			; Prossimo registro colore nibble alti
	addq.w	#4,a2			; Prossimo registro colore nibble bassi
	dbra	d7,TUNNELCONVERTI		; Ripetiamo il loop

	add.w	#(128+8),a1
	add.w	#(128+8),a2
	dbra	d6,TUNNELBANCHI
	rts

*******************************************************************************
;			ROUTINE DI ONDULAMENTO SCHERMO
*******************************************************************************

ONDULA:
	lea	CON1EFFETTO+8,a0
	lea	CON1EFFETTO,a1
	move	#128,d2
SCAMBIA:
	move.w	(A0),(A1)
	addq.w	#8,a0		
	addq.w	#8,a1		
	dbra	d2,SCAMBIA	

	move.w	CON1EFFETTO,ULTIMOVALORE
	rts			

VBcounter:
	dc.l	0
*******************************************************************************
;			ROUTINE DI FADE AGA
*******************************************************************************

MAINFADEINOUT:
	bsr.w	CALCOLAMETTICOL

	btst.b	#1,FLAGFADEINOUT
	bne.s	FADEOUT

FADEIN:
	addq.w	#3,MULTIPLIER
	cmp.w	#255,MULTIPLIER
	bne.s	NONFINITO
	bchg.b	#1,FLAGFADEINOUT

FADEOUT:
	subq.w	#3,MULTIPLIER
	bne.w	NONFINITO
	bchg.b	#1,FLAGFADEINOUT

NONFINITO:
	rts

FLAGFADEINOUT:
	dc.w	0

MULTIPLIER:
	dc.w	0

TEMPORANEO:
	dc.l	0

CALCOLAMETTICOL:
	lea	TEMPORANEO(pc),a0
	lea	LOGOCOLP0+2,a1
	lea	LOGOCOLP0B+2,a2
	lea	PALETTEPIC(pc),a3
	moveq	#8-1,d7

CONVERTIPALETTEBANK:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#32-1,d6

DALONGAREGISTRI:
	;rosso	

	move.l	(a3),d4
	andi.l	#%000011111111,d4
	mulu.w	MULTIPLIER(pc),d4
	asr.w	#8,d4
	andi.l	#%000011111111,d4
	move.l	d4,d5

	;verde

	move.l	(a3),d4
	andi.l	#%1111111100000000,d4
	lsr.l	#8,d4
	mulu.w	MULTIPLIER(pc),d4
	asr.w	#8,d4
	andi.l	#%0000000011111111,d4
	lsl.l	#8,d4
	or.l	d4,d5

	;blu

	move.l	(a3)+,d4
	andi.l	#%111111110000000000000000,d4
	lsr.l	#8,d4
	lsr.l	#8,d4
	mulu.w	MULTIPLIER(pc),d4
	asr.w	#8,d4
	andi.l	#%0000000011111111,d4
	lsl.l	#8,d4
	lsl.l	#8,d4
	or.l	d4,d5
	move.l	d5,(a0)

	move.b	1(a0),(a2)
	andi.b	#%00001111,(a2)
	move.b	2(a0),d2
	lsl.b	#4,d2
	move.b	3(a0),d3
	andi.b	#%00001111,d3
	or.b	d2,d3
	move.b	d3,1(a2)

	move.b	1(A0),d0
	andi.b	#%11110000,d0
	lsr.b	#4,d0
	move.b	d0,(a1)
	move.b	2(a0),d2
	andi.b	#%11110000,d2
	move.b	3(a0),d3
	andi.b	#%11110000,d3
	lsr.b	#4,d3
	ori.b	d2,d3
	move.b	d3,1(a1)
	addq.w	#4,a1
	addq.w	#4,a2
	dbra	d6,DALONGAREGISTRI

	add.w	#(128+8),a1
	add.w	#(128+8),a2

	dbra	d7,CONVERTIPALETTEBANK
	rts

PALETTEPIC:
	dc.l	$00000000,$00ffffff,$00f3f7f7,$00e7ebeb,$00dfdfdf,$00d3d3d7
	dc.l	$00cbcbcb,$00bfbfc3,$00b3b7b7,$00ababaf,$00a3a3a3,$00979b9b
	dc.l	$008f8f92,$00878787,$007f7f89,$00737777,$006b6f6f,$00636767
	dc.l	$005b5f5f,$00535757,$004b4b4f,$00434747,$003f3f3f,$00373737
	dc.l	$002f2f33,$0027272b,$00232323,$001b1b1f,$00131717,$000f0f0f
	dc.l	$00070b0b,$00000007,$0063a7d7,$00578fb7,$0047779f,$00436797
	dc.l	$003b578b,$00374b7f,$002f3f73,$002b3367,$0023275b,$001f1f4f
	dc.l	$001f1b43,$001b1337,$00170f2b,$00130b1f,$000b070f,$00000000
	dc.l	$00fff089,$00f1d780,$00e5c078,$00d8aa6f,$00cc9367,$00bf805f
	dc.l	$00b36f57,$00a65c50,$009a4c48,$008d4147,$00813a46,$00753445
	dc.l	$00692d44,$005c273f,$0050213c,$00431b36,$0063531f,$0057471b
	dc.l	$004f3f17,$004b3b17,$00433313,$003f2f13,$00372b0f,$0033270f
	dc.l	$002b1f0b,$00271b0b,$001f1707,$001b1307,$009a3182,$009b386c
	dc.l	$009c3f57,$009f4647,$0097a347,$008ba347,$007fa347,$0077a747
	dc.l	$006ba747,$0063a747,$00bf9b3b,$00c39337,$00cb8b2f,$00d37f2b
	dc.l	$00db7327,$00e35f1f,$00eb4f17,$00ef3713,$00f71f0b,$00ff0000
	dc.l	$00ff0000,$00ef0000,$00df0000,$00cf0000,$00bb0000,$00ab0000
	dc.l	$009b0000,$008b0000,$007b0000,$006b0000,$005b0000,$00470000
	dc.l	$00370000,$00270000,$00170000,$00070000,$00ff6333,$00eb6337
	dc.l	$00d75f3b,$00c35f3f,$00af5b3f,$009b573f,$00874f3b,$00774737
	dc.l	$00ebcf00,$00d7bb00,$00c7a700,$00a38700,$00876f00,$006b5300
	dc.l	$00473300,$00231300,$00fbffff,$00cbdff3,$009fc3e3,$0077abd3
	dc.l	$005393c7,$003383b7,$001b6fab,$00005f9b,$00005786,$00004b77
	dc.l	$00004367,$00003757,$00002f47,$00002737,$00001b27,$00000f17
	dc.l	$00ffefe7,$00efd7c7,$00dfbfaf,$00d3a797,$00c3977f,$00b3836b
	dc.l	$00a37357,$00936347,$00835337,$0077432b,$0067371f,$00572b17
	dc.l	$0047230f,$00371b07,$00270f00,$00170b00,$00e7d7b7,$00dfcdb1
	dc.l	$00d8c6ac,$00d2bfa7,$00ccb8a3,$00c6b19f,$00bfaa9b,$00b9a496
	dc.l	$00b39d91,$00ac978c,$00a69188,$00a08b84,$009a8580,$00937f7b
	dc.l	$008d7976,$00877472,$00806d6c,$007b6867,$00756363,$006e5d5e
	dc.l	$0068585a,$00625356,$005c4f51,$0055494c,$004f4447,$00493f42
	dc.l	$0042393c,$003c3437,$00362f32,$00302a2c,$00292426,$00231f21
	dc.l	$00ffffff,$00ffdbdb,$00ffb7b7,$00ff9393,$00ff6f6f,$00ff4b4b
	dc.l	$00ff2727,$00ff0000,$007f83af,$0073779f,$006b6b93,$005b5b7b
	dc.l	$00474761,$0037374b,$00272733,$0017171f,$0000ff00,$0000ff00
	dc.l	$0000ff00,$0000ff00,$0000ff00,$0000ff00,$0000ff00,$0000ff00
	dc.l	$0000ff00,$0037374b,$002f2f43,$002b2b3b,$00272733,$001f1f2b
	dc.l	$001b1b23,$0017171f,$00ffffff,$00dbefe3,$00bfdbc7,$00a3cbaf
	dc.l	$0087bb9b,$006fab83,$005b9b6f,$00478b5f,$00377b4f,$0027673b
	dc.l	$001b572b,$000f471b,$0007370f,$00002707,$00001700,$00000700
	dc.l	$0000ff00,$0000ff00,$0000ff00,$0000ff00,$0000ff00,$0000ff00
	dc.l	$0000ff00,$0000ff00,$0000ff00,$0000ff00,$0000ff00,$0000ff00
	dc.l	$0000ff00,$0000ff00,$0000ff00,$00ffffff
	cnop	0,8

*******************************************************************************
;			SALITA DEL LOGO DEFY 7
*******************************************************************************

SALITA:
	lea	SALEBPLPOINTERS,A1
	move.w	2(a1),d0
	swap	d0
	move.w	6(a1),d0
	addq.l	#4,RIMTABPOINTSALITA
	move.l	RIMTABPOINTSALITA(PC),a0
	cmp.l	#FINERIMBALZTABSALITA-4,a0
	bne.s	NOBSALITA
	move.l	#RIMBALZTABSALITA-4,RIMTABPOINTSALITA

NOBSALITA:
	move.l	(a0),d1
	sub.l	d1,d0
	lea	SALEBPLPOINTERS,a1
	moveq	#4-1,d1

POINTBP2SALITA:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#40*572,d0
	addq.w	#8,a1
	dbra	d1,POINTBP2SALITA
	rts


RIMTABPOINTSALITA:
	dc.l	RIMBALZTABSALITA-4

RIMBALZTABSALITA:
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40			; acceleriamo
	dc.l	-4*40						; acceleriamo
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40			; acceleriamo
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40			; acceleriamo
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40			; deceleriamo
	dc.l	-2*40,-2*40,-2*40,-40
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40,0,0,0,0,0	; in cima
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FINERIMBALZTABSALITA:

;************************************************************************
;*	Stampa un carattere alla volta su schermo largo 320 pixel	*
;************************************************************************

PRINTCARATTERE:
	move.l	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	moveq	#0,D2		; Pulisci d2
	move.b	(A0)+,D2	; Prossimo carattere in d2
	cmp.b	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	tst.b	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	add.l	#40*7,PuntaBITPLANE
	addq.l	#1,PuntaTesto
	move.b	(a0)+,d2

NonFineRiga:
	sub.b	#$20,D2
	mulu.w	#8,D2
	move.l	D2,A2
	add.l	#FONT,A2
	move.l	PuntaBITPLANE(PC),A3

	move.b	(A2)+,(A3)
	move.b	(A2)+,40(A3)
	move.b	(A2)+,40*2(A3)
	move.b	(A2)+,40*3(A3)
	move.b	(A2)+,40*4(A3)
	move.b	(A2)+,40*5(A3)
	move.b	(A2)+,40*6(A3)
	move.b	(A2)+,40*7(A3)

	addq.l	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	addq.l	#1,PuntaTesto	; prossimo carattere da stampare

FINETESTO:
	rts

PUNTATESTO:
	dc.l	TESTO

PUNTABITPLANE:
	dc.l	CREDITS

;	$00 per "fine linea" - $FF per "fine testo"

TESTO:
	dc.b	"                                        ",0
	dc.b	"             INTRO CREDITS:             ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"       1H CODE      MODEM/X-ZONE        ",0
	dc.b	"                                        ",0
	dc.b	"       GRAPHICS     LANCH/X-ZONE        ",0
	dc.b	"                                        ",0
	dc.b	"       MUSIC         FBY/X-ZONE         ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"      WANNA CONTACT US?  NO PROBLEM     ",0
	dc.b	"                                        ",0
	dc.b	"        PLASTIC DREAM BBS 24H/DAY       ",0
	dc.b	"                                        ",0
	dc.b	"             +39 41/5732014             ",0
	dc.b	"                                        ",$FF
	even

*******************************************************************************
;				ROUTINE MUSICALE
*******************************************************************************

fade  = 0
jump = 0
system = 1
CIA = 1
exec = 1
opt020 = 1
use = $977f

	include	"play.s"	; La routine vera e propria!

	Section	modulozzo,DATA

P61_DATA:
	incbin	"P61.defy-mag"	; Compresso

	Section	smp,BSS_C

SAMPLES:
	ds.b	61944	; lunghezza riportata dal p61con
	
*******************************************************************************
;			COPPERLIST 1,2,3,ETC.
*******************************************************************************

	SECTION partedicopper,DATA_C
COPLIST:
	dc.w	$8E,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$0038
	dc.w	$94,$00d0
	dc.w	$100,%0000001000010001
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0
	dc.w	$10a,0

	dc.w	$1fc,0

BPLPOINTERS:
	dc.w $e0,0,$e2,0
	dc.w $e4,0,$e6,0
	dc.w $e8,0,$ea,0
	dc.w $ec,0,$ee,0
	dc.w $f0,0,$f2,0
	dc.w $f4,0,$f6,0
	dc.w $f8,0,$fA,0
	dc.w $fC,0,$fE,0

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
LOGOCOLP0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
LOGOCOLP0B:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2C00	; SELEZIONA PALETTE 1 (32-63), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2E00	; SELEZIONA PALETTE 1 (32-63), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4C00	; SELEZIONA PALETTE 2 (64-95), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4E00	; SELEZIONA PALETTE 2 (64-95), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6C00	; SELEZIONA PALETTE 3 (96-127), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6E00	; SELEZIONA PALETTE 3 (96-127), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8C00	; SELEZIONA PALETTE 4 (128-159), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8E00	; SELEZIONA PALETTE 4 (128-159), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AC00	; SELEZIONA PALETTE 5 (160-191), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AE00	; SELEZIONA PALETTE 5 (160-191), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CC00	; SELEZIONA PALETTE 6 (192-223), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CE00	; SELEZIONA PALETTE 6 (192-223), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EE00	; SELEZIONA PALETTE 7 (224-255), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	dc.w	$ffff,$fffe

SALECOPLIST:
	dc.w	$8E,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$0038
	dc.w	$94,$00d0
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0
	dc.w	$10a,0

SALEBPLPOINTERS:
	dc.w	$e0,$0,$e2,$0
	dc.w	$e4,$0,$e6,$0
	dc.w	$e8,$0,$ea,$0
	dc.w	$ec,$0,$ee,$0

	dc.w	$100,%0100001000000000

	dc.w	$106,$c00
	dc.w	$180,$000,$182,$9a9,$184,$125,$186,$114,$188,$236,$18a,$246
	dc.w	$18c,$476,$18e,$358
	dc.w	$190,$369,$192,$687,$194,$48a,$196,$49b,$198,$5bc,$19a,$6ed
	dc.w	$19c,$310,$19e,$cdc
	dc.w	$106,$e00
	dc.w	$180,$000,$182,$4b2,$184,$c43,$186,$ae3,$188,$312,$18a,$d65
	dc.w	$18c,$a1c,$18e,$120
	dc.w	$190,$9a1,$192,$375,$194,$7fb,$196,$cb3,$198,$9e9,$19a,$b89
	dc.w	$19c,$ace,$19e,$f19

	dc.w	$FFFF,$FFFE	; Fine della copperlist

COPLIST2:
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$0038
	dc.w	$94,$00d0
	dc.w	$102,$0
	dc.w	$104,$0
	dc.w	$108,$0
	dc.w	$10a,$0	

BPLPOINTERS2:
	dc.w	$e0,$0,$e2,$0
	dc.w	$e4,$0,$e6,$0
	dc.w	$e8,$0,$ea,$0
	dc.w	$ec,$0,$ee,$0

	dc.w	$100,%0100001000000000

	dc.w	$106,$c00
	dc.w	$180,$000,$182,$9a9,$184,$125,$186,$114,$188,$236,$18a,$246
	dc.w	$18c,$476,$18e,$358
	dc.w	$190,$369,$192,$687,$194,$48a,$196,$49b,$198,$5bc,$19a,$6ed
	dc.w	$19c,$310,$19e,$cdc
	dc.w	$106,$e00
	dc.w	$180,$000,$182,$4b2,$184,$c43,$186,$ae3,$188,$312,$18a,$d65
	dc.w	$18c,$a1c,$18e,$120
	dc.w	$190,$9a1,$192,$375,$194,$7fb,$196,$cb3,$198,$9e9,$19a,$b89
	dc.w	$19c,$ace,$19e,$f19

FinePic1:
	dc.w	$6607,$fffe

FINECOP:
	dc.w	$FFFF,$FFFE	; Fine della copperlist1

COPLIST3:
	dc.w	$6607,$fffe

	dc.w	$100,%0000001000010001
	dc.w	$8e,$2c91	; DiwStrt
	dc.w	$90,$2cb1	; DiwStop
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

BPLPOINTERS3:
	dc.w	$e0,$0,$e2,$0
	dc.w	$e4,$0,$e6,$0
	dc.w	$e8,$0,$ea,$0
	dc.w	$ec,$0,$ee,$0
	dc.w	$f0,$0,$f2,$0
	dc.w	$f4,$0,$f6,$0
	dc.w	$f8,$0,$fa,$0
	dc.w	$fc,$0,$fe,$0

	dc.w	$106,$c00
COLP0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$e00
COLP0B:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$2C00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$2E00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$4C00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$4E00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$6C00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$6E00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$8C00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$8E00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$AC00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$AE00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$CC00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$CE00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$EC00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0
	DC.W	$106,$EE00
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	dc.w	$1fc,0		; Burst mode azzerato

	; Dithering...	
	
	dc.w	$7007,$fffe,$102,$11
	dc.w	$7107,$fffe,$102,$00
	dc.w	$7207,$fffe,$102,$11
	dc.w	$7307,$fffe,$102,$00
	dc.w	$7407,$fffe,$102,$11
	dc.w	$7507,$fffe,$102,$00
	dc.w	$7607,$fffe,$102,$11
	dc.w	$7707,$fffe,$102,$00
	dc.w	$7807,$fffe,$102,$11
	dc.w	$7907,$fffe,$102,$00
	dc.w	$7a07,$fffe,$102,$11
	dc.w	$7b07,$fffe,$102,$00
	dc.w	$7c07,$fffe,$102,$11
	dc.w	$7d07,$fffe,$102,$00
	dc.w	$7e07,$fffe,$102,$11
	dc.w	$7f07,$fffe,$102,$00
	dc.w	$8007,$fffe,$102,$11
	dc.w	$8107,$fffe,$102,$00
	dc.w	$8207,$fffe,$102,$11
	dc.w	$8307,$fffe,$102,$00
	dc.w	$8407,$fffe,$102,$11
	dc.w	$8507,$fffe,$102,$00
	dc.w	$8607,$fffe,$102,$11
	dc.w	$8707,$fffe,$102,$00
	dc.w	$8807,$fffe,$102,$11
	dc.w	$8907,$fffe,$102,$00
	dc.w	$8a07,$fffe,$102,$11
	dc.w	$8b07,$fffe,$102,$00
	dc.w	$8c07,$fffe,$102,$11
	dc.w	$8d07,$fffe,$102,$00
	dc.w	$8e07,$fffe,$102,$11
	dc.w	$8f07,$fffe,$102,$00
	dc.w	$9007,$fffe,$102,$11
	dc.w	$9107,$fffe,$102,$00
	dc.w	$9207,$fffe,$102,$11
	dc.w	$9307,$fffe,$102,$00
	dc.w	$9407,$fffe,$102,$11
	dc.w	$9507,$fffe,$102,$00
	dc.w	$9607,$fffe,$102,$11
	dc.w	$9707,$fffe,$102,$00
	dc.w	$9807,$fffe,$102,$11
	dc.w	$9907,$fffe,$102,$00
	dc.w	$9a07,$fffe,$102,$11
	dc.w	$9b07,$fffe,$102,$00
	dc.w	$9c07,$fffe,$102,$11
	dc.w	$9d07,$fffe,$102,$00
	dc.w	$9e07,$fffe,$102,$11
	dc.w	$9f07,$fffe,$102,$00
	dc.w	$a007,$fffe,$102,$11
	dc.w	$a107,$fffe,$102,$00
	dc.w	$a207,$fffe,$102,$11
	dc.w	$a307,$fffe,$102,$00
	dc.w	$a407,$fffe,$102,$11
	dc.w	$a507,$fffe,$102,$00
	dc.w	$a607,$fffe,$102,$11
	dc.w	$a707,$fffe,$102,$00
	dc.w	$a807,$fffe,$102,$11
	dc.w	$a907,$fffe,$102,$00
	dc.w	$aa07,$fffe,$102,$11
	dc.w	$ab07,$fffe,$102,$00
	dc.w	$ac07,$fffe,$102,$11
	dc.w	$ad07,$fffe,$102,$00
	dc.w	$ae07,$fffe,$102,$11
	dc.w	$af07,$fffe,$102,$00
	dc.w	$b007,$fffe,$102,$11
	dc.w	$b107,$fffe,$102,$00
	dc.w	$b207,$fffe,$102,$11
	dc.w	$b307,$fffe,$102,$00
	dc.w	$b407,$fffe,$102,$11
	dc.w	$b507,$fffe,$102,$00
	dc.w	$b607,$fffe,$102,$11
	dc.w	$b707,$fffe,$102,$00
	dc.w	$b807,$fffe,$102,$11
	dc.w	$b907,$fffe,$102,$00
	dc.w	$ba07,$fffe,$102,$11
	dc.w	$bb07,$fffe,$102,$00
	dc.w	$bc07,$fffe,$102,$11
	dc.w	$bd07,$fffe,$102,$00
	dc.w	$be07,$fffe,$102,$11
	dc.w	$bf07,$fffe,$102,$00
	dc.w	$c007,$fffe,$102,$11
	dc.w	$c107,$fffe,$102,$00
	dc.w	$c207,$fffe,$102,$11
	dc.w	$c307,$fffe,$102,$00
	dc.w	$c407,$fffe,$102,$11
	dc.w	$c507,$fffe,$102,$00
	dc.w	$c607,$fffe,$102,$11
	dc.w	$c707,$fffe,$102,$00
	dc.w	$c807,$fffe,$102,$11
	dc.w	$c907,$fffe,$102,$00
	dc.w	$ca07,$fffe,$102,$11
	dc.w	$cb07,$fffe,$102,$00
	dc.w	$cc07,$fffe,$102,$11
	dc.w	$cd07,$fffe,$102,$00
	dc.w	$ce07,$fffe,$102,$11
	dc.w	$cf07,$fffe,$102,$00
	dc.w	$d007,$fffe,$102,$11
	dc.w	$d107,$fffe,$102,$00
	dc.w	$d207,$fffe,$102,$11
	dc.w	$d307,$fffe,$102,$00
	dc.w	$d407,$fffe,$102,$11
	dc.w	$d507,$fffe,$102,$00
	dc.w	$d607,$fffe,$102,$11
	dc.w	$d707,$fffe,$102,$00
	dc.w	$d807,$fffe,$102,$11
	dc.w	$d907,$fffe,$102,$00
	dc.w	$da07,$fffe,$102,$11
	dc.w	$db07,$fffe,$102,$00
	dc.w	$dc07,$fffe,$102,$11
	dc.w	$dd07,$fffe,$102,$00
	dc.w	$de07,$fffe,$102,$11
	dc.w	$df07,$fffe,$102,$00
	dc.w	$e007,$fffe,$102,$11
	dc.w	$e107,$fffe,$102,$00
	dc.w	$e207,$fffe,$102,$11
	dc.w	$e307,$fffe,$102,$00
	dc.w	$e407,$fffe,$102,$11
	dc.w	$e507,$fffe,$102,$00
	dc.w	$e607,$fffe,$102,$11
	dc.w	$e707,$fffe,$102,$00
	dc.w	$108,40
	dc.w	$10a,40
	dc.w	$e807,$fffe,$102,$11
	dc.w	$108,-40*2
	dc.w	$10a,-40*2
	dc.w	$e907,$fffe,$102,$00
	dc.w	$ea07,$fffe,$102,$11
	dc.w	$eb07,$fffe,$102,$00
	dc.w	$ec07,$fffe,$102,$11
	dc.w	$ed07,$fffe,$102,$00
	dc.w	$ee07,$fffe,$102,$11
	dc.w	$ef07,$fffe,$102,$00
	dc.w	$f007,$fffe,$102,$11
	dc.w	$f107,$fffe,$102,$00
	dc.w	$f207,$fffe,$102,$11
	dc.w	$f307,$fffe,$102,$00
	dc.w	$f407,$fffe,$102,$11
	dc.w	$f507,$fffe,$102,$00
	dc.w	$f607,$fffe,$102,$11
	dc.w	$f707,$fffe,$102,$00
	dc.w	$f807,$fffe,$102,$11
	dc.w	$f907,$fffe,$102,$00
	dc.w	$fa07,$fffe,$102,$11
	dc.w	$fb07,$fffe,$102,$00
	dc.w	$fc07,$fffe,$102,$11
	dc.w	$fd07,$fffe,$102,$00
	dc.w	$fe07,$fffe,$102,$11
	dc.w	$ff07,$fffe,$102,$00
	dc.w	$0007,$fffe,$102,$11
	dc.w	$0107,$fffe,$102,$00
	dc.w	$0207,$fffe,$102,$11
	dc.w	$0307,$fffe,$102,$00
	dc.w	$0407,$fffe,$102,$11
	dc.w	$0507,$fffe,$102,$00
	dc.w	$0607,$fffe,$102,$11
	dc.w	$0707,$fffe,$102,$00
	dc.w	$0807,$fffe,$102,$11
	dc.w	$0907,$fffe,$102,$00
	dc.w	$0a07,$fffe,$102,$11
	dc.w	$0b07,$fffe,$102,$00
	dc.w	$0c07,$fffe,$102,$11
	dc.w	$0d07,$fffe,$102,$00
	dc.w	$0e07,$fffe,$102,$11
	dc.w	$0f07,$fffe,$102,$00
	dc.w	$1007,$fffe,$102,$11
	dc.w	$1107,$fffe,$102,$00
	dc.w	$1207,$fffe,$102,$11
	dc.w	$1307,$fffe,$102,$00
	dc.w	$1407,$fffe,$102,$11
	dc.w	$1507,$fffe,$102,$00
	dc.w	$1607,$fffe,$102,$11
	dc.w	$1707,$fffe,$102,$00
	dc.w	$1807,$fffe,$102,$11
	dc.w	$1907,$fffe,$102,$00
	dc.w	$1a07,$fffe,$102,$11
	dc.w	$1b07,$fffe,$102,$00
	dc.w	$1c07,$fffe,$102,$11
	dc.w	$1d07,$fffe,$102,$00
	dc.w	$1e07,$fffe,$102,$11
	dc.w	$1f07,$fffe,$102,$00
	dc.w	$2007,$fffe,$102,$11
	dc.w	$2107,$fffe,$102,$00
	dc.w	$2207,$fffe,$102,$11
	dc.w	$2307,$fffe,$102,$00
	dc.w	$2407,$fffe,$102,$11
	dc.w	$2507,$fffe,$102,$00
	dc.w	$2607,$fffe,$102,$11
	dc.w	$2707,$fffe,$102,$00
	dc.w	$2807,$fffe,$102,$11
	dc.w	$2907,$fffe,$102,$00
	dc.w	$2a07,$fffe,$102,$11
	dc.w	$2b07,$fffe,$102,$00
	dc.w	$2c07,$fffe,$102,$11
	dc.w	$2d07,$fffe,$102,$00
	dc.w	$2e07,$fffe,$102,$11
	dc.w	$2f07,$fffe,$102,$00
	
	dc.w	$ffff,$fffe

COPVUOTO:
	dc.w	$6607,$fffe

BPLVUOTO:
	dc.w $e0,$0,$e2,$0

	dc.w	$100,%0001001000000000
	dc.w	$8e,$2c91	; DiwStrt
	dc.w	$90,$2cb1	; DiwStop
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

COPCOLORS:
	DC.W	$106,$c00
	dc.w	$180,$0,$182,$fff
	DC.W	$106,$e00
	dc.w	$180,$0,$182,$fff

	dc.w	$ffff,$fffe

COPLIST5:
	dc.w	$6607,$fffe

	dc.w	$100,%0000001000010001
	dc.w	$8e,$2c91	; DiwStrt
	dc.w	$90,$2cb1	; DiwStop
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

BPLPOINTERS5:
	dc.w	$e0,$0,$e2,$0
	dc.w	$e4,$0,$e6,$0
	dc.w	$e8,$0,$ea,$0
	dc.w	$ec,$0,$ee,$0
	dc.w	$f0,$0,$f2,$0
	dc.w	$f4,$0,$f6,$0
	dc.w	$f8,$0,$fa,$0
	dc.w	$fc,$0,$fe,$0

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
TUNNELCOLP0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
TUNNELCOLP0B:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2C00	; SELEZIONA PALETTE 1 (32-63), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2E00	; SELEZIONA PALETTE 1 (32-63), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4C00	; SELEZIONA PALETTE 2 (64-95), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4E00	; SELEZIONA PALETTE 2 (64-95), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6C00	; SELEZIONA PALETTE 3 (96-127), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6E00	; SELEZIONA PALETTE 3 (96-127), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8C00	; SELEZIONA PALETTE 4 (128-159), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8E00	; SELEZIONA PALETTE 4 (128-159), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AC00	; SELEZIONA PALETTE 5 (160-191), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AE00	; SELEZIONA PALETTE 5 (160-191), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CC00	; SELEZIONA PALETTE 6 (192-223), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CE00	; SELEZIONA PALETTE 6 (192-223), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EE00	; SELEZIONA PALETTE 7 (224-255), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	dc.w	$1fc,0		; Burst mode azzerato
	dc.w	$102
CON1EFFETTO:
	dc.w	0
	dc.w	$3007,$fffe,$102,$11
	dc.w	$3207,$fffe,$102,$11
	dc.w	$3407,$fffe,$102,$11
	dc.w	$3607,$fffe,$102,$11
	dc.w	$3807,$fffe,$102,$22
	dc.w	$3a07,$fffe,$102,$22
	dc.w	$3c07,$fffe,$102,$22
	dc.w	$3e07,$fffe,$102,$22
	dc.w	$4007,$fffe,$102,$33
	dc.w	$4207,$fffe,$102,$33
	dc.w	$4407,$fffe,$102,$33
	dc.w	$4607,$fffe,$102,$33
	dc.w	$4807,$fffe,$102,$44
	dc.w	$4a07,$fffe,$102,$44
	dc.w	$4c07,$fffe,$102,$44
	dc.w	$4e07,$fffe,$102,$44
	dc.w	$5007,$fffe,$102,$55
	dc.w	$5207,$fffe,$102,$55
	dc.w	$5407,$fffe,$102,$55
	dc.w	$5607,$fffe,$102,$55
	dc.w	$5807,$fffe,$102,$66
	dc.w	$5a07,$fffe,$102,$66
	dc.w	$5c07,$fffe,$102,$66
	dc.w	$5e07,$fffe,$102,$66
	dc.w	$6007,$fffe,$102,$77
	dc.w	$6207,$fffe,$102,$77
	dc.w	$6407,$fffe,$102,$77
	dc.w	$6607,$fffe,$102,$77
	dc.w	$6807,$fffe,$102,$88
	dc.w	$6a07,$fffe,$102,$88
	dc.w	$6c07,$fffe,$102,$88
	dc.w	$6e07,$fffe,$102,$88
	dc.w	$7007,$fffe,$102,$99
	dc.w	$7207,$fffe,$102,$99
	dc.w	$7407,$fffe,$102,$99
	dc.w	$7607,$fffe,$102,$99
	dc.w	$7807,$fffe,$102,$aa
	dc.w	$7a07,$fffe,$102,$aa
	dc.w	$7c07,$fffe,$102,$aa
	dc.w	$7e07,$fffe,$102,$aa
	dc.w	$8007,$fffe,$102,$bb
	dc.w	$8207,$fffe,$102,$bb
	dc.w	$8407,$fffe,$102,$bb
	dc.w	$8607,$fffe,$102,$bb
	dc.w	$8807,$fffe,$102,$cc
	dc.w	$8a07,$fffe,$102,$cc
	dc.w	$8c07,$fffe,$102,$cc
	dc.w	$8e07,$fffe,$102,$cc
	dc.w	$9007,$fffe,$102,$dd
	dc.w	$9207,$fffe,$102,$dd
	dc.w	$9407,$fffe,$102,$dd
	dc.w	$9607,$fffe,$102,$dd
	dc.w	$9807,$fffe,$102,$ee
	dc.w	$9a07,$fffe,$102,$ee
	dc.w	$9c07,$fffe,$102,$ee
	dc.w	$9e07,$fffe,$102,$ee
	dc.w	$a007,$fffe,$102,$ff
	dc.w	$a207,$fffe,$102,$ff
	dc.w	$a407,$fffe,$102,$ff
	dc.w	$a607,$fffe,$102,$ff
	dc.w	$a807,$fffe,$102,$ff
	dc.w	$aa07,$fffe,$102,$ff
	dc.w	$ac07,$fffe,$102,$ff
	dc.w	$ae07,$fffe,$102,$ff
	dc.w	$b007,$fffe,$102,$ff
	dc.w	$b207,$fffe,$102,$ff
	dc.w	$b407,$fffe,$102,$ff
	dc.w	$b607,$fffe,$102,$ff
	dc.w	$b807,$fffe,$102,$ff
	dc.w	$ba07,$fffe,$102,$ee
	dc.w	$bc07,$fffe,$102,$ee
	dc.w	$be07,$fffe,$102,$ee
	dc.w	$c007,$fffe,$102,$ee
	dc.w	$c207,$fffe,$102,$dd
	dc.w	$c407,$fffe,$102,$dd
	dc.w	$c607,$fffe,$102,$dd
	dc.w	$c807,$fffe,$102,$dd
	dc.w	$ca07,$fffe,$102,$cc
	dc.w	$cc07,$fffe,$102,$cc
	dc.w	$ce07,$fffe,$102,$cc
	dc.w	$d007,$fffe,$102,$cc
	dc.w	$d207,$fffe,$102,$bb
	dc.w	$d407,$fffe,$102,$bb
	dc.w	$d607,$fffe,$102,$bb
	dc.w	$d807,$fffe,$102,$bb
	dc.w	$da07,$fffe,$102,$aa
	dc.w	$dc07,$fffe,$102,$aa
	dc.w	$de07,$fffe,$102,$aa
	dc.w	$e007,$fffe,$102,$aa
	dc.w	$e207,$fffe,$102,$99
	dc.w	$e407,$fffe,$102,$99
	dc.w	$e607,$fffe,$102,$99
	dc.w	$e807,$fffe,$102,$99
	dc.w	$ea07,$fffe,$102,$88
	dc.w	$ec07,$fffe,$102,$88
	dc.w	$ee07,$fffe,$102,$88
	dc.w	$f007,$fffe,$102,$88
	dc.w	$f207,$fffe,$102,$77
	dc.w	$f407,$fffe,$102,$77
	dc.w	$f607,$fffe,$102,$77
	dc.w	$f807,$fffe,$102,$77
	dc.w	$fc07,$fffe,$102,$66
	dc.w	$fe07,$fffe,$102,$66
	dc.w	$ff07,$fffe,$102,$66
	dc.w	$0207,$fffe,$102,$66
	dc.w	$0407,$fffe,$102,$55
	dc.w	$0607,$fffe,$102,$55
	dc.w	$0807,$fffe,$102,$55
	dc.w	$0c07,$fffe,$102,$55
	dc.w	$0e07,$fffe,$102,$44
	dc.w	$1207,$fffe,$102,$44
	dc.w	$1407,$fffe,$102,$44
	dc.w	$1607,$fffe,$102,$44
	dc.w	$1807,$fffe,$102,$33
	dc.w	$1a07,$fffe,$102,$33
	dc.w	$1c07,$fffe,$102,$33
	dc.w	$1e07,$fffe,$102,$33
	dc.w	$2207,$fffe,$102,$22
	dc.w	$2407,$fffe,$102,$22
	dc.w	$2607,$fffe,$102,$22
	dc.w	$2807,$fffe,$102,$22
	dc.w	$2a07,$fffe,$102,$11
	dc.w	$2c07,$fffe,$102,$11
	dc.w	$2e07,$fffe,$102,$11
	dc.w	$3207,$fffe,$102,$11
	dc.w	$3407,$fffe,$102,$11
	dc.w	$3607,$fffe,$102,$11
	dc.w	$e407,$fffe,$102

ULTIMOVALORE:
	dc.w	0

	dc.w	$ffff,$fffe

CHUNKYOFFSET:
	dc.w	2656

PALETTETUNNEL:
		dc.l	$00000000,$00A0A0A0,$0000AA00,$0000AAAA
		dc.l	$00AA0000,$00AA00AA,$00AA5500,$00AAAAAA
		dc.l	$00555555,$005555FF,$0055FF55,$0055FFFF
		dc.l	$00FF5555,$00FF55FF,$00FFFF55,$00FFFFFF
		dc.l	$00EFEFEF,$00DFDFDF,$00D3D3D3,$00C3C3C3
		dc.l	$00B7B7B7,$00ABABAB,$009B9B9B,$008F8F8F
		dc.l	$007F7F7F,$00737373,$00676767,$00575757
		dc.l	$004B4B4B,$003B3B3B,$002F2F2F,$00232323
		dc.l	$00FF0000,$00EF0000,$00E30000,$00D70000
		dc.l	$00CB0000,$00BF0000,$00B30000,$00A70000
		dc.l	$009B0000,$008B0000,$007F0000,$00730000
		dc.l	$00670000,$005B0000,$004F0000,$00400000
		dc.l	$00FFDADA,$00FFBABA,$00FF9F9F,$00FF7F7F
		dc.l	$00FF5F5F,$00FF4040,$00FF2020,$00FF0000
		dc.l	$00FCA85C,$00FC9840,$00FC8820,$00FC7800
		dc.l	$00E46C00,$00CC6000,$00B45400,$009C4C00
		dc.l	$00FCFCD8,$00FCFCB8,$00FCFC9C,$00FCFC7C
		dc.l	$00FCF85C,$00FCF440,$00FCF420,$00FCF400
		dc.l	$00E4D800,$00CCC400,$00B4AC00,$009C9C00
		dc.l	$00848400,$00706C00,$00585400,$00404000
		dc.l	$00D0FC5C,$00C4FC40,$00B4FC20,$00A0FC00
		dc.l	$0090E400,$0080CC00,$0074B400,$00609C00
		dc.l	$00D8FCD8,$00BCFCB8,$009CFC9C,$0080FC7C
		dc.l	$0060FC5C,$0040FC40,$0020FC20,$0000FC00
		dc.l	$0000FF00,$0000EF00,$0000E300,$0000D700
		dc.l	$0007CB00,$0007BF00,$0007B300,$0007A700
		dc.l	$00079B00,$00078B00,$00077F00,$00077300
		dc.l	$00076700,$00075B00,$00074F00,$00044000
		dc.l	$00DAFFFF,$00B8FCFC,$009CFCFC,$007CFCF8
		dc.l	$005CFCFC,$0040FCFC,$0020FCFC,$0000FCFC
		dc.l	$0000E4E4,$0000CCCC,$0000B4B4,$00009C9C
		dc.l	$00008484,$00007070,$00005858,$00004040
		dc.l	$005CBCFC,$0040B0FC,$0020A8FC,$00009CFC
		dc.l	$00008CE4,$00007CCC,$00006CB4,$00005C9C
		dc.l	$00DADAFF,$00BABFFF,$009F9FFF,$007F80FF
		dc.l	$005F60FF,$004040FF,$002025FF,$000005FF
		dc.l	$000000FF,$000000EF,$000000E3,$000000D7
		dc.l	$000000CB,$000000BF,$000000B3,$000000A7
		dc.l	$0000009B,$0000008B,$0000007F,$00000073
		dc.l	$00000067,$0000005B,$0000004F,$00000040
		dc.l	$00F0DAFF,$00E5BAFF,$00DA9FFF,$00D07FFF
		dc.l	$00CA5FFF,$00BF40FF,$00B520FF,$00AA00FF
		dc.l	$009A00E5,$008000CF,$007500B5,$0060009F
		dc.l	$00500085,$00450070,$0035005A,$002A0040
		dc.l	$00FFDAFF,$00FFBAFF,$00FF9FFF,$00FF7FFF
		dc.l	$00FF5FFF,$00FF40FF,$00FF20FF,$00FF00FF
		dc.l	$00E000E5,$00CA00CF,$00B500B5,$009F009F
		dc.l	$00850085,$006F0070,$005A005A,$00400040
		dc.l	$00FFE9DE,$00F7DDD0,$00F0D1C3,$00E9C7B7
		dc.l	$00E1BAAA,$00DAB09E,$00D3A494,$00CC9B89
		dc.l	$00C59080,$00BE8676,$00B67C6B,$00AF7363
		dc.l	$00A86B5A,$00A16152,$009A594A,$00935043
		dc.l	$008B483B,$00843F34,$007E392E,$00773128
		dc.l	$00702C23,$0069261D,$00611F18,$005A1B14
		dc.l	$00531510,$004C110D,$00450C09,$003E0907
		dc.l	$00360504,$002F0302,$00280101,$00210000
		dc.l	$00FF5858,$00FFBE80,$00FFFE82,$0082FF84
		dc.l	$0080FFFF,$008080FF,$00BF80FF,$00FE80FF
		dc.l	$00C72B2B,$00C74F2B,$00C7772B,$00C79F2B
		dc.l	$00C7C72B,$009FC72B,$0077C72B,$004FC72B
		dc.l	$002BC733,$002BC75F,$002BC78B,$002BC7B7
		dc.l	$002BABC7,$002B7FC7,$002B53C7,$002F2BC7
		dc.l	$005B2BC7,$00872BC7,$00B32BC7,$00C72BAF
		dc.l	$00C72B83,$00C72B57,$00C72B2B,$00FFFFFF

CHUNKYPALETTE:
	dc.l	$00235182,$0094a2a2,$002020f0,$003030f0,$004040f0,$005050f0
	dc.l	$006060f0,$007070f0,$008080f0,$009090f0,$00a0a0f0,$00b0b0f0
	dc.l	$00c0c0f0,$00d0d0f0,$00e0e0f0,$00f0f0f0


	cnop	0,8
TITOLO:
	incbin	"jokonda.raw"

SALE:
	incbin	"stsale.raw"

	ds.b	4000
SFERA:
	incbin	"sfera.RAW"

DEFY:
	incbin	"st.raw"

TUNNEL:
	incbin	"prospettiva.raw"

VUOTO:
	dcb.b	40*256,$ff

CREDITS:
	dcb.b	40*256,$00

FONT:
; ' '
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '!'
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00000000
; '"'
	dc.b	%00011011
	dc.b	%00011011
	dc.b	%00011011
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '#'
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%01111111
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00000000
; '$'
	dc.b	%00001000
	dc.b	%00011110
	dc.b	%00100000
	dc.b	%00011100
	dc.b	%00000010
	dc.b	%00111100
	dc.b	%00001000
	dc.b	%00000000
; '%'
	dc.b	%00000001
	dc.b	%00110011
	dc.b	%00110110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110110
	dc.b	%01100110
	dc.b	%00000000
; '&'
	dc.b	%00011000
	dc.b	%00100100
	dc.b	%00011000
	dc.b	%00011001
	dc.b	%00100110
	dc.b	%00111110
	dc.b	%00011001
	dc.b	%00000000
; "'"
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "("
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00110000
	dc.b	%00110000
	dc.b	%00011000
	dc.b	%00001100
	dc.b	%00000000
; ")"
	dc.b	%00110000
	dc.b	%00011000
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00000000
; "*"
	dc.b	%01100011
	dc.b	%00110110
	dc.b	%00011100
	dc.b	%01111111
	dc.b	%00011100
	dc.b	%00110110
	dc.b	%01100011
	dc.b	%00000000
; '+'
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%01111110
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00000000
; ","
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00000000
; "-"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%01111110
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "."
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
; "/"
	dc.b	%00000001
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%01100000
	dc.b	%00000000
; '0'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; '1'
	dc.b	%00011000
	dc.b	%00111000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
; '2'
	dc.b	%00111110
	dc.b	%01100110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%01100000
	dc.b	%01111110
	dc.b	%00000000
; '3'
	dc.b	%01111110
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00011110
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111110
	dc.b	%00000000
; '4'
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110011
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000000
; '5'
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%00111110
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111110
	dc.b	%00000000
; '6'
	dc.b	%00111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; '7'
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%01100000
	dc.b	%00000000
; '8'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; '9'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111111
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111110
	dc.b	%00000000
; ':'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ';'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "<"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "="
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ">"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '?'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00000000
	dc.b	%00001100
	dc.b	%00000000
; "@"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "A"
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; "B"
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%00000000
; 'C'
	dc.b	%00111111
	dc.b	%01110000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01110000
	dc.b	%00111111
	dc.b	%00000000
; 'D'
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%00000000
; 'E'
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111100
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000000
; 'F'
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111100
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%00000000
; 'G'
	dc.b	%00111111
	dc.b	%01110000
	dc.b	%01100000
	dc.b	%01100111
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%00111110
	dc.b	%00000000
; 'H'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'I'
	dc.b	%00011110
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00011110
	dc.b	%00000000
; 'J'
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01100011
	dc.b	%01110011
	dc.b	%00111111
	dc.b	%00000000
; 'K'
	dc.b	%01100011
	dc.b	%01100110
	dc.b	%01101100
	dc.b	%01111000
	dc.b	%01101100
	dc.b	%01100110
	dc.b	%01100011
	dc.b	%00000000
; 'L'
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000000
; 'M'
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%01101011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'N'
	dc.b	%01100011
	dc.b	%01110011
	dc.b	%01111011
	dc.b	%01101111
	dc.b	%01100111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'O'
	dc.b	%00111110
	dc.b	%01110111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%00111110
	dc.b	%00000000
; 'P'
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%00000000
; 'Q'
	dc.b	%00111110
	dc.b	%01110111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%00111111
	dc.b	%00000000
; 'R'
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'S'
	dc.b	%00111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%00111110
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111110
	dc.b	%00000000
; 'T'
	dc.b	%01111111
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%00000000
; 'U'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%00111110
	dc.b	%00000000
; 'V'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00110110
	dc.b	%00011100
	dc.b	%00000000
; 'W'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01101011
	dc.b	%01110111
	dc.b	%01100011
	dc.b	%00000000
; 'X'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00110110
	dc.b	%00001000
	dc.b	%00110110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'Y'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%00111111
	dc.b	%00000011
	dc.b	%00000111
	dc.b	%01111110
	dc.b	%00000000
; 'Z'
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%01111111
	dc.b	%00000000

	cnop	0,4
	SECTION	texture,DATA
CHUNKYPIC:
	incbin	"texture.CHK"

	end		
