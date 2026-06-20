	IFND    GADGETS_SELECT_I
GADGETS_SELECT_I	SET	1
**
**	$VER: select.i V1.0 (10.June.2001)
**	Includes Release 40.15
**
**	Interface definitions for Boopsi select.gadget
**
**	Include Written By: John White, 10.June.2001
**	select.gadget (c) 2000, Massimo Tantignone.
**

SGA_Dummy	EQU	TAG_USER+$A0000
SGA_Active      EQU	(SGA_Dummy+$0001)
SGA_Labels      EQU	(SGA_Dummy+$0002)
SGA_MinItems    EQU	(SGA_Dummy+$0003)
SGA_FullPopUp   EQU	(SGA_Dummy+$0004)
SGA_PopUpDelay  EQU	(SGA_Dummy+$0005)
SGA_PopUpPos    EQU	(SGA_Dummy+$0006)
SGA_Sticky      EQU	(SGA_Dummy+$0007)
SGA_TextAttr    EQU	(SGA_Dummy+$0008)
SGA_TextFont    EQU	(SGA_Dummy+$0009)
SGA_TextPlace   EQU	(SGA_Dummy+$000A)
SGA_Underscore  EQU	(SGA_Dummy+$000B)
SGA_Justify     EQU	(SGA_Dummy+$000C)
SGA_Quiet       EQU	(SGA_Dummy+$000D)
SGA_Symbol      EQU	(SGA_Dummy+$000E)
SGA_SymbolWidth EQU	(SGA_Dummy+$000F)
SGA_SymbolOnly  EQU	(SGA_Dummy+$0010)
SGA_Separator   EQU	(SGA_Dummy+$0011)
SGA_ListFrame   EQU	(SGA_Dummy+$0012)
SGA_DropShadow  EQU	(SGA_Dummy+$0013)
SGA_ItemHeight  EQU	(SGA_Dummy+$0014)
SGA_ListJustify EQU	(SGA_Dummy+$0015)
SGA_ActivePens  EQU	(SGA_Dummy+$0016)
SGA_ActiveBox   EQU	(SGA_Dummy+$0017)
SGA_BorderSize  EQU	(SGA_Dummy+$0018)
SGA_FullWidth   EQU	(SGA_Dummy+$0019)
SGA_FollowMode  EQU	(SGA_Dummy+$001A)
SGA_ReportAll   EQU	(SGA_Dummy+$001B)
SGA_Refresh     EQU	(SGA_Dummy+$001C)
SGA_ItemSpacing EQU	(SGA_Dummy+$001D)
SGA_MinTime     EQU	(SGA_Dummy+$001E)  /* Min anim duration (40.14) */
SGA_MaxTime     EQU	(SGA_Dummy+$001F)  /* Max anim duration (40.14) */
SGA_PanelMode   EQU	(SGA_Dummy+$0020)  /* Window? Blocking? (40.14) */
SGA_Transparent EQU	(SGA_Dummy+$0021)  /* Transparent menu? (40.17) */

SGJ_LEFT   	EQU	0
SGJ_CENTER 	EQU	1
SGJ_RIGHT  	EQU	2

SGPOS_ONITEM 	EQU	0
SGPOS_ONTOP  	EQU	1
SGPOS_BELOW  	EQU	2
SGPOS_RIGHT  	EQU	3

SGFM_NONE 	EQU	0
SGFM_KEEP 	EQU	1
SGFM_FULL 	EQU	2

SGPM_WINDOW    	EQU	0
SGPM_DIRECT_NB 	EQU	1
SGPM_DIRECT_B  	EQU	2

SGS_NOSYMBOL 	EQU	$FFFFFFFF


; Public structures for the "select gadget" BOOPSI class.


	ENDC