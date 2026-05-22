 IFND INTUITION_INTUTION_I
INTUITION_INTUITION_I SET 1
*
*  intuition/intuition.i
*  Release 3.1
*  for PhxAss
*
*  © copyright by F.Wille in 1996
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc

 ifnd GRAPHICS_GFX_I
 include "graphics/gfx.i"
 endc

 ifnd GRAPHICS_CLIP_I
 include "graphics/clip.i"
 endc

 ifnd GRAPHICS_VIEW_I
 include "graphics/view.i"
 endc

 ifnd GRAPHICS_RASTPORT_I
 include "graphics/rastport.i"
 endc

 ifnd GRAPHICS_LAYERS_I
 include "graphics/layers.i"
 endc

 ifnd GRAPHICS_TEXT_I
 include "graphics/text.i"
 endc

 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc

 ifnd DEVICES_TIMER_I
 include "devices/timer.i"
 endc

 ifnd DEVICES_INPUTEVENT_I
 include "devices/inputevent.i"
 endc

 ifnd UTILITY_TAGITEM_I
 include "utility/tagitem.i"
 endc


* struct Menu
 rsreset
mu_NextMenu	rs.l 1
mu_LeftEdge	rs.w 1
mu_TopEdge	rs.w 1
mu_Width	rs.w 1
mu_Height	rs.w 1
mu_Flags	rs.w 1
mu_MenuName	rs.l 1
mu_FirstItem	rs.l 1
mu_JazzX	rs.w 1
mu_JazzY	rs.w 1
mu_BeatX	rs.w 1
mu_BeatY	rs.w 1
mu_SIZEOF	rs.w 0

MENUENABLED	= $0001
MIDRAWN 	= $0100

* struct MenuItem
 rsreset
mi_NextItem	rs.l 1
mi_LeftEdge	rs.w 1
mi_TopEdge	rs.w 1
mi_Width	rs.w 1
mi_Height	rs.w 1
mi_Flags	rs.w 1
mi_MutualExclude rs.l 1
mi_ItemFill	rs.l 1
mi_SelectFill	rs.l 1
mi_Command	rs.b 1
mi_KludgeFill00 rs.b 1
mi_SubItem	rs.l 1
mi_NextSelect	rs.w 1
mi_SIZEOF	rs.w 0

CHECKIT 	= $0001
ITEMTEXT	= $0002
COMMSEQ 	= $0004
MENUTOGGLE	= $0008
ITEMENABLED	= $0010
HIGHFLAGS	= $00C0
HIGHIMAGE	= $0000
HIGHCOMP	= $0040
HIGHBOX 	= $0080
HIGHNONE	= $00C0
CHECKED 	= $0100
ISDRAWN 	= $1000
HIGHITEM	= $2000
MENUTOGGLED	= $4000

* struct Requester
 rsreset
rq_OlderRequest rs.l 1
rq_LeftEdge	rs.w 1
rq_TopEdge	rs.w 1
rq_Width	rs.w 1
rq_Height	rs.w 1
rq_RelLeft	rs.w 1
rq_RelTop	rs.w 1
rq_ReqGadget	rs.l 1
rq_ReqBorder	rs.l 1
rq_ReqText	rs.l 1
rq_Flags	rs.w 1
rq_BackFill	rs.b 1
rq_KludgeFill00 rs.b 1
rq_ReqLayer	rs.l 1
rq_ReqPad1	rs.b 32
rq_ImageBMap	rs.l 1
rq_RWindow	rs.l 1
rq_ReqImage	rs.l 1
rq_ReqPad2	rs.b 32
rq_SIZEOF	rs.w 0

POINTREL	= $0001
PREDRAWN	= $0002
NOISYREQ	= $0004
SIMPLEREQ	= $0010
USEREQIMAGE	= $0020
NOREQBACKFILL	= $0040
REQOFFWINDOW	= $1000
REQACTIVE	= $2000
SYSREQUEST	= $4000
DEFERREFRESH	= $8000

* struct Gadget
 rsreset
gg_NextGadget	rs.l 1
gg_LeftEdge	rs.w 1
gg_TopEdge	rs.w 1
gg_Width	rs.w 1
gg_Height	rs.w 1
gg_Flags	rs.w 1
gg_Activation	rs.w 1
gg_GadgetType	rs.w 1
gg_GadgetRender rs.l 1
gg_SelectRender rs.l 1
gg_GadgetText	rs.l 1
gg_MutualExclude rs.l 1
gg_SpecialInfo	rs.l 1
gg_GadgetID	rs.w 1
gg_UserData	rs.l 1
gg_SIZEOF	rs.w 0

GADGHIGHBITS	= $0003
GADGHCOMP	= $0000
GADGHBOX	= $0001
GADGHIMAGE	= $0002
GADGHNONE	= $0003
GADGIMAGE	= $0004
GRELBOTTOM	= $0008
GRELRIGHT	= $0010
GRELWIDTH	= $0020
GRELHEIGHT	= $0040
SELECTED	= $0080
GADGDISABLED	= $0100
LABELMASK	= $3000
LABELITEXT	= $0000
LABELSTRING	= $1000
LABELIMAGE	= $2000

RELVERIFY	= $0001
GADGIMMEDIATE	= $0002
ENDGADGET	= $0004
FOLLOWMOUSE	= $0008
RIGHTBORDER	= $0010
LEFTBORDER	= $0020
TOPBORDER	= $0040
BOTTOMBORDER	= $0080
BORDERSNIFF	= $8000
TOGGLESELECT	= $0100
BOOLEXTEND	= $2000
STRINGCENTER	= $0200
STRINGRIGHT	= $0400
LONGINT 	= $0800
ALTKEYMAP	= $1000
STRINGEXTEND	= $2000
ACTIVEGADGET	= $4000

GADGETTYPE	= $FC00
SYSGADGET	= $8000
SCRGADGET	= $4000
GZZGADGET	= $2000
REQGADGET	= $1000
SIZING		= $0010
WDRAGGING	= $0020
SDRAGGING	= $0030
WUPFRONT	= $0040
SUPFRONT	= $0050
WDOWNBACK	= $0060
SDOWNBACK	= $0070
CLOSE		= $0080
BOOLGADGET	= $0001
GADGET002	= $0002
PROPGADGET	= $0003
STRGADGET	= $0004
CUSTOMGADGET	= $0005
GTYPEMASK	= $0004

* struct BoolInfo
 rsreset
bi_Flags	rs.w 1
bi_Mask 	rs.l 1
bi_Reserved	rs.l 1
bi_SIZEOF	rs.w 0

BOOLMASK	= $0001

* struct PropInfo
 rsreset
pi_Flags	rs.w 1
pi_HorizPot	rs.w 1
pi_VertPot	rs.w 1
pi_HorizBody	rs.w 1
pi_VertBody	rs.w 1
pi_CWidth	rs.w 1
pi_CHeight	rs.w 1
pi_HPotRes	rs.w 1
pi_VPotRes	rs.w 1
pi_LeftBorder	rs.w 1
pi_TopBorder	rs.w 1
pi_SIZEOF	rs.w 0

AUTOKNOB	= $0001
FREEHORIZ	= $0002
FREEVERT	= $0004
PROPBORDERLESS	= $0008
KNOBHIT 	= $0100
KNOBHMIN	= 6
KNOBVMIN	= 4
MAXBODY 	= $FFFF
MAXPOT		= $FFFF

* struct StringInfo
 rsreset
si_Buffer	rs.l 1
si_UndoBuffer	rs.l 1
si_BufferPos	rs.w 1
si_MaxChars	rs.w 1
si_DispPos	rs.w 1
si_UndoPos	rs.w 1
si_NumChars	rs.w 1
si_DispCount	rs.w 1
si_CLeft	rs.w 1
si_CTop 	rs.w 1
si_Extension	rs.l 1
si_LongInt	rs.l 1
si_AltKeyMap	rs.l 1
si_SIZEOF	rs.w 0

* struct IntuiText
 rsreset
it_FrontPen	rs.b 1
it_BackPen	rs.b 1
it_DrawMode	rs.b 1
it_KludgeFill00 rs.b 1
it_LeftEdge	rs.w 1
it_TopEdge	rs.w 1
it_ITextFont	rs.l 1
it_IText	rs.l 1
it_NextText	rs.l 1
it_SIZEOF	rs.w 0

* struct Border
 rsreset
bd_LeftEdge	rs.w 1
bd_TopEdge	rs.w 1
bd_FrontPen	rs.b 1
bd_BackPen	rs.b 1
bd_DrawMode	rs.b 1
bd_Count	rs.b 1
bd_XY		rs.l 1
bd_NextBorder	rs.l 1
bd_SIZEOF	rs.w 0

* struct Image
 rsreset
ig_LeftEdge	rs.w 1
ig_TopEdge	rs.w 1
ig_Width	rs.w 1
ig_Height	rs.w 1
ig_Depth	rs.w 1
ig_ImageData	rs.l 1
ig_PlanePick	rs.b 1
ig_PlaneOnOff	rs.b 1
ig_NextImage	rs.l 1
ig_SIZEOF	rs.w 0

* struct IntuiMessage
 rsset mn_SIZE
im_Class	rs.l 1
im_Code 	rs.w 1
im_Qualifier	rs.w 1
im_IAddress	rs.l 1
im_MouseX	rs.w 1
im_MouseY	rs.w 1
im_Seconds	rs.l 1
im_Micros	rs.l 1
im_IDCMPWindow	rs.l 1
im_SpecialLink	rs.l 1
im_SIZEOF	rs.w 0

IDCMP_SIZEVERIFY	EQU	$00000001
IDCMP_NEWSIZE		EQU	$00000002
IDCMP_REFRESHWINDOW	EQU	$00000004
IDCMP_MOUSEBUTTONS	EQU	$00000008
IDCMP_MOUSEMOVE		EQU	$00000010
IDCMP_GADGETDOWN	EQU	$00000020
IDCMP_GADGETUP		EQU	$00000040
IDCMP_REQSET		EQU	$00000080
IDCMP_MENUPICK		EQU	$00000100
IDCMP_CLOSEWINDOW	EQU	$00000200
IDCMP_RAWKEY		EQU	$00000400
IDCMP_REQVERIFY		EQU	$00000800
IDCMP_REQCLEAR		EQU	$00001000
IDCMP_MENUVERIFY	EQU	$00002000
IDCMP_NEWPREFS		EQU	$00004000
IDCMP_DISKINSERTED	EQU	$00008000
IDCMP_DISKREMOVED	EQU	$00010000
IDCMP_WBENCHMESSAGE	EQU	$00020000	; System use only
IDCMP_ACTIVEWINDOW	EQU	$00040000
IDCMP_INACTIVEWINDOW	EQU	$00080000
IDCMP_DELTAMOVE		EQU	$00100000
IDCMP_VANILLAKEY	EQU	$00200000
IDCMP_INTUITICKS	EQU	$00400000
IDCMP_IDCMPUPDATE	EQU	$00800000	; new for V36
IDCMP_MENUHELP		EQU	$01000000	; new for V36
IDCMP_CHANGEWINDOW	EQU	$02000000	; new for V36
IDCMP_GADGETHELP	EQU	$04000000	; new for V39
IDCMP_LONELYMESSAGE	EQU	$80000000

SIZEVERIFY	= $00000001
NEWSIZE 	= $00000002
REFRESHWINDOW	= $00000004
MOUSEBUTTONS	= $00000008
MOUSEMOVE	= $00000010
GADGETDOWN	= $00000020
GADGETUP	= $00000040
REQSET		= $00000080
MENUPICK	= $00000100
CLOSEWINDOW	= $00000200
RAWKEY		= $00000400
REQVERIFY	= $00000800
REQCLEAR	= $00001000
MENUVERIFY	= $00002000
NEWPREFS	= $00004000
DISKINSERTED	= $00008000
DISKREMOVED	= $00010000
WBENCHMESSAGE	= $00020000
ACTIVEWINDOW	= $00040000
INACTIVEWINDOW	= $00080000
DELTAMOVE	= $00100000
VANILLAKEY	= $00200000
INTUITICKS	= $00400000
IDCMPUPDATE	= $00800000
MENUHELP	= $01000000
CHANGEWINDOW	= $02000000
LONELYMESSAGE	= $80000000

CWCODE_MOVESIZE	EQU	$0000	; Window was moved and/or sized
CWCODE_DEPTH	EQU	$0001	; Window was depth-arranged (new for V39)


* struct IBox
 rsreset
ibox_Left	rs.w 1
ibox_Top	rs.w 1
ibox_Width	rs.w 1
ibox_Height	rs.w 1
ibox_SIZEOF	rs.w 0

* struct Window
 rsreset
wd_NextWindow	rs.l 1
wd_LeftEdge	rs.w 1
wd_TopEdge	rs.w 1
wd_Width	rs.w 1
wd_Height	rs.w 1
wd_MouseX	rs.w 1
wd_MouseY	rs.w 1
wd_MinWidth	rs.w 1
wd_MinHeight	rs.w 1
wd_MaxWidth	rs.w 1
wd_MaxHeight	rs.w 1
wd_Flags	rs.l 1
wd_MenuStrip	rs.l 1
wd_Title	rs.l 1
wd_FirstRequest rs.l 1
wd_DMRequest	rs.l 1
wd_ReqCount	rs.w 1
wd_WScreen	rs.l 1
wd_RPort	rs.l 1
wd_BorderLeft	rs.b 1
wd_BorderTop	rs.b 1
wd_BorderRight	rs.b 1
wd_BorderBottom rs.b 1
wd_BorderRPort	rs.l 1
wd_FirstGadget	rs.l 1
wd_Parent	rs.l 1
wd_Descendant	rs.l 1
wd_Pointer	rs.l 1
wd_PtrHeight	rs.b 1
wd_PtrWidth	rs.b 1
wd_XOffset	rs.b 1
wd_YOffset	rs.b 1
wd_IDCMPFlags	rs.l 1
wd_UserPort	rs.l 1
wd_WindowPort	rs.l 1
wd_MessageKey	rs.l 1
wd_DetailPen	rs.b 1
wd_BlockPen	rs.b 1
wd_CheckMark	rs.l 1
wd_ScreenTitle	rs.l 1
wd_GZZMouseX	rs.w 1
wd_GZZMouseY	rs.w 1
wd_GZZWidth	rs.w 1
wd_GZZHeight	rs.w 1
wd_ExtData	rs.l 1
wd_UserData	rs.l 1
wd_WLayer	rs.l 1
wd_IFont	rs.l 1
wd_MoreFlags	rs.l 1
wd_Size 	rs.w 0
wd_SIZEOF	rs.w 0

WINDOWSIZING	= $0001
WINDOWDRAG	= $0002
WINDOWDEPTH	= $0004
WINDOWCLOSE	= $0008
SIZEBRIGHT	= $0010
SIZEBOTTOM	= $0020
REFRESHBITS	= $00C0
SMARTREFRESH	= $0000
SIMPLEREFRESH	= $0040
SUPER_BITMAP	= $0080
OTHER_REFRESH	= $00C0
BACKDROP	= $0100
REPORTMOUSE	= $0200
GIMMEZEROZERO	= $0400
BORDERLESS	= $0800
ACTIVATE	= $1000
WINDOWACTIVE	= $2000
INREQUEST	= $4000
MENUSTATE	= $8000
RMBTRAP 	= $10000
NOCAREREFRESH	= $20000
WINDOWREFRESH	= $1000000
WBENCHWINDOW	= $2000000
WINDOWTICKED	= $4000000
SUPER_UNUSED	= $FCFC0000
NW_EXTENDED	= $40000
VISITOR 	= $8000000
ZOOMED		= $10000000
HASZOOM 	= $20000000

DEFAULTMOUSEQUEUE = 5

* struct NewWindow
 rsreset
nw_LeftEdge	rs.w 1
nw_TopEdge	rs.w 1
nw_Width	rs.w 1
nw_Height	rs.w 1
nw_DetailPen	rs.b 1
nw_BlockPen	rs.b 1
nw_IDCMPFlags	rs.l 1
nw_Flags	rs.l 1
nw_FirstGadget	rs.l 1
nw_CheckMark	rs.l 1
nw_Title	rs.l 1
nw_Screen	rs.l 1
nw_BitMap	rs.l 1
nw_MinWidth	rs.w 1
nw_MinHeight	rs.w 1
nw_MaxWidth	rs.w 1
nw_MaxHeight	rs.w 1
nw_Type 	rs.w 1
nw_SIZE 	rs.w 0
nw_SIZEOF	rs.w 0
* struct ExtNewWindow
enw_Extension	rs.l 1
enw_SIZEOF	rs.w 0

 enum TAG_USER+100
 eitem WA_Left
 eitem WA_Top
 eitem WA_Width
 eitem WA_Height
 eitem WA_DetailPen
 eitem WA_BlockPen
 eitem WA_IDCMP
 eitem WA_Flags
 eitem WA_Gadgets
 eitem WA_Checkmark
 eitem WA_Title
 eitem WA_ScreenTitle
 eitem WA_CustomScreen
 eitem WA_SuperBitMap
 eitem WA_MinWidth
 eitem WA_MinHeight
 eitem WA_MaxWidth
 eitem WA_MaxHeight
 eitem WA_InnderWidth
 eitem WA_InnerHeight
 eitem WA_PubScreenName
 eitem WA_PubScreen
 eitem WA_PubScreenFallBack
 eitem WA_WindowName
 eitem WA_Colors
 eitem WA_Zoom
 eitem WA_MouseQueue
 eitem WA_BackFill
 eitem WA_RptQueue
 eitem WA_SizeGadget
 eitem WA_DragBar
 eitem WA_DepthGadget
 eitem WA_CloseGadget
 eitem WA_Backdrop
 eitem WA_ReportMouse
 eitem WA_NoCareRefresh
 eitem WA_Borderless
 eitem WA_Activate
 eitem WA_RMBTrap
 eitem WA_WBenchWindow
 eitem WA_SimpleRefresh
 eitem WA_SizeBRight
 eitem WA_SizeBBottom
 eitem WA_AutoAdjust
 eitem WA_GimmeZeroZero
 eitem WA_v39_91
 eitem WA_v39_92
 eitem WA_NewLookMenus
 eitem WA_v39_94
 eitem WA_v39_95
 eitem WA_v39_96
 eitem WA_Pointer
 eitem WA_BusyPointer
 eitem WA_PointerDelay

 ifnd _PHXASS_

 ifnd INTUITION_SCREENS_I
 include "intuition/screens.i"
 endc

 ifnd INTUITION_PREFERENCES_I
 include "intuition/preferences.i"
 endc

 endc

* struct Remember
 rsreset
rm_NextRemember rs.l 1
rm_RememberSize rs.l 1
rm_Memory	rs.l 1
rm_SIZEOF	rs.w 0

* struct ColorSpec
 rsreset
cs_ColorIndex	rs.w 1
cs_Red		rs.w 1
cs_Green	rs.w 1
cs_Blue 	rs.w 1
cd_SIZEOF	rs.w 0

* struct EasyStruct
 rsreset
es_StructSize	rs.l 1
es_Flags	rs.l 1
es_Title	rs.l 1
es_TextFormat	rs.l 1
es_GadgetFormat rs.l 1
es_SIZEOF	rs.w 0

NOMENU		= $1F
NOITEM		= $3F
NOSUB		= $1F
MENUNULL	= $FFFF

CHECKWIDTH	= 19
COMMWIDTH	= 27
LOWCHECKWIDTH	= 13
LOWCOMMWIDTH	= 16

ALERT_TYPE	= $80000000
RECOVERY_ALERT	= $00000000
DEADEND_ALERT	= $80000000

AUTOFRONTPEN	= 0
AUTOBACKPEN	= 1
AUTODRAWMODE	= RP_JAM2
AUTOLEFTEDGE	= 6
AUTOTOPEDGE	= 3
AUTOITEXTFONT	= 0
AUTONEXTTEXT	= 0

SELECTUP	= (IECODE_LBUTTON+IECODE_UP_PREFIX)
SELECTDOWN	= (IECODE_LBUTTON)
MENUUP		= (IECODE_RBUTTON+IECODE_UP_PREFIX)
MENUDOWN	= (IECODE_RBUTTON)
ALTLEFT 	= (IEQUALIFIER_LALT)
ALTRIGHT	= (IEQUALIFIER_RALT)
AMIGALEFT	= (IEQUALIFIER_LCOMMAND)
AMIGARIGHT	= (IEQUALIFIER_RCOMMAND)
AMIGAKEYS	= (AMIGALEFT+AMIGARIGHT)

CURSORUP	= $4C
CURSORLEFT	= $4F
CURSORRIGHT	= $4E
CURSORDOWN	= $4D
KEYCODE_Q	= $10
KEYCODE_X	= $32
KEYCODE_N	= $36
KEYCODE_M	= $37
KEYCODE_V	= $34
KEYCODE_B	= $35
KEYCODE_LESS	= $38
KEYCODE_GREATER = $39

 ifnd _PHXASS_
 ifnd INTUITION_INTUITIONBASE_I
 include "intuition/intuitionbase.i"
 endc
 endc

 endc
