	IFND	GRAPHICS_RASTPORT_I
GRAPHICS_RASTPORT_I	SET	1

	STRUCTURE	RastPort,0
		APTR	rp_Layer
		APTR	rp_BitMap
		APTR	rp_AreaPtrn
		APTR	rp_TmpRas
		APTR	rp_AreaInfo
		APTR	rp_GelsInfo
		UBYTE	rp_Mask
		BYTE	rp_FgPen
		BYTE	rp_BgPen
		BYTE	rp_A01Pen
		BYTE	rp_DrawMode
		BYTE	rp_AreaPtSz
		BYTE	rp_linpatcnt
		BYTE	rp_dummy
		USHORT	rp_Flags
		USHORT	rp_LinePtrn
		SHORT	rp_cp_x
		SHORT	rp_cp_y
		STRUCT	rp_minterms,8
		SHORT	rp_PenWidth
		SHORT	rp_PenHeight
		APTR	rp_Font
		UBYTE	rp_AlgoStyle
		UBYTE	rp_TxFlags
		UWORD	rp_TxWidth
		UWORD	rp_TxHeight
		UWORD	rp_TxBaseline
		WORD	rp_TxSpacing
		APTR	rp_User
		STRUCT	rp_longreserved,8
		STRUCT	rp_wordreserved,14
		STRUCT	rp_reserved,8
		LABEL	rp_SIZEOF

RP_JAM1=0
RP_JAM2=1
RP_COMPLEMENT=2
RP_INVERSVID=4

	STRUCTURE	TmpRas,0
		APTR	tr_RasPtr
		LONG	tr_Size
		LABEL	tr_SIZEOF

	ENDC ; GRAPHICS_RASTPORT_I
