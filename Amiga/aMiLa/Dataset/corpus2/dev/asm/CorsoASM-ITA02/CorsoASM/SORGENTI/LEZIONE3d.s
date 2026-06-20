
; Lezione3d.s	BARRETTA CHE SALE E SCENDE FATTA COL MOVE&WAIT DEL COPPER

;	In questo listato viene usata una label come FLAG, ossia come
;	segnalazione per indicare se la barretta deve andare in alto
;	o in basso. Analizzate attentamente come funziona questo
;	programma, e' il primo del corso che puo' presentare problemi
;	a livello di ciclo condizionato.


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
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.s	MuoviCopper	; Una routine che fa scendere e salire la barra

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

;
;
;
;


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
	cmpi.b	#$fc,8*9(a0)	; siamo arrivati alla linea $fc?
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


;	Questo byte, indicato dalla label SuGiu, e' un FLAG, ossia una
;	bandierina (in gergo), infatti una volta e'a  $ff e un'altra e' a
;	$00, a seconda della direzione da seguire (su o giu'!). E' appunto
;	come una bandierina, che quando e' abbassata ($00) indica che dobbiamo
;	scendere e quando e' alzata ($FF) dobbiamo salire. Viene infatti
;	eseguita una comparazione della linea raggiunta per verificare se
;	siamo arrivati in cima o in fondo, e se ci siamo arrivati cambiamo
;	la direzione (con clr.b SuGiu o move.b #$ff,Sugiu)

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

Ora la barra se ne va su e giu', tramite l'utilizzo di una label che segna
se stiamo salendo o scendendo: se la label SuGiu e' azzerata vengono eseguite
le istruzioni che fanno scendere la barra, se invece non e' a zero vengono
eseguite le istruzioni che la fanno risalire. All'inizio la label e' a zero,
quindi vengono eseguiti gli ADDQ che la fanno scendere, fino a che, una
volta raggiunto il fondo, la label SuGiu viene scritta con un $FF, quindi
nei cicli seguenti, quando viene fatto il TST.b SuGiu, viene eseguita invece la
serie di SUBQ che la fanno risalire, fino a che non arriva in cima, a quel
punto la label SuGiu viene nuovamente azzerata, quindi vengono eseguiti
nuovamente gli ADDQ che la fanno scendere, eccetera.
Con questa routine si possono verificare bene gli effetti delle modifiche:
Provate a mettere un ; alle istruzioni che aspettano la linea $FF col $dff006:

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR
;	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.s	MuoviCopper

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR
;	beq.s	Aspetta	


In questo modo perdiamo la sincronizzazione col video, e la barretta va
all'impazzata, provate ad eseguirlo cosi'!!! Come avrete notato, non si
fa nemmeno in tempo a vedere il suo movimento! Specialmente se avete un
Amiga 1200 o comunque un computer piu' veloce.
Ora invece faremo andare piu' piano la barretta eseguendola 1 volta ogni
2 fotogrammi anziche' 1 volta per fotogramma: fate questa modifica:
(Togliete anche il loop "Aspetta:")

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
;	bne.s	mouse		; Se non ancora, non andare avanti

frame:
	cmpi.b	#$fe,$dff006	; Siamo alla linea 254? (deve rifare il giro!)
	bne.s	frame		; Se non ancora, non andare avanti

	bsr.s	MuoviCopper

;Aspetta:	; tolto, non c'e' piu' rischio...
;	cmpi.b	#$ff,$dff006
;	beq.s	Aspetta	

In questo caso vengono persi 2 fotogrammi di tempo, infatti quando il pennello
elettronico arriva alla linea $ff, ossia 255, viene passato il primo loop,
e si entra nel loop frame:, che attende che arrivi alla linea 254!!!! per
arrivarci pero' deve arrivare in fondo, ripartire da capo e arrivare a 254,
quindi in totale si aspettano 2 fotogrammi, ossia 2 spennellate complete.
Infatti eseguendo il listato cosi' modificato si nota che la velocita' e'
dimezzata. Per farlo andare ancora piu' piano, si possono perdere 3 fotogrammi:

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti
frame:
	cmpi.b	#$fe,$dff006	; Siamo alla linea 254? (deve rifare il giro!)
	bne.s	frame		; Se non ancora, non andare avanti
frame2:
	cmpi.b	#$fd,$dff006	; Siamo alla linea 253? (deve rifare il giro!)
	bne.s	frame2		; Se non ancora, non andare avanti
	bsr.s	MuoviCopper
	...

Con lo stesso metodo, questa volta arrivati alla linea 254 gli chiediamo
di arrivare alla linea 253, il che costa un altro intero fotogramma.

Per verificare a che linea siete arrivati, quando uscite premendo il MOUSE
provate a fare "M BARRA", e vedrete l'ultimo valore che aveva il WAIT.

