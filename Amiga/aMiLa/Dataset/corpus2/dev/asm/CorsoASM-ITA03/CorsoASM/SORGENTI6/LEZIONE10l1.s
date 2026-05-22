
; Lezione10l1.s	Animazione ciclica con il blitter
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
	MOVEQ	#2-1,D1		; numero di bitplanes
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

mouse:

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.S	Waity1

	bsr.s	Animazione	; sposta i fotogrammi nella tabella
	move.l	Frametab(pc),a0	; Disegna il primo frame della tabella	
	bsr.s	DisegnaFrame	; disegna il frame

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse
	rts


;****************************************************************************
; Questa routine crea l'animazione, spostando gli indirizzi dei fotogrammi
; in maniera che ogni volta il primo della tabella vada all'ultimo posto,
; mentra gli altri scorrono tutti di un posto in direzione del primo
;****************************************************************************

Animazione:
	addq.b	#1,ContaAnim    ; queste tre istruzioni fanno si' che il
	cmp.b	#4,ContaAnim    ; fotogramma venga cambiato una volta
	bne.s	NonCambiare     ; si e 3 no.
	clr.b	ContaAnim
	LEA	FRAMETAB(PC),a0 ; tabella dei fotogrammi
	MOVE.L	(a0),d0		; salva il primo indirizzo in d0
	MOVE.L	4(a0),(a0)	; sposta indietro gli altri 7 indirizzi
	MOVE.L	4*2(a0),4(a0)	; Queste istruzioni "ruotano" gli indirizzi
	MOVE.L	4*3(a0),4*2(a0) ; della tabella.
	MOVE.L	4*4(a0),4*3(a0)
	MOVE.L	4*5(a0),4*4(a0)
	MOVE.L	4*6(a0),4*5(a0)
	MOVE.L	4*7(a0),4*6(a0)
	MOVE.L	d0,4*7(a0)	; metti l'ex primo indirizzo all'ottavo posto

NonCambiare:
	rts

ContaAnim:
	dc.w	0

; Questa e` la tabella degli indirizzi dei fotogrammi. Gli indirizzi
; presenti nella tabella vengono "ruotati" all'interno della tabella dalla
; routine Animazione, in modo che il primo nella lista sia la prima volta il
; fotogramma1, la volta dopo il Fotogramma2, poi il 3,4,5,6,7,8 e di nuovo il
; primo, ciclicamente. In questo modo basta prendere l'indirizzo che sta
; all'inizio della tabella ogni volta dopo il "rimescolamento" per avere gli
; indirizzi dei fotogrammi in sequenza.

FRAMETAB:
	DC.L	Frame1
	DC.L	Frame2
	DC.L	Frame3
	DC.L	Frame4
	DC.L	Frame5
	DC.L	Frame6
	DC.L	Frame7
	DC.L	Frame8


;****************************************************************************
; Questa routine copia un frame di animazione sullo schermo.
; la posizione sullo schermo e le dimensioni dei frames sono costanti
; A0 - indirizzo sorgente
;****************************************************************************

;	           ,-~~-.___.
;	          / ()=(()   \
;	         (  |         0
;	          \_,\, ,----'
;	     ##XXXxxxxxxx
;	            /  ---'~;
;	           /    /~|-
;	         =(   ~~  |
;	   /~~~~~~~~~~~~~~~~~~~~~\
;	  /_______________________\
;	 /_________________________\
;	/___________________________\
;	   |____________________|
;	   |____________________| W<
;	   |____________________|
;	   |                    |

DisegnaFrame:

	moveq	#2-1,d7			; numero planes
	lea	bitplane+80*40+6,a1	; indirizzo destinazione

DisegnaLoop:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$ffffffff,$44(a5)	; maschere
	move.l	#$09f00000,$40(a5)	; BLTCON0  e BLTCON1 (usa A+D)
					; copia normale
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#32,$66(a5)		; BLTDMOD (40-8=32)
	move.l	a0,$50(a5)		; BLTAPT  puntatore sorgente
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*55)+4,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 4 word
					; altezza 55 linee

	lea	2*4*55(a0),a0		; punta al prossimo plane sorgente
					; ogni plane e` largo 4 words e alto
					; 55 righe

	lea	40*256(a1),a1		; punta al prossimo plane destinazione

	dbra	d7,DisegnaLoop

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

	dc.w	$100,$2200	; bplcon0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000

	dc.w	$180,$000	; color0
	dc.w	$182,$00b	; color1
	dc.w	$184,$cc0	; color2
	dc.w	$186,$b00	; color3

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************
; Questi sono i frames che compongono l'animazione

Frame1:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffcf,$fffff800,$7fffff87,$fffffc00,$7fffff03,$fffffc00
	dc.l	$7ffffe01,$fffffc00,$fffffc00,$fffffe00,$fffff800,$7ffffe00
	dc.l	$fffff000,$3ffffe00,$ffffff87,$fffffe00,$ffffff87,$fffffe00
	dc.l	$ffffff87,$fffffe00,$ffffff87,$fffffe00,$ffffff87,$fffffe00
	dc.l	$ffffff87,$fffffe00,$ffffff87,$fffffe00,$ffffff87,$fffffe00
	dc.l	$7fffff87,$fffffc00,$7fffff87,$fffffc00,$7fffff87,$fffffc00
	dc.l	$3fffff87,$fffff800,$3fffff87,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffcf,$fffff800
	dc.l	$3fffffb7,$fffff800,$7fffff7b,$fffffc00,$7ffffefd,$fffffc00
	dc.l	$7ffffdfe,$fffffc00,$fffffbff,$7ffffe00,$fffff7ff,$bffffe00
	dc.l	$ffffefff,$dffffe00,$ffffe078,$1ffffe00,$ffffff7b,$fffffe00
	dc.l	$ffffff7b,$fffffe00,$ffffff7b,$fffffe00,$ffffff7b,$fffffe00
	dc.l	$ffffff7b,$fffffe00,$ffffff7b,$fffffe00,$ffffff7b,$fffffe00
	dc.l	$7fffff7b,$fffffc00,$7fffff7b,$fffffc00,$7fffff7b,$fffffc00
	dc.l	$3fffff7b,$fffff800,$3fffff7b,$fffff800,$3fffff03,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000


Frame2:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7fffffff,$fffffc00
	dc.l	$7fffff80,$3ffffc00,$ffffffc0,$3ffffe00,$ffffffe0,$3ffffe00
	dc.l	$fffffff0,$3ffffe00,$ffffffe0,$3ffffe00,$ffffffc0,$3ffffe00
	dc.l	$ffffff82,$3ffffe00,$ffffff07,$3ffffe00,$fffffe0f,$bffffe00
	dc.l	$fffffc1f,$fffffe00,$fffff83f,$fffffe00,$fffff07f,$fffffe00
	dc.l	$7fffe0ff,$fffffc00,$7ffff1ff,$fffffc00,$7ffffbff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7ffffe00,$1ffffc00
	dc.l	$7ffffe7f,$dffffc00,$ffffff3f,$dffffe00,$ffffff9f,$dffffe00
	dc.l	$ffffffcf,$dffffe00,$ffffff9f,$dffffe00,$ffffff3f,$dffffe00
	dc.l	$fffffe7d,$dffffe00,$fffffcf8,$dffffe00,$fffff9f2,$5ffffe00
	dc.l	$fffff3e7,$1ffffe00,$ffffe7cf,$9ffffe00,$ffffcf9f,$fffffe00
	dc.l	$7fff9f3f,$fffffc00,$7fffce7f,$fffffc00,$7fffe4ff,$fffffc00
	dc.l	$3ffff1ff,$fffff800,$3ffffbff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000


Frame3:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7ffffffd,$fffffc00
	dc.l	$7ffffffc,$fffffc00,$fffffffc,$7ffffe00,$fffffffc,$3ffffe00
	dc.l	$fffffffc,$1ffffe00,$ffff8000,$0ffffe00,$ffff8000,$07fffe00
	dc.l	$ffff8000,$07fffe00,$ffff8000,$0ffffe00,$fffffffc,$1ffffe00
	dc.l	$fffffffc,$3ffffe00,$fffffffc,$7ffffe00,$fffffffc,$fffffe00
	dc.l	$7ffffffd,$fffffc00,$7fffffff,$fffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7ffffff9,$fffffc00,$7ffffffa,$fffffc00
	dc.l	$7ffffffb,$7ffffc00,$fffffffb,$bffffe00,$fffffffb,$dffffe00
	dc.l	$ffff0003,$effffe00,$ffff7fff,$f7fffe00,$ffff7fff,$fbfffe00
	dc.l	$ffff7fff,$fbfffe00,$ffff7fff,$f7fffe00,$ffff0003,$effffe00
	dc.l	$fffffffb,$dffffe00,$fffffffb,$bffffe00,$fffffffb,$7ffffe00
	dc.l	$7ffffffa,$fffffc00,$7ffffff9,$fffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000


Frame4:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7ffffbff,$fffffc00,$7ffff1ff,$fffffc00
	dc.l	$7fffe0ff,$fffffc00,$fffff07f,$fffffe00,$fffff83f,$fffffe00
	dc.l	$fffffc1f,$fffffe00,$fffffe0f,$bffffe00,$ffffff07,$3ffffe00
	dc.l	$ffffff82,$3ffffe00,$ffffffc0,$3ffffe00,$ffffffe0,$3ffffe00
	dc.l	$fffffff0,$3ffffe00,$ffffffe0,$3ffffe00,$ffffffc0,$3ffffe00
	dc.l	$7fffff80,$3ffffc00,$7fffffff,$fffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3ffffbff,$fffff800
	dc.l	$3ffff1ff,$fffff800,$7fffe4ff,$fffffc00,$7fffce7f,$fffffc00
	dc.l	$7fff9f3f,$fffffc00,$ffffcf9f,$fffffe00,$ffffe7cf,$9ffffe00
	dc.l	$fffff3e7,$1ffffe00,$fffff9f2,$5ffffe00,$fffffcf8,$dffffe00
	dc.l	$fffffe7d,$dffffe00,$ffffff3f,$dffffe00,$ffffff9f,$dffffe00
	dc.l	$ffffffcf,$dffffe00,$ffffff9f,$dffffe00,$ffffff3f,$dffffe00
	dc.l	$7ffffe7f,$dffffc00,$7ffffe00,$1ffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000


Frame5:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffc3,$fffff800
	dc.l	$3fffffc3,$fffff800,$7fffffc3,$fffffc00,$7fffffc3,$fffffc00
	dc.l	$7fffffc3,$fffffc00,$ffffffc3,$fffffe00,$ffffffc3,$fffffe00
	dc.l	$ffffffc3,$fffffe00,$ffffffc3,$fffffe00,$ffffffc3,$fffffe00
	dc.l	$ffffffc3,$fffffe00,$ffffffc3,$fffffe00,$ffffffc3,$fffffe00
	dc.l	$fffff800,$1ffffe00,$fffffc00,$3ffffe00,$fffffe00,$7ffffe00
	dc.l	$7fffff00,$fffffc00,$7fffff81,$fffffc00,$7fffffc3,$fffffc00
	dc.l	$3fffffe7,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffff81,$fffff800,$3fffffbd,$fffff800
	dc.l	$3fffffbd,$fffff800,$7fffffbd,$fffffc00,$7fffffbd,$fffffc00
	dc.l	$7fffffbd,$fffffc00,$ffffffbd,$fffffe00,$ffffffbd,$fffffe00
	dc.l	$ffffffbd,$fffffe00,$ffffffbd,$fffffe00,$ffffffbd,$fffffe00
	dc.l	$ffffffbd,$fffffe00,$ffffffbd,$fffffe00,$fffff03c,$0ffffe00
	dc.l	$fffff7ff,$effffe00,$fffffbff,$dffffe00,$fffffdff,$bffffe00
	dc.l	$7ffffeff,$7ffffc00,$7fffff7e,$fffffc00,$7fffffbd,$fffffc00
	dc.l	$3fffffdb,$fffff800,$3fffffe7,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000

Frame6:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$bffffc00,$7fffffff,$1ffffc00
	dc.l	$7ffffffe,$0ffffc00,$fffffffc,$1ffffe00,$fffffff8,$3ffffe00
	dc.l	$fffffff0,$7ffffe00,$fffffbe0,$fffffe00,$fffff9c1,$fffffe00
	dc.l	$fffff883,$fffffe00,$fffff807,$fffffe00,$fffff80f,$fffffe00
	dc.l	$fffff81f,$fffffe00,$fffff80f,$fffffe00,$fffff807,$fffffe00
	dc.l	$7ffff803,$fffffc00,$7fffffff,$fffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$bffff800
	dc.l	$3fffffff,$1ffff800,$7ffffffe,$4ffffc00,$7ffffffc,$e7fffc00
	dc.l	$7ffffff9,$f3fffc00,$fffffff3,$e7fffe00,$fffff3e7,$cffffe00
	dc.l	$fffff1cf,$9ffffe00,$fffff49f,$3ffffe00,$fffff63e,$7ffffe00
	dc.l	$fffff77c,$fffffe00,$fffff7f9,$fffffe00,$fffff7f3,$fffffe00
	dc.l	$fffff7e7,$fffffe00,$fffff7f3,$fffffe00,$fffff7f9,$fffffe00
	dc.l	$7ffff7fc,$fffffc00,$7ffff000,$fffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000


Frame7:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7fffffff,$fffffc00
	dc.l	$7fffff7f,$fffffc00,$fffffe7f,$fffffe00,$fffffc7f,$fffffe00
	dc.l	$fffff87f,$fffffe00,$fffff07f,$fffffe00,$ffffe000,$03fffe00
	dc.l	$ffffc000,$03fffe00,$ffffc000,$03fffe00,$ffffe000,$03fffe00
	dc.l	$fffff07f,$fffffe00,$fffff87f,$fffffe00,$fffffc7f,$fffffe00
	dc.l	$7ffffe7f,$fffffc00,$7fffff7f,$fffffc00,$7fffffff,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7fffff3f,$fffffc00
	dc.l	$7ffffebf,$fffffc00,$fffffdbf,$fffffe00,$fffffbbf,$fffffe00
	dc.l	$fffff7bf,$fffffe00,$ffffef80,$01fffe00,$ffffdfff,$fdfffe00
	dc.l	$ffffbfff,$fdfffe00,$ffffbfff,$fdfffe00,$ffffdfff,$fdfffe00
	dc.l	$ffffef80,$01fffe00,$fffff7bf,$fffffe00,$fffffbbf,$fffffe00
	dc.l	$7ffffdbf,$fffffc00,$7ffffebf,$fffffc00,$7fffff3f,$fffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000


Frame8:
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7fffffff,$fffffc00
	dc.l	$7ffff803,$fffffc00,$fffff807,$fffffe00,$fffff80f,$fffffe00
	dc.l	$fffff81f,$fffffe00,$fffff80f,$fffffe00,$fffff807,$fffffe00
	dc.l	$fffff883,$fffffe00,$fffff9c1,$fffffe00,$fffffbe0,$fffffe00
	dc.l	$fffffff0,$7ffffe00,$fffffff8,$3ffffe00,$fffffffc,$1ffffe00
	dc.l	$7ffffffe,$0ffffc00,$7fffffff,$1ffffc00,$7fffffff,$bffffc00
	dc.l	$3fffffff,$fffff800,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000
	dc.l	$000003ff,$80000000,$00001fff,$f0000000,$0000ffff,$fe000000
	dc.l	$0003ffff,$ff800000,$0007ffff,$ffc00000,$001fffff,$fff00000
	dc.l	$003fffff,$fff80000,$007fffff,$fffc0000,$00ffffff,$fffe0000
	dc.l	$01ffffff,$ffff0000,$03ffffff,$ffff8000,$07ffffff,$ffffc000
	dc.l	$07ffffff,$ffffc000,$0fffffff,$ffffe000,$1fffffff,$fffff000
	dc.l	$1fffffff,$fffff000,$3fffffff,$fffff800,$3fffffff,$fffff800
	dc.l	$3fffffff,$fffff800,$7fffffff,$fffffc00,$7ffff000,$fffffc00
	dc.l	$7ffff7fc,$fffffc00,$fffff7f9,$fffffe00,$fffff7f3,$fffffe00
	dc.l	$fffff7e7,$fffffe00,$fffff7f3,$fffffe00,$fffff7f9,$fffffe00
	dc.l	$fffff77c,$fffffe00,$fffff63e,$7ffffe00,$fffff49f,$3ffffe00
	dc.l	$fffff1cf,$9ffffe00,$fffff3e7,$cffffe00,$fffffff3,$e7fffe00
	dc.l	$7ffffff9,$f3fffc00,$7ffffffc,$e7fffc00,$7ffffffe,$4ffffc00
	dc.l	$3fffffff,$1ffff800,$3fffffff,$bffff800,$3fffffff,$fffff800
	dc.l	$1fffffff,$fffff000,$1fffffff,$fffff000,$0fffffff,$ffffe000
	dc.l	$07ffffff,$ffffc000,$07ffffff,$ffffc000,$03ffffff,$ffff8000
	dc.l	$01ffffff,$ffff0000,$00ffffff,$fffe0000,$007fffff,$fffc0000
	dc.l	$003fffff,$fff80000,$001fffff,$fff00000,$0007ffff,$ffc00000
	dc.l	$0003ffff,$ff800000,$0000ffff,$fe000000,$00001fff,$f0000000
	dc.l	$000003ff,$80000000

;****************************************************************************

	SECTION	bitplane,BSS_C

BITPLANE:
	ds.b	40*256		; 2 bitplanes
	ds.b	40*256

;****************************************************************************

	end

In questo esempio mostriamo un animazione realizzata con il blitter.
Abbiamo 8 fotogrammi che si ripetono ciclicamente. Per realizzare l'animazione
e` sufficente disegnare con il blitter i vari fotogrammi. In questo esempio
i vari fotogrammi hanno tutti le stesse dimensioni e vengono disegnati nella
stessa posizione sullo schermo, cosa che facilita la realizzazione della
routine di disegno. Per scegliere quale sia ogni volta il fotogramma da
disegnare si impiega una routine molto simile a quella usata nell'esempio
lezione7z.s per gli sprite animati. Abbiamo una tabella con gli indirizzi
dei vari fotogrammi. Gli indirizzi vengono di volta in volta ruotati nella
tabella in modo che al primo posto venga sempre a trovarsi il fotogramma
da disegnare. Inoltre c'e` un contatore (ContaAnim) che ci permette di
disegnare il nuovo frame non tutte le volte che la routine viene eseguita ma
solo alcune. Questo contatore viene incrementato ogni volta e solo quando
raggiunge un particolare valore, gli indirizzi dei frame vengono ruotati.
Modificando questo valore, si puo` controllare la velocita` dell'animazione.

