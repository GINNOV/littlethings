
; Lezione4a.s	ROUTINE UNIVERSALE DI PUNTAMENTO BITPLANES

	SECTION	CiriBiri,CODE

Inizio:
	MOVE.L	#PIC,d0		; in d0 mettiamo l'indirizzo della PIC,
				; ossia dove inizia il primo bitplane

	LEA	BPLPOINTERS,A1	; in a1 mettiamo l'indirizzo dei
				; puntatori ai planes della COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
				; per eseguire il ciclo col DBRA
POINTBP:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
				; nella word giusta nella copperlist
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
				; mettendo la word ALTA al posto di quella
				; BASSA, permettendone la copia col move.w!!
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
				; nella word giusta nella copperlist
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
				; rimettendo a posto l'indirizzo.
	ADD.L	#40*256,d0	; Aggiungiamo 10240 ad D0, facendolo puntare
				; al secondo bitplane (si trova dopo il primo)
				; (cioe' aggiungiamo la lunghezza di un plane)
				; Nei cicli seguenti al primo faremo puntare
				; al terzo, al quarto bitplane eccetera.

	addq.w	#8,a1		; a1 ora contiene l'indirizzo dei prossimi
				; bplpointers nella copperlist da scrivere.
	dbra	d1,POINTBP	; Rifai D1 volte POINTBP (D1=num of bitplanes)

	rts	; USCITA!!



COPPERLIST:
;	....	; qua metteremo i registri necessari...

;	Facciamo puntare i bitplanes direttamente mettendo nella copperlist
;	i registri $dff0e0 e seguenti qua di seguito con gli indirizzi
;	dei bitplanes che saranno messi dalla routine POINTBP

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane - BPL2PT
;	....
	dc.w	$FFFF,$FFFE	; fine della copperlist

;	Ricordatevi di selezionare la directory dove si trova la figura
;	in questo caso basta scrivere: "V df0:SORGENTI2"

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Provate a fare un "AD", ossia un DEBUG di questa routine. Debuggando fate
particolare attenzione al valore di D0, visibile in alto a destra, nel momento
dei 2 swap. Per verificare il funzionamento, al termine dell'esecuzione
provate a controllare con un "M BPLPOINTERS" se le words sono state cambiate
con l'indirizzo di PIC: SWAPPATO nelle words. (Con un "M PIC" si puo' vedere
a che indirizzo e' stata caricata tramite INCBIN la PIC, che come previsto
e' lunga 30720 bytes: 40*256*3).

