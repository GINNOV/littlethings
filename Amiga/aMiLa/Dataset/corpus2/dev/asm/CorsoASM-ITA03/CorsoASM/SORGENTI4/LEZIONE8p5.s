
; Lezione8p5.s	Funzionamento dei Condition Codes con l'istruzione NEG

	SECTION	CondC,CODE

Inizio:
	neg.w	dato1
	neg.w	dato2
	neg.w	dato3
	neg.w	dato4
stop:
	rts

dato1:
	dc.w	$ff02
dato2:
	dc.w	$4f02
dato3:
	dc.w	$0000
dato4:
	dc.w	$8000

	end

Vediamo ora un esempio sull'istruzione NEG.
Vi sono due istruzioni di negazione che consentono di complementare a 2 un
operando .B .W o .L sotrraendolo da 0.
--------------------------------------------------------------------------
NEG     <ea>            Sorgente=All
NEGX    <ea>            Sorgente=All
--------------------------------------------------------------------------
L'istruzione di negazione puo' influenzare cosi' i codici condizioni:

1.Bit0, Carry (C): e' posto a 0 se l'operando e' zero, altrimenti e` posto a 1.

2.Bit1, Overflow (V): Il bit e' posto a 1 solo se l'operando ha il valore di
$80 byte, $8000 word, $80000000 long.

3.Bit2, Zero (Z): Il bit e' posto a 1 se il risultato dell'operazione e' zero.
4.Bit3, Negativo (N):  e' posto a 1 se l'operando e' un numero positivo diverso
da zero.
5.Bit4, Extend (X): assume lo stesso stato del bit C
------------------------------------------------------------------------------

La prima istruzione del listato opera sul dato all'indirizzo "DATO1", che e`
un numero negativo. Eseguendola otteniamo:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA7934
SSP=07CA8A67 USP=07CA7934 SR=8011 T1 -- PL=0 X---C PC=07CFEBDA
PC=07CFEBDA 447907CFEBF0	 NEG.W   $07CFEBF0
>

Come potete constatare con il comando ASMONE "M.w dato1" il risultato e`
positivo e` diverso da zero. Pertanto gli unici CC ad essere settati a 1
sono C ed X.
La seconda NEG opera invece su un dato positivo. Il risultato e` quindi
negativo, e di conseguenza questa volta anche il bit N vale 1:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA7934
SSP=07CA8A67 USP=07CA7934 SR=8019 T1 -- PL=0 XN--C PC=07CFEBE0
PC=07CFEBE0 447907CFEBF2	 NEG.W   $07CFEBF2
>

Siamo ora alla terza NEG, che opera sul valore contenuto all'indirizzo
"dato3" che e` zero. Come potete verificare il risultato e` ancora zero,
perche` giustamente il negativo (e quindi il complemento a 2) di zero e`
ancora zero. Per quanto riguarda i CC, sono tutti azzerati tranne Z:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA7934
SSP=07CA8A67 USP=07CA7934 SR=8000 T1 -- PL=0 --Z-- PC=07CFEBE6
PC=07CFEBE6 447907CFEBF4	 NEG.W   $07CFEBF4
>

Veniamo ora all'ultimo caso. Il valore su cui opera la NEG stavolta e`
$8000 = -32678. Come sapete con 16 bit NON possiamo rappresentare il valore
+32678. Poiche` in questo caso la NEG opera su word, essa non puo` calcolare
correttamente il risultato che cerchiamo. Eseguendola, vediamo che essa
lascia INALTERATO (cioe` a $8000) il valore contenuto all'indirizzo "dato4"
e assegna al flag V (oVerflov) il valore 1 per segnalarci l'errore:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA7934
SSP=07CA8A67 USP=07CA7934 SR=801B T1 -- PL=0 XN-VC PC=07CFEBEC
PC=07CFEBEC 4E75		 RTS
>

