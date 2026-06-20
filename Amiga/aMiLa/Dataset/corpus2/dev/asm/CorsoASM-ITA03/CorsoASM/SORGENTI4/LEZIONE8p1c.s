
; Lezione8p1c.s		Funzionamento dei Condition Codes con le DIVU/DIVS

	SECTION	CondC,CODE

Inizio:
	moveq	#$0010,d0
	moveq	#$0003,d1
	divs.w	d1,d0

	move.l	#$200000,d0
	moveq	#$0002,d1
	divs.w	d1,d0
stop:
	rts

	end

;	·[oO]·
;	  C
;	 \__/
;	   U

Vediamo ora un esempio d'uso delle istruzioni di divisione.
Anche per la divisione ll 68000 ci mette a disposizione 2 diverse istruzioni:
DIVS divide 2 numeri considerandoli come numeri in complemento a 2,
mentre DIVU considera i numeri da dividere sempre positivi.
Le differenze quindi sono analoghe a quelle tra MULS e MULU, pertanto non le
illustreremo, fate degli esperimenti per esercizio.
Gli esempi che faremo riguardano la DIVS.
Le istruzioni di divisione dividono un operando a 32bit in un registro dati
con un divisore a 16 bit, il quoziente a 16 bit sara' messo nella word bassa
del registro destinazione e il resto nella word alta.
Nel caso di divisione per 0, il 68000 effettuera' una routine di eccezione, 
e nella maggior parte dei casi si avra' una bella GURU MEDITATION.
La divisione puo' influenzare i codici condizione in questo modo:

1) Carry (C) e' sempre posto a 0
2) Overflow (V) e' settato se il dividendo e' tanto maggiore del divisore che
il risultato non puo' essere contenuto in 16bit
es:
	move.l	#$ffffffff,d0
	divu.w	#2,d0

3) Zero (Z) e' posto a 1 se il risultato dell'operazione e' 0
4) Negativo (N) e' posto a 1 se il risultato dell'operazione e' negativo
5) Extend (X) rimane invariato.
----------------------------------------------------------------------------

Prima vediamo un esempio normale: dividiamo il numero $10(=16) contenuto nel
registro D0 per il numero 3, contenuto in D1.

D0: 00000010 00000003 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154 
SSP=07D33287 USP=07D32154 SR=8000 T1 -- PL=0 ----- PC=07D34CE8
PC=07D34CE8 81C1		 DIVS.W  D1,D0
>

Il risultato e` riportato sotto. Notate che vengono calcolati sia il quoziente
(posto nella word bassa D0) che il resto (posto nella word alta di D0).
Si tratta infatti di una divisione tra interi.

D0: 00010005 00000003 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154
SSP=07D33287 USP=07D32154 SR=8000 T1 -- PL=0 ----- PC=07D34CEA
PC=07D34CEA 203C00200000	 MOVE.L  #$00200000,D0
>

Vediamo ora un'altro esempio.
Dividiamo il numero $200000 (contenuto in D0) per $2 (in D1).

D0: 00200000 00000002 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154 
SSP=07D33287 USP=07D32154 SR=8000 T1 -- PL=0 ----- PC=07D34CF6
PC=07D34CF6 81C1		 DIVS.W  D1,D0
>

Il risultato esatto e` $100000, come potete verificare con il comando "?" di
ASMONE. Questo numero pero` e` troppo grande per essere contenuto in una word.
Pertanto la DIVS non riesce a effettuare il calcolo correttamente e segnala
questo fatto ponendo a 1 il flag V:

D0: 00200000 00000002 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154
SSP=07D33287 USP=07D32154 SR=8002 T1 -- PL=0 ---V- PC=07D34CF8
PC=07D34CF8 4E75		 RTS
>

In casi come questo si deve effetture la divisione mediante algoritmi
particolari.

