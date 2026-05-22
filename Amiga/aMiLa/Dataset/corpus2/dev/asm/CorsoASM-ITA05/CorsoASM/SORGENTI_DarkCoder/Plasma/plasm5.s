
; Plasma5.s	Plasma RGB a 2-bitplanes e ondulazione
;		tasto sinistro per uscire

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA

Waitdisk	EQU	10

Largh_plasm	equ	36		; larghezza del plasma espressa
					; come numero di gruppi di 8 pixel

; numero di bytes occupati nella copperlist da ogni riga del plasma: ogni
; istruzione copper occupa 4 bytes. Ogni riga e` formata da 1 "copper move" in
; BPLCON1, 1 WAIT,Largh_plasm "copper moves" per il plasma

BytesPerRiga	equ	(Largh_plasm+2)*4

Alt_plasm	equ	235		; altezza del plasma espressa
					; come numero di linee

NuovaRigaR	equ	6		; valore sommato all'indice R nella
					; SinTab tra una riga e l'altra
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovoFrameR	equ	2		; valore sottratto all'indice R nella
					; SinTab tra un frame e l'altro
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovaRigaG	equ	2		; come "NuovaRigaR" ma per componente G
NuovoFrameG	equ	8		; come "NuovoFrameR" ma componente G

NuovaRigaB	equ	-12		; come "NuovaRigaR" ma per componente B
NuovoFrameB	equ	-6		; come "NuovoFrameR" ma componente B

NuovaRigaO	equ	12		; come "NuovaRigaR" ma per oscillazioni
NuovoFrameO	equ	-4		; come "NuovoFrameR" ma oscillazioni


START:

;	Puntiamo i bitplanes nelle copperlist

	MOVE.L	#BITPLANE,d0	; bitplane 1 (plasma)
	LEA	COPPERLIST1,A1	; puntatori COP 1
	LEA	COPPERLIST2,A2	; puntatori COP 2
	move.w	d0,6(a1)	; scrive in copperlist 1 
	move.w	d0,6(a2)	; scrive in copperlist 2
	swap	d0
	move.w	d0,2(a1)	; scrive in copperlist 1
	move.w	d0,2(a2)	; scrive in copperlist 2

	MOVE.L	#PIC,d0		; bitplane 2 (maschera)
	move.w	d0,14(a1)	; scrive in copperlist 1 
	move.w	d0,14(a2)	; scrive in copperlist 2
	swap	d0
	move.w	d0,10(a1)	; scrive in copperlist 1
	move.w	d0,10(a2)	; scrive in copperlist 2


	lea	$dff000,a5		; CUSTOM REGISTER in a5

	bsr	InitPlasma		; inizializza la copperlist

; Inizializza i registri del blitter

	Btst	#6,2(a5)
WaitBlit_init:
	Btst	#6,2(a5)		; aspetta il blitter
	bne.s	WaitBlit_init

	move.l	#$4FFE8000,$40(a5)	; BLTCON0/1 - D=A+B+C
					; shift A = 4 pixel
					; shift B = 8 pixel
					
	moveq	#-1,d0			; D0 = $FFFFFFFF
	move.l	d0,$44(a5)		; BLTAFWM/BLTALWM

mod_A	set	0			; modulo canale A
mod_D	set	BytesPerRiga-2		; modulo canale D: va a riga seguente

	move.l	#mod_A<<16+mod_D,$64(a5)	; carica i registri modulo

; moduli canali B e C = 0

	moveq	#0,d0
	move.l	d0,$60(a5)		; scrive BLTBMOD e BLTCMOD

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST1,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP

; Inizializza altri registri hardware
; D0=0
	move.w	d0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA
	move.l	d0,$180(a5)		; COLOR00 e COLOR01 - nero
	move.w	#$3e90,$8e(a5)		; DiwStrt - usiamo una finestra piu`
					; piccola dello schermo
	move.w	#$E6b1,$90(a5)		; DiwStop
	move.w	#$0036,$92(a5)		; DDFStrt - vengono fetchati 40 bytes
	move.w	#$00ce,$94(a5)		; DDFStop
	move.l	d0,$102(a5)		; BPLCON1/2
	move.w	#-40,$108(a5)		; BPL1MOD = -40 ripete sempre la stessa
					; riga
	move.w	#0,$10a(a5)		; BPL2MOD = 0 normale
	move.w	#$2200,$100(a5)		; BPLCON0 - 2 bitplane attivi

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity2

	bsr	ScambiaClists	; scambia le copperlist

	bsr	DoOriz		; effetto oscillazione orizzontale
	bsr	DoPlasma

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse2

	rts

;****************************************************************************
; Questa routine realizza l'effetto di oscillazione orizzontale. 
; L'effetto e` realizzato modificando ad ogni riga il valore di scroll hardware
; del bitplane 1. I valori vengono letti da una tabella e scritti nella
; copperlist.
;****************************************************************************

DoOriz:
	lea	OrizTab(pc),a0		; indirizzo tabella oscillazioni
	move.l	draw_clist(pc),a1	; indirizzo copperlist dove scrivere
	lea	19(a1),a1		; indirizzo secondo byte della seconda
					; word della "copper move" in BPLCON1
; legge e modifica indice

	move.w	IndiceO(pc),d4		; legge l'indice di partenza del
					; frame precedente
	sub.w	#NuovoFrameO,d4		; modifica l'indice nella tabella
					; dal frame precedente
	and.w	#$007F,d4		; tiene l'indice nell'intervallo
					; 0 - 127 (offset in una tabella di
					; 128 bytes)
	move.w	d4,IndiceO		; memorizza l'indice di partenza per
					; il prossimo frame

	move.w	#Alt_plasm-1,d3		; loop per ogni riga
OrizLoop:
	move.b	0(a0,d4.w),d0		; leggi valore dell'oscillazione

	move.b	d0,(a1)			; scrive il valore di scroll nella
					; "copper move" in BPLCON1

	lea	BytesPerRiga(a1),a1	; punta alla prossima riga 
					; nella copper list
; modifica indice per prossima riga

	add.w	#NuovaRigaO,d4		; modifica l'indice nella tabella
					; per la prossima riga

	and.w	#$007F,d4		; tiene l'indice nell'intervallo
					; 0 - 127 (offset in una tabella di
					; 128 bytes)

	dbra	d3,OrizLoop

	rts

;****************************************************************************
; Questa routine realizza il "double buffer" tra le copperlist.
; In pratica prende la clist dove si e` disegnato, e la visualizza copiandone
; l'indirizzo in COP1LC. Scambia le variabili, in modo tale che nel frame
; che segue si disegna sull'altra copper list
;****************************************************************************

ScambiaClists:
	move.l	draw_clist(pc),d0	; indirizzo clist su cui si e` scritto
	move.l	view_clist(pc),draw_clist	; scambia le clists
	move.l	d0,view_clist

	move.l	d0,$80(a5)		; copia l'indirizzo della clist
					; in COP1LC in maniera che venga
					; visualizzata nel prossimo frame
	rts


;****************************************************************************
; Questa routine inizializza la copperlist che genera il plasma. Sistema le
; istruzioni WAIT e le prima meta` delle COPPERMOVE.
;****************************************************************************

InitPlasma:
	lea	Plasma1,a0	; indirizzo plasma 1
	lea	Plasma2,a1	; indirizzo plasma 2
	move.l	#$3e43FFFE,d0	; carica la prima istruzione wait in D0.
				; aspetta la riga $30 e la posizione
				; orizzontale $24
	move.w	#$184,d1	; mette in D1 la prima meta` di un istruzione 
				; "copper move" in COLOR02 (=$dff184)
	move.w	#$186,d4	; mette in D4 la prima meta` di un istruzione 
				; "copper move" in COLOR03 (=$dff186)
	move.w	#$102,d5	; mette in D4 la prima meta` di un istruzione 
				; "copper move" in BPLCON1 (=$dff102)

	move.w	#Alt_plasm-1,d3		; loop per ogni riga
InitLoop1:
	move.w	d5,(a0)+		; scrive la prima parte della
					; "copper move" in BPLCON1 - clist 1
	addq.w	#2,a0			; spazio per la seconda parte
					; della "copper move" - clist 1

	move.w	d5,(a1)+		; scrive la prima parte della
					; "copper move" in BPLCON1 - clist 2
	addq.w	#2,a1			; spazio per la seconda parte
					; della "copper move" - clist 2

	move.l	d0,(a0)+		; scrive la WAIT - (clist 1)
	move.l	d0,(a1)+		; scrive la WAIT - (clist 2)
	add.l	#$01000000,d0		; modifica la WAIT per aspettare
					; la riga seguente

	moveq	#Largh_plasm/2-1,d2	; loop per tutta la larghezza

InitLoop2:
	move.w	d4,(a0)+		; scrive la prima parte della
					; "copper move" in COLOR02 - clist 1
	addq.w	#2,a0			; spazio per la seconda parte
					; della "copper move" - clist 1

	move.w	d4,(a1)+		; scrive la prima parte della
					; "copper move" in COLOR02 - clist 2
	addq.w	#2,a1			; spazio per la seconda parte
					; della "copper move" - clist 2

	move.w	d1,(a0)+		; scrive la prima parte della
					; "copper move" in COLOR03 - clist 1
	addq.w	#2,a0			; spazio per la seconda parte
					; della "copper move" - clist 1

	move.w	d1,(a1)+		; scrive la prima parte della
					; "copper move" in COLOR03 - clist 2
	addq.w	#2,a1			; spazio per la seconda parte
					; della "copper move" - clist 2
	dbra	d2,InitLoop2
	dbra	d3,InitLoop1
	rts


;****************************************************************************
; Questa routine realizza il plasma. Effettua un loop di blittate, ciascuna
; delle quali scrive una "colonna" del plasma, cioe` scrive i colori nelle
; COPPERMOVES messe in colonna.
; I colori scritti in ogni colonna sono letti da una tabella, a partire da
; un indirizzo che varia tra una colonna e l'altra in base a degli offset
; letti da un'altra tabella. Inoltre tra un frame e l'altro gli offset
; variano, realizzando l'effetto di movimento.
;****************************************************************************

DoPlasma:
	lea	Color,a0		; indirizzo colori
	lea	SinTab,a6		; indirizzo tabella offsets
	move.l	draw_clist(pc),a1	; indirizzo copperlist dove scrivere
	lea	26(a1),a1		; indirizzo prima word della prima
					; colonna del plasma
; legge e modifica indice componente R

	move.w	IndiceR(pc),d4		; legge l'indice di partenza del
					; frame precedente
	sub.w	#NuovoFrameR,d4		; modifica l'indice nella tabella
					; dal frame precedente
	and.w	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move.w	d4,IndiceR		; memorizza l'indice di partenza per
					; il prossimo frame
; legge e modifica indice componente G

	move.w	IndiceG(pc),d5		; legge l'indice di partenza del
					; frame precedente
	sub.w	#NuovoFrameG,d5		; modifica l'indice nella tabella
					; dal frame precedente
	and.w	#$00FF,d5		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move.w	d5,IndiceG		; memorizza l'indice di partenza per
					; il prossimo frame
; legge e modifica indice componente B

	move.w	IndiceB(pc),d6		; legge l'indice di partenza del
					; frame precedente
	sub.w	#NuovoFrameB,d6		; modifica l'indice nella tabella
					; dal frame precedente
	and.w	#$00FF,d6		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move.w	d6,IndiceB		; memorizza l'indice di partenza per
					; il prossimo frame

	move.w	#Alt_plasm<<6+1,d3	; dimensione blittata
					; largh. 1 word, alta tutto il plasma

	moveq	#Largh_plasm-1,d2	; il loop NON viene ripetuto per tutta
					; la larghezza. Le ultime 2 colonne
					; vengono lascate stare in modo che
					; esse riscrivano il colore nero nei
					; registri COLOR01 e COLOR00

PlasmaLoop:				; inizio loop blittate

; calcola indirizzo di partenza componente R

	move.w	(a6,d4.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a2		; indirizzo di partenza = ind. colori
					; piu` offset

; calcola indirizzo di partenza componente G

	move.w	(a6,d5.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a3		; indirizzo di partenza = ind. colori
					; piu` offset

; calcola indirizzo di partenza componente B

	move.w	(a6,d6.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a4		; indirizzo di partenza = ind. colori
					; piu` offset

	Btst	#6,2(a5)
WaitBlit:
	Btst	#6,2(a5)		; aspetta il blitter
	bne.s	WaitBlit

	move.l	a2,$48(a5)		; BLTCPT - indirizzo sorgente R
	move.l	a3,$50(a5)		; BLTAPT - indirizzo sorgente G
	move.l	a4,$4C(a5)		; BLTBPT - indirizzo sorgente B
	move.l	a1,$54(a5)		; BLTDPT - indirizzo destinazione
	move.w	d3,$58(a5)		; BLTSIZE

	addq.w	#4,a1			; punta a prossima colonna di 
					; "copper moves" nella copper list

; modifica indice componente R per prossima riga

	add.w	#NuovaRigaR,d4		; modifica l'indice nella tabella
					; per la prossima riga

	and.w	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

; modifica indice componente G per prossima riga

	add.w	#NuovaRigaG,d5		; modifica l'indice nella tabella
					; per la prossima riga

	and.w	#$00FF,d5		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

; modifica indice componente B per prossima riga

	add.w	#NuovaRigaB,d6		; modifica l'indice nella tabella
					; per la prossima riga

	and.w	#$00FF,d6		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	dbra	d2,PlasmaLoop
	rts


; Queste 2 variabili contengono gli indirizzi delle 2 copperlist

view_clist:	dc.l	COPPERLIST1	; indirizzo clist visualizzata
draw_clist:	dc.l	COPPERLIST2	; indirizzo clist dove disegnare

; Questa variabile contiene il valore dell'indice nella tabella delle
; oscillazioni (posizioni orizzontali delle WAIT)

IndiceO:	dc.w	0

; Questa tabella contiene i valori delle oscillazioni (valori di scroll del
; bitplane 1)

OrizTab:
	DC.B	$03,$03,$03,$03,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05
	DC.B	$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
	DC.B	$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$05,$05,$05,$05
	DC.B	$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04,$04,$04,$03,$03,$03
	DC.B	$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
	DC.B	$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
	DC.B	$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03

; Queste variabili contengono i valori degli indici per la prima colonna

IndiceR:	dc.w	0
IndiceG:	dc.w	0
IndiceB:	dc.w	0

; Questa tabella contiene gli offset per l'indirizzo di partenza nella
; tabella dei colori

SinTab:
	DC.W	$0034,$0036,$0038,$003A,$003C,$0040,$0042,$0044,$0046,$0048
	DC.W	$004A,$004C,$004E,$0050,$0052,$0054,$0056,$0058,$005A,$005A
	DC.W	$005C,$005E,$005E,$0060,$0060,$0062,$0062,$0062,$0064,$0064
	DC.W	$0064,$0064,$0064,$0064,$0064,$0064,$0062,$0062,$0062,$0060
	DC.W	$0060,$005E,$005E,$005C,$005A,$005A,$0058,$0056,$0054,$0052
	DC.W	$0050,$004E,$004C,$004A,$0048,$0046,$0044,$0042,$0040,$003C
	DC.W	$003A,$0038,$0036,$0034,$0030,$002E,$002C,$002A,$0028,$0024
	DC.W	$0022,$0020,$001E,$001C,$001A,$0018,$0016,$0014,$0012,$0010
	DC.W	$000E,$000C,$000A,$000A,$0008,$0006,$0006,$0004,$0004,$0002
	DC.W	$0002,$0002,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0002,$0002,$0002,$0004,$0004,$0006,$0006,$0008,$000A,$000A
	DC.W	$000C,$000E,$0010,$0012,$0014,$0016,$0018,$001A,$001C,$001E
	DC.W	$0020,$0022,$0024,$0028,$002A,$002C,$002E,$0030
EndSinTab:

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

; Abbiamo 2 copperlists 

COPPERLIST1:
	dc.w	$e0,$0000,$e2,$0000	; bitplane 1
	dc.w	$e4,$0000,$e6,$0000	; bitplane 2

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.

PLASMA1:
	dcb.b	alt_plasm*BytesPerRiga,0
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

COPPERLIST2:
	dc.w	$e0,$0000,$e2,$0000	; bitplane 1
	dc.w	$e4,$0000,$e6,$0000	; bitplane 2

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.

PLASMA2:
	dcb.b	alt_plasm*BytesPerRiga,0

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;****************************************************************************
; Qui c'e` la tabella di colori che viene scritta nel plasma.
; Devono esserci abbastanza colori da essere letti qualunque sia l'indirizzo
; di partenza. In questo esempio l'indirizzo di partenza puo` variare da
; "Color" (primo colore) fino a "Color+100" (50-esimo colore), perche`
; 100 e` il massimo offset sontenuto nella "SinTab".
; Se Alt_plasm=190 vuol dire che ogni blittata legge 190 colori.
; Quindi in totale devono esserci 240 colori.
;****************************************************************************

Color:
	dc.w	$0f00,$0f00,$0e00,$0e00,$0e00,$0d00,$0d00,$0d00
	dc.w	$0c00,$0c00,$0c00,$0b00,$0b00,$0b00,$0a00,$0a00,$0a00
	dc.w	$0900,$0900,$0900,$0800,$0800,$0800,$0700,$0700,$0700
	dc.w	$0600,$0600,$0600,$0500,$0500,$0500,$0400,$0400,$0400
	dc.w	$0300,$0300,$0300,$0200,$0200,$0200,$0100,$0100,$0100
	dcb.w	18,0
	dc.w	$0100,$0100,$0100,$0100,$0200,$0200,$0200,$0200
	dc.w	$0300,$0300,$0300,$0300,$0400,$0400,$0400,$0400
	dc.w	$0500,$0500,$0500,$0500,$0600,$0600,$0600,$0600
	dc.w	$0700,$0700,$0700,$0700,$0800,$0800,$0800,$0800
	dc.w	$0900,$0900,$0900,$0900,$0a00,$0a00,$0a00,$0a00
	dc.w	$0b00,$0b00,$0b00,$0b00,$0c00,$0c00,$0c00,$0c00
	dc.w	$0d00,$0d00,$0d00,$0d00,$0e00,$0e00,$0e00,$0e00
	dc.w	$0f00,$0f00,$0f00,$0f00

	dc.w	$0f00,$0f00,$0f00,$0f00,$0e00,$0e00,$0e00,$0e00
	dc.w	$0d00,$0d00,$0d00,$0d00,$0c00,$0c00,$0c00,$0c00
	dc.w	$0b00,$0b00,$0b00,$0b00,$0a00,$0a00,$0a00,$0a00
	dc.w	$0900,$0900,$0900,$0800,$0800,$0800,$0800
	dc.w	$0700,$0700,$0700,$0700,$0600,$0600,$0600,$0600
	dc.w	$0500,$0500,$0500,$0500,$0400,$0400,$0400,$0400
	dc.w	$0300,$0300,$0300,$0300,$0200,$0200,$0200,$0200
	dc.w	$0100,$0100,$0100
	dcb.w	18,0
	dc.w	$0100,$0100,$0100,$0200,$0200,$0200,$0300,$0300,$0300
	dc.w	$0400,$0400,$0400,$0500,$0500,$0500,$0600,$0600,$0600
	dc.w	$0700,$0700,$0700,$0800,$0800,$0900,$0900,$0900
	dc.w	$0a00,$0a00,$0a00,$0b00,$0b00,$0b00,$0c00,$0c00,$0c00
	dc.w	$0d00,$0d00,$0d00,$0e00,$0e00,$0e00,$0f00

; Riga dell'immagine che viene ripetuta con il BPLMOD1
; e` formata da 40 bytes alternativamente a 0 o a $FF

BITPLANE:	dcb.w	20,$00FF

; Maschera del plasma: e` un immagine 320*168 pixel a 1 bitplane

Pic:	incbin	plasm_msk.raw

	end

;****************************************************************************

In questo esempio vediamo un plasma a 2 bitplanes. Si tratta di una
semplice variante del plasma 1 bitplane. Si usa il bitplane 1 per fare il
plasma e il 2 come maschera. Il plasma utilizza i colori 2 e 3.
Quindi il plasma apparira` in corrispondenza dei pixel di valore 1 del
bitplane maschera.
Questa tecnica ha anche il vantaggio che non e` necessario scrivere il nero
alla fine della riga, perche` il colore 0 (di sfondo) non viene toccato.
In questo modo, possiamo utilizzare un plasma piu` stretto rispetto a quello
usato nell'esempio plasm4.s anche se la larghezza visibile e` la stessa
(risparmiamo le ultime 2 "copper moves" di ogni riga; confrontate i diversi
valori del parametro "Largh_plasm").
Ovviamente il bitplane di maschera viene visualizzato normalmente, quindi
senza scroll e con modulo azzerato.

