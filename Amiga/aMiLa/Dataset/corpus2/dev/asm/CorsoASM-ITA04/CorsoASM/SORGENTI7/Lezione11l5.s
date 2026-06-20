
; Lezione11l5.s   - "Zoom" di un'animazione che misura solo 40*29 pixel.
;		     La risoluzione finale e' 320*232, ossia 8 volte tanto.

	Section ZoomaPer8,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************

; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper,bitplane DMA abilitati

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

scr_bytes	= 40	; Numero di bytes per ogni linea orizzontale.
			; Da questa si calcola la larghezza dello schermo,
			; moltiplicando i bytes per 8: schermo norm. 320/8=40
			; Es. per uno schermo largo 336 pixel, 336/8=42
			; larghezze esempio:
			; 264 pixel = 33 / 272 pixel = 34 / 280 pixel = 35
			; 360 pixel = 45 / 368 pixel = 46 / 376 pixel = 47
			; ... 640 pixel = 80 / 648 pixel = 81 ...

scr_h		= 256	; Altezza dello schermo in linee
scr_x		= $81	; Inizio schermo, posizione XX (normale $xx81) (129)
scr_y		= $2c	; Inizio schermo, posizione YY (normale $2cxx) (44)
scr_res		= 1	; 2 = HighRes (640*xxx) / 1 = LowRes (320*xxx)
scr_lace	= 0	; 0 = non interlace (xxx*256) / 1 = interlace (xxx*512)
ham		= 0	; 0 = non ham / 1 = ham
scr_bpl		= 3	; Numero Bitplanes

; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)+(ham<<11)
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


START:
	move.l	#planexpand,d0	; bitplanebuffer
	LEA	BPLPOINTERS,A0
	MOVE.W	#3-1,D7		; Numero planes
PointAnim:
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)
	ADDQ.W	#8,A0
	SWAP	D0
	ADDI.L	#40*29,D0	; lunghezza del bitplane di 1 frame
	DBRA	D7,PointAnim

	bsr.w	FaiCopallung	; Fai la copperlist che allunga *8 coi moduli

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPER,$80(a5)		; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$11500,d2	; linea da aspettare = $115
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $115
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $115
	BEQ.S	Waity2

	bsr.w	CambiaFrame	; Espandi orizzontalmente il frame attuale
				; di 8 volte: in pratica ogni bit diventa
				; un byte.

	btst	#6,$bfe001	; Mouse premuto?
	bne.s	mouse
	rts			; esci

****************************************************************************
; Routine che esegue "ZoomaFrame" ogni 7 fotogrammi, per rallentare
****************************************************************************

CambiaFrame:
	addq.b	#1,WaitFlag
	cmp.b	#7,WaitFlag	; Sono passati 7 frames? (per rallentare)
	bne.s	NonOra
	clr.b	WaitFlag
	bsr.w	ZoomaFrame	; Se si, "espandiamo" il prossimo frame!
NonOra:
	rts

WaitFlag:
	dc.w	0

****************************************************************************
; "espansione" delle pic: viene testato ogni bit, e a seconda se quest'ultimo
; e' settato o azzerato, viene immesso un byte $FF o $00.
; Da notare il BYTELOOP, che e' il centro del programma: un byte deve essere
; trasformato in 8 bytes, per cui ogni bit del byte deve essere trasformato
; in un byte. Come fare? Basta fare un btst di ognuno degli 8 bit, e ogni
; volta muovere il byte $00 o $ff a seconda dell'esito del test.
; Viene usato il registro d1 come contatore del loop dbra, ma anche come
; contatore del numero di bit da testare col btst.
****************************************************************************

;	___________
;	\      _  /
;	 \ oO  / /
;	  \\__/ /
;	   \___/____  .--*
;	     \______--'
;	      |    |
;	     _|   _|...g®m ...

ZoomaFrame:
	move.l	AnimPointer(PC),A0 ; Fotogramma piccolo attuale (40*29)
	lea	Planexpand,A1	   ; Buffer destinazione (per 320*29)
	MOVE.W	#(5*29*3)-1,D7	   ; 5 bytes a linea * 29 linee * 3 bitplanes
Animloop:
	moveq	#0,d0
	move.b	(A0)+,d0	; Prossimo byte in d0
	MOVEQ	#8-1,D1		; 8 bit da controllare e espandere.
BYTELOOP:
	BTST.l	D1,d0		; Testa il bit del loop attuale
	BEQ.S	bitclear	; E' azzerato?
	ST.B	(A1)+		; Se no, setta il byte (=$FF)
	BRA.S	bitset
bitclear:
	clr.B	(A1)+		; Se e' azzerato, azzera il byte
bitset:
	DBRA	D1,BYTELOOP	; Controlla ed espandi tutti i bit del byte:
				; D1, calando, ogni volta fa fare il btst di
				; un bit diverso, dal 7 allo 0.

	DBRA	D7,Animloop	; Converti tutto il fotogramma

	add.l	#(5*29)*3,AnimPointer	; Punta al prossimo fotogramma
	move.l	AnimPointer(PC),A0
	lea	FineAnim(PC),a1
	cmp.l	a0,a1			; Era l'ultimo fotogramma?
	bne.s	NonRiparti
	move.l	#cannoanim,AnimPointer	; Se si, ripartiamo dal primo
NonRiparti:
	rts

AnimPointer:
	dc.l	cannoanim

****************************************************************************
; Routine che crea la copperlist che allunga la pic di 8 volte, usando i
; moduli in questo modo: waita una linea, poi mette i moduli a 0, in modo
; che si scatti alla linea dopo, poi riwaita la linea sotto e mette il
; modulo a -40, in modo che la stessa linea venga "replicata" ogni linea
; sotto. Dopo 7 linee waita, mette il modulo a 0 per una linea, facendo
; scattare a quella sotto, poi rimette il modulo a -40 per altre 7 linee
; per replicarla. Il risultato e' che ogni linea e' ripetuta 8 volte.
****************************************************************************

;	   ______
;	 _/      \_
;	 \        /
;	 _\ °  __/-
;	 \_\__/  (·)__
;	   \   )__  __)
;	    \___\_\/
;	   ./_    \.
;	   | |   | |
;	   | |___|_.-_
;	   (______)__/
;	     |___| |
;	     \_ _|_|
;	  _   | |(_)  _
;	 / \__|_|_|__/ \
;	(_______|_______)

FaiCopallung:
	lea	AllungaCop,a0	; Buffer in copperlist
	move.l	#$3407fffe,d0	; wait start
	move.l	#$1080000,d1	; bpl1mod 0
	move.l	#$10a0000,d2	; bpl2mod 0
	move.l	#$108FFD8,d3	; bpl1mod -40
	move.l	#$10aFFD8,d4	; bpl1mod -40
	moveq	#28-1,d7	; numero di loops
FaiCoppa:
	move.l	d0,(a0)+	; wait1
	move.l	d1,(a0)+	; bpl1mod = 0
	move.l	d2,(a0)+	; bpl2mod = 0
	add.l	#$01000000,d0	; salta 1 linea
	move.l	d0,(a0)+	; wait2
	move.l	d3,(a0)+	; bpl1mod = -40
	move.l	d4,(a0)+	; bpl2mod = -40
	add.l	#$07000000,d0	; salta 7 linee
	cmp.l	#$0407fffe,d0	; Siamo sotto $ff?
	bne.s	NonPAl
	move.l	#$ffdffffe,(a0)+ ; per accedere alla zona pal
NonPal:
	dbra	d7,FaiCoppa
	move.l	d0,(a0)+	; wait finale
	rts


****************************************************************************
; ANIMAZIONE: 8 fotogrammi larghi 40*29 pixel, a 8 colori (3 bitplanes)
****************************************************************************

; Animazione. ogni frame misura 40*29 pixel, 3 bitplanes. Tot. 8 frames

cannoanim:
	incbin	"frame1"	; 40*29 a 3 bitplanes (8 colori)
	incbin	"frame2"
	incbin	"frame3"
	incbin	"frame4"
	incbin	"frame5"
	incbin	"frame6"
	incbin	"frame7"
	incbin	"frame8"
FineAnim:

****************************************************************************
;			COPPERLISTOZZA
****************************************************************************

	Section	Copper,DATA_C

COPPER:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop

	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

BPLPOINTERS:
	dc.w $e0,0,$e2,0		;primo 	 bitplane
	dc.w $e4,0,$e6,0		;secondo    "
	dc.w $e8,0,$ea,0		;terzo      "

; 8 Colori

	dc.w	$180,$000,$182,$080,$184,$8c6
	dc.w	$186,$c20,$188,$d50,$18a,$e80,$18c,$0fb0
	dc.w	$18e,$ff0

	dc.w	$2c07,$FFFE	; wait

	dc.w	$100,BPLC0	; bplcon0 - 3 planes

	dc.w	$108,-40	; modulo negativo - ripeti stessa linea!
	dc.w	$10A,-40
AllungaCop:
	ds.b	6*4*28		; 2 wait + 4 move = 6*4 bytes * 21 loops
				; Questa copperlist allunga *8 cio' che e'
				; visualizzato, usando i moduli 0 e -40
				; alternati ogni 8 linee.
	ds.b	4*2		; Per il $ffdffffe e per l'ultimo wait

	dc.w	$100,$200	; bplcon0 - no bitplanes
	dc.w	$FFFF,$FFFE	; Fine copperlist

****************************************************************************
; Buffer dove viene "espanso" ogni fotogramma.
****************************************************************************

	SECTION	BitPlanes,BSS_C

PLANEXPAND:			; Dove viene espanso ogni fotogramma.
	ds.b	40*29*3		; 40 bytes * 29 linee * 3 bitplanes

	end
