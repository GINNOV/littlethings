
; Lezione6r.s	RIEPILOGO DELLA LEZIONE 6 - VARIE ROUTINES DELLA LEZIONE
;		COMBINATE INSIEME + ROUTINE MUSICALE

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANETESTO-2,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#BITPLANEGRIGLIA-2,d0
	LEA	BPLPOINTERS2,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	bsr.w	griglia3	; Fai la scacchiera su BITPLANEGRIGLIA

	bsr.w	mt_init		; Inizializza routine musicale

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	PrintCarattere	; Stampa un carattere alla volta
	bsr.w	MEGAScrolla	; Esegue lo scroll dello schermo largo 640
				; pixel su uno di 320
	bsr.w	Rimbalzo	; Fa rimbalzare il bitplane TESTO
	bsr.w	mt_music	; Suona la musica

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	bsr.w	mt_end		; Termina la routine musicale

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

;************************************************************************
;*	Stampa un carattere alla volta su schermo largo 640 pixel	*
;************************************************************************

PRINTcarattere:
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#80*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,80(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,80*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,80*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,80*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,80*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,80*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,80*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANETESTO

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 80
TESTO:
	dc.b	"          QUESTA DEMO RIASSUME LA LEZION"
	dc.b	"E 6 IN QUANTO CONTIENE SIA LA           ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          ROUTINE DI STAMPA DEI CARATTER"
	dc.b	"I DI 8x8 PIXEL, SIA LO SCROLL           ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          ORIZZONTALE TRAMITE IL BPLCON1"
	dc.b	" ($dff102) E I BPLPOINTERS, SIA         ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          L'USO DI UNA TABELLA DI VALORI"
	dc.b	" PREDEFINITI PER IL MOVIMENTO           ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          OSCILLATORIO VERTICALE DI QUES"
	dc.b	"TO TESTO.                               ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          IL PLAYFIELD DOVE VIENE STAMPA"
	dc.b	"TO QUESTO TESTO HA LE DIMENSIONI        ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          DI UNO SCHERMO HIRES, OSSIA 64"
	dc.b	"0 PIXEL DI LARGHEZZA PER 256 DI         ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          ALTEZZA, E VIENE SPOSTATO SIA "
	dc.b	"ORIZZONTALMENTE, SIA VERTICALMENTE,     ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          MENTRE IL BITPLANE CHE CONTIEN"
	dc.b	"E LA GRIGLIA VIENE SPOSTATO SOLO        ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          ORIZZONTALMENTE. LO SCROLL VER"
	dc.b	"TICALE, ESSENDO DETERMINATO DA UNA      ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          TABELLA, HA VELOCITA' VARIABIL"
	dc.b	"E, MENTRE LO SCROLL ORIZZONTALE E'      ",0
	dc.b	"                                        "
	dc.b	"                                        ",0
	dc.b	"          SEMPRE DI 2 PIXEL PER FOTOGRAM"
	dc.b	"MA.                                     ",$FF



	EVEN

;************************************************************************
;*   Esegue uno scroll di 320 pixel a destra e sinistra (Lezione6o.s)	*
;************************************************************************

; NOTA: Modificata in modo da agire anche sul bitplane della GRIGLIA

MEGAScrolla:
	addq.w	#1,ContaVolte	; Segnamo una esecuzione in piu'
	cmp.w	#160,ContaVolte	; Siamo a 160? Allora abbiamo scrollato 320
				; pixel, dato che eseguiamo 2 volte la routine
				; DESTRA o SINISTRA ogni FRAME per andare al
				; doppio della velocita'
	bne.S	MuoviAncora	; Se non ancora, sposta ancora
	BCHG.B	#1,DestSinFlag	; Se siamo a 160, invece, cambia direzione
	CLR.w	ContaVolte	; di scorrimento e azzera "ContaVolte"
	rts

MuoviAncora:
	BTST	#1,DestSinFlag	; Dobbiamo andare a destra o a sinistra?
	BEQ.S	VaiSinistra
	bsr.s	Destra		; Scorri un pixel verso destra
	bsr.s	Destra		; Scorri un pixel verso destra
				; (2 pixel per frame, dunque doppia velocita')
	rts

VaiSinistra:
	bsr.s	Sinistra	; Scorri un pixel verso sinistra
	bsr.s	Sinistra	; Scorri un pixel verso sinistra
				; (2 pixel per frame, dunque doppia velocita')
	rts

; Questa word conta quante volte ci siamo spostati a Destra o a Sinistra

ContaVolte:
	DC.W	0

; Quando il bit 1 di DestSinFlag e' a ZERO la routine scorre a Sinistra, se
; e' ad 1 scorre a Destra.

DestSinFlag:
	DC.W	0

; Questa routine fa scorrere a destra un bitplane agendo sul BPLCON1 e sui
; puntatori ai bitplanes in copperlist. MIOBPCON1 e' il byte del BPLCON1.

Destra:
	CMP.B	#$ff,MIOBPCON1	; siamo arrivati al massimo scorrimento? (15)
	BNE.s	CON1ADDA	; se non ancora, scorri in avanti di 1
				; con il BPLCON1

	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poiniamo in d0
	move.w	6(a1),d0

	LEA	BPLPOINTERS2,A2	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a2),d1	; copperlist l'indirizzo dove sta puntando
	swap	d1		; attualmente il $dff0e4 e lo poiniamo in d0
	move.w	6(a2),d1

	subq.l	#2,d0		; punta 16 bit piu' indietro ( la PIC scorre
				; verso destra di 16 pixel) - TESTO

	subq.l	#2,d1		; punta 16 bit piu' indietro ( la PIC scorre
				; verso destra di 16 pixel) - GRIGLIA

	clr.b	MIOBPCON1	; azzera lo scroll hardware BPLCON1 ($dff102)
				; infatti abbiamo "saltato" 16 pixel con il
				; bitplane pointer, ora dobbiamo ricominciare
				; da zero con il $dff102 per scattare a
				; destra di un pixel alla volta.

;	Puntiamo il bitplane TESTO

	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

;	Puntiamo il bitplane GRIGLIA

	move.w	d1,6(a2)	; copia la word BASSA dell'indirizzo del plane
	swap	d1		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d1,2(a2)	; copia la word ALTA dell'indirizzo del plane

	rts

CON1ADDA:
	add.b	#$11,MIOBPCON1	; scorri in avanti di 1 pixel
	rts

;	Routine che sposta a sinistra in modo analogo:

Sinistra:
	TST.B	MIOBPCON1	; siamo arrivati al minimo scorrimento? (00)
	BNE.s	CON1SUBBA	; se non ancora, scorri indietro di 1
				; con il BPLCON1

	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poiniamo in d0
	move.w	6(a1),d0

	LEA	BPLPOINTERS2,A2	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a2),d1	; copperlist l'indirizzo dove sta puntando
	swap	d1		; attualmente il $dff0e4 e lo poiniamo in d0
	move.w	6(a2),d1

	addq.l	#2,d0		; punta 16 bit piu' avanti ( la PIC scorre
				; verso sinistra di 16 pixel) - TESTO

	addq.l	#2,d1		; punta 16 bit piu' avanti ( la PIC scorre
				; verso sinistra di 16 pixel) - GRIGLIA

	move.b	#$FF,MIOBPCON1	; scroll hardware a 15 - BPLCON1 ($dff102)

;	Puntiamo il bitplane TESTO

	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

;	Puntiamo il bitplane GRIGLIA

	move.w	d1,6(a2)	; copia la word BASSA dell'indirizzo del plane
	swap	d1		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d1,2(a2)	; copia la word ALTA dell'indirizzo del plane

	rts

CON1SUBBA:
	sub.b	#$11,MIOBPCON1	; scorri indietro di 1 pixel
	rts


;************************************************************************
;*   Fa oscillare SU/GIU tramite l'uso di una tabella (Lezione6m.s)	*
;************************************************************************

Rimbalzo:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poiniamo in d0
	move.w	6(a1),d0

	ADDQ.L	#4,RIMTABPOINT	; Fai puntare alla longword successiva
	MOVE.L	RIMTABPOINT(PC),A0 ; indirizzo contenuto in long RIMTABPOINT
				   ; copiato in a0
	CMP.L	#FINERIMBALZTAB-4,A0 ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTART2		; non ancora? allora continua
	MOVE.L	#RIMBALZTAB-4,RIMTABPOINT ; Riparti a puntare dalla prima long
NOBSTART2:
	MOVE.l	(A0),d1		; copia la long dalla tabella in d1

	sub.l	d1,d0		; sottraiamo il valore attualmente preso dalla
				; tabella, facendo scorrere la figura SU o GIU.

	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#1,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP2:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#80*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
;	dbra	d1,POINTBP2	; Rifai D1 volte POINTBP (D1=num of bitplanes)
	rts


RIMTABPOINT:			; Questa longword "PUNTA" a RIMBALZTAB, ossia
	dc.l	RIMBALZTAB-4	; contiene l'indirizzo di RIMBALZTAB. Terra'
				; l'indirizzo del'ultima long "letta" dentro
				; la tabella. (qua inizia da RIMORTAB-4 in
				; quanto Lampeggio inizia con un ADDQ.L #4,C..
				; serve per "bilanciare" la prima istruzione.

;	La tabella con i valori "precalcolati" del rimbalzo

RIMBALZTAB:
	dc.l	0,0,80,80,80,80,80,80,80,80,80 			; in cima
	dc.l	80,80,2*80,2*80
	dc.l	2*80,2*80,2*80,2*80,2*80			; acceleriamo
	dc.l	3*80,3*80,3*80,3*80,3*80
	dc.l	3*80,3*80,3*80,3*80,3*80
	dc.l	2*80,2*80,2*80,2*80,2*80			; deceleriamo
	dc.l	2*80,2*80,80,80
	dc.l	80,80,80,80,80,80,80,80,80,0,0,0,0,0,0,0	; in fondo
	dc.l	-80,-80,-80,-80,-80,-80,-80,-80,-80
	dc.l	-80,-80,-2*80,-2*80
	dc.l	-2*80,-2*80,-2*80,-2*80,-2*80
	dc.l	-3*80,-3*80,-3*80,-3*80,-3*80			; acceleriamo
	dc.l	-3*80,-3*80,-3*80,-3*80,-3*80
	dc.l	-2*80,-2*80,-2*80,-2*80,-2*80			; deceleriamo
	dc.l	-2*80,-2*80,-80,-80
	dc.l	-80,-80,-80,-80,-80,-80,-80,-80,-80,0,0,0,0,0	; in cima
FINERIMBALZTAB:

;************************************************************************
;*  fa una scacchiera con quadrati di 16 pixel di lato (Lezione6q.s)	*
;************************************************************************

GRIGLIA3:
	LEA	BITPLANEGRIGLIA,a0	; Indirizzo bitplane destinazione

	MOVEQ	#8-1,d0		; 8 coppie di quadretti alti 16 pixel
				; 8*2*16=256 riempimento completo dello schermo
FaiCoppia3:
	move.l	#(20*16)-1,d1	; 20 longwords per riempire 1 linea (640 pixel)
				; 16 linee da riempire
FaiUNO3:
	move.l	#%11111111111111110000000000000000,(a0)+ 
					; lunghezza quadretto ad 1 = 16 pixel
					; quadretto azzerato = 16 pixel
	dbra	d1,FaiUNO3		; fai 16 linee #.#.#.#.#.#.#.#.#.#

	move.l	#(20*16)-1,d1	; 20 lingwords per riempire 1 linea (640 pixel)
				; 16 linee da riempire
FaiALTRO3:
	move.l	#%00000000000000001111111111111111,(a0)+
					; lunghezza quadretto azzerato = 16
					; quadretto ad 1 = 16 pixel
	dbra	d1,FaiAltro3		; fai 8 linee .#.#.#.#.#.#.#.#.#.

	DBRA	d0,FaiCoppia3		 ; fai 8 coppie di quadretti
					 ; #.#.#.#.#.#.#.#.#.#
	rts				 ; .#.#.#.#.#.#.#.#.#.

; **************************************************************************
; *		ROUTINE CHE SUONA MUSICHE SOUNDTRACKER/PROTRACKER	   *
; **************************************************************************

	include	"music.s"	; routine 100% funzionante su tutti gli Amiga


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8e,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$30		; DdfStart (modificato per SCROLL)
	dc.w	$94,$d0		; DdfStop
	dc.w	$102		; BplCon1
	dc.b	0		; byte "alto" inutilizzato del $dff102
MIOBPCON1:
	dc.b	0		; byte "basso" utilizzato del $dff102
	dc.w	$104,0		; BplCon2
	dc.w	$108,40-2	; Bpl1Mod (40 per la figura larga 640, il -2
	dc.w	$10a,40-2	; Bpl2Mod (per bilanciare il DDFSTART

		    ; 5432109876543210
	dc.w	$100,%0010001000000000	; bit 12 - 1 bitplane LOWRES

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo bitplane
BPLPOINTERS2:
	dc.w $e4,0,$e6,0	; secondo bitplane

	dc.w	$180,$113	; color0 - QUADRATO SCURO
	dc.w	$182,$bb5	; color1 - SCRITTE+quadrato scuro
	dc.w	$184,$225	; color2 - QUADRATO CHIARO
	dc.w	$186,$bb5	; color3 - SCRITTE+quadrato chiaro

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;	Il FONT caratteri 8x8

FONT:
	incbin	"metal.fnt"
;	incbin	"normal.fnt"
;	incbin	"nice.fnt"

; **************************************************************************
; *				MUSICA PROTRACKER			   *
; **************************************************************************

mt_data:
	incbin	"mod.purple-shades"


	SECTION	MIOPLANE,BSS_C

BITPLANEGRIGLIA:
	ds.b	80*256	; un bitplane 640x256


	ds.b	80*100
BITPLANETESTO:
	ds.b	80*256	; un bitplane 640x256


	end

Alle volte mettere insieme routines di poco effetto genera un bel risultato.

