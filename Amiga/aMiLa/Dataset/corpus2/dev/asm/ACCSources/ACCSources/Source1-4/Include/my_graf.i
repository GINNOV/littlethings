
* This is my graphics library standard header file.
* Another Genam ripoff mutated to fit in with my
* whims and fancies.

* Graphics.Library offsets

BltBitMap	equ	-30
BltTemplate	equ	-36
ClearEOL		equ	-42
ClearScreen	equ	-48
TextLength	equ	-54
Text		equ	-60
SetFont		equ	-66
OpenFont		equ	-72
CloseFont	equ	-78
AskSoftStyle	equ	-84
SetSoftStyle	equ	-90
AddBob		equ	-96
AddVSprite	equ	-102
DoCollision	equ	-108
DrawGList	equ	-114
InitGels		equ	-120
InitMasks	equ	-126
RemIBob		equ	-132
RemVSprite	equ	-138
SetCollision	equ	-144
SortGList	equ	-150
AddAnimObj	equ	-156
Animate		equ	-162
GetGBuffers	equ	-168
InitGMasks	equ	-174
GelsFuncE	equ	-180
GelsFuncF	equ	-186
LoadRGB4		equ	-192
InitRastPort	equ	-198
InitVPort	equ	-204
MrgCop		equ	-210
MakeVPort	equ	-216
LoadView		equ	-222
WaitBlit		equ	-228
SetRast		equ	-234
Move		equ	-240
Draw		equ	-246
AreaMove		equ	-252
AreaDraw		equ	-258
AreaEnd		equ	-264
WaitTOF		equ	-270
QBlit		equ	-276
InitArea		equ	-282
SetRGB4		equ	-288
QBSBlit		equ	-294
BltClear		equ	-300
RectFill		equ	-306
BltPattern	equ	-312
ReadPixel	equ	-318
WritePixel	equ	-324
Flood		equ	-330
PolyDraw		equ	-336
SetAPen		equ	-342
SetBPen		equ	-348
SetDrMd		equ	-354
InitView		equ	-360
CBump		equ	-366
Cmove		equ	-372
CWait		equ	-378
VBeamPos		equ	-384
InitBitMap	equ	-390
ScrollRaster	equ	-396
WaitBOVP		equ	-402
GetSprite	equ	-408
FreeSprite	equ	-414
ChangeSprite	equ	-420
MoveSprite	equ	-426
LockLayerRom	equ	-432
UnlockLayerRom	equ	-438
SyncSBitMap	equ	-444
CopySBitMap	equ	-450
OwnBlitter	equ	-456
DisownBlitter	equ	-462
InitTmpRas	equ	-468
AskFont		equ	-474
AddFont		equ	-480
RemFont		equ	-486
AllocRaster	equ	-492
FreeRaster	equ	-498
AndRectRegion	equ	-504
OrRectRegion	equ	-510
NewRectRegion	equ	-516

* graphics.library reserved at -522

ClearRegion	equ	-528
DisposeRegion	equ	-534
FreeVPortCopLists	equ	-540
FreeCopList	equ	-546
ClipBlit		equ	-552
XorRectRegion	equ	-558
FreeCprList	equ	-564
GetColorMap	equ	-570
FreeColorMap	equ	-576
GetRGB4		equ	-582
ScrollVPort	equ	-588
UCoperListInit	equ	-594
FreeGBuffers	equ	-600
BltBitMapRastPort	equ	-606


* custom bitmap structure


		rsreset
bm_BytesPerRow	rs.w	1
bm_Rows		rs.w	1
bm_Flags		rs.b	1
bm_Depth		rs.b	1
bm_Pad		rs.w	1
bm_Planes	rs.b	8*4
bm_sizeof	rs.w	0


* TmpRas structure


		rsreset
tr_RasPtr	rs.l	1
tr_Size		rs.l	1
tr_sizeof	rs.w	0


* RastPort structure. This is huge. It's also complicated.
* It also changes for non-1.2 AmigaDosses!! I'm going to
* stick to 1.2 AmigaDos rastport definition here.


		rsreset
rp_Layer		rs.l	1
rp_Bitmap	rs.l	1
rp_AreaPtrn	rs.l	1
rp_TmpRas	rs.l	1
rp_AreaInfo	rs.l	1
rp_GelsInfo	rs.l	1
rp_Mask		rs.b	1
rp_FgPen		rs.b	1
rp_BgPen		rs.b	1
rp_AOLPen	rs.b	1
rp_DrawMode	rs.b	1
rp_AreaPtSz	rs.b	1
rp_dummy		rs.b	1
rp_LinePatCnt	rs.b	1
rp_Flags		rs.w	1
rp_LinePtrn	rs.w	1
rp_cp_x		rs.w	1
rp_cp_y		rs.w	1
rp_Minterms	rs.b	8
rp_PenWidth	rs.w	1
rp_PenHeight	rs.w	1
rp_Font		rs.l	1
rp_AlgoStyle	rs.b	1
rp_TxFlags	rs.b	1
rp_TxHeight	rs.w	1
rp_TxWidth	rs.w	1
rp_TxBaseLine	rs.w	1
rp_TxSpacing	rs.w	1
rp_RP_User	rs.l	1

;	rp_wordreserved	rs.b	14	;NOT 1.2 !!!

rp_longreserved	rs.b	8
rp_reserved	rs.b	8

rp_sizeof	rs.w	0


* This is my macro for calling a GRAPHICS.LIBRARY function


CALLGRAF		macro	name	;call a GRAPHICS.LIBRARY function

		move.l	a6,-(sp)
		move.l	graf_base(a6),a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm



