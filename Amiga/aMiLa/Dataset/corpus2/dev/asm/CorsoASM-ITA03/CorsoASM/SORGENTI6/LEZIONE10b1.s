
; Lezione9b1.s	Esempio di OR tra 2 canali
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

	lea	Figura1,a0
	lea	BITPLANE1,a1
	bsr.s	copia		; esegui copia figura 1

	lea	Figura2,a0
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
; Questa routine l'OR tra 2 figura lette attraverso i canali A e B
;****************************************************************************

;	           /#\    ...
;	          /   \  :   :
;	         / /\  \c o o ø
;	        /%/  \  (  ^  )    /)OO
;	       (  u  / __\ O / \   \)(/
;	       UUU_ ( /)  `-'`  \  /%/
;	        /  \| /   <  :\  )/ /
;	       /  . \::.   >.( \ ' /
;	      /  /\   '::./|. ) \#/
;	     /  /  \    ': ). )
;	 __ û%,/    \   / (.  )
;	(  \% /     /  /  ) .'
;	 \_ò /     /  /   `:'
;	  \_/     /  /
;	         /\./
;	        /.%
;	       / %
;	      (  %
;	       \ ~\
;	        \__)

BlitOR:
	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; maschere
	move.l	#$0dfc0000,$40(a5)	; BLTCON0 e BLTCON1
					; usa i canali A,B e D
					; esegue l'OR tra A e B (LF=$FC)
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#0,$62(a5)		; BLTBMOD (=0)
	move.w	#30,$66(a5)		; BLTDMOD (40-10=30)

	move.l	#Figura1,$50(a5)		; BLTBPT  puntatore sorgente
	move.l	#Figura2,$4c(a5)		; BLTAPT  puntatore sorgente
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

Figura1:
	dc.w	$ffc0,0,0,$0007,$fe00,$8000,0,$1000,0,$0200
	dc.w	$8000,0,$3800,0,$0200,$8000,0,$3800,0,$0200
	dc.w	$8000,0,$3800,0,$0200,$8000,0,$3800,0,$0200
	dc.w	$8000,0,$7c00,0,$0200,$8000,0,$7c00,0,$0200
	dc.w	$8000,0,$7c00,0,$0200,$8000,0,$fe00,0,$0200
	dc.w	$8000,0,$fe00,0,$0200,$8000,0,$fe00,0,$0200
	dc.w	$8000,0,$fe00,0,$0200,$8000,$0001,$ff00,0,$0200
	dc.w	$8000,$0001,$ff00,0,$0200,$8000,$0001,$ff00,0,$0200
	dc.w	$8000,$0003,$ff80,0,$0200,$8000,$0003,$ff80,0,$0200
	dc.w	$8000,$0003,$ff80,0,$0200,$8000,$0003,$ff80,0,$0200
	dc.w	$8000,$0007,$ffc0,0,$0200,$8000,$0007,$ffc0,0,$0200
	dc.w	$8000,$0007,$ffc0,0,$0200,$8000,$000f,$ffe0,0,$0200
	dc.w	$8000,$000f,$ffe0,0,$0200,$8000,$000f,$ffe0,0,$0200
	dc.w	$8000,$000f,$ffe0,0,$0200,$8000,$001f,$fff0,0,$0200
	dc.w	$8000,$001f,$fff0,0,$0200,$8000,$001f,$fff0,0,$0200
	dc.w	$8000,$003f,$fff8,0,$0200,$8000,$003f,$fff8,0,$0200
	dc.w	$8000,$003f,$fff8,0,$0200,$8000,$003f,$fff8,0,$0200
	dc.w	$8000,$007f,$fffc,0,$0200,$8000,$007f,$fffc,0,$0200
	dc.w	$8000,$007f,$fffc,0,$0200,$8000,$003f,$fff8,0,$0200
	dc.w	$8000,$003f,$fff8,0,$0200,$8000,$003f,$fff8,0,$0200
	dc.w	$8000,$003f,$fff8,0,$0200,$8000,$001f,$fff0,0,$0200
	dc.w	$8000,$001f,$fff0,0,$0200,$8000,$001f,$fff0,0,$0200
	dc.w	$8000,$000f,$ffe0,0,$0200,$8000,$000f,$ffe0,0,$0200
	dc.w	$8000,$000f,$ffe0,0,$0200,$8000,$000f,$ffe0,0,$0200
	dc.w	$8000,$0007,$ffc0,0,$0200,$8000,$0007,$ffc0,0,$0200
	dc.w	$8000,$0007,$ffc0,0,$0200,$8000,$0003,$ff80,0,$0200
	dc.w	$8000,$0003,$ff80,0,$0200,$8000,$0003,$ff80,0,$0200
	dc.w	$8000,$0003,$ff80,0,$0200,$8000,$0001,$ff00,0,$0200
	dc.w	$8000,$0001,$ff00,0,$0200,$8000,$0001,$ff00,0,$0200
	dc.w	$8000,0,$fe00,0,$0200,$8000,0,$fe00,0,$0200
	dc.w	$8000,0,$fe00,0,$0200,$8000,0,$fe00,0,$0200
	dc.w	$8000,0,$7c00,0,$0200,$8000,0,$7c00,0,$0200
	dc.w	$8000,0,$7c00,0,$0200,$8000,0,$3800,0,$0200
	dc.w	$8000,0,$3800,0,$0200,$8000,0,$3800,0,$0200
	dc.w	$8000,0,$3800,0,$0200,$8000,0,$1000,0,$0200
	dc.w	$ffc0,0,0,$0007,$fe00

Figura2:
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

In questo esempio vediamo l'OR tra 2 figure. Si tratta di una semplice
blittata che esegue l'OR tra i 2 canali A e B, usando il valore di LF
calcolato nella lezione. Per esercizio potete modificarlo utilizzando
per la lettura il canale C al posto del B. Le modifiche da fare sono
le seguenti:
Sostiuire i registri modulo e puntatore del canale B con quelli del C;
attivare il canale C invece che il B;
Calcolare il giusto valore di LF per eseguira l'OR tra A e C.
Il calcolo di LF e` semplice: basta osservare la tabella in fig.27 e
settare ad 1 tutti i minterms corrispondenti a combinazioni con A=1 oppure
con C=1. Si ottiene LF=$FA.
Ripetete lo stesso esercizio per fare l'OR tra i canali B e C.

