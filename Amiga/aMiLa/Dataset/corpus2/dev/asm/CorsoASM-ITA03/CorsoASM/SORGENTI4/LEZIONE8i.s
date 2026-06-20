
; Lezione8i - Semplici equalizzatori temporizzati con la routine musicale
;	    - TASTO DESTRO per cambiare velocita' delle barre

	SECTION	MAINPROGRAM,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#MyCopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	bsr.w	mt_init	; Inizializza la routine musicale

MainLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	mt_music		; suona la musica

	btst	#2,$dff016	; tasto destro premuto?
	beq.s	VaiForte
	move.b	#2,EqualSpeed	; velocita' di calo = 2 pixel a frame
	bra.s	VaiPiano
Vaiforte:
	move.b	#8,EqualSpeed	; velocita' di calo = 8 pixel a frame
VaiPiano:

	bsr.s	Equalizzatori		; Semplice routine equalizzatori

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001		; LMB premuto?
	bne.s	MainLoop		; Se "NO" ricomincia

	bsr.w	mt_end	; ferma la routine musicale
	rts


; Ecco la routine degli equalizzatori, l'audio analizer. La prima cosa da
; sapere e' dove trovare informazioni sull'utilizzo delle 4 voci da parte
; della routine musicale. Solitamente si usa controllare la variabile della
; replay routine che ci puo' segnalare se viene attivata una voce per suonare
; uno strumento, solitamente "mt_chanXtemp", dove la X puo' essere 1,2,3 o 4.
; Questo sistema pero' non e' la perfezione, dato che possiamo sapere soltanto
; quando "comuncia" l'utilizzo di una delle 4 voci, per cui se per esempio
; viene suonato uno strumento che continua a suonare per 10 secondi, la
; barretta di quella voce si allunghera' al primo secondo, segnalando l'uso
; di quella voce in quel momento, ma poi si abbassera' e rimarra' tranquilla
; fino a che quella voce non sara' usata per suonare un'altro strumento.
; Se una voce e' usata per suoni corti, come la batteria, non si nota questo
; fatto, dato che al momento del BUM! la barretta sale, e quando e' scesa
; nuovamente il suono e' finito o sta per finire. Il problema diviene tragico
; quando vuene usato uno strumento che fa il "loop", ad esempio le voices,
; per cui la barretta fa un solo "saltello", poi rimane giu' durante il loop.
; Questo sistema e' lo stesso delle barre presenti sulle 4 tracce dei vecchi
; soundtracker e protracker fino alla versione 2. Per equalizzatori del tipo
; del protracker 3, che seguono piu' fedelmente il "volume" delle voci, occorre
; modificare la routine musicale stessa, lo stesso vale per gli equalizzatori
; che visualizzano la forma d'onda. Basta fare un "tst.w mt_chanXtemp", e si
; puo' agire di conseguenza. In questo caso vengono mosse delle barre fatte col
; copper, utilizzando la posizione orizzontale dei wait della copperlist, in
; questo modo usiamo solo il colore di sfondo, $dff180, senza bitplanes.
; Basta aspettare l'inizio della linea, mettere il colore della barra, e poi
; mettere un wait che aspetti una posizione orizzontale piu' avanzata, ma
; nella stessa linea, dopodiche' rimettere il colore dello sfondo. In questo
; modo, agendo su quel wait, "spostiamo" in avanti e indietro la barra, come
; abbiamo visto in lezione3g.s e Lezione3h.s
; La routine in pratica fa questo: ogni fotogramma cala le barre, fino a che
; non sono azzerate, per cui se non c'e' musica rimangono azzerate. Nel caso
; che il tst dell'mt_chanXtemp segnali un sample suonato in quella voce, mette
; alla corrispondenza barra il valore massimo, ossia $a7.

;		    ,,,,,,,
;		   ,)))))))))
;		   | _______¡     ___
;		   |  _¬©)©)     ( )))
;		   l_ |  ,\|     / ¯/
;		  __| l___¯|__  /  /
;		 /¯ l__ ¬ _! ¬\/  /
;		/  /::`---':\  \ /
;		\  \:::...::¡\__/
;		 \  \:::::::|
;		  \  \::::::|
;		  /),,)¯¯¯¯¯¯\
;		 / ¯¯¯  /\    \ xCz
;		 \      \_\    \
;		  \______//    /
;		   /  ¬/ /    /
;		  (___/ /____/_
;		        ¯\_____)


Equalizzatori:
	move.b	EqualSpeed(PC),d0 ; velocita' di "calo" delle barre in d0
	cmp.b	#$07,WaitEqu1+1	; la prima barra e' calata a zero?
	bls.s	NonAbbass1	; se si, non la abbassare ulteriormente!
				; * bls significa minore o uguale, e' meglio
				; usarlo al posto del beq perche' sottraendo
				; con d0 un numero troppo grande puo'
				; succedere che si vada a $05 o $03!
	sub.b	d0,WaitEqu1+1	; altrimenti abbassa la barra, composta da
	sub.b	d0,WaitEqu1b+1	; due linee colorate e una nera
	sub.b	d0,WaitEqu1c+1
NonAbbass1:
	tst.w	mt_chan1temp	; voce 1 non "suonata"?
	beq.s	anal2		; se no, salta ad Anal2
	clr.w	mt_chan1temp	; azzera per aspettare la prossima scrittura
	move.b	#$a7,WaitEqu1+1	; BARRA AL MASSIMO!
	move.b	#$a7,WaitEqu1b+1
	move.b	#$a7,WaitEqu1c+1
anal2:
	cmp.b	#$07,WaitEqu2+1	; la seconda barra e' calata a zero?
	bls.s	NonAbbass2	; se si, non la abbassare ulteriormente!
	sub.b	d0,WaitEqu2+1	; altrimenti abbassa la barra
	sub.b	d0,WaitEqu2b+1
	sub.b	d0,WaitEqu2c+1
NonAbbass2:
	tst.w	mt_chan2temp	; voce 2 non "suonata"?
	beq.s	anal3		; se no, salta ad Anal3
	clr.w	mt_chan2temp	; azzera per aspettare la prossima scrittura
	move.b	#$a7,WaitEqu2+1	; BARRA AL MASSIMO!
	move.b	#$a7,WaitEqu2b+1
	move.b	#$a7,WaitEqu2c+1
anal3:
	cmp.b	#$07,WaitEqu3+1	; la terza barra e' calata a zero?
	bls.s	NonAbbass3	; se si, non la abbassare ulteriormente!
	sub.b	d0,WaitEqu3+1	; altrimenti abbassa la barra
	sub.b	d0,WaitEqu3b+1
	sub.b	d0,WaitEqu3c+1
NonAbbass3:
	tst.w	mt_chan3temp	; voce 3 non "suonata"?
	beq.s	anal4		; se no, salta ad Anal4
	clr.w	mt_chan3temp	; azzera per aspettare la prossima scrittura
	move.b	#$a7,WaitEqu3+1	; BARRA AL MASSIMO!
	move.b	#$a7,WaitEqu3b+1
	move.b	#$a7,WaitEqu3c+1
anal4:
	cmp.b	#$07,WaitEqu4+1	; la quarta barra e' calata a zero?
	bls.s	NonAbbass4	; se si, non la abbassare ulteriormente!
	sub.b	d0,WaitEqu4+1	; altrimenti abbassa la barra
	sub.b	d0,WaitEqu4b+1
	sub.b	d0,WaitEqu4c+1
NonAbbass4:
	tst.w	mt_chan4temp	; voce 4 non "suonata"?
	beq.s	analizerend	; se no, esci!
	clr.w 	mt_chan4temp	; azzera per aspettare la prossima scrittura
	move.b	#$a7,WaitEqu4+1	; BARRA AL MASSIMO!
	move.b	#$a7,WaitEqu4b+1
	move.b	#$a7,WaitEqu4c+1
analizerend:
	rts

EqualSpeed:
	dc.b	4
	even

*******************************************************************************
;	ROUTINE MUSICALE

	include	"music.s"
*******************************************************************************

	Section	DatiChippy,data_C

MyCopList:
	dc.w	$100,$200	; Bplcon0 - no bitplanes
	dc.w	$180,$00e	; color0 blu
	dc.w	$ffdf,$fffe	; aspetta la linea $FF

;	wait&mode della routine analyzer - usano la posizione orizzontale
;	dei wait per far andare in "avanti" e "indietro" le barre

	dc.w	$1507,$fffe	; wait inizio riga
	dc.w	$180,$00e	; color0 blu

	dc.w	$1607,$fffe	; wait inizio riga
	dc.w	$180,$f55	; color0 ROSSO - colore prima BARRA
WaitEqu1:
	dc.w	$1617,$fffe	; wait (sara' modificato come fine riga, poi
				; calera' di 4 in 4 fino a tornare a $07)
	dc.w	$180,$00e	; color0 blu
	dc.w	$1707,$fffe	; wait inizio riga
	dc.w	$180,$f55	; color0 ROSSO (barra alta 2 linee!)
WaitEqu1b:
	dc.w	$1717,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$1807,$fffe	; wait inizio riga
	dc.w	$180,$002	; color0 NERO ("ombra" sotto la prima barra)
WaitEqu1c:
	dc.w	$1817,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu

; seconda barra

	dc.w	$1b07,$fffe	; wait inizio linea
	dc.w	$180,$a5f	; color0 VIOLA (seconda BARRA)
WaitEqu2:
	dc.w	$1b17,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$1c07,$fffe	; wait inizio linea
	dc.w	$180,$a5f	; colore SECONDA BARRA (alta 2 linee!)
WaitEqu2b:
	dc.w	$1c17,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$1d07,$fffe	; wait inizio linea
	dc.w	$180,$002	; color0 nero ("ombra")
WaitEqu2c:
	dc.w	$1d17,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu

; terza barra

	dc.w	$2007,$fffe	; wait inizio linea
	dc.w	$180,$ff0	; colore TERZA BARRA
WaitEqu3:
	dc.w	$2017,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$2107,$fffe	; wait inizio linea
	dc.w	$180,$ff0	; colore TERZA BARRA (alta 2 linee!)
WaitEqu3b:
	dc.w	$2117,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$2207,$fffe	; wait inizio linea
	dc.w	$180,$002	; color0 nero ("ombra")
WaitEqu3c:
	dc.w	$2217,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu

; quarta barra

	dc.w	$2507,$fffe	; wait inizio linea
	dc.w	$180,$5F0	; colore QUARTA BARRA
WaitEqu4:
	dc.w 	$2517,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$2607,$fffe	; wait inizio linea
	dc.w	$180,$5F0	; colore QUARTA BARRA (alta 2 linee!)
WaitEqu4b:
	dc.w 	$2617,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu
	dc.w	$2707,$fffe	; wait inizio linea
	dc.w	$180,$002	; color0 nero ("ombra")
WaitEqu4c:
	dc.w 	$2717,$fffe	; wait (modificato per lunghezza barra)
	dc.w	$180,$00e	; color0 blu

	DC.W	$FFFF,$FFFE	; fine copperlist


; Musica. Attenzione: la routine "music.s" del disco 2 non e' la stessa di
; quella del disco 1. Le 2 modifiche sono la rimossione di un BUG che alle
; volte causava una guru all'uscita del programma, e il fatto che mt_data
; e' un puntatore alla musica, e non LA musica. Questo permette di cambiare
; la musica piu' facilmente.

; potete scegliere una delle 4 musichette presenti nel disco.

mt_data:
	dc.l	mt_data1

Mt_data1:
;	incbin	"mod.fairlight"		; by d-zire/silents 92 (lungo solo 2k!)
	incbin	"mod.fuck the bass"	; by m.c.m/remedy 91
;	incbin	"mod.yellowcandy"	; by sire/supplex
;	incbin	"mod.JamInexcess"	; by raiser/ram jam

	end

Potete usare questo sorgente per sentire le 4 musichette protracker di questo
disco. Il "mod.fairlight" e' una delle musiche piu' "sintetiche" possibili,
infatti e' lunga solamente 2374 bytes, e compattata col PowerPacker diventa
lunga 952 bytes!!!

