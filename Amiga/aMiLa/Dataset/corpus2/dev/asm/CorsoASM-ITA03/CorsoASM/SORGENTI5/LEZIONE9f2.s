
; Lezione9f2.s	Scrittura caratteri col blitter

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

;	Puntiamo la PIC "vuota"
	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#2-1,D1		; numero di bitplanes (qua sono 2)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	bsr.w	Stampa		; Stampa le linee di testo sullo schermo

	LEA	TESTO2(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE2,A3	; Indirizzo del bitplane destinazione in a3
	bsr.w	Stampa		; Stampa le linee di testo sullo schermo

mouse:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	rts


;***************************************************************************
;	Routine che stampa caratteri larghi 16x20 pixel
;
;	A0 = punta alla mappa che contiene i caratteri da stampare
;	A3 = punta al bitplane su cui stampare
;***************************************************************************

;	........................
;	:     .______.         :
;	:     l_  _ ¬l    xCz  ¦
;	¦     C©)(®) ·)        |
;	|     l¯C.   T .       |
;	|    __¯¯¯¯) l ::.     |
;	|   (__¯¯¯¯__) ::::.   |
;	¦    __T¯¯T__  ::::::. |
;	`---/  `--'  \---------'
;	    ¯¯¯¯¯¬¯¯¯¯

STAMPA:
	MOVEQ	#10-1,D3	; NUMERO RIGHE DA STAMPARE: 10

PRINTRIGA:
	MOVEQ	#20-1,D0	; NUMERO COLONNE PER RIGA: 20

PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	ADD.L	D2,D2		; MOLTIPLICA PER 2 IL NUMERO PRECEDENTE,
				; perche` ogni carattere e` largo 16 pixel.
				; In questo modo troviamo l'offset.
	MOVE.L	D2,A2

	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	btst	#6,$02(a5)	; aspetta che il blitter finisca
waitblit:
	btst	#6,$02(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0: copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

	move.l	a2,$50(a5)	; BLTAPT: indirizzo font (sorgente A)
	move.l	a3,$54(a5)	; BLTDPT; indirizzo bitplane (destinazione D)
	move	#120-2,$64(a5)	; BLTAMOD: modulo font
	move	#40-2,$66(a5)	; BLTDMOD: modulo bit planes
	move	#(20<<6)+1,$58(a5) ; BLTSIZE: 16 pixel, ossia 1 word di larg.
				   ; * 20 linee di altezza. Da notare che per
				   ; shiftare il 20 si e' usato il comodo
				   ; simbolo <<, che shifta a sinistra.
				   ; (20<<6) e' equivalente a (20*64).

	ADDQ.w	#2,A3		; A3+2,avanziamo di 16 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (20) CARATTERI PER RIGA

	ADD.W	#40*19,A3	; ANDIAMO A CAPO
				; ci spostiamo in basso di 19 righe.

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE
	RTS



; Attenzione! nel font sono disponibili solo questi caratteri:
;
; !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ

		; numero caratteri per linea: 20
TESTO:	        ;         11111111112
		;12345678901234567890
	dc.b	' PRIMA RIGA TESTO 1 ' ; 1
	dc.b	'                    ' ; 2
	dc.b	'     /   /          ' ; 3
	dc.b	'    /   /           ' ; 4
	dc.b	'                    ' ; 5
	dc.b	'S S A R G           ' ; 6
	dc.b	'                    ' ; 7
	dc.b	'                    ' ; 8
	dc.b	'FABIO CIUCCI        ' ; 9
	dc.b	'                    ' ; 10

	EVEN


		; numero caratteri per linea: 20
TESTO2:	        ;         11111111112
		;12345678901234567890
	dc.b	'                    ' ; 1
	dc.b	'SECONDA RIGA TESTO 2' ; 2
	dc.b	'     /   /          ' ; 3
	dc.b	'    /   /           ' ; 4
	dc.b	'                    ' ; 5
	dc.b	'SESTA RIGA          ' ; 6
	dc.b	'                    ' ; 7
	dc.b	'                    ' ; 8
	dc.b	'F B O C U C         ' ; 9
	dc.b	'    AMIGA RULEZ     ' ; 10

	EVEN

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

	dc.w	$100,$2200	; bplcon0 - 2 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
BPLPOINTERS2:
	dc.w $e4,0,$e6,0	;secondo bitplane

	dc.w	$180,$000	; color0 - SFONDO
	dc.w	$182,$19a	; color1 - SCRITTE primo bitplane
	dc.w	$184,$f62	; color2 - SCRITTE secondo bitplane
	dc.w	$186,$1e4	; color3 - SCRITTE primo+secondo bitplane

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;****************************************************************************

; Qui e` memorizzato il FONT di caratteri 16x20. IN CHIP RAM, perche' e'
; copiato col blitter, e non col processore!

FONT:
	incbin	"assembler2:sorgenti6/font16x20.raw"

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres
BITPLANE2:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio usiamo il blitter per stampare caratteri sullo schermo.
Vengono stampate 10 righe di 20 caratteri ciascuna.
Come sorgente abbiamo un font formato da un solo bitplane.
Lo schermo destinazione, invece, e` formato da 2 bitplanes: in questo modo
abbiamo a disposizione 3 colori per i caratteri (cioe` i colori 1,2 e 3,
perche` il colore 0 serve per lo sfondo).
Per stampare un carattere con il colore 1, lo copiamo solo nel bitplane 1, per
stamparlo con il colore 2 lo copiamo solo nel bitplane 2 e per stamparlo con
il colore 3 lo copiamo in entrambi i bitplanes.
Abbiamo fatto una cosa analoga nella Lezione6h.s usando il font 8x8.
La stampa avviene un bitplane per volta. Il testo da stampare e` contenuto
in 2 "mappe" ascii (una per bitplane) alle label TESTO e TESTO2.
Ogni "mappa" o paginata ascii sara' convertita byte per byte nell'offset da
aggiungere all'indirizzo del font per sapere quale carattere stampare. 
Il lavoro e` svolto dalla routine Stampa, che viene richiamata una volta per
ogni bitplane.
La routine e` composta da 2 cicli annidati (messi uno dentro l'altro).
Il ciclo piu` interno stampa una riga di caratteri da sinistra verso destra.
Il ciclo esterno ripete il ciclo interno 10 volte, facendo stampare dunque 10
righe in totale.
Esaminiamo ora in dettaglio come avviene la blittata.
Utiliziamo un font di 60 caratteri 16*20.
Il font e` contenuto in un bitplane "invisibile" (perche` non lo facciamo
puntare dai BPLxPT) largo 960 pixel e alto 20 righe, nel quale sono disegnati
tutti e 60 i caratteri uno di fianco all'altro (infatti 60*16=960) in
quest'ordine (quello ASCII):

 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ

E' presente il file Font16x20.iff che e' la figura originale del font.
Attenzione al fatto che mancano i caratteri dopo il sessantesimo:

	[\]^_`abcdefghijklmnopqrstuvwxyz{|}~

Se volete le lettere minuscole e altri simboli, fatevi un vostro font e una
vostra routine in grado di leggerlo. Fatevi il vostro "standard".
Poiche` i font sono larghi 1 word (16 pixel) e alti 20 righe, tale sara` la
dimensione della blittata. I moduli sono calcolati con la solita formula.
Il bitplane sorgente e` largo 60 words (cioe` 960 pixel, cioe` 120 bytes)
e quindi il modulo sorgente vale 2*(60-1)=120-2=118.
Il bitplane destinazione e` largo 20 words (cioe` 320 pixel, cioe` 40 bytes)
e quindi il modulo sorgente vale 2*(20-1)=40-2=38.
Vediamo come vengono gestiti i puntatori. Il puntatore alla destinazione varia
ad ogni blittata per disegnare il carattere in una diversa posizione dello
schermo, procedendo da sinistra a destra e dall'alto in basso.
Il meccanismo e` lo stesso che abbiamo visto nell'esempio lezione9c2.s.
Il puntatore alla sorgente invece deve puntare ogni volta al carattere che deve
essere stampato. I dati del bitplane sorgente sono organizzati cosi`:

INDIRIZZO	CONTENUTO
FONT		prima riga(16 pixel quindi 1 word) del carattere ' ' 
FONT+2 		prima riga del carattere '!'
FONT+4  	prima riga del carattere '"'

.
.
.
FONT+120  	prima riga del carattere 'Z'
FONT+122  	seconda riga del carattere ' '
FONT+124  	seconda riga del carattere '!'
.
.
.

FONT+2282 	ultima riga del carattere ' '
FONT+2284 	ultima riga del carattere '!'
.
FONT+2398 	ultima riga del carattere 'Z'


La routine legge dalla mappa il codice ASCII del carattere che deve stampare
e da esso calcola l'indirizzo. Il metodo e` molto simile a quello che abbiamo
visto nella lezione 6 quando abbiamo fatto la stessa cosa con il processore.
Dal codice ASCII possiamo ricavare la distanza del carattere dall'inizio del
font. Per farlo prima sottraiamo 32 (cioe` il codice ASCII dello spazio) al
codice ASCII del carattere che stamperemo, perche` il primo carattere del font
e` lo spazio. A questo punto procediamo diversamente dal metodo della lezione
6. Infatti il font della lezione 6 era disegnato "in verticale", cioe`:


!
"
#

ecc.

>
?
@
A
B
C
D
E
F
G

ecc.

In quel caso, quindi per calcolare l'indirizzo dovevamo moltiplicare il codice
ASCII (meno 32) per la quantita` di memoria occupata da un carattere.
In questo caso, invece, il font e` disegnato "in orizzontale", siccome a noi
interessa l'indirizzo della prima word del carattere da disegnare, dovremo
moltiplicare il codice ASCII (meno 32) per la quantita` di memoria occupata
dalla PRIMA RIGA di ogni carattere, in quanto la prima riga del carattere
che ci interessa e` memorizzata DOPO la prima riga dei caratteri che lo
precedono ma PRIMA di tutte le altre righe (a differenza del caso della lezione
6, nel quale tutte le righe di un carattere erano memorizzate prima del
carattere successivo). Siccome una riga occupa 2 byte (1 word = 16 pixel)
dobbiamo moltiplicare per 2, cosa che possiamo fare con una semplice ADD,
risparmiandoci una lenta MULU.

