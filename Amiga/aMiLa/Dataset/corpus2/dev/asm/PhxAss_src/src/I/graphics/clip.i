 IFND GRAPHICS_CLIP_I
GRAPHICS_CLIP_I SET 1
*
*  graphics/clip.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd GRAPHICS_GFX_I
 include "graphics/gfx.i"
 endc

 ifnd EXEC_SEMAPHORES_I
 include "exec/semaphores.i"
 endc

NEWLOCKS = 1

* struct Layer
lr_front	rs.l 1
lr_back 	rs.l 1
lr_ClipRect	rs.l 1
lr_rp		rs.l 1
lr_MinX 	rs.w 1
lr_MinY 	rs.w 1
lr_MaxX 	rs.w 1
lr_MaxY 	rs.w 1
lr_reserved	rs.l 1
lr_priority	rs.w 1
lr_Flags	rs.w 1
lr_SuperBitMap	rs.l 1
lr_SuperClipRect rs.l 1
lr_Window	rs.l 1
lr_Scroll_X	rs.w 1
lr_Scroll_Y	rs.w 1
lr_cr		rs.l 1
lr_cr2		rs.l 1
lr_crnew	rs.l 1
lr_SuperSaverClipRects rs.l 1
lr__cliprects	rs.l 1
lr_LayerInfo	rs.l 1
lr_Lock 	rs.b ss_SIZE
lr_BackFill	rs.l 1
lr_reserved1	rs.l 1
lr_ClipRegion	rs.l 1
lr_SaveClipRects rs.l 1
lr_reserved2	rs.b 22
lr_DamageList	rs.l 1
lr_SIZEOF	rs.w 0

* struct ClipRect
 rsreset
cr_Next 	rs.l 1
cr_prev 	rs.l 1
cr_lobs 	rs.l 1
cr_BitMap	rs.l 1
cr_MinX 	rs.w 1
cr_MinY 	rs.w 1
cr_MaxX 	rs.w 1
cr_MaxY 	rs.w 1
cr__p1		rs.l 1
cr__p2		rs.l 1
cr_reserved	rs.l 1
cr_Flags	rs.l 1
cr_SIZEOF	rs.w 0

CR_NEEDS_NO_CONCEALED_RASTERS = 1

ISLESSX 	= 1
ISLESSY 	= 2
ISGRTRX 	= 4
ISGRTRY 	= 8

 ifnd lr_Front
lr_Front	= lr_front
lr_Back 	= lr_back
lr_RastPort	= lr_rp
cr_Prev 	= cr_prev
cr_LObs 	= cr_lobs
 endc

 endc
