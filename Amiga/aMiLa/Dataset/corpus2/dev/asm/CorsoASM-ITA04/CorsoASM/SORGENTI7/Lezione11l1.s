
;  Lezione11l1.s - cambiamo ad ogni linea il color0 e il bplcon1 ($dff102)

	SECTION	coplanes,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

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
;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTER,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	move.w	#11,ContaNumLoop1
	move.w	#2,Contatore1
	clr.w	Contatore2

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

	btst.b	#2,$dff016
	beq.s	NoEff
	bsr.s	Mainroutine	; rulla i colori e rolla il bplcon1
NoEff:
	bsr.w	PrintCarattere	; Stampa un carattere alla volta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
; Questa routine non e' per niente ottimizzata, si potrebbe fare una
; routine che crea la copperlist, da chiamare all'inizio, poi un'altra
; che cambia solo i valori del color1 e del bplcon1.
; Gia' che era lenta, per peggiorarla e' stato usato un sistema che
; comunque puo' servire in certi casi: per "scorrere" le tabelle, viene
; usato un buffer lungo quanto la tabella in cui viene copiata la tabella
; stessa ruotata, poi da questa tabella i valori sono ricopiati nella
; tabella di partenza. Ma non si faceva prima senza il buffer? Si!
; Ma pensate ad una routine con tante tabelle, che possono tenere i valori
; nelle varie fasi della rotazione. In questo caso potermmo "precalcolarci"
; in tante tabelle i valori ruotati in ogni fase... ma forse si otterrebbe
; cosi' poca ottimizzazione che non varrebbe la pena... insomma date un
; occhiata alla routine, e' "strana" e si ingarbuglia per niente, proprio
; per mostrare tecniche "alternative"... (esagerato.. fa schifo e basta!).
*****************************************************************************

;	    ______
;	  .//_____\,
;	   \\ ¦.¦ /
;	   _\\_-_/_. dA!
;	  ( /  :  \ \
;	 / /   :   \ \
;	 \,_,_,:,_,_\/`).
;	   |   |   | (//\\
;	.-./,,_|__,,\.-. \\
;	`------`-------'  `

MainRoutine:
	move.l	a5,-(sp)	; salviamo a5
	subq.w	#1,Contatore1	; Segna questa esecuzione
	tst.w	Contatore1	; 2 frame passati?
	bne.w	SaltaRull	; Se non ancora non rullare
	move.w	#2,Contatore1	; Riparti, ad aspettare 2 frames
	cmp.w	#15,Contatore2	; Passati 15 frames?
	beq.s	Rulla2
	addq.w	#1,ContaNumLoop1
	cmp.w	#30,ContaNumLoop1 ; siamo a 30 loops da fare?
	bne.s	VaiARullare	  ; se non ancora ok
	move.w	#15,Contatore2	  ; Altrimenti Contatore2=15
	bra.s	VaiARullare
Rulla2:
	subq.w	#1,ContaNumLoop1	; subbiamo
	cmp.w	#3,ContaNumLoop1	; siamo a 3?
	bne.s	VaiARullare		; Se non ancora RiRulla
	clr.w	Contatore2		; Altrimenti azzera contatore2
VaiARullare:
	lea	coltab(PC),a0	; Tabella con i colori
	lea	TabBuf(PC),a1
	move.w	(a0)+,d0	; Primo colore in d0
CopiaColtabLoop:
	move.w	(a0)+,d1	; Prossimo colore in d1
	cmp.w	#-2,d1	; fine tabella?
	beq.s	FiniTabCol	; Se si, il lop e' finito
	move.w	d1,(a1)+	; se no, metti questo colore nella TabBuf
	bra.s	CopiaColtabLoop

FiniTabCol:
	move.w	d0,(a1)+	; Metti il primo colore come ultimo
	move.w	#-2,(a1)+	; E poni il segno di fine tabella
	lea	coltab(PC),a0	; Tab colori
	lea	TabBuf(PC),a1	; Buffer tab
RicopiaInColTabLoop:
	move.w	(a1)+,d0	; copia colore da TabBuf
	move.w	d0,(a0)+	; Mettilo in coltab
	cmp.w	#-2,d0		; Fine?
	bne.s	RicopiaInColTabLoop
SaltaRull:
	lea	BplCon1Tab(PC),a0 ; Tab con valori per bplcon1
	lea	TabBuf(PC),a1
	move.w	(a0)+,d0	; Privo val. della tab salvato in d0
RullaLoop:
	move.w	(a0)+,d1	; Prossimo val. tab Bplcon1
	cmp.w	#-2,d1		; Fine tabella?
	beq.s	rullFinito	; Se si salta avanti
	move.w	d1,(a1)+	; Copia da BplCon1Tab a TabBuf
	bra.s	RullaLoop
rullFinito:
	move.w	d0,(a1)+	; Metti il primo valore come ultimo
	move.w	#-2,(a1)+	  ; metti flag di fine tabella
	lea	BplCon1Tab(PC),a0 ; Tab valori bplcon1
	lea	TabBuf(PC),a1	  ; buffer
RicopiaCon1:
	move.w	(a1)+,d0	; copia da tabbuf
	move.w	d0,(a0)+	; a bplcon1tab
	cmp.w	#-2,d0		; siamo alla fine?
	bne.s	RicopiaCon1	; se non ancora, ricopia!
delayed:
	lea	CopperEffect,a0

; primo loop, che fa la parte ntsc (prime $ff linee)

	move.w	#$2007,d0	; posizione wait start YY=$22
	move.w	#$4007,d2	; posizione wait step YY=$22
	moveq	#7-1,d4		; Numero di loops da $20 l'uno.
				; $20*7=$e0, + $20 iniziale = $100, ossia
				; tutta la zona NTSC
	lea	FineTabCol(PC),a1
	lea	BplCon1Tab(PC),a2 ; tab valori per bplcon1
loop:
	move.w	ContaNumLoop1(PC),d3
main:
	move.w	(a2)+,d5	; Prissimo valore del bplcon1
	cmp.w	#-2,d5		; Fine tabella?
	bne.s	initd		; Se no, continua
	lea	BplCon1Tab(PC),a2 ; Altrimenti, riparti da capo
	move.w	(a2)+,d5	; valore del bplcon1
initd:
	move.w	-(a1),d1	; leggi il colore e vai indietro
	cmp.w	#-2,d1		; Fine tabella?
	bne.s	initc		; Se non ancora, metti il colore & bplcon1
	lea	FineTabCol(PC),a1 ; Altrimenti riparti dalla fine della tabcol
	move.w	-(a1),d1	; leggi il colore e vai indietro
initc:
	move.w	d0,(a0)+	; YYXX del wait
	move.w	#$fffe,(a0)+	; wait
	move.w	#$0180,(a0)+	; registro color0
	move.w	d1,(a0)+	; valore del color0
	move.w	#$0102,(a0)+	; bplcon1
	move.w	d5,(a0)+	; valore del bplcon1
	add.w	#$0100,d0	; fai waitare una linea sotto
	dbra	d3,main
second:
	move.w	(a2)+,d5	; Prossimo Bplcon1val
	cmp.w	#-2,d5		; Fine tabella?
	bne.s	doned
	lea	BplCon1Tab(PC),a2 ; riparti dall'inizio
	move.w	(a2)+,d5	; Prossimo valore Bplcon1
doned:
	move.w	(a1)+,d1	; Prossimo colore
	cmp.w	#-2,d1		; Fine tabella?
	bne.s	done
	lea	coltab(PC),a1	; riparti dall'inizio
	move.w	(a1)+,d1	; Prossimo colore in tab
done:
	move.w	d0,(a0)+	; YYXX del wait
	move.w	#$fffe,(a0)+	; wait
	move.w	#$0180,(a0)+	; registro color0
	move.w	d1,(a0)+	; valore del color0
	move.w	#$0102,(a0)+	; registro bplcon1
	move.w	d5,(a0)+	; valore del reg. bplcon1
	add.w	#$0100,d0	; fai waitare una linea sotto
	cmp.w	d2,d0		; siamo alla fine del blocco da $20 linee?
	bne.s	second
	add.w	#$2000,d2	; sposta il nuovo massimo $20 piu' in basso.
	dbra	d4,loop
	move.l	#$ffdffffe,(a0)+	; Fine zona ntsc

; Secondo loop, che fa la zona PAL, sotto la linea $FF

	move.w	#$0007,d0	; Inizo wait, alla linea $00 (ossia 256)
	move.w	#$2007,d2	; Fine alla linea $20 (+$ff)
	moveq	#2-1,d4		; Numero loops
loop2:
	move.w	ContaNumLoop1(PC),d3
main2:
	move.w	-(a1),d1	; colore precedente
	cmp.w	#-2,d1		; Fine tab?
	bne.s	initc2
	lea	FineTabCol(PC),a1 ; riparti dalla fine della tabCol
	move.w	-(a1),d1	; Colore precedente
initc2:
	move.w	d0,(a0)+	; YYXX del wait
	move.w	#$fffe,(a0)+	; Wait
	move.w	#$0180,(a0)+	; registro color0
	move.w	d1,(a0)+	; valore del color0
	add.w	#$0100,d0	; fai waitare una linea sotto
	dbra	d3,main2
second2:
	move.w	(a1)+,d1	; Prossimo colore
	cmp.w	#-2,d1		; fine tab?
	bne.s	done2
	lea	coltab(PC),a1	; Tabella colori -  riparti dall'inizio
	move.w	(a1)+,d1	; Prossimo colore in d1
done2:
	move.w	d0,(a0)+	; coord YYXX del wait
	move.w	#$fffe,(a0)+	; seconda word del wait
	move.w	#$0180,(a0)+	; registro color0
	move.w	d1,(a0)+	; Valore del color0
	add.w	#$0100,d0	; Fai waitare una linea sotto
	cmp.w	d2,d0		; Siamo in fondo? ($20-$40-$60)
	bne.s	second2		; Se non ancora, insisti
	add.w	#$2000,d2	; Poni il massimo 20 piu' in basso
	dbra	d4,loop2
	move.l	(sp)+,a5	; Ripristiniamo a5
	rts

ContaNumLoop1:	dc.w	0
Contatore1:	dc.w	0
Contatore2:	dc.w	0


	dc.w	-2	; inizio tab
coltab:
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007,$008,$009,$009
	dc.w	$00a,$00a,$00b,$00b,$00b,$01c,$02c,$03c,$04c,$05d,$05d
	dc.w	$06d,$06d,$07d,$07d,$07d,$08d,$08d,$08d,$09d,$09D,$09C
	dc.w	$0aA,$0aA,$0a9,$0a8,$0a7,$0a6,$0a5,$0a4,$0a3,$0b2,$0b1
	dc.w	$0b0,$1b0,$2b0,$3b0,$4b0,$5b0,$6b0,$7b0,$8b0,$9b0,$Ab0
	dc.w	$Bb0,$Cb0,$Db0,$db0,$db0,$db0,$db0,$da0,$da0,$d90,$d90
	dc.w	$d80,$d70,$d60,$d50,$d40,$d30,$d20,$d10,$d00,$d00,$D00
	dc.w	$C00,$B00,$A00,$900,$800,$700,$600,$500,$400,$300,$200
	dc.w	$100,$000,$000
FineTabCol:
	dc.w	-2	; fine tab

; Tabella dei valori per il bplcon1. Come notate si provoca un ondeggio.

	dc.w	-2	; inizio tab
BplCon1Tab:
	dc.w	$11,$11,$11,$22,$22,$33,$44,$55,$55,$66,$66,$66,$077,$077
	dc.w	$77,$77,$77,$77,$66,$66,$66,$55,$55,$44,$33,$33,$022,$022
	dc.w	$22,$11,$11,$11,$11,$00,$00,$00,$00,$00,$00,$11,$011,$011
	dc.w	$11,$11,$22,$22,$22,$22,$33,$33,$44,$44,$55,$55,$055,$055
	dc.w	$66,$66,$66,$66,$66,$66,$77,$77,$77,$77,$77,$77,$077,$077
	dc.w	$77,$77,$66,$66,$66,$66,$66,$66,$55,$55,$55,$55,$044,$044
	dc.w	$33,$33,$33,$33,$22,$22,$22,$22,$22,$22,$11,$11,$011,$011
	dc.w	-2	; fine tab

; In questo buffer vengono ricopiate le tabelle ruotate, che poi vengono
; ricopiate nelle tabelle stesse... un modo strano per scorrere, no?

TabBuf:
	ds.w	128

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
	dc.b	'                                        ',0 ; 1
	dc.b	'    Questo listato cambia ad ogni       ',0 ; 2
	dc.b	'                                        ',0 ; 3
	dc.b	'    linea sia il color1 ($dff184),      ',0 ; 4
	dc.b	'                                        ',0 ; 5
	dc.b	'    che il bplcon1 ($dff102). Notate    ',0 ; 6
	dc.b	'                                        ',0 ; 7
	dc.b	'    come si possano "unire" listati     ',0 ; 8
	dc.b	'                                        ',0 ; 9
	dc.b	'    visti in precedenza in un solo      ',0 ; 10
	dc.b	'                                        ',0 ; 11
	dc.b	'    effetto. Si potrebbero cambiare     ',0 ; 12
	dc.b	'                                        ',0 ; 13
	dc.b	'    anche altri colori e i moduli per   ',0 ; 14
	dc.b	'                                        ',0 ; 15
	dc.b	'    ogni linea, se avete voglia         ',0 ; 16
	dc.b	'                                        ',0 ; 17
	dc.b	'    provate!                            ',$FF ; 18

	EVEN

;	Il FONT caratteri 8x8 (copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

*****************************************************************************

	section	graficozza,data_C

COPPERLIST:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop
	dc.w	$100,BPLC0	; BplCon0
	dc.w	$180,$000	; color0 nero
	dc.w	$182,$eee	; color1 bianco
BPLPOINTER:
	dc.w	$E0,$0000	; Bpl0h
	dc.w	$E2,$0000	; Bpl0l
	dc.w	$102,$0		; Bplcon1
	dc.w	$104,$0		; Bplcon2
	dc.w	$108,$0		; Bpl1mod
	dc.w	$10a,$0		; Bpl2mod

CopperEffect:
	dcb.l	801,0		; spazio per l'effetto (attenzione! se
				; cambiate l'effetto puo' diventare piu'
				; grande o piu' piccolo)
	dc.w	$ffff,$fffe	; Fine copperlist

*****************************************************************************

	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

Avrete notato che aggrovigliamento e quanti loop strani, regolati da contatori,
faccia la routine. questo serve per creare quell'effeto dei colori, che non
e' un semplice scorrimento in alto o in basso, ma "l'incrocio" di piu'
scorrimenti, dato da vari passaggi.

