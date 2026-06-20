
; Lezione10g2.s	Esempio di OR tra con un canale abilitato e uno disabilitato
;		Tasto destro per eseguire la blittata, sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE1,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#1-1,D1		; numero di bitplanes
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

	lea	Figura,a0
	lea	BITPLANE1+20,a1
	bsr.s	copia		; esegui copia figura 2

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1		; se no, non cancellare

	bsr.s	BlitOR		; esegui l'OR tra le 2 figure

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:
	rts


;****************************************************************************
; Questa routine copia la figura sullo schermo.
; Prende come parametri
; A0 - indirizzo sorgente
; A1 - indirizzo destinazione
;****************************************************************************

Copia:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$ffffffff,$44(a5)	; maschere
	move.l	#$09f00000,$40(a5)	; BLTCON0  e BLTCON1 (usa A+D)
					; copia normale
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#30,$66(a5)		; BLTDMOD (40-10=30)
	move.l	a0,$50(a5)		; BLTAPT  puntatore sorgente
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*71)+5,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 5 word
	rts				; altezza 71 linee

;****************************************************************************
; Questa routine l'OR tra una figura letta attraverso il canale B
; e il valore costante contenuto in BLTADAT
;****************************************************************************

;	  |\__/,|   (`\
;	  |_ _  |.--.) )
;	  ( T   )     /
;	 (((^_(((/(((_>

BlitOR:
	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; maschere
	move.l	#$05fc0000,$40(a5)	; BLTCON0 e BLTCON1
					; usa i canali B e D
					; esegue l'OR tra A e B (LF=$FC)
	move.w	#0,$62(a5)		; BLTBMOD (=0)
	move.w	#30,$66(a5)		; BLTDMOD (40-10=30)
	move.w	#$CCCC,$74(a5)		; valore di OR in BLTADAT 

	move.l	#Figura,$4c(a5)		; BLTBPT  puntatore sorgente
	move.l	#BITPLANE1+100*40+10,$54(a5)	; BLTDPT  puntatore dest.
	move.w	#(64*71)+5,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 5 word
	rts				; altezza 71 linee

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

	dc.w	$100,$1200	; bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$aaa	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

Figura:
	dc.w	$ffff,$ffff,$ffff,$ffff,$fe00,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,$3800,0,0
	dc.w	0,$0003,$ff80,0,0,0,$001f,$fff0,0,0
	dc.w	0,$01ff,$ffff,0,0,0,$0fff,$ffff,$e000,0
	dc.w	0,$ffff,$ffff,$fe00,0,$0007,$ffff,$ffff,$ffc0,0
	dc.w	$007f,$ffff,$ffff,$fffc,0,$03ff,$ffff,$ffff,$ffff,$8000
	dc.w	$3fff,$ffff,$ffff,$ffff,$f800,$7fff,$ffff,$ffff,$ffff,$fc00
	dc.w	$3fff,$ffff,$ffff,$ffff,$f800,$03ff,$ffff,$ffff,$ffff,$8000
	dc.w	$007f,$ffff,$ffff,$fffc,0,$0007,$ffff,$ffff,$ffc0,0
	dc.w	0,$ffff,$ffff,$fe00,0,0,$0fff,$ffff,$e000,0
	dc.w	0,$01ff,$ffff,0,0,0,$001f,$fff0,0,0
	dc.w	0,$0003,$ff80,0,0,0,0,$3800,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$8000,0,0,0,$0200,$8000,0,0,0,$0200
	dc.w	$ffff,$ffff,$ffff,$ffff,$fe00

;****************************************************************************

	SECTION	bitplane,BSS_C
BITPLANE1:
	ds.b	40*256

	end

;****************************************************************************

In questo esempio eseguiamo un OR tra una figura letta attraverso il canale B
e un valore costante contenuto nel registro BLTADAT.
Per questo teniamo abilitati i canali B e D, e programmiamo il byte LF
in modo che venga eseguito un OR tra le sorgenti A e B.

