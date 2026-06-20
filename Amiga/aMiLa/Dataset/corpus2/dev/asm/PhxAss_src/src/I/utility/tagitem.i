 ifnd UTILITY_TAGITEM_I
UTILITY_TAGITEM_I set 1
*
*  utility/tagitem.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 rsreset
ti_Tag		rs.l 1
ti_Data 	rs.l 1
ti_SIZEOF	rs.w 0

TAG_END 	= 0
TAG_DONE	= 0
TAG_IGNORE	= 1
TAG_MORE	= 2
TAG_SKIP	= 3
TAG_USER	= $80000000
TAGFILTER_AND	= 0
TAGFILTER_NOT	= 1

 ENDC ; UTILITY_TAGITEM_I
