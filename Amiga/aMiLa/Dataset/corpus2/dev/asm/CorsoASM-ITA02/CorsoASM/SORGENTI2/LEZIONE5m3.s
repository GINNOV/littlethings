
; Lezione5m3.s	"CHIUSURA" DELLA FINESTRA VIDEO CON I DIWSTART/STOP ($8e/$90)

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

	btst	#2,$dff016	; se il tasto destro e' premuto salta
	beq.s	Aspetta		; la routine dello scroll, bloccandolo

	bsr.w	DIWVERTICALE	; mostra la funzione dei DIWSTART e DIWSTOP

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

; Questa routine porta a $95 DIWYSTART incrementandolo di uno ogni volta e
; a $95 DIWYSTOP decrementandolo di uno ogni volta. Quando entrambi i valori
; sono raggiunti la routine esce senza modificare niente
; Da notare che il DIWSTIO qua parte da $fe e non da $ff+$2c come al solito.

DIWVERTICALE:
	CMPI.B	#$95,DIWYSTOP	; Siamo arrivati al DIWSTOP giusto?
	BEQ.S	FINITO		; se si, non dobbiamo procedere oltre
	ADDQ.B	#1,DIWYSTART	; aggiungiamo 1 allo start
	SUBQ.B	#1,DIWYSTOP	; sottraiamo 1 allo stop
FINITO:
	RTS			; Uscita dalla routine


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E		; DIWSTART - Inizio finestra video
DIWYSTART:
	dc.b	$2c		; DIWSTRT $YY
	dc.b	$81		; DIWSTRT $XX (lo incrementiamo fino a $ff)

	dc.w	$90		; DIWSTOP - Fine finestra video
DIWYSTOP:
	dc.b	$fe		; DiwStop YY (partiamo dalla linea $fe!!)
	dc.b	$c1		; DiwStop XX (lo caliamo fino a $00)
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
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

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Questo listato mostra come si possa diminuire la grandezza della finestra
video in senso verticale: se per esempio visualizzassimo solo delle figure
nella parte alta dello schermo, potremmo restringere la finestra, "tagliando"
la parte sotto una certa linea; il byte YY del diwstart/stop e' uguale a quello
del WAIT: un wait $2c07,$fffe aspetta la prima linea bitplane visualizzata,
infatti il DIWSTART e' $2c81. Giunto alla linea $FF, il DIWSTOP riparte da
ZERO: dunque aspettando col diwstop la posizione $2cc1, aspetta la linea
$ff+$2c, ossia 299, ma le linee effettiviamente usate per visualizzare i
bitplane sono 256: dalla $2c (44) alla 299.
In questo esempio influisce anche il fatto che la figura si sposta in basso
assieme all'inizio della visualizzazione della finestra video.
Per vedere meglio cosa succede sul video, sostituite 3 bitplanes "pieni" ossia
con tutti i bit ad 1:

PIC:
	dcb.b	40*256*3,$FF

