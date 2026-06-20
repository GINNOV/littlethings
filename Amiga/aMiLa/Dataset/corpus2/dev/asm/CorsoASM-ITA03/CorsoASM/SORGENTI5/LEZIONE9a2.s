
; Lezione9a2.s - COPIA DI $10 words tramite il BLITTER

	SECTION Blit,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName,a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,a6		; usa una routine della graphics library:
	jsr	-$1c8(a6)	; OwnBlitter, che ci da l'esclusiva sul blitter
				; impedendone l'uso al sistema operativo.
	btst	#6,$dff002	; attendi che il blitter finisca (test a vuoto)
				; per il BUG di Agnus
waitblit:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit

; Ecco come fare una copia

;	   __&__
;	  /     \
;	 |      |
;	 |  (o)(o)
;	 c   .---_)
;	  | |.___|
;	  |  \__/
;	  /_____\
;	 /_____/ \
;	/         \

	move.w	#$09f0,$dff040	 ; BLTCON0: attivati canali A e D
				 ; i MINTERMS (cioe` i bits 0-7) assumono il
				 ; valore $f0. In questo modo si definisce
				 ; l'operazione di copia da A a D

	move.w	#$0000,$dff042	 ; BLTCON1: questo registro lo spiegheremo dopo
	move.l	#SORG,$dff050	 ; BLTAPT: Indirizzo del canale sorgente
	move.l	#DEST,$dff054	 ; BLTDPT: Indirizzo del canale di destinazione
	move.w	#$0000,$dff064	 ; BLTAMOD: questo registro lo spiegheremo dopo
	move.w	#$0000,$dff066	 ; BLTDMOD: questo registro lo spiegheremo dopo
	move.w	#(1*64)+$10,$dff058 ; BLTSIZE: definisce le dimensioni del
				    ; rettangolo. In questo caso abbiamo
				    ; larghezza $10 words e altezza 1 riga.
				    ; Poiche` l'altezza del rettangolo va
				    ; scritta nei bit 6-15 di BLTSIZE
				    ; dobbiamo shiftarla a sinistra di 6 bit.
				    ; Cio` equivale a moltiplicarne il valore
				    ; per 64. La larghezza viene espressa nei
				    ; 6 bit bassi e pertanto non viene 
				    ; modificata.
				    ; Inoltre questa istruzione da inizio
				    ; alla blittata

	btst	#6,$dff002	; attendi che il blitter finisca (test a vuoto)
waitblit2:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit2

	jsr	-$1ce(a6)	; DisOwnBlitter, il sistema operativo ora
				; puo' nuovamente usare il blitter
	move.l	a6,a1		; Base della libreria grafica da chiudere
	move.l	4.w,a6
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	rts

GfxName:
	dc.b	"graphics.library",0,0

******************************************************************************

	SECTION THE_DATA,DATA_C

; notate che i dati che copiamo devono essere in memoria CHIP
; infatti il Blitter opera solo in memoria CHIP

; questa e` la sorgente

SORG:
	dc.w	$1111,$2222,$3333,$4444,$5555,$6666,$7777,$aaaa
	dc.w	$8888,$2222,$3333,$4444,$5555,$6666,$7777,$ffff
THEEND1:
	dc.b	'Qui finisce la sorgente'
	even

; questa e' la destinazione

DEST:
	dcb.w	$10,$0000
THEEND2:
	dc.b	'Qui finisce la destinazione'

	even

	end

Questo esempio mostra una SEMPLICE copia con il blitter.
Assemblate, senza Jumpare, controllate con il comando dell'ASMONE "M SORG"
che a partire dall'indirizzo SORG ci siano in memoria $10 word che assumono
valori vari. Si tratta della sorgente della copia, cioe` della zona della quale
leggeremo i dati. Allo stesso modo, con il comando "M DEST" verificate che 
a partire dell'indirizzo DEST ci siano $10 word azzerate.

A questo punto eseguite l'esempio.
Ora, sempre con il comando ASMONE "M" andate a vedere quello che e` successo
in memoria: i dati all'indirizzo SORG sono rimasti gli stessi di prima.
Cio` e` normale perche` il blitter ha semplicemente letto quei dati, senza
modificarli. Le word a partire dall'indirizzo DEST, invece, ora non sono piu`
azzerate, ma hanno assunto gli stessi valori dei dati sorgente.

L'operazione di copia richiede l'uso di un canale in lettura e di uno in
scrittura. In questo caso usiamo A in lettura e D (ovviamente) per scrivere.
Per copiare dal canale A al canale D e` necessario porre i MINTERMS al valore
$f0. Pertanto il valore da caricare nel registro BLTCON0 e` $09f0.

Notate che avremmo potuto eseguire la copia usando un'altro canale (B o C)
per la lettura. Potete provare a farlo voi per esercizio. Le modifiche
da fare sono molto semplici:

- Abilitare il canale che volete usare invece che il canale A (bit 8-11 di
  BLTCON0)

- Cambiare il valore dei MINTERMS (bit 0-7 di BLTCON0) per indicare una copia
  dal canale che volete usare al canale D.
  Per copiare dal canale B al D il valore giusto e` $CC, mentre per la copia
  da C a D e` $AA.

- Scrivere l'indirizzo di partenza dei dati da copiare invece che nel puntatore
  al canale A (BLTAPT) nel puntatore al canale che volete usare. Gli indirizzi
  dei registri BLTBPT e BLTCPT sono riportati nella lezione.

