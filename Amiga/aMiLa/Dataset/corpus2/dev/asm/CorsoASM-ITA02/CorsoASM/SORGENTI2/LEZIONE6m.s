
; Lezione6m.s	EFFETTO "RIMBALZO" TRAMITE L'USO DI UNA TABELLA


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo la PIC

	MOVE.L	#PIC,d0		; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane
	addq.w	#8,a1
	dbra	d1,POINTBP

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.w	Rimbalzo	; Fa "rimbalzare" la PIC tramite una tabella
				; gia' predisposta.

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

; Questa volta usiamo una tabella che contiene i valori da sottrarre ai
; puntatori dei bitplanes per simulare un "rimbalzo" della figura, anziche' un
; ovvio movimento SU-GIU con add.l #40 e sub.l #40. Per fare cio' e' bastato
; fare una tabella, appunto, con i valori da sottrarre al puntatore, che
; chiaramente sono multipli del 40, dove 2*40 indica che si saltano 2 linee,
; mentre 3*40 che se ne saltano 3 alla volta:
;
;	dc.l	40,40,2*40,2*40	; esempio...
;
; Per tornare alla posizione iniziale una volta arrivati in fondo allo schermo
; occorre aggiungere quanto e' stato tolto ai puntatori bitplanes, dunque,
; essendo presente nella routine una sottrazione:
;
;	sub.l	d1,d0	; sottrai il valore della tabella (d1) all'indirizzo
;			; che sta puntando il bplpointer
;
; come facciamo ad AGGIUNGERE con un SUB?? Semplice! Basta SOTTRARRE numeri
; negativi!!! Quanto fa 10-(-1)? Fa 11!!! Dunque nella tabella sono presenti
; i numeri negativi dopo aver toccato "il fondo":
;
;	dc.l	-8*40,-6*40,-5*40		; risaliamo
;
; un sub.l #-8*40 e' come un add.l #8*40.
; Ricordate pero' che i numeri negativi tengono "il segno" sul bit piu' alto?
; per cui un -40 e' $FFFFFFd8, e' per questo che i valori della tabella sono
; in LONGWORD e non in WORD, per contenere numeri negativi.
; Infatti un:
;
; dc.w -40
;
; Non viene assemblato, da errore, dovete usare .l per i numeri negativi.
;
; Avendo usato i valori .L, bisogna ricordarselo nella routine:
;
; ADDQ.L #4,RIMTABPOINT
; FINERIMBALZTAB-4
; dc.l RIMBALZTAB-4
;
; e non
;
; ADDQ.L #2,RIMTABPOINT
; FINERIMBALZTAB-2
; dc.l RIMBALZTAB-2
;
; Per quanto riguarda lo spostamento vero e proprio non ci sono novita':
; preleviamo l'indirizzo da BPLPOINTERS, facciamo il SUB con il valore letto
; in tabella e ripuntiamo il nuovo indirizzo.

Rimbalzo:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poiniamo in d0
	move.w	6(a1),d0

	ADDQ.L	#4,RIMTABPOINT	; Fai puntare alla longword successiva
	MOVE.L	RIMTABPOINT(PC),A0 ; indirizzo contenuto in long RIMTABPOINT
				   ; copiato in a0
	CMP.L	#FINERIMBALZTAB-4,A0 ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTART2		; non ancora? allora continua
	MOVE.L	#RIMBALZTAB-4,RIMTABPOINT ; Riparti a puntare dalla prima long
NOBSTART2:
	MOVE.l	(A0),d1		; copia la long dalla tabella in d1

	sub.l	d1,d0		; sottraiamo il valore attualmente preso dalla
				; tabella, facendo scorrere la figura SU o GIU.

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


RIMTABPOINT:			; Questa longword "PUNTA" a RIMBALZTAB, ossia
	dc.l	RIMBALZTAB-4	; contiene l'indirizzo di RIMBALZTAB. Terra'
				; l'indirizzo del'ultima long "letta" dentro
				; la tabella. (qua inizia da RIMORTAB-4 in
				; quanto Lampeggio inizia con un ADDQ.L #4,C..
				; serve per "bilanciare" la prima istruzione.

;	La tabella con i valori "precalcolati" del rimbalzo

RIMBALZTAB:
	dc.l	0,0,0,0,0,0,40,40,40,40,40,40,40,40,40 		; scendiamo
	dc.l	40,40,2*40,2*40
	dc.l	2*40,2*40,2*40,2*40,2*40
	dc.l	3*40,3*40,3*40,3*40,3*40,4*40,4*40,4*40,5*40,5*40
	dc.l	6*40,8*40					; in fondo
	dc.l	-8*40,-6*40,-5*40				; risaliamo
	dc.l	-5*40,-4*40,-4*40,-4*40,-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40
	dc.l	-2*40,-2*40,-40,-40
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40,0,0,0,0,0	; siamo in cima
FINERIMBALZTAB:


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist


	dcb.b	80*40,0	; spazio azzerato per lo scroll del bitplane

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,

	end

Programmare una demo o un gioco significa anche fare una miriade di tabelle.
Quella usata in questo listato potrebbe esser utile per il salto di un ometto
protagonista di un platform; i giochi programmati male e con linguaggi non
adatti spesso difettano piu' del fatto che i movimenti non sono naturali che
della lentezza o altro. Immaginatevi che il protagonista di un platform salti
in alto con un add e improvvisamente arrivato in alto scenda con un sub.
L'effetto sarebbe terribilmente brutto. Anche i movimenti ondeggianti degli
alieni di uno sparatutto contano molto, e sono il frutto di tabelle.
Complicando le cose i programmatori bravucci si fanno un certo numero di
tabelle tutte per il salto del personaggio, e a seconda del movimento di
questo o del tempo di pressione del pulsante fanno fare la curva di salto
giusta secondo la tabella giusta, oppure aggiungono dei valori a quelli della
tabella base, o mischiano i valori di molte tabelle. In casi estremi come
i giochi di flipper bisogna proprio farsi una routine che calcola i rimbalzi e
la gravita', ma questo non esclude che la routine abbia tabelle al suo interno;
comunque in un gioco di flipper si muove solo la pallina (lo schermo del
flipper basta muoverlo cambiando i puntatori dei bitplanes) e si puo' perdere
tempo a calcolarsi il movimento, in un altro tipo di gioco si usano le tabelle.
Imparate ad usare la routine che legge i valori dalla tabella e usatela per
modificare esempi precedenti, per far muovere, ad esempio, le barrette copper
in modo strano e oscillante.

Provate a sostituire la tabella con questa: provoca una "fluttuazione"
oscillatoria anziche' un rimbalzo. (usate Amiga+b+c+i)


RIMBALZTAB:
	dc.l	0,0,40,40,40,40,40,40,40,40,40 			; in cima
	dc.l	40,40,2*40,2*40
	dc.l	2*40,2*40,2*40,2*40,2*40			; acceleriamo
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	2*40,2*40,2*40,2*40,2*40			; deceleriamo
	dc.l	2*40,2*40,40,40
	dc.l	40,40,40,40,40,40,40,40,40,0,0,0,0,0,0,0	; in fondo
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40
	dc.l	-40,-40,-2*40,-2*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40			; acceleriamo
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40			; deceleriamo
	dc.l	-2*40,-2*40,-40,-40
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40,0,0,0,0,0	; in cima
FINERIMBALZTAB:


