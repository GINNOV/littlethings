 IFND GRAPHICS_TEXT_I
GRAPHICS_TEXT_I SET 1
*
*  graphics/text.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc

 ifnd UTILITY_TAGITEM_I
 include "utility/tagitem.i"
 endc

FS_NORMAL = 0
 BITDEF FS,UNDERLINED,0
 BITDEF FS,BOLD,1
 BITDEF FS,ITALIC,2
 BITDEF FS,EXTENDED,3
 BITDEF FS,COLORFONT,6
 BITDEF FS,TAGGED,7

 BITDEF FP,ROMFONT,0
 BITDEF FP,DISKFONT,1
 BITDEF FP,REVPATH,2
 BITDEF FP,TALLDOT,3
 BITDEF FP,WIDEDOT,4
 BITDEF FP,PROPORTIONAL,5
 BITDEF FP,DESIGNED,6
 BITDEF FP,REMOVED,7

* struct TextAttr
 rsreset
ta_Name 	rs.l 1
ta_YSize	rs.w 1
ta_Style	rs.b 1
ta_Flags	rs.b 1
ta_SIZEOF	rs.w 0

* struct TTextAttr
 rsreset
tta_Name	rs.l 1
tta_YSize	rs.w 1
tta_Style	rs.b 1
tta_Flags	rs.b 1
tta_Tags	rs.l 1
tta_SIZEOF	rs.w 0

TA_DeviceDPI	= 1|TAG_USER
MAXFONTMATCHWEIGHT = 32767

* struct TextFont
 rsset mn_SIZE
tf_YSize	rs.w 1
tf_Style	rs.b 1
tf_Flags	rs.b 1
tf_XSize	rs.w 1
tf_Baseline	rs.w 1
tf_BoldSmear	rs.w 1
tf_Accessors	rs.w 1
tf_LoChar	rs.b 1
tf_HiChar	rs.b 1
tf_CharData	rs.l 1
tf_Modulo	rs.w 1
tf_CharLoc	rs.l 1
tf_CharSpace	rs.l 1
tf_CharKern	rs.l 1
tf_SIZEOF	rs.w 0
tf_Extension	= mn_ReplyPort

 BITDEF TE0,NOREMFONT,0

* struct TextFontExtension
 rsreset
tfe_MatchWord	rs.w 1
tfe_Flags0	rs.b 1
tfe_Flags1	rs.b 1
tfe_BackPtr	rs.l 1
tfe_OrigReplyPort rs.l 1
tfe_Tags	rs.l 1
tfe_OFontPatchS rs.l 1
tfe_OFontPatchK rs.l 1
tfe_SIZEOF	rs.w 0

CT_COLORFONT	= 1
CT_GREYFONT	= 2
CT_ANTIALIAS	= 4
 BITDEF CT,MAPCOLOR,0

* struct ColorFontColors
 rsreset
cfc_Reserved	rs.w 1
cfc_Count	rs.w 1
cfc_ColorTable	rs.l 1
cfc_SIZEOF	rs.w 0

* struct ColorTextFont
 rsset tf_SIZEOF
ctf_Flags	rs.w 1
ctf_Depth	rs.b 1
ctf_FgColor	rs.b 1
ctf_Low 	rs.b 1
ctf_High	rs.b 1
ctf_PlanePick	rs.b 1
ctf_PlaneOnOff	rs.b 1
ctf_ColorFontColors rs.l 1
ctf_CharData	rs.l 8
ctf_SIZEOF	rs.w 0

* struct TextExtent
 rsreset
te_Width	rs.w 1
te_Height	rs.w 1
te_Extent	rs.w 4
te_SIZEOF	rs.w 0

 endc
