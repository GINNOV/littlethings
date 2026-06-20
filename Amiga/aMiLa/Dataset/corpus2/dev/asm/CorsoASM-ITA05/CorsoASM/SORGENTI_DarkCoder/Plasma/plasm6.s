
; Plasma6.s	Plasma RGB a 4-bitplanes e ondulazione
;		tasto sinistro per uscire

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA

Waitdisk	EQU	10

Largh_plasm	equ	40		; larghezza del plasma espressa
					; come numero di gruppi di 8 pixel

; numero di bytes occupati nella copperlist da ogni riga del plasma: ogni
; istruzione copper occupa 4 bytes. Ogni riga e` formata da 1 WAIT, Largh_plasm
; "copper moves" per il plasma.

BytesPerRiga	equ	(Largh_plasm+1)*4

Alt_plasm	equ	190		; altezza del plasma espressa
					; come numero di linee

NuovaRigaR	equ	-4		; valore sommato all'indice R nella
					; SinTab tra una riga e l'altra
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovoFrameR	equ	16		; valore sottratto all'indice R nella
					; SinTab tra un frame e l'altro
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovaRigaG	equ	-22		; come "NuovaRigaR" ma per componente G
NuovoFrameG	equ	2		; come "NuovoFrameR" ma componente G

NuovaRigaB	equ	40		; come "NuovaRigaR" ma per componente B
NuovoFrameB	equ	4		; come "NuovoFrameR" ma componente B

NuovaRigaO	equ	4		; come "NuovaRigaR" ma per oscillazioni
NuovoFrameO	equ	2		; come "NuovoFrameR" ma oscillazioni


START:

;	Puntiamo l'immagine nelle copperlist

	LEA	COPPERLIST1,A1	; puntatori COP 1
	LEA	COPPERLIST2,A2	; puntatori COP 2
	MOVE.L	#BUFFER,d0	; dove puntare
	move.w	d0,6(a1)	; scrive in copperlist 1 
	move.w	d0,6(a2)	; scrive in copperlist 2
	swap	d0
	move.w	d0,2(a1)	; scrive in copperlist 1
	move.w	d0,2(a2)	; scrive in copperlist 2

; bitplane 2 - parte 2 bytes piu` avanti

	MOVE.L	#BUFFER+2,d0
	move.w	d0,6+8(a1)
	move.w	d0,6+8(a2)
	swap	d0
	move.w	d0,2+8(a1)
	move.w	d0,2+8(a2)

; bitplane 3 - parte 2 bytes piu` avanti

	MOVE.L	#BUFFER+2,d0
	move.w	d0,6+8*2(a1)
	move.w	d0,6+8*2(a2)
	swap	d0
	move.w	d0,2+8*2(a1)
	move.w	d0,2+8*2(a2)

; bitplane 4 - parte 4 bytes piu` avanti

	MOVE.L	#BUFFER+4,d0
	move.w	d0,6+8*3(a1)
	move.w	d0,6+8*3(a2)
	swap	d0
	move.w	d0,2+8*3(a1)
	move.w	d0,2+8*3(a2)

	lea	$dff000,a5		; CUSTOM REGISTER in a5

	bsr	InitPlasma		; inizializza la copperlist

; Inizializza i registri del blitter

	Btst	#6,2(a5)
WaitBlit_init:
	Btst	#6,2(a5)		; aspetta il blitter
	bne.s	WaitBlit_init

	moveq	#-1,d0			; D0 = $FFFFFFFF
	move.l	d0,$44(a5)		; BLTAFWM/BLTALWM

	move.w	#$8000,$42(a5)		; BLTCON1 - shift 8 pixel canale B
					; (usato per il plasma)

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
	move.w	#$30b8,$8e(a5)		; DiwStrt - usiamo una finestra piu`
					; piccola dello schermo per mascherare
					; i bordi ondulati.
	move.w	#$ee90,$90(a5)		; DiwStop

	move.w	#$0038,$92(a5)		; DDFStrt - vengono fetchati 40 bytes
	move.w	#$00d0,$94(a5)		; DDFStop
	move.w	d0,$104(a5)		; BPLCON2
	move.w	#$0080,$102(a5)		; BPLCON1 - i planes pari sono shiftati
					; di 8 pixel a destra
	move.w	#4,$108(a5)		; BPL1MOD = 4 - fetcha 40 bytes su 44
	move.w	#4,$10a(a5)		; BPL2MOD = 4 - fetcha 40 bytes su 44
	move.w	#$4200,$100(a5)		; BPLCON0 - 4 bitplanes attivi

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
; Questa routine crea i bitplanes realizzando l'effetto di oscillazione.
; Il buffer all'indirizzo "PlasmaLine" contiene una riga della figura.
; Questo buffer viene copiato nel buffer video tante volte quanto e` alto
; il plasma, formando cosi` tutta la figura. Ogni riga viene shiftata verso
; destra di un valore variabile, creando cosi` l'ondulazione.
;****************************************************************************

DoOriz:
	lea	OrizTab(pc),a0		; indirizzo tabella oscillazioni
	lea	BUFFER,a1		; indirizzo buffer video (destinazione)
	lea	PlasmaLine,a3		; indirizzo buffer che contiene la
					; linea (sorgente)

	move.w	#1*64+19,d2		; dimensione blittata:
					; larghezza 40 bytes
					; altezza 1 linea

; legge e modifica indice

	move.w	IndiceO(pc),d4		; legge l'indice di partenza del
					; frame precedente
	sub.w	#NuovoFrameO,d4		; modifica l'indice nella tabella
					; dal frame precedente
	and.w	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 256 bytes)
	move.w	d4,IndiceO		; memorizza l'indice di partenza per
					; il prossimo frame

	move.w	#Alt_plasm-1,d3		; loop per ogni riga
OrizLoop:
	move.b	0(a0,d4.w),d0		; leggi valore dell'oscillazione

	moveq	#0,d1			; pulisce D1
	move.b	d0,d1			; copia valore oscillazione
	and.w	#$000f,d0		; lascia solo i 4 bit bassi
	ror.w	#4,d0			; li sposta nelle prime posizioni
	or.w	#$09f0,d0		; valore da scrivere in BLTCON0

	asr.w	#4,d1			
	add.w	d1,d1			; calcola numero di bytes
	lea	(a1,d1.w),a2		; indirizzo sorgente

	Btst	#6,2(a5)
WaitBlit_Oriz:
	Btst	#6,2(a5)		; aspetta il blitter
	bne.s	WaitBlit_Oriz

	move.w	d0,$40(a5)		; BLTCON0 - copia da A a D con shift
	move.l	a3,$50(a5)		; BLTAPT - indirizzo sorgente
	move.l	a2,$54(a5)		; BLTDPT - indirizzo destinazione
	move.w	d2,$58(a5)		; BLTSIZE

	lea	44(a1),a1		; punta alla prossima riga 
					; del buffer video

; modifica indice per prossima riga

	add.w	#NuovaRigaO,d4		; modifica l'indice nella tabella
					; per la prossima riga

	and.w	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 256 bytes)
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
	move.l	#$303FFFFE,d0	; carica la prima istruzione wait in D0.
				; aspetta la riga $30 e la posizione
				; orizzontale $3F

	move.w	#Alt_plasm-1,d3		; loop per ogni riga
InitLoop1:

	move.l	d0,(a0)+		; scrive la WAIT - (clist 1)
	move.l	d0,(a1)+		; scrive la WAIT - (clist 2)
	add.l	#$01000000,d0		; modifica la WAIT per aspettare
					; la riga seguente

	moveq	#Largh_plasm/8-1,d2	; ogni iterazione scrive 8 copper moves

InitLoop2:

; copperlist 1

	move.w	#$0194,(a0)+		;comb 10
	addq.w	#2,a0			; spazio per la seconda parte
					; della "copper move"
	move.w	#$019a,(a0)+		; colore 13
	addq.w	#2,a0
	move.w	#$018c,(a0)+		; colore 6
	addq.w	#2,a0
	move.w	#$0196,(a0)+		; colore 11
	addq.w	#2,a0
	move.w	#$018a,(a0)+		; colore 5
	addq.w	#2,a0
	move.w	#$0184,(a0)+		; colore 2
	addq.w	#2,a0
	move.w	#$0192,(a0)+		; colore 9
	addq.w	#2,a0
	move.w	#$0188,(a0)+		; colore 4
	addq.w	#2,a0

; copperlist 2

	move.w	#$0194,(a1)+		; colore 10
	addq.w	#2,a1			; spazio per la seconda parte
					; della "copper move"
	move.w	#$019a,(a1)+		; colore 13
	addq.w	#2,a1
	move.w	#$018c,(a1)+		; colore 6
	addq.w	#2,a1
	move.w	#$0196,(a1)+		; colore 11
	addq.w	#2,a1
	move.w	#$018a,(a1)+		; colore 5
	addq.w	#2,a1
	move.w	#$0184,(a1)+		; colore 2
	addq.w	#2,a1
	move.w	#$0192,(a1)+		; colore 9
	addq.w	#2,a1
	move.w	#$0188,(a1)+		; colore 4
	addq.w	#2,a1
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
	lea	38(a1),a1		; indirizzo prima word della prima
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

	moveq	#Largh_plasm-6-1,d2	; il loop NON viene ripetuto per tutta
					; la larghezza. Le colonne piu` a
					; destra non sono visibili,
					; quindi e` inutile blittarle.

	Btst	#6,2(a5)		; inizializza i registri blitter
WaitBlit_Plasma:			; per il plasma
	Btst	#6,2(a5)		; aspetta il blitter
	bne.s	WaitBlit_Plasma

	move.w	#$4FFE,$40(a5)		; BLTCON0 - D=A+B+C, shift A = 4 pixel

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
; oscillazioni

IndiceO:	dc.w	0

; Questa tabella contiene i valori delle oscillazioni

OrizTab:
	DC.B	$1C,$1D,$1E,$1E,$1F,$20,$20,$21,$22,$22,$23,$24,$24,$25,$25,$26
	DC.B	$27,$27,$28,$28,$29,$2A,$2A,$2B,$2B,$2C,$2C,$2D,$2D,$2E,$2E,$2F
	DC.B	$2F,$30,$30,$31,$31,$31,$32,$32,$33,$33,$33,$34,$34,$34,$35,$35
	DC.B	$35,$35,$36,$36,$36,$36,$36,$36,$37,$37,$37,$37,$37,$37,$37,$37
	DC.B	$37,$37,$37,$37,$37,$37,$37,$37,$36,$36,$36,$36,$36,$36,$35,$35
	DC.B	$35,$35,$34,$34,$34,$33,$33,$33,$32,$32,$31,$31,$31,$30,$30,$2F
	DC.B	$2F,$2E,$2E,$2D,$2D,$2C,$2C,$2B,$2B,$2A,$2A,$29,$28,$28,$27,$27
	DC.B	$26,$25,$25,$24,$24,$23,$22,$22,$21,$20,$20,$1F,$1E,$1E,$1D,$1C
	DC.B	$1C,$1B,$1A,$1A,$19,$18,$18,$17,$16,$16,$15,$14,$14,$13,$13,$12
	DC.B	$11,$11,$10,$10,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0B,$0A,$0A,$09
	DC.B	$09,$08,$08,$07,$07,$07,$06,$06,$05,$05,$05,$04,$04,$04,$03,$03
	DC.B	$03,$03,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01
	DC.B	$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$03,$03
	DC.B	$03,$03,$04,$04,$04,$05,$05,$05,$06,$06,$07,$07,$07,$08,$08,$09
	DC.B	$09,$0A,$0A,$0B,$0B,$0C,$0C,$0D,$0D,$0E,$0E,$0F,$10,$10,$11,$11
	DC.B	$12,$13,$13,$14,$14,$15,$16,$16,$17,$18,$18,$19,$1A,$1A,$1B,$1C

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
	dc.w	$e8,$0000,$ea,$0000	; bitplane 3
	dc.w	$ec,$0000,$ee,$0000	; bitplane 4

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.

PLASMA1:
	dcb.b	alt_plasm*BytesPerRiga,0
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

COPPERLIST2:
	dc.w	$e0,$0000,$e2,$0000	; bitplane 1
	dc.w	$e4,$0000,$e6,$0000	; bitplane 2
	dc.w	$e8,$0000,$ea,$0000	; bitplane 3
	dc.w	$ec,$0000,$ee,$0000	; bitplane 4

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

;****************************************************************************
; Buffer contenente una riga dell'immagine (44 bytes) che costituisce i planes
; L'immagine viene formata copiando questo buffer tante volte quanto e` alto
; il plasma nel buffer video.
;****************************************************************************

PlasmaLine:
	rept	5
	dc.l	$00ff00ff,$ff00ff00
	endr
	dc.l	$00ff00ff

;****************************************************************************

	SECTION	PlasmaBit,BSS_C

; Spazio per i bitplane. Per tutti e 4 i bitplanes si usa un'immagine larga
; 44 bytes e alta come tutto il plasma

BUFFER:
	ds.b	44*Alt_Plasm

	end



;****************************************************************************

In questo esempio mostriamo un plasma a 4 bitplane con ondulazione di ampiezza
pari a 56 pixel.
Per raggiungere questo risultato utilizziamo 8 registri colore nel plasma che
vengono cambiati ciclicamente. Questo vuol dire che un registro mantiene un
valore costante per 8*8=64 pixel. Quindi un gruppo di 8 pixel puo` muoversi
di 64-8=56 pixel rimanendo sempre all'interno della fascia in cui il colore e`
costante. Per realizzare ondulazioni cosi` ampie non possiamo usare lo scroll
hardware. Come conseguenza non possiamo usare per tutta l'immagine la stessa
riga ripetuta con il modulo negativo. Abbiamo bisogno di un'immagine completa,
in maniera tale che ogni riga possa essere shiftata indipendentemente dalle
altre. Procediamo in questo modo. Abbiamo un buffer dove viene memorizzata la
riga che costituisce l'immagine. Il contenuto di questo buffer viene copiato
in buffer video, tante volte quante sono le righe che costituiscono il plasma
in modo da costruire l'immagine voluta riga per riga. Ogni riga viene
opportunamente shiftata per realizzare l'ondulazione.
Se dovessimo copiare tutte le righe di tutti i bitplanes dovremmo effettuare
un gran numero di blittate. Per ridurre il numero di blittate usiamo un
trucco. In pratica usiamo la stessa immagine per tutti i bitplanes.
Il buffer di partenza e` fatto nel modo seguente:

 dc.l	$00ff00ff,$ff00ff00,$00ff00ff,$ff00ff00 - - -

Una volta che lo abbiamo copiato nel buffer video puntiamo il primo bitplane
all'inizio del buffer video, il secondo e il terzo 2 bytes dopo l'inizio
del buffer video e il quarto, 4 bytes dopo l'inizio del buffer video.
Inoltre i bitplanes pari li shiftiamo di 8 pixel.
Riassumendo:
bitplane 1 punta a BUFFER
bitplane 2 punta a BUFFER+2 + shift di 8 pixel a destra
bitplane 3 punta a BUFFER+2
bitplane 4 punta a BUFFER+4 + shift di 8 pixel a destra

I planes si sovrappongono generando 8 colori:

bitplane 1: dc.l $00ff00ffff00ff0000 ff00ffff00ff0000 ff00ffff00ff0000
bitplane 2: dc.l $--00ffff00ff0000ff 00ffff00ff0000ff 00ffff00ff0000
bitplane 3: dc.l $00ffff00ff0000ff00 ffff00ff0000ff00 ffff00ff0000
bitplane 4: dc.l $--ff00ff0000ff00ff ff00ff0000ff00ff ff00ff0000
                   | | | | | | | | |  | | | | | | | |
colore             --  06  05  09  10   06  05  09  10
		     13  11  02  04   13  11  02  04

come vedete si genera una ripetizione ciclica di 8 colori, che vengono usati
nella copperlist per generare il plasma.
In questo modo, abbiamo una sola immagine che viene usata per tutti e 4 i
planes, e quindi copiando questa sola immagine copiamo 4 bitplanes con un colpo
velocizzando molto l'effetto.
Veniamo ora ai dettagli tecnici. Ogni bitplane e` largo 40 bytes. Poiche` il
bitplane 4 inizia 4 bytes dopo il bitplane 1, dovra` anche finire 4 bytes dopo.
A causa di questo fatto, il buffer video (che contiene tutti e 4 i bitplanes)
e` largo 44 bytes, quindi i registri BPLxMOD avranno valore 4.
Inoltre, a causa degli shift dei bitplane, l'immagine non e` rettangolare ma
ha i bordi ondulati. Inoltre al bordo sinistro la corrispondenza dei bitplanes
no e` perfetta. Per non mostrare i difetti ai bordi abbiamo ristretto la
finestra video con i registri DIWSTRT e DIWSTOP. Se volete vedere cosa accade
ai bordi allargatela. 
A causa di questo restringimento, le colonne piu` a destra del plasma non si
vedono e quindi e` inutile blittarle (quelle piu` a sinistra anche se non
si vedono vanno comunue blittate perche` la fascia nella quale un colore rimane
costante e` parzialmente visibile).

