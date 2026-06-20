
; Lezione7y3.s	DUE UTILIZZI DI UNO SPRITE SULLA STESSA RIGA

;       Questo esempio mostra come sia possibile riutilizzare uno sprite
;       2 volte su una stessa riga accedendo direttamente ai registri


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	NON Puntiamo lo sprite !!!!!!!!!!!!!!!!!!!!

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
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


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
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
	dc.w	$100,%0001001000000000	; bit 12 acceso!! 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1A2,$FF0	; color17, ossia COLOR1 dello sprite0 - GIALLO
	dc.w	$1A4,$a00	; color18, ossia COLOR2 dello sprite0 - ROSSO
	dc.w	$1A6,$F70	; color19, ossia COLOR3 dello sprite0 - ARANCIO

; ---> inserite qua il pezzo di copperlist riportato in fondo al commento

	dc.w	$4007,$fffe	; aspetta la linea $40, posizione orizz. 7
	dc.w	$140,$0060	; SPR0POS - posizione orizzontale
	dc.w	$142,$0000	; SPR0CTL
	dc.w	$146,$0e70	; SPR0DATB
	dc.w	$144,$03c0	; SPR0DATA - attiva lo sprite

	dc.w	$4087,$fffe	; aspetta la linea $40, posizione orizz. 87
	dc.w	$140,$00a0	; SPR0POS - posizione orizzontale

; lo stesso per la linea $41
	dc.w	$4107,$fffe	; wait pos. orizzontale 07
	dc.w	$140,$0060	; spr0pos

	dc.w	$4187,$fffe	; wait pos. orizzontale 87
	dc.w	$140,$00a0	; spr0pos

; lo stesso per la linea $42
	dc.w	$4207,$fffe	; wait
	dc.w	$140,$0060	; spr0pos

	dc.w	$4287,$fffe	; wait... eccetera
	dc.w	$140,$00a0

; lo stesso per la linea $43
	dc.w	$4307,$fffe
	dc.w	$140,$0060

	dc.w	$4387,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $44
	dc.w	$4407,$fffe
	dc.w	$140,$0060

	dc.w	$4487,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $45
	dc.w	$4507,$fffe
	dc.w	$140,$0060

	dc.w	$4587,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $46
	dc.w	$4607,$fffe
	dc.w	$140,$0060

	dc.w	$4687,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $47
	dc.w	$4707,$fffe
	dc.w	$140,$0060

	dc.w	$4787,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $48
	dc.w	$4807,$fffe
	dc.w	$140,$0060

	dc.w	$4887,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $49
	dc.w	$4907,$fffe
	dc.w	$140,$0060

	dc.w	$4987,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $4a
	dc.w	$4a07,$fffe
	dc.w	$140,$0060

	dc.w	$4a87,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $4b
	dc.w	$4b07,$fffe
	dc.w	$140,$0060

	dc.w	$4b87,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $4c
	dc.w	$4c07,$fffe
	dc.w	$140,$0060

	dc.w	$4c87,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $4d
	dc.w	$4d07,$fffe
	dc.w	$140,$0060

	dc.w	$4d87,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $4e
	dc.w	$4e07,$fffe
	dc.w	$140,$0060

	dc.w	$4e87,$fffe
	dc.w	$140,$00a0

; lo stesso per la linea $4f
	dc.w	$4f07,$fffe
	dc.w	$140,$0060

	dc.w	$4f87,$fffe
	dc.w	$140,$00a0

	dc.w	$5007,$fffe	; aspetta la linea $50
	dc.w	$142,$0000	; SPR0CTL - "spegne" lo sprite

	dc.w	$FFFF,$FFFE	; Fine della copperlist



	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

Manipolare direttamente i registri rende anche possibile disegnare uno sprite
due volte sulla stessa riga, ovvero disegnarlo in due diverse posizioni
orizzontali. Il trucco fa uso del copper e della sua capacita` di aspettare
che il pennello elettronico abbia raggiunto una determinata posizione sul
video. All'inizio si aspetta con il copper la prima riga dello schermo in cui
si vuole disegnare lo sprite. Nell'esempio aspettiamo la riga $40 mettendo
nella copperlist:

	dc.w	$4007,$fffe	; aspetta la linea $40, posizione orizz. 7

 Poi si caricano i registri SPR0CTL, SPRDATB e SPRDAT:

	dc.w	$142,$0000	; SPR0CTL
	dc.w	$146,$0e70	; SPR0DATB
	dc.w	$144,$03c0	; SPR0DATA - attiva lo sprite

E si mette il primo valore della posizione orizzontale in SPRxPOS:

	dc.w	$140,$0060	; SPR0POS - posizione orizzontale

A questo punto si aspetta che il pennello elettronico superi questa posizione
orizzontale, in modo che lo sprite venga disegnato.

	dc.w	$4087,$fffe	; aspetta la linea $40, posizione orizz. 87

Nell'esempio la posizione orizzontale dello sprite e` $60. Aspettando
la posizione $87 siamo abbondantemente sicuri che lo sprite e` stato
disegnato. Infatti quando il pennello elettronico ha superato la posizione
orizzontale, lo sprite e` stato effettivamente disegnato.

Una volta avvenuto cio`, si scrive la seconda posizione orizzontale
in SPRxPOS.

	dc.w	$140,$00a0	; SPR0POS - posizione orizzontale

In questo modo lo sprite verra` disegnato anche nella seconda
posizione orizzontale. A questo punto abbiamo disegnato 2 volte lo stesso
sprite su una riga. Per disegnare i 2 sprite sulle righe seguenti,
e` sufficente ripetere tutti i passi fin qui descritti.
Per esempio per la riga $41 scriviamo

; lo stesso per la linea $41
	dc.w	$4107,$fffe
	dc.w	$140,$0060

	dc.w	$4187,$fffe
	dc.w	$140,$00a0

che e` la stessa cosa della riga $40, solo che teniamo costanti SPR0DATA
SPR0DATB e SPR0CTL in modo da tenere costante la forma dello sprite.
Volendo si possono variare questi registri per cambiare la forma dello sprite
tra una riga e l'altra.

Per disabilitare gli sprite basta scrivere un qualsiasi valore in 
SPL0CTL, in questo modo:

	dc.w	$5007,$fffe	; aspetta la linea $50
	dc.w	$142,$0000	; SPR0CTL - "spegne" lo sprite


Se proprio voleste esagerare, potete anche cambiare la palette orizzontalmente
tra la prima barra e la seconda, in modo da avere riutilizzi sulla stessa
linea anche di colore diverso. Provate ad inserire questa copperlist nel
punto indicato con:

; ---> inserite qua il pezzo di copperlist riportato in fondo al commento

Nella copperlist del listato. In pratica sostituiamo la parte finale che si
occupa di visualizzare lo sprite. (Amiga+b+c+i per copiare il testo)


	dc.w	$4007,$fffe	; aspetta la linea $40, posizione orizz. 7
	dc.w	$140,$0060	; SPR0POS - posizione orizzontale
	dc.w	$142,$0000	; SPR0CTL
	dc.w	$146,$0e70	; SPR0DATB
	dc.w	$144,$03c0	; SPR0DATA - attiva lo sprite

	dc.w	$4087,$fffe	; aspetta la linea $40, posizione orizz. 87
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$140,$00a0	; SPR0POS - posizione orizzontale

; linea $41
	dc.w	$4107,$fffe	; wait pos. orizzontale 07
	dc.w	$1A2,$FF0	; color17	; tono arancio
	dc.w	$1A4,$a00	; color18
	dc.w	$1A6,$F70	; color19
	dc.w	$140,$0060	; spr0pos
	dc.w	$4187,$fffe	; wait pos. orizzontale 87
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$140,$00a0	; spr0pos
; linea $42
	dc.w	$4207,$fffe	; wait pos. orizzontale 07
	dc.w	$1A2,$FF0	; color17	; tono arancio
	dc.w	$1A4,$a00	; color18
	dc.w	$1A6,$F70	; color19
	dc.w	$140,$0060	; spr0pos
	dc.w	$4287,$fffe	; wait pos. orizzontale 87
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$140,$00a0	; spr0pos
; linea $43
	dc.w	$4307,$fffe	; wait pos. orizzontale 07
	dc.w	$1A2,$FF0	; color17	; tono arancio
	dc.w	$1A4,$a00	; color18
	dc.w	$1A6,$F70	; color19
	dc.w	$140,$0060	; spr0pos
	dc.w	$4387,$fffe	; wait pos. orizzontale 87
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$140,$00a0	; spr0pos
; linea $44
	dc.w	$4407,$fffe	; wait pos. orizzontale 07
	dc.w	$1A2,$FF0	; color17	; tono arancio
	dc.w	$1A4,$a00	; color18
	dc.w	$1A6,$F70	; color19
	dc.w	$140,$0060	; spr0pos
	dc.w	$4487,$fffe	; wait pos. orizzontale 87
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$140,$00a0	; spr0pos
; linea $45
	dc.w	$4507,$fffe	; wait pos. orizzontale 07
	dc.w	$1A2,$FF0	; color17	; tono arancio
	dc.w	$1A4,$a00	; color18
	dc.w	$1A6,$F70	; color19
	dc.w	$140,$0060	; spr0pos
	dc.w	$4587,$fffe	; wait pos. orizzontale 87
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$140,$00a0	; spr0pos

	dc.w	$4607,$fffe	; aspetta la linea $46
	dc.w	$142,$0000	; SPR0CTL - "spegne" lo sprite
	dc.w	$ffff,$fffe	; fine copperlist

