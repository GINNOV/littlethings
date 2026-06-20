	IFND	EARTH_EARTHREXX_LIB_I
EARTH_EARTHREXX_LIB_I	set	1

;==================================================================
;	Offsets
;==================================================================

_LVOEarthRexxReserved1	equ	-30
_LVOEarthRexxReserved2	equ	-36

_LVOOpenRexxPort	equ	-42
_LVOProcessRexx 	equ	-48
_LVODispatchRexx	equ	-54
_LVOSetResults		equ	-60
_LVOInterfaceRexx	equ	-66
_LVOFreeRexxMsg 	equ	-72
_LVOASyncRexx		equ	-78
_LVOSyncRexx		equ	-84
_LVOCallRexx		equ	-90
_LVOSendRexx		equ	-96
_LVOCloseRexxPort	equ	-102

_LVOActivatePort	equ	-108
_LVOShakePort		equ	-114
_LVODeactivatePort	equ	-120

_LVOASAbbrev		equ	-126
_LVOASAddLib		equ	-132
_LVOASCentre		equ	-138
_LVOASCenter		equ	_LVOASCentre
_LVOASCompress		equ	-144
_LVOASCompare		equ	-150
_LVOASCopies		equ	-156
_LVOASDelStr		equ	-162
_LVOASDelWord		equ	-168
_LVOASErrorText 	equ	-174
_LVOASGetClip		equ	-180
_LVOASInsert		equ	-186
_LVOASLastPos		equ	-192
_LVOASLeft		equ	-198
_LVOASOverlay		equ	-204
_LVOASPos		equ	-210
_LVOASRemLib		equ	-216
_LVOASReverse		equ	-222
_LVOASRight		equ	-228
_LVOASSetClip		equ	-234
_LVOASSpace		equ	-240
_LVOASStrip		equ	-246
_LVOASSubStr		equ	-252
_LVOASSubWord		equ	-258
_LVOASTranslate 	equ	-264
_LVOASTrim		equ	-270
_LVOASUpper		equ	-276
_LVOASVerify		equ	-282
_LVOASWord		equ	-288
_LVOASWordIndex 	equ	-294
_LVOASWordLength	equ	-300
_LVOASWords		equ	-306
_LVOASXRange		equ	-312

_LVONewCreateArgstring	equ	-318
_LVOASCopy		equ	-324
_LVOASPrintf		equ	-330
_LVOASLower		equ	-336
_LVOASPad		equ	-342
_LVOASJoin		equ	-348
_LVOASPadJoin		equ	-354
_LVOASPadLeft		equ	-360
_LVOASPadRight		equ	-366
_LVOASTLeft		equ	-372
_LVOASTRight		equ	-378
_LVOASUnique		equ	-384
_LVOASEmpty		equ	-390

_LVOCreateRexxRsrcList	equ	-396
_LVODeleteRexxRsrcList	equ	-402
_LVOWaitForPort 	equ	-408

_LVOCreateMemoPad	equ	-414
_LVODeleteMemoPad	equ	-420
_LVOExistsMemo		equ	-426
_LVOFindMemo		equ	-432
_LVOAddMemo		equ	-438

;==================================================================
;	Macros
;==================================================================

CALLERX MACRO	;function
	move.l	_EarthRexxBase,a6
	jsr	_LVO\1(a6)
	ENDM

;==================================================================

	ENDC

