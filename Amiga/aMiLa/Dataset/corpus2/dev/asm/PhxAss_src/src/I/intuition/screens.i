 IFND INTUITION_SCREENS_I
INTUITION_SCREENS_I SET 1
*
*  intuition/screens.i
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

 ifnd UTILITY_TAGITEM_I
 include "utility/tagitem.i"
 endc

DRI_VERSION = 1

* struct DrawInfo
 rsreset
dri_Version	rs.w 1
dri_NumPens	rs.w 1
dri_Pens	rs.l 1
dri_Font	rs.l 1
dri_Depth	rs.w 1
dri_ResolutionX rs.w 1
dri_ResolutionY rs.w 1
dri_Flags	rs.l 1
dri_longreserved rs.l 7

 BITDEF DRI,NEWLOOK,0

 enum
 eitem detailPen
 eitem blockPen
 eitem textPen
 eitem shinePen
 eitem shadowPen
 eitem hifillPen
 eitem hifilltextPen
 eitem backgroundPen
 eitem hilighttextPen
 eitem numDrIPens

* struct Screen
 rsreset
sc_NextScreen	rs.l 1
sc_FirstWindow	rs.l 1
sc_LeftEdge	rs.w 1
sc_TopEdge	rs.w 1
sc_Width	rs.w 1
sc_Height	rs.w 1
sc_MouseY	rs.w 1
sc_MouseX	rs.w 1
sc_Flags	rs.w 1
sc_Title	rs.l 1
sc_DefaultTitle rs.l 1
sc_BarHeight	rs.b 1
sc_BarVBorder	rs.b 1
sc_BarHBorder	rs.b 1
sc_MenuVBorder	rs.b 1
sc_MenuHBorder	rs.b 1
sc_WBorTop	rs.b 1
sc_WBorLeft	rs.b 1
sc_WBorRight	rs.b 1
sc_WBorBottom	rs.b 1
sc_KludgeFill00 rs.b 1
sc_Font 	rs.l 1
sc_ViewPort	rs.b vp_SIZEOF
sc_RastPort	rs.b rp_SIZEOF
sc_BitMap	rs.b bm_SIZEOF
sc_LayerInfo	rs.b li_SIZEOF
sc_FirstGadget	rs.l 1
sc_DetailPen	rs.b 1
sc_BlockPen	rs.b 1
sc_SaveColor0	rs.w 1
sc_BarLayer	rs.l 1
sc_ExtData	rs.l 1
sc_UserData	rs.l 1
sc_SIZEOF	rs.w 0

SCREENTYPE	= $000F
WBENCHSCREEN	= $0001
PUBLICSCREEN	= $0002
CUSTOMSCREEN	= $000F
SHOWTITLE	= $0010
BEEPING 	= $0020
CUSTOMBITMAP	= $0040
SCREENBEHIND	= $0080
SCREENQUIET	= $0100
SCREENHIRES	= $0200
STDSCREENHEIGHT = -1
STDSCREENWIDTH	= -1
NS_EXTEND	= $1000
AUTOSCROLL	= $4000

 enum  TAG_USER+33
 eitem SA_Left
 eitem SA_Top
 eitem SA_Width
 eitem SA_Height
 eitem SA_Depth
 eitem SA_DetailPen
 eitem SA_BlockPen
 eitem SA_Title
 eitem SA_Colors
 eitem SA_ErrorCode
 eitem SA_Font
 eitem SA_SysFont
 eitem SA_Type
 eitem SA_BitMap
 eitem SA_PubName
 eitem SA_PubSig
 eitem SA_PubTask
 eitem SA_DisplayID
 eitem SA_DClip
 eitem SA_Overscan
 eitem SA_Obsolete1
 eitem SA_ShowTitle
 eitem SA_Behind
 eitem SA_Quiet
 eitem SA_AutoScroll
 eitem SA_Pens
 eitem SA_FullPalette
 eitem SA_v39_3c
 eitem SA_Parent
 eitem SA_Draggable
 eitem SA_v39_3f
 eitem SA_v39_40
 eitem SA_v39_41
 eitem SA_Interleaved

OSERR_NOMONITOR = 1
OSERR_NOCHIPS	= 2
OSERR_NOMEM	= 3
OSERR_NOCHIPMEM = 4
OSERR_PUBNOTUNIQUUE = 5
OSERR_UNKNOWNMODE = 6

* struct NewScreen
 rsreset
ns_LeftEdge	rs.w 1
ns_TopEdge	rs.w 1
ns_Width	rs.w 1
ns_Height	rs.w 1
ns_Depth	rs.w 1
ns_DetailPen	rs.b 1
ns_BlockPen	rs.b 1
ns_ViewModes	rs.w 1
ns_Types	rs.w 1
ns_Font 	rs.l 1
ns_DefaultTitle rs.l 1
ns_Gadgets	rs.l 1
ns_CustomBitMap rs.l 1
ns_SIZEOF	rs.w 0
* struct ExtNewScreen
ens_Extension	rs.l 1
ens_SIZEOF	rs.w 0

OSCAN_TEXT	= 1
OSCAN_STANDARD	= 2
OSCAN_MAX	= 3
OSCAN_VIDEO	= 4

* struct PubScreenNode
 rsset ln_SIZE
psn_Screen	rs.l 1
psn_Flags	rs.w 1
psn_Size	rs.w 1
psn_VisitorCount rs.w 1
psn_SigTask	rs.l 1
psn_SigBit	rs.b 1
psn_Pad1	rs.b 1
psn_SIZEOF	rs.w 0

PSNF_PRIVATE	= 1
MAXPUBSCREENNAME = 139
SHANGHAI	= 1
POPPUBSCREEN	= 2

 endc
