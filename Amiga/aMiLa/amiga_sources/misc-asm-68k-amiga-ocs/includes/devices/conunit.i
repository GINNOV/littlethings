	IFND	DEVICES_CONUNIT_I
DEVICES_CONUNIT_I	EQU	1
	IFND	EXEC_PORTS_I
	INCLUDE	"exec/ports.i"
	ENDC
	IFND	DEVICES_KEYMAP_I
	INCLUDE	"devices/keymap.i"
	ENDC
PMB_ASM	EQU	M_LNM+1
PMB_AWM	EQU	PMB_ASM+1
MAXTABS	EQU	80
	rsreset
ConUnit	rs.b	MP_SIZE
cu_Window	rs.l	1
cu_XCP	rs.w	1
cu_YCP	rs.w	1
cu_XMax	rs.w	1
cu_YMax	rs.w	1
cu_XRSize	rs.w	1
cu_YRSize	rs.w	1
cu_XROrigin	rs.w	1
cu_YROrigin	rs.w	1
cu_XRExtant	rs.w	1
cu_YRExtant	rs.w	1
cu_XMinShrink	rs.w	1
cu_YMinShrink	rs.w	1
cu_XCCP	rs.w	1
cu_YCCP	rs.w	1
cu_KeyMapStruct	rs.b	km_SIZEOF
cu_TabStops	rs.b	2*MAXTABS
cu_Mask	rs.b	1
cu_FgPen	rs.b	1
cu_BgPen	rs.b	1
cu_AOLPen	rs.b	1
cu_DrawMode	rs.b	1
cu_AreaPtSz	rs.b	1
cu_AreaPtrn	rs.l	1
cu_Minterms	rs.b	8
cu_Font	rs.l	1
cu_AlgoStyle	rs.b	1
cu_TxFlags	rs.b	1
cu_TxHeight	rs.w	1
cu_TxWidth	rs.w	1
cu_TxBaseline	rs.w	1
cu_TxSpacing	rs.w	1
cu_Modes	rs.b	<(PMB_AWM+7)/8>
cu_RawEvents	rs.b	<(IECLASS_MAX+7)/8>
ODDEVEN	EQU	((PMB_AWM+7)/8)+((IECLASS_MAX+7)/8)
	IFNE	ODDEVEN-((ODDEVEN/2)*2)
cu_pad	rs.b	1
	ENDC
ConUnit_SIZEOF	rs.w	0
	ENDC

