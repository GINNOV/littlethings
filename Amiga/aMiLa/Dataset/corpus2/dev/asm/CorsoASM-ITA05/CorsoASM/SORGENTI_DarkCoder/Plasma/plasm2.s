
; Plasma2.s	Plasma RGB a 0-bitplanes
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

BytesPerRiga	equ	(Largh_plasm+2)*4	; numero di bytes occupati
						; nella copperlist da ogni col.
						; del plasma: ogni istruzione
						; copper occupa 4 bytes

Alt_plasm	equ	190		; altezza del plasma espressa
					; come numero di linee

NuovaColR	equ	-2		; valore sommato all'indice R nella
					; SinTab tra una col. e l'altra
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovoFrameR	equ	8		; valore sottratto all'indice R nella
					; SinTab tra un frame e l'altro
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovaColG	equ	2		; come "NuovaColR" ma per componente G
NuovoFrameG	equ	2		; come "NuovoFrameR" ma componente G

NuovaColB	equ	4		; come "NuovaColR" ma per componente B
NuovoFrameB	equ	-6		; come "NuovoFrameR" ma componente B


START:
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
mod_D	set	2			; modulo canale D: colonna seguente

	move.l	#mod_A<<16+mod_D,$64(a5)	; carica i registri modulo

; moduli canali B e C = 0

	moveq	#0,d0
	move.l	d0,$60(a5)		; scrive BLTBMOD e BLTCMOD


; Inizializza altri registri hardware

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST1,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA
	move.w	#$000,$180(a5)		; COLOR00 - nero
	move.w	#$0200,$100(a5)		; BPLCON0 - no bitplanes attivi

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.s	ScambiaClists	; scambia le copperlist

	bsr.s	DoPlasma

	btst	#6,$bfe001	; mouse premuto?
	bne.w	mouse
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
; istruzioni WAIT e le prima meta` delle COPPERMOVE. Alla fine della riga
; del plasma viene inserita un ultima COPPERMOVE che carica il colore
; nero in COLOR00.
;****************************************************************************

InitPlasma:
	lea	Plasma1,a0	; indirizzo plasma 1
	lea	Plasma2,a1	; indirizzo plasma 2
	move.l	#$383dFFFE,d0	; carica la prima istruzione wait in $3d.
				; aspetta la riga $60 e la posizione
				; orizzontale $58
	move.w	#$180,d1	; mette in D1 la prima meta` di un istruzione 
				; "copper move" in COLOR00 (=$dff180)

	move.w	#Alt_plasm-1,d3		; loop per ogni riga
InitLoop1:
	move.l	d0,(a0)+		; scrive la WAIT - (clist 1)
	move.l	d0,(a1)+		; scrive la WAIT - (clist 2)
	add.l	#$01000000,d0		; modifica la WAIT per aspettare
					; la riga seguente

	moveq	#Largh_plasm,d2		; loop per tutta la larghezza
					; del plasma + una volta per
					; l'ultima "copper move" che rimette
					; il nero come sfondo

InitLoop2:
	move.w	d1,(a0)+		; scrive la prima parte della
					; "copper move" - clist 1
	addq.l	#2,a0			; spazio per la seconda parte
					; della "copper move" - clist 1

	move.w	d1,(a1)+		; scrive la prima parte della
					; "copper move" - clist 2
	addq.l	#2,a1			; spazio per la seconda parte
					; della "copper move" - clist 2

	dbra	d2,InitLoop2

	dbra	d3,InitLoop1	
	rts


;****************************************************************************
; Questa routine realizza il plasma. Effettua un loop di blittate, ciascuna
; delle quali scrive una "riga" del plasma, cioe` scrive i colori nelle
; COPPERMOVES messe in riga.
; Viene realizzato un plasma RGB. La 3 componenti vengono lette separatamente
; e "OR-ate" insieme. Per le 3 componenti si usa un'unica tabella, che pero`
; viene letta in posizioni diverse e "percorsa" a velocita` differenti tra
; una riga e l'altra e tra un frame e l'altro. In questo modo e` come avere
; 3 tabelle differenti.
; La tabella contiene in realta` i valori della componente R. Per ottenere
; i valori delle altre componenti G e` necessario shiftare i dati letti a
; destra, di 4 per la G e di 8 per la B. Cio` viene fatto "al volo" dagli
; shifter del blitter.
;****************************************************************************

DoPlasma:

	lea	Color,a0		; indirizzo colori
	lea	SinTab,a6		; indirizzo tabella offsets
	move.l	draw_clist(pc),a1	; indirizzo copperlist dove scrivere
	lea	22(a1),a1		; aggiunge offset necessario per
					; puntare la prima word della prima
					; riga del plasma
					; (bisonga saltare le 4 istruzioni
					; iniziali, la wait di inizio riga
					; e la prima word della "copper move")

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

	move.w	#Largh_plasm<<6+1,d3	; dimensione blittata
					; largh. 1 word, alta quanto
					; la larghezza del plasma

	move.w	#Alt_plasm-1,d2		; loop per tutta l'altezza

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
					; (copiata cosi` com'e`)
	move.l	a3,$50(a5)		; BLTAPT - indirizzo sorgente G
					; (viene shiftata di 4 a destra)
	move.l	a4,$4C(a5)		; BLTBPT - indirizzo sorgente B
					; (viene shiftata di 8 a destra)
	move.l	a1,$54(a5)		; BLTDPT - indirizzo destinazione
	move.w	d3,$58(a5)		; BLTSIZE

	lea	BytesPerRiga(a1),a1	; punta alla prossima riga di 
					; "copper moves" nella copper list

; modifica indice componente R per prossima col.

	add.w	#NuovaColR,d4		; modifica l'indice nella tabella
					; per la prossima col.

	and.w	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

; modifica indice componente G per prossima col.

	add.w	#NuovaColG,d5		; modifica l'indice nella tabella
					; per la prossima col.

	and.w	#$00FF,d5		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

; modifica indice componente B per prossima col.

	add.w	#NuovaColB,d6		; modifica l'indice nella tabella
					; per la prossima col.

	and.w	#$00FF,d6		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	dbra	d2,PlasmaLoop
	rts


; Queste 2 variabili contengono gli indirizzi delle 2 copperlist

view_clist:	dc.l	COPPERLIST1	; indirizzo clist visualizzata
draw_clist:	dc.l	COPPERLIST2	; indirizzo clist dove disegnare


; Queste variabili contengono i valori degli indici per la prima colonna

IndiceR:	dc.w	0
IndiceG:	dc.w	0
IndiceB:	dc.w	0

; Questa tabella contiene gli offset per l'indirizzo di partenza nella
; tabella dei colori

SinTab:
	DC.W	$000E,$0010,$0010,$0010,$0012,$0012,$0012,$0014,$0014,$0014
	DC.W	$0014,$0016,$0016,$0016,$0018,$0018,$0018,$0018,$001A,$001A
	DC.W	$001A,$001A,$001A,$001A,$001C,$001C,$001C,$001C,$001C,$001C
	DC.W	$001C,$001C,$001C,$001C,$001C,$001C,$001C,$001C,$001C,$001C
	DC.W	$001A,$001A,$001A,$001A,$001A,$001A,$0018,$0018,$0018,$0018
	DC.W	$0016,$0016,$0016,$0014,$0014,$0014,$0014,$0012,$0012,$0012
	DC.W	$0010,$0010,$0010,$000E,$000E,$000C,$000C,$000C,$000A,$000A
	DC.W	$000A,$0008,$0008,$0008,$0008,$0006,$0006,$0006,$0004,$0004
	DC.W	$0004,$0004,$0002,$0002,$0002,$0002,$0002,$0002,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0002,$0002,$0002,$0002,$0002,$0002
	DC.W	$0004,$0004,$0004,$0004,$0006,$0006,$0006,$0008,$0008,$0008
	DC.W	$0008,$000A,$000A,$000A,$000C,$000C,$000C,$000C
EndSinTab:

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

; Abbiamo 2 copperlists 

COPPERLIST1:
	dc.w	$3007,$fffe	; wait linea $40
	dc.w	$0180,$c00	; color0
	dc.w	$3407,$fffe	; wait linea $44
	dc.w	$0180,$000	; color0

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.

Plasma1:
	dcb.b	alt_plasm*BytesPerRiga,0

	dc.w	$FA07,$fffe	; wait linea $e0
	dc.w	$0180,$c00	; color0
	dc.w	$FE07,$fffe	; wait linea $e4
	dc.w	$0180,$000	; color0

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

COPPERLIST2:
	dc.w	$3007,$fffe	; wait linea $40
	dc.w	$0180,$c00	; color0
	dc.w	$3407,$fffe	; wait linea $44
	dc.w	$0180,$000	; color0

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.

Plasma2:
	dcb.b	alt_plasm*BytesPerRiga,0

	dc.w	$FA07,$fffe	; wait linea $e0
	dc.w	$0180,$c00	; color0
	dc.w	$FE07,$fffe	; wait linea $e4
	dc.w	$0180,$000	; color0

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;****************************************************************************
; Qui c'e` la tabella da dove vengono lette le componenti dei colori.
; La tabella contiene delle componenti R. Per ottenere le componenti G e
; B, e` sufficente shiftare i dati letti con il blitter.
; Devono esserci abbastanza valori da essere letti qualunque sia l'indirizzo
; di partenza. In questo esempio l'indirizzo di partenza puo` variare da
; "Color" (primo colore) fino a "Color+28" (14-esimo colore), perche`
; 60 e` il massimo offset sontenuto nella "SinTab".
; Se Largh_plasm=40 vuol dire che ogni blittata legge 40 valori.
; Quindi in totale devono esserci 54 valori.
;****************************************************************************

Color:
	dcb.w	2,0

	DC.W	$0100,$0300,$0500,$0600,$0800,$0A00,$0B00,$0C00,$0D00,$0E00
	DC.W	$0F00,$0F00,$0F00,$0F00,$0F00,$0E00,$0D00,$0C00,$0B00,$0A00
	DC.W	$0800,$0600,$0500,$0300,$0100

	dcb.w	2,0

	DC.W	$0100,$0300,$0500,$0600,$0800,$0A00,$0B00,$0C00,$0D00,$0E00
	DC.W	$0F00,$0F00,$0F00,$0F00,$0F00,$0E00,$0D00,$0C00,$0B00,$0A00
	DC.W	$0800,$0600,$0500,$0300,$0100

	end

;****************************************************************************

In questo esempio vediamo un plasma RGB.
Date le dimensioni del plasma e la complessita` della blittata (a 3 canali) non
sarebbe possibile modificare tutta la copperlist prima che finisca il vertical
blank e di conseguenza una parte della copperlist viene visualizzata prima
di essere stata modificata. Per risolvere il problema e` necessario utilizzare
il "double buffering" delle copperlist. Si tratta di una tecnica che abbiamo
gia` visto nell'esempio lezione11i2.s: si utilizzano 2 copperlist, che vengono
visualizzate alternativamente. Mentre una delle 2 viene visualizzata, la
routine di plasma scrive nell'altra. Esattamente come il "double buffering"
dei bitplanes. Lo scambio delle copperlist e` effettuato dalla routine
"ScambiaClists".
Per realizzare il plasma RGB si utilizza una blittata che combina con un
operazione di OR le componenti R,G e B di un colore che vengono lette
separatamente. Per risparmiare memoria, si e` usata una sola tabella di
componenti. Tale tabella contiene le componenti R. Per ottenere le componenti
G e B e` sufficente shiftare verso destra i dati letti, operazione che puo`
essere effettuata "al volo" dal blitter. Notate comunque che i valori delle
componenti vengono lette da punti differenti della tabella. Infatti per ogni
componente abbiamo un indice che viene incrementato separatamente (e con una
diversa velocita`).
In questo plasma, a differenza di quello visto in plasm1.s le blittate
avvengono "per riga". Ogni blittata cioe` riempie una riga del plasma,
mentre in plsm1.s ogni blittata riempiva una colonna.

