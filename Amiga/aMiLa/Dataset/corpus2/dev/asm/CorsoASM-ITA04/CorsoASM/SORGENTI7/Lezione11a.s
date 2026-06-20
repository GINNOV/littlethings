
; Lezione11a.s		Esecuzione di un paio di istruzioni privilegiate.

Inizio:
	move.l	4.w,a6			; ExecBase in a6
	lea	SuperCode(PC),a5	; Routine da eseguire in supervisor
	jsr	-$1e(a6)		; LvoSupervisor - esegui la routine
					; (non salva i registri! attenzione!)
	rts				; esci, dopo aver eseguito la routine
					; "SuperCode" in supervisor.

; Routine eseguita in modo supervisore
;	  __
;	  \/
;	-    -
;	
;	 /  \
		
SuperCode:
	move.w	SR,d0		; istruzione privilegiata
	move.w	d0,sr		; istruzione privilegiata
	RTE	; Return From Exception: come l'RTS, ma per le eccezioni.

	end

Eseguendo questo listato prendete il valore dello Status Register nel momento
dell'eccezione, per cui alla fine dell'esecuzione in d0 ci sara' un valore,
solitamente $2000, che e' anche la prova che si stava eseguendo in exception,
dato che il bit 13 dello SR se settato indica il modo supervisore.

 (((
oO Oo
 \"/
  ~		5432109876543210
	($2000=%0010000000000000)

NOTA: move.w SR,destinazione e' privilegiata solo dal 68010 in avanti, nel
68000 e' eseguibile anche in modo utente. Infatti chi la ha usata nelle
vecchie demo o giochi in modo utente, ha fatto si' che funzioni solo su 68000,
con lancio di bestemmie e accidenti per possessori di 68020+.

