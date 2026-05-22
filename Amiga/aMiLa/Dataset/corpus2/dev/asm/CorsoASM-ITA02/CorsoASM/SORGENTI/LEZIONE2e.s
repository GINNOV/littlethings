
; Lezione2e.s

Inizio:
	lea	$dff006,a0	; metti $dff006 (VHPOSR) in a0
	lea	$dff180,a1	; metti $dff180 (COLOR0) in a1
	lea	$bfe001,a2	; metti $bfe001 (CIAAPRA) in a2
Waitmouse:
	move.w	(a0),(a1)	; metti il valore di $dff006 nel color 0
	btst	#6,(a2)		; tasto sinistro del mouse premuto?
	bne.s	Waitmouse	; se no ritorna a waitmouse e ripeti
	rts			; esci

	END

Come  si puo' notare, il ciclo Waitmouse e' composto di indirizzamenti
indiretti anziche' diretti, ovvero invece di operare direttamente con gli
indirizzi, si mettono questi ultimi in registri dati e si leggono o si
scrivono usando i registri tra parentesi (indirettamente).
Questo aumenta la velocita' del loop, in quanto sono piu' veloci i registri
degli indirizzamenti diretti (si dovrebbe notare infatti un leggero cambiamento
nel lampeggiamento dello schermo rispetto a LEZIONE1a.s dovuto alla maggiore
velocita' di esecuzione).
Dopo l'esecuzione si puo' verificare che i registri a0,a1 ed a2 contengono
rispettivamente $dff006 (VHPOSR), $dff180 (COLOR00) e $bfe001 (CIAAPRA).
Se si vogliono proprio togliere tutti i numeri dal loop, si puo' modificare
il BTST #6,$bfe001 con un BTST d0,$bfe001, dove in d0 ci sia 6:

Inizio:
	lea	$dff006,a0	; VHPOSR - metti $dff006 in a0
	lea	$dff180,a1	; COLOR00 - metti $dff180 in a1
	lea	$bfe001,a2	; CIAAPRA - metti $bfe001 in a2
	moveq	#6,d0		; metti il valore 6 in d0
Waitmouse:
	move.w	(a0),(a1)	; metti il valore di $dff006 nel color 0
	btst	d0,(a2)		; tasto sinistro del mouse premuto?
				; (bit 6 del $bfe001 azzerato?)
	bne.s	Waitmouse	; se no ritorna a waitmouse e ripeti
	rts			; esci

(usate Amiga+b,c ed i per sostituire questo sorgente a quello sopra)

NOTA: Per mettere un 6 in d0 anziche' MOVE.L #6,d0 ho usato MOVEQ #6,d0,
perche' i numeri sotto il $7f (ossia 127), sia negativi che positivi,
possono essere immessi nei registri dati con lo speciale comando MOVEQ, che
e' sempre .L, quindi non si mette .b,.w o .l come gia' visto per il LEA.
Esempi:
	MOVEQ	#100,d0	; meno di 127
	MOVE.L	#130,d0	; piu' di 127, va usato il move.l normale.
	MOVEQ	#-3,d0	; fino a -128 si puo' usare il MOVEQ.

NOTA2: e' molto comune usare tutti i registri mettendoci gli indirizzi ed i
dati necessari alle routines (sottoprogrammi), perche' sono piu' veloci
e flessibili. Ma risultano ovviamente meno leggibili, infatti immaginate
che gli indirizzi e i dati siano stati messi nei registri all'inizio
del programma e che ci troviamo in mezzo ad esso con questa routine:

Routin:
	move.w	(a0),(a1)
	btst	d0,(a2)
	bne.s	Routin

In cui vediamo solo degli (a0),(a1), dei d0,(a2) eccetera. SE NON SAPPIAMO
COSA C'E' NEI REGISTRI TUTTO QUESTO APPARIRA' INSENSATO, quindi vi assicuro
che e' importante impararsi gli indirizzamenti e ricordarsi in che punto
mettete gli indirizzi e i dati nei registri per poter capire quello che si
e' scritto anche solo na settimana prima; la forza dei processori 68000 sta
proprio nella capacita' di lavorare INDIRETTAMENTE alla memoria usando
i registri nei loro diversi indirizzamenti, ma in questo consiste anche
la difficolta'.

Per esercitarvi provate a scrivere dei listati inutili ingarbugliati
tentando di capire in fondo al listato cosa risulti, cosa che potrete poi
verificare eseguendolo. Vi suggerisco un inizio, continuate voi
l'ingarbugliamento come se risolveste un quesito enigmistico:

	lea	PUFFO,a0
	move.l	(a0),a1
	move.l	a1,a2
	move.l	(a2),d0
	moveq	#0,d1
	move.l	d1,a0
	.....
	rts

PUFFO:
	dc.l	$66551

