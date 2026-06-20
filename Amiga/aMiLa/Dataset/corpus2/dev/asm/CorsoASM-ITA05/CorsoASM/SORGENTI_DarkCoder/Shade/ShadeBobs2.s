		************************************
		*       /\/\                       *
		*      /    \                      *
		*     / /\/\ \ O R B_I D           *
		*    / /    \ \   / /              *
		*   / /    __\ \ / /               *
		*   ¯¯     \ \¯¯/ / I S I O N S    *
		*           \ \/ /                 *
		*            \  /                  *
		*             \/                   *
		*     Feel the DEATH inside!       *
		************************************

; Codice di autori sconosciuti adattato e migliorato da
; DeathBringer/Morbid Visions 

***********************************************************
* Shade Bobs
*
;In questo esempio si puo' vedere un'altra implementazione piu' sofisticata 
;che permette di risparmiare alcune blittate rispetto al metodo classico e
;usa una sola area Carry. In particolare e' necessario calcolare un Carry ogni
;due bitplane in vece che ogni 1. Ha lo svantaggio pero' di usare tutti e 4 
;i canali DMA del blitter "rubando" piu' tempo al processore.
;Premendo il bottone destro del mouse si cicla la palette.


	Section	Demo,Code_C

	incdir	"/Include/"
	include	"MVstartup.s"	; Salva Copperlist Etc.

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA

size1	= 80
size2	= 130
size3	= 70

speed1	= 6
speed2	= 8
speed3	= 10
speed4	= 12

Start:	

	Move.w	#$7fff,$9a(a5)		; No DMA
	Move.l	#$7fff7fff,$96(a5)	; No Interupts&Intreq

	move.l	StoreVBR(pc),a0
	move.l	#my_level3,$6c(a0)	; nuovo interrupt Level3 (copper)
	move.l	#my_copper,cop1lc(a5) 	; Copperlist
	move	#$c010,intena(a5)	; abilita interupt

	move	#DMASET,dmacon(a5)	; DMA=copper+Bplanes+blitter
	move	#1,copjmp1(a5)		; Fai partire la copperlist

	moveq	#5-1,d7			;numero planes
	move.l	#screena,d0
	lea	planes+2,a0
.loop
	swap	d0
	move	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move	d0,(a0)
	addq.l	#4,a0
	add.l	#40*256,d0
	dbra	d7,.loop

wait:
	bsr	sb_setup
	btst	#6,$bfe001
	bne.s	wait		; aspetta LMB
	rts			; Exit

*****************************************
* Routine di interrupt livello 3 (copper)

my_level3:
	btst	#4,intreqr+1(a5);E' veramente un Interrupt?
	beq.s	.Noint		; N.B: Testare sempre il bit di interrupt, 
	movem.l	d0-d7/a0-a6,-(a7)	; Copper Interupt
	btst	#10,potinp(a5)		; bottone destro premuto?
	bne.s	.exit			; no, esci

	lea	shade_map,a0		; si, cicla la palette
	move	2(a0),d7
	move	#31-1,d0
.cycle	move	6(a0),2(a0)
	add.l	#4,a0
	dbf	d0,.cycle
	move	d7,-2(a0)

.exit	movem.l	(a7)+,d0-d7/a0-a6
	move	#$0010,intreq(a5)	; Cancella la richiesta di Interrupt
.Noint	rte				; Ritorna al programma principale


*************************************************


rnd:					;crea un numero pseudocasuale
	move.l	rndnumber(pc),d1	;partendo da D0
	move.l	d1,d2			;e ritornandolo in D1
	and.l	#$0ff00000,d1
	swap	d1
	lsr	#4,d1

	add.l	d2,d2
	eor.l	#$87654321,d2
	add.l	d2,d2
	eor.l	d1,d2
	eor.l	#$fedcba97,d2
	add.l	d1,d2
	move.l	d2,rndnumber

	move.l	d2,d1
	swap	d1
	and.l	#$0000ffff,d1
	ext.l	d0
	divu	d0,d1

	move	d1,d2
	ext.l	d2
	add.l	d2,rndnumber
	swap	d1

	rts

rndnumber:	dc.l	$54d2e507

*************************************************

sb_setup:
	move	#2,x1step	;passoX=2
	move	#2,y1step	;passoY=2

	move	#speed1,d0	;velocita'
	bsr	rnd
	asl	#1,d1
	move	d1,x2step	;passoX2=random
	move	#speed2,d0
	bsr	rnd
	asl	#1,d1
	move	d1,y2step	;passoY2=random

	move	#speed3,d0
	bsr	rnd
	asl	#1,d1
	move	d1,x3step	;passoX3=random
	move	#speed4,d0
	bsr	rnd
	asl	#1,d1
	move	d1,y3step	;passoY3=random

	bsr	sb_cls		;cancella schermo

	move	#9,d0
	bsr	rnd
	asl	#6,d1		;d1=random
	lea	shade_colours(pc),a0
	ext.l	d1
	add.l	d1,a0		;colori
	lea	shade_map-4(pc),a1
	move	#31-1,d0
.col	move	(a0)+,2(a1)	;inserisci colori nella copperlist
	add.l	#4,a1
	dbf	d0,.col

.wait	move.l	vposr(a5),d0
	lsr.l	#8,d0
	and.w	#$01FF,d0
	cmp.w	#$0010,d0
	bne.s	.wait

.sinok	bsr	sb_do		;SHADE!

	btst	#6,$bfe001	;LMB Premuto?
	beq.s	.exit		;si esci

	cmp	#512,lcount	;512 Shade?
	blt.s	.wait		;no continua con questa configurazione

	add.l	#4,brush_ptr	;cambia bob
	move.l	brush_ptr,a0
	cmp.l	#-1,(a0)	;fine lista?
	bne.s	.exit
	move.l	#brushlist,brush_ptr	;resetta lista bob
.exit
	rts


***********************
* Cancella lo schermo

	cnop	0,4
sb_cls:
	lea	screena(pc),a0

	move	#$8400,dmacon(a5)	;Blitternasty
	moveq	#5-1,d0			; numero planes
.wait
	btst	#6,dmaconr(a5)
	bne.s	.wait
	
	move.l	#$01000000,bltcon0(a5)
	move.l	a0,bltdpt(a5)
	move	#0,bltdmod(a5)
	move	#(256<<6)+20,bltsize(a5)
	
	add.l	#40*256,a0		;prossimo plane
					;il procedimento e' ripetuto per
					;tutti i bitplanes
	dbra	d0,.wait

	clr	lcount			;resetta contatore di fotogrammi
	move	#$0400,dmacon(a5)	;Blitternasty OFF
	rts
	
***********************************************************
* Routine di Shade

sb_do:
	addq	#1,lcount	;incrementa contatore fotogrammi

	lea	sintable(pc),a3	;tavola coordinate
	lea	186(a3),a4

	move	sinepos(pc),d4		;posizione1
	move	cosinepos(pc),d5	;posizione1

	move	(a3,d4.w),d0	;X1
	move	(a4,d5.w),d1	;Y1
	muls	#size1,d0
	muls	#size1,d1
	swap	d0
	swap	d1

	move	sinepos2(pc),d4		;posizione2
	move	cosinepos2(pc),d5	;posizione2

	move	(a3,d4.w),d2		;X2
	move	(a4,d5.w),d3		;Y2
	muls	#size2,d2
	muls	#size3,d3
	swap	d2
	swap	d3
	add	d2,d0			;X=X1+X2
	add	d3,d1			;Y=Y1+Y2

	move	sinepos3(pc),d4		;posizione3
	move	cosinepos3(pc),d5	;posizione3

	move	(a3,d4.w),d2		;X2
	move	(a4,d5.w),d3		;Y2
	muls	#size2,d2
	muls	#size3,d3
	swap	d2
	swap	d3
	add	d2,d0			;X=X+X3
	add	d3,d1			;Y=Y+Y3

	movem.l	d0-d1,-(a7)
	add	#160-16,d0
	add	#128-16,d1
	bsr	plot_bob		;plotta il bob
	movem.l	(a7)+,d0-d1

	movem.l	d0-d1,-(a7)
	not	d1
	add	#160-16,d0
	add	#128-16,d1
	bsr	plot_bob		;plotta il bob
	movem.l	(a7)+,d0-d1
	
	move	x2step(pc),d1		;aggiorna posizioni
	add	d1,sinepos2		;nella tavola delle
	and	#$3fe,sinepos2		;coordinate
	move	y2step(pc),d1
	add	d1,cosinepos2
	and	#$3fe,cosinepos2
	
	move	x3step(pc),d1		;aggiorna posizioni
	add	d1,sinepos3		;nella tavola 
	and	#$3fe,sinepos3		;delle coordinate
	move	y3step(pc),d1
	add	d1,cosinepos3
	and	#$3fe,cosinepos3
	
	rts

*************************************************

plot_bob:
	movem.l	d0-d7/a0-a6,-(a7)

	lea	screena(pc),a0		;plane0
	lea	40*256(a0),a1		;plane1
	lea	40*256(a1),a2		;plane2
	lea	40*256(a2),a3		;plane3
	lea	40*256(a3),a4		;plane4

	move.l	brush_ptr(pc),a6
	move.l	(a6),a6			;puntatore bob

	move	d0,d5			
	and	#$000f,d5		;Bit offset in word
	lsr	#3,d0			;byte offset 
	ext.l	d0
	add.l	d0,a0			;somma x offset nei puntatori ai
	add.l	d0,a1			;bitplanes
	add.l	d0,a2
	add.l	d0,a3
	add.l	d0,a4
	
	mulu	#40,d1			;Yoffset
	ext.l	d1
	add.l	d1,a0			;somma y offset nei puntatori
	add.l	d1,a1			;ai bitplanes
	add.l	d1,a2
	add.l	d1,a3
	add.l	d1,a4
	
	ror	#4,d5			;shift
	or	#$0b5a,d5		;D=A XOR C

	move	#$8400,dmacon(a5)	; Blitternasty ON
.wait
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait

; plane 1

	move.l	a0,bltdpt(a5)		; Puntatore D
	move.l	a0,bltcpt(a5)		; Puntatore C
	move.l	a6,bltapt(a5)		; Puntatore A
	move.l	#-1,bltafwm(a5)		; BLTAFWM & BLTALWM
	move	d5,bltcon0(a5)		; BLTCON0
	move	#0,bltcon1(a5)
	move.l	#(0<<16)+34,bltamod(a5)	; moduli A e D
	move	#34,bltcmod(a5)		; modulo C
	move	#(31<<6)+3,bltsize(a5)	; BLTSIZE (32+16)*31 pixel

	and	#$f000,d5
	or	#$0f9a,d5		; D=(A AND ~B AND ~C) OR (~A AND C) OR
					;      OR (B AND C) 	
					; N.B: il simbolo " ~ " equivale a NOT


; plane 2
.wait2
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait2

	move.l	a6,bltapt(a5)		; Apt=bob
	move.l	a0,bltbpt(a5)		; Bpt=plane1
	move.l	a1,bltcpt(a5)		; Cpt=plane2
	move.l	a1,bltdpt(a5)		; Dpt=plane2
	move	d5,bltcon0(a5)		; blit cont reg 0
	move.l	#0<<16+34,bltamod(a5)	; moduli A e D
	move.l	#34<<16+34,bltcmod(a5)	; moduli C e B
	move	#(31<<6)+3,bltsize(a5)	; BLTSIZE

; Spiegazione della funzione:
; (A AND ~B AND ~C) = se A=1 e B=0 vuol dire che si e' verificato
; un riporto tra il primo e il secondo bitplane, quindi quest'ultimo varra'
; NOT C, ovvero verra' cambiato il bit.
; (~A AND C) = se A=0 allora non si potra' verificare nessun riporto, quindi
;il bitplane non cambiera' di valore, cioe' varra' C
; (B AND C) = se il primo bitplane e' uguale a 1 (B=1) significa che non si
; e' verificato alcun riporto (infatti in questo caso dovrebbe essere B=0, per
; risolvere ogni dubbio controllare con la tabella della teoria) e quindi il
; bit rimane invariato.


	and.w	#$f000,d5
	or.w	#$0f10,d5		;D= A AND ~B AND ~C

.wait3
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait3

; temp smear 1			;Calcola se c'e' stato riporto
	

	move.l	a6,bltapt(a5)		; Apt=bob
	move.l	a0,bltbpt(a5)		; Bpt=plane1
	move.l	a1,bltcpt(a5)		; Cpt=plane2
	move.l	#tempsmear1,bltdpt(a5)	; Dpt=Carry
	move	d5,bltcon0(a5)		; BLTCON0

	move	#0,bltdmod(a5)		; modulo D
; stessi valori di prima per moduli A, B e C
;	move	#0,bltamod(a5)
;	move.l	#34<<16+34,bltcmod(a5)	; moduli C e B

	move	#(31<<6)+3,bltsize(a5)	; BLTSIZE

.wait4
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait4


					;Adesso si ripete il procedimento 
	; plane 3			;visto fin qui, usando come bob
					;il Carry
					
	move.l	#tempsmear1,bltapt(a5)	; Apt=Carry (prende il posto del bob)
	move.l	a2,bltbpt(a5)		; Bpt=plane2
	move.l	a2,bltdpt(a5)		; Dpt=plane2
	move.w	#$0d3c,bltcon0(a5)	; D=A XOR B

	move	#34,bltdmod(a5)		; modulo D
; stessi valori di prima per moduli A e B
;	move	#0,bltamod(a5)
;	move.l	#34<<16+34,bltcmod(a5)	; moduli C e B

	move	#(31<<6)+3,bltsize(a5)


.wait5
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait5
					
	; plane 4

	move.l	#tempsmear1,bltapt(a5)	; A=Carry
	move.l	a2,bltbpt(a5)		; B=plane3
	move.l	a3,bltcpt(a5)		; C=plane4
	move.l	a3,bltdpt(a5)		; D=plane4
	move	#$0f9a,bltcon0(a5)	; D=(A AND ~B AND ~C) OR (~A AND C) OR
					;      OR (B AND C) 	

; stessi valori di prima per moduli A,B,C e D
;	move	#0,bltamod(a5)
;	move	#34,bltdmod(a5)		; modulo D
;	move.l	#34<<16+34,bltcmod(a5)	; moduli C e B

	move	#(31<<6)+3,bltsize(a5)

.wait6
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait6

; temp smear 2			;ricalcola Carry

	move.l	#tempsmear1,bltapt(a5)	; Apt=VECCHIOcarry
	move.l	a2,bltbpt(a5)		; Bpt=plane3
	move.l	a3,bltcpt(a5)		; Cpt=plane4
	move.l	#tempsmear1,bltdpt(a5)	; Dpt=NUOVOcarry
	move	#$0f10,bltcon0(a5)	; D= A AND ~B AND ~C

	move	#0,bltdmod(a5)		; modulo D
; stessi valori di prima per moduli A,B,C
;	move	#0,bltamod(a5)
;	move.l	#34<<16+34,bltcmod(a5)	; moduli C e B

	move	#(31<<6)+3,bltsize(a5)

.wait7
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait7

; plane 5

	move.l	#tempsmear1,bltapt(a5)	; Apt=Carry
	move.l	a4,bltbpt(a5)		; Bpt=plane5
	move.l	a4,bltdpt(a5)		; Dpt=plane5
	move	#$0d3c,bltcon0(a5)	; D=(A AND ~B AND ~C) OR (~A AND C) OR
					;      OR (B AND C) 	

	move	#34,bltdmod(a5)		; modulo D
; stessi valori di prima per moduli A,B,C
;	move	#0,bltamod(a5)
;	move.l	#34<<16+34,bltcmod(a5)	; moduli C e B

	move	#(31<<6)+3,bltsize(a5)

	move	#$0400,dmacon(a5)	;Blitternasty OFF
	movem.l	(a7)+,d0-d7/a0-a6
	rts

*************************************************************

sinepos:	dc.w	0	;puntatori tabelle coordinate
cosinepos:	dc.w	0
sinepos2:	dc.w	0
cosinepos2:	dc.w	0
sinepos3:	dc.w	0
cosinepos3:	dc.w	0

x1step:	dc.w	10	;passi
y1step:	dc.w	80
x2step:	dc.w	10
y2step:	dc.w	80
x3step:	dc.w	10
y3step:	dc.w	80

sinoffset:	dc.w	0


lcount:		dc.w	0

sintable:
		incdir  "/shade/"

		incbin	"sin.3fe"
		incbin	"sin.3fe"
		incbin	"sin.3fe"
		incbin	"sin.3fe"


shade_colours:	dc.w	$000,$00f,$11f,$22f,$33f,$44f,$55f,$66f,$77f,$88f,$99f,$aaf,$bbf,$ccf,$ddf,$eef,$fff,$fee,$fdd,$fcc,$fbb,$faa,$f99,$f88,$f77,$f66,$f55,$f44,$f33,$f22,$f11,$f00
		dc.w	$000,$002,$004,$006,$008,$00a,$00c,$00e,$f00,$f0f,$e0e,$c0c,$a0a,$808,$606,$404,$202,$400,$600,$800,$a00,$c00,$e00,$f00,$ff0,$ee0,$cc0,$a00,$880,$660,$440,$220
		dc.w	$000,$200,$400,$600,$800,$a00,$c00,$e00,$f00,$ff0,$ee0,$cc0,$a00,$880,$660,$440,$220,$004,$006,$008,$00a,$00c,$00e,$f00,$f0f,$e0e,$c0c,$a0a,$808,$606,$404,$202
		dc.w	$000,$f00,$f11,$f22,$f33,$f44,$f55,$f66,$f77,$f88,$f99,$faa,$fbb,$fcc,$fdd,$fee,$fff,$eef,$ddf,$ccf,$bbf,$aaf,$99f,$88f,$77f,$66f,$55f,$44f,$33f,$22f,$11f,$00f
		dc.w	$000,$00f,$11f,$22f,$33f,$44f,$55f,$66f,$77f,$88f,$99f,$aaf,$bbf,$ccf,$ddf,$eef,$fff,$fee,$fdd,$fcc,$fbb,$faa,$f99,$f88,$f77,$f66,$f55,$f44,$f33,$f22,$f11,$f00
		dc.w	$000,$002,$004,$006,$008,$00a,$00c,$00e,$f00,$f0f,$e0e,$c0c,$a0a,$808,$606,$404,$202,$400,$600,$800,$a00,$c00,$e00,$f00,$ff0,$ee0,$cc0,$a00,$880,$660,$440,$220
		dc.w	$000,$200,$400,$600,$800,$a00,$c00,$e00,$f00,$ff0,$ee0,$cc0,$a00,$880,$660,$440,$220,$004,$006,$008,$00a,$00c,$00e,$f00,$f0f,$e0e,$c0c,$a0a,$808,$606,$404,$202
		dc.w	$000,$f00,$f11,$f22,$f33,$f44,$f55,$f66,$f77,$f88,$f99,$faa,$fbb,$fcc,$fdd,$fee,$fff,$eef,$ddf,$ccf,$bbf,$aaf,$99f,$88f,$77f,$66f,$55f,$44f,$33f,$22f,$11f,$00f
		dc.w	$000,$00f,$11f,$12f,$22f,$23f,$33f,$43f,$44f,$45f,$55f,$65f,$66f,$76f,$77f,$78f,$88f,$98f,$99f,$9af,$aaf,$baf,$bbf,$bcf,$ccf,$dcf,$ddf,$def,$eef,$fef,$fff,$fff

*************************************************
	
my_copper:	
		dc.w	$1fc,0,$106,$0c00	;resetta AGA
		dc.w	$100,$5200		; bltcon0= 5 bp lores
		dc.w	$108,0			; bp modulo 
		dc.w	$10a,0			; bp modulo 
		dc.w	$102,0			;bplcon1=Noscroll
		
		dc.w	$08e,$2c81	; bp window start 
		dc.w	$090,$2cc1	; bp window stop
		dc.w	$094,$d0	; DDFSTOP
		dc.w	$92,$38		; DDFSTRT
		
Planes
		dc.w	  $e0
sb_plane0_hi:	dc.w	0,$e2
sb_plane0_lo:	dc.w	0,$e4
sb_plane1_hi:	dc.w	0,$e6
sb_plane1_lo:	dc.w	0,$e8
sb_plane2_hi:	dc.w	0,$ea
sb_plane2_lo:	dc.w	0,$ec
sb_plane3_hi:	dc.w	0,$ee
sb_plane3_lo:	dc.w	0,$f0
sb_plane4_hi:	dc.w	0,$f2
sb_plane4_lo:	dc.w	0

		
		dc.w	$180,$000
shade_map:	
		dc.w	$182,$11f
		dc.w	$184,$22f
		dc.w	$186,$33f
		dc.w	$188,$44f
		dc.w	$18a,$55f
		dc.w	$18c,$66f
		dc.w	$18e,$77f
		dc.w	$190,$88f
		dc.w	$192,$99f
		dc.w	$194,$aaf
		dc.w	$196,$bbf
		dc.w	$198,$ccf
		dc.w	$19a,$ddf
		dc.w	$19c,$eef
		dc.w	$19e,$fff
		dc.w	$1a0,$fee
		dc.w	$1a2,$fdd
		dc.w	$1a4,$fcc
		dc.w	$1a6,$fbb
		dc.w	$1a8,$faa
		dc.w	$1aa,$f99
		dc.w	$1ac,$f88
		dc.w	$1ae,$f77
		dc.w	$1b0,$f66
		dc.w	$1b2,$f55
		dc.w	$1b4,$f44
		dc.w	$1b6,$f33
		dc.w	$1b8,$f22
		dc.w	$1ba,$f11
		dc.w	$1bc,$f00
		dc.w	$1be,$f00
		
		dc.w	$ffe1,$fffe	; Aspetta la riga 255
		dc.w	$9c,$8010	; Chiama Interrupt Copper
		dc.w	$ffff,$fffe	; end of copper list

tempsmear1:		ds.l	384

brushlist:		dc.l	brush1
		dc.l	brush2
		dc.l	brush3
		dc.l	brush4
		dc.l	brush3
		dc.l	brush4
		dc.l	-1

brush_ptr:		dc.l	brushlist

brush1:		incbin	"shadeb1.bin"
brush2:		incbin	"shadeb2.bin"
brush3:		incbin	"shadeb3.bin"
brush4:		incbin	"shadeb6.bin"


screena:	ds.l	10*256
		ds.l	10*256
		ds.l	10*256
		ds.l	10*256
		ds.l	10*256


