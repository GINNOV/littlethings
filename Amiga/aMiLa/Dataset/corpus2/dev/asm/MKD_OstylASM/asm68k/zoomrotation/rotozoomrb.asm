ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**
**	Zoom&Rotate WarpOS
**
**	Code 68k + PowerPC
**
**	B.Sébastien
**

	Incdir	includes:
	Include	misc/devpacmacros.i
	Include	macros/macros.i
	Include	macros/powerpc.i
	Include macros/display.i

	XDEF	Beg

	XREF	_PowerPCBase
	XREF	LoadRGB32
	XREF	SwapVPBitmap
	XREF	DoC2P_8b
	XREF	ChunkyPTR
	XREF	_LinkerDB

Beg	FLoad	TextureName,TexturePTR,FAST
	Beq.W	Fin

	ScOpen	0,1280,200,6,SUPERHAM,320,200
	
Loop	Jsr	Camera
	Jsr	ZoomRotation
	WaitRMB	Loop

	ScClose	0

Fin	Moveq	#0,d0
	Rts

ZoomRotation

;---------------------
;--------------------------------

LargeurChunky	EQU	320
Xmap		EQU	256/2
Ymap		EQU	256*(256/2)
bf		EQU	1

;Calcul un point
;
	Moveq	#0,d0
	Moveq	#0,d1
	Move	Scale(pc),d0
	Bsr.W	CalculPoint

	;Lea	xy0xy1(pc),a0
	;Move	#LargeurChunky-1,d6
	;Bsr.W	Interpolate16

	;Lea	xy0xy2(pc),a0
	;Exg	d0,d1
	;Neg.L	d0
	;Move	#240-1,d6
	;Bsr.W	Interpolate16

;---------------------
;---- Remplissage ----
;

	XREF	RotoZoom1x1_PPC

;Calcul le deuxieme point
;d0>	x2
;d1>	y2
;
	Move.L	TexturePTR(pc),a2
	Move.L	_PowerPCBase,a6
	Lea	PP_struct(pc),a0
	Move.L	a2,PP_REGS+r4(a0)
	Move.L	ChunkyPTR(pc),PP_REGS+r5(a0)
	Beq.B	DntRotoZoom
	Move.L	ChunkyHeight,PP_REGS+r6(a0)
	Move.L	d0,PP_REGS+r22(a0)
	Move.L	d1,PP_REGS+r23(a0)
	RunPPC	RotoZoom1x1_PPC	

	Jsr	DoC2P_12b
	
DntRotoZoom
	Rts	

PP_struct	Ds.B	PP_SIZE
xy0xy1		Ds.L	LargeurChunky
xy0xy2		Ds.L	240

;-----------------------------
;-------------------------------------
;
CalculPoint
	Lea	Sin(pc),a0
	Lea	Cos(pc),a1
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
	Move	VittAngle(pc),d2
	Add	d2,Angle
	Rts

VittAngle	Dc	1
Angle		Dc	20

Interpolate8
	Moveq	#0,d2
	Moveq	#0,d3
LoopIt	Add.L	d0,d2
	Add.L	d1,d3
	Move.L	d2,d4
	Move.L	d3,d5	
	Swap	d4
	Swap	d5
	Ext.L	d4
	Ext.L	d5
	Add.L	Add_x(pc),d4
	Add.L	Add_y(pc),d5
	Asl.L	#8,d5
	Add.L	d4,d5
	Move.L	d5,(a0)+
	Dbf	d6,LoopIt
	Rts

Interpolate16
	Moveq	#0,d2
	Moveq	#0,d3
Loop1	Add.L	d0,d2
	Add.L	d1,d3
	Move.L	d2,d4
	Move.L	d3,d5	
	Asr.L	#8,d4
	Asr.L	#8,d5
	Add.L	Add_x(pc),d4
	Add.L	Add_y(pc),d5
	Swap	d5
	Move	d4,d5
	Move.L	d5,(a0)+
	Dbf	d6,Loop1
	Rts

;-----------------------------
;-------------------------------------
;
Vitt_alpha	EQU	1
Vitt_beta	EQU	1
z		EQU	0

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
	;Move	d3,VittAngle

;Déplacement horizontal
;d2>	Sin(beta)+Cos(alpha)
;
	Move	(a1,d0.w*2),d2
	Add	(a0,d1.w*2),d2
	Ext.L	d2
	Asl.L	#7,d2
	Move.L	d2,Add_x

;Déplacement vertical
;d2>

	Move	(a1,d1.w*2),d2
	Add	(a0,d1.w*2),d2
	Ext.L	d2
	Asl.L	#4,d2
	Move.L	d2,Add_y

;Zoom
;d2>
	Move	(a1,d1.w*2),d2
	Asl	#2,d2
	Tst	d2
	Bpl.B	Absolut
	Neg	d2
Absolut	Add	#z,d2
	Asr	#2,d2
	;Move	d2,Scale
	Rts

Alpha	Dc	0
Beta	Dc	0
Scale	Dc	200
Add_x	Dc.L	0
Add_y	Dc.L	0

TextureName	Dc.B	'dat:rotozoom/texture.tga',0
		EVEN
		
TexturePTR	Ds.L	1

Sin	Incbin	"Includes:Table/Sin"
Cos	Incbin	"Includes:Table/Cos"

