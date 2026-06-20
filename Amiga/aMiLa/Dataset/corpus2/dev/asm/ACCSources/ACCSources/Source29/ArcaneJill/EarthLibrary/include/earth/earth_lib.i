	IFND	EARTH_EARTH_LIB_I
EARTH_EARTH_LIB_I	SET	1

; "earth.library"

_LVOUnique	equ	-30
_LVORandom	equ	-36
_LVORandomRange	equ	-42
_LVORandomFromSeed	equ	-48
_LVOCyclicRedundancyCheck	equ	-54
_LVO_StrLen	equ	-60
_LVO_StrCmp	equ	-66
_LVO_StrNCmp	equ	-72
_LVO_StrICmp	equ	-78
_LVO_StrNICmp	equ	-84
_LVO_StrCpy	equ	-90
_LVO_StrNCpy	equ	-96
_LVO_StrCat	equ	-102
_LVO_StrNCat	equ	-108
_LVO_StrMove	equ	-114
_LVO_StrMoveUpper	equ	-120
_LVOForEachArgument	equ	-126
_LVOForEachWildCard	equ	-132
_LVOInitTree	equ	-138
_LVOFindTreeNode	equ	-144
_LVOAddTreeNode	equ	-150
_LVOAddTreeNodeAll	equ	-156
_LVORemoveTreeNode	equ	-162
_LVORemoveTreeNodeAll	equ	-168
_LVOTreeNodeParent	equ	-174
_LVOTreeNodeSuccessor	equ	-180
_LVOTreeNodePredecessor	equ	-186
_LVOSortTree	equ	-192
_LVOBalanceTree	equ	-198
_LVOForEachTreeNode	equ	-204
_LVOInitLibraryHook	equ	-210
_LVONodeNameCmp	equ	-216
_LVONodeNameICmp	equ	-222
_LVONodeValueCmp	equ	-228
_LVOInsertNode	equ	-234
_LVOJoinLists	equ	-240
_LVO_StrChr	equ	-246
_LVO_StrStr	equ	-252
_LVO_StrMatch	equ	-258
_LVOEarthLibraryPrivate1	equ	-264
_LVO_VPrintF	equ	-270
_LVO_VFPrintF	equ	-276
_LVO_VSPrintF	equ	-282
_LVO_VSNPrintF	equ	-288
_LVOVHookPrintF	equ	-294
_LVOEarthLibraryPrivate2	equ	-300
_LVORawPrintF	equ	-306
_LVO_PutChar	equ	-312
_LVO_FPutC	equ	-318
_LVO_PutS	equ	-324
_LVO_FPutS	equ	-330
_LVO_VScanF	equ	-336
_LVO_VFScanF	equ	-342
_LVO_VSScanF	equ	-348
_LVOVHookScanF	equ	-354
_LVOEarthLibraryPrivate3	equ	-360
_LVORawScanF	equ	-366
_LVO_GetChar	equ	-372
_LVO_FGetC	equ	-378
_LVO_GetS	equ	-384
_LVO_FGetS	equ	-390
_LVO_GetSN	equ	-396
_LVO_FGetSN	equ	-402
;
; Alternative names for some functions.
;
_LVO_PrintF	equ	_LVO_VPrintF
_LVO_FPrintF	equ	_LVO_VFPrintF
_LVO_SPrintF	equ	_LVO_VSPrintF
_LVO_SNPrintF	equ	_LVO_VSNPrintF
_LVOHookPrintF	equ	_LVOVHookPrintF
_LVO_ScanF	equ	_LVO_VScanF
_LVO_FScanF	equ	_LVO_VFScanF
_LVO_SScanF	equ	_LVO_VSScanF
_LVOHookScanF	equ	_LVOVHookScanF



	ENDC
