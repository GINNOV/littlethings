
; Lezione3c2.s	; BARRETTA CHE SCENDE FATTA CON MOVE&WAIT DEL COPPER
		; (PER FARLA SCENDERE USATE IL TASTO DESTRO DEL MOUSE)

;	Aggiunto un controllo della linea raggiunta per fermare lo scroll


	SECTION	MaremmaCop,CODE	; anche in Fast va bene

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
	move.l	#COPPEROZZA,$dff080	; COP1LC - Puntiamo la nostra COP
	move.w	d0,$dff088		; COPJMP1 - Facciamo partire la COP


mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	btst	#2,$dff016	; POTINP - Tasto destro del mouse premuto?
	bne.s	Aspetta		; Se no, non eseguire Muovicopper

	bsr.s	MuoviCopper	; Questa subroutine fa scendere il WAIT!
				; e viene eseguita 1 volta ogni schermata video
Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Puntiamo la cop di sistema
	move.w	d0,$dff088		; COPJMP1 - facciamo partire la cop

	move.l	4.w,a6		; Execbase in A6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts

;
;	Questa piccola routine fa scendere il wait del copper aumentandolo,
;	infatti la prima volta che sara' eseguito cambiera' il
;
;	dc.w	$2007,$FFFE	; WAIT - aspetto la linea $20
;
;	in:
;
;	dc.w	$2107,$FFFE	; WAIT - aspetto la linea $21!
;
;	e cosi' via, fino al massimo specificato, in questo caso $fc
;

MuoviCopper:
	cmpi.b	#$fc,BARRA	; siamo arrivati alla linea $fc?
	beq.s	Finito		; se si, siamo in fondo e non continuiamo
	addq.b	#1,BARRA	; WAIT 1 cambiato, la barra scende di 1 linea
Finito:
	rts

;	In questo caso se BARRA: ha raggiunto il valore $fc si salta l'addq

;	P.S: per ora non si puo' raggiungere la parte finale dello
;	schermo dopo il $FF, vi spieghero' in seguito perche' e come fare.

GfxName:
	dc.b	"graphics.library",0,0	; NOTA: per mettere in memoria
					; dei caratteri usare sempre il dc.b
					; e metterli tra "", oppure ''

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	MiaCoppy,DATA_C	; Le copperlist DEVONO essere in CHIP RAM!

COPPEROZZA:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, solo sfondo.

	dc.w	$180,$004	; COLOR0 - Inizio la cop col colore BLU SCURO

BARRA:
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79

	dc.w	$180,$600	; COLOR0 - inizio la zona rossa: rosso a 6

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

Come modifica, provate a cambiare il $fc della linea

	cmpi.b	#$fc,BARRA

Mettendoci valori diversi e verificherete che la barra scende fino alla
linea che specificate.

