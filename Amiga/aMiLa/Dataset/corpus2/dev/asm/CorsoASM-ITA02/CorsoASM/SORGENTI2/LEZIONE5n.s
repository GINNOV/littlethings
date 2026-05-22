
; Lezione5n.s	FUSIONE DI 3 EFFETTI COPPER + FIGURA AD 8 COLORI con
;		EFFETTI $dff102 e bitplane pointers

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO I NOSTRI BITPLANES

	MOVE.L	#PIC,d0		; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP	; Rifai D1 volte POINTBP (D1=num of bitplanes)

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	bsr.w	mt_init		; Inizializza routine musicale

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.w	muovicopper	; barra rossa sotto linea $ff
	bsr.s	CopperDestSin	; Routine di scorrimento destra/sinistra
	BSR.w	scrollcolors	; scorrimento ciclico dei colori
	bsr.w	ScorriPlanes	; scorrimento su-giu della figura
	bsr.w	Ondula		; Ondulazione tramite molti $dff102
	bsr.w	mt_music	; Suona la musica

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	bsr.w	mt_end		; Termina la routine musicale

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts			; USCITA DAL PROGRAMMA


;	Dati

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

; **************************************************************************
; *		BARRA A SCORRIMENTO ORIZZONTALE (Lezione3h.s)		   *
; **************************************************************************

CopperDESTSIN:
	CMPI.W	#85,DestraFlag		; VAIDESTRA eseguita 85 volte?
	BNE.S	VAIDESTRA		; se non ancora, rieseguila
	CMPI.W	#85,SinistraFlag	; VAISINISTRA eseguita 85 volte?
	BNE.S	VAISINISTRA		; se non ancora, rieseguila
	CLR.W	DestraFlag	; la routine VAISINISTRA e' stata eseguita
	CLR.W	SinistraFlag	; 85 volte, riparti
	RTS			; TORNIAMO AL LOOP mouse


VAIDESTRA:			; questa routine sposta la barra verso DESTRA
	lea	CopBar+1,A0	; Mettiamo in A0 l'indirizzo del primo XX
	move.w	#29-1,D2	; dobbiamo cambiare 29 wait (usiamo un DBRA)
DestraLoop:
	addq.b	#2,(a0)		; aggiungiamo 2 alla coordinata X del wait
	ADD.W	#16,a0		; andiamo al prossimo wait da cambiare
	dbra	D2,DestraLoop	; ciclo eseguito d2 volte
	addq.w	#1,DestraFlag	; segnamo che abbiamo eseguito VAIDESTRA
	RTS			; TORNIAMO AL LOOP mouse


VAISINISTRA:			; questa routine sposta la barra verso SINISTRA
	lea	CopBar+1,A0
	move.w	#29-1,D2	; dobbiamo cambiare 29 wait
SinistraLoop:
	subq.b	#2,(a0)		; sottraiamo 2 alla coordinata X del wait
	ADD.W	#16,a0		; andiamo al prossimo wait da cambiare
	dbra	D2,SinistraLoop	; ciclo eseguito d2 volte
	addq.w	#1,SinistraFlag ; Annotiamo lo spostamento
	RTS			; TORNIAMO AL LOOP mouse


DestraFlag:		; In questa word viene tenuto il conto delle volte
	dc.w	0	; che e' stata eseguita VAIDESTRA

SinistraFlag:		; In questa word viene tenuto il conto delle volte
	dc.w    0	; che e' stata eseguita VAISINISTRA

; **************************************************************************
; *		BARRA ROSSA SOTTO LA LINEA $FF (Lezione3f.s)		   *
; **************************************************************************

MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; Dobbiamo salire o scendere?
	beq.w	VAIGIU
	cmpi.b	#$0a,(a0)	; siamo arrivati alla linea $0a+$ff? (265)
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	subq.b	#1,8*2(a0)	; tra un wait e l'altro e' di 8 bytes
	subq.b	#1,8*3(a0)
	subq.b	#1,8*4(a0)
	subq.b	#1,8*5(a0)
	subq.b	#1,8*6(a0)
	subq.b	#1,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	subq.b	#1,8*8(a0)	; barra rossa ogni volta per farla salire!
	subq.b	#1,8*9(a0)
	rts

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	rts			; fara' saltare alla routine VAIGIU, e
				; la barra scedera'

VAIGIU:
	cmpi.b	#$2c,8*9(a0)	; siamo arrivati alla linea $2c?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	addq.b	#1,8*2(a0)	; tra un wait e l'altro e' di 8 bytes
	addq.b	#1,8*3(a0)
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	addq.b	#1,8*8(a0)	; barra rossa ogni volta per farla scendere!
	addq.b	#1,8*9(a0)
	rts

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.


SuGiu:
	dc.b	0,0

; **************************************************************************
; *		SCORRIMENTO CICLICO DEI COLORI (Lezione3E.s)		   *
; **************************************************************************

Scrollcolors:	
	move.w	col2,col1	; col2 copiato in col1
	move.w	col3,col2	; col3 copiato in col2
	move.w	col4,col3	; col4 copiato in col3
	move.w	col5,col4	; col5 copiato in col4
	move.w	col6,col5	; col6 copiato in col5
	move.w	col7,col6	; col7 copiato in col6
	move.w	col8,col7	; col8 copiato in col7
	move.w	col9,col8	; col9 copiato in col8
	move.w	col10,col9	; col10 copiato in col9
	move.w	col11,col10	; col11 copiato in col10
	move.w	col12,col11	; col12 copiato in col11
	move.w	col13,col12	; col13 copiato in col12
	move.w	col14,col13	; col14 copiato in col13
	move.w	col1,col14	; col1 copiato in col14
	rts


; **************************************************************************
; *	SCORRIMENTO IN ALTO E IN BASSO DELLA FIGURA (da Lezione5g.s)	   *
; **************************************************************************

;	Questa routine sposta la figura in alto e in basso, agendo sui
;	puntatori ai bitplanes in copperlist (tramite la label BPLPOINTERS)

ScorriPlanes:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poniamo
	move.w	6(a1),d0	; in d0 - il contrario della routine che
				; punta i bitplanes! Qua invece di mettere
				; l'indirizzo lo prendiamo!!!

	TST.B	SuGiu3		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei sub)
	beq.w	VAIGIU3
	cmp.l	#PIC-(40*18),d0	; siamo arrivati abbastanza in BASSO?
	beq.w	MettiGiu3	; se si, siamo in fondo e dobbiamo risalire
	sub.l	#40,d0		; sottraiamo 40, ossia 1 linea, facendo
				; scorrere in BASSO la figura
	bra.s	Finito3

MettiGiu3:
	clr.b	SuGiu3		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	bra.s	Finito3		; fara' saltare alla routine VAIGIU

VAIGIU3:
	cmpi.l	#PIC+(40*130),d0 ; siamo arrivati abbastanza in ALTO?
	beq.s	MettiSu3	; se si, siamo in fondo e dobbiamo risalire
	add.l	#40,d0		; Aggiungiamo 40, ossia 1 linea, facendo
				; scorrere in ALTO la figura
	bra.s	finito3

MettiSu3:
	move.b	#$ff,SuGiu3	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

Finito3:			; PUNTIAMO I PUNTATORI BITPLANES
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP2:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP2	; Rifai D1 volte POINTBP (D1=num of bitplanes)
	rts


;	Questo byte, indicato dalla label SuGiu, e' un FLAG.

SuGiu3:
	dc.b	0,0


; **************************************************************************
; *	EFFETTO DI ONDULAZIONE TRAMITE MOLTI $dff102 (Lezione5h.s)	   *
; **************************************************************************


Ondula:
	LEA	CON1EFFETTO+8,A0 ; Indirizzo word sorgente in a0
	LEA	CON1EFFETTO,A1	; Indirizzo delle word destinazione in a1
	MOVEQ	#19,D2		; 20 bplcon1 da cambiare in COPLIST
SCAMBIA:
	MOVE.W	(A0),(A1)	; copia due word consecutive - scorrimento!
	ADDQ.W	#8,A0		; prossima coppia di word
	ADDQ.W	#8,A1		; prossima coppia di word
	DBRA	D2,SCAMBIA	; ripeti "SCAMBIA" il numero giusto di VOLTE

	MOVE.W	CON1EFFETTO,ULTIMOVALORE ; per rendere infinito il ciclo
	RTS				; copiamo il primo valore nell'ultimo
					; ogni volta.

; **************************************************************************
; *		ROUTINE CHE SUONA MUSICHE SOUNDTRACKER/PROTRACKER	   *
; **************************************************************************

	include	"music.s"	; routine 100% funzionante su tutti gli Amiga

; **************************************************************************
; *				SUPER COPPERLIST			   *
; **************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:

	; Facciamo puntare gli sprite a ZERO, per eliminarli, o ce li troviamo
	; in giro impazziti a disturbare!!!

	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

; Per uno schermo a 3 bitplanes: (8 colori)

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)

;	Facciamo puntare i bitplanes direttamente mettendo nella copperlist
;	i registri $dff0e0 e seguenti qua di seguito con gli indirizzi
;	dei bitplanes che saranno messi dalla routine POINTBP

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

;	Gli 8 colori della figura qua sono resi piu' "verdi"

	dc.w	$0180,$000	; color0
	dc.w	$0182,$070	; color1
	dc.w	$0184,$0f0	; color2
	dc.w	$0186,$0c0	; color3
	dc.w	$0188,$090	; color4
	dc.w	$018a,$030	; color5
	dc.w	$018c,$070	; color6
	dc.w	$018e,$040	; color7

;	L'effetto di Lezione3e.s spostato piu' in ALTO

	dc.w	$2c07,$fffe	; aspettiamo la linea 154 ($9a in esadecimale)
	dc.w	$180		; REGISTRO COLOR0
col1:
	dc.w	$0f0		; VALORE DEL COLOR 0 (che sara' modificato)
	dc.w	$2d07,$fffe ; aspettiamo la linea 155 (non sara' modificata)
	dc.w	$180		; REGISTRO COLOR0 (non sara' modificato)
col2:
	dc.w	$0d0		; VALORE DEL COLOR 0 (sara' modificato)
	dc.w	$2e07,$fffe	; aspettiamo la linea 156 (non modificato,ecc.)
	dc.w	$180		; REGISTRO COLOR0
col3:
	dc.w	$0b0		; VALORE DEL COLOR 0
	dc.w 	$2f07,$fffe	; aspettiamo la linea 157
	dc.w	$180		; REGISTRO COLOR0
col4:
	dc.w	$090		; VALORE DEL COLOR 0
	dc.w	$3007,$fffe	; aspettiamo la linea 158
	dc.w	$180		; REGISTRO COLOR0
col5:
	dc.w	$070		; VALORE DEL COLOR 0
	dc.w	$3107,$fffe	; aspettiamo la linea 159
	dc.w	$180		; REGISTRO COLOR0
col6:
	dc.w	$050		; VALORE DEL COLOR 0
	dc.w	$3207,$fffe	; aspettiamo la linea 160
	dc.w	$180		; REGISTRO COLOR0
col7:
	dc.w	$030		; VALORE DEL COLOR 0
	dc.w	$3307,$fffe	; aspettiamo la linea 161
	dc.w	$180		; color0... (ora avete capito i commenti,
col8:				; posso anche smettere di metterli da qua!)
	dc.w	$030
	dc.w	$3407,$fffe	; linea 162
	dc.w	$180
col9:
	dc.w	$050
	dc.w	$3507,$fffe	;  linea 163
	dc.w	$180
col10:
	dc.w	$070
	dc.w	$3607,$fffe	;  linea 164
	dc.w	$180
col11:
	dc.w	$090
	dc.w	$3707,$fffe	;  linea 165
	dc.w	$180
col12:
	dc.w	$0b0
	dc.w	$3807,$fffe	;  linea 166
	dc.w	$180
col13:
	dc.w	$0d0
	dc.w	$3907,$fffe	;  linea 167
	dc.w	$180
col14:
	dc.w	$0f0
	dc.w 	$3a07,$fffe	;  linea 168

	dc.w	$0180,$000	; color0	; colori reali della figura
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

;	Effetto copper dell'ondulazione col $dff102 di Lezione5h.s "ristretto"

	DC.W	$102
CON1EFFETTO:
	dc.w	$000
	DC.W	$4007,$FFFE,$102,$00
	DC.W	$4407,$FFFE,$102,$11
	DC.W	$4807,$FFFE,$102,$11
	DC.W	$4C07,$FFFE,$102,$22
	DC.W	$5007,$FFFE,$102,$33
	DC.W	$5407,$FFFE,$102,$44
	DC.W	$5807,$FFFE,$102,$66
	DC.W	$5C07,$FFFE,$102,$66
	DC.W	$6007,$FFFE,$102,$77
	DC.W	$6407,$FFFE,$102,$77
	DC.W	$6807,$FFFE,$102,$77
	DC.W	$6C07,$FFFE,$102,$66
	DC.W	$7007,$FFFE,$102,$66
	DC.W	$7407,$FFFE,$102,$55
	DC.W	$7807,$FFFE,$102,$33
	DC.W	$7C07,$FFFE,$102,$22
	DC.W	$8007,$FFFE,$102,$11
	DC.W	$8407,$FFFE,$102,$11
	DC.W	$8807,$FFFE,$102,$00
	DC.W	$8C07,$FFFE,$102
ULTIMOVALORE:
	DC.W	$00

;	EFFETTO DELLA LEZIONE3h.s

	dc.w	$9007,$fffe	; aspettiamo l'inizio della linea
	dc.w	$180,$000	; grigio al minimo, ossia NERO!!!
CopBar:
	dc.w	$9031,$fffe	; wait che cambiamo ($9033,$9035,$9037...)
	dc.w	$180,$100	; colore rosso
	dc.w	$9107,$fffe	; wait che non cambiamo (Inizio linea)
	dc.w	$180,$111	; colore GRIGIO (parte dall'inizio linea fino
	dc.w	$9131,$fffe	; a questo WAIT, che noi cambiaremo...
	dc.w	$180,$200	; dopo il quale comincia il ROSSO

;	    WAIT FISSI (poi grigio) - WAIT DA CAMBIARE (seguiti dal rosso)

	dc.w	$9207,$fffe,$180,$120,$9231,$fffe,$180,$301 ; linea 3
	dc.w	$9307,$fffe,$180,$230,$9331,$fffe,$180,$401 ; linea 4
	dc.w	$9407,$fffe,$180,$240,$9431,$fffe,$180,$502 ; linea 5
	dc.w	$9507,$fffe,$180,$350,$9531,$fffe,$180,$603 ; ....
	dc.w	$9607,$fffe,$180,$360,$9631,$fffe,$180,$703
	dc.w	$9707,$fffe,$180,$470,$9731,$fffe,$180,$803
	dc.w	$9807,$fffe,$180,$580,$9831,$fffe,$180,$904
	dc.w	$9907,$fffe,$180,$690,$9931,$fffe,$180,$a04
	dc.w	$9a07,$fffe,$180,$7a0,$9a31,$fffe,$180,$b04
	dc.w	$9b07,$fffe,$180,$8b0,$9b31,$fffe,$180,$c05
	dc.w	$9c07,$fffe,$180,$9c0,$9c31,$fffe,$180,$d05
	dc.w	$9d07,$fffe,$180,$ad0,$9d31,$fffe,$180,$e05
	dc.w	$9e07,$fffe,$180,$be0,$9e31,$fffe,$180,$f05
	dc.w	$9f07,$fffe,$180,$cf0,$9f31,$fffe,$180,$e05
	dc.w	$a007,$fffe,$180,$be0,$a031,$fffe,$180,$d05
	dc.w	$a107,$fffe,$180,$ad0,$a131,$fffe,$180,$c05
	dc.w	$a207,$fffe,$180,$9c0,$a231,$fffe,$180,$b04
	dc.w	$a307,$fffe,$180,$8b0,$a331,$fffe,$180,$a04
	dc.w	$a407,$fffe,$180,$7a0,$a431,$fffe,$180,$904
	dc.w	$a507,$fffe,$180,$690,$a531,$fffe,$180,$803
	dc.w	$a607,$fffe,$180,$580,$a631,$fffe,$180,$703
	dc.w	$a707,$fffe,$180,$470,$a731,$fffe,$180,$603
	dc.w	$a807,$fffe,$180,$360,$a831,$fffe,$180,$502
	dc.w	$a907,$fffe,$180,$250,$a931,$fffe,$180,$402
	dc.w	$aa07,$fffe,$180,$140,$aa31,$fffe,$180,$301
	dc.w	$ab07,$fffe,$180,$130,$ab31,$fffe,$180,$202
	dc.w	$ac07,$fffe,$180,$120,$ac31,$fffe,$180,$103
	dc.w	$ad07,$fffe,$180,$111,$ad31,$fffe,$180,$004

	dc.w	$ae07,$fffe
	dc.w	$180,$002
	dc.w	$af07,$fffe
	dc.w	$180,$003

;	Effetto specchio "cilindrico" della Lezione3g.s (+ridefinizione colori)

	dc.w	$0182,$235	; color1
	dc.w	$0184,$99e	; color2
	dc.w	$0186,$88c	; color3
	dc.w	$0188,$659	; color4
	dc.w	$018a,$122	; color5
	dc.w	$018c,$337	; color6
	dc.w	$018e,$224	; color7

	dc.w	$b007,$fffe
	dc.w	$180,$004	; Color0
	dc.w	$102,$011	; bplcon1
	dc.w	$108,-40*7	; Bpl1Mod - specchio dimezzato 5 volte
	dc.w	$10a,-40*7	; Bpl2Mod
	dc.w	$b307,$fffe

	dc.w	$180,$006	; Color0
	dc.w	$102,$022	; bplcon1
	dc.w	$108,-40*6	; Bpl1Mod - specchio dimezzato 4 volte
	dc.w	$10a,-40*6	; Bpl2Mod

	dc.w	$b607,$fffe

	dc.w	$0182,$245	; color1
	dc.w	$0184,$9cf	; color2
	dc.w	$0186,$89c	; color3
	dc.w	$0188,$669	; color4
	dc.w	$018a,$132	; color5
	dc.w	$018c,$347	; color6
	dc.w	$018e,$234	; color7

	dc.w	$180,$008	; Color0
	dc.w	$102,$033	; bplcon1
	dc.w	$108,-40*5	; Bpl1Mod - specchio dimezzato 3 volte
	dc.w	$10a,-40*5	; Bpl2Mod

	dc.w	$bb07,$fffe

	dc.w	$180,$00a	; Color0
	dc.w	$102,$044	; bplcon1
	dc.w	$108,-40*4	; Bpl1Mod - specchio dimezzato 2 volte
	dc.w	$10a,-40*4	; Bpl2Mod

	dc.w	$c307,$fffe

	dc.w	$0182,$355	; color1
	dc.w	$0184,$abf	; color2
	dc.w	$0186,$9ac	; color3
	dc.w	$0188,$779	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$457	; color6
	dc.w	$018e,$344	; color7
	dc.w	$180,$00c	; Color0
	dc.w	$102,$055	; bplcon1
	dc.w	$108,-40*3	; Bpl1Mod - specchio dimezzato
	dc.w	$10a,-40*3	; Bpl2Mod

	dc.w	$d007,$fffe

	dc.w	$180,$00e	; Color0
	dc.w	$102,$066	; bplcon1
	dc.w	$108,-40*2	; Bpl1Mod - specchio normale
	dc.w	$10a,-40*2	; Bpl2Mod

	dc.w	$d607,$fffe
	dc.w	$0182,$465	; color1
	dc.w	$0184,$cdf	; color2
	dc.w	$0186,$bbc	; color3
	dc.w	$0188,$889	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$557	; color6
	dc.w	$018e,$444	; color7

	dc.w	$180,$00f	; Color0
	dc.w	$102,$077	; bplcon1
	dc.w	$108,-40	; Bpl1Mod - FLOOD, linee ripetute per
	dc.w	$10a,-40	; Bpl2Mod - effetto centrale di ingrandimento

	dc.w	$da07,$fffe

	dc.w	$0182,$355	; color1
	dc.w	$0184,$abf	; color2
	dc.w	$0186,$9ac	; color3
	dc.w	$0188,$779	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$457	; color6
	dc.w	$018e,$344	; color7
	dc.w	$180,$00e	; Color0
	dc.w	$102,$066	; bplcon1
	dc.w	$108,-40*2	; Bpl1Mod - specchio normale
	dc.w	$10a,-40*2	; Bpl2Mod

	dc.w	$e007,$fffe

	dc.w	$0182,$245	; color1
	dc.w	$0184,$9cf	; color2
	dc.w	$0186,$89c	; color3
	dc.w	$0188,$669	; color4
	dc.w	$018a,$132	; color5
	dc.w	$018c,$347	; color6
	dc.w	$018e,$234	; color7
	dc.w	$180,$00c	; Color0
	dc.w	$102,$055	; bplcon1
	dc.w	$108,-40*3	; Bpl1Mod - specchio dimezzato
	dc.w	$10a,-40*3	; Bpl2Mod

	dc.w	$ed07,$fffe

	dc.w	$180,$00a	; Color0
	dc.w	$102,$044	; bplcon1
	dc.w	$108,-40*4	; Bpl1Mod - specchio dimezzato 2 volte
	dc.w	$10a,-40*4	; Bpl2Mod

	dc.w	$f507,$fffe

	dc.w	$0182,$235	; color1
	dc.w	$0184,$99e	; color2
	dc.w	$0186,$88c	; color3
	dc.w	$0188,$659	; color4
	dc.w	$018a,$122	; color5
	dc.w	$018c,$337	; color6
	dc.w	$018e,$224	; color7
	dc.w	$180,$008	; Color0
	dc.w	$102,$033	; bplcon1
	dc.w	$108,-40*5	; Bpl1Mod - specchio dimezzato 3 volte
	dc.w	$10a,-40*5	; Bpl2Mod

	dc.w	$fa07,$fffe

	dc.w	$180,$006	; Color0
	dc.w	$102,$022	; bplcon1
	dc.w	$108,-40*6	; Bpl1Mod - specchio dimezzato 4 volte
	dc.w	$10a,-40*6	; Bpl2Mod

	dc.w	$fd07,$fffe

	dc.w	$180,$004	; Color0
	dc.w	$102,$011	; bplcon1
	dc.w	$108,-40*7	; Bpl1Mod - specchio dimezzato 5 volte
	dc.w	$10a,-40*7	; Bpl2Mod

	dc.w	$ff07,$fffe

	dc.w	$180,$002	; Color0
	dc.w	$102,$000	; bplcon1
	dc.w	$108,-40	; ferma l'immagine per evitare di visualizzare
	dc.w	$10a,-40	; i byte prima della RAW

;	Effetto della lezione3f.s

	dc.w	$ffdf,$fffe	; ATTENZIONE! WAIT ALLA FINE LINEA $FF!
				; i wait dopo questo sono sotto la linea
				; $FF e ripartono da $00!!

	dc.w	$0107,$FFFE	; una barretta fissa verde SOTTO la linea $FF!
	dc.w	$180,$010
	dc.w	$0207,$FFFE
	dc.w	$180,$020
	dc.w	$0307,$FFFE
	dc.w	$180,$030
	dc.w	$0407,$FFFE
	dc.w	$180,$040
	dc.w	$0507,$FFFE
	dc.w	$180,$030
	dc.w	$0607,$FFFE
	dc.w	$180,$020
	dc.w	$0707,$FFFE
	dc.w	$180,$010
	dc.w	$0807,$FFFE
	dc.w	$180,$000

BARRA:
	dc.w	$0907,$FFFE	; aspetto la linea $79
	dc.w	$180,$300	; inizio la barra rossa: rosso a 3
	dc.w	$0a07,$FFFE	; linea seguente
	dc.w	$180,$600	; rosso a 6
	dc.w	$0b07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$0c07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$0d07,$FFFE
	dc.w	$180,$f00	; rosso a 15 (al massimo)
	dc.w	$0e07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$0f07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$1007,$FFFE
	dc.w	$180,$600	; rosso a 6
	dc.w	$1107,$FFFE
	dc.w	$180,$300	; rosso a 3
	dc.w	$1207,$FFFE
	dc.w	$180,$000	; colore NERO

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


; **************************************************************************
; *			FIGURA AD 8 COLORI 320x256			   *
; **************************************************************************

	dcb.b	40*98,0		; spazio azzerato

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi
	dcb.b	40*8,0		; spazio azzerato

; **************************************************************************
; *				MUSICA PROTRACKER			   *
; **************************************************************************

mt_data:
	incbin	"mod.purple-shades"

	end

; **************************************************************************

Questo listato non e' altro che Lezione4c.s a cui ho aggiunto Lezione4g.s
e Lezione4h.s, le uniche modifiche sono due:
1) Ho dovuto diminuire l'effetto di "ondulato" come numero di WAIT, per farlo
entrare tra un'effetto e l'altro, passando da 45 a 20.
2) Ho cambiato la palette della figura nella parte superiore, rendendola verde
come se la figura si "infilasse" dentro l'effetto "scrollColors", e ho
cambiato i colori qua e la' per migliorare (e allungare) la SUPERCOPPERLIST!

La vera notita' e' l'inserimento della routine che suona la musica!
Intanto per cominciare anziche' inserirla all'interno del listato ho preferito
utilizzare la direttiva dell'ASMONE "INCLUDE", che mi permette, appunto, di
INCLUDERE un pezzo di listato nel mio listato.
Vediamo dunque come si fa a fornire di musica le nostre produzioni: come prima
cosa bisogna chiarire che la musica e' in un formato particolare, in questo
caso PROTRACKER, non si tratta di un pezzo "CAMPIONATO" col digitalizzatore e
risuonato. Ci sono vari programmi per comporre musiche, il piu' usato e' il
protracker (compatibile soundtracker e noisetracker), che salva la musica
nel formato MOD, infatti spesso le musiche in questo formato cominciano per
MOD. Non e' detto pero' che si debba usare sempre una musica protracker, certi
giochi o demo Amiga, specialmente quelli piu' vecchi, hanno musiche composte
con programmi come MED, OCTAMED, FUTURE COMPOSER, SOUNDMONITOR, OKTALYZER, ma
in tal caso bisogna far "suonare" la musica con la routine addetta a suonare
tali formati musicali. Infatti assieme al programma musicale solitamente c'e'
la routine di REPLAY, che puo' essere inclusa nel listato per risuonarla.
Oggigiorno il 99% delle produzioni Amiga usano musiche Protracker, o comunque
sottospecie del protracker, ossia routines che compattano o ottimizzano un
modulo in formato protracker e lo fanno diventare "prorunner" o "propacker",
dunque in questo corso ho incluso la routine che suona musiche PROTRACKER,
compatibile con moduli NOISETRACKER e SOUNDTRACKER vari, che tra l'altro ho
modificato per renderla compatibile al 100% con i microprocessori 68020+ anche
con le CACHE attive, infatti originariamente questa replay routine aveva dei
problemi con processori troppo veloci che causavano il "taglio" e la "perdita"
di alcune note durante l'esecuzione. Dunque la routine "music.s" suona bene
anche sull'Amiga 4000.
Per utilizzarla basta inserirla nel listato, o col comando "I", oppure potete
caricarla in un'altro buffer di testo e copiarla nel vostro listato.
Personalmente preferisco risparmiare spazio nei listati e la includo con la
direttiva "INCLUDE", che in pratica fa assemblare la routine come se fosse
stata inserita manualmente, ma si risparmiano i 21k della sua lunghezza:
immaginate di avere 5 sorgenti, ed in ognuno volete mettere la musica:

	sorgente1.s	12234 bytes
	sorgente2.s	23523 bytes
	sorgente3.s	29382 bytes
	sorgente4.s	78343 bytes
	sorgente5.s	10482 bytes
	sorgente6.s	14925 bytes
	sorgente7.s	29482 bytes

Insieme sono lunghi circa 200k, mentre dopo aver aggiunto a tutti i 21k della
REPLAY-ROUTINE occuperebbero complessivamente circa 300k! Mentre aggiungendo
solo la linea

	include	"music.s"

L'aumento sarebbe di pochi bytes, e il risultato lo stesso.
L'unico particolare e' che, come nell'INCBIN, bisogna trovarsi nella directory
dove si trova il file da includere, o bisogna scrivere tutto il percorso:

	include	"df0:sorgenti2/music.s"

Una volta all'interno del listato, tramite INCLUDE o inserimento, la routine
va fatta funzionare. FACILISSIMO! Basta eseguire "mt_init" prima del loop
MOUSE per inizializzarla, eseguire un "mt_music" ogni FOTOGRAMMA per suonare,
ed eseguire mt_end" alla fine prima di uscire per terminare e chiudere i canali
audio:

	bsr.w	mt_init		; Inizializza routine musicale

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.w	MiaRoutineGrafica
	bsr.w	mt_music

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	bsr.w	mt_end		; Termina la routine musicale

La musica ovviamente deve essere caricata, basta caricarla con INCBIN alla
label "mt_data":

mt_data:
	incbin	"mod.purple-shades"

La musica presente nel disco del corso e' di HI-LITE dei VISION FACTORY, una
musica di qualche annetto fa, la ho scelta anche perche' e' lunga solo 13k!
Se volete far suonare una vostra musica basta caricarla con l'INCBIN:


mt_data:
	incbin	"df1:modules/mod.MIAMUSICA"	; ad esempio!

