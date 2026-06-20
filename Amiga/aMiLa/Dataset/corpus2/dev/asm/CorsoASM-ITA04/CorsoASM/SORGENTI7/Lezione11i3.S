
; Lezione11i3.s	- Fantasia in COP minore

	SECTION	GnippiCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	bsr.w	Write		; Crea la copperlist...

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	CopperEffPointer,$80(a5)
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12000,d2	; linea da aspettare = $FF
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $FF
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $FF
	BEQ.S	Aspetta

	bsr.w	main

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts			; esci


CopperEffPointer:
	dc.l	Copperlist

colmemory:
	dc.l	colbuf



*****************************************************************************
;	Routine che crea la copperlist
*****************************************************************************

;	__/\__
;	\()()/
;	/_\/_\
;	  \/  

cxstart		equ	$26	; posizione X da cui iniziare
cystart		equ	$1c	; posizione Y da cui iniziare
ylinee		equ	280	; numero linee Y
xlinee		equ	10	; numero sezioni X
yDistanza	equ	1	; distanza verticale
xDistanza	equ	20	; distanza ORIZZONTALE tra "strisce"


write:
	move.l	CopperEffPointer(pc),a0	; indirizzo copper
	moveq	#cystart,d0		; posizione Y start
	move.w	#ylinee-1,d4		; numero linee Y da fare
cr2loop:
	moveq	#cxstart,d1		; posizione X start
	moveq	#xlinee-1,d3		; numero blocchi orizzontali da fare
FaiOrizz:
	move.w	d1,d2		; X in d2
	ori.b	#1,d2		; selez. solo bit 1
	move.b	d0,(a0)+	; WAIT - coord Y
	move.b	d2,(a0)+	; WAIT - coord X
	move.w	#$fffe,(a0)+	; seconda word del wait
	move.w	#$180,(a0)+	; registro color0
	clr.w	(a0)+		; color0 (ora azzerato)
	add.w	#xDistanza,d1	; scatta posizione X prossima "striscia"
	dbra	d3,FaiOrizz	; fai tutta la linea orizzontale

	addq.w	#yDistanza,d0	; aggiungi la distanza Y
	dbra	d4,cr2loop	; fai tutte le linee
	move.l	#$fffffffe,(a0)+ ; fine della copperlist!
	rts

*****************************************************************************
;	Routine che modifica la copperlist
*****************************************************************************

;	__/\__
;	\ oO /
;	/_<>_\
;	  \/  

speed		equ	6
stadd		equ	100


main:
	move.l	colmemory(pc),a0	; tabella per i colori
	lea	pointer1(pc),a1		; puntatore 1
	lea	addtable(pc),a2		; tabella con valori da addare
	moveq	#0,d4
	move.w	pointer2(pc),d4		; puntatore 2 in d4
	addq.w	#speed,d4		; + speed
	andi.w	#$1ff,d4		; seleziona solo 9 bit (max 511)
	move.w	d4,pointer2		; salva in puntatore 2
	bclr.l	#8,d4			; azzera bit 8
	beq.s	nosub			; =0 (era 256?)
	move.w	#$100,d1
	sub.w	d4,d1
	move.w	d1,d4
nosub:
	add.w	#stadd,d4	; salta 100
	moveq	#xlinee-1,d1	; num. linee X
Cstart:
	clr.w	d0
	move.b	(a2)+,d0	; prendi valore da addtable
	bclr.l	#7,d0
	bne.s	pstripe
	bclr.l	#6,d0
	bne.s	sub
	bclr.l	#5,d0
	bne.s	add
back:
	dbra	d1,Cstart	; fai per tutte le linee
	bra.s	copy

*****************************************************************************

add:
	bsr.s	addr
	bra.s	back

sub:
	bsr.s	subr
	bra.s	back	

sub1:
	bsr.s	subr
	bra.s	sback

add1:
	bsr.s	addr
	bra.s	sback

*****************************************************************************

;	__/\__
;	\-OO-/
;	/_-)_\
;	  \/

colors		equ	210	; num coloritab

addr:
	moveq	#0,d2
	move.w	(a1),d2
	add.w	d0,d2
	cmp.w	#colors-2,d2	; finiti i colori tab?
	blo.s	noclr
	clr.w	d2
noclr:
	move.w	d2,(a1)+
	bra.s	do_it

*****************************************************************************

;	__/\__
;	\[oO]/
;	/_{}_\
;	  \/

subr:
	moveq	#0,d2
	move.w	(a1),d2
	sub.w	d0,d2
	bpl.s	nomove
	move.w	#colors-2,d2
nomove:
	move.w	d2,(a1)+
do_it:
	lea	colortable(pc),a4
	add.l	d2,a4
	move.w	#ylinee/2-1,d2
do_loop:
	move.l	(a4)+,(a0)+	; metti colori in coplist
	dbra	d2,do_loop
	rts

*****************************************************************************

;	\      _      /
;	 \    (ö)    /
;	  \  '(_)`  /
;	   \  ¯ ¯  /

pstripe:
	move.l	a0,d3
	bclr.l	#5,d0
	bne.s	add1
	bclr.l	#6,d0
	bne.s	sub1	
clear:
	move.w	#ylinee/2-1,d2
clloop:
	clr.l	(a0)+		; azzera tutte le linee
	dbra	d2,clloop
sback:
	move.l	d3,a0	
	add.l	d4,a0
	moveq	#stlinee/4-1,d2
	lea	stable(pc),a4
csloop:
	move.l	(a4)+,(a0)+	; copia dalla stable i colori in cop
	dbra	d2,csloop
	move.l	d3,a0
	add.l	#ylinee*2,a0
	bra.s	back

*****************************************************************************

;	      :
;	     _|_
;	_ __/__/\__ _
;	    \__\/
;	      |
;	      :

copy:
	move.l	colmemory(pc),a0
	move.l	CopperEffPointer(pc),a1
	addq.w	#6,a1
	move.w	#ylinee-1,d0	; fai tutte le linee Y
coloop:
	move.w	(a0),(a1)
	move.w	ylinee*2(a0),8(a1)	; copia da colmemory a coplist
	move.w	ylinee*4(a0),8*2(a1)
	move.w	ylinee*6(a0),8*3(a1)
	move.w	ylinee*8(a0),8*4(a1)
	move.w	ylinee*10(a0),8*5(a1)
	move.w	ylinee*12(a0),8*6(a1)
	move.w	ylinee*14(a0),8*7(a1)
	move.w	ylinee*16(a0),8*8(a1)
	move.w	ylinee*18(a0),8*9(a1)
	lea	8*10(a1),a1
	addq.w	#2,a0
	dbra	d0,coloop
	rts

*****************************************************************************
;			TABELLE DEI COLORI
*****************************************************************************

colortable:
	dc.w	$001,$002,$003,$004,$005,$006,$007,$008,$009,$00a
	dc.w	$00b,$00c,$00d,$00e,$00f
	dc.w	$01f,$02f,$03f,$04f,$05f
	dc.w	$06f,$07f,$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
	dc.w	$0fe,$0fd,$0fc,$0fb,$0fa,$0f9,$0f8,$0f7,$0f6,$0f5
	dc.w	$0f4,$0f3,$0f2,$0f1,$0f0,$1f0,$2f0,$3f0,$4f0,$5f0
	dc.w	$6f0,$7f0,$8f0,$9f0,$af0,$bf0,$cf0,$df0,$ef0,$ff0
	dc.w	$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80,$f70,$f60,$f50
	dc.w	$f40,$f30,$f20,$f10,$f00,$f01,$f02,$f03,$f04,$f05
	dc.w	$f06,$f07,$f08,$f09,$f0a,$f0b,$f0c,$f0d,$f0e,$f0f
	dc.w	$e0e,$d0d,$c0c,$b0b,$a0a,$909,$808,$707,$606
	dc.w	$505,$404,$303,$202,$101,$000
colorend:
	dc.w	$001,$002,$003,$004,$005,$006,$007,$008,$009,$00a
	dc.w	$00b,$00c,$00d,$00e,$00f
	dc.w	$01f,$02f,$03f,$04f,$05f
	dc.w	$06f,$07f,$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
	dc.w	$0fe,$0fd,$0fc,$0fb,$0fa,$0f9,$0f8,$0f7,$0f6,$0f5
	dc.w	$0f4,$0f3,$0f2,$0f1,$0f0,$1f0,$2f0,$3f0,$4f0,$5f0
	dc.w	$6f0,$7f0,$8f0,$9f0,$af0,$bf0,$cf0,$df0,$ef0,$ff0
	dc.w	$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80,$f70,$f60,$f50
	dc.w	$f40,$f30,$f20,$f10,$f00,$f01,$f02,$f03,$f04,$f05
	dc.w	$f06,$f07,$f08,$f09,$f0a,$f0b,$f0c,$f0d,$f0e,$f0f
	dc.w	$e0e,$d0d,$c0c,$b0b,$a0a,$909,$808,$707,$606
	dc.w	$505,$404,$303,$202,$101,$000
	dc.w	$001,$002,$003,$004,$005,$006,$007,$008,$009,$00a
	dc.w	$00b,$00c,$00d,$00e,$00f
	dc.w	$01f,$02f,$03f,$04f,$05f
	dc.w	$06f,$07f,$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
	dc.w	$0fe,$0fd,$0fc,$0fb,$0fa,$0f9,$0f8,$0f7,$0f6,$0f5
	dc.w	$0f4,$0f3,$0f2,$0f1,$0f0,$1f0,$2f0,$3f0,$4f0,$5f0
	dc.w	$6f0,$7f0,$8f0,$9f0,$af0,$bf0,$cf0,$df0,$ef0,$ff0
	dc.w	$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80,$f70,$f60,$f50
	dc.w	$f40,$f30,$f20,$f10,$f00,$f01,$f02,$f03,$f04,$f05
	dc.w	$f06,$f07,$f08,$f09,$f0a,$f0b,$f0c,$f0d,$f0e,$f0f
	dc.w	$e0e,$d0d,$c0c,$b0b,$a0a,$909,$808,$707,$606
	dc.w	$505,$404,$303,$202,$101,$000
	dc.w	$001,$002,$003,$004,$005,$006,$007,$008,$009,$00a
	dc.w	$00b,$00c,$00d,$00e,$00f
	dc.w	$01f,$02f,$03f,$04f,$05f
	dc.w	$06f,$07f,$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
	dc.w	$0fe,$0fd,$0fc,$0fb,$0fa,$0f9,$0f8,$0f7,$0f6,$0f5
	dc.w	$0f4,$0f3,$0f2,$0f1,$0f0,$1f0,$2f0,$3f0,$4f0,$5f0
	dc.w	$6f0,$7f0,$8f0,$9f0,$af0,$bf0,$cf0,$df0,$ef0,$ff0
	dc.w	$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80,$f70,$f60,$f50
	dc.w	$f40,$f30,$f20,$f10,$f00,$f01,$f02,$f03,$f04,$f05
	dc.w	$f06,$f07,$f08,$f09,$f0a,$f0b,$f0c,$f0d,$f0e,$f0f
	dc.w	$e0e,$d0d,$c0c,$b0b,$a0a,$909,$808,$707,$606
	dc.w	$505,$404,$303,$202,$101,$000


pointer1:
	dcb.w	10,0

pointer2:
	dcb.w	10,0

addtable:
	dc.b	$c4,$a2,$44,$a0,$24,$42,$a0,$22,$a4,$c2

; colorsequcolorend-colortable

numctab		equ	512


stripe:
	dc.w	numctab*4

; La barra griagia che "attraversa" quelle colorate

stable:
	dc.w	$000,$111,$222,$444,$555,$666,$777,$888,$888,$999,$999
	dc.w	$aaa,$aaa,$bbb,$bbb,$ccc,$ccc,$ddd,$ddd,$eee,$eee,$eee
	dc.w	$fff,$fff,$fff,$fff,$fff,$eee,$eee,$eee,$ddd,$ddd,$ccc
	dc.w	$ccc,$bbb,$bbb,$aaa,$aaa,$999,$999,$888,$888,$777,$666
	dc.w	$555,$444,$333,$222,$111,$000
stend:

stlinee	equ	stend-stable

*****************************************************************************
;			Buffer vari
*****************************************************************************

	section	bau1,bss

clsize		equ	2*xlinee*ylinee

colbuf:
	ds.b	clsize


*****************************************************************************
;			Copperlist
*****************************************************************************

	section	bau2,bss_c

csize		equ	xlinee*ylinee*8+12

Copperlist:
	ds.b	csize

	END

Non si direbbe che non ci sono bitplanes abilitati, eh!?

