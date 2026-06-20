
; Lezione3c3.s	; BARRETTA CHE SCENDE FATTA CON MOVE&WAIT DEL COPPER
		; (PER FARLA SCENDERE USATE IL TASTO DESTRO DEL MOUSE)


	SECTION	SfumaCop,CODE	; anche in Fast va bene

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

	bsr.s	MuoviCopper	; Routine temporizzata ad 1 frame

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


;	Questa routine sposta in basso una barra composta da 10 wait

MuoviCopper:
	cmpi.b	#$fa,BARRA10	; siamo arrivati alla linea $fa?
	beq.s	Finito		; se si, siamo in fondo e non continuiamo
	addq.b	#1,BARRA	; WAIT 1 cambiato
	addq.b	#1,BARRA2	; WAIT 2 cambiato
	addq.b	#1,BARRA3	; WAIT 3 cambiato
	addq.b	#1,BARRA4	; WAIT 4 cambiato
	addq.b	#1,BARRA5	; WAIT 5 cambiato
	addq.b	#1,BARRA6	; WAIT 6 cambiato
	addq.b	#1,BARRA7	; WAIT 7 cambiato
	addq.b	#1,BARRA8	; WAIT 8 cambiato
	addq.b	#1,BARRA9	; WAIT 9 cambiato
	addq.b	#1,BARRA10	; WAIT 10 cambiato
Finito:
	rts

	; Da qua mettiamo i dati...


GfxName:
	dc.b	"graphics.library",0,0	; NOTA: per mettere in memoria
					; dei caratteri usare sempre il dc.b
					; e metterli tra "", oppure ''

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0


; Qua c'e' la COPPERLIST, fate attenzione alle label BARRA!!!!


	SECTION	CoppyMagic,DATA_C ; Le copperlist DEVONO essere in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - solo colore di sfondo
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO

BARRA:
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79
	dc.w	$180,$300	; COLOR0 - inizio la barra rossa: rosso a 3
BARRA2:
	dc.w	$7a07,$FFFE	; WAIT - linea seguente
	dc.w	$180,$600	; COLOR0 - rosso a 6
BARRA3:
	dc.w	$7b07,$FFFE
	dc.w	$180,$900	; rosso a 9
BARRA4:
	dc.w	$7c07,$FFFE
	dc.w	$180,$c00	; rosso a 12
BARRA5:
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; rosso a 15 (al massimo)
BARRA6:
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; rosso a 12
BARRA7:
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; rosso a 9
BARRA8:
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; rosso a 6
BARRA9:
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; rosso a 3
BARRA10:
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
BARRA2:
	dc.w	$7a07,$FFFE	; linea seguente
	dc.w	$180,$600	; rosso a 6
	...

Mettendo una label a quel byte, si puo' cambiare quel byte agendo sulla
label stessa, in questo caso BARRA.

*******************************************************************************

Vi consiglio di fare molte modifiche, anche le piu' casuali, per
prendere familiarita' col COPPER: Ve ne consiglio alcune:

MODIFICA1: provate a mettere dei ; ai primi 5 ADDQ.b in questo modo:

;	addq.b	#1,BARRA	; WAIT 1 cambiato
;	addq.b	#1,BARRA2	; WAIT 2 cambiato
;	addq.b	#1,BARRA3	; WAIT 3 cambiato
;	addq.b	#1,BARRA4	; WAIT 4 cambiato
;	addq.b	#1,BARRA5	; WAIT 5 cambiato
	addq.b	#1,BARRA6	; WAIT 6 cambiato
	addq.b	#1,BARRA7	; WAIT 7 cambiato
	....

Otterrete l'effetto "CALA IL SIPARIO", infatti la discesa parte in questo modo
dalla meta' dellla barra, e, siccome l'ultimo colore vale fino a che non
viene cambiato, in questo caso l'ultimo colore prima del wait della parte
inferiore della barra che va in fondo e' ROSSO, dunque sembra che la barra si
allunghi fino in fondo allo schermo. Togliete i ; e passiamo alla modifica 2.

MODIFICA2: Per ottenere un effetto "ZOOM" modificate cosi':(usate Amiga+b+c+i)

	addq.b	#1,BARRA
	addq.b	#2,BARRA2
	addq.b	#3,BARRA3
	addq.b	#4,BARRA4
	addq.b	#5,BARRA5
	addq.b	#6,BARRA6
	addq.b	#7,BARRA7
	addq.b	#8,BARRA8
	addq.b	#8,BARRA9
	addq.b	#8,BARRA10

Avete capito come mai si espande la barra? Perche' anziche' andare in basso
insieme i wait hanno diverse "velocita'", per cui le piu' basse si distanziano
da quelle piu' alte.


MODIFICA3: Questa volta "espanderemo" la barra non verso il basso, come nel
	   caso precedente, ma centralmente:

	subq.b	#5,BARRA
	subq.b	#4,BARRA2
	subq.b	#3,BARRA3
	subq.b	#2,BARRA4
	subq.b	#1,BARRA5
	addq.b	#1,BARRA6
	addq.b	#2,BARRA7
	addq.b	#3,BARRA8
	addq.b	#4,BARRA9
	addq.b	#5,BARRA10

Infatti abbiamo cambiato i primi 5 addq in subq, dunque la parte superiore
della barra in questo caso sale invece di scendere, e sale in maniera simile
a quella dello "zoom" precedente, infatti le "velocita'" sono 5,4,3,2,1,
mentre i 5 addq fanno lo stesso per la parte inferiore.


