
; Lezione9n1.s	Signore e signori, lo SCROLLTEXT!!!!!
;		Tasto sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP

	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	lea	testo(pc),a0		; punta al testo dello scrolltext

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

	bsr.s	printchar		; routine che stampa i nuovi chars
	bsr.s	Scorri			; esegui la routine di scorrimento

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse2:
	rts

;****************************************************************************
; Questa routine stampa un carattere. Il carattere viene stampato in una
; parte di schermo invisibile.
; A0 punta al testo da stampare.
;****************************************************************************

PRINTCHAR:
	subq.w	#1,contatore	; diminuisci il contatore di 1
	bne.s	NoPrint		; se e` diverso da 0, non stampiamo,
	move.w	#16,contatore	; altrimenti si; reinizializza il contatore

	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	bne.s	noreset		; Se e` diverso da 0 stampalo,
	lea	testo(pc),a0	; altrimenti ricomincia il testo daccapo
	MOVE.B	(A0)+,D2	; Primo carattere in d2
noreset
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	ADD.L	D2,D2		; MOLTIPLICA PER 2 IL NUMERO PRECEDENTE,
				; perche` ogni carattere e` largo 16 pixel
	MOVE.L	D2,A2

	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	btst	#6,$02(a5)	; aspetta che il blitter finisca
waitblit:
	btst	#6,$02(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0: copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

	move.l	a2,$50(a5)			; BLTAPT: indirizzo font
	move.l	#bitplane+50*42+40,$54(a5)	; BLTDPT: indirizzo bitplane
						; fisso, fuori dalla parte
						; visibile dello schermo.
	move	#120-2,$64(a5)			; BLTAMOD: modulo font
	move	#42-2,$66(a5)			; BLTDMOD: modulo bit planes
	move	#(20<<6)+1,$58(a5) 		; BLTSIZE: font 16*20
NoPrint:
	rts

contatore
	dc.w	16

;****************************************************************************
; Questa routine fa scorrere il testo verso sinistra
;****************************************************************************

;	                            :
;	                            .
;	
;	        . · ·. ¦:.:.:.:.:.:.¦  . · .     . · .
;	    ° ·       ·|            |.·     . . ·     ·
;	       . ··.   |        __  |                  ·
;	     ·      ·. |       /  ` |     .··.          °
;	  ·            | ,___   ___ |   .·    ·
;	°              | ____  /   \|  ·       .
;	         .···. l/   o\/°   /l
;	        °     (¯\____/\___/ ¯)          °
;	               T   (____)   T
;	               l            j xCz
;	                \___ O ____/
;	                   `---'

Scorri:

; Gli indirizzi sorgente e destinazione sono uguali.
; Shiftiamo verso sinistra, quindi usiamo il modo discendente.

	move.l	#bitplane+((21*(50+20))-1)*2,d0		; ind. sorgente e
							; destinazione
ScorriLoop:
	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit2:
	btst	#6,2(a5)
	bne.s	waitblit2

	move.l	#$19f00002,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D
					; con shift di un pixel

	move.l	#$ffff7fff,$44(a5)	; BLTAFWM e BLTALWM
					; BLTAFWM = $ffff - passa tutto
					; BLTALWM = $7fff = %0111111111111111
					;   cancella il bit piu` a sinistra

; carica i puntatori

	move.l	d0,$50(a5)			; bltapt - sorgente
	move.l	d0,$54(a5)			; bltdpt - destinazione

; facciamo scorrere un immagine larga tutto lo schermo, quindi
; il modulo e` azzerato.

	move.l	#$00000000,$64(a5)		; bltamod e bltdmod 
	move.w	#(20*64)+21,$58(a5)		; bltsize
						; altezza 20 linee, largo 21
	rts					; words (tutto lo schermo)

; Questo e` il testo. con lo 0 si termina. Il font usato ha solo i caratteri
; maiuscoli, attenzione!

testo:
	dc.b	"ECCO FINALMENTE LO SCROLLTEXT, CHE TUTTI STAVANO"
	dc.b	" ASPETTANDO... IL FONT E' DI 16*20 PIXEL!..."
	dc.b	" LO SCROLL AVVIENE CON TRANQUILLITA'...",0


;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2

	dc.w	$108,2		; Il bitplane e` largo 42 bytes, ma solo 40
				; bytes sono visibili, quindi il modulo
				; vale 42-40=2
;	dc.w	$10a,2		; Usiamo un solo bitplane, quindi BPLMOD2
				; non e` necessario

	dc.w	$100,$1200	; bplcon0 - 1 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0

; queste istruzioni della copperlist cambiano il colore 1 ogni 2 righe

	dc.w	$5e01,$fffe	; prima riga scrolltext
	dc.w	$0182,$f50	; color1
	dc.w	$6001,$fffe
	dc.w	$0182,$d90
	dc.w	$6201,$fffe
	dc.w	$0182,$dd0
	dc.w	$6401,$fffe
	dc.w	$0182,$5d2
	dc.w	$6601,$fffe
	dc.w	$0182,$2f4
	dc.w	$6801,$fffe
	dc.w	$0182,$0d7
	dc.w	$6a01,$fffe
	dc.w	$0182,$0dd
	dc.w	$6c01,$fffe
	dc.w	$0182,$07d
	dc.w	$6e01,$fffe
	dc.w	$0182,$22f
	dc.w	$7001,$fffe
	dc.w	$0182,$40d
	dc.w	$7201,$fffe
	dc.w	$0182,$80d

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Qui e` memorizzato il FONT di caratteri 16x20

FONT:
	incbin	"assembler2:sorgenti6/font16x20.raw"

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C

BITPLANE:
	ds.b	42*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio presentiamo uno degli effetti piu` classici delle demo:
lo scrolltext. Si tratta di un testo che scorre sullo schermo da destra
verso sinistra, e che di solito contiene i saluti (greeetings) mandati
dagli autori della demo agli altri demo-coders. Come si realizza uno
scrolltext? Si potrebbe pensare di stampare tutto il testo su un bitplane
piu` grande dello schermo visibile e poi scrollare il bitplane. Questa
tecnica ha lo svantaggio di occupare molta memoria, perche` ha bisogno
di un bitplane che contenga tutto il testo.
Noi usiamo un'altra tecnica basata sul blitter, per la quale basta disporre
di un bitplane largo appena 16 pixel (1 word) in piu` dell'area visibile.
Abbiamo dunque una colonna di una word invisibile alla destra dello schermo.
Supponiamo di stampare un carattere nella parte invisibile del bitplane, e
contemporaneamente di far scorrere verso sinistra il bitplane mediante il
blitter. Accade, come potete immaginare, che il carattere si sposti un pixel
alla volta verso sinistra.
Notate che i puntatori ai bitplane rimangono sempre fissi.
Quando il carattere e` completamente visiblie, il che accade dopo 16
shiftate di 1 pixel, essendo il carattere largo 16 pixel, possiamo stampare
il carattere successivo nella parte invisibile dello schermo.
I caratteri che arrivano al bordo sinistro vengono cancellati dalla maschera
del blitter.
In pratica l'effetto e` ottenuto usando 2 routine.
La prima "Printchar" si occupa di stampare i caratteri sullo schermo.
La stampa deve avvenire solo quando il carattere precedentemente stampato e`
diventato completamente visibile, in modo da evitare di sovrapporre i 2
caratteri.
Siccome ogni carattere e` largo 16 pixel, e il testo scorre un pixel alla
volta, in  sostanza la stampa deve avvenire ogni 16 volte che la routine viene
chiamata.
Per questo viene usato un contatore che viene decrementato ad ogni chiamata.
Quando esso assume il valore 0 il carattere viene stampato, e il contatore
reinizializzato a 16. La stampa vera e propria e` una semplice copia con il
blitter (usato in modo ascendente) fatta nella maniera che conosciamo.
La routine "Scorri" e` incaricata di far scorrere il testo usando lo shift
del blitter verso sinistra (cioe` in modo discendente) nel modo che abbiamo
visto nell' esempio lezione9m2.s. Poiche` i caratteri sono alti 20 righe,
tutto il testo occupa una "fascia" di schermo alta 20 righe.
E` necessario far scorrere tutta questa "fascia", ovvero un rettangolo alto 20
righe e largo quanto tutto il bitplane (compresa naturalmente la parte
INVISIBILE, in modo da far scorrere i caratteri nella parte visibile).
La maschera dell'ultima word provvede a cancellare i caratteri che raggiungono
il bordo sinistro.
Abbiamo usato uno schermo formato da 1 bitplane, e i colori sono ottenuti
tramite il copper (altrimenti che furbi saremmo?).

