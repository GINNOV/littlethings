
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


* Custom Bitmap structure


		rsreset
bm_BytesPerRow	rs.w	1
bm_Rows		rs.w	1
bm_Flags		rs.b	1
bm_Depth		rs.b	1
bm_Pad		rs.w	1
bm_Planes	rs.b	8*4
bm_sizeof	rs.w	0


* Colormap structure


		rsreset
cm_Flags		rs.b	1
cm_Type		rs.b	1
cm_Count		rs.w	1
cm_ColorTable	rs.l	1
cm_sizeof	rs.w	0


		rsreset
cp_collPtrs	rs.l	1
cp_sizeof	rs.w	0


* TmpRas structure


		rsreset
tr_RasPtr	rs.l	1
tr_Size		rs.l	1
tr_sizeof	rs.w	0


* Text font handling information


* Flags for TextAttr


FS_NORMAL	equ	0
FSB_EXTENDED	equ	3
FSB_ITALIC	equ	2
FSB_BOLD		equ	1
FSB_UNDERLINED	equ	0

FSF_EXTENDED	equ	$08
FSF_ITALIC	equ	$04
FSF_BOLD		equ	$02
FSF_UNDERLINED	equ	$01


* Flags for TextFont


FPB_ROMFONT	equ	0
FPB_DISKFONT	equ	1
FPB_REVPATH	equ	2
FPB_TALLDOT	equ	3
FPB_WIDEDOT	equ	4
FPB_PROPORTIONAL	equ	5
FPB_DESIGNED	equ	6
FPB_REMOVED	equ	7


FPF_ROMFONT	equ	$01
FPF_DISKFONT	equ	$02
FPF_REVPATH	equ	$04
FPF_TALLDOT	equ	$08
FPF_WIDEDOT	equ	$10
FPF_PROPORTIONAL	equ	$20
FPF_DESIGNED	equ	$40
FPF_REMOVED	equ	$80


* TextAttr structure


		rsreset
ta_Name		rs.l	1
ta_YSize		rs.w	1
ta_Style		rs.b	1
ta_Flags		rs.b	1
ta_sizeof	rs.w	0


* TextFont structure


		rsreset
tf_MsgNode	rs.b	mn_sizeof
tf_YSize		rs.w	1
tf_Style		rs.b	1
tf_Flags		rs.b	1
tf_XSize		rs.w	1
tf_Baseline	rs.w	1
tf_BoldSmear	rs.w	1
tf_Accessors	rs.w	1
tf_LoChar	rs.b	1
tf_HiChar	rs.b	1
tf_CharData	rs.l	1
tf_Modulo	rs.w	1
tf_CharLoc	rs.l	1
tf_CharSpace	rs.l	1
tf_CharKern	rs.l	1
tf_sizeof	rs.w	0


* This is my macro for calling a GRAPHICS.LIBRARY function


CALLGRAF		macro	name	;call a GRAPHICS.LIBRARY function

		move.l	a6,-(sp)
		move.l	graf_base(a6),a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm



