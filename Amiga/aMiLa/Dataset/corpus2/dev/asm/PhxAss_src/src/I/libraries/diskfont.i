 ifnd LIBRARIES_DISKFONT_I
LIBRARIES_DISKFONT_I set 1
*
*  libraries/diskfont.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc
 ifnd GRAPHICS_TEXT_I
 include "graphics/text.i"
 endc

MAXFONTPATH	= 256

* struct FontContents
 rsreset
fc_FileName	rs.b MAXFONTPATH
fc_YSize	rs.w 1
fc_Style	rs.b 1
fc_Flags	rs.b 1
fc_SIZEOF	rs

* struct TFontContents
 rsreset
tfc_FileName	rs.b MAXFONTPATH-2
tfc_TagCount	rs.w 1
tfc_YSize	rs.w 1
tfc_Style	rs.b 1
tfc_Flags	rs.b 1
tfc_SIZEOF	rs

FCH_ID		= $0f00
TFCH_ID 	= $0f02

* struct FontContentsHeader
 rsreset
fch_FileID	rs.w 1
fch_NumEntries	rs.w 1
fch_FC		rs

DFH_ID		= $0f80
MAXFONTNAME	= 32

* struct DiskFontHeader
 rsreset
dfh_DF		rs.b ln_SIZE
dfh_FileID	rs.w 1
dfh_Revision	rs.w 1
dfh_Segment	rs.l 1
dfh_Name	rs.b MAXFONTNAME
dfh_TF		rs.b tf_SIZEOF
dfh_SIZEOF	rs
dfh_TagList	= dfh_Segment

 BITDEF AF,MEMORY,0
 BITDEF AF,DISK,1
 BITDEF AF,SCALED,2
 BITDEF AF,TTATTR,16

* struct AvailFonts
 rsreset
af_Type 	rs.w 1
af_Attr 	rs.b ta_SIZEOF
af_SIZEOF	rs

* struct TAvailFonts
 rsreset
taf_Type	rs.w 1
taf_Attr	rs.b tta_SIZEOF
taf_SIZEOF	rs

* struct AvailFontsHeader
 rsreset
afh_NumEntries	rs.w 1
afh_AF		rs

 endc
