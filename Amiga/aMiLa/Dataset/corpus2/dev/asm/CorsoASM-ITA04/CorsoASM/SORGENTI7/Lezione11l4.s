
; Lezione11l4.s	 - Ondeggio della figura ottenuto cambiando ogni linea i
;		   puntatori ai bitplanes, in piu' la sfumatura del color0
;		   scorre verso l'alto.

	Section BITPLANEolljelly,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA abilitati

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

scr_bytes	= 40	; Numero di bytes per ogni linea orizzontale.
			; Da questa si calcola la larghezza dello schermo,
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
ham		= 0	; 0 = non ham / 1 = ham
scr_bpl		= 1	; Numero Bitplanes

; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)+(ham<<11)
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


START:
	bsr.s	SetCop		; Crea la copperlist

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPER,$80(a5)		; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	PrintCarattere	; Stampa un carattere alla volta
	BSR.w	SistemaCop	; Copia i valori dalle tabelle alla cop
	BSR.W	RoteaTabOndegg	; Rotea i valori della tabella di ondeggio
	BSR.W	RoteaTabColori	; Rotea la tabella dei colori

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; Mouse premuto?
	bne.s	mouse
	rts			; esci

;***************************************************************************
; Questa routine crea la copperlist e ci immette i primi valori
;***************************************************************************

;	           ° o·
;	___   _)))  .  °
;	\ -\_/ (_.)  ·°
;	 \-     ___)o·
;	 /-/`-----'
;	 ¯¯ g®m

SETCOP:
	LEA	COPPER1,A0	; Indirizzo effetto copper
	MOVE.L	ADRCOL1(PC),A2	; Puntatore alla tab colori
	MOVE.L	#$2c07FFFE,D7	; Wait (prima linea $30)
	MOVE.L	#BITPLANE,D0	; Indirizzo del bitplane
	LEA	TABOSC(PC),A1	; Tabella ondeggiamento
	MOVEQ	#39-1,D5	; Numero valori di tabella usabili per questo
				; effetto. (nota: allora non e' facile capire
				; quante linee in pratica e' lungo l'effetto,
				; perche'occorre calcolare che ognuno di questi
				; loop puo' ripetere la linea piu' volte.
FaiEffetto:
	MOVE.B	(A1)+,D6	; Metti prossimo valore ondeggio in d6
	TST.B	D6		; dobbiamo tagliare gia' la linea?
	BNE.S	RipuntaLinea	; Se no, puntiamola...
	ADDI.L	#40,D0		; Oppure adda la lunghezza di 1 linea - punta
				; alla linea seguente del bitplane
	DBRA	D5,FaiEffetto	; E continua il loop
	BRA.w	FineEffetto

RipuntaLinea:
	MOVE.L	D7,(A0)+	; Metti il Wait in coplist
	SWAP	D0		; swappa l'indirizzo del plane
	MOVE.W	#$E0,(A0)+	; BPL1PTH
	MOVE.W	D0,(A0)+	; punta la word alta
	SWAP	D0		; swappa ancora l'indirizzo del plane
	MOVE.W	#$E2,(A0)+	; BPL1PTL
	MOVE.W	D0,(A0)+	; punta la word bassa
	TST.W	(A2)		; fine tab colori?
	BNE.S	SETCOP2		; Se non ancora, ok
	MOVE.L	ADRCOL2(PC),A2	; Altrimenti: tab colori -> riparti
SETCOP2:
	MOVE.W	#$180,(A0)+	; registro color0
	MOVE.W	(A2)+,(A0)+	; valore del color0
	ADDI.L	#$01000000,D7	; Fai waitare una linea sotto
	BCC.S	SETCOP3		; Siamo arrivati a $FF? Se non ancora ok,
	MOVE.L	#$FFDFFFFE,(A0)+ ; Altrimenti fine zona ntsc ($FF)
	MOVE.L	#$0011FFFE,D7	 ; E occorre mettere questi 2 wait.
SETCOP3:
	SUBQ.B	#1,D6	; Subba il valore di "ripetizione linea" preso da
			; TABOSC.
	TST.B	D6	; Abbiamo ripetuto abbastanza volte la linea?
	BNE.S	RipuntaLinea	; Se non ancora, ripuntala, ripetendola

	ADDI.L	#40,D0		; Altrimenti puntiamo piu' in basso di 1 linea
	DBRA	D5,FaiEffetto	; e vediamo di continuare l'effetto.

FineEffetto:
	MOVE.L	#$01000200,(A0)+	; Metti bplcon0 = no bitplanes
	MOVE.L	#$FFFFFFFE,(A0)+	; Metti la fine della copperlist
	RTS

;****************************************************************************
; Questa routine rotea i colori proprio nella tabella colori!
;****************************************************************************

;	 ______________
;	 \    \__/    / 
;	  \__________/
;	  __|______|__
;	__(\___)(___/)__
;	\_\    \/    /_/
;	   \ \____/ /
;	    \______/ g®m
;

RoteaTabColori:
	LEA	COLORSTAB(PC),A0	; tabella colori
	MOVE.W	(A0)+,D0		; Salva il primo colore in d0
RoteaTabColori2:
	TST.W	(A0)		; fine della tabella?
	BNE.S	RoteaTabColori1		; Se non ancora, ok
	MOVE.W	D0,-2(A0)	; altrimenti metti il primo colore come ultimo
	RTS

RoteaTabColori1:
	MOVE.W	(A0)+,-4(A0)	; Sposta (rotea) il colore "indietro"
	BRA.S	RoteaTabColori2

;***************************************************************************
; Questa routine rotea i valori nella tabella "TABOSC"
;***************************************************************************

RoteaTabOndegg:
	LEA	TABOSC(PC),A0	; Indirizzo tabella
	MOVEQ	#63-1,D7	; Numero di valori nella tabella
	MOVE.B	(A0),D0		; Salva il primo valore in d0
RoteaTabOndegg1:
	MOVE.B	1(A0),(A0)+	; sposta i valori "indietro".
	DBRA	D7,RoteaTabOndegg1
	MOVE.B	D0,-1(A0)	; Rimetti il primo valore come ultimo
	RTS

;***************************************************************************

ADRCOL1:
	DC.L	COLORSTAB
ADRCOL2:
	DC.L	COLORSTAB

COLORSTAB:
	DC.W	$FC9,$EC9,$DC9,$CC9,$CB9,$CA9,$C99,$C9A,$C9B,$C9C
	DC.W	$C9D,$C9E,$C9F,$B9F,$A9F,$99F,$9AF,$9BF,$9CF,$ACF
	DC.W	$BCF,$CCF,$DCF,$ECF,$FCF,$FBF,$FAF,$F9F,$F9E,$F9D
	DC.W	$F9C,$E9C,$D9C,$C9C,$CAC,$CBC,$CCC,$CDC,$CEC,$CFC
	DC.W	$CFB,$CFA,$CF9,$BF9,$AF9,$9F9,$9FA,$9FB,$9FC,$AFC
	DC.W	$BFC,$CFC,$DFC,$EFC,$FFC,$FEC,$FDC,$FCC,$FCB,$FCA
	DC.W	0	; con lo zero si termina la tabella

;***************************************************************************
; La routine non e' altro che SETCOP senza le parti che scrivono i registri
; e i wait: si scrive solo il necessario.
; Questa routine agisce sulla copperlist che ridefinisce ad ogni linea i
; puntatori ai bitplanes. Leggendo da una tabella, sa di ogni linea della
; pic quante volte ripeterla, ossia ripuntarla. Se per esempio nella tabella
; ci sono i valori 1,2,3, allora puntera' la prima linea nella prima linea
; dello schermo (1 volta), poi puntera' la seconda linea 2 volte, e la terza
; linea 3 volte. Ecco un "disegnino":
;
; linea1
; linea2
; linea2
; linea3
; linea3
; linea3
;
; Notate che la fugura si allunga...
;***************************************************************************

;	 /) ________ (\
;	(__/        \__)
;	  / ___  ___ \
;	  \ \°_)(_°/ /
;	   \__ `' __/
;	    /      \
;	    \("""")/g®m
;	     ¯    ¯

SistemaCop:
	LEA	COPPER1,A0	; Indirizzo effetto copper
	MOVE.L	ADRCOL1(PC),A2	; Puntatore alla tab colori
	MOVE.L	#$2c07FFFE,D7	; Wait (prima linea $30)
	MOVE.L	#BITPLANE,D0	; Indirizzo del bitplane
	LEA	TABOSC(PC),A1	; Tabella ondeggiamento
	MOVEQ	#39-1,D5	; Numero valori di tabella usabili per questo
				; effetto. (nota: allora non e' facile capire
				; quante linee in pratica e' lungo l'effetto,
				; perche'occorre calcolare che ognuno di questi
				; loop puo' ripetere la linea piu' volte.
FaiEffetto2:
	MOVE.B	(A1)+,D6	; Metti prossimo valore ondeggio in d6
	TST.B	D6		; dobbiamo tagliare gia' la linea?
	BNE.S	RipuntaLinea2	; Se no, puntiamola...
	ADDI.L	#40,D0		; Oppure adda la lunghezza di 1 linea - punta
				; alla linea seguente del bitplane
	DBRA	D5,FaiEffetto2	; E continua il loop
	BRA.w	FineEffetto2

RipuntaLinea2:
	addq.w	#6,a0		; Salta il WAIT e il BPL1PTH
	SWAP	D0		; swappa l'indirizzo del plane
	MOVE.W	D0,(A0)+	; punta la word alta
	SWAP	D0		; swappa ancora l'indirizzo del plane
	addq.w	#2,a0		; salta il BPL1PTL
	MOVE.W	D0,(A0)+	; punta la word bassa
	TST.W	(A2)		; fine tab colori?
	BNE.S	SETCOP22	; Se non ancora, ok
	MOVE.L	ADRCOL2(PC),A2	; Altrimenti: tab colori -> riparti
SETCOP22:
	addq.w	#2,a0		; salta il registro color0
	MOVE.W	(A2)+,(A0)+	; valore del color0
	ADDI.L	#$01000000,D7	; Fai waitare una linea sotto
	BCC.S	SETCOP32	; Siamo arrivati a $FF? Se non ancora ok,
	addq.w	#4,a0		; Salta l'FFDFFFFE
	MOVE.L	#$0011FFFE,D7	 ; E occorre mettere questi 2 wait.
SETCOP32:
	SUBQ.B	#1,D6	; Subba il valore di "ripetizione linea" preso da
			; TABOSC.
	TST.B	D6	; Abbiamo ripetuto abbastanza volte la linea?
	BNE.S	RipuntaLinea2	; Se non ancora, ripuntala, ripetendola

	ADDI.L	#40,D0		; Altrimenti puntiamo piu' in basso di 1 linea
	DBRA	D5,FaiEffetto2	; e vediamo di continuare l'effetto.

FineEffetto2:
	RTS

;********************************************************************

; Tab con 64 valori .byte. Indica per quante linee occorre ripetere la stessa
; linea. Per esempio, dove c'e' un valore 2, la linea e' ripetura 2 volte,
; ossia e' raddoppiata in altezza.

TABOSC:
	DC.B	1,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9
	DC.B	9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2
	DC.B	2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9
	DC.B	9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,1

	EVEN

*****************************************************************************
;			Routine di Print
*****************************************************************************

PRINTcarattere:
	movem.l	d2/a0/a2-a3,-(SP)
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#40*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	movem.l	(SP)+,d2/a0/a2-a3
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANE

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
             ;   1234567890123456789012345678901234567890
	dc.b	'  * * * * * * * * * * * * * * * * *     ',0 ; 1
	dc.b	'  * MAMMA MIA MI BALLA            *     ',0 ; 2
	dc.b	'  *                    LO SCHERMO *     ',0 ; 3
	dc.b	'  * * * * * * * * * * * * * * * * *     ',$FF ; 4

	EVEN

;	Il FONT caratteri 8x8 copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

;********************************************************************
;				COPPERLIST
;********************************************************************

	section	cooppera,data_C

COPPER:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop
	dc.w	$100,BPLC0	; BplCon0
	dc.w	$108,0		; bpl1mod
	dc.w	$10a,0		; bpl2mod
	DC.w	$182,$000	; Color1 (scritte) - NERO
COPPER1:
	DCB.b	4000,0	; Attenzione! La lunghezza dell'effetto dipende
			; dalla tabella TABOSC e non e' facile calcolarla...
	DC.L	$FFFFFFFE

;********************************************************************
;	Il bitplane
;********************************************************************
	section	bitplane,bss_C

BITPLANE:
	ds.b	40*320

	end

Abbiamo visto prima un effetto simile fatto cambiando i moduli, ora cambiando
invece i bplpointers. Questo sistema e' piu' lento di quello con i moduli se
si devono cambiare ogni linea i puntatori di molti bitplanes, ma ogni plane
potrebbe essere definito in maniera diversa per andare per i fatti suoi,
invcece il bplmod coinvolge tutti plane pari e/o dispari.
Una particolarita' di questo sorgente e' che i valori delle tabelle per i plane
e dei colori non sono "roteati" rileggendoli dalle cop e spostandoli, ma
roteando i valori nelle tabelle stesse, per cui basta copiare ogni volta dalla
tabella alla copperlist, dopo che la tabella e' stata "roteata".
Questo sistema e' piu' veloce di altri quando si possiede fast ram ,in quanto
se si dovesse leggere da copperlist il valore e riscriverlo piu' avanti o
indietro, dovremmo accedere 2 volte alla CHIP RAM, con i relativi "ritardi",
mentre nel nostro caso accediamo alla tabella in FAST, con perdita di tempo
minima, e scriviamo solo una volta per colore/plane in CHIP. Su computer come
A4000 l'unico rallentamento e' dato dalla lettura/scrittura in CHIP RAM,
dunque la velocita' dell'esecuzione della routine raddoppia.
