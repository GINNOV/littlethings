
; Lezione9f1.s	BLITTATA, in cui copiamo un rettangolo da un punto
;		all'altro dello stesso schermo
;		Tasto sinistro per eseguire la blittata, destro per uscire.

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
	MOVEQ	#3-1,D1		; numero di bitplanes (qua sono 3)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1		; se no, non cancellare

	bsr.s	copia		; esegui la routine di copia

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts

; ************************ LA ROUTINE DI COPIA ****************************

 ; viene copiato un rettangolo con larghezza=160 e altezza=20
 ; dalle coordinate X1=64, Y1=50 (sorgente)
 ; alle coordinate X2=80, Y2=190 (destinazione)

;	   .  , _ .
;	   ¦\_|/_/l
;	  /¯/¬\/¬\¯\
;	 /_( ©( ® )_\
;	l/_¯\_/\_/¯_\\
;	/ T (____) T \\
;	\/\___/\__/  //
;	(_/  __     T|
;	 l  (. )    |l\
;	  \  ¯¯    // /
;	   \______//¯¯
;	  __Tl___Tl xCz
;	 C____(____)

copia:

; Carica gli indirizzi sorgente e destinazione in 2 variabili

	move.l	#bitplane+((20*50)+64/16)*2,d0	; indirizzo sorgente
	move.l	#bitplane+((20*190)+80/16)*2,d2	; indirizzo destinazione

				; Loop di blittate
	moveq	#3-1,d1		; ripeti per tutti i bit-planes
copia_loop:
	btst	#6,2(a5)	; aspetta che il blitter finisca
waitblit:
	btst	#6,2(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; bltcon0 e BLTCON1 - copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

; carica i puntatori

	move.l	d0,$50(a5)	; bltapt
	move.l	d2,$54(a5)	; bltdpt

; Queste 2 istruzioni settano i moduli della sorgente e della destinazione
; notate che poiche` sorgente e destinazione sono all'interno dello stesso
; schermo il modulo e` lo stesso.
; il modulo e` calcolato secondo la formula (H-L)*2  (H e` la larghezza del
; bitplane in words e L e` la larghezza dell'immagine, sempre in words)
; che abbiamo visto a lezione, (20-160/16)*2=20

	move.w	#(20-160/16)*2,$64(a5)	; bltamod
	move.w	#(20-160/16)*2,$66(a5)	; bltdmod

; Notate anche che poiche` i 2 registri hanno indirizzi consecutivi, si puo`
; usare una sola istruzione invece che 2 (ricordate che 20=$14):
; move.l #$00140014,$64(a5)	; bltamod e bltdmod 

	move.w	#(20*64)+160/16,$58(a5)		; bltsize
						; altezza 20 linee
						; largo 160 pixel (= 10 words)
						
; Aggiorna le variabili contenenti gli indirizzi per farle puntare
; ai bitplanes seguenti 

	add.l	#40*256,d2	; indirizzo destinazione prossimo plane 
	add.l	#40*256,d0	; indirizzo sorgente prossimo plane

	dbra	d1,copia_loop

	btst	#6,$02(a5)	; aspetta che il blitter finisca
waitblit2:
	btst	#6,$02(a5)
	bne.s	waitblit2
	rts

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$3200	; bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

BITPLANE:
	incbin	"assembler2:sorgenti6/amiga.raw"	; qua carichiamo la figura

	end

;****************************************************************************

In questo esempio copiamo con il blitter un'immagine formata da 3 bitplanes.
Notate come e` strutturato il loop nel quale vengono eseguite le blittate.
Gli indirizzi sorgente e destinazione vengono caricati in 2 registri dati
del processore che vengono usati come variabili. Ad ogni iterazione vengono
modificati per puntare al bit-plane seguente. Per questo viene usata la formula

INDIRIZZO2 = INDIRIZZO1+2*H*V

che avevamo visto a lezione. Nel nostro esempio, V=256 (il numero di righe)
e H=20 (la larghezza dello schermo in words).

In questo esempio la sorgente e la destinazione della blittata sono contenute
nello stesso schermo. Per questo motivo il modulo e` uguale per entrambe,
ed e` calcolato secondo la solita formula.

