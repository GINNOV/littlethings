
; Lezione9g3.s	Ancora le mattonelle, stavolta pero` con lo schermo INTERLEAVED
;		La temporizzazione col Wblank fa in modo che venga
;		blittata solo una FILA per fotogramma.
;		Tasto sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#2-1,D1		; numero di bitplanes (qua sono 2)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
				; QUI C'E` LA UNA DIFFERENZA RISPETTO
				; ALLE IMMAGINI NORMALI!!!!!!
	ADD.L	#40,d0		; + LUNGHEZZA DI UNA RIGA !!!!!
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	bsr.s	fillmem		; esegui la routine di "piastrellatura"

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts

*****************************************************************************
; Routine che esegue la piastrellatura
*****************************************************************************

;	    ________
;	   (___  ___)
;	  (¡ (°)(°) ¡)
;	  `| ¯(··)¯ |'
;	   |  /¬¬\  | xCz
;	   l__¯¯¯¯__!
;	  ___T¯¯¯¯T___
;	 /   `----'  ¬\
;	·              ·

fillmem:
	lea	Bitplane,a0	; bitplanes
	lea	gfxdata,a3	; ind. figura

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo
	move.w	#0,$64(a5)		; BLTAMOD = 0
	move.w	#38,$66(a5)		; BLTDMOD (40-2=38), infatti ogni
					; "mattonella" e' larga 16 pixel,
					; cioe' 2 bytes, che dobbiamo togliere
					; alla larghezza totale di una linea,
					; cioe' 40, e il risultato e' 40-2=38!
	move.w	#$0000,$42(a5)		; BLTCON1 - lo spiegheremo dopo
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)

	moveq	#16-1,d7		; 16 file di blocchi per arrivare
					; verticalmente fino in fondo, infatti
					; le mattonelle sono alte 15 pixel,
					; piu' 1 di "spaziatura" tra una e
					; l'altra, sotto ognuna, fa un
					; ingombro di 16 pixel per piastrella,
					; dunque 256/16=16 mattonelle.
FaiTutteLeRighe:
	moveq	#20-1,d6		; 20 blocchi per linea (fila), infatti,
					; essendo le mattonelle larghe 16
					; pixel, cioe' 2 bytes, ne deriva che
					; ce ne possono stare 320/16=20 per
					; linea orizzontale.

; aspetta il vblank una volta ogni riga disegnata.
WaitWblank:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

FaiUnaRigaLoop:

; Blitta il primo bitplane di una mattonella

	move.l	a0,$54(a5)		; BLTDPT - destinazione (bitpl 1)
	move.l	a3,$50(a5)		; BLTAPT - sorgente (fig1)
	move.w	#(2*15*64)+1,$58(a5)	; BLTSIZE - altezza: 2 planes
					; alti 15 righe
					; larghezza 1 word

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2


	addq.w	#2,a0	; salta 1 word (16 pixel) nel bitplane 1, scattando
			; in "avanti" per la prossima mattonella
	dbra	d6,FaiUnaRigaLoop	; e cicla fino a che non sono state
					; blittate tutte le 20 mattonelle
					; di una riga.
 
	lea	40+2*15*40(a0),a0
				; A forza di ADDQ #2,A0, abbiamo incrementato
				; il puntatore a0 fino a superare l'ultima word
				; della riga 0, plane 1. Quindi siamo arrivati
				; alla prima word della riga 0, plane 2.
				; Ora ci vogliamo spostare alla prima word
				; della riga 16, plane 1. Dobbiamo quindi
				; sommare ad A0: 40 per spostarci sulla prima
				; word della riga 1, plane 1 e poi 2*15*40
				; per spostarci dove vogliamo.

	dbra	d7,FaiTutteLeRighe	; fai tutte le 16 righe
 	rts

*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2

				; QUI C'E` UNA DIFFERENZA RISPETTO
				; ALLE IMMAGINI NORMALI!!!!!!
	dc.w	$108,40		; VALORE MODULO = 2*20*(2-1)= 40
	dc.w	$10a,40		; ENTRAMBI I MODULI ALLO STESSO VALORE.

	dc.w	$100,$2200	; bplcon0 - 3 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000

	dc.w $180,$000	; Color0
	dc.w $182,$FED	; Color1
	dc.w $184,$33a	; Color2
	dc.w $186,$888	; Color3

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Figura, composta da 2 biplanes. larghezza = 1 word, altezza = 15 linee

**************************************************************************
; Figura della mattonella

; Si tratta della stessa figura dell'esempio lezioine9f3.s solo che li`
; era in formato normale. Per metterla in formato interleaved sono state
; "mischiate" le righe.

gfxdata:
	dc.w	%1111111111111100	; riga 0, plane 1
	dc.w	%0000000000000010	; riga 0, plane 2
	dc.w	%1111111111111100	; riga 1, plane 1
	dc.w	%0111111111111110	; riga 1, plane 2
	dc.w	%1100000000001100	; riga 3, plane 1
	dc.w	%0111111111110110	; riga 3, plane 2
	dc.w	%1101111111111100
	dc.w	%0111111111110110
	dc.w	%1101111111111100
	dc.w	%0111000000010110
	dc.w	%1101111111011100
	dc.w	%0111011111110110
	dc.w	%1101110011011100
	dc.w	%0111011101110110
	dc.w	%1101110111011100
	dc.w	%0111011101110110
	dc.w	%1101111111011100
	dc.w	%0111010001110110
	dc.w	%1101111111011100
	dc.w	%0111011111110110
	dc.w	%1101100000011100
	dc.w	%0111011111110110
	dc.w	%1101111111111100
	dc.w	%0111111111110110
	dc.w	%1111111111111100
	dc.w	%0100000000000110
	dc.w	%1111111111111100
	dc.w	%0111111111111110
	dc.w	%0000000000000000	; riga 15, plane 1
	dc.w	%1111111111111110	; riga 15, plane 2

*****************************************************************************

	section	gnippi,bss_C

bitplane:
		ds.b	2*40*256	; 2 bitplanes

	end

*****************************************************************************

In questo esempio ritroviamo le mattonelle, stavolta in formato interleaved.
Come prima cosa notate come viene disposta in memoria la figura della
mattonella. Nell'esempio lezione9f3.s avevamo i 2 bitplanes separati.
Qui invece le righe sono mescolate tra loro.
Per quanto riguarda la routine, le mattonelle vengono copiate con una sola
blittata, mentre in lezione9f3.s dovevamo fare una blittata per ogni bitplane.
L'altezza della blittata e` pari al prodotto dell'altezza della figura
(15 linee) per il numero di bitplanes (2), come abbiamo spiegato nella lezione.
Anche il calcolo dell' indirizzo destinazione e` (naturalmente) diverso
(la sorgente e` fissa e pertanto resta sempre uguale). Le mattonelle sulla
stessa riga si trovano distanziate sempre di una word, come e` logico visto
che l'interleaved si differenzia solo per la disposizione delle righe.
La differenza si trova dopo il loop interno, quando siamo arrivati alla fine
di una fila orizzontale di mattonelle e dobbiamo iniziare la seguente.
Se indichiamo con Y la riga alla quale iniziamo a blittare, dobbiamo spostarci
alla riga Y+16.
Nel loop interno, aumentiamo il puntatore di 2 ogni volta, spostandoci in tal
modo di una word verso destra. Alla fine del loop ci troviamo subito dopo
l'ultima word della riga attuale, cioe` sulla prima word del plane 2
della riga Y. Per prima cosa dobbiamo spostarci sul plane 1 della riga Y+1,
aggiungendo 40 (numero di bytes occupati da UN plane di UNA riga).
A questo punto dobbiamo scendere di altre 15 righe.
Poiche` un plane di una riga occupa 40 bytes, e noi abbiamo 2 planes per ogni
riga, dobbiamo aggiungere 2*15*40.
Naturalmente, possiamo aggiungere in una volta sola entrambe le quantita`
facendo una LEA 40+15*2*40(A1),A1.

Riassumiamo la situazione con la seguente figura:

- All'inizio del loop interno il puntatore punta la word indicata con (0).
- Alla fine del loop interno il puntatore punta la word indicata con (1).
- Aggiungendo 40 il puntatore punta la word indicata con (2).
- Aggiungendo 2*40*15 ci spostiamo in basso di 15 righe e il puntatore punta
  la word indicata con (3) che e` la word che volevamo.
  (tra una riga e l'altra ci sono 2*40 bytes; se avessimo aggiunto solo 2*40
   ci saremmo spostati dalla word (2) alla word (2')).

riga Y     plane 1	| (0)  |      |      |    . . .   |      |
riga Y     plane 2	| (1)  |      |      |    . . .   |      |
riga Y+1   plane 1	| (2)  |      |      |    . . .   |      | \
riga Y+1   plane 2	|      |      |      |    . . .   |      |  |
riga Y+1   plane 1	| (2') |      |      |    . . .   |      |  |
riga Y+1   plane 2	|      |      |      |    . . .   |      |  |
								    |
.								    |
								    | 15 righe
.								    |
								    |
.								    |
								    |
								   /
riga Y+16  plane 1	| (3)  |      |      |    . . .   |      |
riga Y+16  plane 2	|      |      |      |    . . .   |      |

