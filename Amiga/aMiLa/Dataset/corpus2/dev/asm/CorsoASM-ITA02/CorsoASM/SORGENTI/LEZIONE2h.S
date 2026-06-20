
; Lezione2h.s

Inizio:
	lea	$dff006,a0	; VHPOSR - metti $dff006 in a0
	lea	$dff180,a1	; COLOR00 - metti $dff180 in a1
	lea	$bfe001,a2	; CIAAPRA - metti $bfe001 in a2
Waitmouse:
	move.w	(a0),(a1)+	; metti il valore di $dff006 nel color 0,
				; ovvero $dff180 (contenuto in a1)
				; e incrementa di 2 a1, portandolo a $dff182,
				; ossia il color 1
	move.w	(a0),-(a1)	; decrementa di 2 a1, riportandolo a $dff180,
				; poi metti $dff006 nel color 0
	btst	#6,(a2)		; tasto sinistro del mouse premuto?
	bne.s	Waitmouse	; se no ritorna a waitmouse e ripeti
	rts			; esci

	END

Con questo ciclo si notano benissimo le differenze tra (a1)+ e -(a1), infatti
sono messi in maniera da annullarsi a vicenda: mentre il primo (a1)+
incrementa a1 di una word portandolo a $dff182, il -(a1) seguente riporta
a1 a $dff180 e scrive sempre nel color 0.
Infatti le due istruzioni si possono riscrivere semplicemente:

	move.w	(a0),(a1)
	move.w	(a0),(a1)

Verificate lo scambiarsi degli indirizzi $dff180 e $dff182 nel reg. a1 facendo
un AD.
Ricordatevi BENE che quando vedete un + DOPO una parentesi il registro
viene AUMENTATO (+!!!) DOPO l'operazione, mentre se vedete un - PRIMA di
una parentesi il registro viene DIMINUITO (-!!!) PRIMA!!!
NOTA: potete terminare il ciclo durante l'AD tenendo premuto il tasto sinistro
quando si esegue il btst; una volta raggiunto l'RTS premete ESC per tornare.

