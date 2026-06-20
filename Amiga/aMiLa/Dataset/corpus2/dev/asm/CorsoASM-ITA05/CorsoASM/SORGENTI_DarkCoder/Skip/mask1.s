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
; maggiori di $80. Commenti alla fine del sorgente
; I credits per il sorgente originale sono di Randy - RJ
; Ehi Randy spero che non te la prendi se miglioro il tuo lavoro!
; Friendship RULEZ! :)))) (The Dark Coder)
 
	SECTION	DK,code
	incdir	"/include/"
	include	"MVstartup.s"		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

START:
	lea	$dff000,a5
	move	#DMASET,dmacon(a5)	; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,cop1lc(a5)	; Puntiamo la nostra COP
	move	d0,copjmp1(a5)		; Facciamo partire la COP

mouse:

; notare il doppio controllo sulla sincronia
; necessario perche` la muovicopper richiede MENO di UNA rasterline su 68030
	move.l	#$1ff00,d1	; bit per la selezione tramite AND
	move.l	#$13000,d2	; linea da aspettare = $130, ossia 304
.Waity1
	move.l	vposr(a5),d0	; vposr e vhposr
	and.l	d1,d0		; seleziona solo i bit della pos. verticale
	cmp.l	d2,d0		; aspetta la linea $130 (304)
	bne.s	.waity1

.Waity2
	move.l	vposr(a5),d0
	and.l	d1,d0
	cmp.l	d2,d0
	beq.s	.waity2

	btst	#2,potinp(a5)	; tasto destro premuto?
	beq.s	.noMuovi	; se si non eseguire MuoviCopper
	bsr.s	MuoviCopper	; Routine che sfrutta il mascheramento del WAIT
.noMuovi

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************

MuoviCopper:
	tst.b	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei subq)
	beq.w	VAIGIU
	cmp.b	#$80,BARRA	; siamo arrivati alla linea $80?
	sne	SuGiu		; se si, siamo in cima e dobbiamo scendere
				; Nel codice di randy c'era una Beq che saltava
				; ad un pezzo di codice che azzerava il flag.
				; Usando la Scc si va piu` veloci e si
				; risparmia memoria. E` consigliabile usare
				; sempre la Scc per alterare i flag
	subq.b	#1,BARRA
	rts

VAIGIU:
	cmp.b	#$F0,BARRA	; siamo arrivati alla linea $F0?
	seq	SuGiu		; se si, siamo in fondo e dobbiamo risalire
				; Anche qui abbiamo sostituito la BEQ di
				; Randy con una SEQ
	addq.b	#1,BARRA
	rts

SuGiu:	dc.b	0	; flag direzione


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


BARRA:
	dc.w	$8407,$FFFE	; aspetto la linea $79 (WAIT NORMALE!)
				; questo wait e' il "BOSS" dei wait
				; mascherati seguenti, infatti lo seguono
				; come degli scagnozzi: se questo wait
				; scende di 1, tutti i wait mascherati
				; sottostanti scendono di 1, eccetera.

	dc.w	$180,$300	; inizio la barra rossa: rosso a 3

	dc.w	$80E1,$80FE	; Questa WAIT attende la fine di una riga.
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

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$900	; rosso a 9

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$c00	; rosso a 12

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$f00	; rosso a 15 (al massimo)

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$c00	; rosso a 12

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$900	; rosso a 9

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$600	; rosso a 6

	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$300	; rosso a 3

UltimaFineRiga:
	dc.w	$80E1,$80FE	; aspetta fine riga
	dc.w	$0001,$FFFE	; WAIT inutile che rallenta il copper

	dc.w	$180,$000	; colore NERO

	dc.w	$fd07,$FFFE	; aspetto la linea $FD
	dc.w	$180,$00a	; blu intensita' 10
	dc.w	$fe07,$FFFE	; linea seguente
	dc.w	$180,$00f	; blu intensita' massima (15)

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

Nel corso di Randy nella lezione11h4.s viene mostrato come realizzare una
barretta con il copper mediante delle WAIT con posizione verticale mascherata,
tecnica che permette di velocizzare l'aggiornamento della copperlist rispetto
al caso in cui vengono usate WAIT con posizioni verticali NON mascherate.

Nel sorgente viene anche asserita l'impossibilita` di adottare questa tecnica
nelle posizioni verticali comprese tra $80 e $FF. Citiamo direttamente dal
commento della lezione11h4.s:

"Quindi, si puo' dire che il mascheramento funziona nella parte alta dello
schermo da $00 a $7f circa, e sotto la zona NTSC, ossia dopo il $FFDF,$FFFE."

Ebbene questo e` falso!!!
Come spieghiamo anche nell'articolo "More Advanced Copper" su questo
numero di Infamia, e` possibilissimo usare il mascheramento nelle posizioni
comprese tra $80 e $FF con un semplicissimo accorgimento. Il problema, infatti
nasce dal fatto che il bit piu` alto della posizione verticale del copper
non e` mascherabile, e quindi viene usato dal copper per il confronto della
posizione specificata nella WAIT (o nella SKIP) e la posizione del pennello
elettronico.
Randy nel sorgente lezione11h4.s del suo corso utilizza delle WAIT con i 7 bit
bassi della posizione verticale mascherati per attendere la fine di una riga.
Le WAIT che Randy utilizza sono delle DC.W $00E1,$80FE, che hanno il bit 8
della posizione verticale da attendere (cioe` il bit 15 della prima WORD)
settato a 0. Se una tale WAIT viene eseguita quando il pennello elettronico si
trova ad una posizione verticale con il bit 8 settato a 0 (cioe` minore di $80
o maggiore di $FF), essendo i bit 8 di valore uguale e poiche` gli altri bit
della posizione verticale sono disabilitati, si tiene conto della posizione
orizzontale, e pertanto la WAIT attende la fine della riga come voluto.
Se invece una tale WAIT viene eseguita quando il pennello elettronico si
trova ad una posizione verticale con il bit 8 settato a 1 (cioe` maggiore o
uguale ad $80 e minore o uguale a $FF), essendo il bit 8 della pos. verticale
del pennello elettronico maggiore del bit 8 della posizione specificata nella
WAIT, il copper considera la posizione specificata dalla WAIT minore di quella
del pennello elettronico e NON aspetta la fine della riga.
Come si fa allora ad aspettare la fine di una riga la cui pos. verticale ha il
bit 8 settato a 1? E` molto semplice, mediante una WAIT cosi` composta:

  DC.W $80E1,$80FE

Questa WAIT si differenzia da quella usata da Randy perche` ha il bit 8 della
posizione verticale settato a 1. In questo modo, se viene eseguita quando il
pennello elettronico si trova ad una posizione verticale con il bit 8 settato
a 1 essendo i bit 8 di valore uguale e poiche` gli altri bit della posizione
verticale sono disabilitati, si tiene conto della posizione orizzontale, e
pertanto la WAIT attende la fine della riga come voluto.
Utilizzando WAIT di questo tipo possiamo applicare la tecnica descritta
nel sorgente lezione11h4.s per muovere la barretta nelle righe comprese tra
$80 e $FF. Notate pero` che WAIT di questo tipo NON funzionano nelle righe
aventi il bit 8 della posizione verticale settato a 0. Infatti, se eseguite in
tali righe, essendo il bit 8 della pos. verticale del pennello elettronico
minore del bit 8 della posizione specificata nella WAIT, il copper considera la
posizione specificata dalla WAIT maggiore di quella del pennello elettronico e
pertanto RIMANE BLOCCATO SULLA WAIT fino a che il pennello elettronico non
raggiunge una riga con il bit 8 settato a 1 ($80) o la copperlist non riparte
da capo. Quindi con le WAIT usate in questo sorgente possiamo far muovere la
barretta SOLO nelle righe comprese tra $80 e $FF. Provare per credere.

Come facciamo allora a muovere una barretta in TUTTO lo schermo ?
Lo vedremo nell'esempio "mask2.s". Intanto vi faccio notare che nella
nostra copperlist abbiamo una ulteriore differenza rispetto a quella di
Randy. Infatti Randy utilizza una coppia di WAIT:

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

La prima WAIT aspetta la fine di una riga. Poiche` pero` come sapete sullo
schermo una riga inizia fisicamente quando il copper ha raggiunto gia` la
posizione $7, se dopo la prima WAIT ci fosse subito la Copper MOVE che cambia
COLOR00, si vedrebbe il cambio di colore sul bordo destro dello schermo
(di nuovo provare per credere). Per questo e` necessaria la seconda WAIT che
aspetta la posizione $7. Notate pero` che il copper ci impiega poco tempo
a passare dalla posizione $E1 alla posizione $7 della riga seguente. Pertanto
per evitare l'effetto indesiderato si puo` adottare anche un'altra soluzione:
interporre tra la WAIT che aspetta la fine della riga e la CMOVE che cambia
COLOR00 una istruzione copper che non fa nulla, per esempio una WAIT (NON
mascherata) che attende la posizione 0,0 e pertanto viene sempre passata.
Anche se l'istruzione e` inutile, il copper deve perdere un po' di tempo
per eseguirla, e questa perdita di tempo e` sufficiente affinche` nel
frattempo il pennello elettronico raggiunga la posizione $7, quindi la CMOVE in
COLOR00 viene eseguita in una posizione tale che viene evitato il difetto del
cambio di colore al bordo destro. In questo esempio abbiamo adottato questa
tecnica, quindi al posto delle DC.W $0007,$80FE di Randy abbiamo messo delle
semplici e NON mascherate WAIT alla riga 0, ovvero delle DC.W $0001,$FFFE.
Perche` l'abbiamo fatto? Lo scoprirete nell'esempio "mask2.s" !!!!
