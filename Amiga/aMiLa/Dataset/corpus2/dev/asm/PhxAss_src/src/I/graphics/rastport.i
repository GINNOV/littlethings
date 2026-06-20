 IFND GRAPHICS_RASTPORT_I
GRAPHICS_RASTPORT_I SET 1
*
*  graphics/rastport.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*


 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc

 ifnd GRAPHICS_GFX_I
 include "graphics/gfx.i"
 endc

* struct TmpRas
 rsreset
tr_RasPtr	rs.l 1
tr_Size 	rs.l 1
tr_SIZEOF	rs.w 0

* struct GelsInfo
 rsreset
gi_sprRsrvd	rs.b 1
gi_Flags	rs.b 1
gi_gelHead	rs.l 1
gi_gelTail	rs.l 1
gi_nextLine	rs.l 1
gi_lastColor	rs.l 1
gi_collHandler	rs.l 1
gi_leftmost	rs.w 1
gi_rightmost	rs.w 1
gi_topmost	rs.w 1
gi_bottommost	rs.w 1
gi_firstBlissObj rs.l 1
gi_lastBlissObj rs.l 1
gi_SIZEOF	rs.w 0

 BITDEF RP,FRST_DOT,0
 BITDEF RP,ONE_DOT,1
 BITDEF RP,DBUFFER,2
 BITDEF RP,AREAOUTLINE,3
 BITDEF RP,NOCROSSFILL,5

RP_JAM1 	= 0
RP_JAM2 	= 1
RP_COMPLEMENT	= 2
RP_INVERSID	= 4

 BITDEF RP,TXSCALE,0

* struct RastPort
 rsreset
rp_Layer	rs.l 1
rp_BitMap	rs.l 1
rp_AreaPtrn	rs.l 1
rp_TmpRas	rs.l 1
rp_AreaInfo	rs.l 1
rp_GelsInfo	rs.l 1
rp_Mask 	rs.b 1
rp_FgPen	rs.b 1
rp_BgPen	rs.b 1
rp_AOlPen	rs.b 1
rp_DrawMode	rs.b 1
rp_AreaPtSz	rs.b 1
rp_linpatcnt	rs.b 1
rp_Dummy	rs.b 1
rp_Flags	rs.w 1
rp_LinePtrn	rs.w 1
rp_cp_x 	rs.w 1
rp_cp_y 	rs.w 1
rp_minterms	rs.b 8
rp_PenWidth	rs.w 1
rp_PenHeight	rs.w 1
rp_Font 	rs.l 1
rp_AlgoStyle	rs.b 1
rp_TxFlags	rs.b 1
rp_TxHeight	rs.w 1
rp_TxWidth	rs.w 1
rp_TxBaseline	rs.w 1
rp_TxSpacing	rs.w 1
rp_RP_User	rs.l 1
rp_longreserved rs.l 2
rp_wordreserved rs.w 7
rp_reserved	rs.b 8
rp_SIZEOF	rs.w 0

* struct AreaInfo
 rsreset
ai_VctrTbl	rs.l 1
ai_VctrPtr	rs.l 1
ai_FlagTbl	rs.l 1
ai_FlagPtr	rs.l 1
ai_Count	rs.w 1
ai_MaxCount	rs.w 1
ai_FirstX	rs.w 1
ai_FirstY	rs.w 1
ai_SIZEOF	rs.w 0

ONE_DOTn	= 1
ONE_DOT 	= 2
FRST_DOTn      = 0
FRST_DOT       = 1

 endc
