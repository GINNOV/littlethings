
; Lezione10c3.s	Effetto riflettore
;		Tasto sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#FIGURA,d0	; punta la figura
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#3-1,D1		; numero di bitplanes
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

	move.l	#BITPLANE4,d0	; punta il bitplane dove viene disegnata
	move.w	d0,6(a1)	; la maschera
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse2:

Loop:
	cmp.b	#$ff,$6(a5)	; VHPOSR - aspetta la linea $ff
	bne.s	loop
Aspetta:
	cmp.b	#$ff,$6(a5)	; ancora linea $ff?
	beq.s	Aspetta

	bsr.s	ClearScreen	; pulisci schermo
	bsr.w	SpostaMaschera	; sposta posizione riflettore
	bsr.s	Riflettore	; routine effetto

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts

;***************************************************************************
; Questa routine cancella la porzione di schermo interessata dalla blittata
;***************************************************************************

ClearScreen:
	lea	BITPLANE4+100*40,a1	; indirizzo zona da cancellare (plane4)

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$01000000,$40(a5)	; BLTCON0 + BLTCON1. Cancellazone
	move.w	#$0000,$66(a5)
	move.l	a1,$54(a5)
	move.w	#(64*39)+20,$58(a5)
	rts

;*****************************************************************************
; Questa routine realizza l'effetto riflettore. 
; Semplicemente la maschera viene disegnata sul bitplane 4
;*****************************************************************************

;	      ___________
;	     /           \
;	    /\            \
;	   / /\____________)____
;	   \/:/\___   ___/\     \
;	    \/ ___ \_/ ___ \     \
;	    ( /  o)   (  o\ )____/
;	     \\__/ /Y\ \__//
;	     (___/(_n_)\___)
;	   __//\ _ _ _ _ /\\__
;	  /==\\_Y Y Y Y Y_//==\
;	 /    `-| | | | |-'    \
;	/       `-^-^-^-'       \

Riflettore:
	lea	BITPLANE4+100*40,a1	; ind. destinazione

	move.w	MascheraX(PC),d0 ; posizione riflettore
	move.w	d0,d2		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	or.w	#$09F0,d0	; ...giusti per inserirsi nel registro BLTCON0
				; notate LF=$F0 (cioe` copia A in D)
	lsr.w	#3,d2		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d2	; escludo il bit 0 del
	add.w	d2,a1		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; maschere
	move.w	d0,$40(a5)		; BLTCON0
	move.w	#$0000,$42(a5)		; BLTCON1 modo ascendente
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#32,$66(a5)		; BLTDMOD (40-8=32)

	move.l	#Maschera,$50(a5)	; BLTAPT  puntatore sorgente
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*39)+4,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 4 word
					; altezza 39 linee

	rts

;*****************************************************************************
; Questa routine legge la coordinata orizzontale da una tabella
; e la memorizza nella variabile MASCHERAX
;*****************************************************************************

SpostaMaschera:
	ADDQ.L	#2,TABXPOINT		; Fai puntare alla word successiva
	MOVE.L	TABXPOINT(PC),A0	; indirizzo contenuto in long TABXPOINT
					; copiato in a0
	CMP.L	#FINETABX-2,A0  	; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTX		; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT 	; Riparti a puntare dalla prima word-2
NOBSTARTX:
	MOVE.W	(A0),MascheraX		; copia il valore nella variabile
	rts

MascheraX:
		dc.w	0	; posizione attuale maschera
TABXPOINT:
		dc.l	TABX	; puntatore alla tabella

; tabella posizioni maschera

TABX:
	DC.W	$12,$16,$19,$1D,$21,$25,$28,$2C,$30,$34
	DC.W	$37,$3B,$3F,$43,$46,$4A,$4E,$51,$55,$58
	DC.W	$5C,$60,$63,$67,$6A,$6E,$71,$74,$78,$7B
	DC.W	$7F,$82,$85,$89,$8C,$8F,$92,$95,$98,$9C
	DC.W	$9F,$A2,$A5,$A8,$AA,$AD,$B0,$B3,$B6,$B8
	DC.W	$BB,$BE,$C0,$C3,$C5,$C8,$CA,$CC,$CF,$D1
	DC.W	$D3,$D5,$D8,$DA,$DC,$DE,$E0,$E1,$E3,$E5
	DC.W	$E7,$E8,$EA,$EC,$ED,$EE,$F0,$F1,$F2,$F4
	DC.W	$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FB,$FC,$FD
	DC.W	$FD,$FE,$FE,$FF,$FF,$FF,$100,$100,$100,$100
	DC.W	$100,$100,$100,$100,$FF,$FF,$FF,$FE,$FE,$FD
	DC.W	$FD,$FC,$FB,$FB,$FA,$F9,$F8,$F7,$F6,$F5
	DC.W	$F4,$F2,$F1,$F0,$EE,$ED,$EC,$EA,$E8,$E7
	DC.W	$E5,$E3,$E1,$E0,$DE,$DC,$DA,$D8,$D5,$D3
	DC.W	$D1,$CF,$CC,$CA,$C8,$C5,$C3,$C0,$BE,$BB
	DC.W	$B8,$B6,$B3,$B0,$AD,$AA,$A8,$A5,$A2,$9F
	DC.W	$9C,$98,$95,$92,$8F,$8C,$89,$85,$82,$7F
	DC.W	$7B,$78,$74,$71,$6E,$6A,$67,$63,$60,$5C
	DC.W	$58,$55,$51,$4E,$4A,$46,$43,$3F,$3B,$37
	DC.W	$34,$30,$2C,$28,$25,$21,$1D,$19,$16,$12
FINETABX:

;*****************************************************************************

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

	dc.w	$100,$4200	; bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000
	dc.w $ec,$0000,$ee,$0000

Colours:
	dc.w	$0180,$000	; colori da 0-7 tutti scuri. In questo modo
				; le parti della figura in corrispondenza delle
				; quali la maschera non e` disegnata sono
				; colorate in modo piu' scuro
	dc.w	$0182,$011	; color1
	dc.w	$0184,$223	; color2
	dc.w	$0186,$122	; color3
	dc.w	$0188,$112	; color4
	dc.w	$018a,$011	; color5
	dc.w	$018c,$112	; color6
	dc.w	$018e,$011	; color7

	dc.w	$0190,$000	; colori 8-15 contengono la palette
	dc.w	$0192,$475
	dc.w	$0194,$fff
	dc.w	$0196,$ccc
	dc.w	$0198,$999
	dc.w	$019a,$232
	dc.w	$019c,$777
	dc.w	$019e,$444

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;*****************************************************************************

; qui c'e` il disegno, largo 320 pixel, alto 256 linee e formato da 3 plane

Figura:
	incbin	"amiga.raw"

;*****************************************************************************

; Questa e` la maschera. E` una figura formata da un solo bitplane,
; alta 39 linee e larga 4 words

Maschera:
	dc.l	$00007fc0,$00000000,$0003fff8,$00000000,$000ffffe,$00000000
	dc.l	$001fffff,$00000000,$007fffff,$c0000000,$00ffffff,$e0000000
	dc.l	$01ffffff,$f0000000,$03ffffff,$f8000000,$03ffffff,$f8000000
	dc.l	$07ffffff,$fc000000,$0fffffff,$fe000000,$0fffffff,$fe000000
	dc.l	$1fffffff,$ff000000,$1fffffff,$ff000000,$1fffffff,$ff000000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$1fffffff,$ff000000,$1fffffff,$ff000000,$1fffffff,$ff000000
	dc.l	$0fffffff,$fe000000,$0fffffff,$fe000000,$07ffffff,$fc000000
	dc.l	$03ffffff,$f8000000,$03ffffff,$f8000000,$01ffffff,$f0000000
	dc.l	$00ffffff,$e0000000,$007fffff,$c0000000,$001fffff,$00000000
	dc.l	$000ffffe,$00000000,$0003fff8,$00000000,$00007fc0,$00000000
	
;*****************************************************************************

; qui c'e` il quarto bitplane, dove viene disegnata la maschera.

	SECTION	bitplane,BSS_C
BITPLANE4:
	ds.b	40*256

	end

;*****************************************************************************

In questo esempio realizziamo un effetto "riflettore" con l'ausilio di un
bitplane maschera. La tecnica e` la seguente. Abbiamo un disegno costituito
da 3 bitplanes larghi 320 pixel e alti 256 linee. Per realizzare l'effetto,
utilizziamo una "maschera", ovvero un disegno di un cerchio formato da 1 solo
bitplane. Questa maschera viene disegnata e spostata su un quarto bitplane,
come se fosse un bob. Siccome viene disegnata su un bitplane separato dalla
figura, non dobbiamo preoccuparci dello sfondo. Si tratta sostanzialmente
dello stesso trucco adottato in lezione9i4.s, l'esempio del bob con lo sfondo
finto. Stavolta pero`, per realizzare l'effetto riflettore, settiamo
diversamente i colori nei registri: la palette della figura a 3 colori,
cioe` i valori che normalmente scriveremmo nei registri COLOR00-COLOR07,
vengono scritti stavolta nei registri COLOR08-COLOR15. Invece, i registri
COLOR00-COLOR07 vengono tutti settati come piu' scuri (o neri). In questo modo,
i pixel dell'immagine in corrispondenza dei quali il quarto bitplane e` settato
a 0 appaiono tutti piu' scuri (avremmo potuto anche annerirli tutti); al
contrario, i pixel dell'immagine in corrispondenza dei quali il quarto
bitplane e` settato a 1 ( cioe` in corrispondenza della maschera) appaiono
con i giusti colori.
Questa tecnica e` molto veloce ma, analogamente all'esempio lezione9i4.s, ha
uno svantaggio: utiliziamo 4 bitplane per un'immagine ad 8 colori.
Nel prossimo esempio vedremo come evitare questo problema.
