
;	Lezione8p2b.s	estensione del segno nei registri indirizzi

	SECTION	CondC,CODE

Inizio:
	move.l	#$ffffffff,a0	; Ossia "move.l #-1,a0"
	move.w	#$51a7,a0
stop:
	rts

	end

;            \|/
;           (©_©)
;--------ooO-(_)-Ooo--------

In questa lezione ci occuperemo di un'altra particolarita` dell'indirizzamento
diretto a registro indirizzi.
Eseguiamo un'istruzione per volta il programma sopra riportato.
La prima MOVE carica un valore di 32 bit in A0.

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: FFFFFFFF 00000000 00000000 00000000 00000000 00000000 00000000 07C9F584
SSP=07CA06B7 USP=07C9F584 SR=8000 T1 -- PL=0 ----- PC=07CA1F8E
PC=07CA1F8E 307C0100		 MOVE.W  #$51A7,A0
>

Come normale il registro A0 ha assunto il valore $FFFFFFFF. Ora eseguiamo
la seconda MOVE. Notiamo che essa carica un valore a 16 bit in A0.
Ci aspetteremmo che solo la word bassa di A0 venisse modificata.
Invece possiamo verificare che e` stata modificata anche la word alta:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 000051A7 00000000 00000000 00000000 00000000 00000000 00000000 07C9F584
SSP=07CA06B7 USP=07C9F584 SR=8000 T1 -- PL=0 ----- PC=07CA1F92
PC=07CA1F92 4E75		 RTS
>

Questo accade perche` quando si scrive in un registro indirizzi una WORD
(ricordiamo che NON e` possibile scrivere un singolo BYTE, cioe`
l'istruzione  MOVE.B xxxx,Ax NON e` permessa) essa viene trasformata in una
LONG WORD mediante un'operazione detta "estensione di segno" che consiste
nel copiare il bit piu` significativo della WORD (cioe` il bit 15, che come
sapete indica il segno di un valore formato WORD) in tutti i bit della
WORD alta, in modo da conservare lo stesso segno passando dal valore WORD a
quello LONG WORD. In pratica nel nostro caso abbiamo:

valore di partenza = $51A7 = %0101000110100111
			      ^
			      |
			      bit piu` significativo vale 0

valore esteso = $000051A7  = %00000000000000000101000110100111

tutti i bit da 16 a 31 hanno assunto il valore 0.

Facciamo un'altro esempio, cambiando i valori caricati dalle MOVE:

	move.l	#$22222222,a0
	move.w	#$c1a7,a0

Eseguendo la prima MOVE otteniamo:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 22222222 00000000 00000000 00000000 00000000 00000000 00000000 07C9F584
SSP=07CA06B7 USP=07C9F584 SR=8000 T1 -- PL=0 ----- PC=07CA2642
PC=07CA2642 307CC1A7		 MOVE.W  #$C1A7,A0
>

eseguendo la seconda:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: FFFFC1A7 00000000 00000000 00000000 00000000 00000000 00000000 07C9F584 
SSP=07CA06B7 USP=07C9F584 SR=8000 T1 -- PL=0 ----- PC=07CA2646
PC=07CA2646 4E75                 RTS

In questo caso l'estensione di segno ha reso negativo il valore LONG WORD:

Valore di partenza = $C1A7 = %1100000110100111
			      ^
			      |
			      Il bit piu` significativo vale 1
Valore esteso = $FFFFC1A7  = %11111111111111111100000110100111

Tutti i bit da 16 a 31 hanno assunto il valore 1.

Nota: l'istruzione EXT.L serve ad estendere il segno come in questi esempi.
