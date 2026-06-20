
; Lezione3d2.s	BARRETTA CHE SALE E SCENDE FATTA COL MOVE&WAIT DEL COPPER


;	Routine eseguita 1 volta ogni 3 fotogrammi


	SECTION	CiriCop,CODE	; anche in Fast va bene

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
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti
frame:
	cmpi.b	#$fe,$dff006	; Siamo alla linea 254? (deve rifare il giro!)
	bne.s	frame		; Se non ancora, non andare avanti
frame2:
	cmpi.b	#$fd,$dff006	; Siamo alla linea 253? (deve rifare il giro!)
	bne.s	frame2		; Se non ancora, non andare avanti

	bsr.s	MuoviCopper	; Una routine che fa scendere e salire la barra


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

;	Routine muovicopper modificata in stile con lo "ZOOM" gia' visto

MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei subq)
	beq.w	VAIGIU
	cmpi.b	#$82,8*9(a0)	; siamo arrivati alla linea $82?
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
;	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	subq.b	#2,8*2(a0)	; tra un wait e l'altro e' di 8 bytes
	subq.b	#3,8*3(a0)
	subq.b	#4,8*4(a0)
	subq.b	#5,8*5(a0)
	subq.b	#6,8*6(a0)
	subq.b	#7,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	subq.b	#8,8*8(a0)	; barra rossa ogni volta per farla salire!
	subq.b	#8,8*9(a0)
	rts

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	rts			; fara' saltare alla routine VAIGIU, e
				; la barra scedera'

VAIGIU:
	cmpi.b	#$fa,8*9(a0)	; siamo arrivati alla linea $fc?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
;	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	addq.b	#2,8*2(a0)	; tra un wait e l'altro e' di 8 bytes
	addq.b	#3,8*3(a0)
	addq.b	#4,8*4(a0)
	addq.b	#5,8*5(a0)
	addq.b	#6,8*6(a0)
	addq.b	#7,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	addq.b	#8,8*8(a0)	; barra rossa ogni volta per farla scendere!
	addq.b	#8,8*9(a0)
	rts

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

SuGiu:
	dc.b	0,0

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C	; Questo comando fa caricare dal sistema
				; operativo questo segmento di dati
				; in CHIP RAM, obbligatoriamente
				; Le copperlist DEVONO essere in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO
	dc.w	$4907,$FFFE	; WAIT - Aspetto la linea $49 (73)
	dc.w	$180,$001	; COLOR0 - blu scurissimo
	dc.w	$4a07,$FFFE	; WAIT - linea 74 ($4a)
	dc.w	$180,$002	; blu un po' piu' intenso
	dc.w	$4b07,$FFFE	; linea 75 ($4b)
	dc.w	$180,$003	; blu piu' chiaro
	dc.w	$4c07,$FFFE	; prossima linea
	dc.w	$180,$004	; blu piu' chiaro
	dc.w	$4d07,$FFFE	; prossima linea
	dc.w	$180,$005	; blu piu' chiaro
	dc.w	$4e07,$FFFE	; prossima linea
	dc.w	$180,$006	; blu a 6
	dc.w	$5007,$FFFE	; salto 2 linee: da $4e a $50, ossia da 78 a 80
	dc.w	$180,$007	; blu a 7
	dc.w	$5207,$FFFE	; sato 2 linee
	dc.w	$180,$008	; blu a 8
	dc.w	$5507,$FFFE	; salto 3 linee
	dc.w	$180,$009	; blu a 9
	dc.w	$5807,$FFFE	; salto 3 linee
	dc.w	$180,$00a	; blu a 10
	dc.w	$5b07,$FFFE	; salto 3 linee
	dc.w	$180,$00b	; blu a 11
	dc.w	$5e07,$FFFE	; salto 3 linee
	dc.w	$180,$00c	; blu a 12
	dc.w	$6207,$FFFE	; salto 4 linee
	dc.w	$180,$00d	; blu a 13
	dc.w	$6707,$FFFE	; salto 5 linee
	dc.w	$180,$00e	; blu a 14
	dc.w	$6d07,$FFFE	; salto 6 linee
	dc.w	$180,$00f	; blu a 15
	dc.w	$780f,$FFFE	; linea $78
	dc.w	$180,$000	; colore NERO

BARRA:
	dc.w	$7907,$FFFE	; aspetto la linea $79
	dc.w	$180,$300	; inizio la barra rossa: rosso a 3
	dc.w	$7a07,$FFFE	; linea seguente
	dc.w	$180,$600	; rosso a 6
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

	dc.w	$fd07,$FFFE	; aspetto la linea $FD
	dc.w	$180,$00a	; blu intensita' 10
	dc.w	$fe07,$FFFE	; linea seguente
	dc.w	$180,$00f	; blu intensita' massima (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

In questo esempio la routine Muovicopper viene eseguita 1 volta ogni 3 FRAME,
ossia 1 volta ogni 3 cinquantesimi di secondo, per rallentare l'eccessiva
velocita', tramite lo stratagemma dei vari cmp con il $dff006.
D'altronde il fatto che e' eseguita ogni 3 fotogrammi la rende anche meno
fluida, come si nota dagli scatti che fa nella parte inferiore.

Questo e' il momento per insegnarvi qualche trucchetto del mestiere.
Se si devono fare delle modifiche a lunghe COPPERLIST, per esempio
si devono cambiare tutti gli 07 in 87, per far aspettare la meta' di ogni
linea anziche' l'inizio, si puo' usare il comando REPLACE dell'editor,
che permette di cambiare una data stringa di caratteri con un'altra.
Per fare la modifica che ho detto, dovete posizionarvi col cursore all'inizio
della COPPERLIST, dopodiche' premere insieme i tasti "AMIGA+SHIFT+R", e
comparira' in altro la scritta "Search For:". Qua dovete scrivere il testo
originale da cercare, in questo caso scrivete "07,$fffe" e premete return.
Ora apparira' la scritta "Replace with:". Qua dovete mettere la modifica che
intendere fare: ossia "87,$fffe". A questo punto il cursore andra' sul
primo 07,$fffe e apparira' la scritta "Replace: (Y/N/L/G)". A questo punto
si deve decidere se scambiare o no lo 07 con l'87. Se lo volete cambiare,
premete la Y, se non lo volete cambiare, premete N. Fatta la scelta il
cursore andra' sul prossimo 07,$fffe e ripetera' la domanda. Cambiateli
pure tutti fino alla fine della copperlist, dopodiche' fermatevi con ESC per
non cambiare quelli nel commento sottostante. Se premete il G alla scelta
saranno scambiati tutti gli 07,$fffe, fino alla fine del testo. Pensateci
bene prima di usare il G (GLOBALE), potreste cambiare qualcosa che non andava
cambiato. E' meglio procedere facendo Y o N fino alla fine della zona da
cambiare, dopodiche' premete ESC per terminare, oppure premete la L all'ultima
modifica da fare (indica LOCALE, ossia ULTIMO CAMBIAMENTO DA FARE).

Una volta fatta questa modifica, eseguite il listato: noterete che la barretta
e le altre "sfumature" hanno una scalettatura verso il centro. Questo e'
proprio perche' cambiamo colore nel mezzo ($87) anziche' all'inizio del video.

Provate ora a ricambiare tutto: fate il REPLACE, dando come stringa originale
"87,$ff" e come stringa nuova "$67,$ff". Noterete che la scalettatura e' piu'
a destra. Per finire, fate un altro effetto: ora avete tutti i wait cambiati
in $xx67,$fffe, ebbene, provate a cambiarli in $xx69,$fffe, ma uno si e uno
no, ossia, immettete alla domanda del replace come prima stringa "67,$ff" e
come seconda "69,$ff", dopodiche' premete una volta Y, quella dopo N, quella
dopo Y e cosi' via, uno Y e uno N.
In questo modo una volta il colore cambiera' alla linea $67 e l'altra a $69,
creando un effetto simile all'incastro dei mattoncini, provate ad eseguirlo.

L'incastro sara' simile a questo:

	ooooooo+++++
	oooo++++++++
	oooooo++++++
	oooo++++++++
	oooooo++++++

