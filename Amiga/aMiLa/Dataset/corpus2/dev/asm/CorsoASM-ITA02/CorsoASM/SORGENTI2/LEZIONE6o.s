
; Lezione6o.s		SCORRIMENTO A DESTRA E SINISTRA DI UN PLAYFIELD PIU'
;			GRANDE DELLO SCHERMO (qua largo 640 pixel)
;			Tasto destro per bloccare lo scroll

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

; Attenzione! Per "centrare" l'immagine occorre puntare 2 bytes piu' indietro
; facendo scorrere in avanti la PIC di 16 pixel, infatti la figura comincia
; 16 pixel piu' indietro grazie al DDFSTART (zona "coperta" dove avviene
; l'errore di visualizzazione da nascondere).

	MOVE.L	#BITPLANE-2,d0	; in d0 mettiamo l'indirizzo del bitplane -2,
				; ossia -16 pixel, in quanto i "primi" 16 pixel
				; sono "coperti" e dobbiamo "saltarli",
				; spostando la PIC in avanti, appunto, di 16
				; pixel
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	bsr.w	print		; Stampa le linee di testo sul playfield
				; largo 640 pixel (80 byte per linea)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	btst	#2,$dff016	; Tasto destro?
	beq.w	Aspetta		; Se si, non scrollare

	bsr.w	MEGAScrolla	; Scorrimento orizzontale di una figura larga
				; 640 pixel in uno schermo largo 320 pixel.

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

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

; La routine Megascrolla serve solamente ad eseguire 320 volte la routine gia'
; vista "Destra:", dopodiche' eseguire 320 volte la routine "Sinistra:" per
; riportare la figura alla posizione iniziale, di qua il ciclo riparte ecc.
; Per tenere il conto del numero di volte che ha eseguito "Destra:" o
; "Sinistra:" utilizza la word "Contavolte" a cui addiziona "1" ogni FRAME;
; essendo lo schermo video largo 320 pixel e la figura in memoria larga 640,
; per scorrerla occorrera' spostarsi di 320 pixel:
;
; All'inizio:
;	 _______________________________
;	|		|		|
;	| schermo video |		|
;	| <-   320   -> |		|
;	|		|		|
;	| <- immagine in memoria 640 -> |
;	|		|		|
;	|		|		|
;	 -------------------------------
;
; Quando abbiamo "scrollato" di 320 pixel a Destra:
;	 _______________________________
;	|		|		|
;	| 		| schermo video |
;	|		| <-   320   -> |
;	|		|		|
;	| <- immagine in memoria 640 -> |
;	|		|		|
;	|		|		|
;	 -------------------------------
;
; Poi altri 320 pixel verso sinistra e torniamo a vedere i primi 320 pixel
; della figura larga 640.
; Tramite il bit 1 della word DestSinFlag viene segnalato se e' necessario
; andare verso destra o verso sinistra. Per scambiare il valore del bit, da
; ZERO ad UNO o da UNO a ZERO e' usata l'istruzione BCHG, ossia BIT CHANGE,
; gia' vista in un'altro listato.

MEGAScrolla:
	addq.w	#1,ContaVolte	; Segnamo una esecuzione in piu'
	cmp.w	#320,ContaVolte	; Siamo a 320?
	bne.S	MuoviAncora	; Se non ancora, sposta ancora
	BCHG.B	#1,DestSinFlag	; Se siamo a 320, invece, cambia direzione
	CLR.w	ContaVolte	; di scorrimento e azzera "ContaVolte"
	rts

MuoviAncora:
	BTST	#1,DestSinFlag	; Dobbiamo andare a destra o a sinistra?
	BEQ.S	VaiSinistra
	bsr.s	Destra		; Scorri un pixel verso destra
	rts

VaiSinistra:
	bsr.s	Sinistra	; Scorri un pixel verso sinistra
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

	subq.l	#2,d0		; punta 16 bit piu' indietro ( la PIC scorre
				; verso destra di 16 pixel)
	clr.b	MIOBPCON1	; azzera lo scroll hardware BPLCON1 ($dff102)
				; infatti abbiamo "saltato" 16 pixel con il
				; bitplane pointer, ora dobbiamo ricominciare
				; da zero con il $dff102 per scattare a
				; destra di un pixel alla volta.

	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
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

	addq.l	#2,d0		; punta 16 bit piu' avanti ( la PIC scorre
				; verso sinistra di 16 pixel)
	move.b	#$FF,MIOBPCON1	; scroll hardware a 15 - BPLCON1 ($dff102)

	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	rts

CON1SUBBA:
	sub.b	#$11,MIOBPCON1	; scorri indietro di 1 pixe
	rts



;	Routine che stampa caratteri larghi 8x8 pixel (su schermo HIRES)

PRINT:
	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	MOVEQ	#25-1,D3	; NUMERO RIGHE DA STAMPARE: 25
PRINTRIGA:
	MOVEQ	#80-1,D0	; NUMERO COLONNE PER RIGA: 80 (hires!)
PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,80(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,80*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,80*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,80*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,80*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,80*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,80*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (80) CARATTERI PER RIGA

	ADD.W	#80*7,A3	; ANDIAMO A CAPO

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE

	RTS


		; numero caratteri per linea: 80, dunque 2 di queste da 40!
TESTO:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	'   PRIMA RIGA  IN HIRES 640 PIXEL DI LAR' ; 1a \ PRIMA RIGA
	dc.b	'GHEZZA!  -- -- --   SEMPRE LA PRIMA RIGA' ; 1b /
	dc.b	'                SECONDA RIGA            ' ; 2  \ SECONDA RIGA
	dc.b	'ANCORA SECONDA RIGA                     ' ;    /
	dc.b	'     /\  /                              ' ; 3
	dc.b	'                                        ' ;
	dc.b	'    /  \/                               ' ; 4
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 5
	dc.b	'                                        ' ;
	dc.b	'        SESTA RIGA                      ' ; 6
	dc.b	'                        FINE SESTA RIGA ' ;
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 8
	dc.b	'                                        ' ;
	dc.b	'FABIO CIUCCI COMMUNICATION INTERNATIONAL' ; 9
	dc.b	' MARKETING TRUST TRADEMARK COPYRIGHTED  ' ;
	dc.b	'                                        ' ; 10
	dc.b	'                                        ' ;
	dc.b	'   1234567890 !@#$%^&*()_+|\=-[]{}      ' ; 11
	dc.b	'   PROVE TECNICHE DI TRASMISSIONE       ' ;
	dc.b	'                                        ' ; 12
	dc.b	'                                        ' ;
	dc.b	'     LA PALINGENETICA OBLITERAZIONE DELL' ; 13
	dc.b	"'IO TRASCENDENTALE CHE SI IMMEDESIMA    " ;
	dc.b	'                                        ' ; 14
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 15
	dc.b	'                                        ' ;
	dc.b	'  Nel mezzo del cammin di nostra vita   ' ; 16
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 17
	dc.b	'                                        ' ;
	dc.b	'    Mi RitRoVaI pEr UnA sELva oScuRa    ' ; 18
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 19
	dc.b	'                                        ' ;
	dc.b	'    CHE LA DIRITTA VIA ERA SMARRITA     ' ; 20
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 21
	dc.b	'                                        ' ;
	dc.b	'  AHI Quanto a DIR QUAL ERA...          ' ; 22
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 23
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 24
	dc.b	'                                        ' ;
	dc.b	' C:\>_                                  ' ; 25
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 26
	dc.b	'                                        ' ;

	EVEN



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
	dc.w	$100,%0001001000000000	; bit 12 - 1 bitplane LOWRES

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	bitplane

	dc.w	$180,$103	; color0 - SFONDO
	dc.w	$182,$4ff	; color1 - SCRITTE

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
;	incbin	"metal.fnt"
;	incbin	"normal.fnt"
	incbin	"nice.fnt"


	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	80*256	; un bitplane largo 640x256 (come l'HIRES)

	end

In questo listato l'unica vera novita' sta nel fatto che scorriamo una figura
piu' grande dello schermo anziche' una grande 320 pixel.
Innanzitutto quando lo schermo e' in LOWRES con valori DDFSTART/STOP normali
il modulo "automatico" e' 40, ossia l'immagine viene considerata fatta di
linee di 40 bytes. Se invece abbiamo in memoria una figura larga 640 pixel,
come in questo caso, dobbiamo cambiare il modulo. Infatti il fatto che la
figura in memoria e' piu' grande non interessa al Copper, il quale visualizza
come sempre uno schermo in LOWRES con modulo 40. Noi possiamo pero' cambiare
il modulo tramite i registri BPL1MOD e BPL2MOD: il modulo viene aggiunto al
modulo corrente, che e' 40, dunque bastera' un:

	dc.w	$108,40		; Bpl1Mod (40 per la figura larga 640)
	dc.w	$10a,40		; Bpl2Mod

Per far "saltare" alla fine di ogni linea di 320 pixel (40 bytes) i 40 bytes
che sono "fuori video", facendo continuare la visualizzazione dall'inizio della
linea seguente:

	 40 bytes	  40 bytes (saltati ogni volta col modulo = 40)
	 _______________________________
	|		|		|
	| schermo video |		|
	| <-   320   -> |		|
	|		|		|
	| <- immagine in memoria 640 -> |
	|		|		|
	|		|		|
	 -------------------------------

Ora, avendo visualizzato la parte Destra della figura larga 640 pixel su uno
schermo largo 320 SEMPLICEMENTE mettendo i moduli a 40, dobbiamo fare la
stessa modifica dell'esempio Lezione6n.s per "nascondere" i primi 16 pixel
dove avviene l'errore di visualizzazione a cusa dello scroll.
Dobbiamo allora far partire lo schermo 16 pixel prima modificando il DDFSTART:

	dc.w	$92,$30			; DDFSTART = $30 (schermo che parte
					; 16 pixel prima, allungandosi a
					; 42 bytes per linea, 336 pixel di
					; larghezza, ma il DIWSTART "nasconde"
					; questi primi 16 pixel con l'errore.

E, in quanto abbiamo allargato lo schermo facendolo andare "a capo" ogni 42
bytes anziche' 40, e' necessario bilanciare sottraendo 2 ai moduli, che
nel nostro caso erano a 40, e andranno a 38:

	dc.w	$108,40-2	; Bpl1Mod (40 per la figura larga 640, il -2
	dc.w	$10a,40-2	; Bpl2Mod (per bilanciare il DDFSTART

In fondo non si puo' dire che uno scroll di questo tipo e' "difficile", l'unica
difficolta' sta nel ricordarsi di sistemare bene MODULI/DDFSTART/INDIRIZZO DEL
BITPLANE. Infatti c'e' anche un'altra "novita'" rispetto a Lezione6n.s:

; Attenzione! Per "centrare" l'immagine occorre puntare 2 bytes piu' indietro
; facendo scorrere in avanti la PIC di 16 pixel, infatti la figura comincia
; 16 pixel piu' indietro grazie al DDFSTART (zona "coperta" dove avviene
; l'errore di visualizzazione da nascondere).

	MOVE.L	#BITPLANE-2,d0	; in d0 mettiamo l'indirizzo del bitplane -2,
				; ossia -16 pixel, in quanto i "primi" 16 pixel
				; sono "coperti" e dobbiamo "saltarli",
				; spostando la PIC in avanti, appunto, di 16
				; pixel

Infatti abbiamo "nascosto" i primi 16 pixel, dunque nasconderemmo i primi 2
caratteri del testo, (8pixel ciascuno*2=16 pixel). Invece "spostando" la figura
in avanti di 16 pixel vediamo correttamente anche i primi 16 pixel e la figura
appare centrata, non spostata verso sinistra di 16 pixel come in Lezione6n.s.
Provate a togliere il -2 dal "MOVE.L #BITPLANE-2,d0" e mettete un ; alla
routine

;	bsr.w	MEGAScrolla

in modo da avere una figura FERMA e noterete che i primi 16 pixel mancano, e
ce ne sono 2 in piu' a destra, ossia la figura parte 16 pixel prima del normale
Per verificare cio', "scopriamo" i primi 16 pixel:

	dc.w	$8e,$2c71	; DiwStrt ($81-16=$71)

Ecco li' i primi 16 pixel "spariti!". Rimettete a posto il -2 e togliete il ;
dalla routine lasciando i primi 16 pixel "scoperti" e vedrete come l'errore
fatidico dello scroll avviene in sordina "dietro le quinte".

