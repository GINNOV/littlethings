
; Lezione5b.s	SCORRIMENTO DI UNA FIGURA A DESTRA E SINISTRA COL $dff102

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

;

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.s	MuoviCopper	; fa scorrere col $dff102 la figura a destra
				; e a sinistra (massimo 16 pixel), qua
				; la scritta COMMODORE

	btst	#2,$dff016	; se il tasto destro e' premuto salta
	beq.s	Aspetta		; la routine dello scroll, bloccandolo

	bsr.w	MuoviCopper2	; fa scorrere col $dff102 la figura a destra
				; e a sinistra (massimo 16 pixel), qua la
				; scritta AMIGA

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta!

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

;	Questa routine sposta la scritta "COMMODORE", agendo su MIOCON1

MuoviCopper:
	TST.B	FLAG		; Dobbiamo avanzare o indietreggiare? se
				; FLAG e' azzerata, (cioe' il TST verifica il
				; BEQ)
				; allora saltiamo a AVANTI, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo indietreggiando (con dei sub)
	beq.w	AVANTI
	cmpi.b	#$00,MIOCON1	; siamo arrivati alla posizione normale, ossia
				; tutto indietro?
	beq.s	MettiAvanti	; se si, dobbiamo avanzare!
	sub.b	#$11,MIOCON1	; sottraiamo 1 allo scroll dei bitplanes
	rts			; dispari ($ff,$ee,$dd,$cc,$bb,$aa,$99....)

MettiAvanti:
	clr.b	FLAG		; Azzerando FLAG, al TST.B FLAG il BEQ
	rts			; fara' saltare alla routine AVANTI, e
				; la figura avanzera' (verso destra)

AVANTI:
	cmpi.b	#$ff,MIOCON1	; siamo arrivati allo scroll massimo in
				; avanti, ossia $FF? ($f pari e $f dispari)
	beq.s	MettiIndietro	; se si, siamo dobbiamo tornare indietro
	add.b	#$11,MIOCON1	; aggiungiamo 1 allo scroll dei bitplanes
				; pari e dispari ($11,$22,$33,$44 etc..)
	rts

MettiIndietro:
	move.b	#$ff,FLAG	; Quando la label FLAG non e' a zero,
	rts			; significa che dobbiamo indietreggiare
				; verso sinistra

;	Questo byte e' un FLAG, ossia serve per indicare se andare avanti o
;	indietro.

FLAG:
	dc.b	0,0

;************************************************************************

;	Questa routine sposta la scritta "AMIGA", agendo su MIACON1

MuoviCopper2:
	TST.B	FLAG2		; Dobbiamo avanzare o indietreggiare?
	beq.w	AVANTI2
	cmpi.b	#$00,MIACON1	; siamo arrivati alla posizione normale?
	beq.s	MettiAvanti2	; se si, dobbiamo avanzare!
	sub.b	#$11,MIACON1	; sottraiamo 1 allo scroll dei bitplanes
	rts			; ($ff,$ee,$dd,$cc,$bb,$aa,$99....)

MettiAvanti2:
	clr.b	FLAG2		; Azzerando FLAG, al TST.B FLAG il BEQ
	rts			; fara' saltare alla routine AVANTI

AVANTI2:
	cmpi.b	#$ff,MIACON1	; siamo arrivati allo scroll massimo in
				; avanti, ossia $FF? ($f pari e $f dispari)
	beq.s	MettiIndietro2	; se si, siamo dobbiamo tornare indietro
	add.b	#$11,MIACON1	; aggiungiamo 1 allo scroll dei bitplanes
				; pari e dispari ($11,$22,$33,$44 etc..)
	rts

MettiIndietro2:
	move.b	#$ff,FLAG2	; Quando la label FLAG non e' a zero,
	rts			; significa che dobbiamo indietreggiare.

Finito2:
	rts

;	Questo byte e' un FLAG, ossia serve per indicare se andare avanti o
;	indietro.

FLAG2:
	dc.b	0,0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!

	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210	; BPLCON0:
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane - BPL2PT

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$7007,$fffe	; Aspettiamo fino sotto la scritta "COMMODORE"

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIACON1:
	dc.b	$ff		; BplCon1 - IL BYTE UTILIZZATO!!!


	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Questo esempio e' stato ottenuto copiando la routine Muovicopper, e cambiando
le sue label aggiungendoci un 2 per "cambiargli nome", per non riscriverla
tutta. Spesso per aggiungere routines simili si ricorre alla copia del pezzo
interessato con Amiga+b+c+i, poi si cambia il nome alle label. Per quanto
riguarda la copperlist e' bastato aggiungere un'altro $dff102, il cui nome
e' MIACON1, dopo un WAIT $7007, ossia sotto la scritta commodore, per cui
agisce sulla parte sottostante di figura, che e' il disegno "AMIGA".
Per creare la "DISCORDANZA" di movimento, per cui una parte va a destra
quando l'altra va a sinistra e viceversa, e' bastato far partire il loop
da $FF anziche' da $00, ossia dalla posizione 15, per cui i due cicli
Muovicopper e Muovicopper2 proseguino dalle 2 posizioni opposte.

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!

	...

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIACON1:
	dc.b	$ff		; BplCon1 - IL BYTE UTILIZZATO!!!

Provate a cambiare il byte MIACON1:, anziche' $ff provate con $55 e $aa o altri
valori, e risultera' piu' chiaro.

Col tasto destro del mouse si blocca solo il secondo $102.
Provate a cambiare il Wait per far avvenire la differenza di scroll in altre
posizioni, ad esempio:


	dc.w	$a007,$fffe

Fa "dividere" la figura nel mezzo della scritta "AMIGA".

