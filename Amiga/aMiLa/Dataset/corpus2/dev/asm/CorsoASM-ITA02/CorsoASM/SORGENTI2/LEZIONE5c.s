
; Lezione5c.s	SCORRIMENTO DI UNA FIGURA IN ALTO E IN BASSO MODIFICANDO I
;		PUNTATORI AI PITPLANES NELLA COPPERLIST

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


	bsr.w	MuoviCopper	; fa scorrere la figura in alto e in basso
				; di una linea alla volta cambiando i
				; puntatori ai bitplanes in copperlist

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


;	Questa routine sposta la figura in alto e in basso, agendo sui
;	puntatori ai bitplanes in copperlist (tramite la label BPLPOINTERS)
;	La struttura e' simile a quella di Lezione3d.s
;	Per prima cosa mettiamo l'indirizzo che stanno puntato i BPLPOINTERS
;	in d0, poi aggiungiamo o sottraiamo 40 a d0, e infine per modificare
;	in copperlist i BPLPOINTERS dobbiamo "ripuntare" il valore cambiato
;	in d0 con la stessa routine POINTBP.

MuoviCopper:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poniamo
	move.w	6(a1),d0	; in d0 - il contrario della routine che
				; punta i bitplanes! Qua invece di mettere
				; l'indirizzo lo prendiamo!!!

	TST.B	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei sub)
	beq.w	VAIGIU
	cmp.l	#PIC-(40*30),d0	; siamo arrivati abbastanza in ALTO?
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	sub.l	#40,d0		; sottraiamo 40, ossia 1 linea, facendo
				; scorrere in BASSO la figura
	bra.s	Finito

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	bra.s	Finito		; fara' saltare alla routine VAIGIU

VAIGIU:
	cmpi.l	#PIC+(40*30),d0	; siamo arrivati abbastanza in BASSO?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	add.l	#40,d0		; Aggiungiamo 40, ossia 1 linea, facendo
				; scorrere in ALTO la figura
	bra.s	finito

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

Finito:				; PUNTIAMO I PUNTATORI BITPLANES
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


;	Questo byte, indicato dalla label SuGiu, e' un FLAG.

SuGiu:
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
	dc.w	$102,0		; BplCon1
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

; Inserite qua il pezzo di copperlist

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

	dcb.b	40*30,0	; questo spazio azzerato serve perche' spostandoci
			; a visualizzare piu' in basso e piu' in alto usciamo
			; dalla zona della PIC e visualizziamo quello che sta
			; prima e dopo la pic stessa, il che' causerebbe
			; la visualizzazione di byte sparsi di disturbo.
			; mettendo dei byte azzerati in quel punto viene
			; visualizzato $0000, ossia il colore di sfondo.

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	dcb.b	40*30,0	; vedi sopra

; NOTA: Il dcb.b serve a mettere molti bytes uguali tra loro in memoria,
; scrivere dcb.b 10,0 e' come scrivere 10 volte dc.b 0.
;

	end

Questa routine in pratica aggiunge o sottrae 40 all'indirizzo a cui puntano i
BPLPOINTERS in copperlist, leggendo per prima cosa l'indirizzo "attuale" con
la routine opposta a quella che punta i bitplanes.
Con questo metodo si possono visualizzare anche immagini piu' grandi dello
schermo, visualizzandone una parte per volta con la possibilita' di scorrerle
in alto o in basso. Ad esempio nei giochi di FLIPPER, come PINBALL DREAMS, lo
schermo di gioco e' piu' lungo di quello visibile, e scorre in alto o in basso,
per visualizzare la parte dove rimbalza la pallina, cambiando i puntatori dei
bitplanes.
In questo esempio spostandoci visualiziamo anche delle linee fuori dalla
nostra figura, in quanto e' lunga 256 linee solamente e noi scorriamo di
30 linee sopra e 30 sotto, ossia 316 linne in totale. E' per questo che sono
presenti dei dcb.b prima e dopo la figura, per "pulire" la zona che appare
scorrendo fuori dai bitplanes RAW. Provate a cambiarli in questo modo:

	dcb.b	40*30,%11001100

Eseguendo il listato noterete che le parti fuori PIC sono a "STRISCE" anziche'
azzerate, infatti le abbiamo riempite di %110011001100110011001100110011
					  110011001100110011001100110011
					  110011001100110011001100110011
Ossia di strisce di bit.

Potete anche scorrere i 3 bitplanes sepatatamente: per fare cio' basta che
abilitiate 1 solo bitplane nel $dff100:

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane

E cambiate la posizione massima raggiungibile dallo scroll:

VAIGIU:
	cmpi.l	#PIC+(40*530),d0; siamo arrivati abbastanza in BASSO?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	...

In questo modo vedrete scorrere i 3 bitplanes separatamente, infatti sono
posti l'uno dopo l'altro.

* Eccovi una modifica da fare alla copperlist: cosa succede se cambiamo tutti
gli 8 colori della figura ogni 2 linee? Copiate (con Amiga+b+c+i) questo pezzo
di copperlist ed inseritelo prima della fine della copperlist:

; Inserite qua il pezzo di copperlist

Cambiando la palette di 8 colori 52 volte, otterrete 8*52= 416 colori cambiati,
ma considerando che il color0, essendo lo sfondo, deve rimanere sempre NERO,
non viene modificato, solo gli altri 7, e non nell'ordine "numerico", ma in
ordine "sparso", infatti l'ordine con cui vengono aggiornati i colori non conta
sul risultato, si puo' cambiare prima il color2,poi il color3 ecc, mentre in
questo esempio "si parte" dal color5 ($dff18a), poi si cambia il color7 ecc.
Cambiando 7 colori 52 volte inserendo questa copperlist otteniamo 364 colori
effettivi sullo schermo contemporaneamente, il che non e' male, considerando
che lo schermo "ufficialmente" visualiziamo solo 8 colori. (7*52=364)


;2
	dc.w $18a,$102,$18e,$212,$182,$223	; color5,color7,color2
	dc.w $18c,$323,$188,$323,$186,$334,$184,$434 ; col6,col4,col3,col2
	dc.w $5007,$fffe
;3
	dc.w $18a,$104,$18e,$214,$182,$225
	dc.w $18c,$324,$188,$324,$186,$335,$184,$435
	dc.w $5207,$fffe
;4
	dc.w $18a,$203,$18e,$313,$182,$324
	dc.w $18c,$423,$188,$423,$186,$434,$184,$534
	dc.w $5407,$fffe
;5
	dc.w $18a,$213,$18e,$313,$182,$324
	dc.w $18c,$433,$188,$433,$186,$434,$184,$534
	dc.w $5607,$fffe
;6
	dc.w $18a,$114,$18e,$214,$182,$224
	dc.w $18c,$323,$188,$323,$186,$334,$184,$434
	dc.w $5807,$fffe
;7
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$322,$186,$333,$184,$433
	dc.w $5a07,$fffe
;8
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $5c07,$fffe
;9
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $5e07,$fffe
;10
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$322,$188,$312,$186,$323,$184,$433
	dc.w $6007,$fffe
;11
	dc.w $18a,$110,$18e,$210,$182,$221
	dc.w $18c,$321,$188,$311,$186,$322,$184,$432
	dc.w $6207,$fffe
;12
	dc.w $18a,$210,$18e,$310,$182,$321
	dc.w $18c,$421,$188,$411,$186,$422,$184,$532
	dc.w $6407,$fffe
;13
	dc.w $18a,$210,$18e,$320,$182,$331
	dc.w $18c,$431,$188,$421,$186,$432,$184,$542
	dc.w $6607,$fffe
;14
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $6807,$fffe
;15
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$440,$188,$430,$186,$441,$184,$551
	dc.w $6a07,$fffe
;16
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $6c07,$fffe
;17
	dc.w $18a,$120,$18e,$230,$182,$331
	dc.w $18c,$341,$188,$331,$186,$342,$184,$452
	dc.w $6e07,$fffe
;18
	dc.w $18a,$120,$18e,$230,$182,$341
	dc.w $18c,$351,$188,$341,$186,$352,$184,$462
	dc.w $7007,$fffe
;19
	dc.w $18a,$121,$18e,$231,$182,$332
	dc.w $18c,$342,$188,$332,$186,$343,$184,$453
	dc.w $7207,$fffe
;20
	dc.w $18a,$021,$18e,$131,$182,$232
	dc.w $18c,$242,$188,$232,$186,$243,$184,$353
	dc.w $7407,$fffe
;21
	dc.w $18a,$022,$18e,$132,$182,$233
	dc.w $18c,$243,$188,$233,$186,$244,$184,$354
	dc.w $7607,$fffe
;22
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
	dc.w $7807,$fffe
;23
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $7a07,$fffe
;24
	dc.w $18a,$013,$18e,$023,$182,$124
	dc.w $18c,$134,$188,$124,$186,$135,$184,$245
	dc.w $7c07,$fffe
;25
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $7e07,$fffe
;26
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
	dc.w $8007,$fffe
;27
	dc.w $18a,$022,$18e,$132,$182,$233
	dc.w $18c,$243,$188,$233,$186,$244,$184,$354
	dc.w $8207,$fffe
;28
	dc.w $18a,$112,$18e,$132,$182,$233
	dc.w $18c,$233,$188,$233,$186,$244,$184,$344
	dc.w $8407,$fffe
;29
	dc.w $18a,$102,$18e,$222,$182,$223
	dc.w $18c,$323,$188,$323,$186,$334,$184,$443
	dc.w $8607,$fffe
;30
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$322,$188,$322,$186,$333,$184,$433
	dc.w $8807,$fffe
;31
	dc.w $18a,$104,$18e,$214,$182,$225
	dc.w $18c,$324,$188,$324,$186,$335,$184,$435
	dc.w $8a07,$fffe
;32
	dc.w $18a,$203,$18e,$313,$182,$324
	dc.w $18c,$423,$188,$423,$186,$434,$184,$534
	dc.w $8c07,$fffe
;33
	dc.w $18a,$213,$18e,$313,$182,$324
	dc.w $18c,$433,$188,$433,$186,$434,$184,$534
	dc.w $8e07,$fffe
;34
	dc.w $18a,$114,$18e,$214,$182,$224
	dc.w $18c,$323,$188,$323,$186,$334,$184,$434
	dc.w $9007,$fffe
;35
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$322,$186,$333,$184,$433
	dc.w $9207,$fffe
;36
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $9407,$fffe
;37
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $9607,$fffe
;38
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$322,$188,$312,$186,$323,$184,$433
	dc.w $9807,$fffe
;39
	dc.w $18a,$110,$18e,$210,$182,$221
	dc.w $18c,$321,$188,$311,$186,$322,$184,$432
	dc.w $9a07,$fffe
;40
	dc.w $18a,$210,$18e,$310,$182,$321
	dc.w $18c,$421,$188,$411,$186,$422,$184,$532
	dc.w $9c07,$fffe
;41
	dc.w $18a,$210,$18e,$320,$182,$331
	dc.w $18c,$431,$188,$421,$186,$432,$184,$542
	dc.w $9e07,$fffe
;42
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $a007,$fffe
;43
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$440,$188,$430,$186,$441,$184,$551
	dc.w $a207,$fffe
;44
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $a407,$fffe
;45
	dc.w $18a,$120,$18e,$230,$182,$331
	dc.w $18c,$341,$188,$331,$186,$342,$184,$452
	dc.w $a607,$fffe
;46
	dc.w $18a,$120,$18e,$230,$182,$341
	dc.w $18c,$351,$188,$341,$186,$352,$184,$462
	dc.w $a807,$fffe
;47
	dc.w $18a,$121,$18e,$231,$182,$332
	dc.w $18c,$342,$188,$332,$186,$343,$184,$453
	dc.w $aa07,$fffe
;48
	dc.w $18a,$021,$18e,$131,$182,$232
	dc.w $18c,$242,$188,$232,$186,$243,$184,$353
	dc.w $ac07,$fffe
;49
	dc.w $18a,$022,$18e,$132,$182,$233
	dc.w $18c,$243,$188,$233,$186,$244,$184,$354
	dc.w $ae07,$fffe
;50
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
	dc.w $b007,$fffe
;51
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $b207,$fffe
;52
	dc.w $18a,$013,$18e,$023,$182,$124
	dc.w $18c,$134,$188,$124,$186,$135,$184,$245
	dc.w $b407,$fffe
;53
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $b607,$fffe
;54
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344

