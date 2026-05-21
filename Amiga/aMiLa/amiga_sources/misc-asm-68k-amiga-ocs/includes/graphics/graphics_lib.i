	IFND	GRAPHICS_LIB_I
GRAPHICS_LIB_I	set	1

* library offsets off _GfxBase

BltBitMap	equ	-30
BltTemplate	equ	-36
ClearEOL	equ	-42
ClearScreen	equ	-48
TextLength	equ	-54
Text	equ	-60
SetFont	equ	-66
OpenFont	equ	-72
CloseFont	equ	-78
AskSoftStyle	equ	-84
SetSoftStyle	equ	-90
AddBob	equ	-96
AddVSprite	equ	-102
DoCollision	equ	-108
DrawGList	equ	-114
InitGels	equ	-120
InitMasks	equ	-126
RemIBob	equ	-132
RemVSprite	equ	-138
SetCollision	equ	-144
SortGList	equ	-150
AddAnimOb	equ	-156
Animate	equ	-162
GetGBuffers	equ	-168
InitGMasks	equ	-174
LoadRGB4	equ	-192
InitRastPort	equ	-198
InitVPort	equ	-204
MrgCop	equ	-210
MakeVPort	equ	-216
LoadView	equ	-222
WaitBlit	equ	-228
SetRast	equ	-234
Move	equ	-240
Draw	equ	-246
AreaMove	equ	-252
AreaDraw	equ	-258
AreaEnd	equ	-264
WaitTOF	equ	-270
QBlit	equ	-276
InitArea	equ	-282
SetRGB4	equ	-288
QBSBlit	equ	-294
BltClear	equ	-300
RectFill	equ	-306
BltPattern	equ	-312
ReadPixel	equ	-318
WritePixel	equ	-324
Flood	equ	-330
PolyDraw	equ	-336
SetAPen	equ	-342
SetBPen	equ	-348
SetDrMd	equ	-354
InitView	equ	-360
CBump	equ	-366
CMove	equ	-372
CWait	equ	-378
VBeamPos	equ	-384
InitBitMap	equ	-390
ScrollRaster	equ	-396
WaitBOVP	equ	-402
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
AskFont	equ	-474
AddFont	equ	-480
RemFont	equ	-486
AllocRaster	equ	-492
FreeRaster	equ	-498
AndRectRegion	equ	-504
OrRectRegion	equ	-510
NewRegion	equ	-516
NotRegion	equ	-522
ClearRegion	equ	-528
DisposeRegion	equ	-534
FreeVPortCopLists	equ	-540
FreeCopList	equ	-546
ClipBlit	equ	-552
XorRectRegion	equ	-558
FreeCprList	equ	-564
GetColorMap	equ	-570
FreeColorMap	equ	-576
GetRGB4	equ	-582
ScrollVPort	equ	-588
UCopperListInit	equ	-594
FreeGBuffers	equ	-600
BltBitMapRastPort	equ	-606
* 1.2 new functions
OrRegionRegion	equ	-612
XorRegionRegion	equ	-618
AndRegionRegion	equ	-624
SetRGB4CM	equ	-630
BltMaskBitMapRastPort	equ	-636
GraphicsReserved1	equ	-642
GraphicsResirved2	equ	-648
AttemptLockLayerRom	equ	-654
AreaEllipse         equ     -186
DrawEllipse         equ     -180

* macro to call graphics library
CALLGRAF	macro
	move.l	_GfxBase,a6
	jsr	\1(a6)
	endm

* macro to define name for library
GRAFNAME	macro
	dc.b	'graphics.library',0
	even
	endm

* Makro für Musterdefinition von Linien

SetDrPt         macro
	move.w d0,$22(a1)
	move.w $20(a1),d0
	or.w #1,d0
	move.w d0,$20(a1)
	move.b #15,$1F(a1)
	endm

* Makro für Musterdefinition von Flächen

SetAfPt  	macro
	move.l d0,$08(a1)
	move.b d1,$1D(a1)
	endm

* Makro für Farbdefinitionen bei Füllungen

SetOPen		macro
	move.w d0,$1B(a1)
	move.w $20(a1),d0
	or.w #8,d0
	move.w d0,$20(a1)
	endm

	ENDC

