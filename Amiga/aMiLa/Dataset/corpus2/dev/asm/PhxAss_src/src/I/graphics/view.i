 IFND GRAPHICS_VIEW_I
GRAPHICS_VIEW_I SET 1
*
*  graphics/view.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd GRAPHICS_GFX_I
 include "graphics/gfx.i"
 endc

 ifnd GRAPHICS_COPPER_I
 include "graphics/copper.i"
 endc

 ifnd GRAPHICS_GFXNODES_I
 include "graphics/gfxnodes.i"
 endc

GENLOCK_VIDEO		= 2
V_LACE			= 4
V_SUPERHIRES		= $20
V_PFBA			= $40
V_EXTRA_HALFBRITE	= $80
GENLOCK_AUDIO		= $100
V_DUALPF		= $400
V_HAM			= $800
V_EXTENDED_MODE 	= $1000
V_VP_HIDE		= $2000
V_SPRITES		= $4000
V_HIRES 		= $8000

EXTEND_VSTRUCT		= $1000

VPF_DENISE	= $80
VPF_A2024	= $40
VPF_AGNUS	= $20
VPF_TENHZ	= $20
VPF_ILACE	= $10

VARVBLANK	= $1000
LOLDIS		= $0800
CSCBLANKEN	= $0400
VARVSYNC	= $0200
VARHSYNC	= $0100
VARBEAM 	= $0080
DISPLAYDUAL	= $0040
DISPLAYPAL	= $0020
VARCSYNC	= $0010
CSBLANK 	= $0008
CSYNCTRUE	= $0004
VSYNCTRUE	= $0002
HSYNCTRUE	= $0001

USE_BPLCON3		= 1
BPLCON2_ZDCTEN		= 1<<10
BPLCON2_ZDBPEN		= 1<<11
BPLCON2_ZDBPSEL0	= 1<<12
BPLCON2_ZDBPSEL1	= 1<<13
BPLCON2_ZDBPSEL2	= 1<<14
BPLCON3_EXTBLNKEN	= 1<<0
BPLCON3_EXTBLKZD	= 1<<1
BPLCON3_ZDCLKEN 	= 1<<2
BPLCON3_BRDNTRAN	= 1<<4
BPLCON3_BRDNBLNK	= 1<<5

* struct ColorMap
 rsreset
cm_Flags	rs.b 1
cm_Type 	rs.b 1
cm_Count	rs.w 1
cm_ColorTable	rs.l 1
cm_vpe		rs.l 1
cm_TransparencyBits rs.l 1
cm_TransparencyPlane rs.b 1
cm_reserved1	rs.b 1
cm_reserved2	rs.w 1
cm_vp		rs.l 1
cm_NormalDisplayInfo rs.l 1
cm_CoerceDisplayInfo rs.l 1
cm_batch_items	rs.l 1
cm_VPModeID	rs.l 1
cm_SIZEOF	rs.w 0

COLORMAP_TYPE_V1_2	= 0
COLORMAP_TYPE_V1_4	= 1
COLORMAP_TRANSPARENCY	= $01
COLORPLANE_TRANSPARENCY = $02
BORDER_BLANKING 	= $04
BORDER_NOTRANSPARENCY	= $08
VIDEOCONTROL_BATCH	= $10

* struct ViewPort
 rsreset
vp_Next 	rs.l 1
vp_ColorMap	rs.l 1
vp_DspIns	rs.l 1
vp_SprIns	rs.l 1
vp_ClrIns	rs.l 1
vp_UCopIns	rs.l 1
vp_DWidth	rs.w 1
vp_DHeight	rs.w 1
vp_DxOffset	rs.w 1
vp_DyOffset	rs.w 1
vp_Modes	rs.w 1
vp_SpritePriorities rs.b 1
vp_ExtendedModes rs.b 1
vp_RasInfo	rs.l 1
vp_SIZEOF	rs.w 0

* struct View
 rsreset
v_ViewPort	rs.l 1
v_LOFCprList	rs.l 1
v_SHFCprList	rs.l 1
v_DyOffset	rs.w 1
v_DxOffset	rs.w 1
v_Modes 	rs.w 1
v_SIZEOF	rs.w 0

* struct ViewExtra
 rsset xln_SIZE
ve_View 	rs.l 1
ve_Monitor	rs.l 1
ve_SIZEOF	rs.w 0

* struct ViewPortExtra
 rsset xln_SIZE
vpe_ViewPort	rs.l 1
vpe_DisplayClip rs.b ra_SIZEOF
vpe_SIZEOF	rs.w 0

* struct collTable
 rsreset
cp_collPtrs	rs.l 16
cp_SIZEOF	rs.w 0

* struct RasInfo
 rsreset
ri_Next 	rs.l 1
ri_BitMap	rs.l 1
ri_RxOffset	rs.w 1
ri_RyOffset	rs.w 1
ri_SIZEOF	rs.w 0

 endc
