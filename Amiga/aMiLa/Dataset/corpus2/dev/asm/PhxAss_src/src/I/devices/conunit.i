 ifnd DEVICES_CONUNIT_I
DEVICES_CONUNIT_I set 1
*
*  devices/conunit.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc
 ifnd DEVICES_CONSOLE_I
 include "devices/console.i"
 endc
 ifnd DEVICES_KEYMAP_I
 include "devices/keymap.i"
 endc
 ifnd DEVICES_INPUTEVENT_I
 include "devices/inputevent.i"
 endc

CONU_LIBRARY	= -1
CONU_STANDARD	= 0

PMB_ASM 	= M_LNM+1
PMB_AWM 	= PMB_ASM+1
MAXTABS 	= 80

* struct ConUnit
 rsset mp_SIZE
cu_Window	rs.l 1
cu_XCP		rs.w 1
cu_YCP		rs.w 1
cu_XMax 	rs.w 1
cu_YMax 	rs.w 1
cu_XRSize	rs.w 1
cu_YRSize	rs.w 1
cu_XROrigin	rs.w 1
cu_YROrigin	rs.w 1
cu_XRExtant	rs.w 1
cu_YRExtant	rs.w 1
cu_XMinShrink	rs.w 1
cu_YMinShrink	rs.w 1
cu_XCCP 	rs.w 1
cu_YCCP 	rs.w 1
cu_KeyMapStruct rs.b km_SIZEOF
cu_TabStops	rs.w MAXTABS
cu_Mask 	rs.b 1
cu_FgPen	rs.b 1
cu_BgPen	rs.b 1
cu_AOLPen	rs.b 1
cu_DrawMode	rs.b 1
cu_Obsolete1	rs.b 1
cu_Obsolete2	rs.l 1
cu_Minterms	rs.b 8
cu_Font 	rs.l 1
cu_AlgoStyle	rs.b 1
cu_TxFlags	rs.b 1
cu_TxHeight	rs.w 1
cu_TxWidth	rs.w 1
cu_TxBaseline	rs.w 1
cu_TxSpacing	rs.w 1
cu_Modes	rs.b (PMB_AWM+7)>>3
cu_RawEvents	rs.b (IECLASS_MAX+8)>>3
 ifne (((PMB_AWM+7)>>3)+((IECLASS_MAX+8)>>3))&1
cu_pad		rs.b 1
 endc
ConUnit_SIZEOF	rs

 endc
