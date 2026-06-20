#ifndef _VBCCINLINE_GRAPHICS_H
#define _VBCCINLINE_GRAPHICS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __BltBitMap(void *, CONST struct BitMap * srcBitMap, LONG xSrc, LONG ySrc, struct BitMap * destBitMap, LONG xDest, LONG yDest, LONG xSize, LONG ySize, ULONG minterm, ULONG mask, PLANEPTR tempA) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,28(2)\n"
	"\tlwz\t11,20(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define BltBitMap(srcBitMap, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA) __BltBitMap(GfxBase, (srcBitMap), (xSrc), (ySrc), (destBitMap), (xDest), (yDest), (xSize), (ySize), (minterm), (mask), (tempA))

VOID __BltTemplate(void *, CONST PLANEPTR source, LONG xSrc, LONG srcMod, struct RastPort * destRP, LONG xDest, LONG yDest, LONG xSize, LONG ySize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define BltTemplate(source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize) __BltTemplate(GfxBase, (source), (xSrc), (srcMod), (destRP), (xDest), (yDest), (xSize), (ySize))

VOID __ClearEOL(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ClearEOL(rp) __ClearEOL(GfxBase, (rp))

VOID __ClearScreen(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define ClearScreen(rp) __ClearScreen(GfxBase, (rp))

WORD __TextLength(void *, struct RastPort * rp, CONST_STRPTR string, ULONG count) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define TextLength(rp, string, count) __TextLength(GfxBase, (rp), (string), (count))

LONG __Text(void *, struct RastPort * rp, CONST_STRPTR string, ULONG count) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define Text(rp, string, count) __Text(GfxBase, (rp), (string), (count))

LONG __SetFont(void *, struct RastPort * rp, CONST struct TextFont * textFont) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SetFont(rp, textFont) __SetFont(GfxBase, (rp), (textFont))

struct TextFont * __OpenFont(void *, struct TextAttr * textAttr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define OpenFont(textAttr) __OpenFont(GfxBase, (textAttr))

VOID __CloseFont(void *, struct TextFont * textFont) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define CloseFont(textFont) __CloseFont(GfxBase, (textFont))

ULONG __AskSoftStyle(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define AskSoftStyle(rp) __AskSoftStyle(GfxBase, (rp))

ULONG __SetSoftStyle(void *, struct RastPort * rp, ULONG style, ULONG enable) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define SetSoftStyle(rp, style, enable) __SetSoftStyle(GfxBase, (rp), (style), (enable))

VOID __AddBob(void *, struct Bob * bob, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AddBob(bob, rp) __AddBob(GfxBase, (bob), (rp))

VOID __AddVSprite(void *, struct VSprite * vSprite, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define AddVSprite(vSprite, rp) __AddVSprite(GfxBase, (vSprite), (rp))

VOID __DoCollision(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define DoCollision(rp) __DoCollision(GfxBase, (rp))

VOID __DrawGList(void *, struct RastPort * rp, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define DrawGList(rp, vp) __DrawGList(GfxBase, (rp), (vp))

VOID __InitGels(void *, struct VSprite * head, struct VSprite * tail, struct GelsInfo * gelsInfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define InitGels(head, tail, gelsInfo) __InitGels(GfxBase, (head), (tail), (gelsInfo))

VOID __InitMasks(void *, struct VSprite * vSprite) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define InitMasks(vSprite) __InitMasks(GfxBase, (vSprite))

VOID __RemIBob(void *, struct Bob * bob, struct RastPort * rp, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define RemIBob(bob, rp, vp) __RemIBob(GfxBase, (bob), (rp), (vp))

VOID __RemVSprite(void *, struct VSprite * vSprite) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define RemVSprite(vSprite) __RemVSprite(GfxBase, (vSprite))

VOID __SortGList(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define SortGList(rp) __SortGList(GfxBase, (rp))

VOID __AddAnimOb(void *, struct AnimOb * anOb, struct AnimOb ** anKey, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define AddAnimOb(anOb, anKey, rp) __AddAnimOb(GfxBase, (anOb), (anKey), (rp))

VOID __Animate(void *, struct AnimOb ** anKey, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define Animate(anKey, rp) __Animate(GfxBase, (anKey), (rp))

BOOL __GetGBuffers(void *, struct AnimOb * anOb, struct RastPort * rp, LONG flag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define GetGBuffers(anOb, rp, flag) __GetGBuffers(GfxBase, (anOb), (rp), (flag))

VOID __InitGMasks(void *, struct AnimOb * anOb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define InitGMasks(anOb) __InitGMasks(GfxBase, (anOb))

VOID __DrawEllipse(void *, struct RastPort * rp, LONG xCenter, LONG yCenter, LONG a, LONG b) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define DrawEllipse(rp, xCenter, yCenter, a, b) __DrawEllipse(GfxBase, (rp), (xCenter), (yCenter), (a), (b))

LONG __AreaEllipse(void *, struct RastPort * rp, LONG xCenter, LONG yCenter, LONG a, LONG b) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define AreaEllipse(rp, xCenter, yCenter, a, b) __AreaEllipse(GfxBase, (rp), (xCenter), (yCenter), (a), (b))

VOID __LoadRGB4(void *, struct ViewPort * vp, CONST UWORD * colors, LONG count) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define LoadRGB4(vp, colors, count) __LoadRGB4(GfxBase, (vp), (colors), (count))

VOID __InitRastPort(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define InitRastPort(rp) __InitRastPort(GfxBase, (rp))

VOID __InitVPort(void *, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define InitVPort(vp) __InitVPort(GfxBase, (vp))

ULONG __MrgCop(void *, struct View * view) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define MrgCop(view) __MrgCop(GfxBase, (view))

ULONG __MakeVPort(void *, struct View * view, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define MakeVPort(view, vp) __MakeVPort(GfxBase, (view), (vp))

VOID __LoadView(void *, struct View * view) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define LoadView(view) __LoadView(GfxBase, (view))

VOID __WaitBlit(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define WaitBlit() __WaitBlit(GfxBase)

VOID __SetRast(void *, struct RastPort * rp, ULONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define SetRast(rp, pen) __SetRast(GfxBase, (rp), (pen))

VOID __Move(void *, struct RastPort * rp, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define Move(rp, x, y) __Move(GfxBase, (rp), (x), (y))

VOID __Draw(void *, struct RastPort * rp, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define Draw(rp, x, y) __Draw(GfxBase, (rp), (x), (y))

LONG __AreaMove(void *, struct RastPort * rp, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define AreaMove(rp, x, y) __AreaMove(GfxBase, (rp), (x), (y))

LONG __AreaDraw(void *, struct RastPort * rp, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define AreaDraw(rp, x, y) __AreaDraw(GfxBase, (rp), (x), (y))

LONG __AreaEnd(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define AreaEnd(rp) __AreaEnd(GfxBase, (rp))

VOID __WaitTOF(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define WaitTOF() __WaitTOF(GfxBase)

VOID __QBlit(void *, struct bltnode * blit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define QBlit(blit) __QBlit(GfxBase, (blit))

VOID __InitArea(void *, struct AreaInfo * areaInfo, APTR vectorBuffer, LONG maxVectors) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define InitArea(areaInfo, vectorBuffer, maxVectors) __InitArea(GfxBase, (areaInfo), (vectorBuffer), (maxVectors))

VOID __SetRGB4(void *, struct ViewPort * vp, LONG index, ULONG red, ULONG green, ULONG blue) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define SetRGB4(vp, index, red, green, blue) __SetRGB4(GfxBase, (vp), (index), (red), (green), (blue))

VOID __QBSBlit(void *, struct bltnode * blit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define QBSBlit(blit) __QBSBlit(GfxBase, (blit))

VOID __BltClear(void *, PLANEPTR memBlock, ULONG byteCount, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define BltClear(memBlock, byteCount, flags) __BltClear(GfxBase, (memBlock), (byteCount), (flags))

VOID __RectFill(void *, struct RastPort * rp, LONG xMin, LONG yMin, LONG xMax, LONG yMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define RectFill(rp, xMin, yMin, xMax, yMax) __RectFill(GfxBase, (rp), (xMin), (yMin), (xMax), (yMax))

VOID __BltPattern(void *, struct RastPort * rp, CONST PLANEPTR mask, LONG xMin, LONG yMin, LONG xMax, LONG yMax, ULONG maskBPR) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define BltPattern(rp, mask, xMin, yMin, xMax, yMax, maskBPR) __BltPattern(GfxBase, (rp), (mask), (xMin), (yMin), (xMax), (yMax), (maskBPR))

ULONG __ReadPixel(void *, struct RastPort * rp, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define ReadPixel(rp, x, y) __ReadPixel(GfxBase, (rp), (x), (y))

LONG __WritePixel(void *, struct RastPort * rp, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define WritePixel(rp, x, y) __WritePixel(GfxBase, (rp), (x), (y))

BOOL __Flood(void *, struct RastPort * rp, ULONG mode, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,8(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-330\n"
	"\tbctrl";
#define Flood(rp, mode, x, y) __Flood(GfxBase, (rp), (mode), (x), (y))

VOID __PolyDraw(void *, struct RastPort * rp, LONG count, CONST WORD * polyTable) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-336\n"
	"\tbctrl";
#define PolyDraw(rp, count, polyTable) __PolyDraw(GfxBase, (rp), (count), (polyTable))

VOID __SetAPen(void *, struct RastPort * rp, ULONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-342\n"
	"\tbctrl";
#define SetAPen(rp, pen) __SetAPen(GfxBase, (rp), (pen))

VOID __SetBPen(void *, struct RastPort * rp, ULONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define SetBPen(rp, pen) __SetBPen(GfxBase, (rp), (pen))

VOID __SetDrMd(void *, struct RastPort * rp, ULONG drawMode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define SetDrMd(rp, drawMode) __SetDrMd(GfxBase, (rp), (drawMode))

VOID __InitView(void *, struct View * view) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-360\n"
	"\tbctrl";
#define InitView(view) __InitView(GfxBase, (view))

VOID __CBump(void *, struct UCopList * copList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-366\n"
	"\tbctrl";
#define CBump(copList) __CBump(GfxBase, (copList))

VOID __CMove(void *, struct UCopList * copList, APTR destination, LONG data) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-372\n"
	"\tbctrl";
#define CMove(copList, destination, data) __CMove(GfxBase, (copList), (destination), (data))

VOID __CWait(void *, struct UCopList * copList, LONG v, LONG h) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-378\n"
	"\tbctrl";
#define CWait(copList, v, h) __CWait(GfxBase, (copList), (v), (h))

LONG __VBeamPos(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-384\n"
	"\tbctrl";
#define VBeamPos() __VBeamPos(GfxBase)

VOID __InitBitMap(void *, struct BitMap * bitMap, LONG depth, LONG width, LONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-390\n"
	"\tbctrl";
#define InitBitMap(bitMap, depth, width, height) __InitBitMap(GfxBase, (bitMap), (depth), (width), (height))

VOID __ScrollRaster(void *, struct RastPort * rp, LONG dx, LONG dy, LONG xMin, LONG yMin, LONG xMax, LONG yMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,20(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define ScrollRaster(rp, dx, dy, xMin, yMin, xMax, yMax) __ScrollRaster(GfxBase, (rp), (dx), (dy), (xMin), (yMin), (xMax), (yMax))

VOID __WaitBOVP(void *, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-402\n"
	"\tbctrl";
#define WaitBOVP(vp) __WaitBOVP(GfxBase, (vp))

WORD __GetSprite(void *, struct SimpleSprite * sprite, LONG num) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define GetSprite(sprite, num) __GetSprite(GfxBase, (sprite), (num))

VOID __FreeSprite(void *, LONG num) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-414\n"
	"\tbctrl";
#define FreeSprite(num) __FreeSprite(GfxBase, (num))

VOID __ChangeSprite(void *, struct ViewPort * vp, struct SimpleSprite * sprite, UWORD * newData) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-420\n"
	"\tbctrl";
#define ChangeSprite(vp, sprite, newData) __ChangeSprite(GfxBase, (vp), (sprite), (newData))

VOID __MoveSprite(void *, struct ViewPort * vp, struct SimpleSprite * sprite, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-426\n"
	"\tbctrl";
#define MoveSprite(vp, sprite, x, y) __MoveSprite(GfxBase, (vp), (sprite), (x), (y))

VOID __LockLayerRom(void *, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,52(2)\n"
	"\tli\t3,-432\n"
	"\tbctrl";
#define LockLayerRom(layer) __LockLayerRom(GfxBase, (layer))

VOID __UnlockLayerRom(void *, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,52(2)\n"
	"\tli\t3,-438\n"
	"\tbctrl";
#define UnlockLayerRom(layer) __UnlockLayerRom(GfxBase, (layer))

VOID __SyncSBitMap(void *, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-444\n"
	"\tbctrl";
#define SyncSBitMap(layer) __SyncSBitMap(GfxBase, (layer))

VOID __CopySBitMap(void *, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-450\n"
	"\tbctrl";
#define CopySBitMap(layer) __CopySBitMap(GfxBase, (layer))

VOID __OwnBlitter(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-456\n"
	"\tbctrl";
#define OwnBlitter() __OwnBlitter(GfxBase)

VOID __DisownBlitter(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-462\n"
	"\tbctrl";
#define DisownBlitter() __DisownBlitter(GfxBase)

struct TmpRas * __InitTmpRas(void *, struct TmpRas * tmpRas, PLANEPTR buffer, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-468\n"
	"\tbctrl";
#define InitTmpRas(tmpRas, buffer, size) __InitTmpRas(GfxBase, (tmpRas), (buffer), (size))

VOID __AskFont(void *, struct RastPort * rp, struct TextAttr * textAttr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-474\n"
	"\tbctrl";
#define AskFont(rp, textAttr) __AskFont(GfxBase, (rp), (textAttr))

VOID __AddFont(void *, struct TextFont * textFont) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-480\n"
	"\tbctrl";
#define AddFont(textFont) __AddFont(GfxBase, (textFont))

VOID __RemFont(void *, struct TextFont * textFont) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-486\n"
	"\tbctrl";
#define RemFont(textFont) __RemFont(GfxBase, (textFont))

PLANEPTR __AllocRaster(void *, ULONG width, ULONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-492\n"
	"\tbctrl";
#define AllocRaster(width, height) __AllocRaster(GfxBase, (width), (height))

VOID __FreeRaster(void *, PLANEPTR p, ULONG width, ULONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-498\n"
	"\tbctrl";
#define FreeRaster(p, width, height) __FreeRaster(GfxBase, (p), (width), (height))

VOID __AndRectRegion(void *, struct Region * region, CONST struct Rectangle * rectangle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-504\n"
	"\tbctrl";
#define AndRectRegion(region, rectangle) __AndRectRegion(GfxBase, (region), (rectangle))

BOOL __OrRectRegion(void *, struct Region * region, CONST struct Rectangle * rectangle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-510\n"
	"\tbctrl";
#define OrRectRegion(region, rectangle) __OrRectRegion(GfxBase, (region), (rectangle))

struct Region * __NewRegion(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-516\n"
	"\tbctrl";
#define NewRegion() __NewRegion(GfxBase)

BOOL __ClearRectRegion(void *, struct Region * region, CONST struct Rectangle * rectangle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-522\n"
	"\tbctrl";
#define ClearRectRegion(region, rectangle) __ClearRectRegion(GfxBase, (region), (rectangle))

VOID __ClearRegion(void *, struct Region * region) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-528\n"
	"\tbctrl";
#define ClearRegion(region) __ClearRegion(GfxBase, (region))

VOID __DisposeRegion(void *, struct Region * region) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-534\n"
	"\tbctrl";
#define DisposeRegion(region) __DisposeRegion(GfxBase, (region))

VOID __FreeVPortCopLists(void *, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-540\n"
	"\tbctrl";
#define FreeVPortCopLists(vp) __FreeVPortCopLists(GfxBase, (vp))

VOID __FreeCopList(void *, struct CopList * copList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-546\n"
	"\tbctrl";
#define FreeCopList(copList) __FreeCopList(GfxBase, (copList))

VOID __ClipBlit(void *, struct RastPort * srcRP, LONG xSrc, LONG ySrc, struct RastPort * destRP, LONG xDest, LONG yDest, LONG xSize, LONG ySize, ULONG minterm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tli\t3,-552\n"
	"\tbctrl";
#define ClipBlit(srcRP, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm) __ClipBlit(GfxBase, (srcRP), (xSrc), (ySrc), (destRP), (xDest), (yDest), (xSize), (ySize), (minterm))

BOOL __XorRectRegion(void *, struct Region * region, CONST struct Rectangle * rectangle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-558\n"
	"\tbctrl";
#define XorRectRegion(region, rectangle) __XorRectRegion(GfxBase, (region), (rectangle))

VOID __FreeCprList(void *, struct cprlist * cprList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-564\n"
	"\tbctrl";
#define FreeCprList(cprList) __FreeCprList(GfxBase, (cprList))

struct ColorMap * __GetColorMap(void *, LONG entries) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-570\n"
	"\tbctrl";
#define GetColorMap(entries) __GetColorMap(GfxBase, (entries))

VOID __FreeColorMap(void *, struct ColorMap * colorMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-576\n"
	"\tbctrl";
#define FreeColorMap(colorMap) __FreeColorMap(GfxBase, (colorMap))

ULONG __GetRGB4(void *, struct ColorMap * colorMap, LONG entry) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-582\n"
	"\tbctrl";
#define GetRGB4(colorMap, entry) __GetRGB4(GfxBase, (colorMap), (entry))

VOID __ScrollVPort(void *, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-588\n"
	"\tbctrl";
#define ScrollVPort(vp) __ScrollVPort(GfxBase, (vp))

struct CopList * __UCopperListInit(void *, struct UCopList * uCopList, LONG n) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-594\n"
	"\tbctrl";
#define UCopperListInit(uCopList, n) __UCopperListInit(GfxBase, (uCopList), (n))

VOID __FreeGBuffers(void *, struct AnimOb * anOb, struct RastPort * rp, LONG flag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-600\n"
	"\tbctrl";
#define FreeGBuffers(anOb, rp, flag) __FreeGBuffers(GfxBase, (anOb), (rp), (flag))

VOID __BltBitMapRastPort(void *, CONST struct BitMap * srcBitMap, LONG xSrc, LONG ySrc, struct RastPort * destRP, LONG xDest, LONG yDest, LONG xSize, LONG ySize, ULONG minterm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tli\t3,-606\n"
	"\tbctrl";
#define BltBitMapRastPort(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm) __BltBitMapRastPort(GfxBase, (srcBitMap), (xSrc), (ySrc), (destRP), (xDest), (yDest), (xSize), (ySize), (minterm))

BOOL __OrRegionRegion(void *, CONST struct Region * srcRegion, struct Region * destRegion) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-612\n"
	"\tbctrl";
#define OrRegionRegion(srcRegion, destRegion) __OrRegionRegion(GfxBase, (srcRegion), (destRegion))

BOOL __XorRegionRegion(void *, CONST struct Region * srcRegion, struct Region * destRegion) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-618\n"
	"\tbctrl";
#define XorRegionRegion(srcRegion, destRegion) __XorRegionRegion(GfxBase, (srcRegion), (destRegion))

BOOL __AndRegionRegion(void *, CONST struct Region * srcRegion, struct Region * destRegion) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-624\n"
	"\tbctrl";
#define AndRegionRegion(srcRegion, destRegion) __AndRegionRegion(GfxBase, (srcRegion), (destRegion))

VOID __SetRGB4CM(void *, struct ColorMap * colorMap, LONG index, ULONG red, ULONG green, ULONG blue) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-630\n"
	"\tbctrl";
#define SetRGB4CM(colorMap, index, red, green, blue) __SetRGB4CM(GfxBase, (colorMap), (index), (red), (green), (blue))

VOID __BltMaskBitMapRastPort(void *, CONST struct BitMap * srcBitMap, LONG xSrc, LONG ySrc, struct RastPort * destRP, LONG xDest, LONG yDest, LONG xSize, LONG ySize, ULONG minterm, CONST PLANEPTR bltMask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-636\n"
	"\tbctrl";
#define BltMaskBitMapRastPort(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask) __BltMaskBitMapRastPort(GfxBase, (srcBitMap), (xSrc), (ySrc), (destRP), (xDest), (yDest), (xSize), (ySize), (minterm), (bltMask))

BOOL __AttemptLockLayerRom(void *, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,52(2)\n"
	"\tli\t3,-654\n"
	"\tbctrl";
#define AttemptLockLayerRom(layer) __AttemptLockLayerRom(GfxBase, (layer))

APTR __GfxNew(void *, ULONG gfxNodeType) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-660\n"
	"\tbctrl";
#define GfxNew(gfxNodeType) __GfxNew(GfxBase, (gfxNodeType))

VOID __GfxFree(void *, APTR gfxNodePtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-666\n"
	"\tbctrl";
#define GfxFree(gfxNodePtr) __GfxFree(GfxBase, (gfxNodePtr))

VOID __GfxAssociate(void *, CONST APTR associateNode, APTR gfxNodePtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-672\n"
	"\tbctrl";
#define GfxAssociate(associateNode, gfxNodePtr) __GfxAssociate(GfxBase, (associateNode), (gfxNodePtr))

VOID __BitMapScale(void *, struct BitScaleArgs * bitScaleArgs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-678\n"
	"\tbctrl";
#define BitMapScale(bitScaleArgs) __BitMapScale(GfxBase, (bitScaleArgs))

UWORD __ScalerDiv(void *, ULONG factor, ULONG numerator, ULONG denominator) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tli\t3,-684\n"
	"\tbctrl";
#define ScalerDiv(factor, numerator, denominator) __ScalerDiv(GfxBase, (factor), (numerator), (denominator))

WORD __TextExtent(void *, struct RastPort * rp, CONST_STRPTR string, LONG count, struct TextExtent * textExtent) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-690\n"
	"\tbctrl";
#define TextExtent(rp, string, count, textExtent) __TextExtent(GfxBase, (rp), (string), (count), (textExtent))

ULONG __TextFit(void *, struct RastPort * rp, CONST_STRPTR string, ULONG strLen, CONST struct TextExtent * textExtent, CONST struct TextExtent * constrainingExtent, LONG strDirection, ULONG constrainingBitWidth, ULONG constrainingBitHeight) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tstw\t8,44(2)\n"
	"\tstw\t9,4(2)\n"
	"\tstw\t10,8(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,12(2)\n"
	"\tli\t3,-696\n"
	"\tbctrl";
#define TextFit(rp, string, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight) __TextFit(GfxBase, (rp), (string), (strLen), (textExtent), (constrainingExtent), (strDirection), (constrainingBitWidth), (constrainingBitHeight))

APTR __GfxLookUp(void *, CONST APTR associateNode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-702\n"
	"\tbctrl";
#define GfxLookUp(associateNode) __GfxLookUp(GfxBase, (associateNode))

BOOL __VideoControl(void *, struct ColorMap * colorMap, struct TagItem * tagarray) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-708\n"
	"\tbctrl";
#define VideoControl(colorMap, tagarray) __VideoControl(GfxBase, (colorMap), (tagarray))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __VideoControlTags(void *, struct ColorMap * colorMap, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-708\n"
	"\tbctrl";
#define VideoControlTags(colorMap, ...) __VideoControlTags(GfxBase, (colorMap), __VA_ARGS__)
#endif

struct MonitorSpec * __OpenMonitor(void *, CONST_STRPTR monitorName, ULONG displayID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-714\n"
	"\tbctrl";
#define OpenMonitor(monitorName, displayID) __OpenMonitor(GfxBase, (monitorName), (displayID))

BOOL __CloseMonitor(void *, struct MonitorSpec * monitorSpec) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-720\n"
	"\tbctrl";
#define CloseMonitor(monitorSpec) __CloseMonitor(GfxBase, (monitorSpec))

DisplayInfoHandle __FindDisplayInfo(void *, ULONG displayID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-726\n"
	"\tbctrl";
#define FindDisplayInfo(displayID) __FindDisplayInfo(GfxBase, (displayID))

ULONG __NextDisplayInfo(void *, ULONG displayID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-732\n"
	"\tbctrl";
#define NextDisplayInfo(displayID) __NextDisplayInfo(GfxBase, (displayID))

ULONG __GetDisplayInfoData(void *, CONST DisplayInfoHandle handle, APTR buf, ULONG size, ULONG tagID, ULONG displayID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tli\t3,-756\n"
	"\tbctrl";
#define GetDisplayInfoData(handle, buf, size, tagID, displayID) __GetDisplayInfoData(GfxBase, (handle), (buf), (size), (tagID), (displayID))

VOID __FontExtent(void *, CONST struct TextFont * font, struct TextExtent * fontExtent) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-762\n"
	"\tbctrl";
#define FontExtent(font, fontExtent) __FontExtent(GfxBase, (font), (fontExtent))

LONG __ReadPixelLine8(void *, struct RastPort * rp, ULONG xstart, ULONG ystart, ULONG width, UBYTE * array, struct RastPort * tempRP) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,36(2)\n"
	"\tli\t3,-768\n"
	"\tbctrl";
#define ReadPixelLine8(rp, xstart, ystart, width, array, tempRP) __ReadPixelLine8(GfxBase, (rp), (xstart), (ystart), (width), (array), (tempRP))

LONG __WritePixelLine8(void *, struct RastPort * rp, ULONG xstart, ULONG ystart, ULONG width, UBYTE * array, struct RastPort * tempRP) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,36(2)\n"
	"\tli\t3,-774\n"
	"\tbctrl";
#define WritePixelLine8(rp, xstart, ystart, width, array, tempRP) __WritePixelLine8(GfxBase, (rp), (xstart), (ystart), (width), (array), (tempRP))

LONG __ReadPixelArray8(void *, struct RastPort * rp, ULONG xstart, ULONG ystart, ULONG xstop, ULONG ystop, UBYTE * array, struct RastPort * temprp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,40(2)\n"
	"\tstw\t10,36(2)\n"
	"\tli\t3,-780\n"
	"\tbctrl";
#define ReadPixelArray8(rp, xstart, ystart, xstop, ystop, array, temprp) __ReadPixelArray8(GfxBase, (rp), (xstart), (ystart), (xstop), (ystop), (array), (temprp))

LONG __WritePixelArray8(void *, struct RastPort * rp, ULONG xstart, ULONG ystart, ULONG xstop, ULONG ystop, UBYTE * array, struct RastPort * temprp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,40(2)\n"
	"\tstw\t10,36(2)\n"
	"\tli\t3,-786\n"
	"\tbctrl";
#define WritePixelArray8(rp, xstart, ystart, xstop, ystop, array, temprp) __WritePixelArray8(GfxBase, (rp), (xstart), (ystart), (xstop), (ystop), (array), (temprp))

LONG __GetVPModeID(void *, CONST struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-792\n"
	"\tbctrl";
#define GetVPModeID(vp) __GetVPModeID(GfxBase, (vp))

LONG __ModeNotAvailable(void *, ULONG modeID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-798\n"
	"\tbctrl";
#define ModeNotAvailable(modeID) __ModeNotAvailable(GfxBase, (modeID))

WORD __WeighTAMatch(void *, struct TTextAttr * reqTextAttr, struct TextAttr * targetTextAttr, struct TagItem * targetTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-804\n"
	"\tbctrl";
#define WeighTAMatch(reqTextAttr, targetTextAttr, targetTags) __WeighTAMatch(GfxBase, (reqTextAttr), (targetTextAttr), (targetTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
WORD __linearvarargs __WeighTAMatchTags(void *, struct TTextAttr * reqTextAttr, struct TextAttr * targetTextAttr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-804\n"
	"\tbctrl";
#define WeighTAMatchTags(reqTextAttr, targetTextAttr, ...) __WeighTAMatchTags(GfxBase, (reqTextAttr), (targetTextAttr), __VA_ARGS__)
#endif

VOID __EraseRect(void *, struct RastPort * rp, LONG xMin, LONG yMin, LONG xMax, LONG yMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-810\n"
	"\tbctrl";
#define EraseRect(rp, xMin, yMin, xMax, yMax) __EraseRect(GfxBase, (rp), (xMin), (yMin), (xMax), (yMax))

ULONG __ExtendFont(void *, struct TextFont * font, CONST struct TagItem * fontTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-816\n"
	"\tbctrl";
#define ExtendFont(font, fontTags) __ExtendFont(GfxBase, (font), (fontTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __ExtendFontTags(void *, struct TextFont * font, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-816\n"
	"\tbctrl";
#define ExtendFontTags(font, ...) __ExtendFontTags(GfxBase, (font), __VA_ARGS__)
#endif

VOID __StripFont(void *, struct TextFont * font) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-822\n"
	"\tbctrl";
#define StripFont(font) __StripFont(GfxBase, (font))

UWORD __CalcIVG(void *, struct View * v, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-828\n"
	"\tbctrl";
#define CalcIVG(v, vp) __CalcIVG(GfxBase, (v), (vp))

LONG __AttachPalExtra(void *, struct ColorMap * cm, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-834\n"
	"\tbctrl";
#define AttachPalExtra(cm, vp) __AttachPalExtra(GfxBase, (cm), (vp))

LONG __ObtainBestPenA(void *, struct ColorMap * cm, ULONG r, ULONG g, ULONG b, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-840\n"
	"\tbctrl";
#define ObtainBestPenA(cm, r, g, b, tags) __ObtainBestPenA(GfxBase, (cm), (r), (g), (b), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __ObtainBestPen(void *, struct ColorMap * cm, ULONG r, ULONG g, ULONG b, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-840\n"
	"\tbctrl";
#define ObtainBestPen(cm, r, g, b, ...) __ObtainBestPen(GfxBase, (cm), (r), (g), (b), __VA_ARGS__)
#endif

VOID __SetRGB32(void *, struct ViewPort * vp, ULONG n, ULONG r, ULONG g, ULONG b) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-852\n"
	"\tbctrl";
#define SetRGB32(vp, n, r, g, b) __SetRGB32(GfxBase, (vp), (n), (r), (g), (b))

ULONG __GetAPen(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-858\n"
	"\tbctrl";
#define GetAPen(rp) __GetAPen(GfxBase, (rp))

ULONG __GetBPen(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-864\n"
	"\tbctrl";
#define GetBPen(rp) __GetBPen(GfxBase, (rp))

ULONG __GetDrMd(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-870\n"
	"\tbctrl";
#define GetDrMd(rp) __GetDrMd(GfxBase, (rp))

ULONG __GetOutlinePen(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-876\n"
	"\tbctrl";
#define GetOutlinePen(rp) __GetOutlinePen(GfxBase, (rp))

VOID __LoadRGB32(void *, struct ViewPort * vp, CONST ULONG * table) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-882\n"
	"\tbctrl";
#define LoadRGB32(vp, table) __LoadRGB32(GfxBase, (vp), (table))

ULONG __SetChipRev(void *, ULONG want) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-888\n"
	"\tbctrl";
#define SetChipRev(want) __SetChipRev(GfxBase, (want))

VOID __SetABPenDrMd(void *, struct RastPort * rp, ULONG apen, ULONG bpen, ULONG drawmode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-894\n"
	"\tbctrl";
#define SetABPenDrMd(rp, apen, bpen, drawmode) __SetABPenDrMd(GfxBase, (rp), (apen), (bpen), (drawmode))

VOID __GetRGB32(void *, CONST struct ColorMap * cm, ULONG firstcolor, ULONG ncolors, ULONG * table) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-900\n"
	"\tbctrl";
#define GetRGB32(cm, firstcolor, ncolors, table) __GetRGB32(GfxBase, (cm), (firstcolor), (ncolors), (table))

struct BitMap * __AllocBitMap(void *, ULONG sizex, ULONG sizey, ULONG depth, ULONG flags, CONST struct BitMap * friend_bitmap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tstw\t8,32(2)\n"
	"\tli\t3,-918\n"
	"\tbctrl";
#define AllocBitMap(sizex, sizey, depth, flags, friend_bitmap) __AllocBitMap(GfxBase, (sizex), (sizey), (depth), (flags), (friend_bitmap))

VOID __FreeBitMap(void *, struct BitMap * bm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-924\n"
	"\tbctrl";
#define FreeBitMap(bm) __FreeBitMap(GfxBase, (bm))

LONG __GetExtSpriteA(void *, struct ExtSprite * ss, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-930\n"
	"\tbctrl";
#define GetExtSpriteA(ss, tags) __GetExtSpriteA(GfxBase, (ss), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __GetExtSprite(void *, struct ExtSprite * ss, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-930\n"
	"\tbctrl";
#define GetExtSprite(ss, ...) __GetExtSprite(GfxBase, (ss), __VA_ARGS__)
#endif

ULONG __CoerceMode(void *, struct ViewPort * vp, ULONG monitorid, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-936\n"
	"\tbctrl";
#define CoerceMode(vp, monitorid, flags) __CoerceMode(GfxBase, (vp), (monitorid), (flags))

VOID __ChangeVPBitMap(void *, struct ViewPort * vp, struct BitMap * bm, struct DBufInfo * db) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-942\n"
	"\tbctrl";
#define ChangeVPBitMap(vp, bm, db) __ChangeVPBitMap(GfxBase, (vp), (bm), (db))

VOID __ReleasePen(void *, struct ColorMap * cm, ULONG n) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-948\n"
	"\tbctrl";
#define ReleasePen(cm, n) __ReleasePen(GfxBase, (cm), (n))

ULONG __ObtainPen(void *, struct ColorMap * cm, ULONG n, ULONG r, ULONG g, ULONG b, LONG f) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tli\t3,-954\n"
	"\tbctrl";
#define ObtainPen(cm, n, r, g, b, f) __ObtainPen(GfxBase, (cm), (n), (r), (g), (b), (f))

ULONG __GetBitMapAttr(void *, CONST struct BitMap * bm, ULONG attrnum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-960\n"
	"\tbctrl";
#define GetBitMapAttr(bm, attrnum) __GetBitMapAttr(GfxBase, (bm), (attrnum))

struct DBufInfo * __AllocDBufInfo(void *, struct ViewPort * vp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-966\n"
	"\tbctrl";
#define AllocDBufInfo(vp) __AllocDBufInfo(GfxBase, (vp))

VOID __FreeDBufInfo(void *, struct DBufInfo * dbi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-972\n"
	"\tbctrl";
#define FreeDBufInfo(dbi) __FreeDBufInfo(GfxBase, (dbi))

ULONG __SetOutlinePen(void *, struct RastPort * rp, ULONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-978\n"
	"\tbctrl";
#define SetOutlinePen(rp, pen) __SetOutlinePen(GfxBase, (rp), (pen))

ULONG __SetWriteMask(void *, struct RastPort * rp, ULONG msk) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-984\n"
	"\tbctrl";
#define SetWriteMask(rp, msk) __SetWriteMask(GfxBase, (rp), (msk))

VOID __SetMaxPen(void *, struct RastPort * rp, ULONG maxpen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-990\n"
	"\tbctrl";
#define SetMaxPen(rp, maxpen) __SetMaxPen(GfxBase, (rp), (maxpen))

VOID __SetRGB32CM(void *, struct ColorMap * cm, ULONG n, ULONG r, ULONG g, ULONG b) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-996\n"
	"\tbctrl";
#define SetRGB32CM(cm, n, r, g, b) __SetRGB32CM(GfxBase, (cm), (n), (r), (g), (b))

VOID __ScrollRasterBF(void *, struct RastPort * rp, LONG dx, LONG dy, LONG xMin, LONG yMin, LONG xMax, LONG yMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,20(2)\n"
	"\tli\t3,-1002\n"
	"\tbctrl";
#define ScrollRasterBF(rp, dx, dy, xMin, yMin, xMax, yMax) __ScrollRasterBF(GfxBase, (rp), (dx), (dy), (xMin), (yMin), (xMax), (yMax))

LONG __FindColor(void *, struct ColorMap * cm, ULONG r, ULONG g, ULONG b, LONG maxcolor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,44(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tstw\t8,16(2)\n"
	"\tli\t3,-1008\n"
	"\tbctrl";
#define FindColor(cm, r, g, b, maxcolor) __FindColor(GfxBase, (cm), (r), (g), (b), (maxcolor))

struct ExtSprite * __AllocSpriteDataA(void *, CONST struct BitMap * bm, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-1020\n"
	"\tbctrl";
#define AllocSpriteDataA(bm, tags) __AllocSpriteDataA(GfxBase, (bm), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct ExtSprite * __linearvarargs __AllocSpriteData(void *, CONST struct BitMap * bm, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-1020\n"
	"\tbctrl";
#define AllocSpriteData(bm, ...) __AllocSpriteData(GfxBase, (bm), __VA_ARGS__)
#endif

LONG __ChangeExtSpriteA(void *, struct ViewPort * vp, struct ExtSprite * oldsprite, struct ExtSprite * newsprite, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-1026\n"
	"\tbctrl";
#define ChangeExtSpriteA(vp, oldsprite, newsprite, tags) __ChangeExtSpriteA(GfxBase, (vp), (oldsprite), (newsprite), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __ChangeExtSprite(void *, struct ViewPort * vp, struct ExtSprite * oldsprite, struct ExtSprite * newsprite, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-1026\n"
	"\tbctrl";
#define ChangeExtSprite(vp, oldsprite, newsprite, ...) __ChangeExtSprite(GfxBase, (vp), (oldsprite), (newsprite), __VA_ARGS__)
#endif

VOID __FreeSpriteData(void *, struct ExtSprite * sp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tli\t3,-1032\n"
	"\tbctrl";
#define FreeSpriteData(sp) __FreeSpriteData(GfxBase, (sp))

VOID __SetRPAttrsA(void *, struct RastPort * rp, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-1038\n"
	"\tbctrl";
#define SetRPAttrsA(rp, tags) __SetRPAttrsA(GfxBase, (rp), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetRPAttrs(void *, struct RastPort * rp, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-1038\n"
	"\tbctrl";
#define SetRPAttrs(rp, ...) __SetRPAttrs(GfxBase, (rp), __VA_ARGS__)
#endif

VOID __GetRPAttrsA(void *, CONST struct RastPort * rp, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-1044\n"
	"\tbctrl";
#define GetRPAttrsA(rp, tags) __GetRPAttrsA(GfxBase, (rp), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GetRPAttrs(void *, CONST struct RastPort * rp, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-1044\n"
	"\tbctrl";
#define GetRPAttrs(rp, ...) __GetRPAttrs(GfxBase, (rp), __VA_ARGS__)
#endif

ULONG __BestModeIDA(void *, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-1050\n"
	"\tbctrl";
#define BestModeIDA(tags) __BestModeIDA(GfxBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __BestModeID(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-1050\n"
	"\tbctrl";
#define BestModeID(...) __BestModeID(GfxBase, __VA_ARGS__)
#endif

VOID __WriteChunkyPixels(void *, struct RastPort * rp, ULONG xstart, ULONG ystart, ULONG xstop, ULONG ystop, CONST UBYTE * array, LONG bytesperrow) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,40(2)\n"
	"\tstw\t10,16(2)\n"
	"\tli\t3,-1056\n"
	"\tbctrl";
#define WriteChunkyPixels(rp, xstart, ystart, xstop, ystop, array, bytesperrow) __WriteChunkyPixels(GfxBase, (rp), (xstart), (ystart), (xstop), (ystop), (array), (bytesperrow))

struct TextFont * __OpenFontTagList(void *, struct TextAttr * textattr, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-1062\n"
	"\tbctrl";
#define OpenFontTagList(textattr, tags) __OpenFontTagList(GfxBase, (textattr), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct TextFont * __linearvarargs __OpenFontTags(void *, struct TextAttr * textattr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-1062\n"
	"\tbctrl";
#define OpenFontTags(textattr, ...) __OpenFontTags(GfxBase, (textattr), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_GRAPHICS_H  */
