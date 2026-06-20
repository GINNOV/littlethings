ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**
**	Zoom and 2D-Rotate 
**
**	by OSTYL !
**

	Incdir	Includes:
	Include	macros/macros.i
	Include	macros/copper.i
	Include	hardware/bplbits.i
	Include	hardware/dmabits.i

	Include	Includes:startup.asm

	Move.L	#160,d0
	Move.L	#100,d1
	Moveq	#0,d2
	Moveq	#0,d3
	Moveq	#40,d4
	Move.L	#40*100,d5
	Jsr	c2pinit

	Jsr	InitEcran

	Move.L	#Vbl,Lev3Vbl
	Move	#INTF_SETCLR+INTF_VERTB+INTF_INTEN,intena+$dff000	

Loop	WaitLMB	Loop
	Rts

Vbl	;Jsr	Wave
	;Jsr	Remplissage

	Jsr	Camera
	Jsr	Rotation

	Lea	Ecran,a1
	Jsr	c2p
	Rts

;---------------------------
;---------------------------
; Initialise l'ecran
;
InitEcran

;Install les pointeurs plan
	Lea	CopperList,a0
	Move.L	#Ecran,d0
	Moveq	#8,d1
	Move.L	#40*100,d2
	InitPtr

;Init 256 couleurs
;
	Lea	Palette(pc),a0
	Move.L	#256,d0
	Moveq	#0,d4
	Jsr	InitPal

;Init le hard écran
;
	_CHIP	a1
	Moveq	#0,d0	
	Move	#BPL32+BPAGEM,fmode(a1)
	Move	#$38,ddfstrt(a1)
	Move	#$a0,ddfstop(a1)
	Fenetre	129,44,320,200,a1
	Move	#BPLF_BPU3+BPLF_COLOR+BPLF_ECSENA,bplcon0(a1)
	Move	d0,bplcon1(a1)
	Move	d0,bplcon2(a1)
	Move	#BPLF_BRDRBLNK,bplcon3(a1)
	Move	d0,bplcon4(a1)
	Move	d0,bpl1mod(a1)
	Move	d0,bpl2mod(a1)
	Lea	CopperList,a0
	Move.L	a0,cop1lc(a1)	
	Move	d0,copjmp1(a1)
	Move	#DMAF_SETCLR+DMAF_COPPER+DMAF_RASTER,dmacon(a1)
	Rts
	
InitPal	LoadPalette

Palette	Dc.B	'CMAP'
	Dc.L	0
	Incbin	Dat:UnpackedChunky/texture2.pal	

	SECTION	CopperConstruction,Data_C

CopperList
	BplPtr	8

RastLine	SET	44	
		REPT	200/2
		CWait	0,RastLine
		CMove	-40,bpl1mod
		CMove	-40,bpl2mod
RastLine	SET	RastLine+1	
		CWait	0,RastLine
		CMove	0,bpl1mod
		CMove	0,bpl2mod
RastLine	SET	RastLine+1	
		ENDR

	CEnd
	
	SECTION	ECRAN,Bss_C
Ecran	Ds.B	40*256*8

;-----------------------------
;-------------------------------------
;
	SECTION	Rotation,Code_F

LargeurChunky	EQU	160
Xmap		EQU	256/2
Ymap		EQU	256*(256/2)

Rotation

;Calcul un point
;
	Bsr.W	CalculPoint
	Movem.L	d0/d1,-(sp)

;Interpolation entre (0,0) et (x1,y1)
;
	Lea	xy0xy1(pc),a0
	Moveq	#0,d2
	Moveq	#0,d3
	Move	#LargeurChunky-1,d6

LoopInter.
	Add.L	d0,d2
	Add.L	d1,d3
	Move.L	d2,d4
	Move.L	d3,d5
	Swap	d4
	Swap	d5
	Ext.L	d4
	Ext.L	d5
	Asl.L	#8,d5
	Add.L	d5,d4
	Move.L	d4,(a0)+
	Dbf	d6,LoopInter.

;---------------------
;---- Remplissage ----
;
	Lea	ChunkyBuffer,a0
	Lea	Texture(pc),a1
	Add.L	#(Xmap+Ymap)*2,a1
	Add.L	Add_x,a1
	Add.L	Add_y,a1

;Calcul le deuxieme point
;d0>	x2
;d1>	y2
;
	Movem.L	(sp)+,d0/d1
	Exg	d0,d1
	Neg.L	d0

	Moveq	#0,d2
	Moveq	#0,d3
	Moveq	#(100/4)-1,d7
Remp.

;Calcul 4 lignes
;>d0	x2 (pas)
;>d1	y2 (pas)
;a3-a6	Adresses dans la map
;
	Add.L	d0,d2				
	Add.L	d1,d3				
	Move.L	d2,d4
	Move.L	d3,d5
	Swap	d4
	Swap	d5
	Ext.L	d4
	Ext.L	d5
	Asl.L	#8,d5
	Add.L	d5,d4
	Lea	(a1,d4.L),a3

	Add.L	d0,d2
	Add.L	d1,d3
	Move.L	d2,d4
	Move.L	d3,d5
	Swap	d4
	Swap	d5
	Ext.L	d4
	Ext.L	d5
	Asl.L	#8,d5
	Add.L	d5,d4
	Lea	(a1,d4.L),a4

	Add.L	d0,d2
	Add.L	d1,d3
	Move.L	d2,d4
	Move.L	d3,d5
	Swap	d4
	Swap	d5
	Ext.L	d4
	Ext.L	d5
	Asl.L	#8,d5
	Add.L	d5,d4
	Lea	(a1,d4.L),a5

	Add.L	d0,d2
	Add.L	d1,d3
	Move.L	d2,d4
	Move.L	d3,d5
	Swap	d4
	Swap	d5
	Ext.L	d4
	Ext.L	d5
	Asl.L	#8,d5
	Add.L	d5,d4
	Lea	(a1,d4.L),a6

;Copie 32 chunkypixels sur 4 lignes avec la table d'interpolation (0,0)(x1,y1)
;>a3-a6	Adresse de départ de la map
;
	Lea	xy0xy1(pc),a2

	Move	#160-1,d6

Scan	Move.L	(a2)+,d5
	Move.B	(a3,d5.L),(a0)
	Move.B	(a4,d5.L),160(a0)
	Move.B	(a5,d5.L),160*2(a0)
	Move.B	(a6,d5.L),160*3(a0)
	Addq.L	#1,a0
	Dbf	d6,Scan

	Lea	3*160(a0),a0
	Dbf	d7,Remp.
	Rts	

xy0xy1	Ds.L	LargeurChunky

;-----------------------------
;-------------------------------------
;
CalculPoint
	Lea	Sin(pc),a0
	Lea	Cos(pc),a1
	Moveq	#0,d0
	Move	Scale,d0
	Moveq	#0,d1
	Move	Angle(pc),d2
	And	#511,d2
	Add	d2,d2
	Move	(a0,d2),d3		;d3=sin(a)
	Move	(a1,d2),d2		;d2=cos(a)
	Move.L	d0,d4
	Move.L	d1,d5
	Muls	d2,d0			;x*cos(a)		
	Muls	d3,d1			;y*sin(a)
	Add.L	d1,d0			;x=x*cos(a) + y*sin(a)
	Muls	d2,d5			;y*cos(a)
	Muls	d3,d4			;x*sin(a)
	Sub.L	d4,d5			;y=y*cos(a) - x*sin(a)
	Move.L	d5,d1
	Move	VittAngle,d2
	Add	d2,Angle
	Rts

VittAngle	Dc	1
Angle		Dc	0

;-----------------------------
;-------------------------------------
;
Vitt_alpha	EQU	1
Vitt_beta	EQU	1
z		EQU	1

Camera
	Lea	Sin(pc),a0	;sin-->a0
	Lea	Cos(pc),a1	;cos-->a1
	Move	Alpha(pc),d0	;alpha-->d0
	Move	Beta(pc),d1	;beta-->d1
	And	#511,d0
	And	#511,d1
	Subq	#Vitt_alpha,Alpha
	Addq	#Vitt_beta,Beta

;Rotation
;
	Move	(a1,d0.w*2),d2
	Sub	(a0,d1.w*2),d2
	Move	Scale,d2
	Move	#1050,d3
	Sub	d2,d3
	Asr	#8,d3
	Move	d3,VittAngle

;Déplacement horizontal
;d2>	Sin(beta)+Cos(alpha)
;
	Move	(a1,d0.w*2),d2
	Add	(a0,d1.w*2),d2
	Ext.L	d2
	Asr.L	#1,d2
	Add.L	d2,d2
	Move.L	d2,Add_x

;Déplacement vertical
;d2>

	Move	(a1,d1.w*2),d2
	Add	(a0,d1.w*2),d2
	Ext.L	d2
	Asr.L	#4,d2
	Lsl	#8,d2
	Add.L	d2,d2
	Move.L	d2,Add_y

;Zoom
;d2>
	Move	(a1,d1.w*2),d2
	Asl	#2,d2
	Tst	d2
	Bpl.B	Absolut
	Neg	d2
Absolut	Add	#z,d2
	Asr	d2
	Move	d2,Scale
	Rts

Alpha	Dc	0
Beta	Dc	0
Scale	Dc	0
Add_x	Dc.L	0
Add_y	Dc.L	0

Sin	Incbin	"Includes:Table/Sin"
Cos	Incbin	"Includes:Table/Cos"

Texture	Incbin	dat:unpackedchunky/texture2.cnk
	Incbin	dat:unpackedchunky/texture2.cnk

;-----------------------------
;-----------------------------
;
	SECTION	TextureWave,Code_F

Wave	Lea	SinTab(pc),a0
	Lea	CosTab(pc),a1
	Lea	Table(pc),a2
	Moveq	#100-1,d0
	Move	#511,d1
	Move	Angle1(pc),d5
	Move	Angle2(pc),d6

WaveLoop
	Move	d5,d2
	And	d1,d2
	Move	d6,d3
	And	d1,d3
	Move	(a0,d2.W*2),d2
	Move	(a1,d3.W*2),d3
	Asr	#1,d2
	Asr	#2,d3
	Addi	#128,d2
	Addi	#128,d3
	Move.B	d2,(a2)+
	Move.B	d3,(a2)+
	Subq	#4,d5
	Addq	#7,d6
	Dbf	d0,WaveLoop	

	Addq	#4,Angle1
	Subq	#6,Angle2
	Rts

Angle1	Ds	1
Angle2	Ds	1

Table	REPT	100	
	Dc.B	0
	Dc.B	100
	ENDR

SinTab	Incbin	Includes:Table/Sin
CosTab	Incbin	Includes:Table/Cos

;-----------------------------
;-----------------------------
;
Remplissage
	Lea	Texture,a0
	Lea	Table(pc),a1
	Lea	ChunkyBuffer,a2
	Move	#100-1,d0

Fill	Moveq	#0,d1
	Moveq	#0,d2
	Move.B	(a1)+,d1
	Move.B	(a1)+,d2

	Sub	d1,d2
	Beq.B	Div0
	Swap	d2
	Move.L	#160,d3
	Divs.L	d3,d2
Div0
	Swap	d2

	REPT	160
	Move.B	(a0,d1.W),(a2)+
	Addx.L	d2,d1
	ENDR

	Lea	256(a0),a0
	Dbf	d0,Fill
	Rts

;-----------------------------
;-----------------------------
; c2p2x1_8_cpu5
;
; Copy speed on 040-25
;
; Public version, share & enjoy

	IFND	BPLX
BPLX	EQU	320
	ENDC
	IFND	BPLY
BPLY	EQU	100
	ENDC
	IFND	BPLSIZE
BPLSIZE	EQU	BPLX*BPLY/8
	ENDC

	SECTION	C2P,Code_F

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

c2pinit	movem.l	d2-d3,-(sp)
	lea	c2p_datanew(pc),a0
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p_scroffs-c2p_data(a0)
	mulu.w	d0,d1
	move.l	d1,c2p_pixels-c2p_data(a0)
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

c2p	Lea	ChunkyBuffer,a0

	movem.l	d2-d7/a2-a6,-(sp)

	move.w	#.x2-.x,d0
	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2

	add.w	#BPLSIZE,a1
	add.l	c2p_scroffs-c2p_data(a2),a1

	move.l	#$55555555,d5

	move.l	#$00ff00ff,a6

	move.l	c2p_pixels-c2p_data(a2),a5
	add.l	a0,a5
	move.l	a1,a2
	add.l	#BPLSIZE*4,a2
	cmpa.l	a0,a3
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

	move.l	#$0f0f0f0f,d6
	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	move.l	a6,d6
	move.l	d1,d7			; Swap 8x1, part 1
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	bra	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d7,(a2)+
	eor.l	d4,d7
	add.l	d4,d4
	eor.l	d7,d4

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2
	move.l	d4,-BPLSIZE-4(a2)

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

	move.l	a3,d4
	move.l	d4,d7
	lsr.l	d7
	eor.l	d4,d7
	and.l	d5,d7
	eor.l	d7,d4
	move.l	d4,BPLSIZE*2(a1)
	eor.l	d7,d4
	add.l	d7,d7
	eor.l	d7,d4

	move.l	#$0f0f0f0f,d6
	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2
	move.l	d4,BPLSIZE(a1)

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	move.l	a4,d4
	move.l	d4,d7
	lsr.l	d7
	eor.l	d4,d7
	and.l	d5,d7
	eor.l	d7,d4
	move.l	d4,(a1)+
	eor.l	d7,d4
	add.l	d7,d7
	eor.l	d7,d4

	move.l	a6,d6
	move.l	d1,d7			; Swap 8x1, part 1
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1
	move.l	d4,-BPLSIZE-4(a1)
.start

	move.l	#$33333333,d6
	move.l	d1,d7			; Swap 2x1, part 1
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d1,d7

	move.l	d0,d4
	lsr.l	d4
	eor.l	d0,d4
	and.l	d5,d4
	eor.l	d4,d0
	move.l	d0,BPLSIZE*2(a2)
	eor.l	d4,d0
	add.l	d4,d4
	eor.l	d4,d0

	move.l	a6,d6
	move.l	d3,d1			; Swap 8x1, part 2
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d0,BPLSIZE(a2)

	move.l	#$33333333,d6
	move.l	d3,d1			; Swap 2x1, part 2
	lsr.l	#2,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	lsl.l	#2,d1
	eor.l	d1,d3
	move.l	d2,a3
	move.l	d3,a4

	move.l	d7,d4
	lsr.l	d4
	eor.l	d7,d4
	and.l	d5,d4
	eor.l	d4,d7

	cmp.l	a0,a5
	bne	.x
.x2
	move.l	d7,(a2)+
	eor.l	d4,d7
	add.l	d4,d4
	eor.l	d7,d4
	move.l	d4,-BPLSIZE-4(a2)

	move.l	a3,d4
	move.l	d4,d7
	lsr.l	d7
	eor.l	d4,d7
	and.l	d5,d7
	eor.l	d7,d4
	move.l	d4,BPLSIZE*2(a1)
	eor.l	d7,d4
	add.l	d7,d7
	eor.l	d7,d4
	move.l	d4,BPLSIZE(a1)

	move.l	a4,d4
	move.l	d4,d7
	lsr.l	d7
	eor.l	d4,d7
	and.l	d5,d7
	eor.l	d7,d4
	move.l	d4,(a1)+
	eor.l	d7,d4
	add.l	d7,d7
	eor.l	d7,d4
	move.l	d4,-BPLSIZE-4(a1)

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p_datanew,a0
	lea	c2p_data,a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop	0,4

c2p_data
c2p_scroffs dc.l 0
c2p_pixels dc.l 0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16

	SECTION	CnkDestination,Bss_F

	XDEF	ChunkyBuffer

ChunkyBuffer	
	Ds.B	160*128
