
; Lezione3c4.s	; BARRETTA CHE SCENDE FATTA CON MOVE&WAIT DEL COPPER
		; (PER FARLA SCENDERE USATE IL TASTO DESTRO DEL MOUSE)

;	In questo listato viene fatta scendere una vera e propria
;	barra sfumata composta di 10 wait, dunque si agisce su 10 wait!
;	La differenza con Lezione3c3.s sta nell'utilizzo di una sola label
;	BARRA anziche' di 10 label, grazie alla distanza di indirizzamento.

	SECTION	BarraRossa,CODE	; anche in Fast va bene

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary, routine della EXEC che apre
				; le librerie, e da in uscita l'indirizzo
				; di base di quella libreria da cui fare le
				; distanze di indirizzamento (Offset)
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist
				; di sistema
	move.l	#COPPERLIST,$dff080	; COP1LC - Puntiamo la nostra COP
	move.w	d0,$dff088		; COPJMP1 - Facciamo partire la COP
mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	btst	#2,$dff016	; POTINP - Tasto destro del mouse premuto?
	bne.s	Aspetta		; Se no, non eseguire Muovicopper

	bsr.s	MuoviCopper	; Sempre piu' difficile

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Puntiamo la cop di sistema
	move.w	d0,$dff088		; COPJMP1 - facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts


;	Questa routine sposta una barra composta di 10 wait

MuoviCopper:
	LEA	BARRA,a0	; mettiamo in a0 l'indirizzo di BARRA:
	cmpi.b	#$fc,8*9(a0)	; siamo arrivati alla linea $fc?
	beq.s	Finito		; se si, siamo in fondo e non continuiamo
	addq.b	#1,(a0)		; WAIT 1 cambiato (indiretto senza distanza)
	addq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	addq.b	#1,8*2(a0)	; tra un wait e l'altro e' di 8 bytes, infatti
	addq.b	#1,8*3(a0)	; dc.w $xx07,$FFFE,$180,$xxx e' una long.
	addq.b	#1,8*4(a0)	; se quindi dall'indirizzo del primo wait
	addq.b	#1,8*5(a0)	; facciamo una distanza di indirizzamento di
	addq.b	#1,8*6(a0)	; 8 modifichiamo il dc.w $xx07,$fffe seguente.
	addq.b	#1,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	addq.b	#1,8*8(a0)	; barra rossa ogni volta per farla scendere!
	addq.b	#1,8*9(a0)	; ultimo wait! (il BARRA10 del sorgente prec.)
Finito:
	rts	; P.S: Con questo RTS si torna al ciclo MOUSE che aspetta
		; per la temporizzazione.

;	NOTA: "*" significa "moltiplicato", "/" significa "diviso"

	; dati

GfxName:
	dc.b	"graphics.library",0,0	; NOTA: per mettere in memoria
					; dei caratteri usare sempre il dc.b
					; e metterli tra "", oppure ''

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C	; Le copperlist DEVONO essere in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO

BARRA:
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79
	dc.w	$180,$300	; COLOR0 - inizio la barra rossa: rosso a 3
	dc.w	$7a07,$FFFE	; WAIT - linea seguente
	dc.w	$180,$600	; COLOR0 -rosso a 6
	dc.w	$7b07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$7c07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; rosso a 15 (al massimo)
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; rosso a 6
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; rosso a 3
	dc.w	$8207,$FFFE
	dc.w	$180,$000	; colore NERO

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

Per far scendere la barra basta cambiare la COPPERLIST, in particolare
in questo esempio vengono cambiati i vari WAIT che compongono la barra, nel
loro primo byte, ossia quello che definisce la linea verticale da attendere:

BARRA:
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79
	dc.w	$180,$300	; COLOR0 - inizio la barra rossa: rosso a 3
	dc.w	$7a07,$FFFE	; linea seguente
	dc.w	$180,$600	; rosso a 6
	...

Mettendo una label a quel byte, si puo' cambiare quel byte agendo sulla
label stessa, in questo caso BARRA. Pero' la barra in questione e' fatta
di 9 wait+color0, quindi per "spostarla" bisogna cambiare tutti e 9 i
wait, mentre i color0 (dc.w $180,$xxx) che si trovano sotto i wait rimangono
inalterati. Per raggiungere tutti e 9 i WAIT, anziche' mettere una LABEL
a tutti, e' piu' veloce caricare l'indirizzo del primo in un registro e
cambiare gli altri facendo delle distanze di indirizzamento:

MuoviCopper:
	LEA	BARRA,a0
	cmpi.b	#$fc,8*9(a0)	; controlliamo l'ultimo wait, quello che
	beq.s	Finito		; definisce la parte inferiore della barra.
	addq.b	#1,(a0)		; cambio BARRA:
	addq.b	#1,8(a0)	; cambio il byte 2 long dopo BARRA:
	addq.b	#1,8*2(a0)	; cambio il byte 4 long dopo BARRA:
	addq.b	#1,8*3(a0)	; cambio il byte 6 long dopo...
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)
	addq.b	#1,8*8(a0)
	addq.b	#1,8*9(a0)
Finito:
	rts

NOTA: Provate a fare un "D MuoviCopper", e verificherete che gli 8*2,8*3 etc.
sono assemblati come:

	ADDQ.B	#1,$8(A0)
	ADDQ.B	#1,$10(A0)
	ADDQ.B	#1,$18(A0)
	ADDQ.B	#1,$20(A0)
	ADDQ.B	#1,$28(A0)

Ossia con il risultato di 8*2 (ossia 16, ovvero $10), di 8*3 ($18)...

Come ultima modifica, provate a cambiare il $fc della linea

	cmpi.b	#$fc,8*9(a0)

Mettendoci valori inferiori, e verificherete che la barra scende fino alla
linea che specificate.

