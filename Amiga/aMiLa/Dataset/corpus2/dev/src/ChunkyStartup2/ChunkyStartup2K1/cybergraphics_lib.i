; made by krabob BECAUSE wasn't found in common devpack !
; cybergraphics_lib.i

_LVOcgfxPrivate1		equ		-30
_LVOcgfxPrivate2		equ		-36	
_LVOcgfxPrivate3		equ		-42
_LVOcgfxPrivate4		equ		-48
_LVOIsCyberModeID		equ		-54
_LVOBestCModeIDTagList		equ		-60
_LVOCModeRequestTagList		equ		-66
_LVOAllocCModeListTagList	equ		-72
_LVOFreeCModeList		equ		-78
_LVOcgfxPrivate5		equ		-84
_LVOScalePixelArray		equ		-90
_LVOGetCyberMapAttr		equ		-96
_LVOGetCyberIDAttr		equ		-102
_LVOReadRGBPixel		equ		-108
_LVOWriteRGBPixel		equ		-114
_LVOReadPixelArray		equ		-120
_LVOWritePixelArray		equ		-126
_LVOMovePixelArray		equ		-132
_LVOcgfxPrivate6		equ		-138
_LVOInvertPixelArray		equ		-144
_LVOFillPixelArray		equ		-150
_LVODoCDrawMethodTagList	equ		-156
_LVOCVideoCtrlTagList		equ		-162
_LVOLockBitMapTagList		equ		-168
_LVOUnLockBitMap		equ		-174
_LVOUnLockBitMapTagList		equ		-180
_LVOExtractColor		equ		-186
_LVOcgfxPrivate7		equ		-192
_LVOWriteLUTPixelArray		equ		-198


CGXNAME	MACRO
	DC.B 'cybergraphics.library',0
	even
	ENDM
