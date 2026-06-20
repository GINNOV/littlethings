 IFND GRAPHICS_LAYERS_I
GRAPHICS_LAYERS_I SET 1
*
*  graphics/layers.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc

 ifnd EXEC_SEMAPHORES_I
 include "exec/semaphores.i"
 endc

LAYERSIMPLE	= 1
LAYERSMART	= 2
LAYERSUPER	= 4
LAYERUPDATING	= $10
LAYERBACKDROP	= $40
LAYERREFRESH	= $80
LAYER_CLIPRECTS_LOST = $100
LMN_REGION	= -1

* struct LayerInfo
 rsreset
li_top_layer	rs.l 1
li_check_lp	rs.l 1
li_obs		rs.l 1
li_FreeClipRects rs.b mlh_SIZE
li_Lock 	rs.b ss_SIZE
li_gs_Head	rs.b lh_SIZE
li_long_reserved rs.l 1
li_Flags	rs.w 1
li_fatten_count rs.b 1
li_LockLayersCount rs.b 1
li_LayerInfo_extra_size rs.w 1
li_blitbuff	rs.l 1
li_LayerInfo_extra rs.l 1
li_SIZEOF	rs.w 0

NEWLAYERINFO_CALLED	= 1
ALERTLAYERSNOMEM	= $83010000

 endc
