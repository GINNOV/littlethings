
; Lezione8p7.s	Funzionamento dei Condition Codes con l'istruzione CMP

	SECTION	CondC,CODE

Inizio:
	move.w	#$9000,d0
	move.w	#$6000,d1
	cmp.w	d0,d1
	bgt.w	salto
stop:
	rts

salto:
	nop	; questo salto viene effettuato se la destinazione e` maggiore
		; della sorgente
	rts

	end

L'istruzione CMP ci permette di confrontare 2 numeri e settare di conseguenza
i CC. Di solito una CMP e` seguita da un'istruzione Bcc. Ecco i 3 "tipi":

CMPA.x	<ea>,Ay		Sorgente=All	Destinazione=An (nota: SOLO .W o .L).
-----------------------------------------------------------------------------
CMPI.x	#d,<ea>		Sorgente=#d	Destinazione=Dati alterabili
-----------------------------------------------------------------------------
CMPM.x	(Ax)+,(Ay)+	Sorgente=(An)+	Destinazione=(An)+
-----------------------------------------------------------------------------

Ognuna delle istruzioni di confronto del 68000 sottrae l'operando Sorgente 
dalla Destinazione e setta i flag di condizione secondo la seguente tabella:

+----------------------+---+---+---+---+
|Condizione            | N | Z | V | C |
+----------------------+---+---+---+---+
|Sorgente<Destinazione | 0 | 0 |0/1| 0 |
+----------------------+---+---+---+---+
|Sorgente=Destinazione | 0 | 1 | 0 | 0 |
+----------------------+---+---+---+---+
|Sorgente>Destinazione | 1 | 0 |0/1| 1 |
+----------------------+---+---+---+---+

Il bit V vale 1 se la differenza tra sorgente e destinazione supera come
risultato il campo in complemento a 2 dell'operando (cioe` se e` minore del
piu` piccolo numero negativo rappresentabile o maggiore del piu` grande
positivo rappresentabile).
N e V sono significativi solo se si confrontano operandi in complemeto a 2.

N.B.: Diversamente dalle istruzione di sottrazione, le istruzioni di confronto
non salvano il risultato della sottrazione!!!!!!!! (Mi pare chiaro!)
------------------------------------------------------------------------------

Le Bcc leggono lo stato dei CC e nel caso sia verificata una particolare
condizione (che varia tra le singole Bcc) eseguono o no un salto.
La CMP setta i flag CC allo stesso modo della SUB.
Vediamo un breve esempio. Effettuiamo un confronto tra un numero positivo
e uno negativo. Vediamo che l'esito del confronto e` diverso se consideriamo
il numero negativo come positivo.
Eseguiamo il programma fino all'istruzione BGT.

D0: 00009000 00006000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4F64 
SSP=07CA6097 USP=07CA4F64 SR=800B T1 -- PL=0 -N-VC PC=07CA7B52
PC=07CA7B52 6E000004		 BGT.W   $07CA7B58
>

La BGT come sapete effettua il salto se l'operando destinazione e` maggiore
dell'operando sorgente.
Inotre essa considera i numeri come valori in complemento a 2.
Nel nostro caso l'operando destinazione e` maggiore dell'operando
sorgente poiche` il primo e` positivo mentre il secondo e` negativo. 
Facciamo un'altro passo e lo verifichiamo:

D0: 00009000 00006000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4F64 
SSP=07CA6097 USP=07CA4F64 SR=800B T1 -- PL=0 -N-VC PC=07CA7B58
PC=07CA7B58 4E71		 NOP
>

come potete vedere il salto e` stato effettuato, infatti la prossima istruzione
da eseguire e` la NOP.
Proviamo ora a vedere cosa accade sostituendo alla BGT l'istruzione BHI.
Anche questa istruzione effettua il salto se l'operando destinazione e`
maggiore dell'operando sorgente. La differenza e` che la BHI considera i numeri
tutti positivi. 
Eseguiamo il programma modificato.

D0: 00009000 00006000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4F64
SSP=07CA6097 USP=07CA4F64 SR=800B T1 -- PL=0 -N-VC PC=07CA7B52
PC=07CA7B52 62000004		 BHI.W   $07CA7B58
>

Questa volta, $9000 viene considerato come numero positivo. Allora esso
risulta maggiore di $6000. Pertanto il salto non viene effettuato:

D0: 00009000 00006000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4F64
SSP=07CA6097 USP=07CA4F64 SR=800B T1 -- PL=0 -N-VC PC=07CA7B56
PC=07CA7B56 4E75		 RTS
>

In conclusione, quando si usa la CMP bisogna fare molta attenzione a come si
vogliono interpretare i numeri negativi, e usare quindi la giusta Bcc.

