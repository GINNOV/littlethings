 IFND GRAPHICS_GFXNODES_I
GRAPHICS_GFXNODES_I SET 1
*
*  graphics/gfxnodes.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

* struct ExtendedNode
 rsreset
xln_Succ	rs.l 1
xln_Pred	rs.l 1
xln_Type	rs.b 1
xln_Pri 	rs.b 1
xln_Name	rs.l 1
xln_Subsystem	rs.b 1
xln_Subtype	rs.b 1
xln_Library	rs.l 1
xln_Init	rs.l 1
xln_SIZE	rs.w 0

SS_GRAPHICS	= 2
VIEW_EXTRA_TYPE 	= 1
VIEWPORT_EXTRA_TYPE	= 2
SPECIAL_MONITOR_TYPE	= 3
MONITOR_SPEC_TYPE	= 4

 endc
