 IFND GRAPHICS_GFX_I
GRAPHICS_GFX_I SET 1
*
*  graphics/gfx.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

BITSET	 = $8000
BITCLR	 = 0
AGNUS	 = 1
DENISE	 = 1

* struct BitMap
 rsreset
bm_BytesPerRow	rs.w 1
bm_Rows 	rs.w 1
bm_Flags	rs.b 1
bm_Depth	rs.b 1
bm_Pad		rs.w 1
bm_Planes	rs.l 8
bm_SIZEOF	rs.w 0

* struct Rectangle
 rsreset
ra_MinX 	rs.w 1
ra_MinY 	rs.w 1
ra_MaxX 	rs.w 1
ra_MaxY 	rs.w 1
ra_SIZEOF	rs.w 0

* struct Rect32
 rsreset
r32_MinX	 rs.l 1
r32_MinY	 rs.l 1
r32_MaxX	 rs.l 1
r32_MaxY	 rs.l 1
r32_SIZEOF	 rs.w 0

* struct tPoint
 rsreset
tpt_x		rs.w 1
tpt_y		rs.w 1
tpt_SIZEOF	rs.w 0

 endc
