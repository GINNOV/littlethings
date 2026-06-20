		************************************
		*       /\/\                       *
		*      /    \                      *
		*     / /\/\ \ O R B_I D           *
		*    / /    \ \   / /              *
		*   / /    __\ \ / /               *
		*   ¯¯     \ \¯¯/ / I S I O N S    *
		*           \ \/ /                 *
		*            \  /                  *
		*             \/                   *
		*     Feel the DEATH inside!       *
		************************************
		* Coded by:                        *
		* The Dark Coder / Morbid Visions  *
		************************************

* ATTENZIONE:
; Questo sorgente e` basato sulla Lezione11h4.s del Corso di Randy
; Mostra come effettuare il mascheramento anche per posizioni verticali
; in TUTTO lo schermo. Commenti alla fine del sorgente
; I credits per il sorgente originale sono di Randy - RJ
; Ehi Randy spero che non te la prendi se miglioro il tuo lavoro!
; Friendship RULEZ! :)))) (The Dark Coder)
 
	SECTION	DK,code
	incdir	"/include/"
	include	MVstartup.s		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

START:
	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
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

	btst	#2,$dff016	; tasto destro premuto?
	beq.s	Mouse2		; se si non eseguire MuoviCopper

	bsr.s	MuoviCopper	; Routine che sfrutta il mascheramento del WAIT

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************

MuoviCopper:
	move	PosBarra(pc),d0	; legge posizione Barra

	tst.b	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei subq)
	beq.w	VAIGIU

	cmp	#$34,d0		; confronta con il limite in alto
	sne	SuGiu		; setta di conseguenza il flag

; aggiorna posizione barra nella variabile e nella CLIST
	move	PosBarra(pc),d0
	subq	#1,d0
	move	d0,PosBarra
	move.b	d0,Barra	; scrive byte basso nella copperlist

; la seconda WAIT 255 deve essere attivata quando l'ultima riga della
; barretta si trova alla riga $FE, ovvero quando PosBarra=$fe-8
	cmp	#$fe-8,d0
	bne.s	.NoAttiva2		; se la barretta inizia ad attraversare
	move.b	#$ff,Attendi255_2	; riga 255 abilita la seconda WAIT 255
	bra.s	.change			; salta il controllo di riga $100
.NoAttiva2

; la prima WAIT 255 deve essere attivata quando la prima riga della
; barretta si trova alla riga $ff
	cmp	#$ff,d0
	bne.s	.NoDisattiva1		; se TUTTA la barretta ha attraversato 
	move.b	#$00,Attendi255_1	; riga 255, disattiva la prima WAIT 255
.NoDisattiva1

.change
	move	#$7f,d0
	bsr	AdjustClist

	move	#$ff,d0
	bsr	AdjustClist

	rts

VAIGIU:
	cmp	#$114,d0	; confronta con il limite in basso
	seq	SuGiu		; setta di conseguenza il flag

; aggiorna posizione barra nella variabile e nella CLIST
	move	PosBarra(pc),d0
	addq	#1,d0
	move	d0,PosBarra
	move.b	d0,Barra	; scrive byte basso nella copperlist

; la seconda WAIT 255 deve essere disattivata quando l'ultima riga della
; barretta si trova alla riga $FF, ovvero quando PosBarra=$ff-8
	cmp	#$ff-8,d0
	bne.s	.NoDisattiva2	; se la barretta inizia ad attraversare la
	move.b	#0,Attendi255_2	; riga 255 disabilita la seconda WAIT 255
	bra.s	.change		; salta il controllo di riga $100
.NoDisattiva2

; la prima WAIT 255 deve essere attivata quando la prima riga della
; barretta si trova alla riga $100
	cmp	#$100,d0
	bne.s	.NoAttiva1		; se TUTTA la barretta ha attraversato 
	move.b	#$ff,Attendi255_1	; riga 255, attiva la prima WAIT 255
.NoAttiva1

.change
	move	#$80,d0
	bsr	AdjustClist

	move	#$100,d0
	bsr	AdjustClist

	rts


Finito:
	rts

; variabili
PosBarra	dc.w	$34	; posizione barra
SuGiu:		dc.b	0	; flag direzione


*******************************
* Routine che corregge la CLIST
* D0 - riga target, cioe` riga che delimita l'ingresso in una diversa
* zona dello schermo.

	cnop	0,4
AdjustClist
	move	PosBarra(pc),d1	; coordinata prima riga barra
	move	d1,d2

	addq	#8,d2		; posizione ultima riga barra (sono 9 righe)
	cmp	d0,d2		; confronta con riga target
	blo.s	.exit		; se minore, la barra si trova TUTTA
				; al di sopra della riga target

	sub	d1,d0		; sottrae la pos dalla riga target
	blo.s	.exit		; se D1>D0, la barra si trova TUTTA
				; al di sotto della riga target

				; altrimenti la differenza ci dice
				; quale riga della barra ha posizione uguale
				; a quella della riga target.

; in D0 c'e` indicato il numero d'ordine della WAIT da modificare:
; moltiplica per 12, offset tra 2 WAIT
	asl	#2,d0
	move	d0,d1
	add	d0,d0
	add	d1,d0

	lea	PrimaWaitMascherata,a0
	bchg	#7,(a0,d0.w)
	
.exit
	rts
	
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200
	dc.w	$180,$000	; Inizio la cop col colore NERO

	dc.w	$2c07,$FFFE	; una piccola barretta fissa verde
	dc.w	$180,$010
	dc.w	$2d07,$FFFE
	dc.w	$180,$020
	dc.w	$2e07,$FFFE
	dc.w	$180,$030
	dc.w	$2f07,$FFFE
	dc.w	$180,$040
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000

Attendi255_1:
	dc.w	$00E1,$FFFE	; aspetta linea 255

BARRA:
	dc.w	$3407,$FFFE	; aspetto la linea $79 (WAIT NORMALE!)
				; questo wait e' il "BOSS" dei wait
				; mascherati seguenti, infatti lo seguono
				; come degli scagnozzi: se questo wait
				; scende di 1, tutti i wait mascherati
				; sottostanti scendono di 1, eccetera.

	dc.w	$180,$300	; inizio la barra rossa: rosso a 3

PrimaWaitMascherata:
	dc.w	$00E1,$80FE	; Questa WAIT attende la fine di una riga.
				; Si tratta di una WAIT con posizione
				; verticale mascherata. Poiche` questa
				; istruzione va eseguita DOPO la riga
				; $80, il bit alto (non mascherabile)
				; deve essere settato a 1.

	dc.w	$0001,$FFFE	; questa WAIT e` un istruzione "inutile"
				; infatti non blocca mai il copper.
				; Il suo scopo e` quello di far perdere
				; un po' di tempo al copper in maniera che
				; la seguente CMOVE venga eseguita quando
				; il pennello elettronico ha iniziato la
				; riga seguente.

	dc.w	$180,$600	; rosso a 6

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$900	; rosso a 9

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$c00	; rosso a 12

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$f00	; rosso a 15 (al massimo)

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$c00	; rosso a 12

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$900	; rosso a 9

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$600	; rosso a 6

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$300	; rosso a 3

	dc.w	$00E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$000	; colore NERO

Attendi255_2:
	dc.w	$FFE1,$FFFE	; aspetta linea 255

	dc.w	$2007,$FFFE	; aspetto la linea $FD
	dc.w	$180,$00a	; blu intensita' 10
	dc.w	$2107,$FFFE	; linea seguente
	dc.w	$180,$00f	; blu intensita' massima (15)

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

In questo esempio mostriamo come usare il mascheramento della posizione
verticale in TUTTO lo schermo. Abbiamo la solita barretta che stavolta si
muove lungo tutto lo schermo. Come sappiamo per usare le WAIT con Y maschera-
ta si deve porre il bit 8 della posizione specificata allo stesso valore della
posizione verticale in cui vogliamo che l'istruzione venga eseguita.
Per comodita`, nel seguito indicheremo come zona 1 dello schermo le righe
da 0 a $7F, zona 2 le righe da $80 a $FF e zona 3 le righe da $100 in poi.

Se abbiamo delle copperlist dinamiche tali che una WAIT mascherata puo`
essere eseguita in qualunque posizione dello schermo, l'unica possibilita`
e` quella di modificare "al volo" le WAIT mascherate. Come abbiamo detto
in skip1.s, rispetto al codice di Randy abbiamo sostituito delle WAIT
mascherate DC.W $0007,$80FE con delle semplici e NON mascherate WAIT
DC.W $0001,$FFFE che fanno la stessa cosa. In questo modo abbiamo dimezzato
il numero di WAIT mascherate presenti nella CLIST e di conseguenza anche
il numero di modifiche da fare! Nel nostro caso infatti dobbiamo modificare
solo delle WAIT che aspettano la fine di una riga. Quando dobbiamo aspettare la
fine di una riga nelle zone 1 o 3 dobbiamo avere DC.W $00E1,$80FE mentre nel
caso in cui aspettiamo in zona 2 ci serve DC.W $80E1,$80FE.
Quindi dobbiamo settare opportunamente il bit 8 di tale istruzione.

I piu` attenti si chiederanno subito:"Ma chi ce lo fa fare a sto' punto ad
usare la WAIT mascherate se dobbiamo modificare comunque la CLIST?".
L'osservazione e` giusta, infatti come ricorderete questo effetto puo`
essere realizzato anche con WAIT non mascherate, e il vantaggio delle WAIT
non mascherate e` proprio quello di non dover modificare TUTTE le WAIT ad ogni
frame. Tuttavia le modifiche da apportare alle WAIT non mascherate sono molto
minori. Infatti e` necessario invertire il bit 8 della posizione verticale
di una WAIT SOLAMENTE quando tale WAIT passa da zona 1 a zona 2 (o viceversa)
o quando passa da zona 2 a zona 3 (o viceversa), cosa che accade solo
occasionalmente. Inoltre, se come in questo caso la barretta si sposta di 1
sola riga ogni frame, e` evidente che di tutte le WAIT che compongono la
barretta al massimo UNA SOLA WAIT passera` da una zona all'altra. Riassumendo,
nel caso in cui utilizziamo delle WAIT non mascherate dobbiamo modificare
TUTTE le WAIT AD OGNI frame. Con le WAIT NON mascherate invece modifichiamo
UNA WAIT in POCHISSIMI frame. E` dunque evidente che le WAIT NON mascherate
sono ancora molto vantaggiose.

Vediamo la realizzazione pratica. Come detto ogni volta che una WAIT transita
da una zona ad un'altra dobbiamo cambiare un bit, ovvero possiamo semplicemente
invertirlo. Nel passaggio da zona 2 a zona 3, abbiamo un problema in piu`:
l'istruzione WAIT che aspetta la riga 255.

Vediamo per prima cosa come modificare le WAIT. Tutte le modifiche sono gestite
da un'unica routine che va bene in tutti i casi, alla quale viene passato come
parametro la riga "target" ovvero la riga che determina il passaggio da una
zona ad un'altra. Tale routine determina l'EVENTUALE passaggio di una delle
WAIT sopra la riga target e di conseguenza inverte lo stato del bit 8 della Y.
Notate che se SCENDIAMO dalla zona 1 alla zona 2, la riga target e` $80,
perche` non appena una WAIT viene eseguita sulla riga $80 il suo bit deve
essere settato a 1. Se invece SALIAMO dalla zona 2 alla zona 1 la riga target
diventa $7F, perche` non appena una WAIT viene eseguita sulla riga $80 il suo
bit deve essere settato a 0.
Ovviamente ad ogni iterazione la nostra routine (AdjustClist) deve essere
eseguita 2 volte, una volta per controllare il passaggio da zona 1 a zona 2
(o viceversa se andiamo nella direzione opposta) e una volta per controllare il
passaggio da zona 2 a zona 3 (o viceversa se andiamo nella direzione opposta).

Si potrebbe obiettare che dover eseguire (2 volte) questa routine puo` far
perdere il vantaggio di dover effettuare meno modifiche sulla CLIST (rispetto
al caso delle WAIT NON mascherate), ma non e` cosi`: infatti questa routine
ha un costo di esecuzione fisso, mentre nel caso delle WAIT NON mascherate
il numero di modifiche da fare e` pari al numero di righe che compongono la
barretta: pensate al caso di una barretta alta 60 righe!!
Inoltre la routine e` cortissima e` viene eseguita in CACHE (se c'e`) e fa
(eventualmente) un solo accesso alla CHIP (la modifica della clist), mentre
nel caso NON mascherato ogni modifica di una WAIT e` un accesso in CHIP.

Come detto, il passaggio da zona 2 a zona 3 ci pone un altro problema.
Nella copperlist in fatti c'e` una WAIT che attende la riga $FF (255).
E` evidente che se la nostra barretta si trova piu` in alto, tale WAIT deve
essere eseguita DOPO le istruzioni della barretta, mentre deve essere eseguita
prima se la barretta si trova in zona 3. Per risolvere questo problema
utilizziamo 2 WAIT che attendono tale riga, una prima e una dopo le istruzioni
della barretta e ne abilitiamo una alla volta. Come facciamo per disabilitare
e abilitare una WAIT? Semplice, basta modificarla mettendo come posizione Y 0
invece che 255 per disabilitarla, e rimettere 255 per abilitarla.
Notate che quando la barretta si trova in parte in zona 2 e in parte in
zona 3, nessuna delle 2 WAIT deve essere abilitata, perche` l'attesa di riga
255 e` fatta dalle WAIT dalla barretta stessa. Quindi (nel caso in cui si
scende da zona 2 a 3) quando la barretta si trova in zona 1 e 2 la prima WAIT
e` disabilitata e la seconda abilitata. Nel momento in cui l'ultima riga della
barra si trova alla riga $FF la WAIT dopo la barretta viene disabilitata,
fintanto che la barra si trova a cavallo tra le 2 zone entrambe le wait restano
disabilitate e quando la prima riga della barra si trova alla riga $100 la
prima WAIT viene abilitata. Nel caso in cui si sale queste azioni si succedono
in maniera opposta.
