שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**
**	Sine and Cosine 
**	Tables
**
**
**
	XDEF	SinTab
	XDEF	CosTab
	XDEF	GetSin
	XDEF	GetCos
	XDEF	GetCosA
	XDEF	GetSinA

GetSin	Lea	SinTab(pc),a0
	Andi	#4095,d0
	Move	(a0,d0.W*2),d0
	Ext.L	d0
	Rts

	;----

GetCos	Lea	CosTab(pc),a0
	Andi	#4095,d0
	Move	(a0,d0.W*2),d0
	Ext.L	d0
	Rts

	;----

GetSinA	Bsr.B	GetSin
	Tst.L	d0
	Bpl.B	SinAok
	Neg.L	d0
SinAok	Rts

	;----

GetCosA	Bsr.B	GetCos
	Tst.L	d0
	Bpl.B	CosAok
	Neg.L	d0
CosAok	Rts

	;----

SinTab	INCBIN	Includes:Table/Sin4096
CosTab	INCBIN	Includes:Table/Cos4096
