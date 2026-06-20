
; Lezione9a1.s - AZZERAMENTO DI $10 words tramite il BLITTER
; Prima di vedere questo esempio, date un'occhiata a LEZIONE2f.s dove viene
; cancellata memoria con il 68000

	SECTION Blit,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName,a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,a6		; usa una routine della graphics library:

	jsr	-$1c8(a6)	; OwnBlitter, che ci da l'esclusiva sul blitter
				; impedendone l'uso al sistema operativo.

				; Prima di usare il blitter dobbiamo attendere
				; che esso termini eventuali blittate in corso.
				; Se ne occupano le istruzioni seguenti

	btst	#6,$dff002	; attendi che il blitter finisca (test a vuoto)
				; per il BUG di Agnus
waitblit:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit

; Ecco come fare una blittata!!! Solo 5 istruzioni per azzerare!!!

;	     __
;	__  /_/\   __
;	\/  \_\/  /\_\
;	 __   __  \/_/   __
;	/\_\ /\_\  __   /\_\
;	\/_/ \/_/ /_/\  \/_/
;	     __   \_\/
;	    /\_\  __
;	    \/_/  \/

	move.w	#$0100,$dff040	 ; BLTCON0: solo DESTINAZIONE attivata
				 ; i MINTERMS (cioe` i bits 0-7) sono tutti
				 ; azzerati. In questo modo si definisce
				 ; l'operazione di cancellazione

	move.w	#$0000,$dff042	 ; BLTCON1: questo registro lo spiegheremo dopo
	move.l	#START,$dff054	 ; BLTDPT: Indirizzo del canale di destinazione
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

******************************************************************************

	SECTION THE_DATA,DATA_C

; notate che i dati che cancelliamo devono essere in memoria CHIP
; infatti il Blitter opera solo in memoria CHIP

START:
	dcb.b	$20,$fe
THEEND:
	dc.b	'Qui non cancelliamo'

	even

GfxName:
	dc.b	"graphics.library",0,0

	end

Questo esempio e' la versione per blitter del listato Lezione2f.s, in cui si
azzeravano dei bytes tramite un loop di "clr.l (a0)+".

Come in quel caso, assemblate, senza Jumpare, e controllate con un "M START"
che sotto tale label sono assemblati $20 bytes "$fe". A questo punto eseguite
il listato, attivando, per la prima volta nel corso, il blitter, dopodiche'
rifate "M START" e verificherete che tali bytes sono stati azzerati, fino alla
label THEEND, infatti con un "N THEEND" troverete la scritta sempre al suo
posto.

L'operazione di cancellazione richiede l'uso del solo canale D.
Inoltre e` necessario azzerare tutti i MINTERMS. Pertanto il valore da caricare
nel registro BLTCON0 e` $0100.
Notate bene il valore che viene scritto nel registro BLTSIZE. Dobbiamo
cancellare un rettangolo largo $10 words e alto una riga. Dobbiamo scrivere
la larghezza nei bit 0-5 di BLTSIZE e l'altezza nei bit 6-15 sempre di BLTSIZE.
Per scrivere l'altezza nei bit 6-15 possiamo quindi shiftarla a sinistra di
6 bit, il che equivale a moltiplicarla per 64. Dunque per scrivere le
dimensioni del rettangolo da blittare nel registro BLTSIZE si usa la seguente
formula:

Valore da scrivere in BLTSIZE = (ALTEZZA*64)+LARGHEZZA

Vi ricordo che la LARGHEZZA e` espressa in words.

NOTA: E' stata usata una funzione del sistema operativo che non abbiamo mai
trattato prima, cioe' quella che impedisce l'uso del blitter al sistema
operativo per evitare di usare il blitter quando anche il workbench lo usa.
Per inibire e riattivare l'uso del blitter da parte del sistema operativo basta
eseguire le apposite routines gia' pronte nel kickstart, piu' in particolare
nella graphics.library: avendo in A6 il GFXBASE, bastera' eseguire un

	jsr	-$1c8(a6)	; OwnBlitter, che ci da l'esclusiva sul blitter

Per garantirci che siamo i soli a cercare il blitter, mentre un

	jsr	-$1ce(a6)	; DisOwnBlitter, il sistema operativo ora
				; puo' nuovamente usare il blitter

sara' necessario prima di uscire dal programma per riattivare il workbench.

Dunque basta ricordarsi che quando usiamo il blitter nei nostri capolavori e'
necessario aggiungere l'OwnBlitter all'inizio e il DisownBlitter alla fine,
oltre al noto Disable ed Enable.

