
; Lezione5i.s	SCORRIMENTO DI UNA FIGURA IN ALTO E IN BASSO DI TUTTA LA CHIP
;		MEMORY USANDO PUNTATORI AI PITPLANES NELLA COPPERLIST
;		TASTO SINISTRO PER SPOSTARSI IN AVANTI, DESTRO PER SPOSTARSI
;		INDIETRO, ENTRAMBI PER USCIRE.

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	Nota: qua i bitplane li lasciamo puntare a $000000, ossia
;	all' inizio della CHIP MEMORY

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti
Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta!

	btst	#2,$dff016	; se il tasto destro e' premuto
	bne.s	NonGiu		; scorri giu!, oppure vai a NonGiu

	bsr.s	VaiGiu		; tasto destro premuto, scorri giu!

Nongiu:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	beq.s	Scorrisu	; se si, scorri in su
	bra.s	mouse		; no? allora ripeti il ciclo il prossimo FRAME

Scorrisu:
	bsr.w	VaiSu		; fa scorrere la figura in alto

	btst	#2,$dff016	; se anche il tasto destro e' premuto allora
	bne.s	mouse		; sono premuti entrambi, esci, oppure "MOUSE"

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


;	Questa routine sposta la figura in alto e in basso, agendo sui
;	puntatori ai bitplanes in copperlist (tramite la label BPLPOINTERS)

VAIGIU:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poniamo
	move.w	6(a1),d0	; in d0 - il contrario della routine che
	sub.l	#80*3,d0	; sottraiamo 80*3, ossia 3 linee, facendo
				; scorrere in BASSO la figura
	bra.s	Finito


VAISU:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poniamo
	move.w	6(a1),d0	; in d0 - il contrario della routine che
	add.l	#80*3,d0	; Aggiungiamo 80*3, ossia 3 linee, facendo
				; scorrere in ALTO la figura
	bra.w	finito


Finito:				; PUNTIAMO I PUNTATORI BITPLANES
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	rts


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$003c	; DdfStart HIRES normale
	dc.w	$94,$00d4	; DdfStop HIRES normale
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%1001001000000000	; bits 12/15 accesi!! 1 bitplane
					; hires 640x256, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$2ae	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

Con questo programmino potete vedere il contenuto della vostra CHIP RAM,
infatti viene visualizzato 1 bitplane in hires, che punta all'indirizzo $00000
ossia all'inizio della CHIP RAM dell'Amiga. Premendo il tasto sinistro del
mouse potete incrementare l'indirizzo visualizzato, scorrendo tutta la memoria,
in cui noterete lo schermo del wordbench, quello dell'ASMONE, nonche' evetuali
figure rimaste in memoria, ad esempio se avete giocato ad un gioco prima di
eseguire questo listato probabilmente troverete gli sfondi e i personaggi del
gioco sempre in memoria, in quanto la memoria non viene cancellata al reset, ma
soltanto spegnendo il cumputer. Col tasto destro potete indietreggiare per
centrare un'immagine che vi interessa; per uscire dovete premere entrambi i
bottoni. provate a fare un'esperimento caricando vari videogiochi, resettando
ed eseguendo questo programmino, per rintracciare in memoria quello che e'
rimasto.
Se volete velocizzare lo scorrimento dovete aumentare il valore aggiunto ai
bitplane, basta che sia un multiplo di 80 (infatti per scorrere di una linea
in HIRES, essendo largo 640 bit per linea anziche' 320, occorre il doppio di
40, che abbiamo fin qua usato per gli schermi in LOWRES).
Nel listato lo schermo scorre di 3 linee alla volta:

	sub.l	#80*3,d0	; sottraiamo 80*3, ossia 3 linee

Per farlo scorrere col TURBO provate con 80*10 o maggiori.
Se per curiosita' volete sapere a che indirizzo sta un bitplane che vedete
sullo schermo, uscite in quel punto e scrivete "M BPLPOINTERS":

XXXXXX 00 E0 00 02 00 E2 10 C0 ... (00 e0 = bplpointerH, 00 e2 l'altro BPLP)

ossia $00E0,$0002,$00E2,$10C0 ......

In questo esempio l'indirizzo e' $0002 10c0, ossia $210c0

