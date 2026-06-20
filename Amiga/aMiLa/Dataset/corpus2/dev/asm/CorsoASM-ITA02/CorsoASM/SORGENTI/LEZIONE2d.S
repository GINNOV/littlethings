
; Lezione2d.s

Inizio:
	lea	CANGURO,a0	; in A0 mettiamo l'indirizzo di CANGURO
	move.l	(a0),d0		; in d0 mettiamo il valore .L che troviamo
				; all'indirizzo che e' in a0, ovvero
				; la prima longword contenuta in CANGURO
	move.l	CANGURO,d1	; in d1 mettiamo il contenuto della prima
				; longword (4 bytes=4 indirizzi) di canguro
	move.l	a0,d2		; in d2 mettiamo il numero contenuto in a0,
				; ossia l'indirizzo di CANGURO caricato
				; prima col LEA CANGURO,a0
	move.l	#CANGURO,d3	; in d3 mettiamo l'indirizzo di CANGURO
	rts

CANGURO:
	dc.l	$123

	END

Con questo esempio si nota la differenza tra l'indirizzamento diretto, quello
indiretto e quello assoluto: una volta assemblato , fate un D Inizio per
controllare e dopo averlo eseguito col J si notera' il risultato nei
registri: in d0 ed in d1 noterete $123, ossia il contenuto .L di CANGURO:

	lea	CANGURO,a0	; in A0 mettiamo l'indirizzo di CANGURO
	move.l	(a0),d0		; in d0 mettiamo il valore contenuto
				; nell'indirizzo che e' in a0, ovvero
				; il valore .L contenuto in CANGURO
				; (Con il MOVE.L si copia il byte contenuto
				; nell'indirizzo in a0, nonche' i 3 seguenti,
				; essendo una long lunga 4 bytes)
E' equivalente a:

	move.l	CANGURO,d1	; in d1 mettiamo il contenuto .L di canguro

Infatti in tutti e due i casi il contenuto .L di canguro va nel registro dati.

Invece in d2,d3 ed a0 si notera' l'indirizzo di CANGURO, infatti:

	lea	CANGURO,a0	; in A0 mettiamo l'indirizzo di CANGURO
	move.l	a0,d2		; in d2 mettiamo il numero contenuto in a0,
				; ossia l'indirizzo di CANGURO caricato col LEA

E' equivalente a:

	move.l	#CANGURO,d3	; in d3 mettiamo l'indirizzo di CANGURO

Queste differenze di indirizzamento devono essere chiare, infatti una volta
che si conoscono basta ricordarsi i comandi, i quali usano tutti lo stesso
sistema di indirizzamento.

Esempi di indirizzamenti fin ora analizzati:

DIRETTO:
	move.l	a0,a1

INDIRETTO:
	clr.l	(a0)
	move.l	(a3),(a4)

ASSOLUTO:
	move.l	#LABEL,d0
	MOVE.L	#10,d4

