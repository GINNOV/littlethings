
; Lezione5g.s	SCORRIMENTO DI UNA FIGURA IN ALTO E IN BASSO MODIFICANDO I
;		PUNTATORI AI PITPLANES NELLA COPPERLIST + EFFETTO SPECCHIO
;		OTTENUTO CON I MODULI NEGATIVI (-40*2, -40*3, -40*4...)

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
	cmp.l	#PIC-(40*18),d0	; siamo arrivati abbastanza in BASSO?
	beq.s	MettiGiu	; se si, siamo in fondo e dobbiamo risalire
	sub.l	#40,d0		; sottraiamo 40, ossia 1 linea, facendo
				; scorrere in BASSO la figura
	bra.s	Finito

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	bra.s	Finito		; fara' saltare alla routine VAIGIU

VAIGIU:
	cmpi.l	#PIC+(40*130),d0	; siamo arrivati abbastanza in ALTO?
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

;	EFFETTO SPECCHIO (che si potrebbe vendere per effetto "texturemap")

	dc.w	$b007,$fffe
	dc.w	$180,$004	; Color0
	dc.w	$108,-40*7	; Bpl1Mod - specchio dimezzato 5 volte
	dc.w	$10a,-40*7	; Bpl2Mod
	dc.w	$b307,$fffe
	dc.w	$180,$006	; Color0
	dc.w	$108,-40*6	; Bpl1Mod - specchio dimezzato 4 volte
	dc.w	$10a,-40*6	; Bpl2Mod
	dc.w	$b607,$fffe
	dc.w	$180,$008	; Color0
	dc.w	$108,-40*5	; Bpl1Mod - specchio dimezzato 3 volte
	dc.w	$10a,-40*5	; Bpl2Mod
	dc.w	$bb07,$fffe
	dc.w	$180,$00a	; Color0
	dc.w	$108,-40*4	; Bpl1Mod - specchio dimezzato 2 volte
	dc.w	$10a,-40*4	; Bpl2Mod
	dc.w	$c307,$fffe
	dc.w	$180,$00c	; Color0
	dc.w	$108,-40*3	; Bpl1Mod - specchio dimezzato
	dc.w	$10a,-40*3	; Bpl2Mod
	dc.w	$d007,$fffe
	dc.w	$180,$00e	; Color0
	dc.w	$108,-40*2	; Bpl1Mod - specchio normale
	dc.w	$10a,-40*2	; Bpl2Mod
	dc.w	$d607,$fffe
	dc.w	$180,$00f	; Color0
	dc.w	$108,-40	; Bpl1Mod - FLOOD, linee ripetute per
	dc.w	$10a,-40	; Bpl2Mod - effetto centrale di ingrandimento
	dc.w	$da07,$fffe
	dc.w	$180,$00e	; Color0
	dc.w	$108,-40*2	; Bpl1Mod - specchio normale
	dc.w	$10a,-40*2	; Bpl2Mod
	dc.w	$e007,$fffe
	dc.w	$180,$00c	; Color0
	dc.w	$108,-40*3	; Bpl1Mod - specchio dimezzato
	dc.w	$10a,-40*3	; Bpl2Mod
	dc.w	$ed07,$fffe
	dc.w	$180,$00a	; Color0
	dc.w	$108,-40*4	; Bpl1Mod - specchio dimezzato 2 volte
	dc.w	$10a,-40*4	; Bpl2Mod
	dc.w	$f507,$fffe
	dc.w	$180,$008	; Color0
	dc.w	$108,-40*5	; Bpl1Mod - specchio dimezzato 3 volte
	dc.w	$10a,-40*5	; Bpl2Mod
	dc.w	$fa07,$fffe
	dc.w	$180,$006	; Color0
	dc.w	$108,-40*6	; Bpl1Mod - specchio dimezzato 4 volte
	dc.w	$10a,-40*6	; Bpl2Mod
	dc.w	$fd07,$fffe
	dc.w	$180,$004	; Color0
	dc.w	$108,-40*7	; Bpl1Mod - specchio dimezzato 5 volte
	dc.w	$10a,-40*7	; Bpl2Mod
	dc.w	$ff07,$fffe
	dc.w	$180,$002	; Color0
	dc.w	$108,-40	; ferma l'immagine per evitare di visualizzare
	dc.w	$10a,-40	; i byte prima della RAW

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

	dcb.b	40*98,0		; spazio azzerato

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	dcb.b	40*30,0		; spazio azzerato

	end

In questo esempio mettendo dei moduli negativi per creare specchiature sempre
piu' "DIMEZZATE", e' stato possibile simulare "un'avvolgimento" dell'immagine
specchiata su una superficie rozzamente "curva". Disponendo bene i moduli
si possono generare effetti del tipo ZOOM o LENTE DI INGRANDIMENTO, nonche' di
distorsione cilindrica come questo esempio, specialmente se si aiuta l'effetto
ottico con i colori (in questo caso con una tonalita' di blu).
Il sorgente e' lo stesso di Lezione5c.s, l'unica modifica e' nella copperlist.
Per aggiungere realismo all'effetto di "avvolgimento su un cilindro" si
puo' simulare una curvatura con i $dff102 (bplcon1), come gia' visto nel
listato Lezione5d2.s. Sostituite la copperlist dell'esempio con questa, che
e' una fusione con quella di Lezione5d2.s.

- Ricordo che per rimuovere la vecchia parte di copperlist potete usare
l'opzione Amiga+b per selezionarla e Amiga+x per il taglio a selezione fatta,
mentre per copiare questa parte di copperlist sopra, selezionatela con Amiga+b,
poi Amiga+c per copiare, posizionatevi nel punto giusto in copperlist e
inseritela con Amiga+i.


	dc.w	$b007,$fffe
	dc.w	$180,$004	; Color0
	dc.w	$102,$011	; bplcon1
	dc.w	$108,-40*7	; Bpl1Mod - specchio dimezzato 5 volte
	dc.w	$10a,-40*7	; Bpl2Mod
	dc.w	$b307,$fffe
	dc.w	$180,$006	; Color0
	dc.w	$102,$022	; bplcon1
	dc.w	$108,-40*6	; Bpl1Mod - specchio dimezzato 4 volte
	dc.w	$10a,-40*6	; Bpl2Mod
	dc.w	$b607,$fffe
	dc.w	$180,$008	; Color0
	dc.w	$102,$033	; bplcon1
	dc.w	$108,-40*5	; Bpl1Mod - specchio dimezzato 3 volte
	dc.w	$10a,-40*5	; Bpl2Mod
	dc.w	$bb07,$fffe
	dc.w	$180,$00a	; Color0
	dc.w	$102,$044	; bplcon1
	dc.w	$108,-40*4	; Bpl1Mod - specchio dimezzato 2 volte
	dc.w	$10a,-40*4	; Bpl2Mod
	dc.w	$c307,$fffe
	dc.w	$180,$00c	; Color0
	dc.w	$102,$055	; bplcon1
	dc.w	$108,-40*3	; Bpl1Mod - specchio dimezzato
	dc.w	$10a,-40*3	; Bpl2Mod
	dc.w	$d007,$fffe
	dc.w	$180,$00e	; Color0
	dc.w	$102,$066	; bplcon1
	dc.w	$108,-40*2	; Bpl1Mod - specchio normale
	dc.w	$10a,-40*2	; Bpl2Mod
	dc.w	$d607,$fffe
	dc.w	$180,$00f	; Color0
	dc.w	$102,$077	; bplcon1
	dc.w	$108,-40	; Bpl1Mod - FLOOD, linee ripetute per
	dc.w	$10a,-40	; Bpl2Mod - effetto centrale di ingrandimento
	dc.w	$da07,$fffe
	dc.w	$180,$00e	; Color0
	dc.w	$102,$066	; bplcon1
	dc.w	$108,-40*2	; Bpl1Mod - specchio normale
	dc.w	$10a,-40*2	; Bpl2Mod
	dc.w	$e007,$fffe
	dc.w	$180,$00c	; Color0
	dc.w	$102,$055	; bplcon1
	dc.w	$108,-40*3	; Bpl1Mod - specchio dimezzato
	dc.w	$10a,-40*3	; Bpl2Mod
	dc.w	$ed07,$fffe
	dc.w	$180,$00a	; Color0
	dc.w	$102,$044	; bplcon1
	dc.w	$108,-40*4	; Bpl1Mod - specchio dimezzato 2 volte
	dc.w	$10a,-40*4	; Bpl2Mod
	dc.w	$f507,$fffe
	dc.w	$180,$008	; Color0
	dc.w	$102,$033	; bplcon1
	dc.w	$108,-40*5	; Bpl1Mod - specchio dimezzato 3 volte
	dc.w	$10a,-40*5	; Bpl2Mod
	dc.w	$fa07,$fffe
	dc.w	$180,$006	; Color0
	dc.w	$102,$022	; bplcon1
	dc.w	$108,-40*6	; Bpl1Mod - specchio dimezzato 4 volte
	dc.w	$10a,-40*6	; Bpl2Mod
	dc.w	$fd07,$fffe
	dc.w	$180,$004	; Color0
	dc.w	$102,$011	; bplcon1
	dc.w	$108,-40*7	; Bpl1Mod - specchio dimezzato 5 volte
	dc.w	$10a,-40*7	; Bpl2Mod
	dc.w	$ff07,$fffe
	dc.w	$180,$002	; Color0
	dc.w	$102,$000	; bplcon1
	dc.w	$108,-40	; ferma l'immagine per evitare di visualizzare
	dc.w	$10a,-40	; i byte prima della RAW

