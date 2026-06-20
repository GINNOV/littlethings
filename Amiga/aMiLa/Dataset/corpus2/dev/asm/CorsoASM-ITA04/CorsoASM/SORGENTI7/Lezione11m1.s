
; Lezione11m1.s - Utilizzo dell'interrupt di livello 2 ($68) per leggere i
;		  codici dei tasti premuti sulla tastiera.
;		  PREMERE LO SPAZIO PER USCIRE

	Section	InterruptKey,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA abilitato

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR

	MOVE.L	#MioInt68KeyB,$68(A0)	; Routine per la tastiera int. liv. 2
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3

		; 76543210
	move.b	#%01111111,$bfed01	; CIAAICR - Disabilita tutte le CIA IRQ
	move.b	#%10001000,$bfed01	; CIAAICR - Attiva solo la SP CIA IRQ

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	movem.l	d0-d7/a0-a6,-(SP)
	bsr.w	mt_init		; inizializza la routine musicale
	movem.l	(SP)+,d0-d7/a0-a6

		; 5432109876543210
	move.w	#%1100000000101000,$9a(a5)    ; INTENA - abilito solo VERTB
					      ; del livello 3 e il livello2

AttendiSpazio:
	move.b	ActualKey(PC),d0 ; Prendi il codice dell'ultimo tasto premuto.
	move.b	d0,Color0+1	; Metti il cod. del carattere attuale come
				; color0... giusto per test..
	cmp.b	#$40,d0		; BARRA SPAZIO PREMUTA? (basta col mouse!)
	bne.s	AttendiSpazio

	bsr.w	mt_end		   ; fine del replay!
	move.b	#%10011111,$bfed01 ; CIAAICR - Riabilita tutte le CIA IRQ
	rts			   ; esci

; Variabile dove e' salvato il carattere attuale

ActualKey:
	dc.b	0

	even

*****************************************************************************
*	ROUTINE IN INTERRUPT $68 (livello 2) - gestione TASTIERA
*****************************************************************************

;03	PORTS	2 ($68)	Input/Output Porte e timers, connesso alla linea INT2

MioInt68KeyB:	; $68
	movem.l d0/a0,-(sp)	; salva i registri usati nello stack
	lea	$dff000,a0	; reg. custom per offset

	MOVE.B	$BFED01,D0	; Ciaa icr - in d0 (leggendo l'icr causiamo
				; anche il suo azzeramento, per cui l'int e'
				; "disdetto" come in intreq).
	BTST.l	#7,D0	; bit IR, (interrupt cia autorizzato), azzerato?
	BEQ.s	NonKey	; se si, esci
	BTST.l	#3,D0	; bit SP, (interrupt della tastiera), azzerato?
	BEQ.s	NonKey	; se si, esci

	MOVE.W	$1C(A0),D0	; INTENAR in d0
	BTST.l	#14,D0		; Bit Master di abilitazione azzerato?
	BEQ.s	NonKey		; Se si, interrupt non attivi!
	AND.W	$1E(A0),D0	; INREQR - in d1 rimangono settati solo i bit
				; che sono settati sia in INTENA che in INTREQ
				; in modo da essere sicuri che l'interrupt
				; avvenuto fosse abilitato.
	btst.l	#3,d0		; INTREQR - PORTS?
	beq.w	NonKey		; Se no, allora esci!

; Dopo i controlli, se siamo qua significa che dobbiamo prendere il carattere!

	moveq	#0,d0
	move.b	$bfec01,d0	; CIAA sdr (serial data register - connesso
				; alla tastiera - contiene il byte inviato dal
				; chip della tastiera) LEGGIAMO IL CHAR!

; abbiamo il char in d0, lo "lavoriamo"...

	NOT.B	D0		; aggiustiamo il valore invertendo i bit
	ROR.B	#1,D0		; e riportando la sequenza a 76543210.
	move.b	d0,ActualKey	; salviamo il carattere

; Ora dobbiamo comunicare alla tastiera che abbiamo preso il dato!

	bset.b	#6,$bfee01	; CIAA cra - sp ($bfec01) output, in modo da
				; abbassare la linea KDAT per confermare che
				; abbiamo ricevuto il carattere.

	st.b	$bfec01		; $FF in $bfec01 - ue'! ho ricevuto il dato!

; Qua dobbiamo mettere una routine che aspetti 90 microsecondi perche' la
; linea KDAT deve stare bassa abbastanza tempo per essere "capita" da tutti
; i tipi di tastiere. Si possono, per esempio, aspettare 3 o 4 linee raster.

	moveq	#4-1,d0	; Numero di linee da aspettare = 4 (in pratica 3 piu'
			; la frazione in cui siamo nel momento di inizio)
waitlines:
	move.b	6(a0),d1	; $dff006 - linea verticale attuale in d1
stepline:
	cmp.b	6(a0),d1	; siamo sempre alla stessa linea?
	beq.s	stepline	; se si aspetta
	dbra	d0,waitlines	; linea "aspettata", aspetta d0-1 linee

; Ora che abbiamo atteso, possiamo riportare $bfec01 in modo input...

	bclr.b	#6,$bfee01	; CIAA cra - sp (bfec01) input nuovamente.

NonKey:		; 3210
	move.w	#%1000,$9c(a0)	; INTREQ togli richiesta, int eseguito!
	movem.l (sp)+,d0/a0	; ripristina i registri dallo stack
	rte

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB e COPER.	    *
*****************************************************************************

;06	BLIT	3 ($6c)	Se il blitter ha finito una blittata si setta ad 1
;05	VERTB	3 ($6c)	Generato ogni volta che il pennello elettronico e'
;			alla linea 00, ossia ad ogni inizio di vertical blank.
;04	COPER	3 ($6c)	Si puo' settare col copper per generarlo ad una certa
;			linea video. Basta richiederlo dopo un certo WAIT.

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	mt_music		; suono la musica
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
nointVERTB:
NointCOPER:
NoBLIT:		 ;6543210
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT,VERTB e COPER
	rte	; uscita dall'int COPER/BLIT/VERTB

*****************************************************************************
;	Routine di replay del protracker/soundtracker/noisetracker
;
	include	"assembler2:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180
Color0:
	dc.w	$000		; color0 - sara' cambiato a seconda del tasto
	dc.w	$FFFF,$FFFE	; Fine della copperlist

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler2:sorgenti4/mod.fairlight"

	end

Immettendo il byte del codice di tastiera nel color0 si nota bene il fatto
che quando un tasto e' PREMUTO il bit 7 e' azzerato, mentre quando e'
RILASCIATO tale bit e' settato: infatti quando si preme un tasto il colore
e' piu' scuro di quando si rilascia, avendo il bit alto del verde azzerato.

