
; Lezione8p2a.s		Flag e registri indirizzi

	SECTION	CondC,CODE

Inizio:
	move.w	#$8000,d0
	move.l	#$80000000,a0
stop:
	rts

	end


;	   . · · .
;	  .       .
;	  .       .
;	   .     .
;	     · ·

In questa lezione ci occuperemo di una particolarita` dell'indirizzamento 
diretto a registro indirizzi. Vedremo questa particolarita` utilizzando una
istruzione MOVE nella quale per la destinazione e` usato l'indirizzamento
diretto a registro indirizzi, ma essa si verifica con tutte le istruzioni che
ammettono l'indirizzamento diretto a registro indirizzi per la destinazione.

Per prima cosa assemblate il programma ed eseguite la prima istruzione.
Otterrete il seguente output:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 80000000 00000000 00000000 00000000 00000000 00000000 00000000 07C9EDC4
SSP=07C9FEF7 USP=07C9EDC4 SR=8004 T1 -- PL=0 --Z-- PC=07CA18DC
PC=07CA18DC 207C80000000	 MOVE.L  #$80000000,A0
>

Come ci aspettavamo il flag "Z" ha assunto il valore 1.
Eseguiamo anche la seconda istruzione:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 80000000 00000000 00000000 00000000 00000000 00000000 00000000 07C9EDC4 
SSP=07C9FEF7 USP=07C9EDC4 SR=8004 T1 -- PL=0 --Z-- PC=07CA18E2
PC=07CA18E2 4E75		 RTS
>

Notiamo che l'istruzione e` stata eseguita, ma che il flag "Z" vale ancora 1
e il flag "N" vale invece 0. Eppure il valore $80000000 che abbiamo caricato
nel registro A0 e` negativo! Dunque il nostro fido 680x0 si e` sbagliato?
Ma naturalmente no! (Mica e` un Pentium 60! :). Il punto e` che come abbiamo
gia` spiegato nella lezione 8, in realta` l'istruzione che si 
occupa di copiare dati in un registro indirizzi e` la MOVEA, una variante
della normale MOVE; l'ASMONE per comodita` ci consente di scrivere
MOVE per copiare nei registri indirizzi, e si occupa lui di sostituire
la MOVE con la MOVEA. Di solito noi non ci accorgiamo nemmeno di questa
sostituzione. In questo caso pero` bisogna stare molto attenti perche`
la MOVEA si comporta diversamente dalla MOVE per quanto riguarda la
modifica dei CC. La MOVEA, come potete leggere in 68000-2.TXT, 
lascia i CC TUTTI INALTERATI. Nel nostro caso, il flag "Z" valeva 1 prima
dell'esecuzione della MOVE #$80000000,A0 e per questo motivo e` rimasto
al valore 1. Verifichiamolo modificando la prima MOVE in

	move.w	#$8000,d0

Eseguendo PASSO PASSO notiamo che la prima MOVE fa assumere il valore 1
al flag "N":

D0: 00008000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CC685C 
SSP=07CC798F USP=07CC685C SR=8008 T1 -- PL=0 -N--- PC=07CC9A60
PC=07CC9A60 207C80000000	 MOVE.L  #$80000000,A0
>

E la MOVE.L #$80000000,A0 come abbiamo detto lascia inalterati i CC:

D0: 00008000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 80000000 00000000 00000000 00000000 00000000 00000000 00000000 07CC685C 
SSP=07CC798F USP=07CC685C SR=8008 T1 -- PL=0 -N--- PC=07CC9A66
PC=07CC9A66 4E75		 RTS     
>

Bisogna prestare particolare attenzione al fatto che i CC non vengono
influenzati quando si indirizzano i registri indirizzi, perche` questo fatto
puo` essere causa di BUG. Supponiamo per esempio di avere memorizzato un dato
e di volerlo modificare in due modi diversi a seconda se esso sia positivo o
negativo. Se spostiamo il dato in un registro dati, per esempio D0, possiamo
scrivere il seguente frammento di codice:

	move.w	dato(pc),d0	; modifica i CC in base al dato
	bmi.s	dato_negativo
dato_positivo:
 ; operazioni da compiere se il dato e` positivo
	bra.s	fine

dato_negativo:
 ; operazioni da compiere se il dato e` negativo
fine:
	; resto del programma

In questo caso come gia` sappiamo la MOVE provvede a settare i CC a seconda
del segno del dato.
Se invece dovessimo mettere il nostro dato in un registro indirizzi
(es. A0) se scrivessimo una procedura analoga non funzionerebbe perche`
la MOVEA non aggiorna correttamente i CC.

	move.w	dato(pc),a0	; NON modifica i CC in base al dato !!
	bmi.s	dato_negativo	; Il salto viene effettuato in base allo
				; stato dei CC precedente alla MOVE
dato_positivo:
	; operazioni da compiere se il dato e` positivo
	bra.s	fine

dato_negativo:
	; operazioni da compiere se il dato e` negativo

fine:
	; resto del programma

Una possibile soluzione al problema potrebbe essere di spostare il dato prima
in un registro dati e successivamente in A0, oppure usare l'istruzione TST.

