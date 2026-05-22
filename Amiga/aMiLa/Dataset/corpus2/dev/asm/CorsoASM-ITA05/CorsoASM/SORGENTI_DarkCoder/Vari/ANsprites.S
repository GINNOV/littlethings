
; Animazione degli sprite.
; Original version: Autore sconosciuto
; Fixed version: Randy/Ram Jam


	SECTION	xxxx,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110100000	; copper,bitplane,sprites

Waitdisk	EQU	10

CopiedSprites	EQU	20

START:

; Puntiamo il biplane azzerato

	MOVE.L	#PLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

; Puntiamo gli sprites

	MOVE.L	#BBUFFER,D0	  ; indirizzo dove sono copiati gli sprite
	LEA	SpritePointers,A1 ; indirizzo puntatori nella copperlist.
	moveq	#8-1,d1		  ; 8 sprites
Ploop:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#68,d0
	addq.w	#8,a1
	dbra	d1,Ploop

	lea	BBUFFER,a1	; destinazione
	moveq	#CopiedSprites-1,d1	; numero di copie
	bsr.w	sprite_copy	; Copia lo sprite 21 volte nel buffer

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPER,$80(a5)		; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $010
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $010
	Beq.S	Waity2

	btst	#2,$16(A5)	; Tasto destro premuto?
	beq.s	NonSpri

	bsr.w	doanim

	lea	$dff000,a5	; rimetti $dff000 in a5

NonSpri:
	btst	#6,$bfe001	; tasti sin. mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
; Routine che provvede all'animazione degli sprite, secondo le tabelle
*****************************************************************************

doanim:
	subq.w	#1,countera	; waitcounter -1
	tst.w	countera	; siamo arrivati a 0?
	bne.s	StessaAnim	; Se non ancora, ok... altrimenti...
	move.l	actionptr(PC),a0 ; Prossima animazione dalla tab!
	cmp.w	#-1,(a0)	; Siamo alla fine della tab?
	bne.s	Nonripart1	; Se non ancora, ok
	move.l	#action,actionptr ; altrimenti riparti da capo
	move.l	actionptr(PC),a0 ; dalla prima animazione...
Nonripart1:
	move.w	(a0),countera	; leffi il tempo di durata dell'animazione
	move.w	2(a0),speedx	; la velocita' X
	move.w	4(a0),speedy	; la velocita' Y
	move.l	6(a0),xptrs	; la tabella X
	move.l	10(a0),yptrs	; la tabella Y
	add.l	#14,actionptr	; Fai puntare alla prossima anim il pointer
StessaAnim:
	move.l	xptrs(PC),a0	; flugbahnx
	move.l	yptrs(PC),a1	; flugbahny
	moveq	#8-1,d7		; numero sprites = 8
	moveq	#0,d2
	moveq	#0,d3
	move.w	speedx(PC),d5	; d5 = addx
	move.w	speedy(PC),d6	; d6 = addy
animloop:
	move.w	(a0),d2		; val da tabx
	move.w	(a1),d3		; val da taby
	add.w	d5,d2		; aggiungi lo speedX
	cmp.w	#360,d2		; abbiamo superato 360?
	blt.s	nomax
	sub.w	#360,d2		; se si, scaliamo
nomax:
	move.w	d2,(a0)+	; salva X
	add.w	d6,d3		; aggiungi lo speedy al taby
	cmp.w	#360,d3		; superato 360?
	blt.s	nomax2
	sub.w	#360,d3		; se si, scala
nomax2:
	move.w	d3,(a1)+	; salva Y
	lea	sinus(PC),a2
	move	(a2,d2.w),d0	; prendi il val X da sintab
	lea	cosinus(PC),a2
	move	(a2,d3.w),d1	; prendi il val Y da costab
	movem.l	d0-d7/a0-a6,-(a7)
	mulu.w	#68,d7		; actualsprite*68 = offset giusto per sprite
	lea	BBUFFER+7*68,a1	; indirizzo ultimo sprite
	sub.l	d7,a1		; subbiamo per trovare l'assress sprite ok
	moveq	#0,d3		; 0 = non attacched
	moveq	#16,d2		; Altezza sprite
	add.l	#127+10,d0	; centra X
	add.l	#43,d1		; centra Y
	bsr.w	spr_control
	movem.l	(a7)+,d0-d7/a0-a6
	dbra	d7,animloop
	rts


*****************************************************************************
; Routine copia gli sprites nel buffer. Da 1 sprite se ne fanno XX	    *
*****************************************************************************

sprite_copy:
	lea	sprite1,a0	; sorgente: uno sprite
	moveq	#68/4,d0	; ogni sprite e' lungo 68 bytes
Copy_loop:
	move.l	(a0)+,(a1)+	; da sprite a destinazione (buf)
	subq.w	#1,d0
	bne.s Copy_loop
	dbra d1,sprite_copy	; fai d1 copie
	rts

actionptr:	dc.l	action
xptrs:		dc.l	x2ptr
yptrs:		dc.l	y2ptr
countera:	dc.w	1
speedx:		dc.w	4
speedy:		dc.w	4

;*****************************************************************************
; Routine di controllo degli sprite TEDESCA!. Parametri:
;
; A1 = Indirizzo dello sprite
; D0 = X Koordinate (0-512) (127 = minimo)
; D1 = Y koordinate (0-512) (43  = minimo)
; D2 = altezza dello Sprite
; D3 = (0 = Normale , 1 = Attached)
;*****************************************************************************

Spr_Control:
	movem.l	d0-d3/a1,-(a7)	; Register retten
	cmp.w	#512,d0		; x >= 512 
	bge.s	lab3 		; ja  --> to end 
	add.w	d1,d2	
	cmp.w	#512,d2		; y >= 512
	bge.s	Lab3		; ja  --> to end
	cmp.b	#01,d3		; test ob Attach Sprite
	bne.s	Lab0		; nein -->
	bset.b	#7,3(a1)	; sonst Attach Bit setzen
	bra.s	Lab1		; weiter
Lab0:
	bclr.b	#7,3(a1)	; Attach Bit Loeschen
Lab1:
	lsr.w	#1,d0		; X Position 1 Bit nach rechts schiften
	bcs.s	Sethorz		; Bit 0 gesetzt gewesen -->
	bclr.b	#0,3(a1)	; sonst Bit 0 der X Position setzen
	bra.s	Lab10		; weiter
Sethorz:
	bset.b	#0,3(a1)	; Bit 0 der X Position loeschen
Lab10:
	move.b	d0,1(a1)	; ermittelten Wert ablegen
	move.b	d1,(a1)		; Y Position ablegen
	btst.l	#8,d1		; Bit 8 in Y Position gesetzt
	beq.s	Yclr		; nein -->
	bset.b	#2,3(a1)	; sonst Bit 8 eintragen
	bra.s	lab2		; weiter
Yclr:
	bclr.b	#2,3(a1)	; Bit 8 als geloescht eintragen
Lab2:
	move.b	d2,2(a1)	; Spritealtezza eintragen
	btst.l	#8,d2		; ist Bit 8 gesetzt
	beq.s	Ystopclr	; nein -->	
	bset.b	#1,3(a1)	; sonst Bit 8 als gesetzt eintragen
	bra.s	lab3		; weiter
Ystopclr:
	bclr.b	#1,3(a1)	; Bit 8 als geloescht eintragen
Lab3:
	movem.l	(a7)+,d0-d3/a1	; Register wiederherstellen
	rts			; zurueck


*****************************************************************************
; La tabella con le caratteristiche delle varie animazioni in sequenza	    *
*****************************************************************************

Action:	
	dc.w	100,2,4		; Tempo durata, SpeedX, SpeedY (num. pari!)
	dc.l	x10ptr,y10ptr	; puntatore tabx, puntatore tabY

	dc.w	100,4,2
	dc.l	x2ptr,y2ptr

	dc.w	100,6,2
	dc.l	x2ptr,y2ptr

	dc.w	100,8,2
	dc.l	x2ptr,y2ptr

	dc.w	100,10,2
	dc.l	x2ptr,y2ptr

	dc.w    100,10,4
	dc.l	x2ptr,y2ptr

	dc.w	150,2,4
	dc.l	x4ptr,y4ptr

	dc.w    200,4,2
	dc.l	x4ptr,y4ptr

	dc.w	200,2,2
	dc.l	x6ptr,y6ptr

	dc.w    150,4,2
	dc.l	x6ptr,y6ptr

	dc.w	200,4,4
	dc.l	x8ptr,y8ptr

	dc.w    150,2,4
	dc.l	x8ptr,y8ptr

	dc.w	200,4,2
	dc.l	x1ptr,y1ptr

	dc.w    150,4,4
	dc.l	x1ptr,y1ptr

	dc.w	200,6,2
	dc.l	x3ptr,y3ptr

	dc.w    50,8,2
	dc.l	x3ptr,y3ptr

	dc.w	200,2,10
	dc.l	x5ptr,y5ptr

	dc.w	100,2,2
	dc.l	x2ptr,y2ptr

	dc.w	200,4,4
	dc.l	x7ptr,y7ptr

	dc.w	150,4,4
	dc.l	x9ptr,y9ptr

	dc.w	$FFFF		; flag di fine tab

;
;******** END OF ANIMATION SEQUENCE DATA *********
;

*****************************************************************************
; Le varie tabelle di X e Y add
*****************************************************************************

x2ptr:		dc.w	0,46,90,134,180,224,270,314
y2ptr:		dc.w	0,46,90,134,180,224,270,314

x4ptr:		dc.w	0,36,72,108,144,180,216,252,288,324
y4ptr:		dc.w	36,72,108,144,180,216,252,288,324,0

x6ptr:		dc.w	0,8,16,24,32,40,48,56,64,72
y6ptr:		dc.w	48,64,80,96,112,128,144,160,176,192

x8ptr:		dc.w	0,16,32,48,64,80,96,112,128,144
y8ptr:		dc.w	48,64,80,96,112,128,144,160,176,192

x1ptr:		dc.w	0,36,72,108,144,180,216,252,288,324
y1ptr:		dc.w	48,64,80,96,112,128,144,160,176,192

x3ptr:		dc.w	0,10,20,30,40,50,60,70,80,90
y3ptr:		dc.w	0,36,72,108,144,180,216,252,288,324

x5ptr:		dc.w	0,2,4,6,8,10,12,14,16,18
y5ptr:		dc.w	0,10,20,30,40,50,60,70,80,90

x7ptr:		dc.w	0,216,72,128,64,324,108,96,160,288
y7ptr:		dc.w	288,160,96,108,324,64,128,72,216,0

y9ptr:		dc.w	80,96,112,128,144,160,176,192,208,224
x9ptr:		dc.w	0,36,72,108,144,180,216,252,288,324

x10ptr:		dc.w	0,10,20,30,40,50,10,340
y10ptr:		dc.w	0,10,20,30,40,50,340,10

*****************************************************************************
; Le tabelle SIN/COS per le traiettorie curve
*****************************************************************************

sinus:
	dc.w	140,143,147,150,154,157,161,164,167,171
	dc.w	174,177,181,184,187,190,193,196,199,202
	dc.w	204,207,209,212,214,217,219,221,223,225
	dc.w	227,228,230,231,233,234,235,236,237,238
	dc.w	238,239,239,240,240,240,240,240,239,239
	dc.w	238,238,237,236,235,234,233,231,230,228
	dc.w	227,225,223,221,219,217,214,212,209,207
	dc.w	204,202,199,196,193,190,187,184,181,177
	dc.w	174,171,167,164,161,157,154,150,147,143
	dc.w	140,137,133,130,126,123,119,116,112,109
	dc.w	106,103,99,96,93,90,87,84,81,78,76,73,71
	dc.w	68,66,63,61,59,57,55,53,52,50,49,47,46,45
	dc.w	44,43,42,42,41,41,40,40,40,40,40,41,41
	dc.w	42,42,43,44,45,46,47,49,50,52,53,55,57
	dc.w	59,61,63,66,68,71,73,76,78,81,84,87,90
	dc.w	93,96,99,103,106,109,112,116,119,123,126
	dc.w	130,133,137
;
cosinus:
	dc.w	168,168,168,168,167,167,166,166,165,164,163
	dc.w	162,161,160,158,157,155,154,152,150,149,147
	dc.w	145,143,141,138,136,134,131,129,127,124,121
	dc.w	119,116,113,111,108,105,102,99,97,94,91,88
	dc.w	85,82,79,76,73,71,68,65,62,59,57,54,51,49
	dc.w	46,44,41,39,36,34,32,29,27,25,23,21,20,18
	dc.w	16,15,13,12,10,9,8,7,6,5,4,4,3,3,2,2,2,2
	dc.w	2,2,2,3,3,4,4,5,6,7,8,9,10,12,13,15,16
	dc.w	18,20,21,23,25,27,29,32,34,36,39,41,44,46
	dc.w	49,51,54,57,59,62,65,68,71,73,76,79,82,85
	dc.w	88,91,94,97,99,102,105,108,111,113,116,119
	dc.w	121,124,127,129,131,134,136,138,141,143,145
	dc.w	147,149,150,152,154,155,157,158,160,161,162
	dc.w	163,164,165,166,166,167,167,168,168,168
endsi:


*****************************************************************************
; I dati di 1 sprite, che saranno copiati 8 volte nel buffer in chip ram
*****************************************************************************

sprite1:			; dati dello sprite
	dc.w 0,0
	dc.w $07c0,0
	dc.w $1010,$0fe0
	dc.w $3798,$0fe0
	dc.w $6fdc,$1fe0
	dc.w $6f1c,$1fe0
	dc.w $e77e,$1f80
	dc.w $f0fe,$0f00
	dc.w $fffe,$0000
	dc.w $fffe,$0000
	dc.w $fffe,$0000
	dc.w $7ffc,$0000
	dc.w $7ffc,$0000
	dc.w $3ff8,$0000
	dc.w $1ff0,$0000
	dc.w $07c0,$0000
	dc.w 0,0		; fine sprite

*****************************************************************************

	section	gfx,data_C

copper:
	dc.w	$8e,$2c81	; diwstart
	dc.w	$90,$2cc1	; diwstop
	dc.w	$92,$38		; ddfstart
	dc.w	$94,$d0		; ddfstop

SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0,$13c,0,$13e,0

	dc.w	$108,0	; bpl1mod
	dc.w	$10a,0	; bpl2mod
	dc.w	$102,0	; bplcon1
	dc.w	$104,0	; bplcon2

BPLPOINTERS:
	dc.w	$e0,0,$e2,0	; plane 1

	dc.w	$100,$1200	; bplcon0 - 1 plane lowres

	dc.w	$180,0		; color0 - nero
	dc.w	$182,$fff	; color1 - bianco

	DC.W	$180,$000,$182,$000

; Colori degli sprite - da color17 a color31

	dc.w $1a2,$4d0	;  Colori sprite 0,1 (verde)
	dc.w $1a4,$ad8
	dc.w $1a6,$ffe
	dc.w $1a8,$4f0

	dc.w $1aa,$fe1	; Colori sprite 2,3 (giallo)
	dc.w $1ac,$fe4
	dc.w $1ae,$ffe
	dc.w $1b0,$fe2

	dc.w $1b2,$d20	; Colori sprite 4,5 (rosso)
	dc.w $1b4,$d88
	dc.w $1b6,$ffe
	dc.w $1b8,$f10

	dc.w $1ba,$40d	; Colori sprite 6,7 (blu)
	dc.w $1bc,$a8d
	dc.w $1be,$fef
	dc.w $1c0,$40f

	dc.w $ffff,$fffe	; Fine della copperlist


; ****************************************************************************

	section	spritezz,bss_C


BBUFFER:
	ds.b	68*CopiedSprites

; ****************************************************************************

	section	grafica,bss_C

plane:
	ds.b	40*256	; 1 plane lowres "nero" come sfondo.

