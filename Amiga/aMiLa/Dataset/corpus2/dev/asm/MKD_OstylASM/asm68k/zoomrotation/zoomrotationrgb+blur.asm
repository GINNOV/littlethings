ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
	Incdir	Includes:
	Include	hardware/bplbits.i
	Incdir	

	Include	Macros:Copper.i
	Include	Macros:Ecran.i
	
	Include	Includes:startup.asm

	Jsr	InitEcran
	Jsr	InitPic
	
	Move.L	#Vbl,Lev3Vbl

	Move	#%1000001110000000,$dff096
	Move	#%1100000000100000,$dff09a

Wait	WaitLMB	Wait

	Rts

;-----------------------------------------------------
;-----------------------------------------------------

	Section	Interrupt,Code

Vbl	;move	#5,$dff180
	Jsr	Camera	
	Jsr	Rotation
	;move	#0,$dff180
	Rts

;------------------------
;---- Traitement tex ----
;
InitPic	Lea	Image,a0
	Move	#(256*256)-1,d0
	Move	#$eee,d1

PicLoop	Move	(a0),d2
	And	d1,d2
	Lsr	d2
	Move	d2,(a0)+	
	Dbf	d0,PicLoop
	Rts	

;-----------------------------------------------------
;-----------------------------------------------------
;Initialise l'ecran

InitEcran
	_CHIP	a1
	Moveq	#0,d0
	Move	#BPL32+BPAGEM,fmode(a1)			
	SetDMARast64	128,320,a1
	Fenetre		129,43,320-2,252,a1
	Move	#$7201,bplcon0(a1)
	Move	d0,bplcon1(a1)
	Move	d0,bplcon2(a1)
	Move	#BPLF_BRDRBLNK,bplcon3(a1)
	Move	d0,bplcon4(a1)
	Moveq	#-40,d1
	Move	d1,bpl1mod(a1)
	Move	d1,bpl2mod(a1)
	Lea	CopperList,a0
	Move.L	a0,cop1lc(a1)	
	Move	d0,copjmp1(a1)

	Move.L	#Ecran,d0
	Moveq	#7,d1
	Move.L	#40,d2
	InitPtr
	Rts

	SECTION	Copper,Data_C

CopperList	BplPtr	7
EcranChunky	Incbin	dat:ZoomRotation/copperlist.bin
		CEnd

	SECTION	Image,Data_C
Ecran		Incbin	dat:ZoomRotation/dégradé.bin

;-----------------------------------------------------
;-----------------------------------------------------
;Rotation
;Auteur: B.Sébastien (sur l'idée de la origine/complex)
;Révision: 19.08.98
;Registre utilisée: d0-a6 (non sauvé)
;
	SECTION	Rotation,Code_F

LargeurChunky	EQU	106
Xmap		EQU	256/2
Ymap		EQU	256*(256/2)

Rotation

;Calcul un point
;
	Jsr	CalculPoint
	Movem.L	d0/d1,-(sp)

;Interpolation entre (0,0) et (x1,y1)
;
	Lea	TableInterpolation(pc),a0
	Moveq	#0,d2
	Moveq	#0,d3
	Moveq	#LargeurChunky-1,d6

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
	Add.L	d4,d4
	Move.L	d4,(a0)+
	Dbf	d6,LoopInter.

;Remplissage de la copperlist
;
	Lea	EcranChunky,a0
	Lea	Image(pc),a1
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
	Moveq	#21-1,d7

Remp.

;Interpolation pour 4 lignes
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
	Add.L	d4,d4
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
	Add.L	d4,d4
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
	Add.L	d4,d4
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
	Add.L	d4,d4
	Lea	(a1,d4.L),a6

;Repli 32 couleurs sur 4 lignes avec la table d'interpolation (0,0)(x1,y1)
;>a3-a6	Adresse de départ de la map
;
Fill	MACRO
	Move.L	(a2)+,d5
	Move	18(a0),d0
	Move	470(a0),d1
	Move	922(a0),d2
	Move	1374(a0),d3
	And	d4,d0
	And	d4,d1
	And	d4,d2
	And	d4,d3
	Lsr	d0
	Lsr	d1
	Lsr	d2
	Lsr	d3
	Add	(a3,d5.L),d0
	Add	(a4,d5.L),d1
	Add	(a5,d5.L),d2
	Add	(a6,d5.L),d3
	Move	d0,18(a0)
	Move	d1,470(a0)
	Move	d2,922(a0)
	Move	d3,1374(a0)
	Addq	#4,a0
	ENDM

	Movem.L	d0-d3,-(sp)
	Lea	TableInterpolation(pc),a2

	Moveq	#32-1,d6
	Move	#$eee,d4

Remp32	Fill
	Dbf	d6,Remp32

	Addq	#4,a0
	Moveq	#32-1,d6
Remp64	Fill
	Dbf	d6,Remp64

	Addq	#4,a0
	Moveq	#32-1,d6
Remp96	Fill
	Dbf	d6,Remp96

	Addq	#4,a0
	Moveq	#10-1,d6
Remp106	Fill
	Dbf	d6,Remp106

	Lea	(452*3)+16(a0),a0
	Movem.L	(sp)+,d0-d3
	Dbf	d7,Remp.
	Rts	

TableInterpolation
	Ds.L	LargeurChunky

Image	Incbin	Dat:Twirl/Texture256x256.rgb

;-----------------------------------------------------
;-----------------------------------------------------
;Calcul un point
;Révision: 19.08.1998
;Registre utilisés: a0/a1/d0-d5 (non sauvegardé) 
;d0>	nouveau x
;d1>	nouveau y
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

VittAngle	Dc	0
Angle		Dc	0

Sin	Incbin	"Includes:Table/Sin"
Cos	Incbin	"Includes:Table/Cos"

;-----------------------------------------------------
;-----------------------------------------------------
;Déplacement de la caméra
;3.09.98
;

Vitt_alpha	EQU	3
Vitt_beta	EQU	2
z		EQU	200

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
	Move	d2,Scale
	Rts

Alpha	Dc	0
Beta	Dc	0
Scale	Dc	0
Add_x	Dc.L	0
Add_y	Dc.L	0
