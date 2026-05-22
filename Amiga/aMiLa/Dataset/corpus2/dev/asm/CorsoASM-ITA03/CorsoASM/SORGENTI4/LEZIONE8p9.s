
; Lezione8m9.s	Funzionamento dei Condition Codes con le 
;		istruzioni di shift

	SECTION	CondC,CODE

Inizio:
	move.w	#$c003,d0
	move.w	d0,d1
	lsr.w	#1,d0
	asr.w	#1,d1

	move.w	#$6000,d0
	move.w	d0,d1
	lsl.w	#1,d0
	asl.w	#1,d1
stop:
	rts

	end

In quest'esempio tratteremo le istruzioni di shift, mettendo in luce le
differenze tra le istruzioni di shift aritmetico (ASx) e logico (LSx).
Iniziamo dallo shift a destra. Prendiamo il numero $C003 e lo shiftiamo
a destra di 1 posto (che corrisponde a dividere per 2). Iniziamo
con LSR:

D0: 0000C003 0000C003 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8008 T1 -- PL=0 -N--- PC=07CA78A6
PC=07CA78A6 E248		 LSR.W   #1,D0
>

La LSR interpreta i numeri sempre come numeri positivi.
Osserviamo che il numero $C003 e` diventato $6001, il che e` corretto se
lo assumiamo come positivo. Osservate inoltre che il flag C ha assunto il
valore del bit che e` uscito a destra, in questo caso 1.

D0: 00006001 0000C003 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8011 T1 -- PL=0 X---C PC=07CA78A8
PC=07CA78A8 E241		 ASR.W   #1,D1
>

La ASR invece interpreta i numeri in complemento a 2. In questo caso, dunque,
$C003 e` stato interpretato come numero negativo, e il risultato ottenuto
e` $E001 che e` corretto nella notazione in complemento a 2 come potete
verificare con il comando "?" di ASMONE.

D0: 00006001 0000E001 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8019 T1 -- PL=0 XN--C PC=07CA78AA
PC=07CA78AA 303C6000		 MOVE.W  #$6000,D0
>

Veniamo ora allo shift a sinistra che "corrisponde" alla moltiplicazione.
Anche qui c'e` la stessa differenza tra ASL e LSL. Vediamo prima come si
comporta la LSL:

D0: 00006000 00006000 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8010 T1 -- PL=0 X---- PC=07CA78B0
PC=07CA78B0 E348		 LSL.W   #1,D0
>

Come vedete il risultato dello shift a sinistra di $6000 e` $C000 che e`
corretto se interpretiamo $C000 come numero positivo. Vediamo cosa fa
invece la ASL

D0: 0000C000 00006000 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8008 T1 -- PL=0 -N--- PC=07CA78B2
PC=07CA78B2 E341		 ASL.W   #1,D1
>

Il risultato e` ancora $C000. Il che e` sbagliato se interpretiamo i numeri
in complemento a 2. Come mai? Se convertite $6000 in decimale e lo moltiplicate
per 2 vedrete che il risultato e` maggiore di 32767, e pertanto non puo` essere
rappresentato correttamente in notazione complemento a 2. Notate che la ASL
ci segnala il fatto ponendo ad 1 il flag V. Cio` non accade invece con la LSL,
che azzera sempre il flag V. Questa e` la sola (ma importante) differenza
tra le 2 istruzioni di shift a sinistra.

D0: 0000C000 0000C000 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=800A T1 -- PL=0 -N-V- PC=07CA78B4
PC=07CA78B4 4E75		 RTS
>

