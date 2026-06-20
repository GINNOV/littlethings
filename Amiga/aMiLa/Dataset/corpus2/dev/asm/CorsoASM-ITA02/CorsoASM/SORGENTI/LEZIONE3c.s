
; Lezione3c.s	; BARRETTA CHE SCENDE FATTA CON MOVE&WAIT DEL COPPER
		; (PER FARLA SCENDERE USATE IL TASTO DESTRO DEL MOUSE)

	SECTION	SECONDCOP,CODE	; anche in Fast va bene

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

	bsr.s	MuoviCopper	; Il primo movimento sullo schermo!!!!!
				; Questa subroutine fa scendere il WAIT!
				; e viene eseguita 1 volta ogni schermata video
				; infatti bsr.s Muovicopper fa si che venga
				; eseguita la routine nominata Muovicopper,
				; al termine della quale, con RTS, il 68000
				; torna qua ad eseguire la routine Aspetta,
				; e cosi' via.


Aspetta:			; se siamo sempre alla linea $ff che abbiamo
				; aspettato prima, non andare avanti.

	cmpi.b	#$ff,$dff006	; siamo a $FF ancora? se si, aspetta la linea
	beq.s	Aspetta		; seguente ($00), altrimenti MuoviCopper viene
				; rieseguito. Questo problema c'e' solo per
				; le routine molto corte che possono essere
				; eseguite in meno di "una linea del pennello
				; elettronico", detta "linea raster": il
				; ciclo mouse: aspetta la linea $FF, dopodiche'
				; esegue MuoviCopper, ma se la esegue troppo
				; in fretta ci troviamo sempre alla linea $FF
				; e quando torniamo al mouse, alla linea $FF
				; ci siamo gia', e riesegue Muovicopper,
				; dunque la routine e' eseguita piu' di una
				; volta al FRAME!!! Specialmente su A4000!
				; questo controllo evita il problema aspettando
				; la linea dopo, per cui tornando al mouse:
				; per raggiungere la linea $ff e' necessario
				; il classico cinquantesimo di secondo.
				; NOTA: Tutti i monitor e i televisori
				; disegnano lo schermo alla stessa velocita',
				; mentre da computer a computer puo' variare
				; la velocita' del processore. E' per questo
				; che un programma temporizzato col $dff006
				; va alla stessa velocita' su un A500 e su
				; un A4000. La temporizzazione verra'
				; affrontata meglio in seguito, per ora
				; preoccupatevi di capire il copper e il
				; funzionamento.


	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (le librerie vanno aperte e chiuse !!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts

;
;	Questa piccola routine fa scendere il wait del copper aumentandolo,
;	infatti la prima volta che sara' eseguito cambiera' il
;
;	dc.w	$2007,$FFFE	; aspetto la linea $20
;
;	in:
;
;	dc.w	$2107,$FFFE	; aspetto la linea $21! (poi $22,$23 ecc.)
;
;	NOTA: una volta raggiunto il valore massimo per un byte, ossia $FF,
;	      se si esegue un ulteriore ADDQ.B #1,BARRA si riparte da 0,
;             fino a ritornare a $ff e cosi' via.

Muovicopper:
	addq.b	#1,BARRA	; WAIT 1 cambiato, la barra scende di 1 linea
	rts

; Provate a modificare questo ADDQ in SUBQ e la barretta salira'!!!!

; Provate a cambiare l'addq/subq #1,BARRA in #2 , #3 o piu' e la velocita'
; aumentera', dato che ogni FRAME il wait si spostera' di 2,3 o piu' linee.
; (se il numero e' maggiore di 8 invece di ADDQ.B bisogna usare ADD.B)


;	DATI...


GfxName:
	dc.b	"graphics.library",0,0	; NOTA: per mettere in memoria
					; dei caratteri usare sempre il dc.b
					; e metterli tra "", oppure ''

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0


;	DATI GRAFICI...


	SECTION	GRAPHIC,DATA_C	; Questo comando fa caricare dal sistema
				; operativo questo segmento di dati
				; in CHIP RAM, obbligatoriamente
				; Le copperlist DEVONO essere in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, solo sfondo.

	dc.w	$180,$004	; COLOR0 - Inizio la cop col colore BLU SCURO

BARRA:
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79

	dc.w	$180,$600	; COLOR0 - inizio la zona rossa: rosso a 6

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end


Ahh! Mi ero dimenticato di mettere il (PC) a "lea GfxName,a1", ma ora c'e'.
Chi si era accorto che ci si poteva mettere ha preso una nota positiva.
In questo programma viene eseguito un movimento sincronizzato con il
pennello elettronico, infatti la barra scende fluidamente.

NOTA1: In questo listato puo' confondere la struttura del ciclo con il test
del mouse piu' il test della posizione del pennello elettronico; quello
che dovete aver chiaro e' che le routines, o subroutines che si trovano tra
il loop mouse: e quello aspetta: sono eseguite 1 volta ogni fotogramma video:
provate infatti a sostituire il bsr.s Muovicopper con la subroutine stessa,
senza l'RTS finale ovviamente:

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

;	bsr.s	MuoviCopper	; Una routine eseguita ogni fotogramma
;				; (Per la fluidita')

	addq.b	#1,BARRA	; WAIT 1 cambiato, la barra scende di 1 linea

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR - Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

In questo caso il risultato non cambia perche' anziche' eseguire l'ADDQ come
subroutine la eseguiamo direttamente, e forse in questo caso e' anche piu'
comodo; ma quando le subroutine sono piu' lunghe conviene fare vari BSR per
orientarsi. Per esempio se duplicate i bsr.s Muovicopper la routine sara'
eseguita 2 volte per fotogramma, e raddoppiera' la velocita':

	bsr.s	MuoviCopper	; Una routine eseguita ogni fotogramma
	bsr.s	MuoviCopper	; Una routine eseguita ogni fotogramma

L'utilita' delle subroutine sta proprio nella maggior chiarezza del programma,
immaginatevi se le nostre routines da mettere tra mouse: e aspetta: fossero di
migliaia di linee! il susseguirsi delle cose apparirebbe meno chiaro. Invece
se chiamiamo per nome ogni singola routine il tutto apparira' piu' facile.

*

Per far scendere la barra basta cambiare la COPPERLIST, in particolare
in questo esempio viene cambiato i WAIT, nel suo primo byte, ossia quello
che definisce la linea verticale da attendere:

BARRA:
	dc.w	$2007,$FFFE	; WAIT - aspetto la linea $20
	dc.w	$180,$600	; COLOR0 - inizio la zona rossa: rosso a 6

Mettendo una label a quel byte, si puo' cambiare quel byte agendo sulla
label stessa, in questo caso BARRA.

MODIFICHE:
Provate a cambiare il colore anziche' il wait: basta mettere una label
dove volete nella copperlist e potete cambiare quello che vi pare.
Mettete barra al colore in questo modo:

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, solo sfondo.

	dc.w	$180,$004	; COLOR0 - Inizio la cop col colore BLU SCURO

;;;;BARRA:			; ** ANNULLO LA LABEL VECCHIA coi ;;
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79

	dc.w	$180		; COLOR0
BARRA:				; ** METTO LA LABEL NUOVA AL VALORE DEL COLORE.
	dc.w	$600	; inizio la zona rossa: rosso a 6

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

Otterrete una variazione dell'intensita' del rosso, infatti cambiamo il
primo byte a sinistra del colore: $0RGB, ossia il $0R, ossia il ROSSO!!!!

Provate ora ad agire sull'intera WORD del colore: cambiate la routine cosi':

	addq.w	#1,BARRA	; invece di .b operiamo sulla .w
	rts

Provatelo e verificherete che i colori si susseguono irregolarmente, infatti
sono il frutto del numero che aumenta: $601,$602... $631,$632... generando
dei colori non ordinatamente.

NOTA:	il comando dc.w mette in memoria dei bytes, delle word o delle long,
	dunque si puo' ottenere lo stesso risultato scrivendo:

	dc.w	$180,$600	; Color0

	oppure:

	dc.w	$180	; Registro Color0
	dc.w	$600	; valore del color0

	Non ci sono problemi di sintassi come con i MOVE.

