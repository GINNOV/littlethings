
; Lezione8p9b.s		Quesiti e consigli sulle applicazioni dei CC

	SECTION	CondC,CODE

AspettaMouse:
	move.b	$BFE001,d2
	and.b	#$40,D2		; $40 = %01000000, cioe' bit 6
	bne.s	AspettaMouse
	RTS

	end

Come mai questa routine aspetta correttamente la pressione del mouse, senza
BTST alcuno? Spero che il commento a lato e la vostra conoscenza dei CC vi
faccia supporre la risposta.
Veniamo ad alcune applicazioni dei "cc". Andatevi a ripescare la Lezione7n.s
che faceva rimbalzare uno sprite. Ecco quella routine senza i "btst" che
testavano (inutilmente) il bit alto per vedere se il numero era divenuto
negativo:

; Questa routine cambia le coordinate dello sprite aggiungendo una velocita`
; costante sia in verticale che in orizzontale. Inoltre quando lo sprite tocca
; uno dei bordi, la routine provvede a invertire la direzione.
; Per comprendere questa routine occorre sapere che l'istruzione "NEG" serve
; a trasformare un numero positivo in negativo e viceversa. Inoltre noterete
; anche un BPL dopo un ADD, e non dopo un TST o un CMP. Ora sapete perche':


MuoviSprite:
	move.w	sprite_y(PC),d0	; leggi la vecchia posizione
	add.w	speed_y(PC),d0	; aggiungi la velocita`
	bpl.s	no_tocca_sopra	; se >0 va bene
	neg.w	speed_y		; se <0 abbiamo toccato il bordo superiore
				; allora inverti la direzione
	bra.s	Muovisprite	; ricalcola la nuova posizione

no_tocca_sopra:
	cmp.w	#243,d0	; quando la posizione vale 256-13=243, lo sprite
			; tocca il bordo inferiore
	blo.s	no_tocca_sotto
	neg.w	speed_y		; se lo sprite tocca il bordo inferiore,
				; inverti la velocita`
	bra.s	Muovisprite	; ricacola la nuova posizione

no_tocca_sotto:
	move	d0,sprite_y	; aggiorna la posizione
posiz_x:
	move.w	sprite_x(PC),d1	; leggi la vecchia posizione
	add.w	speed_x(PC),d1	; aggiungi la velocita`
	bpl.s	no_tocca_sinistra
	neg.w	speed_x		; se <0 tocca a sinistra: inverti la direzione
	bra.s	posiz_x		; ricalcola nuova posizione oriz.

no_tocca_sinistra:
	cmp.w	#304,d1	; quando la posizione vale 320-16=304, lo sprite
			; tocca il bordo destro
	blo.s	no_tocca_destra
	neg.w	speed_x		; se tocca a destra, inverti la direzione
	bra.s	posiz_x		; ricalcola nuova posizione oriz.

no_tocca_destra:
	move.w	d1,sprite_x	; aggiorna la posizione

	lea	miosprite,a1	; indirizzo sprite
	moveq	#13,d2		; altezza sprite
        bsr.s	UniMuoviSprite  ; esegue la routine universale che posiziona
               			; lo sprite
	rts

-	-	-	-	-	-	-	-	-	-

Ora vediamo un'altro possibile utilizzo dei CC. Supponiamo di voler fare uno
scroll verticale ad un bitplane, usando una routine diversa da quella che
"preleva" l'indirizzo dai bplpointers, adda 40 e lo ripunta.
Supponiamo che questa routine debba solo addare 40 al bpl0ptl, ossia alla
word bassa dell'indirizzo. Il problema si pone quando ci troviamo, ad esempio,
all'indirizzo $2ffE2, per cui addando 40 andremmo a $3000a, e anche la word
alta cambia:

Copperlist:
	...
	dc.w	$e0	; bpl0pth
PlaneH:
	dc.w	$0002
	dc.w	$e2	; bpl0ptl
PlaneL:
	dc.w	$ffe2

Come vedete se addiamo 40 a PlaneL otteniamo $000A, ma PlaneH rimane $0002!
Per questo ogni volta preleviamo l'indirizzo, sommiamo e lo rimettiamo nelle
2 word! Altrimenti quando "scatta" la word alta come faremmo?
Con i CC comunque qualcosa si puo' fare. Abbiamo detto che $ffe2+40 ci da
la soluzione esatta, $000a, ma si setta anche il Carry, per il riporto, dato
che abbiamo superato $ffff. Allo potremmo scrivere:

Scroll:
	add.w	#40,PlaneL	; Scendi di una linea aggiungendo 40 alla
				; word bassa dell'indirizzo a cui punta il
				; bpl1pt
	bcc.s	NonScattato	; Abbiamo superato il valore contenibile
				; dalla word e dobbiamo modificare anche
				; la word alta? Se no salta...
	addq.w	#1,PlaneH	; Altrimenti adda di 1 la word alta, ossia
				; "esegui" il riporto dell'add sul PlaneL!
NonScattato:
	rts

Questi sono alcuni esempi di come si possono "rivedere" routines gia' note.

