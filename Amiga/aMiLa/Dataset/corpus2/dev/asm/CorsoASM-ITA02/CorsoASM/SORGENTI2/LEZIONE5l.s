
; Lezione5l.s	Effetto "ALLUNGAMENTO" fatto alternando moduli normali e -40

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	Puntiamo i bitplanes in copperlist

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

mouse:
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

; COPPERLIST CHE "ALLUNGA"

	dc.l	$8907fffe		; wait linea $89
	dc.w	$108,-40,$10a,-40	; modulo -40, ripetizione ultima linea
	dc.l	$9007fffe		; aspetto 7 linee -saranno tutte uguali
	dc.w	$108,0,$10a,0		; poi faccio avanzare di una linea
	dc.l	$9107fffe		; e la linea seguente...
	dc.w	$108,-40,$10a,-40	; rimetto il modulo a FLOOD
	dc.l	$9807fffe		; aspetto 7 linee -saranno tutte uguali
	dc.w	$108,0,$10a,0		; faccio avanzare alla linea dopo
	dc.l	$9907fffe		; poi...
	dc.w	$108,-40,$10a,-40	; mi ripeto la linea per 7 linee col
	dc.l	$a007fffe		; modulo a -40
	dc.w	$108,0,$10a,0		; avanzo di una linea... ECCETERA.
	dc.l	$a107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$a807fffe
	dc.w	$108,0,$10a,0
	dc.l	$a907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$b007fffe
	dc.w	$108,0,$10a,0
	dc.l	$b107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$b807fffe
	dc.w	$108,0,$10a,0
	dc.l	$b907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$c007fffe
	dc.w	$108,0,$10a,0
	dc.l	$c107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$c807fffe
	dc.w	$108,0,$10a,0
	dc.l	$c907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$d007fffe
	dc.w	$108,0,$10a,0
	dc.l	$d107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$d807fffe
	dc.w	$108,0,$10a,0
	dc.l	$d907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$e007fffe
	dc.w	$108,0,$10a,0
	dc.l	$e107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$e807fffe
	dc.w	$108,0,$10a,0
	dc.l	$e907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$f007fffe
	dc.w	$108,0,$10a,0	; ritorno alla normalita'

	dc.w	$FFFF,$FFFE	; Fine della copperlist

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Questo e' uno degli altri utilizzi dell'effetto "FLOOD" fatto con i moduli,
infatti e' piuttosto facile "allungare" una figura o simulare dei pixel piu'
lunghi del normale alternando dei moduli -40, che allungano, a dei moduli
normalmente a zero, che fanno scattare la linea seguente, la quale sara' poi
allungata facendola seguire da un altro modulo -40 mantenuto per qualche linea.
In questo esempio l'allungamento e' un *8, infatti la linea viene fatta
avanzare solo una volta ogni 8 pixel, infatti i moduli -40 vengono distanziati
con i wait di 7 linee, e tra questi allungamenti sono poste delle linee a
modulo normale, che dunque fanno scattare alla linea successiva terminata la
visualizzazione, ma la linea seguente c'e' subito un'altro modulo negativo
che fa ripetere la nuova linea per 7 righe, piu' quella con modulo normale che
fa scattare nuovamente la linea nuova quando va "a capo".
Cambiando la distanza tra i wait si possono creare interessanti effetti di
ondulazione in stile "zoom".

