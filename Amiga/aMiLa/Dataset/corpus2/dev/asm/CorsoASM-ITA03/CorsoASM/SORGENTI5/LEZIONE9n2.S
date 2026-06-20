
; Lezione9n2.s	Ancora Scrolltext!! Quello nell'intro del disco 1!
;		Tasto sinistro per uscire.

	Section	BigScroll,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001111000000	; blitter, copper, bitplane DMA

START:

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE+100*44,d0	; bitplane
	LEA	BPLPOINTERS,A1
	MOVEQ	#3-1,D1			; numero di bitplanes
POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addi.l	#44*256,d0		; + LUNGHEZZA DI UNA PLANE !!!!!
	addq.w	#8,a1
	dbra	d1,POINTB

	bsr.s	makecolors		; Fai effetto in copperlist

	lea	$dff000,a6
	MOVE.W	#DMASET,$96(a6)		; DMACON - abilita dma
	move.l	#COPPERLIST,$80(a6)	; Puntiamo la nostra COP
	move.w	d0,$88(a6)		; Facciamo partire la COP
	move.w	#0,$1fc(a6)		; Disattiva l'AGA
	move.w	#$c00,$106(a6)		; Disattiva l'AGA
	move.w	#$11,$10c(a6)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	MainScroll	; routine di gestione scroll

	BTST.B	#6,$bfe001	; tasto del mouse premuto?
	BNE.s	mouse
	rts

;*****************************************************************************
; questa routine crea una sfumatura di colore nella copperlist
; in pratica nella copperlist c'e` dello spazio vuoto che viene
; riempito da questa routine che mette le giuste istruzioni copper.
; Vedremo molte di queste routines in Lezione11.txt
;*****************************************************************************

MAKECOLORS:
	lea	scol,a0		; Indirizzo dove modificare copperlist
	lea	coltab,a1	; tabella colori 1
	lea	coltab2,a2	; tabella colori 2
	move.l	#$a807,d1	; riga di partenza = $A0
	moveq	#63,d0		; numero di righe
col1:
	move.w	d1,(a0)+	; crea istruzione WAIT
	move.w	#$fffe,(a0)+

	move.w	#$0182,(a0)+	; istruzione che modifica COLOR01
	move.w	(a1)+,(a0)+
	move.w	#$018E,(a0)+	; istruzione che modifica COLOR07
	move.w	(a2)+,(a0)+

	add.w	#$100,d1	; prossima riga
	dbra	d0,col1
	rts

coltab:
	 dc.w	$00,$11,$22,$33,$44,$55,$66,$77,$88,$99
	 dc.w	$aa,$bb,$cc,$dd,$ee,$ff,$ff,$ee,$dd,$cc
	 dc.w	$bb,$aa,$99,$88,$77,$66,$55,$44,$33,$22
	 dc.w	$11,$00
	 dc.w	$000,$110,$220,$330,$440,$550,$660,$770,$880,$990
	 dc.w	$aa0,$bb0,$cc0,$dd0,$ee0,$ff0,$ff0,$ee0,$dd0,$cc0
	 dc.w	$bb0,$aa0,$990,$880,$770,$660,$550,$440,$330,$220
	 dc.w	$110,$000
	 dc.w	$000,$101,$202,$303,$404,$505,$606,$707,$808,$909
	 dc.w	$a0a,$b0b,$c0c,$d0d,$e0e,$f0f,$f0f,$e0e,$d0d,$c0c
	 dc.w	$b0b,$a0a,$909,$808,$707,$606,$505,$404,$303,$202
	 dc.w	$101,$000,0,0

coltab2:
	 dc.w	$000,$101,$202,$303,$404,$505,$606,$707,$808,$909
	 dc.w	$a0a,$b0b,$c0c,$d0d,$e0e,$f0f,$f0f,$e0e,$d0d,$c0c
	 dc.w	$b0b,$a0a,$909,$808,$707,$606,$505,$404,$303,$202
	 dc.w	$101,$000,0,0
	 dc.w	$000,$011,$022,$033,$044,$055,$066,$077,$088,$099
	 dc.w	$0aa,$0bb,$0cc,$0dd,$0ee,$0ff,$0ff,$0ee,$0dd,$0cc
	 dc.w	$0bb,$0aa,$099,$088,$077,$066,$055,$044,$033,$022
	 dc.w	$011,$000
	 dc.w	$000,$110,$220,$330,$440,$550,$660,$770,$880,$990
	 dc.w	$aa0,$bb0,$cc0,$dd0,$ee0,$ff0,$ff0,$ee0,$dd0,$cc0
	 dc.w	$bb0,$aa0,$990,$880,$770,$660,$550,$440,$330,$220
	 dc.w	$110,$000

;*****************************************************************************
; 		ROUTINE PRINCIPALE DELLO SCROLLTEXT
;*****************************************************************************

MainScroll:
	lea	$dff000,a6
	btst.b	#10,$16(a6)		; premuto il tasto destro?
	beq.s	SaltaScroll		; se si, sposta in verticale la scritta
					; senza scrollarla

	move.l	noscroll(pc),d0		; contatore di scroll
	subq.l	#1,d0			; decrementa il contatore
	bmi.s	do_scrolling		; se negativo scrolla
	move.l	d0,noscroll		; altrimenti sposta solo la scritta
	bra.s	SaltaScroll

do_scrolling:				; effettua lo scrolling
	clr.l	noscroll		; azzera il contatore

	bsr.w	PrintChar		; stampa nuovo carattere
	bsr.s	DoScroll		; scrolla text

SaltaScroll:
	bsr.s	Drawscroll		; richiama la routine che disegna
					; il testo sullo schermo

	lea	sinustab(PC),a0		; queste istruzioni ruotano i valori
	lea	4(a0),a1		; della tabella delle posizioni
	move.l	(a0),d0			; verticali dello scrolltext
copysinustab:
	move.l	(a1)+,(a0)+
	cmpi.l	#$ffff,(a1)		; Flag di fine tabella? Se non ancora,
	bne.s	copysinustab		; continua a spostare...
	move.l	d0,(a0)			; Alla fine, metti il primo val. in
	rts				; fondo!

;*****************************************************************************
; Questa routine effettua lo scrolling vero e proprio. Da notare che per
; stabilire la velocita' di scroll, si usa la label "speedlogic", che non
; e' altro che il valore da inserire nel BLTCON0, che a seconda delle varie
; velocita' ha un valore di shift diverso.
;*****************************************************************************

;	    _____________
;	   /  ---  ____ ¬\
;	 _/ ¬____,¬_____-'\_
;	(_   ¬(°T..(°)_¬   _)
;	 T`--  ¯____¯ __,¬ T
;	 l_ ,-¬/----\-`    !
;	  \__ /______\-¯¯¬/
;	    | `------'  T¯ xCz
;	    `-----------'

DoScroll:
	lea	BITPLANE+2,a0	; Source (16 pixel piu' avanti)
	lea	BITPLANE,a1	; Dest   (inizio... quindi <- di 16 pixel!)
	moveq	#3-1,d7		; Numero blittate = 3 per 3 planes
BlittaLoop1:
	btst	#6,2(a6)	; dmaconr - waitblit
bltx:
	btst	#6,2(a6)	; dmaconr - waitblit
	bne.s	bltx

	moveq	#0,d1
	move.w	d1,$42(a6)		; BLTCON1
	move.l	d1,$64(a6)		; BLTAMOD, BLTDMOD
	moveq	#-1,d1			; $FFFFFFFF
	move.l	d1,$44(a6)		; BLTAFWM, BLTALWM
	move.w	speedlogic(PC),$40(a6)	; BLTCON0 (stabilisce velocita' di
					;          scroll tramite lo shift)

	btst	#6,2(a6)	; dmaconr - waitblit
blt23:
	btst	#6,2(a6)	; dmaconr - waitblit
	bne.s	blt23

	move.l	a0,$50(a6)		; BLTAPT
	move.l	a1,$54(a6)		; BLTDPT
	move.w	#(32*64)+22,$58(a6)	; BLTSIZE

	add.w	#32*44,a0	; prossimo plane sorgente
	add.w	#32*44,a1	; prossimo plane destinazione

	dbra	d7,BlittaLoop1
	rts

;*****************************************************************************
; questa routine disegna sullo schermo lo scrolltext ad una posizione verticale
; variabile secondo i valori di una sinusoide (ossia una bella SIN TAB!).
; Da notare che anziche' copiarlo con lente blittate, avremmo potuto in modo
; piu' "economico" e "amighevole" cambiare solo i puntatori ai bitplanes,
; facendo lo stesso lavoro con pochi move. Pero' questo e' un sorgente
; dedicato al blitter, quindi blittiamo!
;*****************************************************************************

Drawscroll:
	lea	BITPLANE,a0		; puntatore sorgente
	lea	sinustab(pc),a5		; tabella seno
	move.l	(a5),d4			; leggi coordinata Y
					; (la prima della tabella)
	lea	BITPLANE+(112*44),a5	; indirizzo destinazione
	add.l	d4,a5			; aggiungi coordinata Y

	btst	#6,2(a6)		; aspetta che il blitter sia fermo
blt1e:					; prima di modificare i registri
	btst	#6,2(a6)
	bne.s	blt1e

	moveq	#-1,d1
	move.l	d1,$44(a6)		; BLATLWM, BLTAFWM
	moveq	#0,d1
	move.l	d1,$64(a6)		; BLTAMOD/BLTDMOD
	move.l	#$09f00000,$40(a6)	; BLTCON0 - copia normale

	moveq	#3-1,d7			; Num. di planes
copialoopa:
	btst	#6,2(a6)		; aspetta che il blitter sia fermo
blt1f:
	btst	#6,2(a6)
	bne.s	blt1f

	move.l	a0,$50(a6)		; BLTAPT
	move.l	a5,$54(a6)		; BLTDPT
	move.w	#32*64+22,$58(a6)	; BLTSIZE - copyscroll

	add.w	#32*44,a0		; prossimo plane sorgente
	add.w	#256*44,a5		; prossimo plane dest.

	dbra	d7,copialoopa
	rts

; Questa tabella contiene gli offset per le coordinte Y per far andare su e
; giu' lo scroll.

sinustab:
	dc.l	0,44,88,132,176,220,264,308,352,396
	dc.l	440,484,528,572,616,660,704,748,792
	dc.l	836,880,924,968,1012,1056,1100,1144,1188,1232
	dc.l	1276,1276,1232
	dc.l	1188,1144,1100,1056,1012,968,924,880,836,792,748,704
	dc.l	660,616,572,528,484,440,396,352,308
	dc.l	264,220,176,132,88,44,0
sinusend:
	 dc.l	0
	 dc.l	$ffff	; flag di fine tabella


;*****************************************************************************
; Questa routine stampa i nuovi caratteri. Da notare che nel testo ci sono
; anche dei FLAG, in questo caso dei numeri da 1 a 5, che cambiano la
; velocita' di scroll. Questo cambiando il valore di shift da mettere in
; bltcon0, nonche' il numero di caratteri da stampare ogni frame (e' chiaro
; che a velocita' supersonica occorre stampare piu' caratteri al frame!).
; Altro particolare da notare, e' che il sistema usato per costruire il
; font e' diverso da quelli visti fino ad ora. Infatti il font caratteri
; non e' altro che una schermata 320*200 a 8 colori, con i caratteri posti
; l'uno accanto all'altro, e una fila sotto l'altra. Questo rende piu' facile
; disegnarsi un proprio font, ma richiede una routine diversa per trovare il
; font. Infatti, occorre fare una tabella contenente gli offsets dall'inizio
; del font di ogni carattere, e a seconda del valore ascii che dobbiamo
; stampare, prendere il corrispondente valore dalla tabella per sapere
; la posizione del carattare in questione. Cio' puo' sembrare complesso, ma
; dato che i caratteri nel font sono messi nell'ordine ascii, vedrete che e'
; molto semplice scriversi la tabella con gli offset!
; Il font, comunque, e' presente anche in formato .iff, in modo da rendere
; piu' chiuaro il sistema, e piu' semplice il disegno di un nuovo font.
;*****************************************************************************

PrintChar:
	tst.w	textctr		; se il contatore e` positivo non stampa
	bne.w	noPrint
	move.l	textptr(PC),a0	; legge il carattere da stampare
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.l	#textend,textptr	; siamo alla fine del testo ?
	bne.s	noend
	lea	scrollmsg(PC),a0	; se si ricomincia da capo!
	move.b	(a0)+,d0		; carattere in d0
noend:
	cmp.b	#1,d0			; FLAG 1? Allora speed = 1
	bne.s	nots1
	move.w	#32,scspeed		; valore iniziale di textctr
	move.w	#$f9f0,speedlogic	; valore di BPLCON0
	move.b	(a0)+,d0		; prossimo carattere in d0
	bra.s	contscroll
nots1:
	cmpi.b	#2,d0			; FLAG 2? Allora speed = 2
	bne.s	nots2
	move.w	#16,scspeed
	move.w	#$e9f0,speedlogic	; valore di BPLCON0
	move.b	(a0)+,d0
	bra.s	contscroll
nots2:
	cmpi.b	#3,d0			; FLAG 3? Allora speed = 3
	bne.s	nots3
	move.w	#8,scspeed
	move.w	#$c9f0,speedlogic	; valore di BPLCON0
	move.b	(a0)+,d0
	bra.s	contscroll
nots3:
	cmpi.b	#4,d0			; FLAG 4? Allora speed = 4
	bne.s	nots4
	move.w	#4,scspeed
	move.w	#$89f0,speedlogic	; valore di BPLCON0
	move.b	(a0)+,d0
	bra.s	contscroll
nots4:
	cmpi.b	#5,d0			; Flag 5? Allora speed = 5
	bne.s	contscroll
	move.w	#2,scspeed
	move.w	#$19f0,speedlogic	; valore di BPLCON0
	move.b	(a0)+,d0

; Qua, passato il controllo dei flag, si stampa il carattere. Si noti il modo
; in cui si trova il carattere, tramite la tabella con gli offsets.

contscroll:
	move.l	a0,textptr	; salva il puntatore al prossimo carattere
	subi.b	#$20,d0		; ascii - 20 = il primo carattere e' lo spazio
	lsl.w	#2,d0		; moltiplica * 4 per trovare l'address in tab,
				; dato che ogni valore in tab e' .L (4 byte)
	lea	addresses(PC),a0
	move.l	0(a0,d0.w),a0	; copia in a0 l'indirizzo del carattere, preso
				; dalla tabella.

	btst	#6,2(a6)	; dmaconr - waitblit
blt30:
	btst	#6,2(a6)	; dmaconr - waitblit
	bne.s	blt30

	moveq	#-1,d1
	move.l	d1,$44(a6)	 	; BLTALWM, BLTAFWM
	move.l	#$09F00000,$40(a6)	; BLTCON0/1 - copia normale
	move.l	#$00240028,$64(a6)	; BLTAMOD = 36, BLTDMOD = 40

	lea	BITPLANE+40,a1		; puntatore destinazione
	moveq	#3-1,d7			; num. bitplanes
CopyCharL:

	btst	#6,2(a6)	; dmaconr - waitblit
blt31:
	btst	#6,2(a6)	; dmaconr - waitblit
	bne.s	blt31

	move.l	a0,$50(a6)		; BLTAPT (carattere in font)
	move.l	a1,$54(a6)		; BLTDPT (bitplane)
	move.w	#32*64+2,$58(a6)	; BLTSIZE

	add.w	#32*44,a1	; prossimo bitplane destinazione
	lea	40*200(a0),a0	; 1 bitplane della pic che contiene il font

	dbra	d7,copycharL

	move.w	scspeed(PC),textctr	; valore iniziale contatore stampa
noPrint:
	subq.w	#1,textctr	; decrementa il contatore che indica quando
				; stampare
endPrint:
	rts

; variabili

textptr:	 dc.l	scrollmsg	; puntatore al carattere da stampare

textctr:	 dc.w	0		; contatore che indica quando stampare
noscroll:	 dc.l	0		; contatore che indica quando scrollare

scspeed:	 dc.w	0		; valore iniziale del contatore che
					; indica quando stampare
					; varia a seconda della velocita`

speedlogic:	 dc.w	0		; valore di BLTCON0
					; varia a seconda della velocita`
					; perche` varia il valore di shift

;*****************************************************************************
; Questa tabella contiene una serie di indirizzi del font, che indicano la
; posizione dei caratteri ascii nel font stesso: per esempio, il primo e'
; Bigf senza altri offset, infatti il primo carattere che si trova nel font
; e' lo spazio, che e' anche il primo dell'ascii. Il secondo (che in ascii e'
; il punto esclamativo !) e' a bigf+4, infatti il ! nel font si trova al
; secondo posto, ossia 4 bytes (32 pixel) dopo il primo, essendo ogni
; carattere largo (e alto) 32 pixel.
; Dato che il font si trova in una figura 320*200, ci potranno stare solo
; 10 caratteri per fila orizzontale, per cui i caratteri dall'11 al 20
; dovranno essere in una fila sotto, quelli dal 22 al 30 sotto ancora, e
; cosi' via.
;*****************************************************************************

addresses:
	 dc.l BigF	; primo carattere: " "
	 dc.l BigF+4	; secondo carattere: "!"
	 dc.l BigF+8
	 dc.l BigF+12,BigF+16,BigF+20,BigF+24,BigF+28,BigF+32,BigF+36

; seconda fila di caratteri nel font: si parte da 1280, ossia 32*40, infatti
; occorre saltare le 32 linee di altezza della prima fila di caratteri

	 dc.l BigF+1280		; undicesimo carattere: "
	 dc.l BigF+1284
	 dc.l BigF+1288
	 dc.l BigF+1292
	 dc.l BigF+1296,BigF+1300,BigF+1304,BigF+1308,BigF+1312,BigF+1316

; terza fila di caratteri nel font

	 dc.l BigF+2560,BigF+2564,BigF+2568,BigF+2572,BigF+2576,BigF+2580
	 dc.l BigF+2584,BigF+2588,BigF+2592,BigF+2596
; quarta
	 dc.l BigF+3840,BigF+3844,BigF+3848,BigF+3852,BigF+3856,BigF+3860
	 dc.l BigF+3864,BigF+3868,BigF+3872,BigF+3876
; quinta
	 dc.l BigF+5120,BigF+5124,BigF+5128,BigF+5132,BigF+5136,BigF+5140
	 dc.l BigF+5144,BigF+5148,BigF+5152,BigF+5156
; sesta
	 dc.l BigF+6400,BigF+6404,BigF+6408,BigF+6412,BigF+6416,BigF+6420
	 dc.l BigF+6424,BigF+6428,BigF+6432,BigF+6436



;*****************************************************************************
; Ecco il testo: mettendo 1,2,3,4 si cambia la velocita' di scroll
;*****************************************************************************

scrollmsg:
 dc.b 4,"AMIGA EXPERT TEAM",1,"        ",3
 dc.b " IL NUOVO GRUPPO ITALIANO DI UTENTI AMIGA EVOLUTI  ",2
 dc.b "       ",3
 dc.b "  SE VUOI METTERTI IN CONTATTO CON APPASSIONATI DI AMIGA ",2
 dc.b "CHE LO USANO PER FARCI MUSICA, GRAFICA, PROGRAMMAZIONE O ALTRO,"
 dc.b " SIA PER HOBBY CHE PER LAVORO, SCRIVI A: (MOUSE DESTRO PER STOP) ",1
 dc.b " MIRKO LALLI - VIA VECCHIA ARETINA 64 - 52020 LATERINA STAZIONE - ",2
 dc.b "AREZZO - ",3
 dc.b " CREDITI PER QUESTA DEMO: ",1
 dc.b "PROGRAMMAZIONE ASSEBLER E GRAFICA BY FABIO CIUCCI -",2
 dc.b " MUSICA PRESA DA UNA LIBRERIA PD ",3
 dc.b "-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-",4
 dc.b "=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-"
 dc.b "                                                 "
textend:

; Nota: Altro CLUB per Amiga e' APU: per informazioni tel. 081/5700434
;							   081/7314158
; giovedi'-venerdi' ore 19-22

******************************************************************************
;		COPPERLIST:
******************************************************************************

	section	copper,data_c

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$24	; BplCon2 - Tutti gli sprite sopra i bitplane
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
	dc.w	$100,$200	; BplCon0 - no bitplanes

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$1af	; color1 - SCRITTE

	dc.w	$9707,$FFFE	; WAIT - disegna la barretta in alto
	dc.w	$180,$110	; Color0
	dc.w	$9807,$FFFE	; wait....
	dc.w	$180,$120
	dc.w	$9a07,$FFFE
	dc.w	$180,$130
	dc.w	$9b07,$FFFE
	dc.w	$180,$240
	dc.w	$9c07,$FFFE
	dc.w	$180,$250
	dc.w	$9d07,$FFFE
	dc.w	$180,$370
	dc.w	$9e07,$FFFE
	dc.w	$180,$390
	dc.w	$9f07,$FFFE
	dc.w	$180,$4b0
	dc.w	$a007,$FFFE
	dc.w	$180,$5d0
	dc.w	$a107,$FFFE
	dc.w	$180,$4a0
	dc.w	$a207,$FFFE
	dc.w	$180,$380
	dc.w	$a307,$FFFE
	dc.w	$180,$360
	dc.w	$a407,$FFFE
	dc.w	$180,$240
	dc.w	$a507,$FFFE
	dc.w	$180,$120
	dc.w	$a607,$FFFE
	dc.w	$180,$110

	dc.w	$A707,$FFFE
	dc.w	$180,$000

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo	  bitplane
	dc.w $e4,0,$e6,0	; secondo bitplane
	dc.w $e8,0,$ea,0	; terzo	  bitplane

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

	dc.w	$108,4		; bpl1mod - saltiamo i 4 bytes dove si
	dc.w	$10a,4		; bpl2mod - vedrebbe stampare il testo...
				; Ricordatevi che lo schermo e' largo 44 bytes
				; in realta', per lasciare all'estrema destra,
				; fuori dal visibile, cio' che non deve essere
				; visto. Tutti gli scrolltext fanno cosi'.

	dc.w	$180,$000	; colori
	dc.w	$182,$111
	dc.w	$184,$233
	dc.w	$186,$555
	dc.w	$188,$778
	dc.w	$18a,$aab
	dc.w	$18c,$fff
	dc.w	$18e,$fff

scol:
	DCB.w	6*64,0		; spazio per le sfumature di colore generate
				; dalla routine "makecolors"

	dc.w	$EE07,$fffe
	dc.w	$180,$004

	dc.w	$184,$023,$186,$118		; Colori piu' "blu"
	dc.w	$188,$25b,$18a,$38e,$18c,$acf

	dc.w	$182,$550	; questa parte di copperlist
	dc.w	$18e,$155	; realizza l'effetto specchio, dovreste sapere
	dc.w	$108,-84	; in che modo!
	dc.w	$10A,-84
	dc.w	$F307,$fffe

	dc.w	$182,$440
	dc.w	$18e,$144
	dc.w	$108,-172
	dc.w	$10A,-172
	dc.w	$108,-84
	dc.w	$10A,-84
	dc.w	$180,$004
	dc.w	$F407,$fffe
	dc.w	$182,$330
	dc.w	$18e,$133
	dc.w	$108,-172
	dc.w	$10A,-172
	dc.w	$180,$005
	dc.w	$F607,$fffe
	dc.w	$182,$220
	dc.w	$18e,$123
	dc.w	$108,-84
	dc.w	$10A,-84
	dc.w	$180,$006
	dc.w	$FA07,$fffe
	dc.w	$182,$110
	dc.w	$18e,$012
	dc.w	$108,-172
	dc.w	$10A,-172
	dc.w	$180,$007
	dc.w	$FD07,$fffe
	dc.w	$182,$110
	dc.w	$18e,$011
	dc.w	$108,-84
	dc.w	$10A,-84
	dc.w	$180,$008
	dc.w	$ffdf,$fffe
	dc.w	$0107,$fffe
	dc.w	$0407,$fffe
	dc.w	$182,$001
	dc.w	$18e,$011
	dc.w	$108,-172
	dc.w	$10A,-172
	dc.w	$180,$009
	dc.w	$0607,$fffe
	dc.w	$182,$002
	dc.w	$18e,$111
	dc.w	$108,-84
	dc.w	$10A,-84
	dc.w	$180,$00A
	dc.w	$0A07,$fffe
	dc.w	$182,$003
	dc.w	$18e,$101
	dc.w	$108,-172
	dc.w	$10A,-172
	dc.w	$180,$00B
	dc.w	$0D07,$fffe
	dc.w	$182,$004
	dc.w	$18e,$202
	dc.w	$108,-84
	dc.w	$10A,-84
	dc.w	$180,$00e

	dc.w	$1307,$fffe
	dc.w	$100,$200	; no bitplanes

	dc.w	$FFFF,$FFFE	; Fine copperlist

;*****************************************************************************

; Ecco il font, che sta in una immagine 320*200 a 3 bitplanes (8 colori)

BigF:
	incbin	"font4"

;*****************************************************************************

	SECTION	BUFY,BSS_C

BITPLANE:
	ds.b	3*44*256	; spazio per 3 bitplanes

	END

In questo listato vediamo un'altro esempio di scrolltext, piu` sofisticato
del precedente.. Si tratta della routine di scroll usata nell'intro AMIGAET
di Fabio Ciucci. In questo programma, lo scrolltext si sposta in alto e in
basso. Per ottenere questo effetto vengono utilizzati 2 buffer per il testo.
Nel primo (invisibile) vengono stampati i caratteri e viene scrollato il testo.
Da qui il testo viene copiato nell'altro buffer (che e` quello visibile) ad
una posizione verticale che varia da un frame all'altro secondo una tabella.
Il secondo buffer non viene mai cancellato perche` durante la copia dal primo
buffer al secondo vengono copiate anche alcune righe "pulite" (azzerate) che
cancellano la parte del vecchio testo che non viene sovrascritta dalla
nuova. Per risparmiare memoria i 2 buffer sono stati riuniti in uno
(all'indirizzo BITPLANE) delle dimensioni di uno schermo 320*256 a 3 planes.
Cio` e` possibile perche` in realta` viene usato uno schermo alto solo 180
linee. Infatti la visualizzazione dei bitplanes viene attivata dalla copperlist
solo a partire dalla linea $A7 del display.
Un' altra particolarita` di questo listato e` che parte della copperlist
viene generata mediante una routine del processore, la "makecolors".
L'argomento delle copperlist generate dal processore (e dal blitter !)
verra` affrontato in una prossima lezione. Per il momento dategli comunque
uno sguardo.

