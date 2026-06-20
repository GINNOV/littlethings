 IFND LIBRARIES_LOCALE_I
LIBRARIES_LOCALE_I SET 1
**
**	libraries/locale.i
**	Release 2.1
**	for PhxAss
**

 IFND EXEC_TYPES_I
 INCLUDE "exec/types.i"
 ENDC
 IFND EXEC_NODES_I
 INCLUDE "exec/nodes.i"
 ENDC
 IFND EXEC_LISTS_I
 INCLUDE "exec/lists.i"
 ENDC
 IFND EXEC_LIBRARIES_I
 INCLUDE "exec/libraries.i"
 ENDC
 IFND UTILITY_TAGITEM_I
 INCLUDE "utility/tagitem.i"
 ENDC

; constants for GetLocaleStr()
DAY_1	equ 1
DAY_2	equ 2
DAY_3	equ 3
DAY_4	equ 4
DAY_5	equ 5
DAY_6	equ 6
DAY_7	equ 7
ABDAY_1 equ 8
ABDAY_2 equ 9
ABDAY_3 equ 10
ABDAY_4 equ 11
ABDAY_5 equ 12
ABDAY_6 equ 13
ABDAY_7 equ 14
MON_1	equ 15
MON_2	equ 16
MON_3	equ 17
MON_4	equ 18
MON_5	equ 19
MON_6	equ 20
MON_7	equ 21
MON_8	equ 22
MON_9	equ 23
MON_10	equ 24
MON_11	equ 25
MON_12	equ 26
ABMON_1 equ 27
ABMON_2 equ 28
ABMON_3 equ 29
ABMON_4 equ 30
ABMON_5 equ 31
ABMON_6 equ 32
ABMON_7 equ 33
ABMON_8 equ 34
ABMON_9 equ 35
ABMON_10 equ 36
ABMON_11 equ 37
ABMON_12 equ 38
YESSTR	equ 39
NOSTR	equ 40
AM_STR	equ 41
PM_STR	equ 42
SOFTHYPHEN equ 43
HARDHYPHEN equ 44
OPENQUOTE equ 45
CLOSEQUOTE equ 46
MAXSTRMSG equ 47

* struct LocaleBase
 rsset lib_SIZE
lb_SysPatches	rs

* struct Locale
 rsreset
loc_LocaleName		rs.l 1
loc_LanguageName	rs.l 1
loc_PrefLanguages	rs.l 10
loc_Flags		rs.l 1
loc_CodeSet		rs.l 1
loc_CountryCode 	rs.l 1
loc_TelephoneCode	rs.l 1
loc_GMTOffset		rs.l 1
loc_MeasuringSystem	rs.b 1
loc_CalendarType	rs.b 1
loc_Reserved0		rs.b 2
loc_DateTimeFormat	rs.l 1
loc_DateFormat		rs.l 1
loc_TimeFormat		rs.l 1
loc_ShortDateTimeFormat rs.l 1
loc_ShortDateFormat	rs.l 1
loc_ShortTimeFormat	rs.l 1
loc_DecimalPoint	rs.l 1
loc_GroupSeparator	rs.l 1
loc_FracGroupSeparator	rs.l 1
loc_Grouping		rs.l 1
loc_FracGrouping	rs.l 1
loc_MonDecimalPoint	rs.l 1
loc_MonGroupSeparator	rs.l 1
loc_MonFracGroupSeparator rs.l 1
loc_MonGrouping 	rs.l 1
loc_MonFracGrouping	rs.l 1
loc_MonFracDigits	rs.b 1
loc_MonIntFracDigits	rs.b 1
loc_Reserved1		rs.b 2
loc_MonCS		rs.l 1
loc_MonSmallCS		rs.l 1
loc_MonIntCS		rs.l 1
loc_MonPositiveSign	rs.l 1
loc_MonPositiveSpaceSep rs.b 1
loc_MonPositiveSignPos	rs.b 1
loc_MonPositiveCSPos	rs.b 1
loc_Reserved2		rs.b 1
loc_MonNegativeSign	rs.l 1
loc_MonNegativeSpaceSep rs.b 1
loc_MonNegativeSignPos	rs.b 1
loc_MonNegativeCSPos	rs.b 1
loc_Reserved3		rs.b 1
Locale_SIZEOF		rs

; constants for Locale.loc_MeasuringSystem
MS_ISO		equ 0
MS_AMERICAN	equ 1
MS_IMPERIAL	equ 2
MS_BRITISH	equ 3

; constants for Locale.loc_CalendarType */
CT_7SUN equ 0
CT_7MON equ 1
CT_7TUE equ 2
CT_7WED equ 3
CT_7THU equ 4
CT_7FRI equ 5
CT_7SAT equ 6

; constants for Locale.loc_MonPositiveSpaceSep and Locale.loc_MonNegativeSpaceSep
SS_NOSPACE	equ 0
SS_SPACE	equ 1

; constants for Locale.loc_MonPositiveSignPos and Locale.loc_MonNegativeSignPos
SP_PARENS	equ 0
SP_PREC_ALL	equ 1
SP_SUCC_ALL	equ 2
SP_PREC_CURR	equ 3
SP_SUCC_CURR	equ 4

; constants for Locale.loc_MonPositiveCSPos and Locale.loc_MonNegativeCSPos */
CSP_PRECEDES	equ 0
CSP_SUCCEEDS	equ 1

; Tags for OpenCatalog()
OC_TagBase	EQU TAG_USER+$90000
OC_BuiltInLanguage EQU OC_TagBase+1
OC_BuiltInCodeSet EQU OC_TagBase+2
OC_Version	EQU OC_TagBase+3
OC_Language	EQU OC_TagBase+4

; Comparison types for StrnCmp()
SC_ASCII	EQU 0
SC_COLLATE1	EQU 1
SC_COLLATE2	EQU 2

; This structure must only be allocated by locale.library and is READ-ONLY!
* struct Catalog
 rsset ln_SIZE
cat_Pad 	rs.w 1
cat_Language	rs.l 1
cat_CodeSet	rs.l 1
cat_Version	rs.w 1
cat_Revision	rs.w 1
Catalog_SIZEOF	rs

 ENDC
