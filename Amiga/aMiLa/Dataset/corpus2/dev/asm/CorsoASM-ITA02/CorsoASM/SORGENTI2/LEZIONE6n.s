
; Lezione6n.s	SCROLLING ORIZZONTALE MAGGIORE DI 16 PIXEL, usando il BPLCON1
;		e i BITPLANE POINTERS - TASTO DESTRO PER MUOVERE A SINISTRA

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

	btst	#2,$dff016	; Tasto destro premuto?
	beq.s	VaiSinistra	; se si, vai a sinistra!

	bsr.w	Destra		; Fa avanzare la pic verso destra modificando
				; il bplcon1 e i bitplane pointers
	bra.s	Aspetta

VaiSinistra:
	bsr.w	Sinistra	; Fa indietreggiare la pic verso sinistra.

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

; Questa routine fa scorrere a destra un bitplane agendo sul BPLCON1 e sui
; puntatori ai bitplanes in copperlist. MIOBPCON1 e' il byte del BPLCON1.

Destra:
	CMP.B	#$ff,MIOBPCON1	; siamo arrivati al massimo scorrimento? (15)
	BNE.s	CON1ADDA	; se non ancora, scorri in avanti di 1
				; con il BPLCON1

	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poiniamo in d0
	move.w	6(a1),d0

	subq.l	#2,d0		; punta 16 bit piu' indietro ( la PIC scorre
				; verso destra di 16 pixel)
	clr.b	MIOBPCON1	; azzera lo scroll hardware BPLCON1 ($dff102)
				; infatti abbiamo "saltato" 16 pixel con il
				; bitplane pointer, ora dobbiamo ricominciare
				; da zero con il $dff102 per scattare a
				; destra di un pixel alla volta.

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

CON1ADDA:
	add.b	#$11,MIOBPCON1	; scorri in avanti di 1 pixel
	rts

;	Routine che sposta a sinistra in modo analogo:

Sinistra:
	TST.B	MIOBPCON1	; siamo arrivati al minimo scorrimento? (00)
	BNE.s	CON1SUBBA	; se non ancora, scorri indietro di 1
				; con il BPLCON1

	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poiniamo in d0
	move.w	6(a1),d0

	addq.l	#2,d0		; punta 16 bit piu' avanti ( la PIC scorre
				; verso sinistra di 16 pixel)
	move.b	#$FF,MIOBPCON1	; scroll hardware a 15 - BPLCON1 ($dff102)

	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP3:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP3	; Rifai D1 volte POINTBP (D1=num of bitplanes)
	rts

CON1SUBBA:
	sub.b	#$11,MIOBPCON1	; scorri indietro di 1 pixe
	rts


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
	dc.w	$102		; BplCon1
	dc.b	0		; byte "alto" inutilizzato del $dff102
MIOBPCON1:
	dc.b	0		; byte "basso" utilizzato del $dff102
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

	dcb.b	40,0

	end

Orribile l'errore scattoso di visualizzazione al bordo sinistro dello schermo,
eh?? Toglierlo non e' difficile, basta cambiare due cosucce, vediamo come e
perche': il perche' avviene questo inconveniente e' da ricercare nel fatto che
spostando la figura senza informare i canali DMA li troviamo "impreparati" e
non fanno in tempo a leggere bene i primi 16 pixel a sinistra.
Per evitare questo cosa possiamo fare? Nulla.
Pero' possiamo far avvenire il pasticcio fuori dallo "schermo visibile", vi
ricordate il DIWSTART e il DIWSTOP? Determinano la grandezza della finestra
dove sono visualizzati i dati. E' chiaro che se facciamo partire la finestra
16 pixel piu' a destra il problema viene "tappato":

	dc.w	$8E,$2c91	; DiwStrt ($81+16=$91)

Provate a cambiare il valore ed eseguite nuovamente il listato. Anche se
abbiamo "tappato" l'errore pero' ora abbiamo uno schemo largo 304 pixel
anziche' 320 e anche decentrato!!
Ma in nostro aiuto vengono i registri DDFSTART e DDFSTOP! Questi registri
si occupano anche loro della grandezza della finestra video, ma in maniera
diversa, infatti mentre il DIWSTART/DIWSTOP e' come un cartoncino nero con
una fessura ridimensionabile come vediamo nella figura sotto,

	#####################
	#####################
	#####		#####
	#####	figura  #####
	#####		#####
	#####		#####
	#####		#####
	#####		#####
	#####		#####
	#####################
	#####################

se cambiamo il DDFSTART/STOP cambiamo proprio la lunghezza di una linea video,
per esempio se allunghiamo lo schermo di 16 pixel, facendolo diventare di
336 pixel per linea, ossia 42 bytes anziche' 40, dovremo visualizzarci una
figura larga proprio 42 pixel per linea.
Il modo OVERSCAN, che allarga la figura visualizzabile oltre i normali 320x256
o 640x256, viene ottenuto con i DDFSTART/STOP, ricordandosi ovviamente di
"allargare" anche la finestra con DIWSTART/DISTOP.
torniamo al problema: noi dobbiamo fare in modo che quell'errore largo 16 pixel
avvenga fuori dalla nostra vista. Basta far cominciare lo schermo col DDFSTART
16 pixel prima, facendoolo finire alla stessa posizione, e lasciare i valori
normali di DIWSTART/DIWSTOP, per cui vediamo sempre 320x256 pixel, ma la
finestra video e' larga in realta' 336 pixel e l'errore sta avvenendo fuori
dalla nostra vista. La figura pero' diventa larga 42 bytes, dunque dobbiamo
bilanciare quei 2 bytes (16 pixel) ogni linea. Come facciamo ogni termine linea
(che ora avviene al pixel 42) a tornare indietro di 2 per visualizzare la
linea correttamente? Insomma per far tornare i conti? Basta sottrarre al modulo
corrente 2. Nel nostro caso, col modulo a ZERO, basta mettere -2.
Per far partire lo schermo 16 pixel prima occorre modificare in questo modo
il DATA FETCH START (DDFSTRT):

	dc.w	$92,$30			; DDFSTART = $30 (schermo che parte
					; 16 pixel prima, allungandosi a
					; 42 bytes per linea, 336 pixel di
					; larghezza, ma il DIWSTART "nasconde"
					; questi primi 16 pixel con l'errore.


	dc.w	$108,-2			; MODULI = -2, dobbiamo "saltare" i
	dc.w	$10a,-2			; primi 16 pixel di ogni linea
					; facendoli leggere 2 volte.


Fate questa modifica e rimettete a posto il DIWSTART:

	dc.w	$8E,$2c81	; DiwStrt

Ora lo scroll e' PERFETTO. C'e' solo il particolare che aumentando tramite
l'OVERSCAN le dimensioni della finestra video viene annullato lo sprite 7,
ossia l'ultimo sprite.

P.S: Se volete dare una sbirciatina all'errore che continua ad esistere in
OVERSCAN fuori dalla finestra fate iniziare il DIWSTART 16 pixel prima:

	dc.w	$8E,$2c71	; DiwStrt

E' sempre li'!!!! Ma nessuno lo puo' piu' vedere ora.

Avete visto che era facile togliere l'errore? Basta far iniziare prima di 16
pixel il DDFSTART (a $30) e togliere 2 al valore dei moduli.

