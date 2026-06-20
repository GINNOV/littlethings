
; Lezione7y4.s	- Paesaggio fatto con 2 soli sprite!!

;       Questo esempio mostra come sia possibile generare una intera 
;	schermata usando direttamente i registri degli sprite


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

	dc.w	$01ba,$0fff		; colore 29
	dc.w	$01bc,$0aaa		; colore 30
	dc.w	$01be,$0753		; colore 31

; per comodita` usiamo dei simboli. Ricordo che si puo' definire un simbolo
; o EQUATE in due modi, e cioe', come in questo caso, ponendo il nome del
; simbolo che vogliamo creare senza spaziature, seguito da un = e dal valore
; che tale simbolo dovra' rappresentare, oppure nella stesso modo, ma con il
; simbolo EQU anziche' l'=.

spr6pos		= $170
spr6data	= $174
spr6datb	= $176
spr7pos		= $178
spr7data	= $17c
spr7datb	= $17e

; linea $50
	dc.w	$5025,$fffe
	dc.w	spr6data,$0,spr6datb,$0,spr7data,$f000,spr7datb,$0
	dc.w	spr6pos,$40,spr7pos,$48,$504b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$505b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$506b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$507b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$508b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$509b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$50ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$50bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$50cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$50db,$fffe

; linea $51
	dc.w	$5125,$fffe
	dc.w	spr6data,$0001,spr6datb,$0000,spr7data,$b800,spr7datb,$4000
	dc.w	spr6pos,$40,spr7pos,$48,$514b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$515b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$516b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$517b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$518b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$519b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$51ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$51bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$51cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$51db,$fffe

; linea $52
	dc.w	$5225,$fffe
	dc.w	spr6data,$0003,spr6datb,$0000,spr7data,$bc00,spr7datb,$4000
	dc.w	spr6pos,$40,spr7pos,$48,$524b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$525b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$526b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$527b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$528b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$529b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$52ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$52bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$52cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$52db,$fffe

; linea $53
	dc.w	$5325,$fffe
	dc.w	spr6data,$0002,spr6datb,$0001,spr7data,$ec00,spr7datb,$1200
	dc.w	spr6pos,$40,spr7pos,$48,$534b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$535b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$536b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$537b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$538b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$539b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$53ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$53bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$53cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$53db,$fffe

; linea $54
	dc.w	$5425,$fffe
	dc.w	spr6data,$0007,spr6datb,$0000,spr7data,$2b00,spr7datb,$d400
	dc.w	spr6pos,$40,spr7pos,$48,$544b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$545b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$546b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$547b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$548b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$549b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$54ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$54bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$54cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$54db,$fffe

; linea $55
	dc.w	$5525,$fffe
	dc.w	spr6data,$001c,spr6datb,$0003,spr7data,$e780,spr7datb,$1800
	dc.w	spr6pos,$40,spr7pos,$48,$554b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$555b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$556b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$557b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$558b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$559b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$55ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$55bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$55cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$55db,$fffe

; linea $56
	dc.w	$5625,$fffe
	dc.w	spr6data,$803e,spr6datb,$0001,spr7data,$9ac1,spr7datb,$6500
	dc.w	spr6pos,$40,spr7pos,$48,$564b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$565b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$566b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$567b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$568b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$569b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$56ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$56bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$56cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$56db,$fffe

; linea $57
	dc.w	$5725,$fffe
	dc.w	spr6data,$c079,spr6datb,$0006,spr7data,$b6e7,spr7datb,$4910
	dc.w	spr6pos,$40,spr7pos,$48,$574b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$575b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$576b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$577b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$578b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$579b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$57ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$57bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$57cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$57db,$fffe

; linea $58
	dc.w	$5825,$fffe
	dc.w	spr6data,$c07f,spr6datb,$0048,spr7data,$fff6,spr7datb,$2009
	dc.w	spr6pos,$40,spr7pos,$48,$584b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$585b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$586b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$587b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$588b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$589b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$58ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$58bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$58cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$58db,$fffe

; linea $59
	dc.w	$5925,$fffe
	dc.w	spr6data,$e06f,spr6datb,$0096,spr7data,$7eaf,spr7datb,$a150
	dc.w	spr6pos,$40,spr7pos,$48,$594b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$595b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$596b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$597b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$598b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$599b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$59ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$59bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$59cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$59db,$fffe

; linea $5a
	dc.w	$5a25,$fffe
	dc.w	spr6data,$61ed,spr6datb,$9013,spr7data,$dfff,spr7datb,$6cab
	dc.w	spr6pos,$40,spr7pos,$48,$5a4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5a5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5a6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5a7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5a8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5a9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5aab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5abb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5acb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5adb,$fffe

; linea $5b
	dc.w	$5b25,$fffe
	dc.w	spr6data,$db9f,spr6datb,$72ed,spr7data,$ffff,spr7datb,$dbee
	dc.w	spr6pos,$40,spr7pos,$48,$5b4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5b5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5b6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5b7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5b8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5b9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5bab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5bbb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5bcb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5bdb,$fffe

; linea $5c
	dc.w	$5c25,$fffe
	dc.w	spr6data,$ffff,spr6datb,$cfbf,spr7data,$ffff,spr7datb,$ff3f
	dc.w	spr6pos,$40,spr7pos,$48,$5c4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5c5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5c6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5c7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5c8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5c9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5cab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5cbb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5ccb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5cdb,$fffe

; linea $5d
	dc.w	$5d25,$fffe
	dc.w	spr6data,$ffff,spr6datb,$ffff,spr7data,$ffff,spr7datb,$feff
	dc.w	spr6pos,$40,spr7pos,$48,$5d4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5d5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5d6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5d7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5d8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5d9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5dab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5dbb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5dcb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5ddb,$fffe

; istruzioni copper per disattivare gli sprite
	dc.w	$5107,$fffe		; aspetta inizio riga
	dc.w	$172,0			; spr6ctl
	dc.w	$17a,0			; spr7ctl

	dc.w	$FFFF,$FFFE	; Fine della copperlist


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

Come vedete e` possibile visualizzare anche piu` di 2 volte uno sprite sulla
stessa riga, a patto che si sappia programmare in assembler.
In questo esempio usiamo 2 sprite (6 e 7) visualizzandoli 10 volte ciascuno per
linea, per un totale di 16*20=320 pixel per riga.
In pratica copriamo tutto lo schermo. L'idea e` la stessa dell'esempio
precedente, cioe` di cambiare i valori dei registri degli sprite con il
copper. Questa volta pero` oltre a cambiare la posizione cambiamo ad ogni
riga anche la forma degli sprite modificando i valori dei registri SPRxDATA
e SPRxDATB, in modo da formare un paesaggio. Per semplicita` il nostro
paesaggio e` alto 14 righe, ma si potrebbe riempire lo schermo!
Ogni linea della copperlist e` fatta in questo modo:

; linea $50
	dc.w	$5025,$fffe
	dc.w	spr6data,$0,spr6datb,$0,spr7data,$f000,spr7datb,$0
	dc.w	spr6pos,$40,spr7pos,$48,$504b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$505b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$506b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$507b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$508b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$509b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$50ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$50bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$50cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$50db,$fffe

In questo caso abbiamo preso la parte di copperlist relativa alla riga $50.
Vediamo il significato di tutte le istruzioni:

	dc.w	$5025,$fffe	; WAIT

La prima istruzione serve ad attendere che il pennello elettronico raggiunga
la posizione orizzontale $25 della riga attuale.

	dc.w	spr6data,$0,spr6datb,$0,spr7data,$f000,spr7datb,$0

Queste istruzioni sevono a settare per questa riga i valori dei registri DATA
che determinano la forma dello sprite.

	dc.w	spr6pos,$40,spr7pos,$48,$504b,$fffe

queste istruzioni servono per cambiare le posizioni degli sprite.
Lavorano come nell'esempio precedente. Prima vengono aggiornate le posizioni
degli sprite, e poi si attende che i 2 sprite vengano visualizzati.
A questo punto si ripetono 10 gruppi di istruzioni copper come questo, che a
loro volta modificano le posizioni degli sprite e attendono con dei WAIT che
distanziano di 16 pixel orizzontali ($4b, $5b, $6b...) gli sprite visualzzati.
Per es. troviamo

	dc.w	spr6pos,$50,spr7pos,$58,$505b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$506b,$fffe

Dividiamo una linea nei 3 comandi che contiene:

	dc.w	spr6pos,$50	; determina la posizione dello sprite6
	dc.w	spr7pos,$58	; determina la posizione dello sprite7
	dc.w	$505b,$fffe	; WAIT - attendi 16 pixel piu' avanti.

e cosi` via.
Dopo 10 gruppi cosi` abbiamo disegnato tutta una riga. A questo punto non ci
resta che ripetere tutto quello che abbiamo fatto per la riga $50 anche per
tutte le altre righe del paesaggio. Ovviamente per ogni riga avremo un
diverso valore nei registri SPRxDATx che determinera` una diversa forma per
lo sprite.

Naturalmente per generare copperlist cosi' lunghe e complesse vengono scritte
apposite routine "GeneraCopperlist", che pero' per la loro complessita' non
sono ancora state inserite nel corso. L'importante in questo listato e' capire
il meccanismo del riutilizzo degli sprite agendo direttamente sui registri con
la copperlist.



