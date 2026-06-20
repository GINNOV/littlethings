
; Lezione4c.s	FUSIONE DI 3 EFFETTI COPPER + FIGURA AD 8 COLORI

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;*****************************************************************************
;	FACCIAMO PUNTARE I BPLPOINTERS NELLA COPPELIST AI NOSTRI BITPLANES
;*****************************************************************************


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

;

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; FMODE - Disattiva l'AGA
	move.w	#$c00,$dff106		; BPLCON3 - Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.w	muovicopper	; barra rossa sotto linea $ff
	bsr.w	CopperDestSin	; Routine di scorrimento destra/sinistra
	BSR.w	scrollcolors	; scorrimento ciclico dei colori

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:


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

; Il BPLCON0 per uno schermo a 3 bitplanes: (8 colori)

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)

;	Facciamo puntare i bitplanes direttamente mettendo nella copperlist
;	i registri $dff0e0 e seguenti qua di seguito con gli indirizzi
;	dei bitplanes che saranno messi dalla routine POINTBP

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane - BPL2PT

;	L'effetto di Lezione3e.s spostato piu' in ALTO

	dc.w	$3a07,$fffe	; aspettiamo la linea 154 ($9a in esadecimale)
	dc.w	$180		; REGISTRO COLOR0
col1:
	dc.w	$0f0		; VALORE DEL COLOR 0 (che sara' modificato)
	dc.w	$3b07,$fffe ; aspettiamo la linea 155 (non sara' modificata)
	dc.w	$180		; REGISTRO COLOR0 (non sara' modificato)
col2:
	dc.w	$0d0		; VALORE DEL COLOR 0 (sara' modificato)
	dc.w	$3c07,$fffe	; aspettiamo la linea 156 (non modificato,ecc.)
	dc.w	$180		; REGISTRO COLOR0
col3:
	dc.w	$0b0		; VALORE DEL COLOR 0
	dc.w 	$3d07,$fffe	; aspettiamo la linea 157
	dc.w	$180		; REGISTRO COLOR0
col4:
	dc.w	$090		; VALORE DEL COLOR 0
	dc.w	$3e07,$fffe	; aspettiamo la linea 158
	dc.w	$180		; REGISTRO COLOR0
col5:
	dc.w	$070		; VALORE DEL COLOR 0
	dc.w	$3f07,$fffe	; aspettiamo la linea 159
	dc.w	$180		; REGISTRO COLOR0
col6:
	dc.w	$050		; VALORE DEL COLOR 0
	dc.w	$4007,$fffe	; aspettiamo la linea 160
	dc.w	$180		; REGISTRO COLOR0
col7:
	dc.w	$030		; VALORE DEL COLOR 0
	dc.w	$4107,$fffe	; aspettiamo la linea 161
	dc.w	$180		; color0... (ora avete capito i commenti,
col8:				; posso anche smettere di metterli da qua!)
	dc.w	$030
	dc.w	$4207,$fffe	; linea 162
	dc.w	$180
col9:
	dc.w	$050
	dc.w	$4307,$fffe	;  linea 163
	dc.w	$180
col10:
	dc.w	$070
	dc.w	$4407,$fffe	;  linea 164
	dc.w	$180
col11:
	dc.w	$090
	dc.w	$4507,$fffe	;  linea 165
	dc.w	$180
col12:
	dc.w	$0b0
	dc.w	$4607,$fffe	;  linea 166
	dc.w	$180
col13:
	dc.w	$0d0
	dc.w	$4707,$fffe	;  linea 167
	dc.w	$180
col14:
	dc.w	$0f0
	dc.w 	$4807,$fffe	;  linea 168

	dc.w 	$180,$0000	; Decidiamo il colore NERO per la parte
				; di schermo sotto l'effetto


	dc.w	$0180,$000	; color0
	dc.w	$0182,$550	; color1	; ridefiniamo il colore della
	dc.w	$0184,$ff0	; color2	; scritta COMMODORE! GIALLA!
	dc.w	$0186,$cc0	; color3
	dc.w	$0188,$990	; color4
	dc.w	$018a,$220	; color5
	dc.w	$018c,$770	; color6
	dc.w	$018e,$440	; color7

	dc.w	$7007,$fffe	; Aspettiamo la fine della scritta COMMODORE

;	Gli 8 colori della figura sono definiti qui:

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

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

	dc.w	$9207,$fffe,$180,$222,$9231,$fffe,$180,$300 ; linea 3
	dc.w	$9307,$fffe,$180,$333,$9331,$fffe,$180,$400 ; linea 4
	dc.w	$9407,$fffe,$180,$444,$9431,$fffe,$180,$500 ; linea 5
	dc.w	$9507,$fffe,$180,$555,$9531,$fffe,$180,$600 ; ....
	dc.w	$9607,$fffe,$180,$666,$9631,$fffe,$180,$700
	dc.w	$9707,$fffe,$180,$777,$9731,$fffe,$180,$800
	dc.w	$9807,$fffe,$180,$888,$9831,$fffe,$180,$900
	dc.w	$9907,$fffe,$180,$999,$9931,$fffe,$180,$a00
	dc.w	$9a07,$fffe,$180,$aaa,$9a31,$fffe,$180,$b00
	dc.w	$9b07,$fffe,$180,$bbb,$9b31,$fffe,$180,$c00
	dc.w	$9c07,$fffe,$180,$ccc,$9c31,$fffe,$180,$d00
	dc.w	$9d07,$fffe,$180,$ddd,$9d31,$fffe,$180,$e00
	dc.w	$9e07,$fffe,$180,$eee,$9e31,$fffe,$180,$f00
	dc.w	$9f07,$fffe,$180,$fff,$9f31,$fffe,$180,$e00
	dc.w	$a007,$fffe,$180,$eee,$a031,$fffe,$180,$d00
	dc.w	$a107,$fffe,$180,$ddd,$a131,$fffe,$180,$c00
	dc.w	$a207,$fffe,$180,$ccc,$a231,$fffe,$180,$b00
	dc.w	$a307,$fffe,$180,$bbb,$a331,$fffe,$180,$a00
	dc.w	$a407,$fffe,$180,$aaa,$a431,$fffe,$180,$900
	dc.w	$a507,$fffe,$180,$999,$a531,$fffe,$180,$800
	dc.w	$a607,$fffe,$180,$888,$a631,$fffe,$180,$700
	dc.w	$a707,$fffe,$180,$777,$a731,$fffe,$180,$600
	dc.w	$a807,$fffe,$180,$666,$a831,$fffe,$180,$500
	dc.w	$a907,$fffe,$180,$555,$a931,$fffe,$180,$400
	dc.w	$aa07,$fffe,$180,$444,$aa31,$fffe,$180,$301
	dc.w	$ab07,$fffe,$180,$333,$ab31,$fffe,$180,$202
	dc.w	$ac07,$fffe,$180,$222,$ac31,$fffe,$180,$103
	dc.w	$ad07,$fffe,$180,$113,$ad31,$fffe,$180,$004

	dc.w	$ae07,$FFFE	; prossima linea
	dc.w	$180,$006	; blu a 6
	dc.w	$b007,$FFFE	; salto 2 linee
	dc.w	$180,$007	; blu a 7
	dc.w	$b207,$FFFE	; sato 2 linee
	dc.w	$180,$008	; blu a 8
	dc.w	$b507,$FFFE	; salto 3 linee
	dc.w	$180,$009	; blu a 9
	dc.w	$b807,$FFFE	; salto 3 linee
	dc.w	$180,$00a	; blu a 10
	dc.w	$bb07,$FFFE	; salto 3 linee
	dc.w	$180,$00b	; blu a 11
	dc.w	$be07,$FFFE	; salto 3 linee
	dc.w	$180,$00c	; blu a 12
	dc.w	$c207,$FFFE	; salto 4 linee
	dc.w	$180,$00d	; blu a 13
	dc.w	$c707,$FFFE	; salto 7 linee
	dc.w	$180,$00e	; blu a 14
	dc.w	$ce07,$FFFE	; salto 6 linee
	dc.w	$180,$00f	; blu a 15
	dc.w	$d807,$FFFE	; salto 10 linee
	dc.w	$180,$11F	; schiarisco...
	dc.w	$e807,$FFFE	; salto 16 linee
	dc.w	$180,$22F	; schiarisco...

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

;	Ricordatevi di selezionare la directory dove si trova la figura
;	in questo caso basta scrivere: "V df0:SORGENTI2"


PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

In questo esempio non c'e' nulla di nuovo, ma abbiamo messo insieme molti
degli effetti copper fin qui studiati: Lezione3h.s, Lezione3f.s, Lezione3e.s,
semplicemente caricando quei sorgenti in altri buffer di testo, copiandone la
routine e la parte di copperlist dell'effetto: le routines come si puo' notare
sono una sotto l'altra nell'ordine con cui ho caricato gli esempi, mentre i
wait delle copperlist vanno "AGGIUNTATI" secondo un preciso ordine, in modo che
non si sovrappongano: infatti ho dovuto spostare piu' in altro i wait
dell'effetto Lezione3f.s, mentre gli altri 2 li ho potuti lasciare uguali.
Bastera' poi che nel loop sincronizzato si richiamino le routines:

	bsr.w	muovicopper	; barra rossa sotto linea $ff
	bsr.w	CopperDestSin	; Routine di scorrimento destra/sinistra
	BSR.w	scrollcolors	; scorrimento ciclico dei colori

Spesso si programmano le singole routines separatamente per poi metterle
insieme come in questo esempio; e' bene esercitarsi a montare e smontare
demo grafiche come in questo esempio, perche' in fondo buona parte della
programmazione e' costitutita dal montaggio delle routines. Ogni routine poi
puo' essere riutilizzata in molti listati, con semplici modifiche: per
esempio il programmatore dei TEAM 17 sicuramente ha usato le stesse routines
di gestione joystick e di caricamento da disco su tutti i suoi giochi, e
probabilmente le routines che spostano i personaggi sullo schermo sono
derivate l'una dall'altra con poche modifiche. Ogni routine che programmate
o che trovate in giro puo' servirvi molte volte, sia come esempio sia per
metterla proprio in vostri programmi. Se aveste tutte le routines necessarie
alla programmazione di un gioco separate, ipotizziamo un joystick.s, un
caricadisco.s, un suonamusica.s, un scrollaschermo.s, eccetera, fare il
gioco si limiterebbe ad una operazione simile a chi apparecchia la tavola:
cioe' mettere i tovaglioli, i piatti, le posate al punto giusto, cosi'
dovreste mettere insieme il gioco come un puzzle, cosa che richiederebbe
comunque la conoscenza almeno del funzionamento delle routines.
Il problema di tante demo e di tanti giochi infatti sta nel fatto che le
routines sono ben combinate, la grafica e il suono se le sono fatte, ma
viene il sospetto che le routines provengano da altri programmatori, rubate
o concesse. D'altronde se il gioco funziona, cosa importa? Sara' sempre
un bel gioco ma simile a qualche altro, un incrocio. Quando le routines
uno se le programma da solo, si riconosce sempre perche' o le ha fatte peggio
degli altri, o le ha fatte meglio. Dunque i giochi brutti e quelli bellissimi
sono i piu' "ONESTAMENTE" programmati. Ma vi consiglio di lasciare da parte
l'orgoglio per ora che state imparando, non credo che possiate innovare la
programmazione Amiga ora! Dunque scomponete e riaggiuntate le routines che
trovate nel corso come in questo listato, lo scopo e' imparare, e non c'e'
modo migliore di imparare che aggiuntare e smontare routines. Basta che
poi non andiate in giro con le MIE routines a dire che le avete programmate
voi del tutto. Quando avrete finito questo corso, allora sarete in grado di
farvele, e magari di avere idee innovative, l'assembler non pone limiti.

