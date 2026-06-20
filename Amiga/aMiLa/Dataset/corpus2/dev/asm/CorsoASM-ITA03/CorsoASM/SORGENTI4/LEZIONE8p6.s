
; Lezione8p6.s	Funzionamento dei Condition Codes con l'istruzione ADD

	SECTION	CondC,CODE

Inizio:
	move.w	#$4000,d0
	move.w	#$2000,d1
	add.w	d0,d1
	move.w	#$e000,d0
	move.w	#$b000,d1
	add.w	d0,d1
	move.w	#$6000,d0
	move.w	#$5000,d1
	add.w	d0,d1
	move.w	#$9000,d0
	move.w	#$a000,d1
	add.w	d0,d1
stop:
	rts

	end


L'istruzione ADD influenza i codici condizione cosi':

1) Bit0, Carry (C): e' posto a 1 se il risultato non puo' essere contenuto
   nell'operando destinazione.
   Esempio: (si assume che i numeri siano senza segno.)

	move.w	#$7001,d0	; d0=$7001
	add.w	#$8fff,d0	; d0=$7001+$8fff=$10000

  Come si puo' vedere il risultato dell'addizione non puo' essere contenuto in
  una word in quanto servirebbero 17 bit, il flag C viene settato.

2) Bit1, Overflow (V): Il bit e' posto a 1 solo se l'addizione di due numeri
   con lo stesso segno supera come risultato il campo in complemento a 2
   dell'operando (per es. nel caso di operandi WORD V vale 1 se il risultato
   e` maggiore di 32767 oppure se e` minore di -32768)
   Esempio: (numeri con segno)

	move.w	#$7fff,d0	; d0=$7fff
	addq.w	#$1,d0		; d0=$7fff+1=$8000=-32768 !!!!!

  in questo caso il bit di Overflow viene settato.

3) Bit2, Zero (Z): Il bit e' posto a 1 se il risultato dell'operazione e' zero.
4) Bit3, Negativo (N): Il bit e' posto a 1 se l'ultima operazione ha prodotto
   un risultato negativo.
5) Bit4, Extend (X): assume lo stesso stato del bit C

V ed N hanno senso solo se si sommano numeri con segno.

N.B.: Se le operazioni hanno come operando destinazione un registro indirizzi,
i codici condizione rimangono INVARIATI!!!!
Questa e' una variazione dell'istruzione ADD, ed e' chiamata add address ADDA.
-------------------------------------------------------------------------------

Ora verifichiamo la teoria.
Eseguiamo i primi 2 passi del programma: si tratta di 2 MOVE che hanno
come effetto quello di caricare i 2 valori che vogliamo sommare in 2
registri. Si tratta di 2 valori positivi.

D0: 00004000 00002000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4754
SSP=07CA5887 USP=07CA4754 SR=8000 T1 -- PL=0 ----- PC=07CA7A74
PC=07CA7A74 D240		 ADD.W   D0,D1
>

Eseguiamo la somma. Come potete verificare "a mano", questa somma non genera
riporti, ovvero il risultato ($6000) e` un numero minore di $7fff, e pertanto
puo` essere contenuto ancora in una word. Quindi i flag C,X e V vengono
azzerati. Inoltre anche Z ed N vengono azzerati, perche` $6000 e` positivo e
diverso da zero.

D0: 00004000 00006000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4754 
SSP=07CA5887 USP=07CA4754 SR=8000 T1 -- PL=0 ----- PC=07CA7A76
PC=07CA7A76 303CE000		 MOVE.W  #$E000,D0
>

Facciamo ora una somma tra $e000 e $b000. In questo caso abbiamo a che fare
con numeri negativi. Il risultato (che potete verificare a mano)
e` $9000=-28672 che e` maggiore di -32768 e quindi non da problemi, per cui
il flag V vale zero.
Notate pero` che volendo potremmo considerare i nostri 2 numeri come positivi
tralasciando il segno. In questo caso, cioe`, le nostre word assumerebbero
valori compresi tra 0 e 65535. In questo caso, il risultato che otteniamo,
cioe` $9000 non e` ovviamente corretto. Cio` accade perche` il risultato esatto
di $e000+$b000 (considerarti come positivi) sarebbe $19000=102400, cioe` un
numero maggiore di 65535 che avrebbe bisogno di 17 bit per essere
rappresentato correttamente.
Il 68000, per ovviare a questo problema, memorizza il 17-esimo bit nel Carry,
(e anche in X) che quindi assume valore 1. Notate inoltre che siccome $9000
e` negativo (considerato in complemento a 2) anche il flag N assume valore 1.
Ecco quindi cio` che ottenete eseguendo la somma:

D0: 0000E000 00009000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4754
SSP=07CA5887 USP=07CA4754 SR=8019 T1 -- PL=0 XN--C PC=07CA7A80
PC=07CA7A80 303C6000		 MOVE.W  #$6000,D0
>

Vediamo un terzo esempio. Questa volta sommiamo $5000(=20480) e $6000(=24576).
Si tratta di 2 numeri positivi. A differenza del primo esempio, pero`,
se eseguiamo la somma a mano vediamo che il risultato e` 45056(=$b000) che
risulta maggiore di 32767, e infatti come potete notare e` un numero negativo.
Pertanto se interpretiamo i numeri in complemento a 2 (cioe` vanno da -32768
a 32767) il risultato e` sbagliato, e pertanto il flag V assume valore 1.
Se invece interpretiamo i numeri come sempre positivi (cioe` da 0 a 65536)
il risultato e` corretto, perche` e` minore di 65535. Pertanto il flag C
assume valore zero. Il flag N assume comunque il valore 1 perche` abbiamo un
numero negativo (se interpretato in complemento a 2). Infatti:

D0: 00006000 0000B000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4754 
SSP=07CA5887 USP=07CA4754 SR=800A T1 -- PL=0 -N-V- PC=07CA7A8A
PC=07CA7A8A 303C9000             MOVE.W  #$9000,D0
>

Vediamo ora un'ultimo esempio. Sommiamo $9000 e $a000. Si tratta di 2 numeri
negativi. Se li interpretiamo in complemento a 2 e li sommiamo, notiamo
che il risultato e` minore di -32768. Pertanto il flag V assume valore 1.
Se li interpretiamo come numeri positivi, abbiamo che la loro somma sarebbe
$13000 che ha bisogno di 17 bit. Pertanto anche il flag C vale 1. 
Come risultato otteniamo $3000 ovvero i 16 bit meno significativi della somma.
Poiche` $3000 e` positivo, il flag N vale zero.

D0: 00009000 00003000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4754 
SSP=07CA5887 USP=07CA4754 SR=8013 T1 -- PL=0 X--VC PC=07CA7A94
PC=07CA7A94 4E75                 RTS     
>

