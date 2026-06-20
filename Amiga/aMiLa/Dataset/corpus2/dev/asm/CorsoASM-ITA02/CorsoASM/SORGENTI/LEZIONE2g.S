
; Lezione2G.s

Inizio:
	lea	THEEND,a0	; metti in a0 l'indirizzo da dove iniziare
	lea	START,a1	; metti in a1 l'indirizzo dove finire
CLELOOP:
	clr.l	-(a0)	;aggiungi 4 ad a0 (long!), poi azzera la long
	cmp.l	a0,a1	; a0 e' uguale ad a1? Cioe' siamo all'indirizzo START?
	bne.s	CLELOOP	; se no, torna ad eseguire CLELOOP...
	rts		; ESCI dal prog e torna ad ASMONE

START:
	dcb.b	40,$fe	; METTI QUA IN MEMORIA 40 bytes $fe.
THEEND:			; questa label segna la fine dei 40 bytes...

	dcb.b	10,0	; mettiamo 10 bytes azzerati qua tanto per sfizio

	end

questo programmino fa una pulizia a partire dall'indirizzo messo in a0, fino
all'indirizzo che mettiamo in a1: la diversita' con LEZIONE2f.s in cui e'
usato un CLR.L (a0)+ e' che qua si parte dalla fine dei bytes da pulire e
si arriva "indietreggiando" fino all'inizio.
per verificare cio', fate un AD e noterete che ogni volta che viene eseguito
il CLR.L -(a0) il registro a0 decrementa fino a raggiungere a1, cioe' START.
verificate pure con M START che dopo l'esecuzione la pulizia e' avvenuta,
e se vi aggrada modificate pure il CLR.L -(a0) con CLR.W -(a0) e noterete
che sono necessari 20 passaggi (infatti 20*2=40) e che ogni volta a0 e'
diminuito di 2, mentre sostituendolo con CLR.B -(a0) serviranno 40 passaggi
e il registro a0 sara' decrementato di 1 ogni volta.

